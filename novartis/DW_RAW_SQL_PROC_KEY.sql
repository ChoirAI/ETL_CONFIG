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
DROP TABLE "Product";

CREATE TABLE "Product" (
        "ProductID" varchar(20) NOT NULL,
        "ProductName" varchar(100) NULL,
        "ProductName_EN" varchar(100) NULL,
        "BrandID" varchar(20) NOT NULL,
        "BrandName" varchar(100) NULL,
        "BrandName_EN" varchar(100) NULL,
        "ProductLevel1" varchar(100) NULL,
        "ProductLevel1_EN" varchar(100) NULL,
        "ProductLevel2" varchar(100) NULL,
        "ProductLevel2_EN" varchar(100) NULL,
        "ProductLevel3" varchar(100) NULL,
        "ProductLevel3_EN" varchar(100) NULL,
        "ProductLevel4" varchar(100) NULL,
        "ProductLevel4_EN" varchar(100) NULL,
        "ProductLevel5" varchar(100) NULL,
        "ProductLevel5_EN" varchar(100) NULL,
        "ProductLevel6" varchar(100) NULL,
        "ProductLevel6_EN" varchar(100) NULL,
        "ProductLevel7" varchar(100) NULL,
        "ProductLevel7_EN" varchar(100) NULL,
        "ProductLevel8" varchar(100) NULL,
        "ProductLevel8_EN" varchar(100) NULL,
        "IsStandardSKU" bool DEFAULT false NULL,
        "ProductFeature" varchar(100) NULL,
        "PrimaryMarket" varchar(100) NULL,
        "PriProductInMarket" bool DEFAULT false NULL,
        CONSTRAINT product_pk PRIMARY KEY ("ProductID")
);

insert into "Product"
select
        sku_id as "ProductID",
        coalesce(sku_name_cn,sku_name) as "ProductName",
        sku_name as "ProductName_EN",
        brand_id as "BrandID",
        coalesce(brand_name_cn,brand_name) as "BrandName",
        brand_name as "BrandName_EN",
        ta_name as "ProductLevel1",
        ta_name as "ProductLevel1_EN",
        family_name as "ProductLevel2",
        family_name as "ProductLevel2_EN",
        brand_group as "ProductLevel3",
        brand_group as "ProductLevel3_EN",
        brand_name_cn as "ProductLevel4",
        brand_name as "ProductLevel4_EN",
        coalesce(sku_name_cn,sku_name) as "ProductLevel5",
        sku_name as "ProductLevel5_EN",
        null as "ProductLevel6",
        null as "ProductLevel6_EN",
        null as "ProductLevel7",
        null as "ProductLevel7_EN",
        null as "ProductLevel8",
        null as "ProductLevel8_EN",
        is_standard_sku::bool as "IsStandardSKU",
        brand_category as "ProductFeature",
        pmr.market as "PrimaryMarket",
        null as "PriProductInMarket"
from product_raw pr
left join productmapping_raw pmr on pr.brand_id::text = pmr.productid and pmr.iskeymarket = 'Y'
where pr.is_active=1;

update "Product" p set "BrandName" = pmr.productname
from productmapping_raw pmr where p."BrandID" = pmr.productid and p."BrandName" <> pmr.productname; --4

alter table "Product" owner to nvs_user_dw;
alter table "Product_arc" owner to nvs_user_dw;

RAISE NOTICE 'Product Ready';


END;
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
DROP TABLE "Geography";

CREATE TABLE "Geography" (
        "CountyID" varchar(20) NOT NULL,
        "CountyName" varchar(100) NULL,
        "CountyName_EN" varchar(100) NULL,
        "CityID" varchar(20) NULL,
        "CityName" varchar(100) NULL,
        "CityName_EN" varchar(100) NULL,
        "ProvinceID" varchar(20) NULL,
        "ProvinceName" varchar(100) NULL,
        "ProvinceName_EN" varchar(100) NULL,
        "CountyTier" varchar(20) NULL,
        "CityTier" varchar(20) NULL,
        "CountryID" varchar NULL,
        "CountryName" varchar NULL,
        "CountryName_EN" varchar NULL,
        CONSTRAINT geography_pk PRIMARY KEY ("CountyID")
);

insert into "Geography"
select
    countyid as "CountyID",
    countyname  as "CountyName",
    countyname_en as "CountyName_EN",
    cityid as "CityID",
    cityname as "CityName",
    cityname_en as "CityName_EN",
    provinceid as "ProvinceID",
    provincename as "ProvinceName",
    provincename_en as "ProvinceName_EN",
    countytier as "CountyTier",
    citytier as "CityTier",
    'CN' as "CountryID",
    '中国' as "CountryName",
    'China' as "CountryName_EN"
from "geography_raw";

alter table "Geography" owner to nvs_user_dw;
alter table "Geography_arc" owner to nvs_user_dw;

RAISE NOTICE 'Geography Ready';


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
DROP TABLE "Institution";

CREATE TABLE "Institution" (
        "InstitutionID" varchar(20) NOT NULL,
        "InstitutionName" varchar(100) NOT NULL,
        "InstitutionName_EN" varchar(255) NULL,
        "InstitutionType1" varchar(100) NULL,
        "InstitutionType2" varchar(100) NULL,
        "InstitutionType3" varchar(100) NULL,
        "InstitutionType4" varchar(100) NULL,
        "InstitutionTier" varchar(20) NULL,
        "CountyID" varchar(20) NULL,
        "CountyName" varchar(100) NULL,
        "CityID" varchar(20) NULL,
        "CityName" varchar(100) NULL,
        "ProvinceID" varchar(20) NULL,
        "ProvinceName" varchar(100) NULL,
        "CountyTier" varchar(100) NULL,
        "CityTier" varchar(100) NULL,
        "CountryID" varchar NULL,
        "CountryName" varchar NULL,
        CONSTRAINT institution_pk PRIMARY KEY ("InstitutionID")
);

insert into "Institution"
select
    ir.institutionid as "InstitutionID",
    ir.institutionname as "InstitutionName",
    null as "InstitutionName_EN",
    null as "InstitutionType1",
    ir.institutiontype2 as "InstitutionType2",
    ir.institutiontype3 as "InstitutionType3",
    ir.institutiontype4 as "InstitutionType4",
    ir.institutiontier as "InstitutionTier",
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
from "institution_raw" ir
join "Geography" g on ir.countyid::text = g."CountyID"; --Updated Rows  14173

alter table "Institution" owner to nvs_user_dw;
alter table "Institution_arc" owner to nvs_user_dw;

RAISE NOTICE 'Institution Ready';


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
DROP TABLE "OrgCycle";

CREATE TABLE "OrgCycle" (
        "Cycle" varchar(20) NOT NULL,
        "RepTerritoryID" varchar(50) NOT NULL,
        "RepTerritoryName" varchar(100) NULL,
        "RepProductLine" varchar(100) NULL,
        "RepTerritoryType1" varchar(100) NULL,
        "RepTerritoryType2" varchar(100) NULL,
        "RepID" varchar(50) NULL,
        "RepName" varchar(100) NULL,
        "FLMTerritoryID" varchar(50) NULL,
        "FLMTerritoryName" varchar(100) NULL,
        "FLMTerritoryType" varchar(100) NULL,
        "FLMID" varchar(50) NULL,
        "FLMName" varchar(100) NULL,
        "SLMTerritoryID" varchar(50) NULL,
        "SLMTerritoryName" varchar(100) NULL,
        "SLMID" varchar(50) NULL,
        "SLMName" varchar(100) NULL,
        "TLMTerritoryID" varchar(50) NULL,
        "TLMTerritoryName" varchar(100) NULL,
        "TLMID" varchar(50) NULL,
        "TLMName" varchar(100) NULL,
        "FHTerritoryID" varchar(50) NULL,
        "FHTerritoryName" varchar(100) NULL,
        "FHID" varchar(50) NULL,
        "FHName" varchar(100) NULL,
        "BUHTerritoryID" varchar(50) NULL,
        "BUHTerritoryName" varchar(100) NULL,
        "BUHID" varchar(50) NULL,
        "BUHName" varchar(100) NULL,
        CONSTRAINT orgcycle_pk PRIMARY KEY ("Cycle", "RepTerritoryID")
);

insert into "OrgCycle"
select
 "cycle" as "Cycle",
 "repterritoryid" as "RepTerritoryID",
 "repterritoryname" as "RepTerritoryName",
 "repproductline" as "RepProductLine",
 null as "RepTerritoryType1",
 null as "RepTerritoryType2",
 "repid" as "RepID",
 "repname" as "RepName",
 "flmterritoryid" as "FLMTerritoryID",
 "flmterritoryname" as "FLMTerritoryName",
 null as "FLMTerritoryType",
 "flmid" as "FLMID",
 "flmname" as "FLMName",
 "slmterritoryid" as "SLMTerritoryID",
 "slmterritoryname" as "SLMTerritoryName",
 "slmid" as "SLMID",
 "slmname" as "SLMName",
 "tlmterritoryid" as "TLMTerritoryID",
 "tlmterritoryname" as "TLMTerritoryName",
 "tlmid" as "TLMID",
 "tlmname" as "TLMName",
 "fhterritoryid" as "FHTerritoryID",
 "fhterritoryname" as "FHTerritoryName",
 "fhid" as "FHID",
 "fhname" as "FHName",
 "buhterritoryid" as "BUHTerritoryID",
 "buhterritoryname" as "BUHTerritoryName",
 "buhid" as "BUHID",
 "buhname" as "BUHName"
