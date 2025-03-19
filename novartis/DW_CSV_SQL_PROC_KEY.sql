-- DROP PROCEDURE public.proc_cleanse_areamarketcycledata();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_areamarketcycledata()
 LANGUAGE plpgsql
AS $procedure$
begin

--==========================================================================================================================
-- AreaMarketCycleData cleansing
--==========================================================================================================================
RAISE NOTICE 'AreaMarketCycleData started';

drop table if exists "AreaMarketCycleData_arc" CASCADE;
alter table "AreaMarketCycleData" rename to "AreaMarketCycleData_arc";

-- 1. Standardize column names and calculate MarketSize
create table "AreaMarketCycleData_1" as 
select
	"Cycle"::varchar(20),
	"ExternalAreaID"::varchar(20),
	max("ExternalAreaName")::varchar(100) as "ExternalAreaName",
	max("ExternalAreaName_EN")::varchar(100) as "ExternalAreaName_EN",
	"MarketName"::varchar(100),
	min("ExternalProductID")::varchar(100) as "ExternalProductID",
	"ExternalProductGroup"::varchar(100) as "ExternalProductName",
	max(split_part("ExternalProductName_EN", '  ',1))::varchar(100) as "ExternalProductName_EN",
	max("IsInternalProduct"::text)::bool as "IsInternalProduct",
	max("ProductID")::varchar(20) as "ProductID",
	max("ProductName")::varchar(100) as "ProductName",
	max("ProductName_EN")::varchar(100) as "ProductName_EN",
	sum("SalesValue"::numeric(255,8)) as "SalesValue",
	sum("LYSalesValue"::numeric(255,8)) as "LYSalesValue",
	sum("SalesUnit"::numeric(255,8)) as "SalesUnit",
	sum("LYSalesUnit"::numeric(255,8)) as "LYSalesUnit",
	sum(sum("SalesValue"::numeric(255,8)))over(partition by "ExternalAreaID", "MarketName", "Cycle") as "MarketValueSize",
	sum(sum("LYSalesValue"::numeric(255,8)))over(partition by "ExternalAreaID", "MarketName", "Cycle") as "LYMarketValueSize",
	sum(sum("SalesUnit"::numeric(255,8)))over(partition by "ExternalAreaID", "MarketName", "Cycle") as "MarketUnitSize",
	sum(sum("LYSalesUnit"::numeric(255,8)))over(partition by "ExternalAreaID", "MarketName", "Cycle") as "LYMarketUnitSize"
from
	"AreaMarketCycleData_raw"
group by
	"ExternalAreaID",
	"MarketName",
	"Cycle",
	"ExternalProductGroup"; --	34680

-- 1.1 Update IsInternalProduct, ProductID, ProductName, ProductName_EN
update "AreaMarketCycleData_1" amcd set "IsInternalProduct" = true, "ProductID" = pm."ProductID", "ProductName" = pm."ProductName", "ProductName_EN" = pm."ProductName_EN"
from "ProductMapping" pm where amcd."ExternalProductID" = pm."IMS_ProductID" and amcd."MarketName" = pm."Market" ; --7677

RAISE NOTICE 'AMCD Step1 - Standardize columns done';

-- 2. Create a Cartesian table with the CROSS JOIN of ins+prod_mkt+cycle
drop table if exists "AreaMarketCycleData_2";
create table "AreaMarketCycleData_2" as select * from "AreaMarketCycleData_1" where 1=2;
-- 2.1 insert Cross-join result as a framework
INSERT INTO "AreaMarketCycleData_2" 
("Cycle", "ExternalAreaID", "ExternalAreaName", "ExternalAreaName_EN", "MarketName", "ExternalProductID", "ExternalProductName", "ExternalProductName_EN", "IsInternalProduct", "ProductID", "ProductName", "ProductName_EN") 
select "Cycle", "ExternalAreaID", "ExternalAreaName", "ExternalAreaName_EN", "MarketName", "ExternalProductID", "ExternalProductName", "ExternalProductName_EN", "IsInternalProduct", "ProductID", "ProductName", "ProductName_EN"
from (select distinct "MarketName", min("ExternalProductID") as "ExternalProductID", "ExternalProductName", max("ExternalProductName_EN") as "ExternalProductName_EN", max("IsInternalProduct"::text)::bool as "IsInternalProduct", max("ProductID") as "ProductID", max("ProductName") as "ProductName", max("ProductName_EN") as "ProductName_EN" from "AreaMarketCycleData_1" group by "MarketName", "ExternalProductName") prod
join (select distinct "Cycle" from "AreaMarketCycleData_1") cal on 1=1
join (select distinct "ExternalAreaID", "ExternalAreaName", "ExternalAreaName_EN" from "AreaMarketCycleData_1") geo on 1=1;--35712 (32*18*62)

drop index if exists amcd2_pk_idx;
CREATE INDEX amcd2_pk_idx ON public."AreaMarketCycleData_2" ("Cycle","ExternalAreaID","MarketName","ExternalProductID");
RAISE NOTICE 'AMCD Step2.1 - Create Cross Join table done';

-- 2.2 Attach values to the Cartesian table 
update "AreaMarketCycleData_2" f
set
	"SalesValue" = f1."SalesValue",
	"LYSalesValue" = f1."LYSalesValue",
	"SalesUnit" = f1."SalesUnit",
	"LYSalesUnit"= f1."LYSalesUnit",
	"MarketValueSize"=f1."MarketValueSize",
	"LYMarketValueSize" = f1."LYMarketValueSize",
	"MarketUnitSize" = f1."MarketUnitSize",
	"LYMarketUnitSize" = f1."LYMarketUnitSize"
from "AreaMarketCycleData_1" f1
where f."Cycle" = f1."Cycle" and f."ExternalAreaID" = f1."ExternalAreaID" and f."MarketName" = f1."MarketName" and f."ExternalProductID" = f1."ExternalProductID";  --Updated Rows	34680

RAISE NOTICE 'AMCD Step2.2 - Attach values to Cross Join table done';

-- 2.3 Update market size data for no sales records
drop table if exists "AreaMarketCycleData_size";
create table "AreaMarketCycleData_size" as 
select
	"ExternalAreaID",
	"Cycle",
	"MarketName",
	max("MarketValueSize") as "MarketValueSize",
	max("LYMarketValueSize") as "LYMarketValueSize",
	max("MarketUnitSize") as "MarketUnitSize",
	max("LYMarketUnitSize") as "LYMarketUnitSize"
from "AreaMarketCycleData_1" f1
group by "ExternalAreaID","Cycle","MarketName"; --3327
drop index if exists amcds_pk_idx;
CREATE INDEX amcds_pk_idx ON "AreaMarketCycleData_size" USING btree ("ExternalAreaID", "MarketName", "Cycle");

update "AreaMarketCycleData_2" f
set
	"MarketValueSize"=f1."MarketValueSize",
	"LYMarketValueSize" = f1."LYMarketValueSize",
	"MarketUnitSize" = f1."MarketUnitSize",
	"LYMarketUnitSize" = f1."LYMarketUnitSize"
