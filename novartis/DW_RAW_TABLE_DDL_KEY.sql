-- public.geography_raw definition


DROP TABLE IF EXISTS public.geography_raw;

CREATE TABLE public.geography_raw (
	countyid text NULL,
	countyname text NULL,
	countyname_en text NULL,
	cityid text NULL,
	cityname text NULL,
	cityname_en text NULL,
	provinceid text NULL,
	provincename text NULL,
	provincename_en text NULL,
	countytier text NULL,
	citytier text NULL,
	audit_batch_id int4 NOT NULL,
	audit_job_id int4 NOT NULL,
	audit_src_sys_name text NOT NULL,
	audit_created_usr text NOT NULL,
	audit_updated_usr text NOT NULL,
	audit_created_tmstmp timestamp NOT NULL,
	audit_updated_tmstmp timestamp NOT NULL
);

-- public.insmarketcycledata_raw definition


DROP TABLE IF EXISTS public.insmarketcycledata_raw;

CREATE TABLE public.insmarketcycledata_raw (
	"cycle" text NULL,
	institutionid text NULL,
	institutionname text NULL,
	marketname text NULL,
	externalproductid text NULL,
	externalproductname text NULL,
	externalproductname_en text NOT NULL,
	productid text NOT NULL,
	productname text NOT NULL,
	productname_en text NOT NULL,
	islyvalid text NOT NULL,
	salesvalue numeric(38, 8) NULL,
	lysalesvalue numeric(38, 8) NULL,
	salesunit numeric(38, 8) NULL,
	lysalesunit numeric(38, 8) NULL,
	marketvaluesize numeric(38, 8) NULL,
	lymarketvaluesize numeric(38, 8) NULL,
	marketunitsize numeric(38, 8) NULL,
	lymarketunitsize numeric(38, 8) NULL,
	isinternalproduct text NULL,
	audit_batch_id int4 NOT NULL,
	audit_job_id int4 NOT NULL,
	audit_src_sys_name text NOT NULL,
	audit_created_usr text NOT NULL,
	audit_updated_usr text NOT NULL,
	audit_created_tmstmp timestamp NOT NULL,
	audit_updated_tmstmp timestamp NOT NULL
);


-- public.inspotential_raw definition


DROP TABLE IF EXISTS public.inspotential_raw;

CREATE TABLE public.inspotential_raw (
	"year" text NULL,
	ta_id text NULL,
	hospital_id text NULL,
	ta_potential text NULL,
	decile int4 NULL,
	quintile int4 NULL,
	ta_potential_2 text NULL,
	audit_batch_id int4 NOT NULL,
	audit_job_id int4 NOT NULL,
	audit_src_sys_name text NOT NULL,
	audit_created_usr text NOT NULL,
	audit_updated_usr text NOT NULL,
	audit_created_tmstmp timestamp NOT NULL,
	audit_updated_tmstmp timestamp NOT NULL
);


-- public.insprodlisting_raw definition


DROP TABLE IF EXISTS public.insprodlisting_raw;

CREATE TABLE public.insprodlisting_raw (
	institutionid text NULL,
	institutionname text NULL,
	productid text NULL,
	issku text NOT NULL,
	productname text NULL,
	productname_en text NULL,
	productname_df text NULL,
	ym text NULL,
	listingstatus text NULL,
	listingstatus_en text NULL,
	listingcycle text NULL,
	audit_batch_id int4 NOT NULL,
	audit_job_id int4 NOT NULL,
	audit_src_sys_name text NOT NULL,
	audit_created_usr text NOT NULL,
	audit_updated_usr text NOT NULL,
	audit_created_tmstmp timestamp NOT NULL,
	audit_updated_tmstmp timestamp NOT NULL
);


-- public.insprodproperty_raw definition


DROP TABLE IF EXISTS public.insprodproperty_raw;

CREATE TABLE public.insprodproperty_raw (
	brand text NULL,
	institutionid text NULL,
	institutionname text NULL,
	insprodproperty1 text NULL,
	ym text NULL,
	audit_batch_id int4 NOT NULL,
	audit_job_id int4 NOT NULL,
	audit_src_sys_name text NOT NULL,
	audit_created_usr text NOT NULL,
	audit_updated_usr text NOT NULL,
	audit_created_tmstmp timestamp NOT NULL,
	audit_updated_tmstmp timestamp NOT NULL
);


-- public.institution_raw definition


DROP TABLE IF EXISTS public.institution_raw;

CREATE TABLE public.institution_raw (
	institutionid text NULL,
	institutionname text NULL,
	institutiontype2 text NULL,
	institutiontype3 text NULL,
	institutiontype4 text NULL,
	institutiontier text NULL,
	countyid text NULL,
	countyname text NULL,
	audit_batch_id int4 NOT NULL,
	audit_job_id int4 NOT NULL,
	audit_src_sys_name text NOT NULL,
	audit_created_usr text NOT NULL,
	audit_updated_usr text NOT NULL,
	audit_created_tmstmp timestamp NOT NULL,
	audit_updated_tmstmp timestamp NOT NULL
);


