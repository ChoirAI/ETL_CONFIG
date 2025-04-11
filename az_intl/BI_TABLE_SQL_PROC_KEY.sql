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
delete from bi_scope_lookup where type in ('geography');
--firstly apply manual rules
insert into bi_scope_lookup
values
(gen_random_uuid(), NOW(), NOW(), NULL, 'a&z', 'Australia & New Zealand Total', 'A&Z', 'EN', 'area', 'geography'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'a&z', 'Australia & New Zealand Total', 'A&Z', 'EN', 'geo_cluster', 'geography'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'a&z', 'Australia & New Zealand Total', 'Australia & New Zealand', 'EN', 'geo_cluster', 'geography'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'a&z', 'Australia & New Zealand Total', 'Australia and New Zealand', 'EN', 'geo_cluster', 'geography'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'african', 'AFRICAN', 'africa cluster', 'EN', 'geo_term', 'geography'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'african', 'AFRICAN', 'africa cluster', 'EN', 'geo_cluster', 'geography')
;
--international
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(geo_lvl1),' ','_'), geo_lvl1, geo_lvl1, 'EN', 'region', 'geography'
from dim_geo dg
where nullif(geo_lvl1,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'geography' and bsl.range_standard_name = geo_lvl1 and upper(bsl.range_local_name) = upper(geo_lvl1))
group by geo_lvl1; --1
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(geo_lvl1),' ','_'), geo_lvl1, geo_lvl1, 'EN', 'geo_cluster', 'geography'
from dim_geo dg
where nullif(geo_lvl1,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_cluster' and bsl.range_standard_name = geo_lvl1 and upper(bsl.range_local_name) = upper(geo_lvl1))
group by geo_lvl1; --1
--region
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(geo_lvl2),' ','_'), geo_lvl2, geo_lvl2, 'EN', 'sub_region', 'geography'
from dim_geo dg
where nullif(geo_lvl2,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'geography' and bsl.range_standard_name = geo_lvl2 and upper(bsl.range_local_name) = upper(geo_lvl2))
group by geo_lvl2; --4
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(geo_lvl2),' ','_'), geo_lvl2, geo_lvl2, 'EN', 'geo_cluster', 'geography'
from dim_geo dg
where nullif(geo_lvl2,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_cluster' and bsl.range_standard_name = geo_lvl2 and upper(bsl.range_local_name) = upper(geo_lvl2))
group by geo_lvl2; --4
--area
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(geo_lvl3),' ','_'), geo_lvl3, geo_lvl3, 'EN', 'area', 'geography'
from dim_geo dg
where nullif(geo_lvl3,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'geography' and bsl.range_standard_name = geo_lvl3 and upper(bsl.range_local_name) = upper(geo_lvl3))
group by geo_lvl3; --16
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(geo_lvl3),' ','_'), geo_lvl3, geo_lvl3, 'EN', 'geo_cluster', 'geography'
from dim_geo dg
where nullif(geo_lvl3,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_cluster' and bsl.range_standard_name = geo_lvl3 and upper(bsl.range_local_name) = upper(geo_lvl3))
group by geo_lvl3; --16
--geo_market
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(geo_lvl4),' ','_'), geo_lvl4, geo_lvl4, 'EN', 'geo_market', 'geography'
from dim_geo dg
where nullif(geo_lvl4,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'geography' and bsl.range_standard_name = geo_lvl4 and upper(bsl.range_local_name) = upper(geo_lvl4))
group by geo_lvl4; --66
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(geo_lvl4),' ','_'), geo_lvl4, geo_lvl4, 'EN', 'geo_cluster', 'geography'
from dim_geo dg
where nullif(geo_lvl4,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_cluster' and bsl.range_standard_name = geo_lvl4 and upper(bsl.range_local_name) = upper(geo_lvl4))
group by geo_lvl4; --66
--geo_market_sub_1
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(geo_lvl5),' ','_'), geo_lvl5, geo_lvl5, 'EN', 'geo_market_sub_1', 'geography'
from dim_geo dg
where nullif(geo_lvl5,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'geography' and bsl.range_standard_name = geo_lvl5 and upper(bsl.range_local_name) = upper(geo_lvl5))
group by geo_lvl5; --96
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(geo_lvl5),' ','_'), geo_lvl5, geo_lvl5, 'EN', 'geo_cluster', 'geography'
from dim_geo dg
where nullif(geo_lvl5,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_cluster' and bsl.range_standard_name = geo_lvl5 and upper(bsl.range_local_name) = upper(geo_lvl5))
group by geo_lvl5; --96
--geo_market_sub_2
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(geo_lvl6),' ','_'), geo_lvl6, geo_lvl6, 'EN', 'geo_market_sub_2', 'geography'
from dim_geo dg
where nullif(geo_lvl6,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'geography' and bsl.range_standard_name = geo_lvl6 and upper(bsl.range_local_name) = upper(geo_lvl6))
group by geo_lvl6; --8
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(geo_lvl6),' ','_'), geo_lvl6, geo_lvl6, 'EN', 'geo_cluster', 'geography'
from dim_geo dg
where nullif(geo_lvl6,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_cluster' and bsl.range_standard_name = geo_lvl6 and upper(bsl.range_local_name) = upper(geo_lvl6))
group by geo_lvl6; --8
--entity
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(entity_description),' ','_'), entity_description, entity_description, 'EN', 'entity', 'geography'
from dim_geo dg
where nullif(entity_description,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'geography' and bsl.range_standard_name = entity_description and upper(bsl.range_local_name) = upper(entity_description))
group by entity_description; --23
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(entity_description),' ','_'), entity_description, entity_description, 'EN', 'geo_cluster', 'geography'
from dim_geo dg
where nullif(entity_description,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_cluster' and bsl.range_standard_name = entity_description and upper(bsl.range_local_name) = upper(entity_description))
group by entity_description; --23
--geo_term
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(geo_cluster_key),' ','_'), geo_cluster_key, geo_cluster_key, 'EN', 'geo_term', 'geography'
from dim_geo_cluster dgc
where nullif(geo_cluster_key,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'geography' and bsl.range_standard_name = geo_cluster_key and upper(bsl.range_local_name) = upper(geo_cluster_key))
group by geo_cluster_key; --6
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(geo_cluster_key),' ','_'), geo_cluster_key, geo_cluster_key, 'EN', 'geo_cluster', 'geography'
from dim_geo_cluster dgc
where nullif(geo_cluster_key,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'geo_cluster' and bsl.range_standard_name = geo_cluster_key and upper(bsl.range_local_name) = upper(geo_cluster_key))
group by geo_cluster_key; --6

--                select type, level, count(*) from bi_scope_lookup where type = 'geography' group by type, level order by 1, 3;

-- 1.2 keep product aliases in old DBV records
insert into bi_scope_lookup
select min(bsla.id::text)::uuid as id, min(bsla.created_at) as created_at, now() as updated_at, null as deleted_at, min(bsla.range_external_id) as range_external_id, bsla.range_standard_name, bsla.range_local_name, min(bsla.local_language) as local_language, bsla."level", bsla."type"
from bi_scope_lookup_arc bsla
join bi_scope_lookup bsl1 on bsla."level" = bsl1."level" and bsla."type" = bsl1."type" and upper(bsla.range_standard_name) = upper(bsl1.range_standard_name)
where bsla.type = 'geography'
and not exists (select 1 from bi_scope_lookup bsl where bsla."level" = bsl."level" and bsla."type" = bsl."type" and upper(bsla.range_standard_name) = upper(bsl.range_standard_name) and upper(bsla.range_local_name) = upper(bsl.range_local_name) )
group by bsla.range_standard_name, bsla.range_local_name, bsla."level", bsla."type"; --16

RAISE NOTICE 'Build bi_scope_lookup Step1 - Geo done';