from "AreaMarketCycleData_size" f1
where f."Cycle" = f1."Cycle" and f."ExternalAreaID" = f1."ExternalAreaID" and f."MarketName" = f1."MarketName";  --34680

RAISE NOTICE 'AMCD Step2.3 - Update Size for IMCD done';

-- 4. Drop internal tables
alter table "AreaMarketCycleData_2" rename to "AreaMarketCycleData";
drop table "AreaMarketCycleData_1";
drop table "AreaMarketCycleData_size";

alter table "AreaMarketCycleData" owner to nvs_user_dw;
RAISE NOTICE 'AMCD Done, remember to VACUUM the table';


end;
$procedure$
;

-- DROP PROCEDURE public.proc_cleanse_geography();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_geography()
 LANGUAGE plpgsql
AS $procedure$
BEGIN
	

--=============================================================================================================================
-- Geography
--=============================================================================================================================
RAISE NOTICE 'Geography started';

drop table if exists "Geography_arc";
create table "Geography_arc" as select * from "Geography";
truncate "Geography";

insert into "Geography" 
select
	"CountyID",
	"CountyName",
	"CountyName_EN",
	"CityID",
	"CityName",
	"CityName_EN",
	"ProvinceID",
	"ProvinceName",
	"ProvinceName_EN",
	"CountyTier",
	"CityTier",
	'CN' as "CountryID",
	'中国' as "CountryName",
	'China' as "CountryName_EN"
from "Geography_raw";

alter table "Geography" owner to nvs_user_dw;
alter table "Geography_arc" owner to nvs_user_dw;

RAISE NOTICE 'Geography Ready';


END;
$procedure$
;

-- DROP PROCEDURE public.proc_cleanse_insmarketcycledata();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_insmarketcycledata()
 LANGUAGE plpgsql
AS $procedure$
begin

--==========================================================================================================================
-- InsMarketCycleData cleansing
--==========================================================================================================================
RAISE NOTICE 'InsMarketCycleData started';

drop table if exists "InsMarketCycleData_arc" CASCADE;
alter table "InsMarketCycleData" rename to "InsMarketCycleData_arc";

-- 1. Standardize column names and column type, and map product columns
drop table if exists "InsMarketCycleData_1";
create table "InsMarketCycleData_1" as select * from "InsMarketCycleData_arc" where 1=2;
insert into "InsMarketCycleData_1" ("Cycle", "InstitutionID", "InstitutionName", "MarketName", "ExternalProductID", "ExternalProductName", "ExternalProductName_EN", "IsInternalProduct", "ProductID", "ProductName", "ProductName_EN", "SalesValue", "LYSalesValue", "SalesUnit", "LYSalesUnit", "MarketValueSize", "LYMarketValueSize", "MarketUnitSize", "LYMarketUnitSize")
select
	cycle as "Cycle",
	institutionid as "InstitutionID",
	institutionname as "InstitutionName",
	upper(marketname) as "MarketName",
	externalproductid as "ExternalProductID",
	externalproductname as "ExternalProductName",
	externalproductname as "ExternalProductName_EN",
	case when pm."ProductID" is not null then true else false end as "IsInternalProduct",
	pm."ProductID",
	pm."ProductName",
	pm."ProductName_EN",
	salesvalue::numeric(255,8) as "SalesValue",
	lysalesvalue::numeric(255,8) as "LYSalesValue",
	salesunit::numeric(255,8) as "SalesUnit",
	lysalesunit::numeric(255,8) as "LYSalesUnit",
	marketvaluesize::numeric(255,8) as "MarketValueSize",
	lymarketvaluesize::numeric(255,8) as "LYMarketValueSize",
	marketunitsize::numeric(255,8) as "MarketUnitSize",
	lymarketunitsize::numeric(255,8) as "LYMarketUnitSize"
from "InsMarketCycleData_raw" imcdr
left join "ProductMapping" pm on imcdr.externalproductid = pm."CPA_ProductID" and upper(imcdr.marketname) = pm."Market"
; --689187

RAISE NOTICE 'IMCD Step1 - Standardize columns done';

-- 2. Calculate Market Size columns
drop table if exists "InsMarketCycleData_2";
create table "InsMarketCycleData_2" as
select
	"Cycle"::varchar(20),
	"InstitutionID"::varchar(20),
	max("InstitutionName")::varchar(100) as "InstitutionName",
	"MarketName"::varchar(100),
	"ExternalProductID"::varchar(20) as "ExternalProductID",
	max("ExternalProductName")::varchar(100) as "ExternalProductName",
	max("ExternalProductName_EN")::varchar(100) as "ExternalProductName_EN",
	max("IsInternalProduct"::text)::bool as "IsInternalProduct",
	max("ProductID")::varchar(20) as "ProductID",
	max("ProductName")::varchar(100) as "ProductName",
	max("ProductName_EN")::varchar(100) as "ProductName_EN",
	sum("SalesValue")::numeric(255,8) as "SalesValue",
	sum("LYSalesValue")::numeric(255,8) as "LYSalesValue",
	sum("SalesUnit")::numeric(255,8) as "SalesUnit",
	sum("LYSalesUnit")::numeric(255,8) as "LYSalesUnit",
	sum(sum(coalesce("SalesValue",0)))over(partition by "InstitutionID", "MarketName", "Cycle")::numeric(255,8) as "MarketValueSize", 
	sum(sum(coalesce("LYSalesValue",0)))over(partition by "InstitutionID", "MarketName", "Cycle")::numeric(255,8) as "LYMarketValueSize", 
	sum(sum(coalesce("SalesUnit",0)))over(partition by "InstitutionID", "MarketName", "Cycle")::numeric(255,8) as "MarketUnitSize", 
	sum(sum(coalesce("LYSalesUnit",0)))over(partition by "InstitutionID", "MarketName", "Cycle")::numeric(255,8) as "LYMarketUnitSize"
from "InsMarketCycleData_1"
group by "InstitutionID", "ExternalProductID", "MarketName", "Cycle"; --689187

drop index if exists imcd2_pk_idx;
CREATE INDEX imcd2_pk_idx ON "InsMarketCycleData_2" USING btree ("InstitutionID", "ExternalProductID", "MarketName", "Cycle");
RAISE NOTICE 'IMCD Step2 - Calculate Market Size done';

