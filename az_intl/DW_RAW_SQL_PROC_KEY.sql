-- DROP PROCEDURE public.proc_cleanse_dim_geo();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_dim_geo()
 LANGUAGE plpgsql
AS $procedure$
BEGIN


--=============================================================================================================================
-- dim_geo
--=============================================================================================================================
RAISE NOTICE 'Dim Geo started';
drop table if exists dim_geo_arc;
alter table dim_geo rename to dim_geo_arc;

DROP TABLE if exists public.dim_geo cascade;

CREATE TABLE public.dim_geo (
        entity_code varchar(100) NULL,
        entity_description varchar(100) NULL,
        geo_lvl1 varchar(100) NULL,
        geo_lvl2 varchar(100) NULL,
        geo_lvl3 varchar(100) NULL,
        geo_lvl4 varchar(100) NULL,
        geo_lvl5 varchar(100) NULL,
        geo_lvl6 varchar(100) NULL,
        geo_lvl7 varchar(100) NULL,
        geo_lvl8 varchar(100) NULL,
        geo_lvl3_raw varchar(50) NULL,
        geo_lvl5_raw varchar(50) NULL
);

-- 1. Standardize column names and column type
drop table if exists dim_geo_1;
create table dim_geo_1 as
select
        entity_code,
        entity_description,
        geo_lvl1,
        geo_lvl2,
        geo_lvl3,
        geo_lvl4,
        geo_lvl5,
        geo_lvl6,
        geo_lvl7,
        geo_lvl8
from
        dim_geo_raw; --254
--select entity_code, count(*) from dim_geo_1 group by 1 having count(*)>1;

RAISE NOTICE 'Dim Geo Step1 - Standardize columns done';

-- 2. Cleanse column values
-- 2.1 Treate China & HongKong as one area
alter table dim_geo_1 add "geo_lvl3_raw" varchar(50) NULL;
UPDATE dim_geo_1 SET "geo_lvl3_raw" = "geo_lvl3";
UPDATE dim_geo_1 SET "geo_lvl3" = 'China & HongKong' where "geo_lvl3_raw" in ('China','Hong Kong');

-- 2.2 Handle C. America
alter table dim_geo_1 add "geo_lvl5_raw" varchar(50) NULL;
update dim_geo_1 set "geo_lvl5_raw" = "geo_lvl5";
update dim_geo_1 set "geo_lvl5"='C. America'  where "geo_lvl5_raw" in ('Costa Rica','El Salvador','Guatemala','Honduras','Nicaragua','Panama'); --12

RAISE NOTICE 'Dim Geo Step2 - Cleanse column values done';

-- 3. Drop internal tables
DROP TABLE if exists public.dim_geo cascade;
alter table dim_geo_1 rename to dim_geo;
alter table dim_geo owner to az_user_dw;

RAISE NOTICE 'Dim Geo Ready';


END;
$procedure$
;


-- DROP PROCEDURE public.proc_cleanse_dim_product();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_dim_product()
 LANGUAGE plpgsql
AS $procedure$
BEGIN
        

--=============================================================================================================================
-- dim_product
--=============================================================================================================================
RAISE NOTICE 'Dim Product started';
drop table if exists dim_product_arc;
alter table dim_product rename to dim_product_arc;

DROP TABLE if exists public.dim_product cascade;

CREATE TABLE public.dim_product (
        product_code varchar(100) NULL,
        product_description varchar(100) NULL,
        brand_lv1 varchar(100) NULL,
        brand_lv2 varchar(100) NULL,
        brand_lv3 varchar(100) NULL,
        brand_lv4 varchar(100) NULL,
        brand_lv5 varchar(100) NULL,
        brand_lv6 varchar(100) NULL,
        brand_lv7 varchar(100) NULL,
        brand_lv8 varchar(100) NULL,
        ex_covid bool DEFAULT true NOT NULL,
        volume_type varchar(20) NULL,
        pri_gmd_sub_mkt varchar(50) NULL
);

-- 1. Standardize column names and column type
drop table if exists dim_product_1;
create table dim_product_1 as 
select
        product_code,
        product_description,
        brand_lv1,
        brand_lv2,
        brand_lv3,
        brand_lv4,
        brand_lv5,
        brand_lv6,
        brand_lv7,
        brand_lv8
from
        dim_product_raw; --417
--select product_code, count(*) from dim_product_1 group by 1 having count(*)>1;
        
RAISE NOTICE 'Dim Product Step1 - Standardize columns done';

-- 2. Cleanse column values 
update dim_product_1 set brand_lv2 = replace(brand_lv2, '(Alt 9)', '') where brand_lv2 like '%(Alt 9)%';--413
update dim_product_1 set brand_lv3 = replace(brand_lv3, '(Alt 9)', '') where brand_lv3 like '%(Alt 9)%';--413
update dim_product_1 set brand_lv4 = replace(brand_lv4, '(Alt 9)', '') where brand_lv4 like '%(Alt 9)%';--312
update dim_product_1 set brand_lv5 = replace(brand_lv5, '(Alt 9)', '') where brand_lv5 like '%(Alt 9)%';--385
update dim_product_1 set brand_lv6 = replace(brand_lv6, '(Alt 9)', '') where brand_lv6 like '%(Alt 9)%';--62

update dim_product_1 set brand_lv2 = 'BBU' where brand_lv2 = 'BioPharma TA';--322
update dim_product_1 set brand_lv2 = 'OBU' where brand_lv2 = 'Oncology';--70
update dim_product_1 set brand_lv2 = 'RDU' where brand_lv2 in ('Rare Diseases','Rare Disease');--20
update dim_product_1 set brand_lv3 = replace(brand_lv3,'BioPharmaceuticals: ','') where brand_lv3 like 'BioPharmaceuticals: %';--193
update dim_product_1 set brand_lv3 = 'R&I' where brand_lv3 = 'Respiratory & Immunology';--76
update dim_product_1 set brand_lv3 = 'V&I' where brand_lv3 = 'Vaccines & Immune Therapies';--22
update dim_product_1 set brand_lv3 = 'Rare Disease' where brand_lv3 = 'Rare Disease Unit';--0

RAISE NOTICE 'Dim Product Step2 - Cleanse column values done';

-- 3. Add columns
-- 3.1 add ex_covid
alter table dim_product_1 add ex_covid bool default true not null;
update dim_product_1 set ex_covid = true;
update dim_product_1 set ex_covid = false where product_code in ('3086', '6002', '6003', '6004', '6005', '6007', '6008', '6012', '6599');
        --select * from dim_product where brand_lv4 in ('AZD3152', 'Evusheld', 'Vaxzevria Family') or brand_lv5 in ('COVID-19 Family');

-- 3.2 add volume_type, pri_gmd_sub_mkt
alter table dim_product_1 add column volume_type varchar(20);
alter table dim_product_1 add column pri_gmd_sub_mkt varchar(50);

drop table if exists public.dim_brand_mapping cascade;
CREATE TABLE public.dim_brand_mapping (
        brand_lv4 varchar(50) NULL,
        pri_gmd_sub_mkt varchar(50) NULL,
		volume_type varchar(10) NULL
);
INSERT INTO public.dim_brand_mapping (brand_lv4, pri_gmd_sub_mkt, volume_type)
VALUES 
('Airsupra', 'Rescue Respiratory Market', 'SU'),
('Arimidex Family', 'Hormonal Breast Cancer', 'SU'),
('Breztri Family', 'ICS/LAMA/LABA (COPD)', 'DOT'),
('Brilinta Family', 'Oral Anti-Platelet', 'DOT'),
('Calquence', 'BTK inhibitors', 'SU'),
('Casodex Family', 'Anti Androgens', 'SU'),
('Crestor Family', 'Statin', 'SU'),
('Enhertu Family', 'HER2 Targeted Therapies', 'SU'),
('Exenatide Family', 'GLP-1 excluding Obesity', 'DOT'),
('Fasenra Family', 'Severe Asthma', 'DOT'),
('Faslodex Family', 'Advanced Breast Cancer', 'DOT'),
('Forxiga Extended Family', 'iOAD Total', 'DOT'),
('Imfinzi', 'Immune Checkpoint Inhibitors', 'SU'),
('Lokelma', 'Hyperkalaemia', 'DOT'),
('Losec Family', 'PPI', 'SU'),
('Lynparza Family', 'PARP Inhibitors', 'DOT'),
('Nexium Family', 'PPI', 'SU'),
('Onglyza Family', 'iOAD - Diabetes', 'DOT'),
('Pulmicort Family', 'Acute Neb Market', 'SU'),
('Saphnelo Family', 'SLE', 'DOT'),
('Seloken/Toprol-XL', 'Beta Blockers', 'SU'),
('Symbicort Family', 'ICS/LABA', 'DOT'),
('Synagis Family', NULL, 'SU'),
('Tagrisso', 'EGFR TKI', 'SU'),
('Tezspire Family', 'Severe Asthma', 'DOT'),
('Zoladex', 'Hormonal LHRH', 'DOT');

update dim_product_1 dp set pri_gmd_sub_mkt = m.pri_gmd_sub_mkt, volume_type = m.volume_type
from dim_brand_mapping m
where dp.brand_lv4 = m.brand_lv4; --413

RAISE NOTICE 'Dim Product Step3 - Add columns done';

-- 4. Drop internal tables
DROP TABLE if exists public.dim_product cascade;
alter table dim_product_1 rename to dim_product;
alter table dim_product owner to az_user_dw;

RAISE NOTICE 'Dim Product Ready';


END;
$procedure$
;



-- DROP PROCEDURE public.proc_cleanse_fact_propel_sales_external();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_fact_propel_sales_external()
 LANGUAGE plpgsql
AS $procedure$
BEGIN

--=============================================================================================================================
-- fact_propel_target_external
--=============================================================================================================================
RAISE NOTICE 'PROPEL Target started';

drop table if exists fact_propel_target_external_arc;
create table fact_propel_target_external_arc as select * from fact_propel_target_external;
drop table if exists fact_propel_target_external cascade;