-- public.instrtyproductchannelcycledata_raw definition


DROP TABLE IF EXISTS public.instrtyproductchannelcycledata_raw;

CREATE TABLE public.instrtyproductchannelcycledata_raw (
	"cycle" text NULL,
	brand text NULL,
	productid text NULL,
	productname text NULL,
	franchise text NULL,
	repterritoryid text NULL,
	repterritoryname text NULL,
	subinstype text NULL,
	insid text NULL,
	insname text NULL,
	salesvalue float8 NULL,
	lysalesvalue float8 NULL,
	salesunit float8 NULL,
	lysalesunit float8 NULL,
	audit_batch_id int4 NOT NULL,
	audit_job_id int4 NOT NULL,
	audit_src_sys_name text NOT NULL,
	audit_created_usr text NOT NULL,
	audit_updated_usr text NOT NULL,
	audit_created_tmstmp timestamp NOT NULL,
	audit_updated_tmstmp timestamp NOT NULL
);


-- public.instrtyproductcycledata_raw definition


DROP TABLE IF EXISTS public.instrtyproductcycledata_raw;

CREATE TABLE public.instrtyproductcycledata_raw (
	"cycle" text NULL,
	brand text NULL,
	productid text NULL,
	productname text NULL,
	franchise text NULL,
	repterritoryid text NULL,
	repterritoryname text NULL,
	insid text NULL,
	insname text NULL,
	salesvalue float8 NULL,
	targetvalue float8 NULL,
	lysalesvalue float8 NULL,
	salesunit float8 NULL,
	targetunit float8 NULL,
	lysalesunit float8 NULL,
	fte numeric(38, 8) NULL,
	f2valuecvh float8 NULL,
	f2volume float8 NULL,
	audit_batch_id int4 NOT NULL,
	audit_job_id int4 NOT NULL,
	audit_src_sys_name text NOT NULL,
	audit_created_usr text NOT NULL,
	audit_updated_usr text NOT NULL,
	audit_created_tmstmp timestamp NOT NULL,
	audit_updated_tmstmp timestamp NOT NULL
);


-- public.marketareamapping_raw definition


DROP TABLE IF EXISTS public.marketareamapping_raw;

CREATE TABLE public.marketareamapping_raw (
	geographyid text NULL,
	geographyname text NULL,
	geographyname_en text NULL,
	ims_externalareaid text NULL,
	audit_batch_id int4 NOT NULL,
	audit_job_id int4 NOT NULL,
	audit_src_sys_name text NOT NULL,
	audit_created_usr text NOT NULL,
	audit_updated_usr text NOT NULL,
	audit_created_tmstmp timestamp NOT NULL,
	audit_updated_tmstmp timestamp NOT NULL
);

-- public.product_raw definition


DROP TABLE IF EXISTS public.product_raw;

CREATE TABLE public.product_raw (
	ta_name text NULL,
	ta_id text NULL,
	family_name text NULL,
	family_id text NULL,
	pl_name text NULL,
	pl_id text NULL,
	brand_name text NULL,
	brand_name_cn text NULL,
	brand_id text NULL,
	sku_name text NULL,
	sku_name_cn text NULL,
	sku_id text NULL,
	is_standard_sku int4 NULL,
	is_active int4 NULL,
	brand_category text NULL,
	brand_group text NULL,
	audit_batch_id int4 NOT NULL,
	audit_job_id int4 NOT NULL,
	audit_src_sys_name text NOT NULL,
	audit_created_usr text NOT NULL,
	audit_updated_usr text NOT NULL,
	audit_created_tmstmp timestamp NOT NULL,
	audit_updated_tmstmp timestamp NOT NULL
);


-- public.productmapping_raw definition


DROP TABLE IF EXISTS public.productmapping_raw;

CREATE TABLE public.productmapping_raw (
	productid text NULL,
	productname text NULL,
	productname_en text NULL,
	ims_productid text NULL,
	ims_productname text NULL,
	ims_productname_en text NULL,
	cpa_productid text NULL,
	cpa_productname text NULL,
	market text NULL,
	iskeymarket text NULL,
	audit_batch_id int4 NOT NULL,
	audit_job_id int4 NOT NULL,
	audit_src_sys_name text NOT NULL,
	audit_created_usr text NOT NULL,
	audit_updated_usr text NOT NULL,
	audit_created_tmstmp timestamp NOT NULL,
	audit_updated_tmstmp timestamp NOT NULL
);

-- public.territoryareamapping_raw definition


DROP TABLE IF EXISTS public.territoryareamapping_raw;

CREATE TABLE public.territoryareamapping_raw (
	tlmterritoryid text NULL,
	slmterritoryid text NULL,
	externalareaid text NULL,
	externalareaname text NULL,
	marketname text NULL,
	ym text NULL,
	audit_batch_id int4 NOT NULL,
	audit_job_id int4 NOT NULL,
	audit_src_sys_name text NOT NULL,
	audit_created_usr text NOT NULL,
	audit_updated_usr text NOT NULL,
	audit_created_tmstmp timestamp NOT NULL,
	audit_updated_tmstmp timestamp NOT NULL
);