-- 3. Create a Cartesian table with the CROSS JOIN of ins+prod_mkt+cycle
drop table if exists "InsMarketCycleData_3";
create table "InsMarketCycleData_3" as select * from "InsMarketCycleData_2" where 1=2;
-- 3.1 insert Cross-join result as a framework
insert into "InsMarketCycleData_3" ("Cycle", "InstitutionID", "InstitutionName", "MarketName", "ExternalProductID", "ExternalProductName", "ExternalProductName_EN", "IsInternalProduct", "ProductID", "ProductName", "ProductName_EN")
select "Cycle", "InstitutionID", "InstitutionName", "MarketName", "ExternalProductID", "ExternalProductName", "ExternalProductName_EN", "IsInternalProduct", "ProductID", "ProductName", "ProductName_EN"
from
(select distinct "MarketName", "ExternalProductID", "ExternalProductName", "ExternalProductName_EN", "IsInternalProduct", "ProductID", "ProductName", "ProductName_EN" from "InsMarketCycleData_2") prod
join (select distinct "InstitutionID", "InstitutionName" from "InsMarketCycleData_2") ins on 1=1
join (select distinct "Cycle" from "InsMarketCycleData_2") cycle on 1=1;--3,258,424

drop index if exists imcd3_pk_idx;
CREATE INDEX imcd3_pk_idx ON "InsMarketCycleData_3" USING btree ("InstitutionID", "ExternalProductID", "MarketName", "Cycle");
RAISE NOTICE 'IMCD Step3.1 - Create Cross Join table done';

-- 3.2 Attach values to the Cartesian table 
update "InsMarketCycleData_3" f
set "SalesValue" = f2."SalesValue", "LYSalesValue" = f2."LYSalesValue", "SalesUnit" = f2."SalesUnit", "LYSalesUnit" = f2."LYSalesUnit"
from "InsMarketCycleData_2" f2
where f."InstitutionID" = f2."InstitutionID" and f."ExternalProductID" = f2."ExternalProductID" and f."MarketName" = f2."MarketName" and f."Cycle" = f2."Cycle";  --689187
RAISE NOTICE 'IMCD Step3.2 - Attach values to Cross Join table done';

-- 3.3 Update market size data for no sales records
drop table if exists "InsMarketCycleData_size";
create table "InsMarketCycleData_size" as 
select
	"InstitutionID",
	"MarketName",
	"Cycle",
	max("MarketValueSize") as "MarketValueSize",
	max("LYMarketValueSize") as "LYMarketValueSize",
	max("MarketUnitSize") as "MarketUnitSize",
	max("LYMarketUnitSize") as "LYMarketUnitSize"
from "InsMarketCycleData_2"
group by "InstitutionID", "MarketName", "Cycle"; --96462
drop index if exists imcds_pk_idx;
CREATE INDEX imcds_pk_idx ON "InsMarketCycleData_size" USING btree ("InstitutionID", "MarketName", "Cycle");

update "InsMarketCycleData_3" f
set
	"MarketValueSize" = imcds."MarketValueSize",
	"LYMarketValueSize" = imcds."LYMarketValueSize",
	"MarketUnitSize" = imcds."MarketUnitSize",
	"LYMarketUnitSize" = imcds."LYMarketUnitSize"
from "InsMarketCycleData_size" imcds
where f."InstitutionID" = imcds."InstitutionID" and f."MarketName" = imcds."MarketName" and f."Cycle" = imcds."Cycle";  --Updated Rows	2,556,991

RAISE NOTICE 'IMCD Step3.3 - Update Size for IMCD done';

-- 4. Drop internal tables
alter table "InsMarketCycleData_3" rename to "InsMarketCycleData";
drop table "InsMarketCycleData_1";
drop table "InsMarketCycleData_2";
drop table "InsMarketCycleData_size";

alter table "InsMarketCycleData" owner to nvs_user_dw;

RAISE NOTICE 'IMCD Done, remember to VACUUM the table';


end;
$procedure$
;

-- DROP PROCEDURE public.proc_cleanse_insprodproperty();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_insprodproperty()
 LANGUAGE plpgsql
AS $procedure$
BEGIN
	

--=============================================================================================================================
-- InsProdProperty
--=============================================================================================================================
RAISE NOTICE 'InsProdProperty started';

drop table if exists "InsProdProperty_arc";
create table "InsProdProperty_arc" as select * from "InsProdProperty";
truncate "InsProdProperty";

insert into "InsProdProperty" 
select
	ipp.institutionid as "InstitutionID",
	ipp.institutionname as "InstitutionName",
	null as "InstitutionName_EN",
	p."ProductID",
	p."ProductName",
	p."ProductName_EN",
	p."ProductName" as "ProductName_DF",
	ipp.insprodproperty1 as "InsProdProperty1",
	null as "InsProdProperty2",
	null as "InsProdProperty3"
from "InsProdProperty_raw" ipp
join "Product" p on ipp.productname_en = p."ProductName_EN" 
; 

update "InsProdProperty" set "ProductID"='556',"ProductName"='典必殊',"ProductName_EN"='Tobradex' 
where "ProductID" in ('2073', '556'); --Updated Rows	15014
update "InsProdProperty" set "ProductID"='4',"ProductName"='曲莱',"ProductName_EN"='Trileptal' 
where "ProductID" in ('4', '47'); --0
update "InsProdProperty" set "ProductID"='18',"ProductName"='艾斯能',"ProductName_EN"='Exelon' 
where "ProductID" in ('18', '945'); --0

delete from "InsProdProperty" where "ProductName" =''and "ProductID"=''and"ProductName_EN"='';--0

alter table "InsProdProperty" owner to nvs_user_dw;
alter table "InsProdProperty_arc" owner to nvs_user_dw;

RAISE NOTICE 'InsProdProperty Ready';


END;
$procedure$
;

-- DROP PROCEDURE public.proc_cleanse_institution();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_institution()
 LANGUAGE plpgsql
AS $procedure$
BEGIN
	

--=============================================================================================================================
-- Institution
--=============================================================================================================================
RAISE NOTICE 'Institution started';

drop table if exists "Institution_arc";
create table "Institution_arc" as select * from "Institution";
truncate "Institution";

insert into "Institution"
select
	ir.hp_id as "InstitutionID",
	ir.hp_name as "InstitutionName",
	null as "InstitutionName_EN",
	null as "InstitutionType1",
	property_lv2 as "InstitutionType2",
	null as "InstitutionType3",
	null as "InstitutionType4",
	standard_level as "InstitutionTier",
	g."CountyID",
	g."CountyName",
	g."CityID",
	g."CityName",
	g."ProvinceID",
	g."ProvinceName",
	g."CountyTier",
	g."CityTier",
	g."CountryID",
	g."CountryName"
from
	"Institution_raw" ir
join "Geography" g on ir.county_id::text = g."CountyID"; --Updated Rows	14173

alter table "Institution" owner to nvs_user_dw;
alter table "Institution_arc" owner to nvs_user_dw;

RAISE NOTICE 'Institution Ready';


END;
$procedure$
;

-- DROP PROCEDURE public.proc_cleanse_instrtyproductchannelcycledata();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_instrtyproductchannelcycledata()
 LANGUAGE plpgsql
AS $procedure$
begin

--==========================================================================================================================
-- InsTrtyProductChannelCycleData cleansing
--==========================================================================================================================
RAISE NOTICE 'InsTrtyProductChannelCycleData cleansing started';