CREATE TABLE fact_propel_target_external (
        years varchar(10) NULL,
        "period" varchar(20) NULL,
        product_code varchar(20) NULL,
        entity_code varchar(20) NULL,
        bud numeric NULL,
        bud_ytd numeric NULL,
        rbu1 numeric NULL,
        rbu1_ytd numeric NULL,
        rbu2ltp numeric NULL,
        rbu2ltp_ytd numeric NULL,
        mtp numeric NULL,
        mtp_ytd numeric NULL,
        bud_in_vol numeric NULL,
        bud_in_vol_ytd numeric NULL,
        rbu1_in_vol numeric NULL,
        rbu1_in_vol_ytd numeric NULL,
        rbu2ltp_in_vol numeric NULL,
        rbu2ltp_in_vol_ytd numeric NULL,
        mtp_in_vol numeric NULL,
        mtp_in_vol_ytd numeric NULL,
        wdind int4 NULL,
        load_dt date NULL
);

DELETE FROM fact_propel_sales_external_raw WHERE CAST(SUBSTRING(years FROM 'FY(\d{2})') AS INTEGER) + 2000 < EXTRACT(YEAR FROM CURRENT_DATE) - 3;

-- 1. Standardize column names and column type
drop table if exists fact_propel_target_external_1;
create table fact_propel_target_external_1 as
select
        account_member_alias::varchar(50) as type,
        years::varchar(10),
        "period"::varchar(20),
        product_code::varchar(20),
        entity_code::varchar(20),
        bud::numeric,
        bud_ytd::numeric,
        rbu1::numeric,
        rbu1_ytd::numeric,
        rbu2ltp::numeric,
        rbu2ltp_ytd::numeric,
        mtp::numeric,
        mtp_ytd::numeric,
        wdind::int,
        load_dt::date
from fact_propel_sales_external_raw
WHERE CAST(SUBSTRING(years FROM 'FY(\d{2})') AS INTEGER) + 2000 >= EXTRACT(YEAR FROM CURRENT_DATE) - 2; 
--select type, years, period, product_code, entity_code, count(*) from fact_propel_target_external_1 group by 1,2,3,4,5 having count(*)>1;

RAISE NOTICE 'PROPEL Target Step1 - Standardize columns done';

-- 2. Split KPI columns to value and volume columns based on type
drop table if exists fact_propel_target_external_2;
create table fact_propel_target_external_2 as
select
        f.years,
        f."period",
        f.product_code,
        f.entity_code,
        f.bud,
        f.bud_ytd,
        f.rbu1,
        f.rbu1_ytd,
        f.rbu2ltp,
        f.rbu2ltp_ytd,
        f.mtp,
        f.mtp_ytd,
        vol.bud as bud_in_vol,
        vol.bud_ytd as bud_in_vol_ytd,
        vol.rbu1 as rbu1_in_vol,
        vol.rbu1_ytd as rbu1_in_vol_ytd,
        vol.rbu2ltp as rbu2ltp_in_vol,
        vol.rbu2ltp_ytd as rbu2ltp_in_vol_ytd,
        vol.mtp as mtp_in_vol,
        vol.mtp_ytd as mtp_in_vol_ytd,
        f.wdind,
        f.load_dt
from fact_propel_target_external_1 f
left join fact_propel_target_external_1 vol on f.years = vol.years and f.period = vol.period and f.product_code = vol.product_code and f.entity_code = vol.entity_code and vol.type = 'Product Sales (Pack volume)'
where f.type = 'Total Revenue'; --49370

insert into fact_propel_target_external_2
select
        vol.years,
        vol."period",
        vol.product_code,
        vol.entity_code,
        f.bud,
        f.bud_ytd,
        f.rbu1,
        f.rbu1_ytd,
        f.rbu2ltp,
        f.rbu2ltp_ytd,
        f.mtp,
        f.mtp_ytd,
        vol.bud as bud_in_vol,
        vol.bud_ytd as bud_in_vol_ytd,
        vol.rbu1 as rbu1_in_vol,
        vol.rbu1_ytd as rbu1_in_vol_ytd,
        vol.rbu2ltp as rbu2ltp_in_vol,
        vol.rbu2ltp_ytd as rbu2ltp_in_vol_ytd,
        vol.mtp as mtp_in_vol,
        vol.mtp_ytd as mtp_in_vol_ytd,
        vol.wdind,
        vol.load_dt
from fact_propel_target_external_1 vol
left join fact_propel_target_external_1 f on f.years = vol.years and f.period = vol.period and f.product_code = vol.product_code and f.entity_code = vol.entity_code and f.type = 'Total Revenue'
where vol.type = 'Product Sales (Pack volume)' and f.entity_code is null; --495

RAISE NOTICE 'PROPEL Target Step2 - Split Value & Volume done';

-- 4. Set null value as 0 for all numeric columns
update fact_propel_target_external_2 set bud =0 where bud is null;
update fact_propel_target_external_2 set bud_ytd =0 where bud_ytd is null;
update fact_propel_target_external_2 set rbu1 =0 where rbu1 is null;
update fact_propel_target_external_2 set rbu1_ytd =0 where rbu1_ytd is null;
update fact_propel_target_external_2 set rbu2ltp =0 where rbu2ltp is null;
update fact_propel_target_external_2 set rbu2ltp_ytd =0 where rbu2ltp_ytd is null;
update fact_propel_target_external_2 set mtp =0 where mtp is null;
update fact_propel_target_external_2 set mtp_ytd =0 where mtp_ytd is null;
update fact_propel_target_external_2 set bud_in_vol =0 where bud_in_vol is null;
update fact_propel_target_external_2 set bud_in_vol_ytd =0 where bud_in_vol_ytd is null;
update fact_propel_target_external_2 set rbu1_in_vol =0 where rbu1_in_vol is null;
update fact_propel_target_external_2 set rbu1_in_vol_ytd =0 where rbu1_in_vol_ytd is null;
update fact_propel_target_external_2 set rbu2ltp_in_vol =0 where rbu2ltp_in_vol is null;
update fact_propel_target_external_2 set rbu2ltp_in_vol_ytd =0 where rbu2ltp_in_vol_ytd is null;
update fact_propel_target_external_2 set mtp_in_vol =0 where mtp_in_vol is null;
update fact_propel_target_external_2 set mtp_in_vol_ytd =0 where mtp_in_vol_ytd is null;

RAISE NOTICE 'PROPEL Target Step3 - Set null value as 0 done';

-- 5. Drop internal tables
insert into fact_propel_target_external select * from fact_propel_target_external_2;
drop table fact_propel_target_external_1;
alter table fact_propel_target_external owner to az_user_dw;

RAISE NOTICE 'PROPEL Target Done';

--=============================================================================================================================
-- fact_propel_sales_external
--=============================================================================================================================
RAISE NOTICE 'PROPEL Sales started';
drop table if exists fact_propel_sales_external_arc;
create table fact_propel_sales_external_arc as select * from fact_propel_sales_external;
drop table if exists fact_propel_sales_external cascade;

CREATE TABLE fact_propel_sales_external (
        years varchar(10) NULL,
        "period" varchar(20) NULL,
        product_code varchar(20) NULL,
        entity_code varchar(20) NULL,
        act numeric NULL,
        act_ytd numeric NULL,
        ly_act numeric NULL,
        ly_act_ytd numeric NULL,
        bud numeric NULL,
        bud_ytd numeric NULL,
        rbu1 numeric NULL,
        rbu1_ytd numeric NULL,
        rbu2ltp numeric NULL,
        rbu2ltp_ytd numeric NULL,
        mtp numeric NULL,
        mtp_ytd numeric NULL,
        act_in_vol numeric NULL,
        act_in_vol_ytd numeric NULL,
        ly_act_in_vol numeric NULL,
        ly_act_in_vol_ytd numeric NULL,
        bud_in_vol numeric NULL,
        bud_in_vol_ytd numeric NULL,
        rbu1_in_vol numeric NULL,
        rbu1_in_vol_ytd numeric NULL,
        rbu2ltp_in_vol numeric NULL,
        rbu2ltp_in_vol_ytd numeric NULL,
        mtp_in_vol numeric NULL,
        mtp_in_vol_ytd numeric NULL,
        wdind int4 NULL,
        load_dt date NULL
);

-- 1. Standardize column names and column type
drop table if exists fact_propel_sales_external_1;
create table fact_propel_sales_external_1 as
select
        account_member_alias::varchar(50) as type,
        years::varchar(10),
        "period"::varchar(20),
        product_code::varchar(20),
        entity_code::varchar(20),
        act::numeric,
        act_ytd::numeric,
        bud::numeric,
        bud_ytd::numeric,
        rbu1::numeric,
        rbu1_ytd::numeric,
        rbu2ltp::numeric,
        rbu2ltp_ytd::numeric,
        mtp::numeric,
        mtp_ytd::numeric,
        wdind::int,
        load_dt::date
from fact_propel_sales_external_raw; --89868
--select type, years, period, product_code, entity_code, count(*) from fact_propel_sales_external_1 group by 1,2,3,4,5 having count(*)>1;

RAISE NOTICE 'PROPEL Sales Step1 - Standardize columns done';

-- 2. Add lastyear columns and update the values
alter table fact_propel_sales_external_1 add ly_act numeric null;
alter table fact_propel_sales_external_1 add ly_act_ytd numeric null;

-- 2.1 Update LY with values of year-1
update fact_propel_sales_external_1 cy
set ly_act = ly.act,
        ly_act_ytd = ly.act_ytd
from fact_propel_sales_external_1 ly
where cy."period" = ly."period" and replace(cy.years,'FY','')::int-1= replace(ly.years,'FY','')::int
and cy.product_code = ly.product_code and cy.entity_code = ly.entity_code and cy.type = ly.type; --39365