from "orgcycle_raw"
where "cycle" <= (select max("cycle") from "instrtyproductcycledata_raw" where salesvalue>0);


alter table "OrgCycle" owner to nvs_user_dw;
alter table "OrgCycle_arc" owner to nvs_user_dw;

RAISE NOTICE 'OrgCycle Ready';


END;
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
DROP TABLE "InsProdProperty";

CREATE TABLE "InsProdProperty" (
        "InstitutionID" varchar(20) NULL,
        "InstitutionName" varchar(255) NULL,
        "InstitutionName_EN" varchar(255) NULL,
        "ProductID" varchar(20) NULL,
        "ProductName" varchar(100) NULL,
        "ProductName_EN" varchar(100) NULL,
        "InsProdProperty1" varchar(100) NULL,
        "InsProdProperty2" varchar(100) NULL,
        "InsProdProperty3" varchar(100) NULL
);

insert into "InsProdProperty"
select
    ipp.institutionid as "InstitutionID",
    max(ipp.institutionname) as "InstitutionName",
    null as "InstitutionName_EN",
    p."BrandID" as "ProductID",
    max(p."BrandName") as "ProductName",
    max(p."BrandName_EN") as "ProductName_EN",
    max(ipp.insprodproperty1) as "InsProdProperty1",
    null as "InsProdProperty2",
    null as "InsProdProperty3"
from insprodproperty_raw ipp
join "Product" p on ipp.brand = p."ProductLevel4_EN"
where ipp.ym = (select max("cycle") from "instrtyproductcycledata_raw" where salesvalue>0)
group by p."BrandID", ipp.institutionid
;

delete from "InsProdProperty" where "ProductID"=''and "ProductName" =''and "ProductName_EN"='';

alter table "InsProdProperty" owner to nvs_user_dw;
alter table "InsProdProperty_arc" owner to nvs_user_dw;

RAISE NOTICE 'InsProdProperty Ready';


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
DROP TABLE "TerritoryAreaMapping";

CREATE TABLE "TerritoryAreaMapping" (
        "SLMTerritoryID" varchar(100) NOT NULL,
        "SLMTerritoryName" varchar(100) NULL,
        "SLMName" varchar(100) NULL,
        "TLMTerritoryID" varchar(100) NULL,
        "TLMTerritoryName" varchar(100) NULL,
        "TLMName" varchar(100) NULL,
        "FHTerritoryID" varchar(100) NULL,
        "FHTerritoryName" varchar(100) NULL,
        "FHName" varchar(100) NULL,
        "BUHTerritoryID" varchar(100) NULL,
        "BUHTerritoryName" varchar(100) NULL,
        "BUHName" varchar(100) NULL,
        "ExternalAreaID" varchar(20) NOT NULL,
        "ExternalAreaName" varchar(100) NOT NULL,
        "MarketName" varchar(100) NOT NULL,
        CONSTRAINT territoryareamapping_pk PRIMARY KEY ("SLMTerritoryID", "ExternalAreaID", "MarketName")
);

-- 1. Standardize column names
insert into "TerritoryAreaMapping"
select distinct
 oc."SLMTerritoryID",
 oc."SLMTerritoryName",
 oc."SLMName",
 oc."TLMTerritoryID",
 oc."TLMTerritoryName",
 oc."TLMName",
 oc."FHTerritoryID",
 oc."FHTerritoryName",
 oc."FHName",
 oc."BUHTerritoryID",
 oc."BUHTerritoryName",
 oc."BUHName",
 tamr.externalareaid as "ExternalAreaID",
 tamr.externalareaname as "ExternalAreaName",
 tamr.marketname as "MarketName"
from "territoryareamapping_raw" tamr
join (select distinct "SLMTerritoryID", "SLMTerritoryName", "SLMName", "TLMTerritoryID", "TLMTerritoryName", "TLMName", "FHTerritoryID", "FHTerritoryName", "FHName", "BUHTerritoryID", "BUHTerritoryName", "BUHName" from "OrgCycle" where "Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" itpcd where "SalesValue" > 0)) oc on tamr."slmterritoryid" = oc."SLMTerritoryName"
join (select distinct "marketname" from "areamarketcycledata_raw") amcd on tamr."marketname" = amcd."marketname"
where tamr.ym = (select max("Cycle") from "InsTrtyProductCycleData" itpcd where "SalesValue" > 0);


-- 1.1 Update AreaName to align with AMCD
update "TerritoryAreaMapping" tam set "ExternalAreaName" = amcd.externalareaname
from (select distinct externalareaid, externalareaname  from areamarketcycledata_raw) amcd
where tam."ExternalAreaID" = amcd.externalareaid and tam."ExternalAreaName" <> amcd.externalareaname;

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
drop table if exists "TerritoryAreaMapping_dup";
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
create table "AreaMarketCycleData_arc" as select * from "AreaMarketCycleData";
DROP TABLE "AreaMarketCycleData";

CREATE TABLE "AreaMarketCycleData" (
        "Cycle" varchar(20) NULL,
        "ExternalAreaID" varchar(20) NULL,
        "ExternalAreaName" varchar(100) NULL,
        "ExternalAreaName_EN" varchar(100) NULL,
        "MarketName" varchar(100) NULL,
        "ExternalProductID" varchar(100) NULL,
        "ExternalProductName" varchar(100) NULL,
        "ExternalProductName_EN" varchar(100) NULL,
        "IsInternalProduct" bool NULL,
        "ProductID" varchar(20) NULL,
        "ProductName" varchar(100) NULL,
        "ProductName_EN" varchar(100) NULL,
        "SalesValue" numeric(28, 8) NULL,
        "LYSalesValue" numeric(28, 8) NULL,
        "SalesUnit" numeric(28, 8) NULL,
        "LYSalesUnit" numeric(28, 8) NULL,
        "MarketValueSize" numeric(28, 8) NULL,
        "LYMarketValueSize" numeric(28, 8) NULL,
        "MarketUnitSize" numeric(28, 8) NULL,
        "LYMarketUnitSize" numeric(28, 8) NULL
);

-- 1. Standardize column names and calculate MarketSize
drop table if exists "AreaMarketCycleData_1";
create table "AreaMarketCycleData_1" as
select
    "cycle"::varchar(20) as "Cycle",
    "externalareaid"::varchar(20) as "ExternalAreaID",
    max("externalareaname")::varchar(100) as "ExternalAreaName",
    max("externalareaname_en")::varchar(100) as "ExternalAreaName_EN",
    "marketname"::varchar(100) as "MarketName",
    min("externalproductid")::varchar(100) as "ExternalProductID",
    coalesce(externalproductgroup, externalproductgroup_en)::varchar(100) as "ExternalProductName",
    max(split_part("externalproductname_en", '  ',1))::varchar(100) as "ExternalProductName_EN",
    case when max(pm."ProductID") is not null then true else false end as "IsInternalProduct",
    max(pm."ProductID") as "ProductID",
    max(pm."ProductName") as "ProductName",
    max(pm."ProductName_EN") as "ProductName_EN",
    sum("salesvalue"::numeric(28,8)) as "SalesValue",
    sum("lysalesvalue"::numeric(28,8)) as "LYSalesValue",
    sum("salesunit"::numeric(28,8)) as "SalesUnit",
    sum("lysalesunit"::numeric(28,8)) as "LYSalesUnit",
    sum(sum("salesvalue"::numeric(28,8)))over(partition by "externalareaid", "marketname", "cycle") as "MarketValueSize",
    sum(sum("lysalesvalue"::numeric(28,8)))over(partition by "externalareaid", "marketname", "cycle") as "LYMarketValueSize",
    sum(sum("salesunit"::numeric(28,8)))over(partition by "externalareaid", "marketname", "cycle") as "MarketUnitSize",
    sum(sum("lysalesunit"::numeric(28,8)))over(partition by "externalareaid", "marketname", "cycle") as "LYMarketUnitSize"
from "areamarketcycledata_raw" amcdr
left join "ProductMapping" pm on amcdr.externalproductid = pm."IMS_ProductID" and upper(amcdr.marketname) = pm."Market"
where upper(amcdr.marketname) in (select distinct p."PrimaryMarket" from "OrgCycle" oc
        join "InsTrtyProductCycleData" itpcd on oc."RepTerritoryID" = itpcd."RepTerritoryCode" and oc."Cycle" = (select max("Cycle") from "OrgCycle" oc2)
        join "Product" p on itpcd."ProductID" = p."ProductID"
        where p."PrimaryMarket" is not null)