drop table if exists "InsTrtyProductChannelCycleData_arc" CASCADE;
create table "InsTrtyProductChannelCycleData_arc" as select * from "InsTrtyProductChannelCycleData";
truncate "InsTrtyProductChannelCycleData";

-- Step1. Standardize column names and column type 
create table "InsTrtyProductChannelCycleData_1" as 
select
	repterritoryid as "RepTerritoryCode",
	"cycle" as "Cycle",
	null as "SubInsID",
	null as "SubInsName",
	channel_type as "SubInsType",
	institutionid as "InsID",
	institutionname as "InsName",
	p."ProductID" as "ProductID",
	p."ProductName" as "ProductName",
	productname as "ProductName_EN",
	franchise as "Franchise",
	replace(salesvalue,',','')::numeric(255,8) as "SalesValue",
	replace(lysalesvalue,',','')::numeric(255,8) as "LYSalesValue",
	replace(salesunit,',','')::numeric(255,8) as "SalesUnit",
	replace(lysalesunit,',','')::numeric(255,8) as "LYSalesUnit"
from "InsTrtyProductChannelCycleData_raw" itpccd
join "Product" p on itpccd.productname = p."ProductName_EN"
where itpccd.channel_type is not null
;--677,348

RAISE NOTICE 'ITPCCD Step1 - Standardize column Done';

-- Step2. Create cross-join table
create table "InsTrtyProductChannelCycleData_2" as select * from "InsTrtyProductChannelCycleData_1" where 1=2;
insert into "InsTrtyProductChannelCycleData_2" ("RepTerritoryCode", "Cycle", "SubInsID", "SubInsName", "SubInsType", "InsID", "InsName", "ProductID", "ProductName", "ProductName_EN", "Franchise") 
select
	"RepTerritoryCode",
	"Cycle",
	null as "SubInsID",
	null as "SubInsName",
	"SubInsType",
	"InsID",
	"InsName",
	"ProductID",
	"ProductName",
	"ProductName_EN",
	"Franchise"
from (select distinct "RepTerritoryCode", "Cycle", "InsID", "InsName", "ProductID", "ProductName", "ProductName_EN", "Franchise" from "InsTrtyProductChannelCycleData_1") itpcd
join (select distinct "SubInsType" from "InsTrtyProductChannelCycleData_1") ch on 1=1;
--Updated Rows	2,668,215

-- Step2.1 Attach values to the cross-join table 
update "InsTrtyProductChannelCycleData_2" f
set
	"SalesValue" = f1."SalesValue",
	"LYSalesValue" = f1."LYSalesValue",
	"SalesUnit" = f1."SalesUnit",
	"LYSalesUnit" = f1."LYSalesUnit"
from "InsTrtyProductChannelCycleData_1" f1
where f."InsID" = f1."InsID" and f."RepTerritoryCode" = f1."RepTerritoryCode" and f."ProductID" = f1."ProductID" and f."Cycle" = f1."Cycle" and f."SubInsType" = f1."SubInsType";  --677,348

-- Step2.2 Drop internal tables
drop index if exists itpccd_pk_idx;
drop index if exists itpccd_pk_idx2;
INSERT INTO "InsTrtyProductChannelCycleData" ("RepTerritoryCode", "Cycle", "SubInsID", "SubInsName", "SubInsType", "InsID", "InsName", "ProductID", "ProductName", "ProductName_EN", "Franchise", "SalesValue", "LYSalesValue", "SalesUnit", "LYSalesUnit") 
select * from "InsTrtyProductChannelCycleData_2";--Updated Rows	2668215
create index itpccd_pk_idx on public."InsTrtyProductChannelCycleData" ("InsID","RepTerritoryCode","ProductID","Cycle","SubInsType");
create index itpccd_pk_idx2 on public."InsTrtyProductChannelCycleData" ("InsID","RepTerritoryCode","ProductID","Cycle");

RAISE NOTICE 'ITPCCD Step2 - Cross-join table Done';

--Step3. Update InsTrtyProductQuarterChannelData
drop table if exists InsTrtyProductQuarterChannelSales;
CREATE TEMP Table InsTrtyProductQuarterChannelSales AS
SELECT C.QUARTER_TEXT,
	max(C.quarter_start_date) as quarter_start_date,
	max(C.quarter_end_date) as quarter_end_date,
	itpccd."SubInsType" as sales_channel,
	ITPCD."InsID" as InsID,
	MAX(ITPCD."InsName") as InsName,
	ITPCD."RepTerritoryCode" as RepTerritoryCode,
	ITPCD."ProductID" as ProductID,
	MAX(ITPCD."ProductName") as ProductName,
	MAX(ITPCD."ProductName_EN") as ProductName_EN,	
	round(sum(itpccd."SalesValue"),2) as sales_cq,
	round(sum(itpccd."SalesValue") / nullif(count(distinct itpccd."Cycle"),0),2) AS avg_sales_cq,
	round(sum(itpcd."SalesValue")/nullif(count(distinct itpccd."SubInsType"),0),2) as sales_xchannel_cq
from "InsTrtyProductCycleData" itpcd
join "InsTrtyProductChannelCycleData" itpccd on itpccd."InsID" = itpcd."InsID" and itpccd."RepTerritoryCode" = itpcd."RepTerritoryCode" and itpccd."ProductID" =itpcd."ProductID" and itpccd."Cycle" =itpcd."Cycle" 
join dim_calendar c ON itpcd."Cycle" = c.MONTH_TEXT and c.DAY_OF_MONTH_NUM = 1
GROUP BY C.QUARTER_TEXT,
	itpccd."SubInsType",
	ITPCD."InsID",
	ITPCD."RepTerritoryCode",
	ITPCD."ProductID"
order by 	itpccd."SubInsType",
	ITPCD."InsID",
	ITPCD."RepTerritoryCode",
	ITPCD."ProductID",
	C.QUARTER_TEXT; -- 295043

drop table if exists InsTrtyProductLastQuarterChannelSales;
CREATE TEMP Table InsTrtyProductLastQuarterChannelSales AS
SELECT C.QUARTER_TEXT,
	max(C.quarter_start_date) as quarter_start_date,
	max(C.quarter_end_date) as quarter_end_date,
	itpccd."SubInsType" as sales_channel,
	ITPCD."InsID" as InsID,
	MAX(ITPCD."InsName") as InsName,
	ITPCD."RepTerritoryCode" as RepTerritoryCode,
	ITPCD."ProductID" as ProductID,
	MAX(ITPCD."ProductName") as ProductName,
	MAX(ITPCD."ProductName_EN") as ProductName_EN,	
	round(sum(itpccd."SalesValue"),2) AS sales_lq,
	round(sum(itpccd."SalesValue") / nullif(count(distinct itpccd."Cycle"),0),2) AS avg_sales_lq,
	round(sum(itpcd."SalesValue")/nullif(count(distinct itpccd."SubInsType"),0),2) as sales_xchannel_lq