-- 2. Product setup
delete from bi_scope_lookup where type in ('product');
--firstly apply manual rules
insert into bi_scope_lookup
values
(gen_random_uuid(), NOW(), NOW(), NULL, 'management_reporting', 'Management Reporting', 'All products', 'EN', 'total_product', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'management_reporting', 'Management Reporting', 'All products', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'management_reporting', 'Management Reporting', 'total products', 'EN', 'total_product', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'management_reporting', 'Management Reporting', 'total products', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'obu', 'OBU', 'Oncology Unit', 'EN', 'bu', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'obu', 'OBU', 'Oncology Unit', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'obu', 'OBU', 'onco', 'EN', 'bu', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'obu', 'OBU', 'onco', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'rdu', 'RDU', 'Rare Disease Unit', 'EN', 'bu', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'rdu', 'RDU', 'Rare Disease Unit', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'rdu', 'Rare Disease', 'Rare Disease', 'EN', 'ta', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'rdu', 'Rare Disease', 'Rare Disease', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'bbu', 'BBU', 'BioPharma BU', 'EN', 'bu', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'bbu', 'BBU', 'BioPharma BU', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'bbu', 'BBU', 'BioPharma TA', 'EN', 'bu', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'bbu', 'BBU', 'BioPharma TA', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'bbu', 'BBU', 'BioPharmaceuticals', 'EN', 'bu', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'bbu', 'BBU', 'BioPharmaceuticals', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'bydureon_family', 'Bydureon Family', 'Bydureon', 'EN', 'brand_sub_2', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'bydureon_family', 'Bydureon Family', 'Bydureon', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'bydureon_family', 'Bydureon Family', 'Bydureon Family', 'EN', 'brand_sub_2', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'bydureon_family', 'Bydureon Family', 'Bydureon Family', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'byetta_family', 'Byetta Family', 'Byetta', 'EN', 'brand_sub_2', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'byetta_family', 'Byetta Family', 'Byetta', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'byetta_family', 'Byetta Family', 'Byetta Family', 'EN', 'brand_sub_2', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'byetta_family', 'Byetta Family', 'Byetta Family', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'forxiga', 'Forxiga Extended Family', 'Forxiga', 'EN', 'brand', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'forxiga', 'Forxiga Extended Family', 'Forxiga', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'dapagliflozin', 'Forxiga Extended Family', 'Dapagliflozin', 'EN', 'brand', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'dapagliflozin', 'Forxiga Extended Family', 'Dapagliflozin', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'dapagliflozin', 'Forxiga Extended Family', 'Dapa', 'EN', 'brand', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'dapagliflozin', 'Forxiga Extended Family', 'Dapa', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'farxiga', 'Farxiga', 'Farxiga', 'EN', 'product_name', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'farxiga', 'Farxiga', 'Farxiga', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'edistride', 'Farxiga Partner Brand', 'EDISTRIDE', 'EN', 'product_name', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'edistride', 'Farxiga Partner Brand', 'EDISTRIDE', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'farxiga_partner_brand', 'Farxiga Partner Brand', 'Farxiga Partner Brand', 'EN', 'product_name', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'farxiga_partner_brand', 'Farxiga Partner Brand', 'Farxiga Partner Brand', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'farxiga_partner_brand', 'Farxiga Partner Brand', 'Forxiga 2nd brand', 'EN', 'product_name', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'farxiga_partner_brand', 'Farxiga Partner Brand', 'Forxiga 2nd brand', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'qtern', 'Qtern', 'Qtern', 'EN', 'product_name', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'qtern', 'Qtern', 'Qtern', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'xigduo', 'Xigduo', 'Xigduo', 'EN', 'product_name', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'xigduo', 'Xigduo', 'Xigduo', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'xigduo', 'Xigduo', 'XIGDUO IR/XR', 'EN', 'product_name', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'xigduo', 'Xigduo', 'XIGDUO IR/XR', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'sidapvia', 'Sidapvia', 'Sidapvia', 'EN', 'product_name', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'sidapvia', 'Sidapvia', 'Sidapvia', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'rilast_turbuhaler', 'RILAST TURBUHALER', 'RILAST TURBUHALER', 'EN', 'product_name', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'rilast_turbuhaler', 'RILAST TURBUHALER', 'RILAST TURBUHALER', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'rilast_turbuhaler', 'RILAST TURBUHALER', 'Symbicort 2nd brand', 'EN', 'product_name', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'rilast_turbuhaler', 'RILAST TURBUHALER', 'Symbicort 2nd brand', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'galvus', 'Galvus Family', 'Galvus', 'EN', 'brand', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'galvus', 'Galvus Family', 'Galvus', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'invokana', 'Invokana Family', 'Invokana', 'EN', 'brand', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'invokana', 'Invokana Family', 'Invokana', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'januvia', 'Januvia Family', 'Januvia', 'EN', 'brand', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'januvia', 'Januvia Family', 'Januvia', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'jardiance', 'Jardiance Family', 'Jardiance', 'EN', 'brand', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'jardiance', 'Jardiance Family', 'Jardiance', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'nesina', 'Nesina Family', 'Nesina', 'EN', 'brand', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'nesina', 'Nesina Family', 'Nesina', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'steglatro', 'Steglatro Family', 'Steglatro', 'EN', 'brand', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'steglatro', 'Steglatro Family', 'Steglatro', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'tradjenta', 'Tradjenta Family', 'Tradjenta', 'EN', 'brand', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'tradjenta', 'Tradjenta Family', 'Tradjenta', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'seloken/toprol-xl', 'Seloken/Toprol-XL', 'Seloken Family', 'EN', 'brand', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'seloken/toprol-xl', 'Seloken/Toprol-XL', 'Seloken Family', 'EN', 'product_cluster', 'product')
; --42

--total_product
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(brand_lv1),' ','_'), brand_lv1, brand_lv1, 'EN', 'total_product', 'product'
from dim_product dp
where nullif(brand_lv1,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'product' and upper(bsl.range_local_name) = upper(brand_lv1))
group by brand_lv1; --1
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(brand_lv1),' ','_'), brand_lv1, brand_lv1, 'EN', 'product_cluster', 'product'
from dim_product dp
where nullif(brand_lv1,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(brand_lv1))
group by brand_lv1; --1
--bu
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(brand_lv2),' ','_'), brand_lv2, brand_lv2, 'EN', 'bu', 'product'
from dim_product dp
where nullif(brand_lv2,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'product' and upper(bsl.range_local_name) = upper(brand_lv2))
group by brand_lv2; --4
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(brand_lv2),' ','_'), brand_lv2, brand_lv2, 'EN', 'product_cluster', 'product'
from dim_product dp
where nullif(brand_lv2,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(brand_lv2))
group by brand_lv2; --4
--ta
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(brand_lv3),' ','_'), brand_lv3, brand_lv3, 'EN', 'ta', 'product'
from dim_product dp
where nullif(brand_lv3,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'product' and upper(bsl.range_local_name) = upper(brand_lv3))
group by brand_lv3; --5
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(brand_lv3),' ','_'), brand_lv3, brand_lv3, 'EN', 'product_cluster', 'product'
from dim_product dp
where nullif(brand_lv3,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(brand_lv3))
group by brand_lv3; --5
--brand
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(brand_lv4),' ','_'), brand_lv4, brand_lv4, 'EN', 'brand', 'product'
from dim_product dp
where nullif(brand_lv4,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'product' and upper(bsl.range_local_name) = upper(brand_lv4))
group by brand_lv4; --61
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(brand_lv4),' ','_'), brand_lv4, brand_lv4, 'EN', 'product_cluster', 'product'
from dim_product dp
where nullif(brand_lv4,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(brand_lv4))
group by brand_lv4; --61
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(brand_lv4),' ','_'), brand_lv4, replace(brand_lv4,' Family',''), 'EN', 'brand', 'product'
from dim_product dp
where nullif(brand_lv4,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'product' and upper(bsl.range_local_name) = upper(replace(brand_lv4,' Family','')))
group by brand_lv4; --28
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(brand_lv4),' ','_'), brand_lv4, replace(brand_lv4,' Family',''), 'EN', 'product_cluster', 'product'
from dim_product dp
where nullif(brand_lv4,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(replace(brand_lv4,' Family','')))
group by brand_lv4; --28
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(brand_lv4),' ','_'), brand_lv4, dpm.product_name, 'EN', 'brand', 'product'
from dim_product dp
join dim_product_mapping dpm on dp.brand_lv4 = dpm.brand_mapping_value and dpm.brand_lvl = 'brand_lv4'
where nullif(brand_lv4,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'product' and upper(bsl.range_local_name) = upper(dpm.product_name))
group by brand_lv4, dpm.product_name;--5
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(brand_lv4),' ','_'), brand_lv4, dpm.product_name, 'EN', 'product_cluster', 'product'
from dim_product dp
join dim_product_mapping dpm on dp.brand_lv4 = dpm.brand_mapping_value and dpm.brand_lvl = 'brand_lv4'
where nullif(brand_lv4,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(dpm.product_name))
group by brand_lv4, dpm.product_name;--5

insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, replace(lower(international_product),' ','_'), international_product, international_product, 'EN', 'brand', 'product'
from iqvia_gmd_product igp
where nullif(international_product,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'product' and upper(bsl.range_local_name) = upper(international_product))
and gmd_sub_mkt in (select distinct pri_gmd_sub_mkt from dim_product)
group by international_product; --13694
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, replace(lower(international_product),' ','_'), international_product, international_product, 'EN', 'product_cluster', 'product'
from iqvia_gmd_product igp
where nullif(international_product,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(international_product))
and gmd_sub_mkt in (select distinct pri_gmd_sub_mkt from dim_product)
group by international_product; --13694
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, replace(lower(international_product),' ','_'), international_product, replace(international_product,' Family',''), 'EN', 'brand', 'product'
from iqvia_gmd_product igp
where replace(international_product,' Family','') <> international_product
and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'product' and upper(bsl.range_local_name) = upper(replace(international_product,' Family','')))
and gmd_sub_mkt in (select distinct pri_gmd_sub_mkt from dim_product)
group by international_product; --11
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, replace(lower(international_product),' ','_'), international_product, replace(international_product,' Family',''), 'EN', 'product_cluster', 'product'
from iqvia_gmd_product igp
where replace(international_product,' Family','') <> international_product
and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(replace(international_product,' Family','')))
and gmd_sub_mkt in (select distinct pri_gmd_sub_mkt from dim_product)
group by international_product; --11

insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, replace(lower(dp.brand_lv4),' ','_'), dp.brand_lv4, diibt.brand, 'EN', 'brand', 'product'
from dim_ireal_indication_brand_ta diibt
left join dim_product_mapping dpm on diibt.brand = dpm.product_name and dpm."source" = 'iREAL'
left join dim_product dp on dpm.brand_mapping_value = dp.product_code and dpm.brand_lvl = 'product_code'
where diibt.brand is not null
and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'product' and upper(bsl.range_local_name) = upper(diibt.brand))
group by dp.brand_lv4, diibt.brand;
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, replace(lower(dp.brand_lv4),' ','_'), dp.brand_lv4, diibt.brand, 'EN', 'product_cluster', 'product'
from dim_ireal_indication_brand_ta diibt
left join dim_product_mapping dpm on diibt.brand = dpm.product_name and dpm."source" = 'iREAL'
left join dim_product dp on dpm.brand_mapping_value = dp.product_code and dpm.brand_lvl = 'product_code'
where diibt.brand is not null
and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(diibt.brand))
group by dp.brand_lv4, diibt.brand;

--brand_sub_1
--insert into bi_scope_lookup
--select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(brand_lv5),' ','_'), brand_lv5, brand_lv5, 'EN', 'brand_sub_1', 'product'
--from dim_product dp
--where nullif(brand_lv5,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type='product' and upper(bsl.range_local_name) = upper(brand_lv5))
--group by brand_lv5; --27
--insert into bi_scope_lookup
--select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(brand_lv5),' ','_'), brand_lv5, replace(brand_lv5,' Family',''), 'EN', 'brand_sub_1', 'product'
--from dim_product dp
--where nullif(brand_lv5,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type='product' and upper(bsl.range_local_name) = upper(replace(brand_lv5,' Family','')))
--group by brand_lv5; --5
--insert into bi_scope_lookup
--select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(brand_lv5),' ','_'), brand_lv5, brand_lv5, 'EN', 'product_cluster', 'product'
--from dim_product dp
--where nullif(brand_lv5,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(brand_lv5))
--group by brand_lv5; --27
--insert into bi_scope_lookup
--select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(brand_lv5),' ','_'), brand_lv5, replace(brand_lv5,' Family',''), 'EN', 'product_cluster', 'product'
--from dim_product dp
--where nullif(brand_lv5,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(replace(brand_lv5,' Family','')))
--group by brand_lv5; --5
--brand_sub_2
--insert into bi_scope_lookup
--select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(brand_lv6),' ','_'), brand_lv6, brand_lv6, 'EN', 'brand_sub_2', 'product'
--from dim_product dp
--where nullif(brand_lv6,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type='product' and upper(bsl.range_local_name) = upper(brand_lv6))
--group by brand_lv6; --340
--insert into bi_scope_lookup
--select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(brand_lv6),' ','_'), brand_lv6, replace(brand_lv6,' Family',''), 'EN', 'brand_sub_1', 'product'
--from dim_product dp
--where nullif(brand_lv6,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type='product' and upper(bsl.range_local_name) = upper(replace(brand_lv6,' Family','')))
--group by brand_lv6; --5
--insert into bi_scope_lookup
--select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(brand_lv6),' ','_'), brand_lv6, brand_lv6, 'EN', 'product_cluster', 'product'
--from dim_product dp
--where nullif(brand_lv6,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(brand_lv6))
--group by brand_lv6; --340
--insert into bi_scope_lookup
--select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(brand_lv5),' ','_'), brand_lv5, replace(brand_lv5,' Family',''), 'EN', 'product_cluster', 'product'
--from dim_product dp
--where nullif(brand_lv5,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(replace(brand_lv5,' Family','')))
--group by brand_lv5; --5
--product_name
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(product_description),' ','_'), product_description, product_description, 'EN', 'product_name', 'product'
from dim_product dp
where nullif(product_description,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type='product' and upper(bsl.range_local_name) = upper(product_description))
group by product_description; --389
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(product_description),' ','_'), product_description, product_description, 'EN', 'product_cluster', 'product'
from dim_product dp
where nullif(product_description,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(product_description))
group by product_description; --389
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, replace(lower(international_product_raw),' ','_'), international_product_raw, international_product_raw, 'EN', 'product_name', 'product'
from iqvia_gmd_product igp
where gmd_sub_mkt = 'iOAD Total' and international_product_raw <> international_product
and nullif(international_product_raw,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.type = 'product' and upper(bsl.range_local_name) = upper(international_product_raw))
group by international_product_raw; --2455
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, replace(lower(international_product_raw),' ','_'), international_product_raw, international_product_raw, 'EN', 'product_cluster', 'product'
from iqvia_gmd_product igp
where gmd_sub_mkt = 'iOAD Total' and international_product_raw <> international_product
and nullif(international_product_raw,'') is not null and not exists (select 1 from bi_scope_lookup bsl where bsl.level = 'product_cluster' and upper(bsl.range_local_name) = upper(international_product_raw))
group by international_product_raw; --2457

--corporation
delete from bi_scope_lookup where level = 'corporation';
insert into bi_scope_lookup
values
(gen_random_uuid(), NOW(), NOW(), NULL, 'boehringer_ingel', 'BOEHRINGER INGEL', 'Boehringer Ingelheim', 'EN', 'corporation', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'boehringer_ingel', 'BOEHRINGER INGEL', 'Boehringer Ingelheim', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'boehringer_ingel', 'BOEHRINGER INGEL', 'B.I.', 'EN', 'corporation', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'boehringer_ingel', 'BOEHRINGER INGEL', 'B.I.', 'EN', 'product_cluster', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'gilead_sciences', 'GILEAD SCIENCES', 'Gilead', 'EN', 'corporation', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'gilead_sciences', 'GILEAD SCIENCES', 'Gilead', 'EN', 'product_cluster', 'product')
;
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(corporation),' ','_'), corporation, corporation, 'EN', 'corporation', 'product'
from fact_iqvia_qtr_corp_rnk f
where not exists (select 1 from bi_scope_lookup where type='product' and upper(range_local_name) = upper(f.corporation))
and f.us_dollars_actual > 0 and f.period >= '2024-01-01'
group by corporation; --12578
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(corporation),' ','_'), corporation, corporation, 'EN', 'corporation', 'product'
from fact_iqvia_qtr_gmd_ms f
where not exists (select 1 from bi_scope_lookup where type='product' and upper(range_local_name) = upper(f.corporation))
and f.us_dollars_actual > 0 and to_date(f.period,'dd/mm/yyyy') >= '2024-01-01'
group by corporation; --1294
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(corporation),' ','_'), corporation, corporation, 'EN', 'corporation', 'product'
from fact_iqvia_mth_gmd_ms f
where not exists (select 1 from bi_scope_lookup where type='product' and upper(range_local_name) = upper(f.corporation))
and f.us_dollars_actual > 0 and to_date(f.period,'dd/mm/yyyy') >= '2024-01-01'
group by corporation; --0
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(corporation),' ','_'), corporation, corporation, 'EN', 'product_cluster', 'product'
from fact_iqvia_qtr_corp_rnk f
where not exists (select 1 from bi_scope_lookup where level='product_cluster' and upper(range_local_name) = upper(f.corporation))
and f.us_dollars_actual > 0 and f.period >= '2024-01-01'
group by corporation; --12576
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(corporation),' ','_'), corporation, corporation, 'EN', 'product_cluster', 'product'
from fact_iqvia_qtr_gmd_ms f
where not exists (select 1 from bi_scope_lookup where level='product_cluster' and upper(range_local_name) = upper(f.corporation))
and f.us_dollars_actual > 0 and to_date(f.period,'dd/mm/yyyy') >= '2024-01-01'
group by corporation; --1293
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(corporation),' ','_'), corporation, corporation, 'EN', 'product_cluster', 'product'
from fact_iqvia_mth_gmd_ms f
where not exists (select 1 from bi_scope_lookup where level='product_cluster' and upper(range_local_name) = upper(f.corporation))
and f.us_dollars_actual > 0 and to_date(f.period,'dd/mm/yyyy') >= '2024-01-01'
group by corporation; --0

