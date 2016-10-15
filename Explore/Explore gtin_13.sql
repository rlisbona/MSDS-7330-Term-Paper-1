`PRIMARY`
SELECT DISTINCT
    TABLE_NAME,
    INDEX_NAME, column_name, collation, cardinality, nullable, index_type
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'gtin_13';

select distinct * from INFORMATION_SCHEMA.STATISTICS;
select distinct * from INFORMATION_SCHEMA.tables  WHERE TABLE_SCHEMA = 'gtin_13';

select * from information_schema.KEY_COLUMN_USAGE
where table_schema = 'GTIN_13';

Select top 10 * from brand;
Select top 10 * from brand_group;
Select top 10 * from brand_owner;
Select top 10 * from brand_owner_bsin;
Select top 10 * from brand_type;
Select top 10 * from gs1_gcp;
Select top 10 * from gs1_gcp_nb;
Select top 10 * from gs1_gcp_nb;
Select top 10 * from gs1_gcp_rc;
Select top 10 * from gs1_gpc;
Select top 10 * from gs1_gpc;
Select top 10 * from gs1_gpc_hier;
Select top 10 * from gs1_prefix;
Select top 10 * from gtin;
Select top 10 * from label;
Select top 10 * from label_gtin;
Select top 10 * from label_gtin;
Select top 10 * from nutrition_us;
Select top 10 * from pkg_type;