from "InsTrtyProductCycleData" itpcd
join "InsTrtyProductChannelCycleData" itpccd on itpccd."InsID" = itpcd."InsID" and itpccd."RepTerritoryCode" = itpcd."RepTerritoryCode" and itpccd."ProductID" =itpcd."ProductID" and itpccd."Cycle" =itpcd."Cycle" 
JOIN DIM_CALENDAR C ON to_date(ITPCD."Cycle",'yyyymm') = to_date(C.MONTH_TEXT,'yyyymm')-interval '3 month' and C.DAY_OF_MONTH_NUM = 1
GROUP BY C.QUARTER_TEXT,
	itpccd."SubInsType",
	ITPCD."InsID",
	ITPCD."RepTerritoryCode",
	ITPCD."ProductID"
order by itpccd."SubInsType",
	ITPCD."InsID",
	ITPCD."RepTerritoryCode",
	ITPCD."ProductID",
	C.QUARTER_TEXT; -- 295043

drop table if exists "InsTrtyProductQuarterChannelData";
CREATE Table "InsTrtyProductQuarterChannelData" AS
select cq.*, lq.sales_lq, lq.avg_sales_lq, lq.sales_xchannel_lq
from InsTrtyProductQuarterChannelSales cq
left join InsTrtyProductLastQuarterChannelSales lq 
on cq.QUARTER_TEXT=lq.QUARTER_TEXT 
and cq.InsID=lq.InsID 
and cq.RepTerritoryCode=lq.RepTerritoryCode 
and cq.ProductID=lq.ProductID
and cq.sales_channel = lq.sales_channel;
-- 295043

RAISE NOTICE 'ITPCCD Step3 - ITPQCD Refresh Done';

--Step4. Update InsTrtyProductMonthData
drop table if exists InsTrtyProductMonthChannelSales;
CREATE TEMP Table InsTrtyProductMonthChannelSales AS
SELECT itpcd."Cycle" as month_text,
	itpccd."SubInsType" as sales_channel,
	ITPCD."InsID" as InsID,
	MAX(ITPCD."InsName") as InsName,
	ITPCD."RepTerritoryCode" as RepTerritoryCode,
	ITPCD."ProductID" as ProductID,
	MAX(ITPCD."ProductName") as ProductName,
	MAX(ITPCD."ProductName_EN") as ProductName_EN,	
	round(sum(itpccd."SalesValue"),2) as sales_cm,
	round(sum(itpccd."SalesValue") / nullif(count(distinct itpccd."Cycle"),0),2) AS avg_sales_cm,
	round(sum(itpcd."SalesValue")/nullif(count(distinct itpccd."SubInsType"),0),2) as sales_xchannel_cm
from "InsTrtyProductCycleData" itpcd
join "InsTrtyProductChannelCycleData" itpccd on itpccd."InsID" = itpcd."InsID" and itpccd."RepTerritoryCode" = itpcd."RepTerritoryCode" and itpccd."ProductID" =itpcd."ProductID" and itpccd."Cycle" =itpcd."Cycle" 
GROUP BY itpcd."Cycle",
	itpccd."SubInsType",
	ITPCD."InsID",
	ITPCD."RepTerritoryCode",
	ITPCD."ProductID"
order by 	itpccd."SubInsType",
	ITPCD."InsID",
	ITPCD."RepTerritoryCode",
	ITPCD."ProductID",
	itpcd."Cycle"; -- 774998

drop table if exists InsTrtyProductLastMonthChannelSales;
CREATE TEMP Table InsTrtyProductLastMonthChannelSales AS
SELECT c.month_text,
	itpccd."SubInsType" as sales_channel,
	ITPCD."InsID" as InsID,
	MAX(ITPCD."InsName") as InsName,
	ITPCD."RepTerritoryCode" as RepTerritoryCode,
	ITPCD."ProductID" as ProductID,
	MAX(ITPCD."ProductName") as ProductName,
	MAX(ITPCD."ProductName_EN") as ProductName_EN,	
	round(sum(itpccd."SalesValue"),2) AS sales_lm,
	round(sum(itpccd."SalesValue") / nullif(count(distinct itpccd."Cycle"),0),2) AS avg_sales_lm,
	round(sum(itpcd."SalesValue")/nullif(count(distinct itpccd."SubInsType"),0),2) as sales_xchannel_lm
from "InsTrtyProductCycleData" itpcd
join "InsTrtyProductChannelCycleData" itpccd on itpccd."InsID" = itpcd."InsID" and itpccd."RepTerritoryCode" = itpcd."RepTerritoryCode" and itpccd."ProductID" =itpcd."ProductID" and itpccd."Cycle" =itpcd."Cycle" 
join dim_calendar c on to_date(itpcd."Cycle",'yyyymm') = to_date(c.month_text,'yyyymm')-interval '1 month' and c.day_of_month_num = 1
GROUP BY c.month_text,
	itpccd."SubInsType",
	ITPCD."InsID",
	ITPCD."RepTerritoryCode",
	ITPCD."ProductID"
order by itpccd."SubInsType",
	ITPCD."InsID",
	ITPCD."RepTerritoryCode",
	ITPCD."ProductID",
	c.month_text; -- 774998

drop table if exists "InsTrtyProductMonthChannelData";
CREATE Table "InsTrtyProductMonthChannelData" AS
select cm.*, lm.sales_lm, lm.avg_sales_lm, lm.sales_xchannel_lm
from InsTrtyProductMonthChannelSales cm
left join InsTrtyProductLastMonthChannelSales lm
on cm.month_text=lm.month_text 
and cm.InsID=lm.InsID 
and cm.RepTerritoryCode=lm.RepTerritoryCode 
and cm.ProductID=lm.ProductID
and cm.sales_channel = lm.sales_channel;
-- 774998

RAISE NOTICE 'ITPCCD Step4 - ITPMCD Refresh Done';

--Step5. Drop internal tables and Alter table owner
drop table "InsTrtyProductChannelCycleData_1";
drop table "InsTrtyProductChannelCycleData_2";
alter table "InsTrtyProductChannelCycleData" owner to nvs_user_dw;
alter table "InsTrtyProductQuarterData" owner to nvs_user_dw;
alter table "InsTrtyProductMonthData" owner to nvs_user_dw;

RAISE NOTICE 'ITPCCD Cleansing Done';


end;
$procedure$
;

-- DROP PROCEDURE public.proc_cleanse_instrtyproductcycledata();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_instrtyproductcycledata()
 LANGUAGE plpgsql
AS $procedure$
begin

--==========================================================================================================================
-- InsTrtyProductCycleData cleansing
--==========================================================================================================================
RAISE NOTICE 'InsTrtyProductCycleData cleansing started';

drop table if exists "InsTrtyProductCycleData_arc" CASCADE;
create table "InsTrtyProductCycleData_arc" as select * from "InsTrtyProductCycleData";
truncate "InsTrtyProductCycleData";