--indication
delete from bi_scope_lookup where level = 'indication';
insert into bi_scope_lookup
values
(gen_random_uuid(), NOW(), NOW(), NULL, 'imfinzi_+-_treme_hcc_1l_(himalaya)', 'Imfinzi +- treme HCC 1L (HIMALAYA)', 'HIMALAYA', 'EN', 'indication', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'sle', 'SLE', 'SLE', 'EN', 'indication', 'product'),
(gen_random_uuid(), NOW(), NOW(), NULL, 'rsv', 'RSV', 'RSV', 'EN', 'indication', 'product')
;
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(indication),' ','_'), indication, indication, 'EN', 'indication', 'product'
from fact_ireal_metric f
where not exists (select 1 from bi_scope_lookup where type='product' and upper(range_local_name) = upper(f.indication))
group by indication;--114
        --study
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(max(f.indication)),' ','_'), max(f.indication), d.study, 'EN', 'indication', 'product'
from fact_ireal_metric f
join dim_ireal_indication_brand_ta d on f.indication = d.indication
where not exists (select 1 from bi_scope_lookup where type='product' and upper(range_local_name) = upper(d.study)) and d.study is not null
group by d.study having count(distinct f.indication) = 1;--93
        --brand-study,
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(f.indication),' ','_'), f.indication, max(d.brand||'_'||d.study), 'EN', 'indication', 'product'
from fact_ireal_metric f
join dim_ireal_indication_brand_ta d on f.indication = d.indication
where not exists (select 1 from bi_scope_lookup where type='product' and upper(range_local_name) = upper(d.brand||'_'||d.study)) and d.study is not null
group by f.indication;--96
        --brand-indication,
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(f.indication),' ','_'), f.indication, max(d.brand||' '||replace(d.indication,d.brand||' ','')), 'EN', 'indication', 'product'
from fact_ireal_metric f
join dim_ireal_indication_brand_ta d on f.indication = d.indication
where not exists (select 1 from bi_scope_lookup where type='product' and upper(range_local_name) = upper(d.brand||' '||replace(d.indication,d.brand||' ','')) )
group by f.indication;--58
        --study-indication (no need, study already in indication)
--product_market
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(gmd_sub_mkt),' ','_'), gmd_sub_mkt, gmd_sub_mkt, 'EN', 'product_market', 'product'
from iqvia_gmd_product igp
where nullif(gmd_sub_mkt,'') is not null and not exists (select 1 from bi_scope_lookup bsl where type='product' and upper(bsl.range_local_name) = upper(gmd_sub_mkt))
group by gmd_sub_mkt; --37
--exclude_covid
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL,
replace(lower(ex_covid::text),' ','_'), ex_covid, ex_covid, 'EN', 'exclude_covid', 'product'  from dim_product dp
group by ex_covid;--2

-- 2.2 keep product aliases in old DBV records
insert into bi_scope_lookup
select min(bsla.id::text)::uuid as id, min(bsla.created_at) as created_at, now() as updated_at, null as deleted_at, min(bsla.range_external_id) as range_external_id, bsla.range_standard_name, bsla.range_local_name, min(bsla.local_language) as local_language, bsla."level", bsla."type" from bi_scope_lookup_arc bsla
join bi_scope_lookup bsl1 on bsla."level" = bsl1."level" and bsla."type" = bsl1."type" and bsla.range_standard_name = bsl1.range_standard_name
where bsla.type = 'product'
and not exists (select 1 from bi_scope_lookup bsl where bsla."type" = bsl."type" and upper(bsla.range_local_name) = upper(bsl.range_local_name))
group by bsla.range_standard_name, bsla.range_local_name, bsla."level", bsla."type"; --150
insert into bi_scope_lookup
select gen_random_uuid() as id, min(bsla.created_at) as created_at, now() as updated_at, null as deleted_at, min(bsla.range_external_id) as range_external_id, bsla.range_standard_name, bsla.range_local_name, min(bsla.local_language) as local_language, bsla."level", bsla."type" from bi_scope_lookup_arc bsla
join bi_scope_lookup bsl1 on bsla."level" = bsl1."level" and bsla."type" = bsl1."type" and bsla.range_standard_name = bsl1.range_standard_name
where bsla.level = 'product_cluster'
and not exists (select 1 from bi_scope_lookup bsl where bsla.level = bsl.level and upper(bsla.range_local_name) = upper(bsl.range_local_name))
group by bsla.range_standard_name, bsla.range_local_name, bsla."level", bsla."type"; --150

RAISE NOTICE 'Build bi_scope_lookup Step2 - Product done';

-- 3. market_access Setup
--regulatory_approval_status
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(regulatory_approval_status),' ','_'), regulatory_approval_status, regulatory_approval_status, 'EN', 'regulatory_approval_status', 'market_access'
from fact_ireal_mainlist_raw
where regulatory_approval_status is not null
group by regulatory_approval_status; --5
--commercial_launch_status
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(commercial_launch_status),' ','_'), commercial_launch_status, commercial_launch_status, 'EN', 'commercial_launch_status', 'market_access'
from fact_ireal_mainlist_raw
where commercial_launch_status is not null
group by commercial_launch_status; --3
--public_national_reimbursement_approval_status
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(public_national_reimbursement_approval_status),' ','_'), public_national_reimbursement_approval_status, public_national_reimbursement_approval_status, 'EN', 'public_national_reimbursement_approval_status', 'market_access'
from fact_ireal_mainlist_raw
where public_national_reimbursement_approval_status is not null
group by public_national_reimbursement_approval_status; --5
--diagnostic_reimbursement_approval_status
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(diagnostic_reimbursement_approval_status),' ','_'), diagnostic_reimbursement_approval_status, diagnostic_reimbursement_approval_status, 'EN', 'diagnostic_reimbursement_approval_status', 'market_access'
from fact_ireal_mainlist_raw
where diagnostic_reimbursement_approval_status is not null
group by diagnostic_reimbursement_approval_status; --5
--gpi_pricing_approval_status
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(gpi_pricing_approval_status),' ','_'), gpi_pricing_approval_status, gpi_pricing_approval_status, 'EN', 'gpi_pricing_approval_status', 'market_access'
from fact_ireal_mainlist_raw
where gpi_pricing_approval_status is not null
group by gpi_pricing_approval_status; --6
--private_insurance_approval_status
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(private_insurance_approval_status),' ','_'), private_insurance_approval_status, private_insurance_approval_status, 'EN', 'private_insurance_approval_status', 'market_access'
from fact_ireal_mainlist_raw
where private_insurance_approval_status is not null
group by private_insurance_approval_status; --4
--institution1_reimbursement_approval_status
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower("institution_#1_reimbursement_approval_status"),' ','_'), "institution_#1_reimbursement_approval_status", "institution_#1_reimbursement_approval_status", 'EN', 'institution1_reimbursement_approval_status', 'market_access'
from fact_ireal_mainlist_raw
where "institution_#1_reimbursement_approval_status" is not null
group by "institution_#1_reimbursement_approval_status"; --5
--institution2_reimbursement_approval_status
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower("institution_#2_reimbursement_approval_status"),' ','_'), "institution_#2_reimbursement_approval_status", "institution_#2_reimbursement_approval_status", 'EN', 'institution2_reimbursement_approval_status', 'market_access'
from fact_ireal_mainlist_raw
where "institution_#2_reimbursement_approval_status" is not null
group by "institution_#2_reimbursement_approval_status"; --4
--institution3_reimbursement_approval_status
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower("institution_#3_reimbursement_approval_status"),' ','_'), "institution_#3_reimbursement_approval_status", "institution_#3_reimbursement_approval_status", 'EN', 'institution3_reimbursement_approval_status', 'market_access'
from fact_ireal_mainlist_raw
where "institution_#3_reimbursement_approval_status" is not null
group by "institution_#3_reimbursement_approval_status"; --5
--pap_availability
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(pap_availability),' ','_'), pap_availability, pap_availability, 'EN', 'pap_availability', 'market_access'
from fact_ireal_mainlist_raw
where pap_availability is not null
group by pap_availability; --4
--ivs_availability
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(ivs_availability),' ','_'), ivs_availability, ivs_availability, 'EN', 'ivs_availability', 'market_access'
from fact_ireal_mainlist_raw
where ivs_availability is not null
group by ivs_availability; --4
--bridging_program_availability
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(bridging_program_availability),' ','_'), bridging_program_availability, bridging_program_availability, 'EN', 'bridging_program_availability', 'market_access'
from fact_ireal_mainlist_raw
where bridging_program_availability is not null
group by bridging_program_availability; --4
--last_updated_by
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(last_updated_by),' ','_'), last_updated_by, last_updated_by, 'EN', 'last_updated_by', 'market_access'
from fact_ireal_mainlist_raw
where last_updated_by is not null
group by last_updated_by; --121
--modified_by
insert into bi_scope_lookup
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, NULL, replace(lower(modified_by),' ','_'), modified_by, modified_by, 'EN', 'modified_by', 'market_access'
from fact_ireal_mainlist_raw
where modified_by is not null
group by modified_by; --89