group by
    "externalareaid",
    "marketname",
    "cycle",
    coalesce(externalproductgroup, externalproductgroup_en); -- 34680

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
from (select distinct "MarketName", "ExternalProductID", max("ExternalProductName") as "ExternalProductName", max("ExternalProductName_EN") as "ExternalProductName_EN", max("IsInternalProduct"::text)::bool as "IsInternalProduct", max("ProductID") as "ProductID", max("ProductName") as "ProductName", max("ProductName_EN") as "ProductName_EN" from "AreaMarketCycleData_1" group by "MarketName", "ExternalProductID") prod
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
where f."Cycle" = f1."Cycle" and f."ExternalAreaID" = f1."ExternalAreaID" and f."MarketName" = f1."MarketName" and f."ExternalProductID" = f1."ExternalProductID";  --Updated Rows        34680

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

insert into "AreaMarketCycleData"
select
        "Cycle",
        "ExternalAreaID",
        "ExternalAreaName",
        "ExternalAreaName_EN",
        "MarketName",
        "ExternalProductID",
        "ExternalProductName",
        "ExternalProductName_EN",
        "IsInternalProduct",
        "ProductID",
        "ProductName",
        "ProductName_EN",
        "SalesValue",
        "LYSalesValue",
        "SalesUnit",
        "LYSalesUnit",
        "MarketValueSize",
        "LYMarketValueSize",
        "MarketUnitSize",
        "LYMarketUnitSize"
from "AreaMarketCycleData_2";

RAISE NOTICE 'AMCD Step2.3 - Update Size for AMCD done';

--Step3. Update AreaMarketMonthData
drop table if exists AreaMarketR3MData;
CREATE TEMP Table AreaMarketR3MData AS
SELECT c.month_text,
 max(c.rolling_3m_start_date) as rolling_3m_start_date,
 max(c.rolling_3m_end_date) as rolling_3m_end_date,
 amcd."ExternalAreaID" as ExternalAreaID,
 MAX(amcd."ExternalAreaName") as ExternalAreaName,
 MAX(amcd."ExternalAreaName_EN") as ExternalAreaName_EN,
 amcd."MarketName" as MarketName,
 amcd."ExternalProductID" as ExternalProductID,
 MAX(amcd."ExternalProductName") as ExternalProductName,
 MAX(amcd."ExternalProductName_EN") as ExternalProductName_EN,
 bool_or("IsInternalProduct") as IsInternalProduct,
 MAX(amcd."ProductID") as ProductID,
 MAX(amcd."ProductName") as ProductName,
 MAX(amcd."ProductName_EN") as ProductName_EN,
 sum(amcd."SalesValue") AS rolling_3m_sales,
 sum(amcd."SalesUnit") AS rolling_3m_sales_unit
FROM "AreaMarketCycleData" amcd
JOIN dim_calendar c ON amcd."Cycle" between to_char(c.rolling_3m_start_date,'yyyymm') and to_char(c.rolling_3m_end_date,'yyyymm') and c.day_of_month_num = 1
GROUP BY c.month_text,
 amcd."MarketName",
 amcd."ExternalAreaID",
 amcd."ExternalProductID"
order by amcd."MarketName",
 amcd."ExternalAreaID",
 amcd."ExternalProductID",
 C.month_text; --Updated Rows        43648
 --计算每个月的rolling3month的钱与量的和

drop table if exists AreaMarketP3MData;
CREATE TEMP Table AreaMarketP3MData AS
SELECT to_char(to_date(c.month_text,'yyyymm') + interval '3 month', 'yyyymm') as month_text,
 max(c.rolling_3m_start_date) as rolling_3m_start_date,
 max(c.rolling_3m_end_date) as rolling_3m_end_date,
 amcd."ExternalAreaID" as ExternalAreaID,
 MAX(amcd."ExternalAreaName") as ExternalAreaName,
 MAX(amcd."ExternalAreaName_EN") as ExternalAreaName_EN,
 amcd."MarketName" as MarketName,
 amcd."ExternalProductID" as ExternalProductID,
 MAX(amcd."ExternalProductName") as ExternalProductName,
 MAX(amcd."ExternalProductName_EN") as ExternalProductName_EN,
 bool_or("IsInternalProduct") as IsInternalProduct,
 MAX(amcd."ProductID") as ProductID,
 MAX(amcd."ProductName") as ProductName,
 MAX(amcd."ProductName_EN") as ProductName_EN,
 sum(amcd."SalesValue") AS rolling_3m_sales,
 sum(amcd."SalesUnit") AS rolling_3m_sales_unit
FROM "AreaMarketCycleData" amcd
JOIN dim_calendar c ON amcd."Cycle" between to_char(c.rolling_3m_start_date,'yyyymm') and to_char(c.rolling_3m_end_date,'yyyymm') and c.day_of_month_num = 1
GROUP BY c.month_text,
 amcd."MarketName",
 amcd."ExternalAreaID",
 amcd."ExternalProductID"
order by amcd."MarketName",
 amcd."ExternalAreaID",
 amcd."ExternalProductID",
 C.month_text; --Updated Rows        43648

CREATE INDEX InsTrtyProductR3MSales_idx ON AreaMarketR3MData (month_text,MarketName,ExternalAreaID,ExternalProductID);
CREATE INDEX InsTrtyProductP3MSales_idx ON AreaMarketP3MData (month_text,MarketName,ExternalAreaID,ExternalProductID);

drop table if exists  "AreaMarketMonthData";
CREATE Table "AreaMarketMonthData" AS
select r3m.*, p3m.rolling_3m_sales as pass_3m_sales, p3m.rolling_3m_sales_unit as pass_3m_sales_unit, lm."SalesValue" as lm_sales, lm."SalesUnit" as lm_sales_unit
from AreaMarketR3MData r3m
left join "AreaMarketCycleData" lm on to_date(r3m.month_text, 'yyyymm') - interval '1 month' = to_date(lm."Cycle",'yyyymm') and r3m.MarketName=lm."MarketName" and r3m.ExternalAreaID=lm."ExternalAreaID" and r3m.ExternalProductID=lm."ExternalProductID"
left join AreaMarketP3MData p3m on r3m.month_text=p3m.month_text and r3m.MarketName=p3m.MarketName and r3m.ExternalAreaID=p3m.ExternalAreaID and r3m.ExternalProductID=p3m.ExternalProductID; -- Updated Rows        43648

--Step4. Update AreaMarketQuarterData
drop table if exists AreaMarketQuarterSales;
CREATE TEMP Table AreaMarketQuarterSales AS
SELECT C.QUARTER_TEXT,
 max(C.quarter_start_date) as quarter_start_date,
 max(C.quarter_end_date) as quarter_end_date,
 amcd."ExternalAreaID" as ExternalAreaID,
 MAX(amcd."ExternalAreaName") as ExternalAreaName,
 MAX(amcd."ExternalAreaName_EN") as ExternalAreaName_EN,
 amcd."MarketName" as MarketName,
 amcd."ExternalProductID" as ExternalProductID,
 MAX(amcd."ExternalProductName") as ExternalProductName,
 MAX(amcd."ExternalProductName_EN") as ExternalProductName_EN,
 bool_or("IsInternalProduct") as IsInternalProduct,
 MAX(amcd."ProductID") as ProductID,
 MAX(amcd."ProductName") as ProductName,
 MAX(amcd."ProductName_EN") as ProductName_EN,
 SUM(amcd."SalesValue") AS sales_cq,
 SUM(amcd."SalesValue") / NULLIF(COUNT(DISTINCT amcd."Cycle"),0) AS avg_sales_cq,
 SUM(amcd."SalesUnit") AS sales_unit_cq,
 SUM(amcd."SalesUnit") / NULLIF(COUNT(DISTINCT amcd."Cycle"),0) AS avg_sales_unit_cq
FROM "AreaMarketCycleData" amcd
JOIN DIM_CALENDAR C ON amcd."Cycle" = C.MONTH_TEXT and C.DAY_OF_MONTH_NUM = 1
GROUP BY C.QUARTER_TEXT,
 amcd."MarketName",
 amcd."ExternalAreaID",
 amcd."ExternalProductID"
order by amcd."MarketName",
 amcd."ExternalAreaID",
 amcd."ExternalProductID",
 C.QUARTER_TEXT; -- Updated Rows        13888

 drop table if exists AreaMarketLastQuarterSales;