-- Step1. Standardize column names and calculate MarketSize
insert into "InsTrtyProductCycleData" ("RepTerritoryCode", "Cycle", "InsID", "InsName", "ProductID", "ProductName", "ProductName_EN", "ProductName_DF", "TargetValue", "SalesValue", "LYSalesValue", "TargetUnit", "SalesUnit", "LYSalesUnit", "FTE")
select
	repterritorycode as "RepTerritoryCode",
	cycle as "Cycle",
	insid as "InsID",
	insname as "InsName",
	p."ProductID" as "ProductID",
	p."ProductName" as "ProductName",
	productname as "ProductName_EN",
	p."ProductName" as "ProductName_DF",
	replace(targetvalue,',','')::numeric as "TargetValue",
	replace(salesvalue,',','')::numeric as "SalesValue",
	replace(lysalesvalue,',','')::numeric as "LYSalesValue",
	replace(targetunit,',','')::numeric as "TargetUnit",
	replace(salesunit,',','')::numeric as "SalesUnit",
	replace(lysalesunit,',','')::numeric as "LYSalesUnit",
	replace(fte,',','')::numeric as "FTE"
from
	"InsTrtyProductCycleData_raw" itpcd
join "Product" p on
	itpcd.productname = p."ProductName_EN";

RAISE NOTICE 'Step1 - ITPCD Refresh Done';

--Step2. Update InsTrtyProductQuarterData
drop table if exists InsTrtyProductQuarterSales;
CREATE TEMP Table InsTrtyProductQuarterSales AS
SELECT C.QUARTER_TEXT,
	max(C.quarter_start_date) as quarter_start_date,
	max(C.quarter_end_date) as quarter_end_date,
	ITPCD."InsID" as InsID,
	MAX(ITPCD."InsName") as InsName,
	ITPCD."RepTerritoryCode" as RepTerritoryCode,
	ITPCD."ProductID" as ProductID,
	MAX(ITPCD."ProductName") as ProductName,
	MAX(ITPCD."ProductName_EN") as ProductName_EN,	
	ROUND(SUM(ITPCD."SalesValue"),1) AS sales_cq,
	ROUND(SUM(ITPCD."SalesValue") / NULLIF(COUNT(DISTINCT ITPCD."Cycle"),0),1) AS avg_sales_cq,
	ROUND(SUM(ITPCD."SalesUnit"),1) AS sales_unit_cq,
	ROUND(SUM(ITPCD."SalesUnit") / NULLIF(COUNT(DISTINCT ITPCD."Cycle"),0),1) AS avg_sales_unit_cq
FROM "InsTrtyProductCycleData" ITPCD
JOIN DIM_CALENDAR C ON ITPCD."Cycle" = C.MONTH_TEXT and C.DAY_OF_MONTH_NUM = 1
GROUP BY C.QUARTER_TEXT,
	ITPCD."InsID",
	ITPCD."RepTerritoryCode",
	ITPCD."ProductID"
order by ITPCD."InsID",
	ITPCD."RepTerritoryCode",
	ITPCD."ProductID",
	C.QUARTER_TEXT; -- Updated Rows	708218

drop table if exists InsTrtyProductLastQuarterSales;
CREATE TEMP Table InsTrtyProductLastQuarterSales AS
SELECT C.QUARTER_TEXT,
	max(C.quarter_start_date) as quarter_start_date,
	max(C.quarter_end_date) as quarter_end_date,
	ITPCD."InsID" as InsID,
	MAX(ITPCD."InsName") as InsName,
	ITPCD."RepTerritoryCode" as RepTerritoryCode,
	ITPCD."ProductID" as ProductID,
	MAX(ITPCD."ProductName") as ProductName,
	MAX(ITPCD."ProductName_EN") as ProductName_EN,	
	ROUND(SUM(ITPCD."SalesValue"),1) AS sales_lq,
	ROUND(SUM(ITPCD."SalesValue") / NULLIF(COUNT(DISTINCT ITPCD."Cycle"),0),1) AS avg_sales_lq,
	ROUND(SUM(ITPCD."SalesUnit"),1) AS sales_unit_lq,
	ROUND(SUM(ITPCD."SalesUnit") / NULLIF(COUNT(DISTINCT ITPCD."Cycle"),0),1) AS avg_sales_unit_lq
FROM "InsTrtyProductCycleData" ITPCD
JOIN DIM_CALENDAR C ON to_date(ITPCD."Cycle",'yyyymm') = to_date(C.MONTH_TEXT,'yyyymm')-interval '3 month' and C.DAY_OF_MONTH_NUM = 1
GROUP BY C.QUARTER_TEXT,
	ITPCD."InsID",
	ITPCD."RepTerritoryCode",
	ITPCD."ProductID"
order by ITPCD."InsID",
	ITPCD."RepTerritoryCode",
	ITPCD."ProductID",
	C.QUARTER_TEXT; --Updated Rows	708218

drop table if exists "InsTrtyProductQuarterData";
CREATE Table "InsTrtyProductQuarterData" AS
select cq.*, lq.sales_lq, lq.avg_sales_lq, lq.sales_unit_lq, lq.avg_sales_unit_lq
from InsTrtyProductQuarterSales cq
left join InsTrtyProductLastQuarterSales lq 
on cq.QUARTER_TEXT=lq.QUARTER_TEXT 
and cq.InsID=lq.InsID 
and cq.RepTerritoryCode=lq.RepTerritoryCode 
and cq.ProductID=lq.ProductID;
-- Updated Rows	708218

RAISE NOTICE 'Step2 - ITPQD Refresh Done';

--Step3. Update InsTrtyProductMonthData
drop table if exists InsTrtyProductR3MSales;
CREATE TEMP Table InsTrtyProductR3MSales AS
SELECT C.month_text,
	max(c.rolling_3m_start_date) as rolling_3m_start_date,
	max(c.rolling_3m_end_date) as rolling_3m_end_date,
	ITPCD."InsID" as InsID,
	MAX(ITPCD."InsName") as InsName,
	ITPCD."RepTerritoryCode" as RepTerritoryCode,
	ITPCD."ProductID" as ProductID,
	MAX(ITPCD."ProductName") as ProductName,
	MAX(ITPCD."ProductName_EN") as ProductName_EN,	
	ROUND(sum(itpcd."SalesValue"),1) AS rolling_3m_sales,
	ROUND(sum(itpcd."SalesUnit"),1) AS rolling_3m_sales_unit
FROM "InsTrtyProductCycleData" ITPCD
JOIN DIM_CALENDAR C ON itpcd."Cycle" between to_char(c.rolling_3m_start_date,'yyyymm') and to_char(c.rolling_3m_end_date,'yyyymm') and C.DAY_OF_MONTH_NUM = 1
GROUP BY C.month_text,
	ITPCD."InsID",
	ITPCD."RepTerritoryCode",
	ITPCD."ProductID"
order by ITPCD."InsID",
	ITPCD."RepTerritoryCode",
	ITPCD."ProductID",
	C.month_text; -- Updated Rows	2124654