------------------------------------------------------------------------------------------------
-- 3.2 keep manually inserted DBV records from Archive table
insert into bi_scope_lookup
select distinct bsla.* from bi_scope_lookup_arc bsla
join bi_scope_lookup bsl on bsla.range_standard_name = bsl.range_standard_name and bsla."level" = bsl."level" and bsla."type" = bsl."type"
where bsla.type = 'market_access' and bsl.range_local_name <> bsla.range_local_name
and not exists (select 1 from bi_scope_lookup where type = 'market_access' and upper(range_local_name) = upper(bsla.range_local_name)); --23

RAISE NOTICE 'Build bi_scope_lookup Step3 - market_access done';

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
drop table if exists bi_scope_affiliation;

CREATE TABLE bi_scope_affiliation (
        id uuid NOT NULL,
        created_at timestamptz NOT NULL,
        updated_at timestamptz NOT NULL,
        deleted_at timestamptz NULL,
        scope1_type varchar(255) NOT NULL,
        scope1_level varchar(255) NOT NULL,
        scope1_range_std_name varchar(255) NOT NULL,
        scope2_type varchar(255) NOT NULL,
        scope2_level varchar(255) NOT NULL,
        scope2_range_std_name varchar(255) NOT NULL,
        relation varchar(255) NOT NULL,
        CONSTRAINT bi_scope_affiliation_pkey PRIMARY KEY (id)
);

RAISE NOTICE 'Backup and re-create bi_scope_affiliation done';

-- 1) Brand to Market
INSERT INTO bi_scope_affiliation (id, created_at, updated_at, deleted_at, scope1_type, scope1_level, scope1_range_std_name, scope2_type, scope2_level, scope2_range_std_name, relation)
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, 'product', 'brand', dp.brand_lv4, 'product', 'product_market', fimgm.gmd_sub_mkt,'cascade'
from iqvia_gmd_product fimgm
join dim_product_mapping dpm on fimgm.international_product = dpm.product_name and dpm."source" = 'IQVIA'
join dim_product dp on dpm.brand_mapping_value = (case dpm.brand_lvl when 'brand_lv4' then dp.brand_lv4 when 'brand_lv5' then dp.brand_lv5 when 'brand_lv6' then dp.brand_lv6 when 'product_code' then dp.product_code end)
where dp.pri_gmd_sub_mkt = fimgm.gmd_sub_mkt
and not exists (select 1 from bi_scope_affiliation where scope1_range_std_name = dp.brand_lv4 and scope2_range_std_name = fimgm.gmd_sub_mkt)
and dp.brand_lv4 is not null and fimgm.gmd_sub_mkt is not null
group by dp.brand_lv4, fimgm.gmd_sub_mkt; --25

INSERT INTO bi_scope_affiliation (id, created_at, updated_at, deleted_at, scope1_type, scope1_level, scope1_range_std_name, scope2_type, scope2_level, scope2_range_std_name, relation)
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, 'product', 'brand', international_product, 'product', 'product_market', gmd_sub_mkt,'cascade'
from iqvia_gmd_product fimgm
where gmd_sub_mkt in (select distinct pri_gmd_sub_mkt from dim_product where pri_gmd_sub_mkt is not null)
and not exists (select 1 from bi_scope_affiliation where scope1_range_std_name = international_product and scope2_range_std_name = gmd_sub_mkt)
group by international_product, gmd_sub_mkt;--14259

RAISE NOTICE 'Build bi_scope_affiliation Step1 Brand to Market done';

-- 2) brand_sub_2 to Market
INSERT INTO bi_scope_affiliation (id, created_at, updated_at, deleted_at, scope1_type, scope1_level, scope1_range_std_name, scope2_type, scope2_level, scope2_range_std_name, relation)
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, 'product', 'brand_sub_2', dp.brand_lv6, 'product', 'product_market', fimgm.gmd_sub_mkt,'cascade'
from iqvia_gmd_product fimgm
join dim_product_mapping dpm on fimgm.international_product = dpm.product_name and dpm."source" = 'IQVIA'
join dim_product dp on dpm.brand_mapping_value = dp.brand_lv6 --and dpm.brand_lvl = 'brand_lv6'
where dp.pri_gmd_sub_mkt = fimgm.gmd_sub_mkt
and not exists (select 1 from bi_scope_affiliation where scope1_range_std_name = dp.brand_lv6 and scope2_range_std_name = fimgm.gmd_sub_mkt)
and dp.brand_lv6 is not null and fimgm.gmd_sub_mkt is not null
group by dp.brand_lv6, fimgm.gmd_sub_mkt; --2

RAISE NOTICE 'Build bi_scope_affiliation Step2 brand_sub_2 to Market done';

-- 3) Product_name to Market
INSERT INTO bi_scope_affiliation (id, created_at, updated_at, deleted_at, scope1_type, scope1_level, scope1_range_std_name, scope2_type, scope2_level, scope2_range_std_name, relation) values
(gen_random_uuid(), now(), now(), null, 'product', 'product_name', 'RILAST TURBUHALER', 'product', 'product_market', 'ICS/LABA', 'cascade'),
(gen_random_uuid(), now(), now(), null, 'product', 'product_name', 'Sidapvia', 'product', 'product_market', 'iOAD Total', 'cascade'),
(gen_random_uuid(), now(), now(), null, 'product', 'product_name', 'Qtern', 'product', 'product_market', 'iOAD Total', 'cascade'),
(gen_random_uuid(), now(), now(), null, 'product', 'product_name', 'Xigduo', 'product', 'product_market', 'iOAD Total', 'cascade');

INSERT INTO bi_scope_affiliation (id, created_at, updated_at, deleted_at, scope1_type, scope1_level, scope1_range_std_name, scope2_type, scope2_level, scope2_range_std_name, relation)
select gen_random_uuid() as id, NOW() as created_at, NOW() as updated_at, null as deleted_at, 'product', 'product_name', dp.product_description, 'product', 'product_market', fimgm.gmd_sub_mkt,'cascade'
from iqvia_gmd_product fimgm
join dim_product_mapping dpm on fimgm.international_product_raw = dpm.product_name and dpm."source" = 'IQVIA'
join dim_product dp on dpm.brand_mapping_value = dp.product_code --and dpm.brand_lvl = 'product_code'
where dp.pri_gmd_sub_mkt = fimgm.gmd_sub_mkt
and not exists (select 1 from bi_scope_affiliation where scope1_range_std_name = dp.product_description and scope2_range_std_name = fimgm.gmd_sub_mkt)
and dp.product_description is not null and fimgm.gmd_sub_mkt is not null
group by dp.product_description, fimgm.gmd_sub_mkt; --2

RAISE NOTICE 'Build bi_scope_affiliation Step3 Product_name to Market done';

END;
$procedure$
;

-- DROP PROCEDURE public.proc_refresh_bi_source_table_info();

CREATE OR REPLACE PROCEDURE public.proc_refresh_bi_source_table_info()
 LANGUAGE plpgsql
AS $procedure$

BEGIN

--=============================================================================================================================
-- bi_source_table_info
--=============================================================================================================================
RAISE NOTICE 'Refresh bi_source_table_info started';

drop table if exists bi_source_table_info_arc;
create table bi_source_table_info_arc as select * from bi_source_table_info;

RAISE NOTICE 'Backup and re-create bi_source_table_info done';