CREATE TEMP Table AreaMarketLastQuarterSales AS
SELECT C.QUARTER_TEXT,
 max(C.quarter_start_date) as quarter_start_date,
 max(C.quarter_end_date) as quarter_end_date,
 amcd."ExternalAreaID" as ExternalAreaID,
 MAX(amcd."ExternalAreaName") as ExternalAreaName,
 MAX(amcd."ExternalAreaName_EN") as ExternalAreaName_EN,
 amcd."MarketName" as MarketName,
 amcd."ExternalProductID" as ExternalProductID,
 MAX(amcd."ExternalProductName") as ExternalProductName,
 MAX(amcd."ExternalProductName_EN") as ExternalProductName_EN,
 bool_or("IsInternalProduct") as IsInternalProduct,
 MAX(amcd."ProductID") as ProductID,
 MAX(amcd."ProductName") as ProductName,
 MAX(amcd."ProductName_EN") as ProductName_EN,
 SUM(amcd."SalesValue") AS sales_lq,
 SUM(amcd."SalesValue") / NULLIF(COUNT(DISTINCT amcd."Cycle"),0) AS avg_sales_lq,
 SUM(amcd."SalesUnit") AS sales_unit_lq,
 SUM(amcd."SalesUnit") / NULLIF(COUNT(DISTINCT amcd."Cycle"),0) AS avg_sales_unit_lq
FROM "AreaMarketCycleData" amcd
JOIN DIM_CALENDAR C ON to_date(amcd."Cycle",'yyyymm') = to_date(C.MONTH_TEXT,'yyyymm')-interval '3 month' and C.DAY_OF_MONTH_NUM = 1
GROUP BY C.QUARTER_TEXT,
 amcd."MarketName",
 amcd."ExternalAreaID",
 amcd."ExternalProductID"
order by amcd."MarketName",
 amcd."ExternalAreaID",
 amcd."ExternalProductID",
 C.QUARTER_TEXT;--Updated Rows        13888

drop table if exists "AreaMarketQuarterData";
CREATE Table "AreaMarketQuarterData" AS
select cq.*, lq.sales_lq, lq.avg_sales_lq, lq.sales_unit_lq, lq.avg_sales_unit_lq
from AreaMarketQuarterSales cq
left join AreaMarketLastQuarterSales lq
on cq.QUARTER_TEXT=lq.QUARTER_TEXT
and cq.MarketName=lq.MarketName
and cq.ExternalAreaID=lq.ExternalAreaID
and cq.ExternalProductID=lq.ExternalProductID;
-- Updated Rows 13888


-- 4. Drop internal tables
drop table "AreaMarketCycleData_1";
drop table "AreaMarketCycleData_size";

alter table "AreaMarketCycleData" owner to nvs_user_dw;
alter table "AreaMarketQuarterData" owner to nvs_user_dw;
alter table "AreaMarketMonthData" owner to nvs_user_dw;
RAISE NOTICE 'AMCD Done, remember to VACUUM the table';


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
DROP TABLE "MarketAreaMapping";

CREATE TABLE "MarketAreaMapping" (
        "GeographyID" varchar(20) NULL,
        "GeographyName" varchar(100) NULL,
        "GeographyName_EN" varchar(100) NULL,
        "IMS_ExternalAreaID" varchar(20) NULL,
        "IMS_ExternalAreaName" varchar(100) NULL,
        "IMS_ExternalAreaName_EN" varchar(100) NULL,
        CONSTRAINT marketareamapping_unique UNIQUE ("IMS_ExternalAreaID")
);

insert into "MarketAreaMapping"
select g."geographyid", g."geographyname", g."geographyname_en", ims."IMS_ExternalAreaID", ims."IMS_ExternalAreaName", ims."IMS_ExternalAreaName_EN"
from (select
 "ims_externalareaid" as "IMS_ExternalAreaID",
 max(coalesce(amcd."externalareaname","geographyname")) as "IMS_ExternalAreaName",
 max(coalesce(amcd."externalareaname_en","geographyname_en")) as "IMS_ExternalAreaName_EN",
 max("geographyid") as "GeographyID"
from "marketareamapping_raw" mamr
left join (select distinct "externalareaid", "externalareaname", "externalareaname_en" from "areamarketcycledata_raw") amcd on mamr."ims_externalareaid" = amcd."externalareaid"
group by "IMS_ExternalAreaID") ims
join (select distinct "geographyid", "geographyname", "geographyname_en" from "marketareamapping_raw") g on ims."GeographyID" = g."geographyid"
;

alter table "MarketAreaMapping" owner to nvs_user_dw;
alter table "MarketAreaMapping_arc" owner to nvs_user_dw;

RAISE NOTICE 'MarketAreaMapping Ready';


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
DROP TABLE "ProductMapping";

CREATE TABLE "ProductMapping" (
        "ProductID" varchar(20) NULL,
        "ProductName" varchar(100) NULL,
        "ProductName_EN" varchar(100) NULL,
        "IMS_ProductID" varchar(100) NULL,
        "IMS_ProductName" varchar(100) NULL,
        "IMS_ProductName_EN" varchar(100) NULL,
        "CPA_ProductID" varchar(100) NULL,
        "CPA_ProductName" varchar(100) NULL,
        "Market" varchar(100) NULL,
        "IsKeyMarket" bool null,
        "PriProductInMarket" bool null
);

INSERT INTO "ProductMapping" ("ProductID", "ProductName", "ProductName_EN", "IMS_ProductID", "IMS_ProductName", "IMS_ProductName_EN", "CPA_ProductID", "CPA_ProductName", "Market", "IsKeyMarket", "PriProductInMarket")
select
        pmr.productid,
        pmr.productname,
        pmr.productname_en,
        pmr.ims_productid,
        pmr.ims_productname,
        pmr.ims_productname_en,
        pmr.cpa_productid,
        pmr.cpa_productname,
        pmr.market,
        pmr.iskeymarket::bool,
        false as "PriProductInMarket"
from productmapping_raw pmr
where pmr.productid in (select distinct "BrandID" from "Product");

update "ProductMapping" pm set "PriProductInMarket" = true
from
(select "Market", min("ProductID") as "ProductID" from "ProductMapping"
group by "Market") a
where pm."Market" = a."Market" and pm."ProductID" = a."ProductID";

alter table "ProductMapping" owner to nvs_user_dw;
alter table "ProductMapping_arc" owner to nvs_user_dw;

RAISE NOTICE 'ProductMapping Ready';


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
create table "InsMarketCycleData_arc" as select * from "InsMarketCycleData";
DROP TABLE "InsMarketCycleData";

CREATE TABLE "InsMarketCycleData" (
        "Cycle" varchar(20) NOT NULL,
        "InstitutionID" varchar(20) NOT NULL,
        "InstitutionName" varchar(100) NULL,
        "MarketName" varchar(100) NOT NULL,
        "ExternalProductID" varchar(20) NOT NULL,
        "ExternalProductName" varchar(100) NULL,
        "ExternalProductName_EN" varchar(100) NULL,
        "IsInternalProduct" bool NULL,
        "ProductID" varchar(20) NULL,
        "ProductName" varchar(100) NULL,
        "ProductName_EN" varchar(100) NULL,
        "SalesValue" numeric(28, 8) NULL,
        "LYSalesValue" numeric(28, 8) NULL,
        "SalesUnit" numeric(28, 8) NULL,
        "LYSalesUnit" numeric(28, 8) NULL,
        "MarketValueSize" numeric(28, 8) NULL,
        "LYMarketValueSize" numeric(28, 8) NULL,
        "MarketUnitSize" numeric(28, 8) NULL,
        "LYMarketUnitSize" numeric(28, 8) NULL,
        CONSTRAINT insmarketcycledata_pk PRIMARY KEY ("InstitutionID", "ExternalProductID", "MarketName", "Cycle")
);

-- 1. Standardize column names and column type, and map product columns
drop table if exists "InsMarketCycleData_1";
create table "InsMarketCycleData_1" as
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
    salesvalue::numeric(28,8) as "SalesValue",
    lysalesvalue::numeric(28,8) as "LYSalesValue",
    salesunit::numeric(28,8) as "SalesUnit",
    lysalesunit::numeric(28,8) as "LYSalesUnit",
    marketvaluesize::numeric(28,8) as "MarketValueSize",
    lymarketvaluesize::numeric(28,8) as "LYMarketValueSize",
    marketunitsize::numeric(28,8) as "MarketUnitSize",
    lymarketunitsize::numeric(28,8) as "LYMarketUnitSize"