drop table if exists InsTrtyProductP3MSales;
CREATE TEMP Table InsTrtyProductP3MSales AS
SELECT to_char(to_date(c.month_text,'yyyymm') + interval '3 month', 'yyyymm') as month_text,
	max(c.rolling_3m_start_date) as previous_3m_start_date,
	max(c.rolling_3m_end_date) as previous_3m_end_date,
	ITPCD."InsID" as InsID,
	MAX(ITPCD."InsName") as InsName,
	ITPCD."RepTerritoryCode" as RepTerritoryCode,
	ITPCD."ProductID" as ProductID,
	MAX(ITPCD."ProductName") as ProductName,
	MAX(ITPCD."ProductName_EN") as ProductName_EN,	
	ROUND(sum(itpcd."SalesValue"),1) AS previous_3m_sales,
	ROUND(sum(itpcd."SalesUnit"),1) AS previous_3m_sales_unit
FROM "InsTrtyProductCycleData" ITPCD
JOIN DIM_CALENDAR C ON itpcd."Cycle" between to_char(c.rolling_3m_start_date,'yyyymm') and to_char(c.rolling_3m_end_date,'yyyymm') and C.DAY_OF_MONTH_NUM = 1
GROUP BY C.month_text,
	ITPCD."InsID",
	ITPCD."RepTerritoryCode",
	ITPCD."ProductID"
order by ITPCD."InsID",
	RepTerritoryCode,
	ProductID,
	month_text; -- Updated Rows	2124654
	
drop table "InsTrtyProductMonthData";
CREATE Table "InsTrtyProductMonthData" AS
select r3m.*, p3m.previous_3m_sales, p3m.previous_3m_sales_unit
from InsTrtyProductR3MSales r3m
left join InsTrtyProductP3MSales p3m 
on r3m.month_text=p3m.month_text 
and r3m.InsID=p3m.InsID 
and r3m.RepTerritoryCode=p3m.RepTerritoryCode 
and r3m.ProductID=p3m.ProductID; -- 2124654

RAISE NOTICE 'Step3 - ITPMD Refresh Done';

--Step4. Alter table owner
alter table "InsTrtyProductCycleData" owner to nvs_user_dw;
alter table "InsTrtyProductQuarterData" owner to nvs_user_dw;
alter table "InsTrtyProductMonthData" owner to nvs_user_dw;


end;
$procedure$
;

-- DROP PROCEDURE public.proc_cleanse_marketareamapping();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_marketareamapping()
 LANGUAGE plpgsql
AS $procedure$
BEGIN


--=============================================================================================================================
-- MarketAreaMapping
--=============================================================================================================================
RAISE NOTICE 'MarketAreaMapping started';

drop table if exists "MarketAreaMapping_arc";
create table "MarketAreaMapping_arc" as select * from "MarketAreaMapping";
truncate "MarketAreaMapping";

insert into "MarketAreaMapping"
select g."GeographyID", g."GeographyName", g."GeographyName_EN", ims."IMS_ExternalAreaID", ims."IMS_ExternalAreaName", ims."IMS_ExternalAreaName_EN"
from (select
 "IMS_ExternalAreaID",
 max(coalesce(amcd."ExternalAreaName","GeographyName")) as "IMS_ExternalAreaName",
 max(coalesce(amcd."ExternalAreaName_EN","GeographyName_EN")) as "IMS_ExternalAreaName_EN",
 max("GeographyID") as "GeographyID"
from "MarketAreaMapping_raw" mamr
left join (select distinct "ExternalAreaID", "ExternalAreaName", "ExternalAreaName_EN" from "AreaMarketCycleData_raw") amcd on mamr."IMS_ExternalAreaID" = amcd."ExternalAreaID"
group by "IMS_ExternalAreaID") ims
join (select distinct "GeographyID", "GeographyName", "GeographyName_EN" from "MarketAreaMapping_raw") g on ims."GeographyID" = g."GeographyID"
;

alter table "MarketAreaMapping" owner to nvs_user_dw;
alter table "MarketAreaMapping_arc" owner to nvs_user_dw;

RAISE NOTICE 'MarketAreaMapping Ready';


END;
$procedure$
;

-- DROP PROCEDURE public.proc_cleanse_orgcycle();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_orgcycle()
 LANGUAGE plpgsql
AS $procedure$
BEGIN


--=============================================================================================================================
-- OrgCycle
--=============================================================================================================================
RAISE NOTICE 'OrgCycle started';

drop table if exists "OrgCycle_arc";
create table "OrgCycle_arc" as select * from "OrgCycle";

update "OrgCycle_raw" set "TLMID" = "TLMTerritoryID", "FHID" = "FHTerritoryID" ;
update "OrgCycle_raw" set "RepTerritoryName" = "RepTerritoryID", "FLMTerritoryName" = "FLMTerritoryID", "SLMTerritoryName"="SLMTerritoryID", "TLMTerritoryID" = "TLMTerritoryName", "FHTerritoryID" = "FHTerritoryName";

insert into "OrgCycle"
select
 (select max("cycle") from "InsTrtyProductCycleData_raw" where "salesvalue">'0') as "Cycle",
 "RepTerritoryID",
 "RepTerritoryName",
 "RepProductLine",
 "RepTerritoryType1",
 "RepTerritoryType2",
 "RepID",
 "RepName",
 "FLMTerritoryID",
 "FLMTerritoryName",
 "FLMTerritoryType",
 "FLMID",
 "FLMName",
 "SLMTerritoryID",
 "SLMTerritoryName",
 "SLMID",
 "SLMName",
 "TLMTerritoryID",
 "TLMTerritoryName",
 "TLMID",
 "TLMName",
 "FHTerritoryID",
 "FHTerritoryName",
 "FHID",
 "FHName",
 "BUHTerritoryID",
 "BUHTerritoryName",
 "BUHID",
 "BUHName"
from "OrgCycle_raw";

alter table "OrgCycle" owner to nvs_user_dw;
alter table "OrgCycle_arc" owner to nvs_user_dw;

RAISE NOTICE 'OrgCycle Ready';


END;
$procedure$
;

-- DROP PROCEDURE public.proc_cleanse_product();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_product()
 LANGUAGE plpgsql
AS $procedure$
BEGIN
	

--=============================================================================================================================
-- Product
--=============================================================================================================================
RAISE NOTICE 'Product started';

drop table if exists "Product_arc";
create table "Product_arc" as select * from "Product";
truncate "Product";

insert into "Product" 
select
	sku_id as "ProductID",
	sku_name as "ProductName",
	sku_name as "ProductName_EN",
	'诺华产品' as "ProductLevel1",
	'Novartis Product' as "ProductLevel1_EN",
	ta_name as "ProductLevel2",
	ta_name as "ProductLevel2_EN",
	family_name as "ProductLevel3",
	family_name as "ProductLevel3_EN",
	brand_name as "ProductLevel4",
	brand_name as "ProductLevel4_EN",
	sku_name as "ProductLevel5",
	sku_name as "ProductLevel5_EN",
	null as "ProductLevel6",
	null as "ProductLevel6_EN",
	null as "ProductLevel7",
	null as "ProductLevel7_EN",
	null as "ProductLevel8",
	null as "ProductLevel8_EN",
	pm."Market" as "PrimaryMarket",
	null as "ProductFeature",
	null as "PriProductInMarket"