update bi_source_table_info 
set last_available_cycle = a.to_period, 
    first_available_cycle = a.from_period, 
    last_updated_at = now()
from (
    select 
        to_char(max(dc."date"), 'yyyy/mm') as to_period, 
        to_char(min(dc."date"), 'yyyy/mm') as from_period 
    from fact_propel_sales_external fpse 
    join dim_calendar dc 
        on fpse."period" || ', ' || fpse.years = dc.month_text_long 
        and dc.day_of_month_num = 1
    where fpse.act > 0
) a
where table_name = 'fact_propel_sales_external';

update bi_source_table_info 
set last_available_cycle = a.to_period, 
    last_updated_at = now()
from (
    select 
        to_char(max(dc."date"), 'yyyy/mm') as to_period
    from fact_propel_target_external fpte 
    join dim_calendar dc 
        on fpte."period" || ', ' || fpte.years = dc.month_text_long 
        and dc.day_of_month_num = 1
    where fpte.bud > 0
) a
where table_name = 'fact_propel_target_external';

update bi_source_table_info 
set last_available_cycle = a.to_period, 
    first_available_cycle = a.from_period, 
    last_updated_at = now()
from (
    select 
        to_char(max(dc."date"), 'yyyy/mm') as to_period, 
        to_char(min(dc."date"), 'yyyy/mm') as from_period 
    from fact_iqvia_mth_gmd_ms f 
    join dim_calendar dc 
        on f."period" = dc.date_text1
    where f.us_dollars_actual > 0
) a
where table_name = 'fact_iqvia_mth_gmd_ms';

update bi_source_table_info 
set last_available_cycle = a.to_period, 
    first_available_cycle = a.from_period, 
    last_updated_at = now()
from (
    select 
        to_char(max(dc."date"), 'yyyy/mm') as to_period, 
        to_char(min(dc."quarter_start_date"), 'yyyy/mm') as from_period 
    from fact_iqvia_qtr_gmd_ms f 
    join dim_calendar dc 
        on f."period" = dc.date_text1
    where f.us_dollars_actual > 0
) a
where table_name = 'fact_iqvia_qtr_gmd_ms';

update bi_source_table_info 
set last_available_cycle = a.to_period, 
    first_available_cycle = a.from_period, 
    last_updated_at = now()
from (
    select 
        to_char(max(dc."date"), 'yyyy/mm') as to_period, 
        to_char(min(dc."quarter_start_date"), 'yyyy/mm') as from_period 
    from fact_iqvia_qtr_corp_rnk f 
    join dim_calendar dc 
        on f."period" = dc."date"
    where f.us_dollars_actual > 0
) a
where table_name = 'fact_iqvia_qtr_corp_rnk';

update bi_source_table_info 
set last_updated_at = now()
where table_name = 'fact_ireal_metric';

RAISE NOTICE 'Refresh bi_source_table_info done';

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

drop table if exists agg_ta_permission;
create temp table agg_ta_permission as 
select
        dp.brand_lv3 as ta,
        dp.brand_lv4 as products,
        dp.pri_gmd_sub_mkt as markets,
        null as competitor_cpa,
        null as competitor_ims
from dim_product dp
where dp.brand_lv4 is not null
group by dp.brand_lv3, dp.brand_lv4, dp.pri_gmd_sub_mkt
union
select
        dp.brand_lv3,
        null as products,
        igp.gmd_sub_mkt as markets,
        null as competitor_cpa,
        null as competitor_ims        
from iqvia_gmd_product igp 
left join dim_product_mapping dpm on igp.therapy_area = dpm.product_name and dpm."source" = 'IQVIA' and dpm.brand_lvl = 'brand_lv3'
left join dim_product dp on dpm.brand_mapping_value = dp.brand_lv3
group by dp.brand_lv3, igp.gmd_sub_mkt; --99

drop table if exists bi_user_profile_to_refresh;
create table bi_user_profile_to_refresh as
with bup as 
(select *, unnest(ta) AS element 
from bi_user_profile)
select 
        bup.unique_code, 
        bup.user_name, 
        bup.ta,
        array_agg(distinct abp.products)filter(where abp.products is not null) as products,
        array_agg(distinct abp.markets)filter(where abp.markets is not null) as markets,
        null as competitor_cpa,
        null as competitor_ims
from bup
join agg_ta_permission abp on bup.element = abp.ta
group by bup.unique_code, bup.user_name, bup.ta; --31

RAISE NOTICE 'Refresh bi_user_profile Step1 - by TA done';

update bi_user_profile bup
set
        products = coalesce(tr.products, '{}'),
        markets = coalesce(tr.markets, '{}')
from bi_user_profile_to_refresh tr 
where bup.unique_code = tr.unique_code
;

RAISE NOTICE 'bi_user_profile refresh done';

END;
$procedure$
;


-- DROP PROCEDURE public.proc_cleanse_bi_dynamic_kpi_rule();

CREATE OR REPLACE PROCEDURE public.proc_cleanse_bi_dynamic_kpi_rule()
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    v_all_geos JSONB;
    v_current_geo_level TEXT;
    v_geo TEXT;
    v_geo_lvl4 TEXT;
    v_data_source TEXT;
    v_brand TEXT;
    v_value_type TEXT;
    v_brand_level TEXT;
    v_market TEXT;
    v_kpi TEXT;
    v_kpi_key TEXT;
    v_suffix TEXT;
    v_product_name TEXT;
    v_product_code TEXT;
    v_all_sub_market TEXT[];
    v_type_kpi_preference JSONB;
    v_brand_market_cache JSONB;
    v_product_code_cache JSONB;
    v_geo_list JSONB;

    -- 动态配置字典 --
    v_product_type_dict JSONB;
    v_product_name_type_dict JSONB;
    v_product_datasource_dict JSONB;
    v_geo_lvl1_type_preference JSONB;
    v_geo_lvl2_type_preference JSONB;
    v_geo_lvl3_type_preference JSONB;
    v_geo_lvl4_type_preference JSONB;

    -- 临时记录类型 --
    tmp_rec RECORD;