from "insmarketcycledata_raw" imcdr
left join "ProductMapping" pm on imcdr.externalproductid = pm."CPA_ProductID" and upper(imcdr.marketname) = pm."Market"
where upper(imcdr.marketname) in (select distinct p."PrimaryMarket" from "OrgCycle" oc
                join "InsTrtyProductCycleData" itpcd on oc."RepTerritoryID" = itpcd."RepTerritoryCode" and oc."Cycle" = (select max("Cycle") from "OrgCycle" oc2)
                join "Product" p on itpcd."ProductID" = p."ProductID"
                where p."PrimaryMarket" is not null); --3,555,000

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
        sum("SalesValue")::numeric(28,8) as "SalesValue",
        sum("LYSalesValue")::numeric(28,8) as "LYSalesValue",
        sum("SalesUnit")::numeric(28,8) as "SalesUnit",
        sum("LYSalesUnit")::numeric(28,8) as "LYSalesUnit",
        sum(sum(coalesce("SalesValue",0)))over(partition by "InstitutionID", "MarketName", "Cycle")::numeric(28,8) as "MarketValueSize",
        sum(sum(coalesce("LYSalesValue",0)))over(partition by "InstitutionID", "MarketName", "Cycle")::numeric(28,8) as "LYMarketValueSize",
        sum(sum(coalesce("SalesUnit",0)))over(partition by "InstitutionID", "MarketName", "Cycle")::numeric(28,8) as "MarketUnitSize",
        sum(sum(coalesce("LYSalesUnit",0)))over(partition by "InstitutionID", "MarketName", "Cycle")::numeric(28,8) as "LYMarketUnitSize"
from "InsMarketCycleData_1"
group by "InstitutionID", "ExternalProductID", "MarketName", "Cycle"; --3,555,000

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
join (select distinct "Cycle" from "InsMarketCycleData_2") cycle on 1=1;--3,951,990

drop index if exists imcd3_pk_idx;
CREATE INDEX imcd3_pk_idx ON "InsMarketCycleData_3" USING btree ("InstitutionID", "ExternalProductID", "MarketName", "Cycle");
RAISE NOTICE 'IMCD Step3.1 - Create Cross Join table done';

-- 3.2 Attach values to the Cartesian table
update "InsMarketCycleData_3" f
set "SalesValue" = f2."SalesValue", "LYSalesValue" = f2."LYSalesValue", "SalesUnit" = f2."SalesUnit", "LYSalesUnit" = f2."LYSalesUnit"
from "InsMarketCycleData_2" f2
where f."InstitutionID" = f2."InstitutionID" and f."ExternalProductID" = f2."ExternalProductID" and f."MarketName" = f2."MarketName" and f."Cycle" = f2."Cycle";  --3,555,000
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
group by "InstitutionID", "MarketName", "Cycle"; --96462 -> 132282
drop index if exists imcds_pk_idx;
CREATE INDEX imcds_pk_idx ON "InsMarketCycleData_size" USING btree ("InstitutionID", "MarketName", "Cycle");

update "InsMarketCycleData_3" f
set
        "MarketValueSize" = imcds."MarketValueSize",
        "LYMarketValueSize" = imcds."LYMarketValueSize",
        "MarketUnitSize" = imcds."MarketUnitSize",
        "LYMarketUnitSize" = imcds."LYMarketUnitSize"
from "InsMarketCycleData_size" imcds
where f."InstitutionID" = imcds."InstitutionID" and f."MarketName" = imcds."MarketName" and f."Cycle" = imcds."Cycle";  --Updated Rows        3,555,000

insert into "InsMarketCycleData"
select
        "Cycle",
        "InstitutionID",
        "InstitutionName",
        "MarketName",
        "ExternalProductID",
        "ExternalProductName",
        "ExternalProductName_EN",
        "IsInternalProduct",
        "ProductID",
        "ProductName",
        "ProductName_EN",
        "SalesValue",
        "LYSalesValue",
        "SalesUnit",
        "LYSalesUnit",
        "MarketValueSize",
        "LYMarketValueSize",
        "MarketUnitSize",
        "LYMarketUnitSize"
from "InsMarketCycleData_3";--3,951,990

drop table "InsMarketCycleData_1";
drop table "InsMarketCycleData_2";
drop table "InsMarketCycleData_size";

RAISE NOTICE 'IMCD Step3.3 - Update Size for IMCD done';

-- 4. Create IMMD & IMQD
drop table if exists insmarketr3mdata;
CREATE Table insmarketr3mdata AS
SELECT c.month_text,
 max(c.rolling_3m_start_date) as rolling_3m_start_date,
 max(c.rolling_3m_end_date) as rolling_3m_end_date,
 imcd."InstitutionID" as InstitutionID,
 max(imcd."InstitutionName") as InstitutionName,
 imcd."MarketName" as MarketName,
 imcd."ExternalProductID" as ExternalProductID,
 max(imcd."ExternalProductName") as ExternalProductName,
 max(imcd."ExternalProductName_EN") as ExternalProductName_EN,
 bool_or("IsInternalProduct") as IsInternalProduct,
 max(imcd."ProductID") as ProductID,
 max(imcd."ProductName") as ProductName,
 max(imcd."ProductName_EN") as ProductName_EN,
 sum(imcd."SalesValue") AS rolling_3m_sales,
 sum(imcd."SalesUnit") AS rolling_3m_sales_unit
FROM "InsMarketCycleData" imcd
JOIN dim_calendar c ON imcd."Cycle" between to_char(c.rolling_3m_start_date,'yyyymm') and to_char(c.rolling_3m_end_date,'yyyymm') and c.day_of_month_num = 1
GROUP BY c.month_text,
 imcd."MarketName",
 imcd."InstitutionID",
 imcd."ExternalProductID"
order by imcd."MarketName",
 imcd."InstitutionID",
 imcd."ExternalProductID",
 c.month_text; --Updated Rows        4391100

drop table if exists insmarketp3mdata;
CREATE Table insmarketp3mdata AS
SELECT to_char(to_date(c.month_text,'yyyymm') + interval '3 month', 'yyyymm') as month_text,
 max(c.rolling_3m_start_date) as rolling_3m_start_date,
 max(c.rolling_3m_end_date) as rolling_3m_end_date,
 imcd."InstitutionID" as InstitutionID,
 max(imcd."InstitutionName") as InstitutionName,
 imcd."MarketName" as MarketName,
 imcd."ExternalProductID" as ExternalProductID,
 max(imcd."ExternalProductName") as ExternalProductName,
 max(imcd."ExternalProductName_EN") as ExternalProductName_EN,
 bool_or("IsInternalProduct") as IsInternalProduct,
 max(imcd."ProductID") as ProductID,
 max(imcd."ProductName") as ProductName,
 max(imcd."ProductName_EN") as ProductName_EN,
 sum(imcd."SalesValue") AS rolling_3m_sales,
 sum(imcd."SalesUnit") AS rolling_3m_sales_unit
FROM "InsMarketCycleData" imcd
JOIN dim_calendar c ON imcd."Cycle" between to_char(c.rolling_3m_start_date,'yyyymm') and to_char(c.rolling_3m_end_date,'yyyymm') and c.day_of_month_num = 1
GROUP BY c.month_text,
 imcd."MarketName",
 imcd."InstitutionID",
 imcd."ExternalProductID"
order by imcd."MarketName",
 imcd."InstitutionID",
 imcd."ExternalProductID",
 c.month_text; --Updated Rows        4391100

CREATE INDEX insmarketr3mdata_idx ON insmarketr3mdata (month_text,MarketName,InstitutionID,ExternalProductID);
CREATE INDEX insmarketp3mdata_idx ON insmarketp3mdata (month_text,MarketName,InstitutionID,ExternalProductID);

drop table if exists  "InsMarketMonthData";
CREATE Table "InsMarketMonthData" AS
select r3m.*, p3m.rolling_3m_sales as pass_3m_sales, p3m.rolling_3m_sales_unit as pass_3m_sales_unit, lm."SalesValue" as lm_sales, lm."SalesUnit" as lm_sales_unit
from insmarketr3mdata r3m
left join "InsMarketCycleData" lm on to_date(r3m.month_text, 'yyyymm') - interval '1 month' = to_date(lm."Cycle",'yyyymm') and r3m.MarketName=lm."MarketName" and r3m.InstitutionID=lm."InstitutionID" and r3m.ExternalProductID=lm."ExternalProductID"
left join insmarketp3mdata p3m on r3m.month_text=p3m.month_text and r3m.MarketName=p3m.MarketName and r3m.InstitutionID=p3m.InstitutionID and r3m.ExternalProductID=p3m.ExternalProductID; -- Updated Rows        4391100

--Step5. Update AreaMarketQuarterData
drop table if exists insmarketquartersales;
CREATE Table insmarketquartersales AS
SELECT c.quarter_text,
 max(c.quarter_start_date) as quarter_start_date,
 max(c.quarter_end_date) as quarter_end_date,
 imcd."InstitutionID" as InstitutionID,
 max(imcd."InstitutionName") as InstitutionName,
 imcd."MarketName" as MarketName,
 imcd."ExternalProductID" as ExternalProductID,
 max(imcd."ExternalProductName") as ExternalProductName,
 max(imcd."ExternalProductName_EN") as ExternalProductName_EN,
 bool_or("IsInternalProduct") as IsInternalProduct,
 max(imcd."ProductID") as ProductID,
 max(imcd."ProductName") as ProductName,
 max(imcd."ProductName_EN") as ProductName_EN,
 sum(imcd."SalesValue") as sales_cq,
 sum(imcd."SalesValue") / nullif(count(distinct imcd."Cycle"),0) as avg_sales_cq,
 sum(imcd."SalesUnit") as sales_unit_cq,
 sum(imcd."SalesUnit") / nullif(count(distinct imcd."Cycle"),0) as avg_sales_unit_cq