-- 2.2 Insert the records which only LY has value, but CY doesn't
insert into fact_propel_sales_external_1
select
        ly."type",
        'FY'||replace(ly.years,'FY','')::int+1 as years,
        ly."period",
        ly.product_code,
        ly.entity_code,
        null as act,
        null as act_ytd,
        null as bud,
        null as bud_ytd,
        null as rbu1,
        null as rbu1_ytd,
        null as rbu2ltp,
        null as rbu2ltp_ytd,
        null as mtp,
        null as mtp_ytd,
        ly.wdind,
        ly.load_dt,
        ly.act as ly_act,
        ly.act_ytd as ly_act_ytd
from fact_propel_sales_external_1 ly
left join fact_propel_sales_external_1 cy on cy."period" = ly."period" and replace(cy.years,'FY','')::int-1= replace(ly.years,'FY','')::int
and cy.product_code = ly.product_code and cy.entity_code = ly.entity_code and cy.type = ly.type
where cy.product_code is null and ly.years <> (select max(years) from fact_propel_sales_external_1); --4956

RAISE NOTICE 'PROPEL Sales Step2 - lastyear columns setup done';

-- 3. Split KPI columns to value and volume columns based on type
drop table if exists fact_propel_sales_external_2;
create table fact_propel_sales_external_2 as
select
        f.years,
        f."period",
        f.product_code,
        f.entity_code,
        f.act,
        f.act_ytd,
        f.ly_act,
        f.ly_act_ytd,
        f.bud,
        f.bud_ytd,
        f.rbu1,
        f.rbu1_ytd,
        f.rbu2ltp,
        f.rbu2ltp_ytd,
        f.mtp,
        f.mtp_ytd,
        vol.act as act_in_vol,
        vol.act_ytd as act_in_vol_ytd,
        vol.ly_act as ly_act_in_vol,
        vol.ly_act_ytd as ly_act_in_vol_ytd,
        vol.bud as bud_in_vol,
        vol.bud_ytd as bud_in_vol_ytd,
        vol.rbu1 as rbu1_in_vol,
        vol.rbu1_ytd as rbu1_in_vol_ytd,
        vol.rbu2ltp as rbu2ltp_in_vol,
        vol.rbu2ltp_ytd as rbu2ltp_in_vol_ytd,
        vol.mtp as mtp_in_vol,
        vol.mtp_ytd as mtp_in_vol_ytd,
        f.wdind,
        f.load_dt
from fact_propel_sales_external_1 f
left join fact_propel_sales_external_1 vol on f.years = vol.years and f.period = vol.period and f.product_code = vol.product_code and f.entity_code = vol.entity_code and vol.type = 'Product Sales (Pack volume)'
where f.type = 'Total Revenue'; --49370

insert into fact_propel_sales_external_2
select
        vol.years,
        vol."period",
        vol.product_code,
        vol.entity_code,
        f.act,
        f.act_ytd,
        f.ly_act,
        f.ly_act_ytd,
        f.bud,
        f.bud_ytd,
        f.rbu1,
        f.rbu1_ytd,
        f.rbu2ltp,
        f.rbu2ltp_ytd,
        f.mtp,
        f.mtp_ytd,
        vol.act as act_in_vol,
        vol.act_ytd as act_in_vol_ytd,
        vol.ly_act as ly_act_in_vol,
        vol.ly_act_ytd as ly_act_in_vol_ytd,
        vol.bud as bud_in_vol,
        vol.bud_ytd as bud_in_vol_ytd,
        vol.rbu1 as rbu1_in_vol,
        vol.rbu1_ytd as rbu1_in_vol_ytd,
        vol.rbu2ltp as rbu2ltp_in_vol,
        vol.rbu2ltp_ytd as rbu2ltp_in_vol_ytd,
        vol.mtp as mtp_in_vol,
        vol.mtp_ytd as mtp_in_vol_ytd,
        vol.wdind,
        vol.load_dt
from fact_propel_sales_external_1 vol
left join fact_propel_sales_external_1 f on f.years = vol.years and f.period = vol.period and f.product_code = vol.product_code and f.entity_code = vol.entity_code and f.type = 'Total Revenue'
where vol.type = 'Product Sales (Pack volume)' and f.entity_code is null; --495

--select years,period,product_code,entity_code, array_agg(distinct type)
--from fact_propel_sales_external_1 group by years,period,product_code,entity_code
--having count(distinct type)=1 and max(type) = 'Product Sales (Pack volume)';

RAISE NOTICE 'PROPEL Sales Step3 - Split Value & Volume done';

-- 4. Set null value as 0 for all numeric columns
update fact_propel_sales_external_2 set act=0 where act is null;
update fact_propel_sales_external_2 set act_ytd =0 where act_ytd is null;
update fact_propel_sales_external_2 set ly_act=0 where ly_act is null;
update fact_propel_sales_external_2 set ly_act_ytd =0 where ly_act_ytd is null;
update fact_propel_sales_external_2 set bud =0 where bud is null;
update fact_propel_sales_external_2 set bud_ytd =0 where bud_ytd is null;
update fact_propel_sales_external_2 set rbu1 =0 where rbu1 is null;
update fact_propel_sales_external_2 set rbu1_ytd =0 where rbu1_ytd is null;
update fact_propel_sales_external_2 set rbu2ltp =0 where rbu2ltp is null;
update fact_propel_sales_external_2 set rbu2ltp_ytd =0 where rbu2ltp_ytd is null;
update fact_propel_sales_external_2 set mtp =0 where mtp is null;
update fact_propel_sales_external_2 set mtp_ytd =0 where mtp_ytd is null;
update fact_propel_sales_external_2 set act_in_vol=0 where act_in_vol is null;
update fact_propel_sales_external_2 set act_in_vol_ytd =0 where act_in_vol_ytd is null;
update fact_propel_sales_external_2 set ly_act_in_vol=0 where ly_act_in_vol is null;
update fact_propel_sales_external_2 set ly_act_in_vol_ytd =0 where ly_act_in_vol_ytd is null;
update fact_propel_sales_external_2 set bud_in_vol =0 where bud_in_vol is null;
update fact_propel_sales_external_2 set bud_in_vol_ytd =0 where bud_in_vol_ytd is null;
update fact_propel_sales_external_2 set rbu1_in_vol =0 where rbu1_in_vol is null;
update fact_propel_sales_external_2 set rbu1_in_vol_ytd =0 where rbu1_in_vol_ytd is null;
update fact_propel_sales_external_2 set rbu2ltp_in_vol =0 where rbu2ltp_in_vol is null;
update fact_propel_sales_external_2 set rbu2ltp_in_vol_ytd =0 where rbu2ltp_in_vol_ytd is null;
update fact_propel_sales_external_2 set mtp_in_vol =0 where mtp_in_vol is null;
update fact_propel_sales_external_2 set mtp_in_vol_ytd =0 where mtp_in_vol_ytd is null;

RAISE NOTICE 'PROPEL Sales Step4 - Set null value as 0 done';

-- 5. Drop internal tables
insert into fact_propel_sales_external select * from fact_propel_sales_external_2 WHERE CAST(SUBSTRING(years FROM 'FY(\d{2})') AS INTEGER) + 2000 >= EXTRACT(YEAR FROM CURRENT_DATE) - 2;
drop table fact_propel_sales_external_1;
alter table fact_propel_sales_external owner to az_user_dw;

RAISE NOTICE 'PROPEL Sales Done';


END;
$procedure$
;



-- DROP PROCEDURE public.proc_cleanse_fact_iqvia_mth_gmd_ms();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_fact_iqvia_mth_gmd_ms()
 LANGUAGE plpgsql
AS $procedure$
BEGIN

SET work_mem = '64MB';
--=============================================================================================================================
-- IQVIA Mth GMD MS
--=============================================================================================================================
RAISE NOTICE 'IQVIA Mth GMD MS started';
drop table if exists fact_iqvia_mth_gmd_ms_arc;
alter table fact_iqvia_mth_gmd_ms rename to fact_iqvia_mth_gmd_ms_arc;

DROP TABLE if exists public.fact_iqvia_mth_gmd_ms cascade;

CREATE TABLE public.fact_iqvia_mth_gmd_ms (
        "cluster" varchar(50) NULL,
        cluster_i varchar(50) NULL,
        cluster_ii varchar(50) NULL,
        corporation varchar(50) NULL,
        therapy_area varchar(50) NULL,
        gmd varchar(50) NULL,
        gmd_sub_mkt varchar(50) NULL,
        product_family varchar(50) NULL,
        international_product varchar(50) NULL,
        international_product_raw varchar(50) NULL,
        local_product varchar(50) NULL,
        product_key varchar(50) NULL,
        load_dt varchar(50) NULL,
        "period" varchar(50) NULL,
        days_of_therapy numeric NULL,
        units numeric NULL,
        volume numeric NULL,
        us_dollars_actual numeric NULL,
        gmd_sub_market_size numeric NULL,
        gmd_sub_market_vol_size numeric NULL,
        ly_us_dollars_actual numeric NULL,
        ly_volume numeric NULL,
        ly_gmd_sub_market_size numeric NULL,
        ly_gmd_sub_market_vol_size numeric NULL
);

-- 1. Standardize column names and column type, and remove usd_constant columns
drop table if exists fact_iqvia_mth_gmd_ms_1;
create table fact_iqvia_mth_gmd_ms_1 as
select
        "cluster",
        cluster_i,
        cluster_ii,
        region,
        country,
        panel,
        corporation,
        therapy_area,
        gmd,
        trim("gmd_sub_mkt") as gmd_sub_mkt,
        product_family,
        international_product,
        international_product as international_product_raw,
        local_product,
        master_key,
        load_dt,
        "period",
        days_of_therapy::numeric as days_of_therapy,
        units::numeric as units,
        "us_dollars_(constant)"::numeric as us_dollars_actual,
        ytd_dot::numeric as ytd_dot,
        ytd_units::numeric as ytd_units,
        "ytd_us_dollars_(constant)"::numeric as ytd_us_dollars_actual
from
        fact_iqvia_mth_gmd_ms_raw;

RAISE NOTICE 'IQVIA Mth GMD MS Step1 - Standardize columns done';

