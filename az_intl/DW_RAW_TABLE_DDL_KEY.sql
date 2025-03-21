-- public.ilt_entity_exf definition

-- Drop table

DROP TABLE IF EXISTS public.dim_geo_raw;

CREATE TABLE public.dim_geo_raw (
	entity_code varchar(50) NULL,
	entity_description varchar(50) NULL,
	geo_lvl1 varchar(50) NULL,
	geo_lvl2 varchar(50) NULL,
	geo_lvl3 varchar(50) NULL,
	geo_lvl4 varchar(50) NULL,
	geo_lvl5 varchar(50) NULL,
	geo_lvl6 varchar(50) NULL,
	geo_lvl7 varchar(50) NULL,
	geo_lvl8 varchar(50) NULL
);
-- public.dim_geo_raw definition

-- Drop table

DROP TABLE IF EXISTS public.dim_product_raw;

CREATE TABLE public.dim_product_raw (
	brand_lv1 varchar(50) NULL,
	brand_lv2 varchar(50) NULL,
	brand_lv3 varchar(64) NULL,
	brand_lv4 varchar(50) NULL,
	brand_lv5 varchar(50) NULL,
	brand_lv6 varchar(50) NULL,
	brand_lv7 varchar(50) NULL,
	brand_lv8 varchar(50) NULL,
	product_code varchar(50) NULL,
	product_description varchar(50) NULL
);

-- public.international_sales_external definition

-- Drop table

DROP TABLE IF EXISTS public.fact_propel_sales_external_raw;

CREATE TABLE public.fact_propel_sales_external_raw (
	account_member_alias varchar(1000) NULL,
	act varchar(50) NULL,
	act_ytd varchar(50) NULL,
	bud varchar(50) NULL,
	bud_ytd varchar(50) NULL,
	entity_code varchar(50) NULL,
	load_dt timestamp NULL,
	mtp varchar(50) NULL,
	mtp_ytd varchar(50) NULL,
	"period" varchar(1000) NULL,
	product_code varchar(1000) NULL,
	rbu1 varchar(50) NULL,
	rbu1_ytd varchar(50) NULL,
	rbu2ltp varchar(50) NULL,
	rbu2ltp_ytd varchar(50) NULL,
	wdind numeric(4, 2) NULL,
	years varchar(50) NULL
);
-- public.iqvia_mnth_gmd_ms definition

-- Drop table

DROP TABLE IF EXISTS public.fact_iqvia_mth_gmd_ms_raw;

CREATE TABLE public.fact_iqvia_mth_gmd_ms_raw (
	"cluster" varchar(50) NULL,
	cluster_i varchar(50) NULL,
	cluster_ii varchar(50) NULL,
	corporation varchar(50) NULL,
	country varchar(50) NULL,
	days_of_therapy float4 NULL,
	gmd varchar(50) NULL,
	"gmd_sub_mkt" varchar(50) NULL,
	international_product varchar(50) NULL,
	load_dt varchar(50) NULL,
	local_product varchar(50) NULL,
	master_key int4 NULL,
	panel varchar(50) NULL,
	"period" varchar(50) NULL,
	product_family varchar(50) NULL,
	region varchar(50) NULL,
	"therapy_area" varchar(50) NULL,
	units float4 NULL,
	"us_dollars_(actual)" float4 NULL,
	"us_dollars_(constant)" float4 NULL,
	ytd_dot float4 NULL,
	ytd_units float4 NULL,
	"ytd_us_dollars_(actual)" float4 NULL,
	"ytd_us_dollars_(constant)" float4 NULL
);

-- public.iqvia_qtr_corp_rnk definition

-- Drop table

DROP TABLE IF EXISTS public.fact_iqvia_qtr_corp_rnk_raw;

CREATE TABLE public.fact_iqvia_qtr_corp_rnk_raw (
	"cluster" varchar(50) NULL,
	cluster_i varchar(50) NULL,
	cluster_ii varchar(50) NULL,
	corporation varchar(50) NULL,
	country varchar(50) NULL,
	days_of_therapy float4 NULL,
	load_dt varchar(50) NULL,
	master_key int4 NULL,
	panel varchar(50) NULL,
	"period" varchar(50) NULL,
	region varchar(50) NULL,
	"therapy_area" varchar(50) NULL,
	units float4 NULL,
	"us_dollars_(actual)" float4 NULL,
	"us_dollars_(constant)" float4 NULL,
	ytd_dot float4 NULL,
	ytd_units float4 NULL,
	"ytd_us_dollars_(actual)" float4 NULL,
	"ytd_us_dollars_(constant)" float4 NULL
);

-- public.iqvia_qtr_gmd_ms definition

-- Drop table

DROP TABLE IF EXISTS public.fact_iqvia_qtr_gmd_ms_raw;

CREATE TABLE public.fact_iqvia_qtr_gmd_ms_raw (
	"cluster" varchar(50) NULL,
	cluster_i varchar(50) NULL,
	cluster_ii varchar(50) NULL,
	corporation varchar(50) NULL,
	country varchar(50) NULL,
	days_of_therapy float4 NULL,
	gmd varchar(50) NULL,
	"gmd_sub_mkt" varchar(50) NULL,
	international_product varchar(50) NULL,
	load_dt varchar(50) NULL,
	local_product varchar(50) NULL,
	master_key int4 NULL,
	panel varchar(50) NULL,
	"period" varchar(50) NULL,
	product_family varchar(50) NULL,
	region varchar(50) NULL,
	"therapy_area" varchar(50) NULL,
	units float4 NULL,
	"us_dollars_(actual)" float4 NULL,
	"us_dollars_(constant)" float4 NULL,
	ytd_dot float4 NULL,
	ytd_units float4 NULL,
	"ytd_us_dollars_(actual)" float4 NULL,
	"ytd_us_dollars_(constant)" float4 NULL
);