from "Product_raw" pr
join "ProductMapping" pm on pr.brand_id::text = pm."ProductID" and pm."IsKeyMarket";

alter table "Product" owner to nvs_user_dw;
alter table "Product_arc" owner to nvs_user_dw;

RAISE NOTICE 'Product Ready';


END;
$procedure$
;

-- DROP PROCEDURE public.proc_cleanse_productmapping();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_productmapping()
 LANGUAGE plpgsql
AS $procedure$
BEGIN
	

--=============================================================================================================================
-- ProductMapping
--=============================================================================================================================
RAISE NOTICE 'ProductMapping started';

drop table if exists "ProductMapping_arc";
create table "ProductMapping_arc" as select * from "ProductMapping";
truncate "ProductMapping";

insert into "ProductMapping" 
select
	"ProductID",
	"ProductName",
	"ProductName_EN",
	"IMS_ProductID",
	"IMS_ProductName",
	"IMS_ProductName_EN",
	"CPA_ProductID",
	"CPA_ProductName",
	"Market",
	"IsKeyMarket"::bool
from
	"ProductMapping_raw";

alter table "ProductMapping" owner to nvs_user_dw;
alter table "ProductMapping_arc" owner to nvs_user_dw;

RAISE NOTICE 'ProductMapping Ready';


END;
$procedure$
;


-- DROP PROCEDURE public.proc_cleanse_territoryareamapping();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_territoryareamapping()
 LANGUAGE plpgsql
AS $procedure$
begin

--==========================================================================================================================
-- TerritoryAreaMapping cleansing
--==========================================================================================================================
RAISE NOTICE 'TerritoryAreaMapping started';

drop table if exists "TerritoryAreaMapping_arc";
create table "TerritoryAreaMapping_arc" as select * from "TerritoryAreaMapping"; --180
truncate "TerritoryAreaMapping";

-- 1. Standardize column names
insert into "TerritoryAreaMapping"
select distinct
 tamr."RepTerritoryID（RM）" as "SLMTerritoryID",
 oc."SLMTerritoryName",
 oc."SLMName",
 tamr."RepTerritoryID（AD）" as "TLMTerritoryID",
 oc."TLMTerritoryName",
 oc."TLMName",
 oc."FHTerritoryID",
 oc."FHTerritoryName",
 oc."FHName",
 oc."BUHTerritoryID",
 oc."BUHTerritoryName",
 oc."BUHName",
 tamr."ExternalAreaID" as "ExternalAreaID",
 mamr."IMS_ExternalAreaName" as "ExternalAreaName",
 tamr."MarketName" as "MarketName"
from "TerritoryAreaMapping_raw" tamr
join (select distinct "IMS_ExternalAreaID", "IMS_ExternalAreaName", "IMS_ExternalAreaName_EN" from "MarketAreaMapping_raw")mamr on tamr."ExternalAreaID" = mamr."IMS_ExternalAreaID"
join (select distinct "SLMTerritoryID", "SLMTerritoryName", "SLMName", "TLMTerritoryID", "TLMTerritoryName", "TLMName", "FHTerritoryID", "FHTerritoryName", "FHName", "BUHTerritoryID", "BUHTerritoryName", "BUHName" from "OrgCycle" where "Cycle" = (select max("Cycle") from "OrgCycle")) oc on tamr."RepTerritoryID（RM）" = oc."SLMTerritoryID"
join (select distinct "MarketName" from "AreaMarketCycleData_raw") amcd on tamr."MarketName" = amcd."MarketName"
where tamr."YM" = (select max("cycle") from "InsTrtyProductCycleData_raw" itpcd where "salesvalue" > '0'); --342

-- 1.1 Update AreaName to align with AMCD
update "TerritoryAreaMapping" tam set "ExternalAreaName" = amcd."ExternalAreaName"
from (select distinct "ExternalAreaID", "ExternalAreaName"  from "AreaMarketCycleData_raw") amcd
where tam."ExternalAreaID" = amcd."ExternalAreaID" and tam."ExternalAreaName" <> amcd."ExternalAreaName";

RAISE NOTICE 'TerritoryAreaMapping Step1 - Standardize columns done';

-- 2. add BUH, FH affiliated with ROC records
insert into "TerritoryAreaMapping"
select
 '' as "SLMTerritoryID",
 '' as "SLMTerritoryName",
 '' as "SLMName",
 '' as "TLMTerritoryID",
 '' as "TLMTerritoryName",
 '' as "TLMName",
 "FHTerritoryID",
 max("FHTerritoryName") as "FHTerritoryName",
 max("FHName") as "FHName",
 max("BUHTerritoryID") as "BUHTerritoryID",
 max("BUHTerritoryName") as "BUHTerritoryName",
 max("BUHName"),
 'ROC' as "ExternalAreaID",
 '中国其它地区' as "ExternalAreaName",
 "MarketName"
from "TerritoryAreaMapping" tam
group by "FHTerritoryID", "MarketName";--11

RAISE NOTICE 'TerritoryAreaMapping Step2 - Add ROC records done';

-- 3. Remove duplicate records
create temp table "TerritoryAreaMapping_dup" as
select "SLMTerritoryID", "SLMTerritoryName", "SLMName", "TLMTerritoryID", "TLMTerritoryName", "TLMName", "FHTerritoryID", "FHTerritoryName", "FHName", "BUHTerritoryID", "BUHTerritoryName", "BUHName", "ExternalAreaID", "ExternalAreaName", "MarketName" from "TerritoryAreaMapping"
group by "SLMTerritoryID", "SLMTerritoryName", "SLMName", "TLMTerritoryID", "TLMTerritoryName", "TLMName", "FHTerritoryID", "FHTerritoryName", "FHName", "BUHTerritoryID", "BUHTerritoryName", "BUHName", "ExternalAreaID", "ExternalAreaName", "MarketName" having count(*)>1;

delete from "TerritoryAreaMapping" tam
where exists (select 1 from "TerritoryAreaMapping_dup" tamd where tamd."SLMTerritoryID"=tam."SLMTerritoryID" and tamd."MarketName"=tam."MarketName" and tamd."ExternalAreaID"=tam."ExternalAreaID");
insert into "TerritoryAreaMapping" select * from "TerritoryAreaMapping_dup";

RAISE NOTICE 'TerritoryAreaMapping Step3 - Remove duplicate records done';

-- 4. Drop internal tables
alter table "TerritoryAreaMapping" owner to nvs_user_dw;

RAISE NOTICE 'TerritoryAreaMapping Done';


end;
$procedure$
;