-- 2. Apply Geo and Product business rules
-- Update Gulf States in cluster_ii to UAE, Kuwait
update fact_iqvia_mth_gmd_ms_1  set cluster_ii = 'Kuwait' where cluster_ii='Gulf States' and upper(panel) like '%KUWAIT %';
update fact_iqvia_mth_gmd_ms_1  set cluster_ii = 'UAE' where cluster_ii='Gulf States' and upper(panel) like '%UAE %';
-- Update Near East in cluster_ii to Jordon, Lebanon
update fact_iqvia_mth_gmd_ms_1  set cluster_ii = 'Lebanon' where cluster_ii='Near East' and upper(panel) like '%LEBANON %';
update fact_iqvia_mth_gmd_ms_1  set cluster_ii = 'Jordan' where cluster_ii='Near East' and upper(panel) like '%JORDAN %';
-- Update international_product with product_family for iOAD Total and Symbicort Family
update fact_iqvia_mth_gmd_ms_1 set international_product = product_family where gmd_sub_mkt in ('iOAD Total', 'SGLT2i Total', 'NIAD Total', 'IAD Total', 'iOAD - Diabetes'); --88160
update fact_iqvia_mth_gmd_ms_1 set international_product = product_family where product_family in ('Symbicort Family'); --3866
-- Update therapy_area to align with dim_product
update fact_iqvia_mth_gmd_ms_1 set therapy_area = 'R&I' where therapy_area = 'Respiratory & Immunology';
update fact_iqvia_mth_gmd_ms_1 set therapy_area = 'V&I' where therapy_area = 'Vaccine & Immune';
update fact_iqvia_mth_gmd_ms_1 set therapy_area = 'Rare Disease' where therapy_area = 'Rare Disease Unit';
-- Update gmd_sub_mkt for LOKELMA market to gmd Hyperkalaemia
update fact_iqvia_mth_gmd_ms_1 set gmd_sub_mkt = 'Hyperkalaemia' where gmd_sub_mkt in ('Kayexelate Family','Branded Hyperkalaemia');

RAISE NOTICE 'IQVIA Mth GMD MS Step2 - Apply business rules done';

-- 3. Remove masterkey & panel, and keep record unique on product+period+cluster_ii
drop table if exists fact_iqvia_mth_gmd_ms_2;
create table fact_iqvia_mth_gmd_ms_2 as
select
        max("cluster")::varchar(50) as "cluster",
        max(cluster_i)::varchar(50) as cluster_i,
        cluster_ii,
        corporation,
        therapy_area,
        max(gmd)::varchar(50) as gmd,
        f.gmd_sub_mkt,
        product_family,
        international_product,
        international_product_raw,
        max(local_product)::varchar(50) as local_product,
        max(load_dt)::varchar(50) as load_dt,
        "period",
        sum(days_of_therapy) as days_of_therapy,
        sum(units) as units,
        CASE WHEN max(coalesce(dp.volume_type, npm.volume_type)) = 'DOT' THEN sum(days_of_therapy) ELSE sum(units) END AS volume,
        sum(us_dollars_actual) as us_dollars_actual
from fact_iqvia_mth_gmd_ms_1 f
left join (select pri_gmd_sub_mkt, max(volume_type) as volume_type from dim_product where pri_gmd_sub_mkt is not null group by pri_gmd_sub_mkt) dp on f.gmd_sub_mkt = dp.pri_gmd_sub_mkt
left join (select igp.gmd_sub_mkt, max(p.volume_type) as volume_type from  iqvia_gmd_product igp join dim_product_mapping m on igp.international_product = m.product_name  join dim_product p on m.brand_mapping_value = p.product_description or m.brand_mapping_value = p.brand_lv4 or m.brand_mapping_value = p.brand_lv6
group by igp.gmd_sub_mkt) npm on f.gmd_sub_mkt = npm.gmd_sub_mkt
group by corporation, f.gmd_sub_mkt, product_family, international_product, international_product_raw, therapy_area, "period", cluster_ii; --234235

RAISE NOTICE 'IQVIA Mth GMD MS Step3 - Remove masterkey & panel done';

-- 4. Add product_key and Add Calculation columns
-- 4.1 add gmd_sub_market_size, gmd_sub_market_vol_size
drop table if exists fact_iqvia_mth_gmd_ms_3;
create table fact_iqvia_mth_gmd_ms_3 as
select
        max("cluster")::varchar(50) as "cluster",
        max(cluster_i)::varchar(50) as cluster_i,
        cluster_ii,
        corporation,
        therapy_area,
        max(gmd)::varchar(50) as gmd,
        gmd_sub_mkt,
        product_family,
        international_product,
        international_product_raw,
        max(local_product)::varchar(50) as local_product,
        md5(corporation||gmd_sub_mkt||product_family||international_product||international_product_raw||therapy_area)::varchar(50) as product_key,
        max(load_dt)::varchar(50) as load_dt,
        "period",
        sum(days_of_therapy) as days_of_therapy,
        sum(units) as units,
        sum(volume) as volume,
        sum(us_dollars_actual) as us_dollars_actual,
        sum(sum(coalesce(us_dollars_actual,0)))over(partition by gmd_sub_mkt, cluster_ii, "period") as gmd_sub_market_size,
        sum(sum(coalesce(volume,0)))over(partition by gmd_sub_mkt, cluster_ii, "period") as gmd_sub_market_vol_size
from fact_iqvia_mth_gmd_ms_2
group by corporation, gmd_sub_mkt, product_family, international_product, international_product_raw, therapy_area, "period", cluster_ii; --234235

CREATE INDEX fact_iqvia_mth_gmd_ms_3_pk_idx ON fact_iqvia_mth_gmd_ms_3 USING btree (product_key, period, cluster_ii);
CREATE INDEX fact_iqvia_mth_gmd_ms_3_pk_idx2 ON fact_iqvia_mth_gmd_ms_3 USING btree (gmd_sub_mkt, period, cluster_ii);

-- 4.2 add ly columns
alter table fact_iqvia_mth_gmd_ms_3 add ly_us_dollars_actual numeric null;
alter table fact_iqvia_mth_gmd_ms_3 add ly_volume numeric null;
alter table fact_iqvia_mth_gmd_ms_3 add ly_gmd_sub_market_size numeric null;
alter table fact_iqvia_mth_gmd_ms_3 add ly_gmd_sub_market_vol_size numeric null;

update fact_iqvia_mth_gmd_ms_3 cy
set ly_us_dollars_actual = ly.us_dollars_actual,
        ly_volume = ly.volume,
        ly_gmd_sub_market_size = ly.gmd_sub_market_size,
        ly_gmd_sub_market_vol_size = ly.gmd_sub_market_vol_size
from fact_iqvia_mth_gmd_ms_3 ly
where to_date(cy."period",'dd/mm/yyyy') - interval '1 year' = to_date(ly."period",'dd/mm/yyyy') and cy.cluster_ii = ly.cluster_ii and cy.product_key = ly.product_key; --104366

insert into fact_iqvia_mth_gmd_ms_3
select
        ly."cluster",
        ly.cluster_i,
        ly.cluster_ii,
        ly.corporation,
        ly.therapy_area,
        ly.gmd,
        ly.gmd_sub_mkt,
        ly.product_family,
        ly.international_product,
        ly.international_product_raw,
        ly.local_product,
        ly.product_key,
        ly.load_dt,
        to_char(to_date(ly."period",'dd/mm/yyyy') + interval '1 year','dd/mm/yyyy') as "period",
        cy.days_of_therapy,
        cy.units,
        cy.volume,
        cy.us_dollars_actual,
        cy.gmd_sub_market_size,
        cy.gmd_sub_market_vol_size,
        ly.us_dollars_actual as ly_us_dollars_actual,
        ly.volume as ly_volume,
        ly.gmd_sub_market_size as ly_gmd_sub_market_size,
        ly.gmd_sub_market_vol_size as ly_gmd_sub_market_vol_size
from fact_iqvia_mth_gmd_ms_3 ly
left join fact_iqvia_mth_gmd_ms_3 cy on to_date(cy."period",'dd/mm/yyyy') - interval '1 year' = to_date(ly."period",'dd/mm/yyyy') and cy.cluster_ii = ly.cluster_ii and cy.product_key = ly.product_key
where cy.product_key is null and right(ly."period",4) <> (select max(right("period",4)) from fact_iqvia_mth_gmd_ms_3); --6112

delete from fact_iqvia_mth_gmd_ms_3 where right(period,4)::numeric < (select max(right(period,4))::numeric-2 from fact_iqvia_mth_gmd_ms_3);

RAISE NOTICE 'IQVIA Mth GMD MS Step4 - Add Calculation columns done';

-- 5. Create a table to keep gmd market size, AKA class size, and greater class size
drop table if exists fact_iqvia_mth_class;
create table fact_iqvia_mth_class as
select
        max("cluster")::varchar(50) as "cluster",
        max(cluster_i)::varchar(50) as cluster_i,
        cluster_ii::varchar(50),
        "period"::varchar(50),
        max(therapy_area)::varchar(50) as therapy_area,
        max(gmd)::varchar(50) as gmd,
        gmd_sub_mkt::varchar(50),
        gmd_sub_mkt::varchar(50) as "class",
        null::varchar(50) as greater_class,
        max(gmd_sub_market_size)::numeric as class_size,
        max(gmd_sub_market_vol_size)::numeric as class_vol_size,
        max(ly_gmd_sub_market_size)::numeric as ly_class_size,
        max(ly_gmd_sub_market_vol_size)::numeric as ly_class_vol_size,
        null::numeric as greater_class_size,
        null::numeric as greater_class_vol_size,
        null::numeric as ly_greater_class_size,
        null::numeric as ly_greater_class_vol_size
from fact_iqvia_mth_gmd_ms_3
group by cluster_ii, "period", gmd_sub_mkt
; --Updated Rows        42416
CREATE INDEX fact_iqvia_mth_class_pk_idx ON fact_iqvia_mth_class USING btree (gmd_sub_mkt, "period", cluster_ii);

update fact_iqvia_mth_class f
set
        greater_class = gc.class,
        greater_class_size = gc.class_size,
        greater_class_vol_size = gc.class_vol_size,
        ly_greater_class_size = gc.ly_class_size,
        ly_greater_class_vol_size = gc.ly_class_vol_size
