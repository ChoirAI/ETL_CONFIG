CREATE OR REPLACE PROCEDURE process_fact_iqvia_qtr_corp_rnk_3()
LANGUAGE plpgsql
AS $$
DECLARE
    max_year_start DATE;
    current_period DATE;
    period_cursor CURSOR FOR
        SELECT DISTINCT TO_DATE("period", 'dd/mm/yyyy') AS period_date
        FROM fact_iqvia_qtr_corp_rnk_2
        WHERE TO_DATE("period", 'dd/mm/yyyy') >= (
            SELECT TO_DATE(TO_CHAR(MAX(TO_DATE("period", 'dd/mm/yyyy')) - INTERVAL '2 year', 'yyyy'), 'yyyy')
            FROM fact_iqvia_qtr_corp_rnk_2
        )
        ORDER BY TO_DATE("period", 'dd/mm/yyyy');
BEGIN
    -- 删除目标表（如果存在）
    DROP TABLE IF EXISTS fact_iqvia_qtr_corp_rnk_3;

    -- 创建目标表结构
    CREATE TABLE fact_iqvia_qtr_corp_rnk_3 AS
    SELECT "cluster", cluster_i, cluster_ii, corporation, therapy_area, load_dt, "period", '' AS ta_key,
           days_of_therapy, units, us_dollars_actual, ly_us_dollars_actual, ly_units
    FROM fact_iqvia_qtr_corp_rnk_2
    WHERE 1 = 2;

    -- 获取最大年份的起始日期
    SELECT TO_DATE(TO_CHAR(MAX(TO_DATE("period", 'dd/mm/yyyy')) - INTERVAL '2 year', 'yyyy'), 'yyyy')
    INTO max_year_start
    FROM fact_iqvia_qtr_corp_rnk_2;

    -- 打开游标并逐月处理数据
    OPEN period_cursor;
    LOOP
        FETCH period_cursor INTO current_period;
        EXIT WHEN NOT FOUND;

        RAISE NOTICE 'Processing period: %', current_period;

        -- 插入按当前周期处理的数据
        INSERT INTO fact_iqvia_qtr_corp_rnk_3
        WITH corp_cte AS (
            SELECT DISTINCT corporation
            FROM fact_iqvia_qtr_corp_rnk_2
        ),
        ta_cte AS (
            SELECT DISTINCT therapy_area
            FROM fact_iqvia_qtr_corp_rnk_2
        ),
        geo_cte AS (
            SELECT DISTINCT "cluster", cluster_i, cluster_ii
            FROM fact_iqvia_qtr_corp_rnk_2
        ),
        cal_cte AS (
            SELECT DISTINCT "period", load_dt
            FROM fact_iqvia_qtr_corp_rnk_2
            WHERE TO_DATE("period", 'dd/mm/yyyy') = current_period
        ),
        base_data_cte AS (
            SELECT
                geo."cluster",
                geo.cluster_i,
                geo.cluster_ii,
                corp.corporation,
                ta.therapy_area,
                cal.load_dt,
                cal."period",
                MD5(ta.therapy_area || cal."period" || geo.cluster_ii) AS ta_key
            FROM corp_cte corp
            JOIN ta_cte ta ON TRUE
            JOIN cal_cte cal ON TRUE
            JOIN geo_cte geo ON TRUE
        ),
        f2_data_cte AS (
            SELECT
                corporation,
                therapy_area,
                "period",
                cluster_ii,
                days_of_therapy,
                units,
                us_dollars_actual,
                ly_us_dollars_actual,
                ly_units
            FROM fact_iqvia_qtr_corp_rnk_2
            WHERE TO_DATE("period", 'dd/mm/yyyy') = current_period
        )
        SELECT
            base."cluster",
            base.cluster_i,
            base.cluster_ii,
            base.corporation,
            base.therapy_area,
            base.load_dt,
            base."period",
            base.ta_key,
            f2.days_of_therapy,
            f2.units,
            f2.us_dollars_actual,
            f2.ly_us_dollars_actual,
            f2.ly_units
        FROM base_data_cte base
        LEFT JOIN f2_data_cte f2
            ON base.corporation = f2.corporation
           AND base.therapy_area = f2.therapy_area
           AND base."period" = f2."period"
           AND base.cluster_ii = f2.cluster_ii;
    END LOOP;

    CLOSE period_cursor;
    
drop index if exists fact_iqvia_qtr_corp_rnk_ta_idx;
CREATE INDEX fact_iqvia_qtr_corp_rnk_ta_idx ON fact_iqvia_qtr_corp_rnk_3 USING hash (ta_key);


-- 6. Drop internal tables
drop table if exists fact_iqvia_qtr_corp_rnk cascade;
alter table fact_iqvia_qtr_corp_rnk_3 rename to fact_iqvia_qtr_corp_rnk;
drop table fact_iqvia_qtr_corp_rnk_1;
drop table fact_iqvia_qtr_corp_rnk_2;

alter table fact_iqvia_qtr_ta owner to az_user_dw;
alter table fact_iqvia_qtr_corp_rnk owner to az_user_dw;
END;
$$;

CALL process_fact_iqvia_qtr_corp_rnk_3();