BEGIN
    -- 原子化表结构变更 --
    BEGIN
        DROP TABLE IF EXISTS bi_dynamic_kpi_rule_arc CASCADE;
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'bi_dynamic_kpi_rule') THEN
            ALTER TABLE bi_dynamic_kpi_rule
                RENAME CONSTRAINT bi_dynamic_kpi_rule_pkey TO bi_dynamic_kpi_rule_arc_pkey;
            ALTER TABLE bi_dynamic_kpi_rule
                RENAME TO bi_dynamic_kpi_rule_arc;
        END IF;

        CREATE TABLE bi_dynamic_kpi_rule (
            id uuid PRIMARY KEY,
            created_at timestamptz NOT NULL,
            updated_at timestamptz NOT NULL,
            deleted_at timestamptz NULL,
            "type" varchar(20) NOT NULL,
            geo_name varchar(50) NOT NULL,
            geo_lvl varchar(20) NOT NULL,
            product_name varchar(50) NOT NULL,
            product_lvl varchar(20) NOT NULL,
            product_market_name varchar(50) NOT NULL,
            product_market_lvl varchar(20) NOT NULL,
            kpi_type varchar(50) NOT NULL,
            kpi_key_preference text NOT NULL
        );

        INSERT INTO public.bi_dynamic_kpi_rule
        (id, created_at, updated_at, deleted_at, "type", geo_name, geo_lvl, product_name, product_lvl, product_market_name, product_market_lvl, kpi_type, kpi_key_preference)
        VALUES
        ('18071af4-a9cd-4be0-8ba7-33fa27dfa96d'::uuid, '2024-07-17 11:06:32.667', '2024-07-17 11:06:32.667', NULL, 'int_sales_to_ext', 'all', 'all', 'external_product', 'brand_lv4', 'all', 'all', 'yoy_sales_growth_in_value', 'yoy_sales_growth_in_market_in_value'),
        ('6c74491c-2a0c-4a90-81b3-3a4494c8ddec'::uuid, '2024-07-17 11:06:32.667', '2024-07-17 11:06:32.667', NULL, 'int_sales_to_ext', 'all', 'all', 'external_product', 'brand_lv4', 'all', 'all', 'yoy_sales_growth_percentage_in_volume', 'yoy_sales_growth_percentage_in_market_in_volume'),
        ('93d6e5e0-0609-4532-83c7-af26deecbe6e'::uuid, '2024-07-17 11:06:32.667', '2024-07-17 11:06:32.667', NULL, 'int_sales_to_ext', 'all', 'all', 'external_product', 'brand_lv4', 'all', 'all', 'yoy_sales_growth_percentage_in_value', 'yoy_sales_growth_percentage_in_market_in_value'),
        ('e2c3c84c-51e6-4039-94ed-8b739dafe804'::uuid, '2024-07-17 09:40:24.018', '2024-07-17 09:40:24.018', NULL, 'int_sales_to_ext', 'all', 'all', 'external_product', 'brand_lv4', 'all', 'all', 'sales_in_volume', 'sales_in_market_in_volume'),
        ('fa24e8bf-6acc-43f6-a920-6e6bdcf0af59'::uuid, '2024-07-17 09:40:24.018', '2024-07-17 09:40:24.018', NULL, 'int_sales_to_ext', 'all', 'all', 'external_product', 'brand_lv4', 'all', 'all', 'sales_in_value', 'sales_in_market_in_value'),
        ('fc7e61ba-13be-465c-9fbc-077c08bd33b7'::uuid, '2024-07-17 11:06:32.667', '2024-07-17 11:06:32.667', NULL, 'int_sales_to_ext', 'all', 'all', 'external_product', 'brand_lv4', 'all', 'all', 'yoy_sales_growth_in_volume', 'yoy_sales_growth_in_market_in_volume'),
        ('fa24e8bf-6acc-43f6-a920-6e6bdcf0af5a'::uuid, '2024-07-17 09:40:24.018', '2024-07-17 09:40:24.018', NULL, 'int_sales_to_ext', 'all', 'all', 'external_product', 'product_name', 'all', 'all', 'sales_in_value', 'sales_in_market_in_value'),
        ('e2c3c84c-51e6-4039-94ed-8b739dafe80b'::uuid, '2024-07-17 09:40:24.018', '2024-07-17 09:40:24.018', NULL, 'int_sales_to_ext', 'all', 'all', 'external_product', 'product_name', 'all', 'all', 'sales_in_volume', 'sales_in_market_in_volume'),
        ('18071af4-a9cd-4be0-8ba7-33fa27dfa96c'::uuid, '2024-07-17 11:06:32.667', '2024-07-17 11:06:32.667', NULL, 'int_sales_to_ext', 'all', 'all', 'external_product', 'product_name', 'all', 'all', 'yoy_sales_growth_in_value', 'yoy_sales_growth_in_market_in_value'),
        ('fc7e61ba-13be-465c-9fbc-077c08bd33bd'::uuid, '2024-07-17 11:06:32.667', '2024-07-17 11:06:32.667', NULL, 'int_sales_to_ext', 'all', 'all', 'external_product', 'product_name', 'all', 'all', 'yoy_sales_growth_in_volume', 'yoy_sales_growth_in_market_in_volume'),
        ('93d6e5e0-0609-4532-83c7-af26deecbe6f'::uuid, '2024-07-17 11:06:32.667', '2024-07-17 11:06:32.667', NULL, 'int_sales_to_ext', 'all', 'all', 'external_product', 'product_name', 'all', 'all', 'yoy_sales_growth_percentage_in_value', 'yoy_sales_growth_percentage_in_market_in_value'),
        ('6c74491c-2a0c-4a90-81b3-3a4494c8ddee'::uuid, '2024-07-17 11:06:32.667', '2024-07-17 11:06:32.667', NULL, 'int_sales_to_ext', 'all', 'all', 'external_product', 'product_name', 'all', 'all', 'yoy_sales_growth_percentage_in_volume', 'yoy_sales_growth_percentage_in_market_in_volume');

    EXCEPTION
        WHEN others THEN
            RAISE EXCEPTION '表结构变更失败: %', SQLERRM;
    END;

    -- 动态加载产品类型配置（显式别名）--
    SELECT jsonb_object_agg(brand_lv4,
    CASE
        WHEN brand_lv4 IN ('Arimidex Family','Casodex Family','Enhertu Family','Faslodex Family','Imfinzi','Lynparza Family','Synagis Family','Zoladex')
        THEN 'in_value'
        ELSE 'in_volume'
    END
) INTO v_product_type_dict
FROM (
    SELECT DISTINCT brand_lv4
    FROM dim_product
    WHERE brand_lv4 IN (
        'Airsupra','Arimidex Family','Breztri Family','Brilinta Family',
        'Calquence','Casodex Family','Crestor Family','Enhertu Family',
        'Exenatide Family','Fasenra Family','Faslodex Family',
        'Forxiga Extended Family','Imfinzi','Lokelma','Losec Family',
        'Lynparza Family','Nexium Family','Onglyza Family','Pulmicort Family',
        'Saphnelo Family','Seloken/Toprol-XL','Symbicort Family','Synagis Family',
        'Tagrisso','Tezspire Family','Zoladex'
    )
) t;

    -- 特殊品牌分流处理 --
    IF v_product_type_dict ? 'Exenatide Family' THEN
        v_product_type_dict := v_product_type_dict - 'Exenatide Family' ||
            '{"Bydureon Family": "in_volume", "Byetta Family": "in_volume"}'::JSONB;
    END IF;

    -- 加载产品名称类型配置 --
    SELECT jsonb_object_agg(product_description, 'in_volume') INTO v_product_name_type_dict
    FROM dim_product
    WHERE product_description IN (
        'RILAST TURBUHALER','Farxiga Partner Brand','Sidapvia',
        'Qtern','Xigduo','Symbicort 2nd Brand','Farxiga'
    );

    -- 加载数据源配置 --
    SELECT jsonb_object_agg(product, datasource) INTO v_product_datasource_dict
    FROM (
        SELECT 'Airsupra' AS product, 'M' AS datasource UNION ALL
        SELECT 'Arimidex Family', 'M' UNION ALL
        SELECT 'Breztri Family', 'M' UNION ALL
        SELECT 'Brilinta Family', 'M' UNION ALL
        SELECT 'Calquence', 'M' UNION ALL
        SELECT 'Casodex Family', 'Q' UNION ALL
        SELECT 'Crestor Family', 'M' UNION ALL
        SELECT 'Enhertu Family', 'M' UNION ALL
        SELECT 'Exenatide Family', 'M' UNION ALL
        SELECT 'Fasenra Family', 'M' UNION ALL
        SELECT 'Faslodex Family', 'M' UNION ALL
        SELECT 'Forxiga Extended Family', 'M' UNION ALL
        SELECT 'Imfinzi', 'M' UNION ALL
        SELECT 'Lokelma', 'M' UNION ALL
        SELECT 'Losec Family', 'Q' UNION ALL
        SELECT 'Lynparza Family', 'M' UNION ALL
        SELECT 'Nexium Family', 'Q' UNION ALL
        SELECT 'Onglyza Family', 'M' UNION ALL
        SELECT 'Pulmicort Family', 'M' UNION ALL
        SELECT 'Saphnelo Family', 'M' UNION ALL
        SELECT 'Seloken/Toprol-XL', 'Q' UNION ALL
        SELECT 'Symbicort Family', 'M' UNION ALL
        SELECT 'Tagrisso', 'M' UNION ALL
        SELECT 'Tezspire Family', 'M' UNION ALL
        SELECT 'Zoladex', 'Q' UNION ALL
        SELECT 'RILAST TURBUHALER', 'M' UNION ALL
        SELECT 'Farxiga', 'M' UNION ALL
        SELECT 'Farxiga Partner Brand', 'M' UNION ALL
        SELECT 'Sidapvia', 'M' UNION ALL
        SELECT 'Qtern', 'M' UNION ALL
        SELECT 'Xigduo', 'M' UNION ALL
        SELECT 'Symbicort 2nd Brand', 'M'
    ) t;

    -- 加载地理层级偏好配置 --
    SELECT jsonb_object_agg(geo_level, pref_type) INTO v_geo_lvl1_type_preference
    FROM (VALUES ('International Region', 'MTH')) t(geo_level, pref_type);

    SELECT jsonb_object_agg(geo_level, pref_type) INTO v_geo_lvl2_type_preference
    FROM (VALUES ('China', 'MTH'), ('International Markets', 'MTH')) t(geo_level, pref_type);

    SELECT jsonb_object_agg(geo_level, pref_type) INTO v_geo_lvl3_type_preference
    FROM (
        VALUES
        ('Russia & EURASIA', 'MTH'),('Asia Area', 'QTR'),
        ('China & HongKong', 'MTH'),('Latin America Area', 'MTH'),
        ('Ukraine & Georgia Cluster', 'MTH'),('Middle East and Africa', 'MTH')
    ) t(geo_level, pref_type);

    SELECT jsonb_object_agg(geo_level, pref_type) INTO v_geo_lvl4_type_preference
    FROM (
        VALUES
        ('Andean Cluster', 'MTH'),('Australia', 'MTH'),('Brazil', 'MTH'),
        ('CAMCAR', 'MTH'),('Egypt', 'MTH'),('Frontier Markets', 'MTH'),
        ('Gulf States', 'MTH'),('Hong Kong', 'QTR'),('India', 'MTH'),
        ('Indonesia', 'QTR'),('Kazakhstan', 'MTH'),('Maghreb', 'MTH'),
        ('Malaysia', 'QTR'),('Mexico', 'MTH'),('Near East', 'MTH'),
        ('Philippines', 'QTR'),('Russia', 'MTH'),('Subsahara Total', 'MTH'),
        ('Saudi Arabia', 'MTH'),('Singapore', 'QTR'),('South Africa', 'MTH'),
        ('South Korea', 'MTH'),('Southcone', 'MTH'),('Taiwan', 'MTH'),
        ('Thailand', 'MTH'),('Turkey', 'MTH'),('Ukraine', 'MTH'),('Vietnam', 'QTR')
    ) t(geo_level, pref_type);

    -- 加载地理层级数据 --
    SELECT jsonb_object_agg(geo_level, geo_values) INTO v_all_geos
    FROM (
        SELECT
            geo_level,
            jsonb_agg(DISTINCT geo_value) AS geo_values
        FROM (
            SELECT DISTINCT 'geo_lvl1' AS geo_level, geo_lvl1 AS geo_value FROM dim_geo WHERE entity_code LIKE '%440%'
            UNION SELECT DISTINCT 'geo_lvl2', geo_lvl2 FROM dim_geo WHERE geo_lvl2 != geo_lvl1
            AND entity_code LIKE '%440%'
            UNION SELECT DISTINCT 'geo_lvl3', geo_lvl3 FROM dim_geo WHERE geo_lvl3 != geo_lvl1
            AND geo_lvl3 != geo_lvl2
            AND  entity_code LIKE '%440%'
            UNION SELECT DISTINCT 'geo_lvl4', geo_lvl4 FROM dim_geo WHERE geo_lvl4 != geo_lvl1
            AND geo_lvl4 != geo_lvl2
            AND geo_lvl4 != geo_lvl3
            AND entity_code LIKE '%440%'
            UNION SELECT DISTINCT 'geo_lvl5', geo_lvl5 FROM dim_geo WHERE geo_lvl5 != geo_lvl1
            AND geo_lvl5 != geo_lvl2
            AND geo_lvl5 != geo_lvl3
            AND geo_lvl5 != geo_lvl4
            AND entity_code LIKE '%440%'
        ) t
        GROUP BY geo_level
    ) t;

    -- 加载KPI偏好设置 --
        SELECT jsonb_object_agg(
    regexp_replace(bks.kpi_key, '_in_(value|volume)$', ''),
    bks.kpi_key
        ) INTO v_type_kpi_preference
        FROM bi_kpi_sql bks
        WHERE bks.kpi_table = 'fact_iqvia_qtr_gmd_ms'
        AND (bks.kpi_key LIKE '%_in_value%' OR bks.kpi_key LIKE '%_in_volume%');

    -- 加载品牌市场映射 --
    SELECT jsonb_object_agg(product, sub_markets) INTO v_brand_market_cache
    FROM (
        SELECT
            product,
            jsonb_agg(DISTINCT sub_market) AS sub_markets
        FROM (
            SELECT dpm.brand_mapping_value AS product, igp.gmd_sub_mkt AS sub_market
            FROM iqvia_gmd_product igp
            JOIN dim_product_mapping dpm ON dpm.product_name = igp.international_product AND dpm.source = 'IQVIA'
            UNION
            SELECT dpm.brand_mapping_value, igp.gmd_sub_mkt
            FROM iqvia_gmd_product igp
            JOIN dim_product_mapping dpm ON dpm.product_name = igp.international_product_raw AND dpm.source = 'IQVIA'
            UNION
            SELECT 'RILAST TURBUHALER', igp.gmd_sub_mkt
            FROM iqvia_gmd_product igp
            WHERE igp.international_product_raw = 'RILAST TURBUHALER'
        ) t
        GROUP BY product
    ) t;

    -- 加载产品代码映射 --
    SELECT jsonb_object_agg(product_description, product_code) INTO v_product_code_cache
    FROM dim_product;

    -- 主处理逻辑（统一变量前缀）--
    FOR v_current_geo_level, v_geo_list IN
        SELECT key, value FROM jsonb_each(v_all_geos)
    LOOP
        FOR v_geo IN
            SELECT value::TEXT FROM jsonb_array_elements_text(v_geo_list)
        LOOP
            -- 确定数据源类型 --
            IF v_current_geo_level = 'geo_lvl5' THEN
                SELECT dg.geo_lvl4 INTO v_geo_lvl4
                FROM dim_geo dg
                WHERE dg.geo_lvl5 = v_geo
                AND dg.entity_code LIKE '%440%'
                LIMIT 1;

                v_data_source := COALESCE(
                    (v_geo_lvl4_type_preference->>v_geo_lvl4),
                    'QTR'
                );
            ELSE
                v_data_source := COALESCE(
                    v_geo_lvl1_type_preference->>v_geo,
                    v_geo_lvl2_type_preference->>v_geo,
                    v_geo_lvl3_type_preference->>v_geo,
                    v_geo_lvl4_type_preference->>v_geo,
                    'QTR'
                );
            END IF;

            -- 处理品牌级数据 --
            FOR v_brand, v_value_type IN
                SELECT key, value FROM jsonb_each_text(v_product_type_dict)
            LOOP
                v_brand_level := CASE
                    WHEN v_brand IN ('Bydureon Family','Byetta Family') THEN 'brand_lv6'
                    ELSE 'brand_lv4'
                END;

                v_all_sub_market := ARRAY(
                    SELECT jsonb_array_elements_text(v_brand_market_cache->v_brand)
                );
                CONTINUE WHEN v_all_sub_market IS NULL;

                v_suffix := CASE
                    WHEN v_product_datasource_dict->>v_brand = 'Q' THEN ''
                    WHEN v_data_source = 'MTH' THEN '_mth'
                    ELSE ''
                END;

                FOR v_market IN SELECT unnest(v_all_sub_market)
                LOOP
                    FOR v_kpi, v_kpi_key IN
                        SELECT key, value
                        FROM jsonb_each_text(v_type_kpi_preference)
                    LOOP
                        INSERT INTO bi_dynamic_kpi_rule VALUES (
                            gen_random_uuid(),
                            NOW(),
                            NOW(),
                            NULL,
                            'IQVIA',
                            v_geo,
                            v_current_geo_level,
                            v_brand,
                            v_brand_level,
                            v_market,
                            'sub_product_market',
                            v_kpi,
                            v_kpi || '_' || v_value_type || v_suffix
                        );
                    END LOOP;
                END LOOP;
            END LOOP;

            -- 处理产品级数据 --
            FOR v_product_name, v_value_type IN
                SELECT key, value FROM jsonb_each_text(v_product_name_type_dict)
            LOOP
                v_product_code := COALESCE(
                    v_product_code_cache->>v_product_name,
                    (SELECT product_code FROM dim_product WHERE product_description = v_product_name)
                );
                CONTINUE WHEN v_product_code IS NULL;

                v_all_sub_market := ARRAY(
                    SELECT jsonb_array_elements_text(v_brand_market_cache->v_product_code)
                );
                CONTINUE WHEN v_all_sub_market IS NULL;

                v_suffix := CASE
                    WHEN v_product_datasource_dict->>v_product_name = 'Q' THEN ''
                    WHEN v_data_source = 'MTH' THEN '_mth'
                    ELSE ''
                END;

                FOR v_market IN SELECT unnest(v_all_sub_market)
                LOOP
                    FOR v_kpi, v_kpi_key IN  -- 使用统一前缀变量
                        SELECT key, value
                        FROM jsonb_each_text(v_type_kpi_preference)
                    LOOP
                        INSERT INTO bi_dynamic_kpi_rule VALUES (
                            gen_random_uuid(),
                            NOW(),
                            NOW(),
                            NULL,
                            'IQVIA',
                            v_geo,
                            v_current_geo_level,
                            v_product_name,
                            'product_name',
                            v_market,
                            'sub_product_market',
                            v_kpi,
                            v_kpi || '_' || v_value_type || v_suffix
                        );
                    END LOOP;
                END LOOP;
            END LOOP;
        END LOOP;
    END LOOP;
END;
$procedure$
;