from fact_iqvia_mth_class gc
where f.class = 'SGLT2i Total'
and gc.class = 'NIAD Total'
and f.cluster_ii=gc.cluster_ii and f."period"=gc."period";--1537

RAISE NOTICE 'IQVIA Mth GMD MS Step5 - fact_iqvia_mth_class created';

-- 6. Create a Cartesian table with the CROSS JOIN of product+period+geo for both Mth and Qtr
drop table if exists fact_iqvia_mth_gmd_ms;
create table fact_iqvia_mth_gmd_ms as select * from fact_iqvia_mth_gmd_ms_arc where 1=2;
insert into fact_iqvia_mth_gmd_ms
select
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
        cal."period",
        f3.days_of_therapy,
        f3.units,
        f3.volume,
        f3.us_dollars_actual,
        gmd.class_size as gmd_sub_market_size,
        gmd.class_vol_size as gmd_sub_market_vol_size,
        f3.ly_us_dollars_actual,
        f3.ly_volume,
        gmd.ly_class_size as ly_gmd_sub_market_size,
        gmd.ly_class_vol_size as ly_gmd_sub_market_vol_size
from
(select
        max(corporation) as corporation,
        max(therapy_area) as therapy_area,
        max(gmd) as gmd,
        max(gmd_sub_mkt) as gmd_sub_mkt,
        max(product_family) as product_family,
        max(international_product) as international_product,
        max(international_product_raw) as international_product_raw,
        max(local_product) as local_product,
        product_key
from fact_iqvia_mth_gmd_ms_3
group by product_key) prod
join (select "period", max(load_dt) as load_dt from fact_iqvia_mth_gmd_ms_3 where to_date(period,'dd/mm/yyyy')>=(select to_date(to_char(max(to_date(period,'dd/mm/yyyy')) - interval '2 year', 'yyyy'), 'yyyy') from fact_iqvia_mth_gmd_ms_3) group by "period") cal on 1=1
join (select distinct "cluster", cluster_i, cluster_ii from fact_iqvia_mth_gmd_ms_3) geo on 1=1
left join fact_iqvia_mth_class gmd on prod.gmd_sub_mkt = gmd.gmd_sub_mkt and cal."period" = gmd."period" and geo.cluster_ii = gmd.cluster_ii
left join fact_iqvia_mth_gmd_ms_3 f3 on prod.product_key = f3.product_key and cal."period" = f3."period" and geo.cluster_ii = f3.cluster_ii
;--Updated Rows        35515512

RAISE NOTICE 'IQVIA Mth GMD MS Step6 - Create Cross Join table fact_iqvia_mth_gmd_ms done';

-- 7. Drop internal tables
drop table fact_iqvia_mth_gmd_ms_1;
drop table fact_iqvia_mth_gmd_ms_2;
drop table fact_iqvia_mth_gmd_ms_3;
alter table fact_iqvia_mth_gmd_ms owner to az_user_dw;
alter table fact_iqvia_mth_class owner to az_user_dw;

RAISE NOTICE 'IQVIA Mth GMD MS Done, remember to VACUUM the table';

END;
$procedure$
;



-- DROP PROCEDURE public.proc_cleanse_fact_iqvia_qtr_gmd_ms();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_fact_iqvia_qtr_gmd_ms()
 LANGUAGE plpgsql
AS $procedure$
BEGIN

SET work_mem = '64MB';
--=============================================================================================================================
-- IQVIA Qtr GMD MS
--=============================================================================================================================
RAISE NOTICE 'IQVIA Qtr GMD MS started';
drop table if exists fact_iqvia_qtr_gmd_ms_arc;
alter table fact_iqvia_qtr_gmd_ms rename to fact_iqvia_qtr_gmd_ms_arc;

DROP TABLE if exists public.fact_iqvia_qtr_gmd_ms cascade;

CREATE TABLE public.fact_iqvia_qtr_gmd_ms (
        "cluster" varchar(50) NULL,
        cluster_i varchar(50) NULL,
        cluster_ii varchar(50) NULL,
        corporation text NULL,
        therapy_area text NULL,
        gmd text NULL,
        gmd_sub_mkt varchar(50) NULL,
        product_family text NULL,
        international_product text NULL,
        international_product_raw text NULL,
        local_product text NULL,
        product_key varchar(50) NULL,
        load_dt text NULL,
        "period" varchar(50) NULL,
        days_of_therapy numeric NULL,
        units numeric NULL,
        volume numeric NULL,
        us_dollars_actual numeric NULL,
        gmd_sub_market_size numeric NULL,
        gmd_sub_market_vol_size numeric NULL,
        ly_us_dollars_actual numeric NULL,
        ly_volume numeric NULL,
        ly_gmd_sub_market_size numeric NULL,
        ly_gmd_sub_market_vol_size numeric NULL
);

DROP TABLE if exists public.iqvia_gmd_product cascade;

CREATE TABLE public.iqvia_gmd_product (
        therapy_area text NULL,
        gmd text NULL,
        gmd_sub_mkt varchar(50) NULL,
        product_family text NULL,
        international_product text NULL,
        international_product_raw text NULL
);

-- 1. Standardize column names and column type, and remove usd_constant columns
drop table if exists fact_iqvia_qtr_gmd_ms_1;
create table fact_iqvia_qtr_gmd_ms_1 as
select
        "cluster",
        cluster_i,
        cluster_ii,
        region,
        country,
        panel,
        corporation,
        therapy_area,
        gmd,
        trim("gmd_sub_mkt") as gmd_sub_mkt,
        product_family,
        international_product,
        international_product as international_product_raw,
        local_product,
        master_key,
        load_dt,
        "period",
        days_of_therapy::numeric as days_of_therapy,
        units::numeric as units,
        "us_dollars_(constant)"::numeric as us_dollars_actual,
        ytd_dot::numeric as ytd_dot,
        ytd_units::numeric as ytd_units,
        "ytd_us_dollars_(constant)"::numeric as ytd_us_dollars_actual
from
        fact_iqvia_qtr_gmd_ms_raw; --4007304

RAISE NOTICE 'IQVIA Qtr GMD MS Step1 - Standardize columns done';

-- 2. Apply Geo and Product business rules
-- Update Gulf States in cluster_ii to UAE, Kuwait
update fact_iqvia_qtr_gmd_ms_1  set cluster_ii = 'Kuwait' where cluster_ii='Gulf States' and upper(panel) like '%KUWAIT %';
update fact_iqvia_qtr_gmd_ms_1  set cluster_ii = 'UAE' where cluster_ii='Gulf States' and upper(panel) like '%UAE %';
-- Update Near East in cluster_ii to Jordon, Lebanon
update fact_iqvia_qtr_gmd_ms_1  set cluster_ii = 'Lebanon' where cluster_ii='Near East' and upper(panel) like '%LEBANON %';
update fact_iqvia_qtr_gmd_ms_1  set cluster_ii = 'Jordan' where cluster_ii='Near East' and upper(panel) like '%JORDAN %';
-- Update international_product with product_family for iOAD Total and Symbicort Family
update fact_iqvia_qtr_gmd_ms_1 set international_product = product_family where gmd_sub_mkt in ('iOAD Total', 'SGLT2i Total', 'NIAD Total', 'IAD Total', 'iOAD - Diabetes'); --981259
update fact_iqvia_qtr_gmd_ms_1 set international_product = product_family where product_family in ('Symbicort Family'); --7095
-- Update therapy_area to align with dim_product
update fact_iqvia_qtr_gmd_ms_1 set therapy_area = 'R&I' where therapy_area = 'Respiratory & Immunology';
update fact_iqvia_qtr_gmd_ms_1 set therapy_area = 'V&I' where therapy_area = 'Vaccine & Immune';
update fact_iqvia_qtr_gmd_ms_1 set therapy_area = 'Rare Disease' where therapy_area = 'Rare Disease Unit';

-- Update gmd_sub_mkt for LOKELMA market to gmd Hyperkalaemia
update fact_iqvia_qtr_gmd_ms_1 set gmd_sub_mkt = 'Hyperkalaemia' where gmd_sub_mkt in ('Kayexelate Family','Branded Hyperkalaemia');

RAISE NOTICE 'IQVIA Qtr GMD MS Step2 - Apply business rules done';

-- 3. Remove masterkey & panel, and keep record unique on product+period+cluster_ii
drop table if exists fact_iqvia_qtr_gmd_ms_2;
create table fact_iqvia_qtr_gmd_ms_2 as
select
        max("cluster")::varchar(50) as "cluster",
        max(cluster_i)::varchar(50) as cluster_i,
        cluster_ii,
        corporation,
        therapy_area,
        max(gmd)::varchar(50) as gmd,
        f.gmd_sub_mkt,
        product_family,
        international_product,
        international_product_raw,
        max(local_product)::varchar(50) as local_product,
        max(load_dt)::varchar(50) as load_dt,
        "period",
        sum(days_of_therapy) as days_of_therapy,
        sum(units) as units,
        CASE WHEN max(coalesce(dp.volume_type, npm.volume_type)) = 'DOT' THEN sum(days_of_therapy) ELSE sum(units) END AS volume,
        sum(us_dollars_actual) as us_dollars_actual
from fact_iqvia_qtr_gmd_ms_1 f
left join (select pri_gmd_sub_mkt, max(volume_type) as volume_type from dim_product where pri_gmd_sub_mkt is not null group by pri_gmd_sub_mkt) dp on f.gmd_sub_mkt = dp.pri_gmd_sub_mkt
left join (select igp.gmd_sub_mkt, max(p.volume_type) as volume_type from  iqvia_gmd_product igp join dim_product_mapping m on igp.international_product = m.product_name  join dim_product p on m.brand_mapping_value = p.product_description or m.brand_mapping_value = p.brand_lv4 or m.brand_mapping_value = p.brand_lv6
group by igp.gmd_sub_mkt) npm on f.gmd_sub_mkt = npm.gmd_sub_mkt
group by corporation, f.gmd_sub_mkt, product_family, international_product, international_product_raw, therapy_area, "period", cluster_ii; --983980