FROM "InsMarketCycleData" imcd
JOIN dim_calendar c ON imcd."Cycle" = c.month_text and c.day_of_month_num = 1
GROUP BY c.quarter_text,
 imcd."MarketName",
 imcd."InstitutionID",
 imcd."ExternalProductID"
order by imcd."MarketName",
 imcd."InstitutionID",
 imcd."ExternalProductID",
 c.quarter_text; -- Updated Rows        1317330

drop table if exists insmarketlastquartersales;
CREATE Table insmarketlastquartersales AS
SELECT C.QUARTER_TEXT,
 max(C.quarter_start_date) as quarter_start_date,
 max(C.quarter_end_date) as quarter_end_date,
 imcd."InstitutionID" as InstitutionID,
 max(imcd."InstitutionName") as InstitutionName,
 imcd."MarketName" as MarketName,
 imcd."ExternalProductID" as ExternalProductID,
 max(imcd."ExternalProductName") as ExternalProductName,
 max(imcd."ExternalProductName_EN") as ExternalProductName_EN,
 bool_or("IsInternalProduct") as IsInternalProduct,
 max(imcd."ProductID") as ProductID,
 max(imcd."ProductName") as ProductName,
 max(imcd."ProductName_EN") as ProductName_EN,
 sum(imcd."SalesValue") as sales_lq,
 sum(imcd."SalesValue") / nullif(count(distinct imcd."Cycle"),0) as avg_sales_lq,
 sum(imcd."SalesUnit") as sales_unit_lq,
 sum(imcd."SalesUnit") / nullif(count(distinct imcd."Cycle"),0) as avg_sales_unit_lq
FROM "InsMarketCycleData" imcd
JOIN dim_calendar c ON to_date(imcd."Cycle",'yyyymm') = to_date(c.month_text,'yyyymm')-interval '3 month' and c.day_of_month_num = 1
GROUP BY c.quarter_text,
 imcd."MarketName",
 imcd."InstitutionID",
 imcd."ExternalProductID"
order by imcd."MarketName",
 imcd."InstitutionID",
 imcd."ExternalProductID",
 c.quarter_text;--Updated Rows        1317330

drop table if exists "InsMarketQuarterData";
CREATE Table "InsMarketQuarterData" AS
select cq.*, lq.sales_lq, lq.avg_sales_lq, lq.sales_unit_lq, lq.avg_sales_unit_lq
from insmarketquartersales cq
left join insmarketlastquartersales lq on cq.quarter_text=lq.quarter_text and cq.marketname=lq.marketname and cq.institutionid=lq.institutionid and cq.externalproductid=lq.externalproductid;--Updated Rows        1317330

RAISE NOTICE 'IMCD Step4 - IMMD, IMQD created';

-- 4. Drop internal tables
drop table insmarketr3mdata;
drop table insmarketp3mdata;
drop table insmarketquartersales;
drop table insmarketlastquartersales;

alter table "InsMarketCycleData" owner to nvs_user_dw;
alter table "InsMarketQuarterData" owner to nvs_user_dw;
alter table "InsMarketMonthData" owner to nvs_user_dw;

RAISE NOTICE 'IMCD Done, remember to VACUUM the table';


end;
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
DROP TABLE "InsTrtyProductChannelCycleData";

CREATE TABLE "InsTrtyProductChannelCycleData" (
        "RepTerritoryCode" varchar(50) NULL,
        "Cycle" varchar(20) NULL,
        "SubInsID" varchar(20) NULL,
        "SubInsName" varchar(100) NULL,
        "SubInsType" varchar(100) NULL,
        "InsID" varchar(20) NULL,
        "InsName" varchar(100) NULL,
        "ProductID" varchar(20) NULL,
        "ProductName" varchar(100) NULL,
        "ProductName_EN" varchar(100) NULL,
        "Franchise" varchar(100) NULL,
        "SalesValue" numeric(28, 8) NULL,
        "LYSalesValue" numeric(28, 8) NULL,
        "SalesUnit" numeric(28, 8) NULL,
        "LYSalesUnit" numeric(28, 8) NULL
);
CREATE INDEX itpccd_pk_idx ON public."InsTrtyProductChannelCycleData" USING btree ("InsID", "RepTerritoryCode", "ProductID", "Cycle", "SubInsType");
CREATE INDEX itpccd_pk_idx2 ON public."InsTrtyProductChannelCycleData" USING btree ("InsID", "RepTerritoryCode", "ProductID", "Cycle");

-- Step1. Standardize column names and column type
drop table if exists "InsTrtyProductChannelCycleData_1";
create table "InsTrtyProductChannelCycleData_1" as
select
        repterritoryid as "RepTerritoryCode",
        "cycle" as "Cycle",
        null as "SubInsID",
        null as "SubInsName",
        subinstype as "SubInsType",
        insid as "InsID",
        max(insname) as "InsName",
        p."ProductID" as "ProductID",
        max(p."ProductName") as "ProductName",
        max(productname) as "ProductName_EN",
        max(franchise) as "Franchise",
        sum(salesvalue::numeric(28,8)) as "SalesValue",
        sum(lysalesvalue::numeric(28,8)) as "LYSalesValue",
        sum(salesunit::numeric(28,8)) as "SalesUnit",
        sum(lysalesunit::numeric(28,8)) as "LYSalesUnit"
from instrtyproductchannelcycledata_raw itpccd
join "Product" p on itpccd.productid = p."ProductID"
join "OrgCycle" oc on itpccd.repterritoryid = oc."RepTerritoryID" and oc."Cycle" =(select max("cycle") from instrtyproductcycledata_raw where salesvalue>0)
where oc."BUHTerritoryName" in ('CRMBU', 'OTNBU')
and itpccd.subinstype is not null
group by insid, subinstype, repterritoryid, p."ProductID", cycle;--677,348

RAISE NOTICE 'ITPCCD Step1 - Standardize column Done';

-- Step2. Create cross-join table
drop table if exists "InsTrtyProductChannelCycleData_2";
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
--Updated Rows        2,668,215

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
select * from "InsTrtyProductChannelCycleData_2";--Updated Rows        2668215
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
order by         itpccd."SubInsType",
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
order by         itpccd."SubInsType",
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
alter table "InsTrtyProductQuarterChannelData" owner to nvs_user_dw;
alter table "InsTrtyProductMonthChannelData" owner to nvs_user_dw;

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
DROP TABLE "InsTrtyProductCycleData";

CREATE TABLE "InsTrtyProductCycleData" (
        "RepTerritoryCode" varchar(50) NULL,
        "Cycle" varchar(20) NULL,
        "InsID" varchar(20) NULL,
        "InsName" varchar(100) NULL,
        "ProductID" varchar(20) NULL,
        "ProductName" varchar(100) NULL,
        "ProductName_EN" varchar(100) NULL,
        "TargetValue" numeric(28, 8) NULL,
        "SalesValue" numeric(28, 8) NULL,
        "LYSalesValue" numeric(28, 8) NULL,
        "TargetUnit" numeric(28, 8) NULL,
        "SalesUnit" numeric(28, 8) NULL,
        "LYSalesUnit" numeric(28, 8) NULL,
        "FTE" numeric(28, 8) NULL
);
CREATE INDEX instrtyproductcycledata_insid_idx ON public."InsTrtyProductCycleData" USING btree ("InsID", "RepTerritoryCode", "ProductID", "Cycle");

-- Step1. Standardize column names and calculate MarketSize
insert into "InsTrtyProductCycleData" ("RepTerritoryCode", "Cycle", "InsID", "InsName", "ProductID", "ProductName", "ProductName_EN", "TargetValue", "SalesValue", "LYSalesValue", "TargetUnit", "SalesUnit", "LYSalesUnit", "FTE")
select
    repterritoryid as "RepTerritoryCode",
    cycle as "Cycle",
    insid as "InsID",
    max(insname) as "InsName",
    p."ProductID" as "ProductID",
    max(p."ProductName") as "ProductName",
    max(productname) as "ProductName_EN",
    sum(targetvalue::numeric(28,8)) as "TargetValue",
    sum(salesvalue::numeric(28,8)) as "SalesValue",
    sum(lysalesvalue::numeric(28,8)) as "LYSalesValue",
    sum(targetunit::numeric(28,8)) as "TargetUnit",
    sum(salesunit::numeric(28,8)) as "SalesUnit",
    sum(lysalesunit::numeric(28,8)) as "LYSalesUnit",
    sum(fte::numeric(28,8)) as "FTE"