-- public.ireal_mainlist definition

-- Drop table

DROP TABLE IF EXISTS public.fact_ireal_mainlist_raw;

CREATE TABLE public.fact_ireal_mainlist_raw (
	modified varchar(100) NULL,
	market varchar(100) NULL,
	emrad_target_approval_date varchar(100) NULL,
	sno int4 NULL,
	brand varchar(100) NULL,
	indication varchar(64) NULL,
	sourcing_from_international_regulatory_team bool NULL,
	regulatory_approval_status varchar(100) NULL,
	expected_regulatory_submission_date varchar(100) NULL,
	actual_regulatory_submission_date varchar(100) NULL,
	expected_regulatory_approval_date varchar(100) NULL,
	actual_regulatory_approval_date varchar(100) NULL,
	"if_no_submission_planned,_please_provide_reason" varchar(256) NULL,
	"will_reg._approval_follow_ema,_fda_or_other_label?" varchar(100) NULL,
	"if_other,_please_provide_details" varchar(256) NULL,
	commercial_launch_status varchar(100) NULL,
	expected_comm_launch_date varchar(100) NULL,
	actual_comm_launch_date varchar(100) NULL,
	"if_no_comm_launch,_please_provide_reason" varchar(256) NULL,
	isnat varchar(100) NULL,
	public_national_reimbursement_approval_status varchar(100) NULL,
	expected_public_national_reimbursement_submission_date varchar(100) NULL,
	actual_public_national_reimbursement_submission_date varchar(100) NULL,
	expected_public_national_reimbursement_approval_date varchar(100) NULL,
	actual_public_national_reimbursement_approval_date varchar(100) NULL,
	public_national_reimbursement_population_criteria varchar(100) NULL,
	"if_other,_please_provide_details2" varchar(256) NULL,
	diagnostic_reimbursement_approval_status varchar(100) NULL,
	expected_diagnostic_reimbursement_approval_date varchar(100) NULL,
	actual_diagnostic_reimbursement_approval_date varchar(100) NULL,
	pap_availability varchar(100) NULL,
	expected_pap_launch_date varchar(100) NULL,
	actual_pap_launch_date varchar(100) NULL,
	ivs_availability varchar(100) NULL,
	expected_ivs_launch_date varchar(100) NULL,
	actual_ivs_launch_date varchar(100) NULL,
	bridging_program_availability varchar(100) NULL,
	expected_bridging_program_launch_date varchar(100) NULL,
	actual_bridging_program_launch_date varchar(100) NULL,
	gpi_pricing_approval_status varchar(128) NULL,
	expected_gpi_submission_date varchar(100) NULL,
	"institution_#1_name" varchar(100) NULL,
	"institution_#1_reimbursement_approval_status" varchar(100) NULL,
	"expected_institution_#1_reimbursement_submission_date" varchar(100) NULL,
	"actual_institution_#1_reimbursement_submission_date" varchar(100) NULL,
	"expected_institution_#1_reimbursement_approval_date" varchar(100) NULL,
	"actual_institution_#1_reimbursement_approval_date" varchar(100) NULL,
	"institution_#1_reimbursement_population_criteria" varchar(100) NULL,
	"if_other,_please_provide_details3" varchar(128) NULL,
	"institution_#2_name" varchar(100) NULL,
	"institution_#2_reimbursement_approval_status" varchar(100) NULL,
	"expected_institution_#2_reimbursement_submission_date" varchar(100) NULL,
	"actual_institution_#2_reimbursement_submission_date" varchar(100) NULL,
	"expected_institution_#2_reimbursement_approval_date" varchar(100) NULL,
	"actual_institution_#2_reimbursement_approval_date" varchar(100) NULL,
	"institution_#2_reimbursement_population_criteria" varchar(100) NULL,
	"if_other,_please_provide_details4" varchar(256) NULL,
	"institution_#3_name" varchar(100) NULL,
	"institution_#3_reimbursement_approval_status" varchar(100) NULL,
	"expected_institution_#3_reimbursement_submission_date" varchar(100) NULL,
	"actual_institution_#3_reimbursement_submission_date" varchar(100) NULL,
	"expected_institution_#3_reimbursement_approval_date" varchar(100) NULL,
	"actual_institution_#3_reimbursement_approval_date" varchar(100) NULL,
	"institution_#3_reimbursement_population_criteria" varchar(100) NULL,
	"if_other,_please_provide_details5" varchar(100) NULL,
	private_insurance_approval_status varchar(100) NULL,
	expected_private_insurance_submission_date varchar(100) NULL,
	actual_private_insurance_submission_date varchar(100) NULL,
	expected_private_insurance_approval_date varchar(100) NULL,
	actual_private_insurance_approval_date varchar(100) NULL,
	private_insurance_population_criteria varchar(100) NULL,
	"if_other,_please_provide_details6" varchar(100) NULL,
	"%_population_with_access_to_date" varchar(100) NULL,
	"%_population_with_access_planned_in_peak_year_of_access" varchar(100) NULL,
	ta varchar(100) NULL,
	"peak_year_of_access_(number_of_years_after_launch)" varchar(100) NULL,
	area varchar(100) NULL,
	is1st varchar(100) NULL,
	is2nd varchar(100) NULL,
	is3rd varchar(100) NULL,
	ispri varchar(100) NULL,
	unit varchar(100) NULL,
	manual_last_update varchar(100) NULL,
	id int4 NULL,
	last_updated_by varchar(100) NULL,
	lowermarket varchar(100) NULL,
	modified_by varchar(100) NULL,
	responsible_rad varchar(100) NULL
);