RAISE NOTICE 'IQVIA Qtr GMD MS Step3 - Remove masterkey & panel done';

-- 4. Add product_key and Add Calculation columns
-- 4.1 add gmd_sub_market_size, gmd_sub_market_vol_size
drop table if exists fact_iqvia_qtr_gmd_ms_3;
create table fact_iqvia_qtr_gmd_ms_3 as
select
        max("cluster")::varchar(50) as "cluster",
        max(cluster_i)::varchar(50) as cluster_i,
        cluster_ii,
        corporation,
        therapy_area,
        max(gmd)::varchar(50) as gmd,
        gmd_sub_mkt,
        product_family,
        international_product,
        max(international_product_raw)::varchar(50) as international_product_raw,
        max(local_product)::varchar(50) as local_product,
        md5(corporation||gmd_sub_mkt||product_family||international_product||international_product_raw||therapy_area)::varchar(50) as product_key,
        max(load_dt)::varchar(50) as load_dt,
        "period",
        sum(days_of_therapy) as days_of_therapy,
        sum(units) as units,
        sum(volume) as volume,
        sum(us_dollars_actual) as us_dollars_actual,
        sum(sum(coalesce(us_dollars_actual,0)))over(partition by gmd_sub_mkt, cluster_ii, "period") as gmd_sub_market_size,
        sum(sum(coalesce(volume,0)))over(partition by gmd_sub_mkt, cluster_ii, "period") as gmd_sub_market_vol_size
from fact_iqvia_qtr_gmd_ms_2
group by corporation, gmd_sub_mkt, product_family, international_product, international_product_raw, therapy_area, "period", cluster_ii; --983980

CREATE INDEX fact_iqvia_qtr_gmd_ms_3_pk_idx ON fact_iqvia_qtr_gmd_ms_3 USING btree (product_key, period, cluster_ii);

-- 4.2 add ly columns
alter table fact_iqvia_qtr_gmd_ms_3 add ly_us_dollars_actual numeric null;
alter table fact_iqvia_qtr_gmd_ms_3 add ly_volume numeric null;
alter table fact_iqvia_qtr_gmd_ms_3 add ly_gmd_sub_market_size numeric null;
alter table fact_iqvia_qtr_gmd_ms_3 add ly_gmd_sub_market_vol_size numeric null;

update fact_iqvia_qtr_gmd_ms_3 cy
set ly_us_dollars_actual = ly.us_dollars_actual,
        ly_volume = ly.volume,
        ly_gmd_sub_market_size = ly.gmd_sub_market_size,
        ly_gmd_sub_market_vol_size = ly.gmd_sub_market_vol_size
from fact_iqvia_qtr_gmd_ms_3 ly
where to_date(cy."period",'dd/mm/yyyy') - interval '1 year' = to_date(ly."period",'dd/mm/yyyy') and cy.cluster_ii = ly.cluster_ii and cy.product_key = ly.product_key; --566700

insert into fact_iqvia_qtr_gmd_ms_3
select
        ly."cluster",
        ly.cluster_i,
        ly.cluster_ii,
        ly.corporation,
        ly.therapy_area,
        ly.gmd,
        ly.gmd_sub_mkt,
        ly.product_family,
        ly.international_product,
        ly.international_product_raw,
        ly.local_product,
        ly.product_key,
        ly.load_dt,
        to_char(to_date(ly."period",'dd/mm/yyyy') + interval '1 year','dd/mm/yyyy') as "period",
        cy.days_of_therapy,
        cy.units,
        cy.volume,
        cy.us_dollars_actual,
        cy.gmd_sub_market_size,
        cy.gmd_sub_market_vol_size,
        ly.us_dollars_actual as ly_us_dollars_actual,
        ly.volume as ly_volume,
        ly.gmd_sub_market_size as ly_gmd_sub_market_size,
        ly.gmd_sub_market_vol_size as ly_gmd_sub_market_vol_size
from fact_iqvia_qtr_gmd_ms_3 ly
left join fact_iqvia_qtr_gmd_ms_3 cy on to_date(cy."period",'dd/mm/yyyy') - interval '1 year' = to_date(ly."period",'dd/mm/yyyy') and cy.cluster_ii = ly.cluster_ii and cy.product_key = ly.product_key
where cy.product_key is null and right(ly."period",4) <> (select max(right("period",4)) from fact_iqvia_qtr_gmd_ms_3); --136517

delete from fact_iqvia_qtr_gmd_ms_3 where right(period,4)::numeric < (select max(right(period,4))::numeric-2 from fact_iqvia_qtr_gmd_ms_3);

RAISE NOTICE 'IQVIA Qtr GMD MS Step4 - Add Calculation columns done';

-- 5. Prepare market size data for QTR
drop table if exists fact_iqvia_qtr_class;
create table fact_iqvia_qtr_class as
select
        max("cluster")::varchar(50) as "cluster",
        max(cluster_i)::varchar(50) as cluster_i,
        cluster_ii::varchar(50),
        "period"::varchar(50),
        max(therapy_area)::varchar(50) as therapy_area,
        max(gmd)::varchar(50) as gmd,
        gmd_sub_mkt::varchar(50),
        gmd_sub_mkt::varchar(50) as "class",
        null::varchar(50) as greater_class,
        max(gmd_sub_market_size)::numeric as class_size,
        max(gmd_sub_market_vol_size)::numeric as class_vol_size,
        max(ly_gmd_sub_market_size)::numeric as ly_class_size,
        max(ly_gmd_sub_market_vol_size)::numeric as ly_class_vol_size,
        null::numeric as greater_class_size,
        null::numeric as greater_class_vol_size,
        null::numeric as ly_greater_class_size,
        null::numeric as ly_greater_class_vol_size
from fact_iqvia_qtr_gmd_ms_3
group by cluster_ii, "period", gmd_sub_mkt
; --16493
CREATE INDEX fact_iqvia_qtr_class_pk_idx ON fact_iqvia_qtr_class USING btree (gmd_sub_mkt, "period", cluster_ii);

update fact_iqvia_qtr_class f
set
        greater_class = gc.class,
        greater_class_size = gc.class_size,
        greater_class_vol_size = gc.class_vol_size,
        ly_greater_class_size = gc.ly_class_size,
        ly_greater_class_vol_size = gc.ly_class_vol_size
from fact_iqvia_qtr_class gc
where f.class = 'SGLT2i Total'
and gc.class = 'NIAD Total'
and f.cluster_ii=gc.cluster_ii and f."period"=gc."period";--464

RAISE NOTICE 'IQVIA Qtr GMD MS Step5 - fact_iqvia_qtr_class created';



END;
$procedure$
;


-- DROP PROCEDURE public.proc_cleanse_fact_iqvia_qtr_corp_rnk();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_fact_iqvia_qtr_corp_rnk()
 LANGUAGE plpgsql
AS $procedure$
BEGIN

SET work_mem = '64MB';
--=============================================================================================================================
-- IQVIA Corp Rank
--=============================================================================================================================
RAISE NOTICE 'IQVIA Corp Rank started';
drop table if exists fact_iqvia_qtr_corp_rnk_arc;
create table fact_iqvia_qtr_corp_rnk_arc as select * from fact_iqvia_qtr_corp_rnk;
drop table if exists fact_iqvia_qtr_corp_rnk CASCADE;

CREATE TABLE public.fact_iqvia_qtr_corp_rnk (
        "cluster" varchar(50) NULL,
        cluster_i varchar(50) NULL,
        cluster_ii varchar(50) NULL,
        corporation varchar(50) NULL,
        therapy_area varchar(50) NULL,
        load_dt varchar(50) NULL,
        "period" date NULL,
        ta_key text NULL,
        days_of_therapy numeric NULL,
        units numeric NULL,
        us_dollars_actual numeric NULL,
        ly_us_dollars_actual numeric NULL,
        ly_units numeric NULL
);

-- 1. Standardize column names and column type, and remove usd_constant columns
drop table if exists fact_iqvia_qtr_corp_rnk_1;
create table fact_iqvia_qtr_corp_rnk_1 as
select
        "cluster",
        cluster_i,
        cluster_ii,
        region,
        country,
        panel,
        corporation,
        therapy_area,
        master_key,
        load_dt,
        to_date("period",'DD/MM/YYYY') as "period",
        days_of_therapy::numeric(18,2) as days_of_therapy,
        units::numeric(18,2) as units,
        "us_dollars_(constant)"::numeric(18,2) as us_dollars_actual,
        ytd_dot::numeric(18,2) as ytd_dot,
        ytd_units::numeric(18,2) as ytd_units,
        "ytd_us_dollars_(constant)"::numeric(18,2) as ytd_us_dollars_actual
from
        fact_iqvia_qtr_corp_rnk_raw;--4595794

RAISE NOTICE 'IQVIA Corp Rank Step1 - Standardize columns done';

-- 2. Apply Geo and Product business rules
-- Update Gulf States in cluster_ii to UAE, Kuwait
update fact_iqvia_qtr_corp_rnk_1  set cluster_ii = 'Kuwait' where cluster_ii='Gulf States' and upper(panel) like '%KUWAIT %';
update fact_iqvia_qtr_corp_rnk_1  set cluster_ii = 'UAE' where cluster_ii='Gulf States' and upper(panel) like '%UAE %';
-- Update Near East in cluster_ii to Jordon, Lebanon
update fact_iqvia_qtr_corp_rnk_1  set cluster_ii = 'Lebanon' where cluster_ii='Near East' and upper(panel) like '%LEBANON %';
update fact_iqvia_qtr_corp_rnk_1  set cluster_ii = 'Jordan' where cluster_ii='Near East' and upper(panel) like '%JORDAN %';
-- Update therapy_area to align with dim_product
update fact_iqvia_qtr_corp_rnk_1 set therapy_area = 'R&I' where therapy_area = 'Respiratory & Immunology';
update fact_iqvia_qtr_corp_rnk_1 set therapy_area = 'V&I' where therapy_area = 'Vaccine & Immune';
update fact_iqvia_qtr_corp_rnk_1 set therapy_area = 'Rare Disease' where therapy_area = 'Rare Disease Unit';

