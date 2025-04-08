CREATE OR REPLACE PROCEDURE process_fact_iqvia_qtr_gmd_ms()
LANGUAGE plpgsql
AS $$
DECLARE
    max_year_start DATE;
    current_period DATE;
    period_cursor CURSOR FOR
        SELECT DISTINCT to_date("period", 'dd/mm/yyyy') AS period_date
        FROM fact_iqvia_qtr_gmd_ms_3
        WHERE to_date("period", 'dd/mm/yyyy') >= max_year_start
        ORDER BY to_date("period", 'dd/mm/yyyy');
BEGIN
    -- 设置 work_mem
    SET work_mem = '64MB';

    -- 删除目标表（如果存在）
    DROP TABLE IF EXISTS fact_iqvia_qtr_gmd_ms;

    -- 创建目标表结构
    CREATE TABLE fact_iqvia_qtr_gmd_ms AS
    SELECT * FROM fact_iqvia_qtr_gmd_ms_arc WHERE 1 = 2;

    -- 获取最大年份的起始日期
    SELECT to_date(to_char(max(to_date(period, 'dd/mm/yyyy')) - INTERVAL '1 year', 'yyyy'), 'yyyy')
    INTO max_year_start
    FROM fact_iqvia_qtr_gmd_ms_3;

    -- 打开游标并逐月处理数据
    OPEN period_cursor;
    LOOP
        FETCH period_cursor INTO current_period;
        EXIT WHEN NOT FOUND;

        RAISE NOTICE 'Processing period: %', current_period;

        -- 插入按当前周期处理的数据
        INSERT INTO fact_iqvia_qtr_gmd_ms
        WITH cal AS (
            SELECT "period", MAX(load_dt) AS load_dt
            FROM fact_iqvia_qtr_gmd_ms_3
            WHERE to_date(period, 'dd/mm/yyyy') = current_period
            GROUP BY "period"
        ),
        geo AS (
            SELECT DISTINCT "cluster", cluster_i, cluster_ii
            FROM fact_iqvia_qtr_gmd_ms_3
        ),
        prod AS (
            SELECT
                gmd_sub_mkt,
                product_key,
                MAX(corporation) AS corporation,
                MAX(therapy_area) AS therapy_area,
                MAX(gmd) AS gmd,
                MAX(product_family) AS product_family,
                MAX(international_product) AS international_product,
                MAX(international_product_raw) AS international_product_raw,
                MAX(local_product) AS local_product
            FROM fact_iqvia_qtr_gmd_ms_3
            GROUP BY gmd_sub_mkt, product_key
        ),
        prod_cal_geo AS (
            SELECT
                geo."cluster",
                geo.cluster_i,
                geo.cluster_ii,
                prod.corporation,
                prod.therapy_area,
                prod.gmd,
                prod.gmd_sub_mkt,
                prod.product_family,
                prod.international_product,
                prod.international_product_raw,
                prod.local_product,
                prod.product_key,
                cal.load_dt,
                cal."period"
            FROM prod
            JOIN cal ON TRUE
            JOIN geo ON TRUE
        ),
        step1 AS (
            SELECT
                pcg."cluster",
                pcg.cluster_i,
                pcg.cluster_ii,
                pcg.corporation,
                pcg.therapy_area,
                pcg.gmd,
                pcg.gmd_sub_mkt,
                pcg.product_family,
                pcg.international_product,
                pcg.international_product_raw,
                pcg.local_product,
                pcg.product_key,
                pcg.load_dt,
                pcg."period",
                gmd.class_size AS gmd_sub_market_size,
                gmd.class_vol_size AS gmd_sub_market_vol_size,
                gmd.ly_class_size AS ly_gmd_sub_market_size,
                gmd.ly_class_vol_size AS ly_gmd_sub_market_vol_size
            FROM prod_cal_geo pcg
            LEFT JOIN fact_iqvia_qtr_class gmd
                ON pcg.gmd_sub_mkt = gmd.gmd_sub_mkt
                AND pcg."period" = gmd."period"
                AND pcg.cluster_ii = gmd.cluster_ii
        )
        SELECT
            step1."cluster",
            step1.cluster_i,
            step1.cluster_ii,
            step1.corporation,
            step1.therapy_area,
            step1.gmd,
            step1.gmd_sub_mkt,
            step1.product_family,
            step1.international_product,
            step1.international_product_raw,
            step1.local_product,
            step1.product_key,
            step1.load_dt,
            step1."period",
            f3.days_of_therapy,
            f3.units,
            f3.volume,
            f3.us_dollars_actual,
            step1.gmd_sub_market_size,
            step1.gmd_sub_market_vol_size,
            f3.ly_us_dollars_actual,
            f3.ly_volume,
            step1.ly_gmd_sub_market_size,
            step1.ly_gmd_sub_market_vol_size
        FROM step1
        LEFT JOIN fact_iqvia_qtr_gmd_ms_3 f3
            ON step1.product_key = f3.product_key
            AND step1."period" = f3."period"
            AND step1.cluster_ii = f3.cluster_ii;
    END LOOP;

    CLOSE period_cursor;
    
    -- 7. Drop internal tables
drop table fact_iqvia_qtr_gmd_ms_1;
drop table fact_iqvia_qtr_gmd_ms_2;
drop table fact_iqvia_qtr_gmd_ms_3;
alter table fact_iqvia_qtr_gmd_ms owner to az_user_dw;
alter table fact_iqvia_qtr_class owner to az_user_dw;



drop table if exists iqvia_gmd_product_arc;
alter table iqvia_gmd_product rename to iqvia_gmd_product_arc;

create table iqvia_gmd_product as
select distinct therapy_area, gmd, gmd_sub_mkt, product_family, international_product, international_product_raw from fact_iqvia_qtr_gmd_ms
union
select distinct therapy_area, gmd, gmd_sub_mkt, product_family, international_product, international_product_raw from fact_iqvia_mth_gmd_ms;

alter table iqvia_gmd_product owner to az_user_dw;
END;
$$;

CALL process_fact_iqvia_qtr_gmd_ms();