-- public.areamarketcycledata_raw definition


DROP TABLE IF EXISTS public.areamarketcycledata_raw;

CREATE TABLE public.areamarketcycledata_raw (
	"cycle" text NULL,
	externalareaid text NULL,
	externalareaname text NULL,
	externalareaname_en text NULL,
	marketname text NULL,
	externalproductid text NULL,
	externalproductname text NULL,
	externalproductname_en text NULL,
	externalproductgroup text NULL,
	externalproductgroup_en text NULL,
	isinternalproduct text NOT NULL,
	productid text NOT NULL,
	productname text NOT NULL,
	productname_en text NOT NULL,
	salesvalue numeric(38, 8) NULL,
	lysalesvalue numeric(38, 8) NULL,
	salesunit numeric(38, 8) NULL,
	lysalesunit numeric(38, 8) NULL,
	marketvaluesize numeric(38, 8) NULL,
	lymarketvaluesize numeric(38, 8) NULL,
	marketunitsize numeric(38, 8) NULL,
	lymarketunitsize numeric(38, 8) NULL,
	audit_batch_id int4 NOT NULL,
	audit_job_id int4 NOT NULL,
	audit_src_sys_name text NOT NULL,
	audit_created_usr text NOT NULL,
	audit_updated_usr text NOT NULL,
	audit_created_tmstmp timestamp NOT NULL,
	audit_updated_tmstmp timestamp NOT NULL
);

-- public.orgcycle_raw definition


DROP TABLE IF EXISTS public.orgcycle_raw;

CREATE TABLE public.orgcycle_raw (
	"cycle" text NULL,
	buhterritoryid text NULL,
	buhterritoryname text NULL,
	buhid text NULL,
	buhname text NULL,
	fhterritoryid text NULL,
	fhterritoryname text NULL,
	fhid text NULL,
	fhname text NULL,
	tlmterritoryid text NULL,
	tlmterritoryname text NULL,
	tlmid text NULL,
	tlmname text NULL,
	slmterritoryid text NULL,
	slmterritoryname text NULL,
	slmid text NULL,
	slmname text NULL,
	flmterritoryid text NULL,
	flmterritoryname text NULL,
	flmid text NULL,
	flmname text NULL,
	repterritoryid text NULL,
	repterritoryname text NULL,
	repid text NULL,
	repname text NULL,
	repproductline text NULL,
	repbaseprovince text NULL,
	repbasecity text NULL,
	audit_batch_id int4 NOT NULL,
	audit_job_id int4 NOT NULL,
	audit_src_sys_name text NOT NULL,
	audit_created_usr text NOT NULL,
	audit_updated_usr text NOT NULL,
	audit_created_tmstmp timestamp NOT NULL,
	audit_updated_tmstmp timestamp NOT NULL
);


-- public.franchisebrandgroup_raw definition

DROP TABLE IF EXISTS public.franchisebrandgroup_raw;

CREATE TABLE public.franchisebrandgroup_raw (
	ym text NULL,
	bu text NULL,
	franchise text NULL,
	brand text NULL,
	brandgroup text NULL,
	audit_batch_id int4 NOT NULL,
	audit_job_id int4 NOT NULL,
	audit_src_sys_name text NOT NULL,
	audit_created_usr text NOT NULL,
	audit_updated_usr text NOT NULL,
	audit_created_tmstmp timestamp NOT NULL,
	audit_updated_tmstmp timestamp NOT NULL
);


-- public.lowperformance_raw definition
DROP TABLE IF EXISTS public.lowperformance_raw;

CREATE TABLE public.lowperformance_raw (
	md_version text NULL,
	territory_version text NULL,
	ta text NULL,
	franchise text NULL,
	ad_post text NULL,
	rm_post text NULL,
	dm_post text NULL,
	mr_post text NULL,
	promotion_grid text NULL,
	dl_continuous_quarters text NULL,
	latest_quarter text NULL,
	productivity text NULL,
	yoy_growth_rate text NULL,
	audit_batch_id int4 NOT NULL,
	audit_job_id int4 NOT NULL,
	audit_src_sys_name text NOT NULL,
	audit_created_usr text NOT NULL,
	audit_updated_usr text NOT NULL,
	audit_created_tmstmp timestamp NOT NULL,
	audit_updated_tmstmp timestamp NOT NULL
);

-- Table: public.choir_refresh_date

DROP TABLE IF EXISTS public.choir_refresh_date;

CREATE TABLE public.choir_refresh_date
(
    id text COLLATE pg_catalog."default" NOT NULL,
    subject text COLLATE pg_catalog."default",
    to_period text COLLATE pg_catalog."default",
    last_modified_date timestamp without time zone,
    audit_updated_tmstmp timestamp without time zone,
    CONSTRAINT choir_refresh_date_pkey PRIMARY KEY (id)
);