RAISE NOTICE 'IQVIA Corp Rank Step2 - Apply business rules done';

-- 3. Remove masterkey & panel, and keep record unique on corporation+therapy_area+period+cluster_ii; Add market_size, market_units_size
drop table if exists fact_iqvia_qtr_corp_rnk_2;
create table fact_iqvia_qtr_corp_rnk_2 as
select
        max("cluster")::varchar(50) as "cluster",
        max(cluster_i)::varchar(50) as cluster_i,
        cluster_ii,
        corporation,
        therapy_area,
        max(load_dt)::varchar(50) as load_dt,
        "period",
        sum(days_of_therapy) as days_of_therapy,
        sum(units) as units,
        sum(us_dollars_actual) as us_dollars_actual,
        sum(sum(coalesce(us_dollars_actual,0)))over(partition by therapy_area, cluster_ii, "period") as market_size,
        sum(sum(coalesce(units,0)))over(partition by therapy_area, cluster_ii, "period") as market_units_size
from fact_iqvia_qtr_corp_rnk_1 f
group by corporation, therapy_area, "period", cluster_ii; --220199

CREATE INDEX fact_iqvia_qtr_corp_rnk_2_pk_idx ON fact_iqvia_qtr_corp_rnk_2 USING btree (corporation, therapy_area, period, cluster_ii);
CREATE INDEX fact_iqvia_qtr_corp_rnk_2_pk_idx2 ON fact_iqvia_qtr_corp_rnk_2 USING brin (therapy_area, period, cluster_ii);

RAISE NOTICE 'IQVIA Corp Rank Step3 - Remove masterkey & panel done';

-- 4. Add LY columns
alter table fact_iqvia_qtr_corp_rnk_2 add ly_us_dollars_actual numeric null;
alter table fact_iqvia_qtr_corp_rnk_2 add ly_units numeric null;
alter table fact_iqvia_qtr_corp_rnk_2 add ly_market_size numeric null;
alter table fact_iqvia_qtr_corp_rnk_2 add ly_market_units_size numeric null;

update fact_iqvia_qtr_corp_rnk_2 cy
set ly_us_dollars_actual = ly.us_dollars_actual,
        ly_units = ly.units,
        ly_market_size = ly.market_size,
        ly_market_units_size = ly.market_units_size
from fact_iqvia_qtr_corp_rnk_2 ly
where cy."period" - interval '1 year' = ly."period" and cy.cluster_ii = ly.cluster_ii and cy.corporation = ly.corporation and cy.therapy_area = ly.therapy_area; --102632

insert into fact_iqvia_qtr_corp_rnk_2
select
        ly."cluster",
        ly.cluster_i,
        ly.cluster_ii,
        ly.corporation,
        ly.therapy_area,
        ly.load_dt,
        ly."period" + interval '1 year' as "period",
        cy.days_of_therapy,
        cy.units,
        cy.us_dollars_actual,
        cy.market_size,
        cy.market_units_size,
        ly.us_dollars_actual as ly_us_dollars_actual,
        ly.units as ly_units,
        ly.market_size as ly_market_size,
        ly.market_units_size as ly_market_units_size
from fact_iqvia_qtr_corp_rnk_2 ly
left join fact_iqvia_qtr_corp_rnk_2 cy on cy."period" - interval '1 year' = ly."period" and cy.cluster_ii = ly.cluster_ii and cy.corporation = ly.corporation and cy.therapy_area = ly.therapy_area
where cy.corporation is null and to_char(ly."period",'yyyy') <> (select max(to_char("period",'yyyy')) from fact_iqvia_qtr_corp_rnk_2); --6822

RAISE NOTICE 'IQVIA Corp Rank Step4 - Add Calculation columns done';

-- 5. Prepare market size data for Corp Rank
drop table if exists fact_iqvia_qtr_ta_arc;
create table fact_iqvia_qtr_ta_arc as select * from fact_iqvia_qtr_ta;

drop table if exists fact_iqvia_qtr_ta;
create table fact_iqvia_qtr_ta as
select therapy_area, "period", cluster_ii, '' as ta_key, market_size, market_units_size, ly_market_size, ly_market_units_size
from fact_iqvia_qtr_corp_rnk_2 where 1=2;

insert into fact_iqvia_qtr_ta
select
        ta.therapy_area,
        cal."period",
        geo.cluster_ii,
        md5(ta.therapy_area || cal."period" || geo.cluster_ii) as ta_key,
        f2.market_size,
        f2.market_units_size,
        f2.ly_market_size,
        f2.ly_market_units_size
from (select distinct therapy_area from fact_iqvia_qtr_corp_rnk_2) ta
join (select distinct "period" from fact_iqvia_qtr_corp_rnk_2) cal on 1=1
join (select distinct cluster_ii from fact_iqvia_qtr_corp_rnk_2) geo on 1=1
left join (
        select
                therapy_area,
                "period",
                cluster_ii,
                max(market_size) as market_size,
                max(market_units_size) as market_units_size,
                max(ly_market_size) as ly_market_size,
                max(ly_market_units_size) as ly_market_units_size
        from
                fact_iqvia_qtr_corp_rnk_2
        group by
                therapy_area,
                "period",
                cluster_ii) f2
        on ta.therapy_area = f2.therapy_area and cal."period" = f2."period" and geo.cluster_ii = f2.cluster_ii
; --2176

CREATE INDEX fact_iqvia_qtr_ta_pk_idx ON fact_iqvia_qtr_ta USING hash (ta_key);

RAISE NOTICE 'IQVIA Corp Rank Step5 - fact_iqvia_qtr_ta created';


END;
$procedure$
;

-- DROP PROCEDURE public.proc_cleanse_fact_ireal_mainlist();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_fact_ireal_mainlist()
 LANGUAGE plpgsql
AS $procedure$
BEGIN

--=============================================================================================================================
-- fact_ireal_metric
--=============================================================================================================================
RAISE NOTICE 'fact_ireal_metric started';

drop table if exists fact_ireal_metric_arc;
alter table fact_ireal_metric rename to fact_ireal_metric_arc;
alter table fact_ireal_metric_arc drop constraint fact_ireal_metric_pk;

DROP TABLE if exists public.fact_ireal_metric CASCADE;

CREATE TABLE public.fact_ireal_metric (
        id varchar(100) NULL,
        sno varchar(100) NULL,
        lowermarket varchar(100) NULL,
        market varchar(100) NOT NULL,
        ta varchar(100) NULL,
        brand varchar(100) NOT NULL,
        indication varchar(100) NOT NULL,
        area varchar(100) NULL,
        unit varchar(100) NULL,
        regulatory_approval_status varchar(100) NULL,
        no_regulatory_submission_reason varchar(300) NULL,
        follow_ema_fda_or_other varchar(100) NULL,
        "others" varchar(300) NULL,
        commercial_launch_status varchar(100) NULL,
        no_commercial_launch_reason varchar(300) NULL,
        isnat varchar(100) NULL,
        public_national_reimbursement_approval_status varchar(100) NULL,
        public_national_reimbursement_population_criteria varchar(100) NULL,
        public_national_reimbursement_population_criteria_details varchar(300) NULL,
        diagnostic_reimbursement_approval_status varchar(100) NULL,
        pap_availability varchar(100) NULL,
        ivs_availability varchar(100) NULL,
        bridging_program_availability varchar(100) NULL,
        gpi_pricing_approval_status varchar(100) NULL,
        institution1_name varchar(100) NULL,
        institution1_reimbursement_approval_status varchar(100) NULL,
        institution1_reimbursement_population_criteria varchar(100) NULL,
        institution1_reimbursement_population_criteria_detail varchar(300) NULL,
        institution2_name varchar(100) NULL,
        institution2_reimbursement_approval_status varchar(100) NULL,
        institution2_reimbursement_population_criteria varchar(100) NULL,
        institution2_reimbursement_population_criteria_detail varchar(300) NULL,
        institution3_name varchar(100) NULL,
        institution3_reimbursement_approval_status varchar(100) NULL,
        institution3_reimbursement_population_criteria varchar(100) NULL,
        institution3_reimbursement_population_criteria_detail varchar(300) NULL,
        private_insurance_approval_status varchar(100) NULL,
        private_insurance_population_criteria varchar(100) NULL,
        private_insurance_population_criteria_details varchar(300) NULL,
        "%_population_with_access_to_date" varchar(100) NULL,
        "%_population_with_access_planned_in_peak_year_of_access" varchar(100) NULL,
        peak_year_of_access varchar(100) NULL,
        is1st varchar(100) NULL,
        is2nd varchar(100) NULL,
        is3rd varchar(100) NULL,
        ispri varchar(100) NULL,
        manual_last_update varchar(100) NULL,
        last_updated_by varchar(100) NULL,
        sourcing_from_international_regulatory_team varchar(100) NULL,
        modified varchar(100) NULL,
        modified_by varchar(100) NULL
);