from instrtyproductcycledata_raw itpcd
join "Product" p on itpcd.productid = p."ProductID"
join "OrgCycle" oc on itpcd.repterritoryid = oc."RepTerritoryID" and oc."Cycle" =(select max("cycle") from "instrtyproductcycledata_raw" where salesvalue>0)
where oc."BUHTerritoryName" in ('CRMBU', 'OTNBU')
group by insid, repterritoryid, p."ProductID", cycle;

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
    C.QUARTER_TEXT; -- Updated Rows    708218

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
    C.QUARTER_TEXT; --Updated Rows 708218

drop table if exists "InsTrtyProductQuarterData";
CREATE Table "InsTrtyProductQuarterData" AS
select cq.*, lq.sales_lq, lq.avg_sales_lq, lq.sales_unit_lq, lq.avg_sales_unit_lq
from InsTrtyProductQuarterSales cq
left join InsTrtyProductLastQuarterSales lq
on cq.QUARTER_TEXT=lq.QUARTER_TEXT
and cq.InsID=lq.InsID
and cq.RepTerritoryCode=lq.RepTerritoryCode
and cq.ProductID=lq.ProductID;
-- Updated Rows 708218

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
    C.month_text; -- Updated Rows  2124654

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
    month_text; -- Updated Rows    2124654

drop table if exists "InsTrtyProductMonthData";
CREATE Table "InsTrtyProductMonthData" AS
select r3m.*, p3m.previous_3m_sales, p3m.previous_3m_sales_unit, lm."SalesValue" as lm_sales, lm."SalesUnit" as lm_sales_unit
from InsTrtyProductR3MSales r3m
left join "InsTrtyProductCycleData" lm on to_date(r3m.month_text, 'yyyymm') - interval '1 month' = to_date(lm."Cycle",'yyyymm') and r3m.InsID=lm."InsID" and r3m.RepTerritoryCode=lm."RepTerritoryCode" and r3m.ProductID=lm."ProductID"
left join InsTrtyProductP3MSales p3m on r3m.month_text=p3m.month_text and r3m.InsID=p3m.InsID and r3m.RepTerritoryCode=p3m.RepTerritoryCode and r3m.ProductID=p3m.ProductID; -- Updated Rows        2124654



RAISE NOTICE 'Step3 - ITPMD Refresh Done';

--Step4. Alter table owner
alter table "InsTrtyProductCycleData" owner to nvs_user_dw;
alter table "InsTrtyProductQuarterData" owner to nvs_user_dw;
alter table "InsTrtyProductMonthData" owner to nvs_user_dw;


end;
$procedure$
;



-- DROP PROCEDURE public.proc_cleanse_insprodlisting();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_insprodlisting()
 LANGUAGE plpgsql
AS $procedure$
BEGIN


--=============================================================================================================================
-- InsProdListingEvent
--=============================================================================================================================
RAISE NOTICE 'InsProdListingEvent started';

drop table if exists "InsProdListingEvent_arc";
create table "InsProdListingEvent_arc" as select * from "InsProdListingEvent";
DROP TABLE "InsProdListingEvent";

CREATE TABLE "InsProdListingEvent" (
        "InstitutionID" varchar(20) NOT NULL,
        "InstitutionName" varchar(100) NULL,
        "InstitutionName_EN" varchar(255) NULL,
        "ProductLevel" varchar(20) NOT NULL,
        "ProductID" varchar(20) NOT NULL,
        "ProductName" varchar(100) NULL,
        "ProductName_EN" varchar(100) NULL,
        "ListingStatus" varchar(100) NOT NULL,
        "ListingStatus_EN" varchar(100) NULL,
        "EventDate" varchar(20) NOT NULL,
        CONSTRAINT insprodlistingevent_pk PRIMARY KEY ("InstitutionID", "ProductID", "ListingStatus")
);
CREATE INDEX insprodlistingevent_productid_idx ON public."InsProdListingEvent" USING btree ("ProductID", "ListingStatus");

truncate "InsProdListingEvent";
INSERT INTO "InsProdListingEvent"
select distinct
        iplr.institutionid as "InstitutionID",
        max(i."InstitutionName") as "InstitutionName",
        null as "InstitutionName_EN",
        'brand' as "ProductLevel",
        iplr.productid as "ProductID",
        max(p."BrandName") as "ProductName",
        max(p."BrandName_EN") as "ProductName_EN",
        iplr.listingstatus as "ListingStatus",
        max(iplr.listingstatus_en) as "ListingStatus_EN",
        min(iplr.listingcycle) as "EventDate"
