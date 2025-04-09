-- DROP PROCEDURE public.proc_cleanse_bi_scope_lookup();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_bi_scope_lookup()
 LANGUAGE plpgsql
AS $procedure$

BEGIN

--=============================================================================================================================
-- bi_scope_lookup
--=============================================================================================================================
RAISE NOTICE 'Initialize bi_scope_lookup started';
drop table if exists bi_scope_lookup_arc;
create table bi_scope_lookup_arc as select * from bi_scope_lookup;
drop table if exists bi_scope_lookup;

CREATE TABLE bi_scope_lookup (
        id uuid NOT NULL,
        created_at timestamptz NOT NULL,
        updated_at timestamptz NOT NULL,
        deleted_at timestamptz NULL,
        range_external_id varchar(255) NOT NULL,
        range_standard_name varchar(255) NOT NULL,
        range_local_name varchar(255) NOT NULL,
        local_language varchar(10) NOT NULL,
        "level" varchar(255) NOT NULL,
        "type" varchar(255) NOT NULL,
        CONSTRAINT bi_scope_lookup_pkey PRIMARY KEY (id)
);

RAISE NOTICE 'Backup and re-create bi_scope_lookup done';

-- 1. Geography setup
delete from bi_scope_lookup where type in ('geography', 'geo_and_org'); 
--firstly apply manual rules
insert into bi_scope_lookup
values 
(gen_random_uuid(), NOW(), NOW(), NULL, 'cn', '中国', '全国', 'CN', 'country', 'geography'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'cn', '中国', '全国', 'CN', 'geo_territory_cluster', 'geo_and_org'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'roc', '中国其它地区', 'ROC', 'CN', 'city', 'geography'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'roc', '中国其它地区', 'ROC', 'CN', 'geo_territory_cluster', 'geo_and_org'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'roc', '中国其它地区', 'Rest of China', 'CN', 'geo_territory_cluster', 'geo_and_org'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'roc', '中国其它地区', '中国其它地区', 'CN', 'geo_territory_cluster', 'geo_and_org')
;
--country
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, min("CountryID") as range_external_id, "CountryName" as range_standard_name, "CountryName"  as range_local_name, 'CN' as local_language, 'country' as "level", 'geography' as "type" from "Geography" g
where nullif("CountryName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'geography' and upper(bsl.range_local_name) = upper("CountryName"))
group by "CountryName"; --1
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, min("CountryID") as range_external_id, "CountryName" as range_standard_name, "CountryName_EN"  as range_local_name, 'CN' as local_language, 'country' as "level", 'geography' as "type" from "Geography" g
where nullif("CountryName_EN",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'geography' and upper(bsl.range_local_name) = upper("CountryName_EN"))
group by "CountryName", "CountryName_EN"; --1
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, min("CountryID") as range_external_id, "CountryName" as range_standard_name, "CountryName"  as range_local_name, 'CN' as local_language, 'geo_territory_cluster' as "level", 'geo_and_org' as "type" from "Geography" g
where nullif("CountryName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_territory_cluster' and upper(bsl.range_local_name) = upper("CountryName"))
group by "CountryName"; --1
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, min("CountryID") as range_external_id, "CountryName" as range_standard_name, "CountryName_EN"  as range_local_name, 'CN' as local_language, 'geo_territory_cluster' as "level", 'geo_and_org' as "type" from "Geography" g
where nullif("CountryName_EN",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_territory_cluster' and upper(bsl.range_local_name) = upper("CountryName_EN"))
group by "CountryName", "CountryName_EN"; --1
--province
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, min("ProvinceID") as range_external_id, "ProvinceName" as range_standard_name, "ProvinceName"  as range_local_name, 'CN' as local_language, 'province' as "level", 'geography' as "type" from "Geography" g
where nullif("ProvinceName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'geography' and upper(bsl.range_local_name) = upper("ProvinceName"))
group by "ProvinceName"; --33
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, min("CountryID") as range_external_id, "ProvinceName" as range_standard_name, "ProvinceName_EN"  as range_local_name, 'CN' as local_language, 'province' as "level", 'geography' as "type" from "Geography" g
where nullif("ProvinceName_EN",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'geography' and upper(bsl.range_local_name) = upper("ProvinceName_EN"))
group by "ProvinceName", "ProvinceName_EN"; --33
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, min("ProvinceID") as range_external_id, "ProvinceName" as range_standard_name, "ProvinceName"  as range_local_name, 'CN' as local_language, 'geo_territory_cluster' as "level", 'geo_and_org' as "type" from "Geography" g
where nullif("ProvinceName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_territory_cluster' and upper(bsl.range_local_name) = upper("ProvinceName"))
group by "ProvinceName"; --33
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, min("CountryID") as range_external_id, "ProvinceName" as range_standard_name, "ProvinceName_EN"  as range_local_name, 'CN' as local_language, 'geo_territory_cluster' as "level", 'geo_and_org' as "type" from "Geography" g
where nullif("ProvinceName_EN",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_territory_cluster' and upper(bsl.range_local_name) = upper("ProvinceName_EN"))
group by "ProvinceName", "ProvinceName_EN"; --33
--city
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, min("CityID") as range_external_id, "CityName" as range_standard_name, "CityName"  as range_local_name, 'CN' as local_language, 'city' as "level", 'geography' as "type" from "Geography" g
where nullif("CityName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'geography' and upper(bsl.range_local_name) = upper("CityName"))
group by "CityName"; --368
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, min("CityID") as range_external_id, max("CityName") as range_standard_name, "CityName_EN"  as range_local_name, 'CN' as local_language, 'city' as "level", 'geography' as "type" from "Geography" g
where nullif("CityName_EN",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'geography' and upper(bsl.range_local_name) = upper("CityName_EN"))
group by "CityName_EN" having count(distinct "CityName") = 1; --363
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, min("CityID") as range_external_id, "CityName" as range_standard_name, "CityName"  as range_local_name, 'CN' as local_language, 'geo_territory_cluster' as "level", 'geo_and_org' as "type" from "Geography" g
where nullif("CityName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_territory_cluster' and upper(bsl.range_local_name) = upper("CityName"))
group by "CityName"; --368
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, min("CityID") as range_external_id, max("CityName") as range_standard_name, "CityName_EN"  as range_local_name, 'CN' as local_language, 'geo_territory_cluster' as "level", 'geo_and_org' as "type" from "Geography" g
where nullif("CityName_EN",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_territory_cluster' and upper(bsl.range_local_name) = upper("CityName_EN"))
group by "CityName_EN" having count(distinct "CityName") = 1; --363
--county
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, min("CountyID") as range_external_id, "CityName"||"CountyName" as range_standard_name, "CityName"||"CountyName" as range_local_name, 'CN' as local_language, 'county' as "level", 'geography' as "type" from "Geography" g
where nullif("CityName"||"CountyName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'geography' and upper(bsl.range_local_name) = upper("CityName"||"CountyName"))
and not exists (select 1 from bi_scope_lookup bsl where bsl.level in ('city') and bsl.range_standard_name = g."CountyName")
group by "CityName","CountyName"; --3180
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, min("CountyID") as range_external_id, "CityName"||"CountyName" as range_standard_name, "CityName"||"CountyName" as range_local_name, 'CN' as local_language, 'geo_territory_cluster' as "level", 'geo_and_org' as "type" from "Geography" g
where nullif("CityName"||"CountyName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_territory_cluster' and upper(bsl.range_local_name) = upper("CityName"||"CountyName"))
and not exists (select 1 from bi_scope_lookup bsl where bsl.level in ('city') and bsl.range_standard_name = g."CountyName")
group by "CityName","CountyName"; --3180

--city_tier
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, "CityTier" as range_external_id, "CityTier" as range_standard_name, "CityTier" as range_local_name, 'CN' as local_language, 'city_tier' as "level", 'geography' as "type" from "Geography" g
where nullif("CityTier",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'geography' and upper(bsl.range_local_name) = upper("CityTier"))
group by "CityTier"; --8
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, "CityTier" as range_external_id, "CityTier" as range_standard_name, case "CityTier" when 'City-1' then '一线城市' when 'City-2' then '二线城市' when 'City-3' then '三线城市' when 'City-4a' then '四线城市' when 'City-4b' then '四线城市' else "CityTier" end as range_local_name, 'CN' as local_language, 'city_tier' as "level", 'geography' as "type" from "Geography" g
where nullif("CityTier",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'geography' and upper(bsl.range_local_name) = upper(case "CityTier" when 'City-1' then '一线城市' when 'City-2' then '二线城市' when 'City-3' then '三线城市' when 'City-4a' then '四线城市' when 'City-4b' then '四线城市' else "CityTier" end))
group by "CityTier"; --5
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, "CityTier" as range_external_id, "CityTier" as range_standard_name, "CityTier" as range_local_name, 'CN' as local_language, 'geo_territory_cluster' as "level", 'geo_and_org' as "type" from "Geography" g
where nullif("CityTier",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_territory_cluster' and upper(bsl.range_local_name) = upper("CityTier"))
group by "CityTier"; --8
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, "CityTier" as range_external_id, "CityTier" as range_standard_name, case "CityTier" when 'City-1' then '一线城市' when 'City-2' then '二线城市' when 'City-3' then '三线城市' when 'City-4a' then '四线城市' when 'City-4b' then '四线城市' else "CityTier" end as range_local_name, 'CN' as local_language, 'geo_territory_cluster' as "level", 'geo_and_org' as "type" from "Geography" g
where nullif("CityTier",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_territory_cluster' and upper(bsl.range_local_name) = upper(case "CityTier" when 'City-1' then '一线城市' when 'City-2' then '二线城市' when 'City-3' then '三线城市' when 'City-4a' then '四线城市' when 'City-4b' then '四线城市' else "CityTier" end))
group by "CityTier"; --5
-- county_tier
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, "CountyTier" as range_external_id, "CountyTier" as range_standard_name, "CountyTier" as range_local_name, 'CN' as local_language, 'county_tier' as "level", 'geography' as "type" from "Geography" g
where nullif("CountyTier",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'geography' and upper(bsl.range_local_name) = upper("CountyTier"))
group by "CountyTier"; --0
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, "CountyTier" as range_external_id, "CountyTier" as range_standard_name, "CountyTier" as range_local_name, 'CN' as local_language, 'geo_territory_cluster' as "level", 'geo_and_org' as "type" from "Geography" g
where nullif("CountyTier",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_territory_cluster' and upper(bsl.range_local_name) = upper("CountyTier"))
group by "CountyTier"; --0

-- 1.2 keep product aliases in old DBV records
insert into bi_scope_lookup
select min(bsla.id::text)::uuid as id, min(bsla.created_at) as created_at, now() as updated_at, null as deleted_at, min(bsla.range_external_id) as range_external_id, bsla.range_standard_name, bsla.range_local_name, min(bsla.local_language) as local_language, bsla."level", bsla."type" from bi_scope_lookup_arc bsla
join bi_scope_lookup bsl1 on bsla."level" = bsl1."level" and bsla."type" = bsl1."type" and bsla.range_standard_name = bsl1.range_standard_name
where bsla.type = 'geography' and bsla.level <> 'county'
and not exists (select 1 from bi_scope_lookup bsl where bsla."level" = bsl."level" and bsla."type" = bsl."type" and upper(bsla.range_local_name) = upper(bsl.range_local_name))
group by bsla.range_standard_name, bsla.range_local_name, bsla."level", bsla."type"; --37

RAISE NOTICE 'Build bi_scope_lookup Step1 - Geo done';

-- 2. Institution setup
delete from bi_scope_lookup where type in ('institution'); 
--institution_name
delete from bi_scope_lookup where level = 'institution_name';
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, min("InstitutionID") as range_external_id, "InstitutionName" as range_standard_name, "InstitutionName"  as range_local_name, 'CN' as local_language, 'institution_name' as "level", 'institution' as "type" from "Institution" i
where nullif("InstitutionName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'institution_name' and upper(bsl.range_local_name) = upper(i."InstitutionName"))
and i."InstitutionTier" not in ('未评级','未知','一级','一级甲等','一级乙等','一级丙等')
group by i."InstitutionName"; --20244
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, min("InstitutionID") as range_external_id, "InstitutionName" as range_standard_name, "InstitutionID"  as range_local_name, 'CN' as local_language, 'institution_name' as "level", 'institution' as "type" 
from "Institution" i
where nullif("InstitutionID",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'institution_name' and upper(bsl.range_local_name) = upper(i."InstitutionID"))
and i."InstitutionTier" not in ('未评级','未知','一级','一级甲等','一级乙等','一级丙等')
group by i."InstitutionID", i."InstitutionName"; --8704
--institution_tier
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, "InstitutionTier" as range_external_id, "InstitutionTier" as range_standard_name, "InstitutionTier"  as range_local_name, 'CN' as local_language, 'institution_tier' as "level", 'institution' as "type" from "Institution" i
where nullif("InstitutionTier",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'institution_tier' and upper(bsl.range_local_name) = upper(i."InstitutionTier"))
group by i."InstitutionTier";--14
--institution_ownership
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, "InstitutionType2" as range_external_id, "InstitutionType2" as range_standard_name, "InstitutionType2"  as range_local_name, 'CN' as local_language, 'institution_ownership' as "level", 'institution' as "type" from "Institution" i
where nullif("InstitutionType2",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'institution_ownership' and upper(bsl.range_local_name) = upper(i."InstitutionType2"))
group by i."InstitutionType2";--4
--institution_product_segment
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, "InsProdProperty1" as range_external_id, "InsProdProperty1" as range_standard_name, "InsProdProperty1"  as range_local_name, 'CN' as local_language, 'institution_product_segment' as "level", 'institution' as "type" from "InsProdProperty" ipp
where nullif("InsProdProperty1",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'institution_product_segment' and upper(bsl.range_local_name) = upper(ipp."InsProdProperty1"))
group by ipp."InsProdProperty1"; --3
--institution_product_type
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, "InsProdProperty2" as range_external_id, "InsProdProperty2" as range_standard_name, "InsProdProperty2"  as range_local_name, 'CN' as local_language, 'institution_product_type' as "level", 'institution' as "type" from "InsProdProperty" ipp
where nullif("InsProdProperty2",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'institution_product_type' and upper(bsl.range_local_name) = upper(ipp."InsProdProperty2"))
group by ipp."InsProdProperty2"; --20
insert into bi_scope_lookup select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, "InsProdProperty2" as range_external_id, "InsProdProperty2" as range_standard_name, "InsProdProperty2"||'眼科' as range_local_name, 'CN' as local_language, 'institution_product_type' as "level", 'institution' as "type" from "InsProdProperty" ipp
where nullif("InsProdProperty2",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'institution_product_type' and upper(bsl.range_local_name) = upper("InsProdProperty2"||'眼科'))
and ipp."ProductName" = '诺适得' and ipp."InsProdProperty2" not like '%医院'
group by ipp."InsProdProperty2"; --7 眼科医院
--sales_channel
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, "SubInsType" as range_external_id, "SubInsType" as range_standard_name, "SubInsType"  as range_local_name, 'CN' as local_language, 'sales_channel' as "level", 'institution' as "type" from "InsTrtyProductChannelCycleData" itpccd
where nullif("SubInsType",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'sales_channel' and upper(bsl.range_local_name) = upper(itpccd."SubInsType"))
group by itpccd."SubInsType"; --5
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, "SubInsType" as range_external_id, "SubInsType" as range_standard_name, "SubInsType"||'渠道'  as range_local_name, 'CN' as local_language, 'sales_channel' as "level", 'institution' as "type" from "InsTrtyProductChannelCycleData" itpccd
where nullif("SubInsType",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'sales_channel' and upper(bsl.range_local_name) = upper(itpccd."SubInsType"||'渠道'))
group by itpccd."SubInsType"; --5
--sales_channel_category
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, "SalesChannelCategory_CN" as range_external_id, "SalesChannelCategory_CN" as range_standard_name, "SalesChannelCategory_CN"  as range_local_name, 'CN' as local_language, 'sales_channel_category' as "level", 'institution' as "type" from "InsTrtyProductChannelCycleData" itpccd join "SalesChannel" sc on sc."SalesChannel_EN" = itpccd."SubInsType" 
where nullif("SalesChannelCategory_CN",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'sales_channel_category' and upper(bsl.range_local_name) = upper(sc."SalesChannelCategory_CN"))
group by sc."SalesChannelCategory_CN"; --5
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, "SalesChannelCategory_CN" as range_external_id, "SalesChannelCategory_CN" as range_standard_name, "SalesChannelCategory_CN"||'渠道'  as range_local_name, 'CN' as local_language, 'sales_channel_category' as "level", 'institution' as "type" from "InsTrtyProductChannelCycleData" itpccd join "SalesChannel" sc on sc."SalesChannel_EN" = itpccd."SubInsType" 
where nullif("SalesChannelCategory_CN",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'sales_channel_category' and upper(bsl.range_local_name) = upper(sc."SalesChannelCategory_CN"||'渠道'))
group by sc."SalesChannelCategory_CN"; --5
--product_listing_status
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, "ListingStatus" as range_external_id, "ListingStatus" as range_standard_name, "ListingStatus"  as range_local_name, 'CN' as local_language, 'product_listing_status' as "level", 'institution' as "type" from "InsProdListing" ipl
where nullif("ListingStatus",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_listing_status' and upper(bsl.range_local_name) = upper(ipl."ListingStatus"))
group by ipl."ListingStatus"; --4
insert into bi_scope_lookup
select gen_random_uuid() as id, now() as created_at, now() as updated_at, null as deleted_at, "ListingStatus" as range_external_id, "ListingStatus" as range_standard_name, "ListingStatus_EN"  as range_local_name, 'CN' as local_language, 'product_listing_status' as "level", 'institution' as "type" from "InsProdListing" ipl
where nullif("ListingStatus",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_listing_status' and upper(bsl.range_local_name) = upper(ipl."ListingStatus_EN"))
group by ipl."ListingStatus", ipl."ListingStatus_EN"; --4

-- 2.2 keep product aliases in old DBV records
insert into bi_scope_lookup
select min(bsla.id::text)::uuid as id, min(bsla.created_at) as created_at, now() as updated_at, null as deleted_at, min(bsla.range_external_id) as range_external_id, bsla.range_standard_name, bsla.range_local_name, min(bsla.local_language) as local_language, bsla."level", bsla."type" from bi_scope_lookup_arc bsla
join bi_scope_lookup bsl1 on bsla."level" = bsl1."level" and bsla."type" = bsl1."type" and bsla.range_standard_name = bsl1.range_standard_name
where bsla.type = 'institution'
and not exists (select 1 from bi_scope_lookup bsl where bsla."level" = bsl."level" and bsla."type" = bsl."type" and upper(bsla.range_local_name) = upper(bsl.range_local_name) )
group by bsla.range_standard_name, bsla.range_local_name, bsla."level", bsla."type"; --5229

RAISE NOTICE 'Build bi_scope_lookup Step2 - Institution done';

-- 3. Territory setup
delete from bi_scope_lookup where type in ('org_territory'); 
-- bu_head
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, "BUHTerritoryID", "BUHTerritoryName", "BUHTerritoryName", 'CN', 'bu_head', 'org_territory'
from "OrgCycle" oc
join "InsTrtyProductCycleData" itpcd on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from public."InsTrtyProductCycleData" where "SalesValue" > 0)
where nullif("BUHTerritoryName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'org_territory' and upper(bsl.range_local_name) = upper("BUHTerritoryName"))
group by "BUHTerritoryID", "BUHTerritoryName"; --2
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, "BUHTerritoryID", "BUHTerritoryName", "BUHTerritoryName", 'CN', 'geo_territory_cluster', 'geo_and_org'
from "OrgCycle" oc
join "InsTrtyProductCycleData" itpcd on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from public."InsTrtyProductCycleData" where "SalesValue" > 0)
where nullif("BUHTerritoryName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_territory_cluster' and upper(bsl.range_local_name) = upper("BUHTerritoryName"))
group by "BUHTerritoryID", "BUHTerritoryName"; --2
-- franchise_head
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, "FHTerritoryID", "FHTerritoryName", "FHTerritoryName", 'CN', 'franchise_head', 'org_territory'
from "OrgCycle" oc
join "InsTrtyProductCycleData" itpcd on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from public."InsTrtyProductCycleData" where "SalesValue" > 0)
where nullif("FHTerritoryName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'org_territory' and upper(bsl.range_local_name) = upper("FHTerritoryName"))
group by "FHTerritoryID", "FHTerritoryName"; --4
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, "FHTerritoryID", "FHTerritoryName", "FHTerritoryName", 'CN', 'geo_territory_cluster', 'geo_and_org'
from "OrgCycle" oc
join "InsTrtyProductCycleData" itpcd on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from public."InsTrtyProductCycleData" where "SalesValue" > 0)
where nullif("FHTerritoryName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_territory_cluster' and upper(bsl.range_local_name) = upper("FHTerritoryName"))
group by "FHTerritoryID", "FHTerritoryName"; --4
-- third_line_manager
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, "TLMTerritoryID", "TLMTerritoryName", "TLMTerritoryName", 'CN', 'third_line_manager', 'org_territory'
from "OrgCycle" oc
join "InsTrtyProductCycleData" itpcd on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from public."InsTrtyProductCycleData" where "SalesValue" > 0)
where nullif("TLMTerritoryName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'org_territory' and upper(bsl.range_local_name) = upper("TLMTerritoryName"))
group by "TLMTerritoryID", "TLMTerritoryName"; --12
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, "TLMTerritoryID", "TLMTerritoryName", "TLMTerritoryName", 'CN', 'geo_territory_cluster', 'geo_and_org'
from "OrgCycle" oc
join "InsTrtyProductCycleData" itpcd on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from public."InsTrtyProductCycleData" where "SalesValue" > 0)
where nullif("TLMTerritoryName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_territory_cluster' and upper(bsl.range_local_name) = upper("TLMTerritoryName"))
group by "TLMTerritoryID", "TLMTerritoryName"; --12
-- second_line_manager
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, "SLMTerritoryID", "SLMTerritoryName", "SLMTerritoryName", 'CN', 'second_line_manager', 'org_territory'
from "OrgCycle" oc
join "InsTrtyProductCycleData" itpcd on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from public."InsTrtyProductCycleData" where "SalesValue" > 0)
where nullif("SLMTerritoryName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'org_territory' and upper(bsl.range_local_name) = upper("SLMTerritoryName"))
group by "SLMTerritoryID", "SLMTerritoryName"; --44
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, "SLMTerritoryID", "SLMTerritoryName", "SLMTerritoryName", 'CN', 'geo_territory_cluster', 'geo_and_org'
from "OrgCycle" oc
join "InsTrtyProductCycleData" itpcd on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from public."InsTrtyProductCycleData" where "SalesValue" > 0)
where nullif("SLMTerritoryName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_territory_cluster' and upper(bsl.range_local_name) = upper("SLMTerritoryName"))
group by "SLMTerritoryID", "SLMTerritoryName"; --44
-- first_line_manager
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, "FLMTerritoryID", "FLMTerritoryName", "FLMTerritoryName", 'CN', 'first_line_manager', 'org_territory'
from "OrgCycle" oc
join "InsTrtyProductCycleData" itpcd on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from public."InsTrtyProductCycleData" where "SalesValue" > 0)
where nullif("FLMTerritoryName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'org_territory' and upper(bsl.range_local_name) = upper("FLMTerritoryName"))
group by "FLMTerritoryID", "FLMTerritoryName"; --270
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, "FLMTerritoryID", "FLMTerritoryName", "FLMTerritoryName", 'CN', 'geo_territory_cluster', 'geo_and_org'
from "OrgCycle" oc
join "InsTrtyProductCycleData" itpcd on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from public."InsTrtyProductCycleData" where "SalesValue" > 0)
where nullif("FLMTerritoryName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_territory_cluster' and upper(bsl.range_local_name) = upper("FLMTerritoryName"))
group by "FLMTerritoryID", "FLMTerritoryName"; --270
-- rep_territory
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, "RepTerritoryID", "RepTerritoryName", "RepTerritoryName", 'CN', 'rep_territory', 'org_territory'
from "OrgCycle" oc
join "InsTrtyProductCycleData" itpcd on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from public."InsTrtyProductCycleData" where "SalesValue" > 0)
where nullif("RepTerritoryName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'org_territory' and upper(bsl.range_local_name) = upper("RepTerritoryName"))
group by "RepTerritoryID", "RepTerritoryName"; --2050
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, "RepTerritoryID", "RepTerritoryName", "RepTerritoryName", 'CN', 'geo_territory_cluster', 'geo_and_org'
from "OrgCycle" oc
join "InsTrtyProductCycleData" itpcd on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from public."InsTrtyProductCycleData" where "SalesValue" > 0)
where nullif("RepTerritoryName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_territory_cluster' and upper(bsl.range_local_name) = upper("RepTerritoryName"))
group by "RepTerritoryID", "RepTerritoryName"; --2050

--full_name
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, max("BUHTerritoryID"), max("BUHTerritoryName"), "BUHName", 'CN', 'full_name', 'org_territory'
from "OrgCycle" oc
join "InsTrtyProductCycleData" itpcd on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from public."InsTrtyProductCycleData" where "SalesValue" > 0)
where "BUHName" ~ '[\u4e00-\u9fff]' --中文字符
and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'full_name' and upper(bsl.range_local_name) = upper("BUHName"))
group by "BUHName"; --2
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, max("FHTerritoryID"), max("FHTerritoryName"), "FHName", 'CN', 'full_name', 'org_territory'
from "OrgCycle" oc
join "InsTrtyProductCycleData" itpcd on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from public."InsTrtyProductCycleData" where "SalesValue" > 0)
where "FHName" ~ '[\u4e00-\u9fff]' --中文字符
and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'full_name' and upper(bsl.range_local_name) = upper("FHName"))
group by "FHName"; --2
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, max("TLMTerritoryID"), max("TLMTerritoryName"), "TLMName", 'CN', 'full_name', 'org_territory'
from "OrgCycle" oc
join "InsTrtyProductCycleData" itpcd on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from public."InsTrtyProductCycleData" where "SalesValue" > 0)
where "TLMName" ~ '[\u4e00-\u9fff]' --中文字符
and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'full_name' and upper(bsl.range_local_name) = upper("TLMName"))
group by "TLMName"; --7
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, max("SLMTerritoryID"), max("SLMTerritoryName"), "SLMName", 'CN', 'full_name', 'org_territory'
from "OrgCycle" oc
join "InsTrtyProductCycleData" itpcd on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from public."InsTrtyProductCycleData" where "SalesValue" > 0)
where "SLMName" ~ '[\u4e00-\u9fff]' --中文字符
and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'full_name' and upper(bsl.range_local_name) = upper("SLMName"))
group by "SLMName"; --40
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, max("FLMTerritoryID"), max("FLMTerritoryName"), "FLMName", 'CN', 'full_name', 'org_territory'
from "OrgCycle" oc
join "InsTrtyProductCycleData" itpcd on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from public."InsTrtyProductCycleData" where "SalesValue" > 0)
where "FLMName" ~ '[\u4e00-\u9fff]' --中文字符
and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'full_name' and upper(bsl.range_local_name) = upper("FLMName"))
group by "FLMName"; --252
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, max("RepTerritoryID"), max("RepTerritoryName"), "RepName", 'CN', 'full_name', 'org_territory'
from "OrgCycle" oc
join "InsTrtyProductCycleData" itpcd on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from public."InsTrtyProductCycleData" where "SalesValue" > 0)
where "RepName" ~ '[\u4e00-\u9fff]' --中文字符
and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'full_name' and upper(bsl.range_local_name) = upper("RepName"))
group by "RepName"; --1922

--product_line
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, oc."RepProductLine", oc."RepProductLine", oc."RepProductLine", 'CN', 'product_line', 'org_territory'
from "OrgCycle" oc
join "InsTrtyProductCycleData" itpcd on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from public."InsTrtyProductCycleData" where "SalesValue" > 0)
where nullif(oc."RepProductLine",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'org_territory' and upper(bsl.range_local_name) = upper(oc."RepProductLine"))
group by oc."RepProductLine"; --8
--        is_vacancy_territory
insert into bi_scope_lookup (id,created_at,updated_at,deleted_at,range_external_id,range_standard_name,range_local_name,local_language,"level","type") values 
         (gen_random_uuid(),NOW(),NOW(),NULL,'false','false','在岗','CN','is_vacancy_territory','org_territory'),
         (gen_random_uuid(),NOW(),NOW(),NULL,'true','true','空岗','CN','is_vacancy_territory','org_territory'); --2
         
-- 3.2 keep territory aliases in old DBV records
insert into bi_scope_lookup
select min(bsla.id::text)::uuid as id, min(bsla.created_at) as created_at, now() as updated_at, null as deleted_at, min(bsla.range_external_id) as range_external_id, bsla.range_standard_name, bsla.range_local_name, min(bsla.local_language) as local_language, bsla."level", bsla."type" from bi_scope_lookup_arc bsla
join bi_scope_lookup bsl1 on bsla."level" = bsl1."level" and bsla."type" = bsl1."type" and bsla.range_standard_name = bsl1.range_standard_name
where bsla.type = 'org_territory' and bsla.level <> 'full_name'
and not exists (select 1 from bi_scope_lookup bsl where bsla."level" = bsl."level" and bsla."type" = bsl."type" and upper(bsla.range_local_name) = upper(bsl.range_local_name) )
group by bsla.range_standard_name, bsla.range_local_name, bsla."level", bsla."type"; --79
insert into bi_scope_lookup
select min(bsla.id::text)::uuid as id, min(bsla.created_at) as created_at, now() as updated_at, null as deleted_at, min(bsla.range_external_id) as range_external_id, bsla.range_standard_name, bsla.range_local_name, min(bsla.local_language) as local_language, bsla."level", bsla."type" from bi_scope_lookup_arc bsla
join bi_scope_lookup bsl1 on bsla."level" = bsl1."level" and bsla."type" = bsl1."type" and bsla.range_standard_name = bsl1.range_standard_name
where bsla.type = 'geo_and_org' 
and not exists (select 1 from bi_scope_lookup bsl where bsla."level" = bsl."level" and bsla."type" = bsl."type" and upper(bsla.range_local_name) = upper(bsl.range_local_name) )
group by bsla.range_standard_name, bsla.range_local_name, bsla."level", bsla."type"; --150

RAISE NOTICE 'Build bi_scope_lookup Step3 - Territory done';

-- 4. Product setup
--brand
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, min(p."BrandID"), p."BrandName", p."BrandName", 'CN', 'brand', 'product'
from "Product" p --join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where nullif(p."BrandName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'product' and upper(bsl.range_local_name) = upper(p."BrandName"))
group by p."BrandName"; --76
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, min(p."BrandID"), p."BrandName", p."BrandName_EN", 'CN', 'brand', 'product'
from "Product" p --join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where nullif(p."BrandName_EN",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'product' and upper(bsl.range_local_name) = upper(p."BrandName_EN"))
group by p."BrandName", p."BrandName_EN"; --75
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, max("ExternalProductID"), coalesce(pm."ProductName","ExternalProductName"), "ExternalProductName", 'CN', 'brand', 'product'
from "AreaMarketCycleData" amcd
left join "ProductMapping" pm on amcd."ExternalProductID" = pm."IMS_ProductID" 
where nullif(amcd."ExternalProductName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'product' and upper(bsl.range_local_name) = upper(amcd."ExternalProductName"))
group by amcd."ExternalProductName",pm."ProductName"; --133
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, max("ExternalProductID"), coalesce(pm."ProductName","ExternalProductName"), "ExternalProductName", 'CN', 'brand', 'product'
from "InsMarketCycleData" imcd
left join "ProductMapping" pm on imcd."ExternalProductID" = pm."CPA_ProductID" 
where nullif(imcd."ExternalProductName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'product' and upper(bsl.range_local_name) = upper(imcd."ExternalProductName"))
group by imcd."ExternalProductName",pm."ProductName"; --119
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, min(p."BrandID"), p."BrandName", p."BrandName", 'CN', 'product_cluster', 'product'
from "Product" p --join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where nullif(p."BrandName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(p."BrandName"))
group by p."BrandName"; --76
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, min(p."BrandID"), p."BrandName", p."BrandName_EN", 'CN', 'product_cluster', 'product'
from "Product" p --join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where nullif(p."BrandName_EN",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(p."BrandName_EN"))
group by p."BrandName", p."BrandName_EN"; --75
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, max("ExternalProductID"), coalesce(pm."ProductName","ExternalProductName"), "ExternalProductName", 'CN', 'product_cluster', 'product'
from "AreaMarketCycleData" amcd
left join "ProductMapping" pm on amcd."ExternalProductID" = pm."IMS_ProductID" 
where nullif(amcd."ExternalProductName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(amcd."ExternalProductName"))
group by amcd."ExternalProductName",pm."ProductName"; --133
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, max("ExternalProductID"), coalesce(pm."ProductName","ExternalProductName"), "ExternalProductName", 'CN', 'product_cluster', 'product'
from "InsMarketCycleData" imcd
left join "ProductMapping" pm on imcd."ExternalProductID" = pm."CPA_ProductID" 
where nullif(imcd."ExternalProductName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(imcd."ExternalProductName"))
group by imcd."ExternalProductName",pm."ProductName"; --119
--sku
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, max(p."ProductID"), p."ProductName_EN", p."ProductName", 'CN', 'sku', 'product'
from "Product" p --join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where nullif(p."ProductName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'product' and upper(bsl.range_local_name) = upper(p."ProductName"))
group by p."ProductName", p."ProductName_EN"; --83
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, max(p."ProductID"), p."ProductName_EN", p."ProductName", 'CN', 'product_cluster', 'product'
from "Product" p --join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where nullif(p."ProductName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(p."ProductName"))
group by p."ProductName", p."ProductName_EN"; --83
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, max(p."ProductID"), p."ProductName_EN", p."ProductName_EN", 'CN', 'sku', 'product'
from "Product" p --join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where nullif(p."ProductName_EN",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'product' and upper(bsl.range_local_name) = upper(p."ProductName_EN"))
group by p."ProductName_EN"; --81
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, max(p."ProductID"), p."ProductName_EN", p."ProductName_EN", 'CN', 'product_cluster', 'product'
from "Product" p --join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where nullif(p."ProductName_EN",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(p."ProductName_EN"))
group by p."ProductName_EN"; --81
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, max(p."ProductID"), p."ProductName_EN", replace(p."ProductName", p."BrandName", p."BrandName_EN"), 'CN', 'sku', 'product'
from "Product" p --join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where nullif(p."ProductName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'product' and upper(bsl.range_local_name) = upper(replace(p."ProductName", p."BrandName", p."BrandName_EN")))
group by p."ProductName", p."ProductName_EN", p."BrandName", p."BrandName_EN"; --67
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, max(p."ProductID"), p."ProductName_EN", replace(p."ProductName", p."BrandName", p."BrandName_EN"), 'CN', 'product_cluster', 'product'
from "Product" p --join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where nullif(p."ProductName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(replace(p."ProductName", p."BrandName", p."BrandName_EN")))
group by p."ProductName", p."ProductName_EN", p."BrandName", p."BrandName_EN"; --67
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, max(p."ProductID"), p."ProductName_EN", replace(p."ProductName_EN", p."BrandName_EN", p."BrandName"), 'CN', 'sku', 'product'
from "Product" p --join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where nullif(p."ProductName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'product' and upper(bsl.range_local_name) = upper(replace(p."ProductName_EN", p."BrandName_EN", p."BrandName")))
group by p."ProductName", p."ProductName_EN", p."BrandName", p."BrandName_EN"; --77
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, max(p."ProductID"), p."ProductName_EN", replace(p."ProductName_EN", p."BrandName_EN", p."BrandName"), 'CN', 'product_cluster', 'product'
from "Product" p --join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where nullif(p."ProductName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(replace(p."ProductName_EN", p."BrandName_EN", p."BrandName")))
group by p."ProductName", p."ProductName_EN", p."BrandName", p."BrandName_EN"; --77

--brand_lifecycle
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, p."ProductFeature", p."ProductFeature", p."ProductFeature", 'CN', 'brand_lifecycle', 'product'
from "Product" p join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where nullif(p."ProductFeature",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'product' and upper(bsl.range_local_name) = upper(p."ProductFeature"))
group by p."ProductFeature"; --3
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, p."ProductFeature", p."ProductFeature", p."ProductFeature", 'CN', 'product_cluster', 'product'
from "Product" p join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where nullif(p."ProductFeature",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(p."ProductFeature"))
group by p."ProductFeature"; --3
--brand_group
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at,  tpp."TrtyProdProperty1",  tpp."TrtyProdProperty1",  tpp."TrtyProdProperty1", 'CN', 'brand_group', 'product'
from "TrtyProdProperty" tpp
where nullif(tpp."TrtyProdProperty1",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'product' and upper(bsl.range_local_name) = upper(tpp."TrtyProdProperty1"))
group by tpp."TrtyProdProperty1"; --6
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at,  tpp."TrtyProdProperty1",  tpp."TrtyProdProperty1",  tpp."TrtyProdProperty1", 'CN', 'product_cluster', 'product'
from "TrtyProdProperty" tpp
where nullif(tpp."TrtyProdProperty1",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(tpp."TrtyProdProperty1"))
group by tpp."TrtyProdProperty1"; --6

--is_internal_product
insert into bi_scope_lookup (id,created_at,updated_at,deleted_at,range_external_id,range_standard_name,range_local_name,local_language,"level","type") values 
         (gen_random_uuid(),NOW(),NOW(),NULL,'false','false','外部产品','CN','is_internal_product','product'),
         (gen_random_uuid(),NOW(),NOW(),NULL,'false','false','竞品','CN','is_internal_product','product'),
         (gen_random_uuid(),NOW(),NOW(),NULL,'true','true','内部产品','CN','is_internal_product','product'),
         (gen_random_uuid(),NOW(),NOW(),NULL,'true','true','Novartis','CN','is_internal_product','product'),
         (gen_random_uuid(),NOW(),NOW(),NULL,'true','true','诺华产品','CN','is_internal_product','product'); --5        
--product_market
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, lower(p."PrimaryMarket"), p."PrimaryMarket", p."PrimaryMarket", 'CN', 'product_market', 'product'
from "Product" p join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where nullif(p."PrimaryMarket",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_market' and upper(bsl.range_local_name) = upper(p."PrimaryMarket"))
group by p."PrimaryMarket"; --21
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, lower(p."PrimaryMarket"), p."PrimaryMarket", max(p."ProductLevel4")||'市场', 'CN', 'product_market', 'product'
from "Product" p join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where nullif(p."PrimaryMarket",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_market' and upper(bsl.range_local_name) = upper(p."ProductLevel4"||'市场'))
group by p."PrimaryMarket"; --21
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, lower(p."PrimaryMarket"), p."PrimaryMarket", max(p."ProductLevel4_EN")||' Market', 'CN', 'product_market', 'product'
from "Product" p join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where nullif(p."PrimaryMarket",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_market' and upper(bsl.range_local_name) = upper(p."ProductLevel4_EN"||' Market'))
group by p."PrimaryMarket"; --21
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, lower(p."PrimaryMarket"), p."PrimaryMarket", max(p."ProductLevel4_EN")||'市场', 'CN', 'product_market', 'product'
from "Product" p join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where nullif(p."PrimaryMarket",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_market' and upper(bsl.range_local_name) = upper(p."ProductLevel4_EN"||' Market'))
group by p."PrimaryMarket"; --5
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, lower("MarketName"), "MarketName", "MarketName", 'CN', 'product_market', 'product'
from "AreaMarketCycleData" amcd
where nullif("MarketName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_market' and upper(bsl.range_local_name) = upper("MarketName"))
group by "MarketName"; --6
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, lower("MarketName"), "MarketName", "MarketName", 'CN', 'product_market', 'product'
from "InsMarketCycleData" imcd
where nullif("MarketName",'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_market' and upper(bsl.range_local_name) = upper("MarketName"))
group by "MarketName"; --5

-- 4.2 keep product aliases in old DBV records
insert into bi_scope_lookup
select min(bsla.id::text)::uuid as id, min(bsla.created_at) as created_at, now() as updated_at, null as deleted_at, min(bsla.range_external_id) as range_external_id, bsla.range_standard_name, bsla.range_local_name, min(bsla.local_language) as local_language, bsla."level", bsla."type" from bi_scope_lookup_arc bsla
join bi_scope_lookup bsl1 on bsla."level" = bsl1."level" and bsla."type" = bsl1."type" and bsla.range_standard_name = bsl1.range_standard_name
where bsla.type = 'product'
and not exists (select 1 from bi_scope_lookup bsl where bsla."level" = bsl."level" and bsla."type" = bsl."type" and upper(bsla.range_local_name) = upper(bsl.range_local_name) )
and bsla.range_standard_name <> '其他'
group by bsla.range_standard_name, bsla.range_local_name, bsla."level", bsla."type"; --280

RAISE NOTICE 'Build bi_scope_lookup Step4 - Product done';

END;
$procedure$
;


-- DROP PROCEDURE public.proc_cleanse_bi_scope_affiliation();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_bi_scope_affiliation()
 LANGUAGE plpgsql
AS $procedure$
BEGIN


--=============================================================================================================================
-- bi_scope_affiliation
--=============================================================================================================================
RAISE NOTICE 'Initialize bi_scope_affiliation started';
drop table if exists bi_scope_affiliation_arc;
create table bi_scope_affiliation_arc as select * from bi_scope_affiliation;
truncate bi_scope_affiliation;

-- 1) Brand to Market
INSERT INTO bi_scope_affiliation (id, created_at, updated_at, deleted_at, scope1_type, scope1_level, scope1_range_std_name, scope2_type, scope2_level, scope2_range_std_name, relation)
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, 'product', 'brand', p."BrandName", 'product', 'product_market', p."PrimaryMarket",'cascade'
from "Product" p join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where not exists (select 1 from bi_scope_affiliation where scope1_range_std_name = p."BrandName" and scope2_range_std_name = p."PrimaryMarket")
and p."BrandName" is not null and "PrimaryMarket" is not null
group by p."BrandName", "PrimaryMarket"; --23
INSERT INTO bi_scope_affiliation (id, created_at, updated_at, deleted_at, scope1_type, scope1_level, scope1_range_std_name, scope2_type, scope2_level, scope2_range_std_name, relation)
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, 'product', 'brand', "ExternalProductName", 'product', 'product_market', "MarketName",'cascade'
from "AreaMarketCycleData" amcd
where not "IsInternalProduct"
and not exists (select 1 from bi_scope_affiliation where scope1_range_std_name = amcd."ExternalProductName" and scope2_range_std_name = amcd."MarketName")
group by "ExternalProductName", "MarketName"; --108
INSERT INTO bi_scope_affiliation (id, created_at, updated_at, deleted_at, scope1_type, scope1_level, scope1_range_std_name, scope2_type, scope2_level, scope2_range_std_name, relation)
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, 'product', 'brand', "ExternalProductName", 'product', 'product_market', "MarketName",'cascade'
from "InsMarketCycleData" imcd
where not "IsInternalProduct"
and not exists (select 1 from bi_scope_affiliation where scope1_range_std_name = imcd."ExternalProductName" and scope2_range_std_name = imcd."MarketName")
group by "ExternalProductName", "MarketName"; --75

RAISE NOTICE 'Step1 Brand to Market done';

-- 2) Market to Brand
INSERT INTO bi_scope_affiliation (id, created_at, updated_at, deleted_at, scope1_type, scope1_level, scope1_range_std_name, scope2_type, scope2_level, scope2_range_std_name, relation)
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, 'product', 'product_market', pm."Market", 'product', 'brand', p."BrandName",'cascade'
from "ProductMapping" pm
join "Product" p on pm."ProductID" = p."BrandID"
where not exists (select 1 from bi_scope_affiliation where scope1_range_std_name = pm."Market" and scope2_range_std_name = p."BrandName")
and p."BrandName" is not null and pm."Market" is not null
and p."ProductID" in (select distinct "ProductID" from "InsTrtyProductCycleData")
group by p."BrandName", pm."Market"; --23
INSERT INTO bi_scope_affiliation (id, created_at, updated_at, deleted_at, scope1_type, scope1_level, scope1_range_std_name, scope2_type, scope2_level, scope2_range_std_name, relation)
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, 'product', 'product_market', "MarketName", 'product', 'brand', "ExternalProductName",'cascade'
from "AreaMarketCycleData" amcd
where not "IsInternalProduct"
and not exists (select 1 from bi_scope_affiliation where scope2_range_std_name = amcd."ExternalProductName" and scope1_range_std_name = amcd."MarketName")
group by "ExternalProductName", "MarketName"; --108
INSERT INTO bi_scope_affiliation (id, created_at, updated_at, deleted_at, scope1_type, scope1_level, scope1_range_std_name, scope2_type, scope2_level, scope2_range_std_name, relation)
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, 'product', 'product_market', "MarketName", 'product', 'brand', "ExternalProductName",'cascade'
from "InsMarketCycleData" imcd
where not "IsInternalProduct"
and not exists (select 1 from bi_scope_affiliation where scope2_range_std_name = imcd."ExternalProductName" and scope1_range_std_name = imcd."MarketName")
group by "ExternalProductName", "MarketName"; --75

RAISE NOTICE 'Step2 Market to Brand done';

-- 3) Territory to Market
INSERT INTO bi_scope_affiliation (id, created_at, updated_at, deleted_at, scope1_type, scope1_level, scope1_range_std_name, scope2_type, scope2_level, scope2_range_std_name, relation) 
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, 'org_territory', 'bu_head', oc."BUHTerritoryName", 'product', 'product_market', pm."PrimaryMarket",'cascade'
from "InsTrtyProductCycleData" itpcd
join "OrgCycle" oc on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)
join "Product" pm on itpcd."ProductID" = pm."ProductID"
where pm."PrimaryMarket" in (select distinct "MarketName" from "AreaMarketCycleData" union select distinct "MarketName" from "InsMarketCycleData")
and pm."PrimaryMarket" not in ('CRM - LEQVIO INJ MKT')
group by oc."BUHTerritoryName", pm."PrimaryMarket";--24
INSERT INTO bi_scope_affiliation (id, created_at, updated_at, deleted_at, scope1_type, scope1_level, scope1_range_std_name, scope2_type, scope2_level, scope2_range_std_name, relation) 
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, 'org_territory', 'franchise_head', oc."FHTerritoryName", 'product', 'product_market', pm."PrimaryMarket",'cascade' 
from "InsTrtyProductCycleData" itpcd
join "OrgCycle" oc on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)
join "Product" pm on itpcd."ProductID" = pm."ProductID"
where not exists (select 1 from bi_scope_affiliation where scope1_range_std_name = oc."FHTerritoryName" and scope2_range_std_name = pm."PrimaryMarket")
and pm."PrimaryMarket" in (select distinct "MarketName" from "AreaMarketCycleData" union select distinct "MarketName" from "InsMarketCycleData")
and pm."PrimaryMarket" not in ('CRM - LEQVIO INJ MKT')
group by oc."FHTerritoryName", pm."PrimaryMarket";--16
INSERT INTO bi_scope_affiliation (id, created_at, updated_at, deleted_at, scope1_type, scope1_level, scope1_range_std_name, scope2_type, scope2_level, scope2_range_std_name, relation) 
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, 'org_territory', 'third_line_manager', oc."TLMTerritoryName", 'product', 'product_market', pm."PrimaryMarket",'cascade' 
from "InsTrtyProductCycleData" itpcd
join "OrgCycle" oc on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)
join "Product" pm on itpcd."ProductID" = pm."ProductID"
where not exists (select 1 from bi_scope_affiliation where scope1_range_std_name = oc."TLMTerritoryName" and scope2_range_std_name = pm."PrimaryMarket")
and pm."PrimaryMarket" in (select distinct "MarketName" from "AreaMarketCycleData" union select distinct "MarketName" from "InsMarketCycleData")
and pm."PrimaryMarket" not in ('CRM - LEQVIO INJ MKT')
group by oc."TLMTerritoryName", pm."PrimaryMarket";--69
INSERT INTO bi_scope_affiliation (id, created_at, updated_at, deleted_at, scope1_type, scope1_level, scope1_range_std_name, scope2_type, scope2_level, scope2_range_std_name, relation) 
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, 'org_territory', 'second_line_manager', oc."SLMTerritoryName", 'product', 'product_market', pm."PrimaryMarket",'cascade'
from "InsTrtyProductCycleData" itpcd
join "OrgCycle" oc on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)
join "Product" pm on itpcd."ProductID" = pm."ProductID"
where not exists (select 1 from bi_scope_affiliation where scope1_range_std_name = oc."SLMTerritoryName" and scope2_range_std_name = pm."PrimaryMarket")
and pm."PrimaryMarket" in (select distinct "MarketName" from "AreaMarketCycleData" union select distinct "MarketName" from "InsMarketCycleData")
and pm."PrimaryMarket" not in ('CRM - LEQVIO INJ MKT')
group by oc."SLMTerritoryName", pm."PrimaryMarket";--307
INSERT INTO bi_scope_affiliation (id, created_at, updated_at, deleted_at, scope1_type, scope1_level, scope1_range_std_name, scope2_type, scope2_level, scope2_range_std_name, relation) 
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, 'org_territory', 'first_line_manager', oc."FLMTerritoryName", 'product', 'product_market', pm."PrimaryMarket",'cascade' 
from "InsTrtyProductCycleData" itpcd
join "OrgCycle" oc on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)
join "Product" pm on itpcd."ProductID" = pm."ProductID"
where not exists (select 1 from bi_scope_affiliation where scope1_range_std_name = oc."FLMTerritoryName" and scope2_range_std_name = pm."PrimaryMarket")
and pm."PrimaryMarket" in (select distinct "MarketName" from "AreaMarketCycleData" union select distinct "MarketName" from "InsMarketCycleData")
and pm."PrimaryMarket" not in ('CRM - LEQVIO INJ MKT')
group by oc."FLMTerritoryName", pm."PrimaryMarket";--2035
INSERT INTO bi_scope_affiliation (id, created_at, updated_at, deleted_at, scope1_type, scope1_level, scope1_range_std_name, scope2_type, scope2_level, scope2_range_std_name, relation) 
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, 'org_territory', 'rep_territory', oc."RepTerritoryName", 'product', 'product_market', pm."PrimaryMarket",'cascade' 
from "InsTrtyProductCycleData" itpcd
join "OrgCycle" oc on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)
join "Product" pm on itpcd."ProductID" = pm."ProductID"
where not exists (select 1 from bi_scope_affiliation where scope1_range_std_name = oc."RepTerritoryName" and scope2_range_std_name = pm."PrimaryMarket")
and pm."PrimaryMarket" in (select distinct "MarketName" from "AreaMarketCycleData" union select distinct "MarketName" from "InsMarketCycleData")
and pm."PrimaryMarket" not in ('CRM - LEQVIO INJ MKT')
group by oc."RepTerritoryName", pm."PrimaryMarket";--15035

RAISE NOTICE 'Step3 Territory to Market done';

-- 4) SKU to brand
INSERT INTO bi_scope_affiliation (id, created_at, updated_at, deleted_at, scope1_type, scope1_level, scope1_range_std_name, scope2_type, scope2_level, scope2_range_std_name, relation)
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, 'product', 'sku', p."ProductName", 'product', 'brand', p."BrandName",'cascade'
from "Product" p join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where not exists (select 1 from bi_scope_affiliation where scope1_level='sku' and scope2_level='brand' and scope1_range_std_name = p."ProductName" and scope2_range_std_name = p."BrandName")
group by p."BrandName", p."ProductName"; --39

RAISE NOTICE 'Step4 SKU to brand done';

-- 5) SKU to Market
INSERT INTO bi_scope_affiliation (id, created_at, updated_at, deleted_at, scope1_type, scope1_level, scope1_range_std_name, scope2_type, scope2_level, scope2_range_std_name, relation)
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, 'product', 'sku', p."ProductName", 'product', 'product_market', p."PrimaryMarket",'cascade'
from "Product" p join "InsTrtyProductCycleData" itpcd on itpcd."ProductID" = p."ProductID"
where not exists (select 1 from bi_scope_affiliation where scope1_level='sku' and scope2_level='product_market' and scope1_range_std_name = p."ProductName" and scope2_range_std_name = p."PrimaryMarket")
and p."PrimaryMarket" is not null
group by p."PrimaryMarket", p."ProductName"; --36

RAISE NOTICE 'Step5 SKU to Market done';

-- 6) Market to Market
INSERT INTO bi_scope_affiliation (id, created_at, updated_at, deleted_at, scope1_type, scope1_level, scope1_range_std_name, scope2_type, scope2_level, scope2_range_std_name, relation) 
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, 'product', 'product_market', 'CRM - HLP MKT', 'product', 'product_market', 'CRM - LEQVIO INJ MKT','cascade' 
where not exists (select 1 from bi_scope_affiliation where scope1_level='product_market' and scope2_level='product_market' and scope1_range_std_name = 'CRM - HLP MKT' and scope2_range_std_name = 'CRM - LEQVIO INJ MKT'); --1

RAISE NOTICE 'Build bi_scope_affiliation done';

END;
$procedure$
;

-- DROP PROCEDURE public.proc_cleanse_bi_user_profile();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_bi_user_profile()
 LANGUAGE plpgsql
AS $procedure$

BEGIN

--=============================================================================================================================
-- bi_user_profile
--=============================================================================================================================
RAISE NOTICE 'Refresh bi_user_profile started';
drop table if exists bi_user_profile_arc;
create table bi_user_profile_arc as select * from bi_user_profile;

RAISE NOTICE 'Backup and re-create bi_user_profile done';

drop table if exists agg_fh_permission;
create temp table agg_fh_permission as 
select
        oc."FHTerritoryName",
        p."BrandName" as products,
        p."PrimaryMarket" as markets,
        null as competitor_cpa,
        null as competitor_ims
from "InsTrtyProductCycleData" itpcd
join "Product" p on itpcd."ProductID" = p."ProductID" 
join "OrgCycle" oc on oc."RepTerritoryID" = itpcd."RepTerritoryCode" and oc."Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)
where p."BrandName" is not null
group by oc."FHTerritoryName", p."BrandName", p."PrimaryMarket"
union
select
        tam."FHTerritoryName",
        null as products,
        amcd."MarketName" as markets,
        null as competitor_cpa,
        coalesce(amcd."ProductName",
        amcd."ExternalProductName") as competitor_ims
from "AreaMarketCycleData" amcd 
join "TerritoryAreaMapping" tam on amcd."ExternalAreaID" = tam."ExternalAreaID" and amcd."MarketName" = tam."MarketName" 
where amcd."MarketName" is not null
group by tam."FHTerritoryName", amcd."IsInternalProduct", amcd."MarketName", coalesce(amcd."ProductName", amcd."ExternalProductName")
union 
select
        oc."FHTerritoryName",
        null as products,
        imcd."MarketName" as markets,
        coalesce(imcd."ProductName",
        imcd."ExternalProductName") as competitor_cpa,
        null as competitor_ims
from "InsMarketCycleData" imcd 
join "ProductMapping" pm on imcd."MarketName" = pm."Market" 
join "Product" p on pm."ProductID" = p."BrandID" and p."IsStandardSKU" 
join "InsTrtyProductCycleData" itpcd on imcd."InstitutionID" = itpcd."InsID" and p."ProductID" = itpcd."ProductID" and itpcd."Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)
join "OrgCycle" oc on itpcd."RepTerritoryCode" = oc."RepTerritoryID" and oc."Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)
where imcd."MarketName" is not null
group by oc."FHTerritoryName", imcd."IsInternalProduct", imcd."MarketName", coalesce(imcd."ProductName", imcd."ExternalProductName")
; --1117

drop table if exists bi_user_profile_to_refresh;
create table bi_user_profile_to_refresh as
with bup as 
(select *, unnest(territory) AS element 
from bi_user_profile
where level='bu_head')
select 
        user_id, 
        'bu_head' as level,
        array_agg(distinct "BUHTerritoryName")filter(where "BUHTerritoryName" is not null) as territory,
        array_agg(distinct afp.products)filter(where afp.products is not null) as products,
        array_agg(distinct afp.markets)filter(where afp.markets is not null) as markets,
        array_agg(distinct afp.competitor_cpa)filter(where afp.competitor_cpa is not null) as competitor_cpa,
        array_agg(distinct afp.competitor_ims)filter(where afp.competitor_ims is not null) as competitor_ims
from "OrgCycle" oc 
join bup on oc."BUHTerritoryName" = bup.element 
join agg_fh_permission afp on oc."FHTerritoryName" = afp."FHTerritoryName"
where oc."Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)
group by user_id
order by products; --18

RAISE NOTICE 'Refresh bi_user_profile Step1 - bu_head done';

insert into bi_user_profile_to_refresh 
with bup as 
(select *, unnest(territory) AS element 
from bi_user_profile
where level='franchise_head')
select 
        user_id, 
        'franchise_head' as level,
        array_agg(distinct oc."FHTerritoryName")filter(where oc."FHTerritoryName" is not null) as territory,
        array_agg(distinct afp.products)filter(where afp.products is not null) as products,
        array_agg(distinct afp.markets)filter(where afp.markets is not null) as markets,
        array_agg(distinct afp.competitor_cpa)filter(where afp.competitor_cpa is not null) as competitor_cpa,
        array_agg(distinct afp.competitor_ims)filter(where afp.competitor_ims is not null) as competitor_ims
from "OrgCycle" oc 
join bup on oc."FHTerritoryName" = bup.element 
join agg_fh_permission afp on oc."FHTerritoryName" = afp."FHTerritoryName"
where oc."Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)
group by user_id
order by products; --23

RAISE NOTICE 'Refresh bi_user_profile Step2 - franchise_head done';

insert into bi_user_profile_to_refresh 
with bup as 
(select *, unnest(territory) AS element 
from bi_user_profile
where level = 'third_line_manager')
select 
        user_id, 
        'third_line_manager' as level,
        array_agg(distinct "TLMTerritoryName")filter(where "TLMTerritoryName" is not null) as territory,
        array_agg(distinct afp.products)filter(where afp.products is not null) as products,
        array_agg(distinct afp.markets)filter(where afp.markets is not null) as markets,
        array_agg(distinct afp.competitor_cpa)filter(where afp.competitor_cpa is not null) as competitor_cpa,
        array_agg(distinct afp.competitor_ims)filter(where afp.competitor_ims is not null) as competitor_ims
from "OrgCycle" oc 
join bup on oc."TLMTerritoryName" = bup.element 
join agg_fh_permission afp on oc."FHTerritoryName" = afp."FHTerritoryName"
where oc."Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)
group by user_id
order by products; --16

RAISE NOTICE 'Refresh bi_user_profile Step3 - third_line_manager done';

insert into bi_user_profile_to_refresh 
with bup as 
(select *, unnest(territory) AS element 
from bi_user_profile
where level='second_line_manager')
select 
        user_id, 
        'second_line_manager' as level,
        array_agg(distinct "SLMTerritoryName")filter(where "SLMTerritoryName" is not null) as territory,
        array_agg(distinct afp.products)filter(where afp.products is not null) as products,
        array_agg(distinct afp.markets)filter(where afp.markets is not null) as markets,
        array_agg(distinct afp.competitor_cpa)filter(where afp.competitor_cpa is not null) as competitor_cpa,
        array_agg(distinct afp.competitor_ims)filter(where afp.competitor_ims is not null) as competitor_ims
from "OrgCycle" oc 
join bup on oc."SLMTerritoryName" = bup.element 
join agg_fh_permission afp on oc."FHTerritoryName" = afp."FHTerritoryName"
where oc."Cycle" = (select max("Cycle") from "InsTrtyProductCycleData" where "SalesValue">0)
group by user_id
order by products; --81

RAISE NOTICE 'Refresh bi_user_profile Step4 - second_line_manager done';

update bi_user_profile bup
set
        territory = tr.territory,
        products = tr.products,
        markets = tr.markets,
        competitor_cpa = tr.competitor_cpa,
        competitor_ims = tr.competitor_ims
from bi_user_profile_to_refresh tr 
where bup.user_id = tr.user_id
;

RAISE NOTICE 'bi_user_profile refresh done';

END;
$procedure$
;


-- DROP PROCEDURE public.proc_cleanse_bi_source_table_info();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_bi_source_table_info()
 LANGUAGE plpgsql
AS $procedure$

BEGIN
--=============================================================================================================================
-- bi_source_table_info
--=============================================================================================================================
RAISE NOTICE 'Refresh bi_source_table_info started';

update bi_source_table_info set last_available_cycle = to_char(to_date(crd.to_period,'yyyymm'),'yyyy/mm'), last_updated_at = crd.last_modified_date
from choir_refresh_date crd
where table_name = 'InsTrtyProductCycleData' and crd.subject = 'sales';
update bi_source_table_info set last_available_cycle = to_char(to_date(itpct.to_period,'yyyymm'),'yyyy/mm'), last_updated_at = now()
from (select max("Cycle") as to_period from "InsTrtyProductCycleTarget" where "TargetValue" > 0) itpct
where table_name = 'InsTrtyProductCycleTarget';
update bi_source_table_info set last_available_cycle = to_char(to_date(crd.to_period,'yyyymm'),'yyyy/mm'), last_updated_at = crd.last_modified_date
from choir_refresh_date crd
where table_name = 'AreaMarketCycleData' and crd.subject = 'ims';
update bi_source_table_info set last_available_cycle = to_char(to_date(crd.to_period,'yyyymm'),'yyyy/mm'), last_updated_at = crd.last_modified_date
from choir_refresh_date crd
where table_name = 'InsMarketCycleData' and crd.subject = 'cpn';
update bi_source_table_info set last_available_cycle = to_char(to_date(crd.to_period,'yyyymm'),'yyyy/mm'), last_updated_at = crd.last_modified_date
from choir_refresh_date crd
where table_name = 'InsProdListingEvent' and crd.subject = 'hospital listing';
update bi_source_table_info set last_updated_at = crd.last_modified_date 
from choir_refresh_date crd
where table_name = 'InsProdListing' and crd.subject = 'hospital listing';

RAISE NOTICE 'Refresh bi_source_table_info done';

END;
$procedure$
;