DROP TABLE if exists public.fact_ireal_metric CASCADE;
create table fact_ireal_metric as
select
        id,
        sno,
        lowermarket,
        market,
        ta,
        brand,
        indication,
        area,
        unit,
        regulatory_approval_status,
        "if_no_submission_planned,_please_provide_reason" as no_regulatory_submission_reason,
        "will_reg._approval_follow_ema,_fda_or_other_label?" as follow_ema_fda_or_other,
        "if_other,_please_provide_details" as "others",
        commercial_launch_status,
        "if_no_comm_launch,_please_provide_reason" as no_commercial_launch_reason,
        isnat,
        public_national_reimbursement_approval_status,
        public_national_reimbursement_population_criteria,
        "if_other,_please_provide_details2" as public_national_reimbursement_population_criteria_details,
        diagnostic_reimbursement_approval_status,
        pap_availability,
        ivs_availability,
        bridging_program_availability,
        gpi_pricing_approval_status,
        "institution_#1_name" as institution1_name,
        "institution_#1_reimbursement_approval_status" as institution1_reimbursement_approval_status,
        "institution_#1_reimbursement_population_criteria" as institution1_reimbursement_population_criteria,
        "if_other,_please_provide_details3" as institution1_reimbursement_population_criteria_detail,
        "institution_#2_name" as institution2_name,
        "institution_#2_reimbursement_approval_status" as institution2_reimbursement_approval_status,
        "institution_#2_reimbursement_population_criteria" as institution2_reimbursement_population_criteria,
        "if_other,_please_provide_details4" as institution2_reimbursement_population_criteria_detail,
        "institution_#3_name" as institution3_name,
        "institution_#3_reimbursement_approval_status" as institution3_reimbursement_approval_status,
        "institution_#3_reimbursement_population_criteria" as institution3_reimbursement_population_criteria,
        "if_other,_please_provide_details5" as institution3_reimbursement_population_criteria_detail,
        private_insurance_approval_status,
        private_insurance_population_criteria,
        "if_other,_please_provide_details6" as private_insurance_population_criteria_details,
        "%_population_with_access_to_date",
        "%_population_with_access_planned_in_peak_year_of_access",
        "peak_year_of_access_(number_of_years_after_launch)" as peak_year_of_access,
        is1st,
        is2nd,
        is3rd,
        ispri,
        manual_last_update,
        last_updated_by,
        sourcing_from_international_regulatory_team,
        modified,
        modified_by
from
        fact_ireal_mainlist_raw fim;
ALTER TABLE public.fact_ireal_metric ADD CONSTRAINT fact_ireal_metric_pk PRIMARY KEY (brand,indication,market);

RAISE NOTICE 'iREAL Step1 - fact_ireal_metric cleanse done';

--=============================================================================================================================
-- fact_ireal_event
--=============================================================================================================================
RAISE NOTICE 'fact_ireal_event started';

drop table if exists fact_ireal_event_arc;
alter table fact_ireal_event rename to fact_ireal_event_arc;
drop index if exists fact_ireal_event_market_idx;

create table fact_ireal_event (
        market varchar(50) NULL,
        brand varchar(50) NULL,
        indication varchar(64) NULL,
        ireal_phase varchar(50) NULL,
        ireal_status  varchar(50) NULL,
        latest_status varchar(100) NULL,
        date date NULL
);


--1. update regulatory_approval_status
--expected_submission
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'regulatory_approval' as  ireal_phase
,'expected_submission' as ireal_status
,regulatory_approval_status as latest_status,
to_date(expected_regulatory_submission_date,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;
--actual_submission
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'regulatory_approval','actual_submission',regulatory_approval_status,to_date(actual_regulatory_submission_date,'YYYY-MM-DD HH24:MI:SS.US') as "date"  from fact_ireal_mainlist_raw;
--expected_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'regulatory_approval','expected_approval',regulatory_approval_status,to_date(expected_regulatory_approval_date ,'YYYY-MM-DD HH24:MI:SS.US') as "date"  from fact_ireal_mainlist_raw;
--actual_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'regulatory_approval','actual_approval',regulatory_approval_status,to_date(actual_regulatory_approval_date,'YYYY-MM-DD HH24:MI:SS.US') as "date"  from fact_ireal_mainlist_raw;

--2. update commercial_launch_status
--expected_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'commercial_launch','expected_approval',commercial_launch_status,to_date(expected_comm_launch_date,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;
--actual_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'commercial_launch','actual_approval',commercial_launch_status,to_date(actual_comm_launch_date,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;

--3. public_national_reimbursement_approval
--expected_submission
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'public_national_reimbursement_approval','expected_submission',public_national_reimbursement_approval_status ,to_date(expected_public_national_reimbursement_submission_date,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;
--actual_submission
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'public_national_reimbursement_approval','actual_submission',public_national_reimbursement_approval_status ,to_date(actual_public_national_reimbursement_submission_date ,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;
--expected_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'public_national_reimbursement_approval','expected_approval',public_national_reimbursement_approval_status ,to_date(expected_public_national_reimbursement_approval_date ,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;
--actual_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'public_national_reimbursement_approval','actual_approval',public_national_reimbursement_approval_status ,to_date(actual_public_national_reimbursement_approval_date,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;

--4. diagnostic_reimbursement_approval
--expected_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'diagnostic_reimbursement_approval','expected_approval',diagnostic_reimbursement_approval_status,to_date(expected_diagnostic_reimbursement_approval_date ,'YYYY-MM-DD HH24:MI:SS.US') as "date"  from fact_ireal_mainlist_raw;
--actual_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'diagnostic_reimbursement_approval','actual_approval',diagnostic_reimbursement_approval_status,to_date(actual_diagnostic_reimbursement_approval_date ,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;

--5. pap_availability
--expected_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'pap_availability','expected_approval',pap_availability  ,to_date(expected_pap_launch_date,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;
--actual_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'pap_availability','actual_approval',pap_availability,to_date(actual_pap_launch_date ,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;

--6. ivs_availability
--expected_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'ivs_availability','expected_approval',ivs_availability  ,to_date(expected_ivs_launch_date ,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;
--actual_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'ivs_availability','actual_approval',ivs_availability,to_date(actual_ivs_launch_date ,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;

--7 bridging_program_availability
--expected_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'bridging_program_availability','expected_approval',bridging_program_availability  ,to_date(expected_bridging_program_launch_date  ,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;
--actual_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'bridging_program_availability','actual_approval',bridging_program_availability,to_date(actual_bridging_program_launch_date  ,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;

--8. gpi_pricing_approval
--expected_submission
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'gpi_pricing_approval','expected_submission',gpi_pricing_approval_status ,to_date(expected_gpi_submission_date,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;

--9. institution_#1_reimbursement_approval
--expected_submission
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'institution1_reimbursement_approval','expected_submission',"institution_#1_reimbursement_approval_status",to_date("expected_institution_#1_reimbursement_submission_date",'YYYY-MM-DD HH24:MI:SS.US') as "date"  from fact_ireal_mainlist_raw;
--actual_submission
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'institution1_reimbursement_approval','actual_submission',"institution_#1_reimbursement_approval_status",to_date("actual_institution_#1_reimbursement_submission_date",'YYYY-MM-DD HH24:MI:SS.US') as "date"  from fact_ireal_mainlist_raw;
--expected_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'institution1_reimbursement_approval','expected_approval',"institution_#1_reimbursement_approval_status",to_date("expected_institution_#1_reimbursement_approval_date" ,'YYYY-MM-DD HH24:MI:SS.US') as "date"  from fact_ireal_mainlist_raw;
--actual_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'institution1_reimbursement_approval','actual_approval',"institution_#1_reimbursement_approval_status",to_date("actual_institution_#1_reimbursement_approval_date" ,'YYYY-MM-DD HH24:MI:SS.US') as "date"  from fact_ireal_mainlist_raw;

--10. institution_#2_reimbursement_approval
--expected_submission
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'institution2_reimbursement_approval','expected_submission',"institution_#2_reimbursement_approval_status",to_date("expected_institution_#2_reimbursement_submission_date",'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;
--actual_submission
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'institution2_reimbursement_approval','actual_submission',"institution_#2_reimbursement_approval_status",to_date("actual_institution_#2_reimbursement_submission_date",'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;
--expected_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'institution2_reimbursement_approval','expected_approval',"institution_#2_reimbursement_approval_status",to_date("expected_institution_#2_reimbursement_approval_date" ,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;
--actual_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'institution2_reimbursement_approval','actual_approval',"institution_#2_reimbursement_approval_status",to_date("actual_institution_#2_reimbursement_approval_date" ,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;

--11. institution_#3_reimbursement_approval
--expected_submission
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'institution3_reimbursement_approval','expected_submission',"institution_#3_reimbursement_approval_status",to_date("expected_institution_#3_reimbursement_submission_date",'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;
--actual_submission
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'institution3_reimbursement_approval','actual_submission',"institution_#3_reimbursement_approval_status",to_date("actual_institution_#3_reimbursement_submission_date",'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;
--expected_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'institution3_reimbursement_approval','expected_approval',"institution_#3_reimbursement_approval_status",to_date("expected_institution_#3_reimbursement_approval_date" ,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;
--actual_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'institution3_reimbursement_approval','actual_approval',"institution_#3_reimbursement_approval_status",to_date("actual_institution_#3_reimbursement_approval_date",'YYYY-MM-DD HH24:MI:SS.US') as "date"  from fact_ireal_mainlist_raw;

--12. private_insurance_approval
--expected_submission
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'private_insurance_approval','expected_submission',private_insurance_approval_status ,to_date(expected_private_insurance_submission_date ,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;
--actual_submission
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'private_insurance_approval','actual_submission',private_insurance_approval_status ,to_date(actual_private_insurance_submission_date ,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;
--expected_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'private_insurance_approval','expected_approval',private_insurance_approval_status ,to_date(expected_private_insurance_approval_date ,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;
--actual_approval
INSERT INTO fact_ireal_event
(market, brand, indication, ireal_phase, ireal_status, latest_status, "date")
select market, brand, indication,'private_insurance_approval','actual_approval',private_insurance_approval_status ,to_date(actual_private_insurance_approval_date ,'YYYY-MM-DD HH24:MI:SS.US') as "date" from fact_ireal_mainlist_raw;

-- 13. Update Dates in fact_ireal_event
update fact_ireal_event fie set "date" = to_date(case when to_char("date",'dd')<'25' then to_char("date",'yyyy-mm') when to_char("date",'dd')>='25' then to_char("date"+ INTERVAL '1 month','yyyy-mm') else null end, 'yyyy-mm');
RAISE NOTICE 'iREAL Step2 - fact_ireal_event cleanse done';

-- 14. alter table owner
CREATE INDEX fact_ireal_event_market_idx ON public.fact_ireal_event (market,brand,indication);
alter table fact_ireal_mainlist_raw owner to az_user_dw;
alter table fact_ireal_metric owner to az_user_dw;
alter table fact_ireal_event owner to az_user_dw;

RAISE NOTICE 'iREAL Ready';

END;
$procedure$
;