from "insprodlisting_raw" iplr
join "Institution" i on iplr.institutionid = i."InstitutionID"
join "Product" p on iplr.productid = p."BrandID"
join (select distinct "InsID", "ProductID" from "InsTrtyProductCycleData" where "Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)) itpcd on iplr.institutionid = itpcd."InsID" and p."ProductID" = itpcd."ProductID"
where lower(iplr.issku) = 'false'
and iplr.ym = (select max(ym) from "insprodlisting_raw")
and iplr.listingstatus = '正式进院'
group by iplr.institutionid, iplr.productid, iplr.listingstatus; --11243
INSERT INTO "InsProdListingEvent"
select distinct
        iplr.institutionid as "InstitutionID",
        max(i."InstitutionName") as "InstitutionName",
        null as "InstitutionName_EN",
        'sku' as "ProductLevel",
        iplr.productid as "ProductID",
        max(p."ProductName") as "ProductName",
        max(p."ProductName_EN") as "ProductName_EN",
        iplr.listingstatus as "ListingStatus",
        max(iplr.listingstatus_en) as "ListingStatus_EN",
        min(iplr.listingcycle) as "EventDate"
from "insprodlisting_raw" iplr
join "Institution" i on iplr.institutionid = i."InstitutionID"
join "Product" p on iplr.productid = p."ProductID"
join (select distinct "InsID", "ProductID" from "InsTrtyProductCycleData" where "Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)) itpcd on iplr.institutionid = itpcd."InsID" and iplr.productid = itpcd."ProductID"
where lower(iplr.issku) = 'true'
and iplr.ym = (select max(ym) from "insprodlisting_raw")
and iplr.listingstatus = '正式进院'
group by iplr.institutionid, iplr.productid, iplr.listingstatus; --2070

INSERT INTO "InsProdListingEvent"
select distinct
        iplr.institutionid as "InstitutionID",
        max(i."InstitutionName") as "InstitutionName",
        null as "InstitutionName_EN",
        'brand' as "ProductLevel",
        iplr.productid as "ProductID",
        max(p."BrandName") as "ProductName",
        max(p."BrandName_EN") as "ProductName_EN",
        iplr.listingstatus as "ListingStatus",
        max(iplr.listingstatus_en) as "ListingStatus_EN",
        min(iplr.listingcycle) as "EventDate"
from "insprodlisting_raw" iplr
join "Institution" i on iplr.institutionid = i."InstitutionID"
join "Product" p on iplr.productid = p."BrandID"
join (select distinct "InsID", "ProductID" from "InsTrtyProductCycleData" where "Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)) itpcd on iplr.institutionid = itpcd."InsID" and p."ProductID" = itpcd."ProductID"
where lower(iplr.issku) = 'false'
and iplr.ym = (select max(ym) from "insprodlisting_raw")
and iplr.listingstatus = '临采'
group by iplr.institutionid, iplr.productid, iplr.listingstatus; --1135
INSERT INTO "InsProdListingEvent"
select distinct
        iplr.institutionid as "InstitutionID",
        max(i."InstitutionName") as "InstitutionName",
        null as "InstitutionName_EN",
        'sku' as "ProductLevel",
        iplr.productid as "ProductID",
        max(p."ProductName") as "ProductName",
        max(p."ProductName_EN") as "ProductName_EN",
        iplr.listingstatus as "ListingStatus",
        max(iplr.listingstatus_en) as "ListingStatus_EN",
        min(iplr.listingcycle) as "EventDate"
from "insprodlisting_raw" iplr
join "Institution" i on iplr.institutionid = i."InstitutionID"
join "Product" p on iplr.productid = p."ProductID"
join (select distinct "InsID", "ProductID" from "InsTrtyProductCycleData" where "Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)) itpcd on iplr.institutionid = itpcd."InsID" and iplr.productid = itpcd."ProductID"
where lower(iplr.issku) = 'true'
and iplr.ym = (select max(ym) from "insprodlisting_raw")
and iplr.listingstatus = '临采'
group by iplr.institutionid, iplr.productid, iplr.listingstatus; --123

INSERT INTO "InsProdListingEvent"
select distinct
        iplr.institutionid as "InstitutionID",
        max(i."InstitutionName") as "InstitutionName",
        null as "InstitutionName_EN",
        'brand' as "ProductLevel",
        iplr.productid as "ProductID",
        max(p."BrandName") as "ProductName",
        max(p."BrandName_EN") as "ProductName_EN",
        iplr.listingstatus as "ListingStatus",
        max(iplr.listingstatus_en) as "ListingStatus_EN",
        min(iplr.listingcycle) as "EventDate"
from "insprodlisting_raw" iplr
join "Institution" i on iplr.institutionid = i."InstitutionID"
join "Product" p on iplr.productid = p."BrandID"
join (select distinct "InsID", "ProductID" from "InsTrtyProductCycleData" where "Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)) itpcd on iplr.institutionid = itpcd."InsID" and p."ProductID" = itpcd."ProductID"
where lower(iplr.issku) = 'false'
and iplr.ym = (select max(ym) from "insprodlisting_raw")
and iplr.listingstatus = '院内药房采购'
group by iplr.institutionid, iplr.productid, iplr.listingstatus; --64
INSERT INTO "InsProdListingEvent"
select distinct
        iplr.institutionid as "InstitutionID",
        max(i."InstitutionName") as "InstitutionName",
        null as "InstitutionName_EN",
        'sku' as "ProductLevel",
        iplr.productid as "ProductID",
        max(p."ProductName") as "ProductName",
        max(p."ProductName_EN") as "ProductName_EN",
        iplr.listingstatus as "ListingStatus",
        max(iplr.listingstatus_en) as "ListingStatus_EN",
        min(iplr.listingcycle) as "EventDate"
from "insprodlisting_raw" iplr
join "Institution" i on iplr.institutionid = i."InstitutionID"
join "Product" p on iplr.productid = p."ProductID"
join (select distinct "InsID", "ProductID" from "InsTrtyProductCycleData" where "Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)) itpcd on iplr.institutionid = itpcd."InsID" and iplr.productid = itpcd."ProductID"
where lower(iplr.issku) = 'true'
and iplr.ym = (select max(ym) from "insprodlisting_raw")
and iplr.listingstatus = '院内药房采购'
group by iplr.institutionid, iplr.productid, iplr.listingstatus; --3

RAISE NOTICE 'Step1 - InsProdListingEvent cleanse done';

--=============================================================================================================================
-- InsProdListing
--=============================================================================================================================
RAISE NOTICE 'InsProdListing started';

drop table if exists "InsProdListing_arc";
create table "InsProdListing_arc" as select * from "InsProdListing";
DROP TABLE "InsProdListing";

CREATE TABLE "InsProdListing" (
        "InstitutionID" varchar(20) NOT NULL,
        "InstitutionName" varchar(100) NULL,
        "InstitutionName_EN" varchar(255) NULL,
        "ProductLevel" varchar(20) NOT NULL,
        "ProductID" varchar(20) NOT NULL,
        "ProductName" varchar(100) NULL,
        "ProductName_EN" varchar(100) NULL,
        "ListingStatus" varchar(100) NULL,
        "ListingStatus_EN" varchar(100) NULL,
        CONSTRAINT insprodlisting_pk PRIMARY KEY ("InstitutionID", "ProductID")
);

-- Insert listing status records from RAW data
INSERT INTO "InsProdListing"
select distinct
        iplr.institutionid as "InstitutionID",
        max(i."InstitutionName") as "InstitutionName",
        null as "InstitutionName_EN",
        'brand' as "ProductLevel",
        p."BrandID" as "ProductID",
        max(p."BrandName") as "ProductName",
        max(p."BrandName_EN") as "ProductName_EN",
        case min(case iplr.listingstatus when '正式进院' then 1 when '临采' then 2 when '院内药房采购' then 3 when '未进院' then 4 end)
                when 1 then '正式进院' when 2 then '临采' when 3 then '院内药房采购' when 4 then '未进院' end as "ListingStatus",
        case min(case iplr.listingstatus when '正式进院' then 1 when '临采' then 2 when '院内药房采购' then 3 when '未进院' then 4 end)
                when 1 then 'Formal listed' when 2 then 'Temp listed' when 3 then 'Pharmacy listed' when 4 then 'Not listed' end as "ListingStatus_EN"
from "insprodlisting_raw" iplr
join "Institution" i on iplr.institutionid = i."InstitutionID"
join "Product" p on iplr.productid = p."BrandID"
join (select distinct "InsID", "ProductID" from "InsTrtyProductCycleData" where "Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)) itpcd on iplr.institutionid = itpcd."InsID" and p."ProductID" = itpcd."ProductID"
where lower(iplr.issku) = 'false'
and iplr.ym = (select max(ym) from "insprodlisting_raw")
group by iplr.institutionid, p."BrandID"; --59721
INSERT INTO "InsProdListing"
select distinct
        iplr.institutionid as "InstitutionID",
        max(i."InstitutionName") as "InstitutionName",
        null as "InstitutionName_EN",
        'sku' as "ProductLevel",
        p."ProductID",
        max(p."ProductName") as "ProductName",
        max(p."ProductName_EN") as "ProductName_EN",
        case min(case iplr.listingstatus when '正式进院' then 1 when '临采' then 2 when '院内药房采购' then 3 when '未进院' then 4 end)
                when 1 then '正式进院' when 2 then '临采' when 3 then '院内药房采购' when 4 then '未进院' end as "ListingStatus",
        case min(case iplr.listingstatus when '正式进院' then 1 when '临采' then 2 when '院内药房采购' then 3 when '未进院' then 4 end)
                when 1 then 'Formal listed' when 2 then 'Temp listed' when 3 then 'Pharmacy listed' when 4 then 'Not listed' end as "ListingStatus_EN"
from "insprodlisting_raw" iplr
join "Institution" i on iplr.institutionid = i."InstitutionID"
join "Product" p on iplr.productid = p."ProductID"
join (select distinct "InsID", "ProductID" from "InsTrtyProductCycleData" where "Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)) itpcd on iplr.institutionid = itpcd."InsID" and iplr.productid = itpcd."ProductID"
where lower(iplr.issku) = 'true'
and iplr.ym = (select max(ym) from "insprodlisting_raw")
group by iplr.institutionid, p."ProductID"; --4222

-- Insert the rest Institution/Product listing status which not mentioned in RAW data
INSERT INTO "InsProdListing"
select distinct
        ipp."InstitutionID",
        ipp."InstitutionName",
        ipp."InstitutionName_EN",
        'brand' as "ProductLevel",
        ipp."ProductID",
        ipp."ProductName",
        ipp."ProductName_EN",
        '未进院' as "ListingStatus",
        'Not listed' as "ListingStatus_EN"
from "InsProdProperty" ipp
join "Institution" i on ipp."InstitutionID" = i."InstitutionID"
join (select distinct "InsID", p."BrandID" from "InsTrtyProductCycleData"  itpcd join "Product" p on itpcd."ProductID" = p."ProductID" where "Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)) itpcd on ipp."InstitutionID" = itpcd."InsID" and ipp."ProductID" = itpcd."BrandID"
where not exists (select 1 from "InsProdListing" ipl where ipl."InstitutionID" = ipp."InstitutionID" and ipl."ProductID" = ipp."ProductID"); --37935

RAISE NOTICE 'Step2 - InsProdListing cleanse done';

-- Alter table owner
alter table "InsProdListingEvent" owner to nvs_user_dw;
alter table "InsProdListing" owner to nvs_user_dw;

RAISE NOTICE 'InsProdListing & InsProdListingEvent Ready';

END;
$procedure$
;

-- DROP PROCEDURE public.proc_cleanse_lowperformance();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_lowperformance()
 LANGUAGE plpgsql
AS $procedure$
begin

--==========================================================================================================================
-- proc_cleanse_LowPerformance cleansing
--==========================================================================================================================
RAISE NOTICE 'LowPerformance started';
drop table if exists "LowPerformanceDetail_arc";
create table "LowPerformanceDetail_arc" as select * from "LowPerformanceDetail"; --180
truncate "LowPerformanceDetail";

-- 1. Standardize column names
--AD_post|AD_name|RM_post|RM_name|DM_post|DM_name|MR_post|MR_name|PG|双低状态|上个季度生产力|上个季度增长率
insert into "LowPerformanceDetail"
select distinct
    oc."BUHTerritoryName",
    oc."BUHName",
    oc."FHTerritoryName",
    oc."FHName",
    oc."TLMTerritoryName",
    oc."TLMName",
    oc."SLMTerritoryName",
    oc."SLMName",
    oc."FLMTerritoryName",
    oc."FLMName",
    oc."RepTerritoryName",
    oc."RepName",
    lpr.promotion_grid,
    lpr.dl_continuous_quarters::INTEGER,
    lpr.latest_quarter,
    nullif(productivity,'')::numeric(38,8),
    nullif(yoy_growth_rate,'')::numeric(38,8) * 100 as yoy_growth_rate
from "lowperformance_raw" lpr
join "OrgCycle" oc on lpr.territory_version::text = oc."Cycle" and lpr.mr_post = oc."RepTerritoryName"
where lpr.territory_version = (select max(territory_version) from "lowperformance_raw");

RAISE NOTICE 'LowPerformance - Standardize columns done';

end;
$procedure$
;



