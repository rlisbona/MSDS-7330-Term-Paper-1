
/* Explore GTIN_13 tables - Randy Lisbona 10/29/2016 */
/* Summarize record counts in all tables */
select * from information_schema.tables where information_schema.tables.table_schema = 'gtin_13';
flush tables;

select TABLE_NAME, TABLE_ROWS, AVG_ROW_LENGTH,  DATA_LENGTH, INDEX_LENGTH from information_schema.tables where information_schema.tables.table_schema = 'gtin_13';

/* TABLE_NAME		TABLE_ROWS */
/* brand			4151 */
/* brand_group		3 */
/* brand_owner		32 */
/* brand_owner_bsin	581 */
/* brand_type		2 */
/* gs1_gcp			1549550 */
/* gs1_gcp_nb		264 */
/* gs1_gcp_rc		16 */
/* gs1_gpc			38760 */
/* gs1_gpc_hier		3298 */
/* gs1_prefix		1000 */
/* gtin				844270 */
/* label			2 */
/* label_gtin		3 */
/* nutrition_us		231 */
/* pkg_type			42 */

select * from information_schema.REFERENTIAL_CONSTRAINTS where information_schema.REFERENTIAL_CONSTRAINTS.constraint_schema = 'gtin_13';
/* no referential constraints found */

select * from information_schema.TABLE_CONSTRAINTS where information_schema.TABLE_CONSTRAINTS.constraint_schema = 'gtin_13';
/* All tables have Primary Keys */

select * from information_schema.KEY_COLUMN_USAGE  where information_schema.KEY_COLUMN_USAGE.constraint_schema = 'gtin_13';
/* no referential constraints found */

/*  Tables and Keys
TABLE_NAME			Key1			Key2
brand				BSIN	
brand_group			BSIN	
brand_owner			OWNER_CD	
brand_owner_bsin	BSIN	
brand_type			BRAND_TYPE_CD	
gs1_gcp				GCP_CD	
gs1_gcp_nb			prefix_cd		gcp_length
gs1_gcp_rc			RETURN_CODE	
gs1_gpc				GPC_LANG		GPC_CD
gs1_gpc_hier		GPC_B_CD	
gs1_prefix			PREFIX_CD	
gtin				GTIN_CD	
label				LABEL_ID	
nutrition_us		GTIN_CD	
pkg_type		pkg_type_cd	
*/

/* Individual tables */

drop view if exists brand_owner_bsin_subset;
create view brand_owner_bsin_subset as
SELECT * FROM gtin_13.brand_owner_bsin 
where OWNER_CD between 27 and 30
order by OWNER_CD, BSIN;

SELECT * FROM gtin_13.brand_type;

SELECT * FROM gtin_13.pkg_type;

/* check how many package types there are */
select distinct(pkg_type_cd) from gtin;

drop view if exists gtin_subset;
create view gtin_subset as
SELECT A.* FROM gtin_13.gtin A join gtin_13.nutrition_us B on 
A.GTIN_CD = B.GTIN_CD
where b.INGREDIENTS REGEXP '.WHEAT.'
limit 20;

drop view if exists  gs1_gcp_subset;
create view gs1_gcp_subset as
SELECT A.*  FROM gtin_13.gs1_gcp A left join gtin_subset B on
A.GCP_CD = B.GCP_CD or a.GCP_CD = '73410'
order by GCP_CD
limit 20;

/***********************   The deeper we go (linking more tables) the fewer matching records we find  **************************************/
/*                         Recommend using primarily the gtin table and brand table, gts_gcp doesn't have much useful information **********/

SELECT A.*  FROM gtin_13.gs1_gcp A 
where A.GCP_CD REGEXP '.73410.';

select A.* from 
     gtin_13.gs1_gcp 			A 									/* 1,673,000 rows returned -Product names in various languages			*/
join gtin_13.gtin 				B on A.GCP_CD 		= B.GCP_CD  	/*   918,000 rows returned -Main table with GTIN product item codes 	*/
join gtin_13.brand 				D on B.BSIN 		= D.BSIN  		/*   527,000 rows returned -Brand name of item							*/
join gtin_13.brand_owner_bsin 	E on D.BSIN 		= E.BSIN		/*    86,500 rows returned -Brand owner code of Brand					*/
join gtin_13.brand_owner 		F on E.OWNER_CD 	= F.OWNER_CD	/*    86,500 rows returned -Brand owner name of owner code				*/
join gtin_13.nutrition_us 		C on B.GTIN_CD 		= C.GTIN_CD		/*        52 rows returned -Nutrition information of item				*/
/* no package records matched 
join gtin_13.pkg_type 			G on B.PKG_TYPE_CD = G.pkg_type_cd  /*         0 rows returned -Package description of item */
*/







where /* GCP_CD REGEXP '^00008' or */GLN_NM REGEXP '.Safeway.' or GLN_NM REGEXP '.Kellog.' or GCP_CD = '73410'*/

SELECT * FROM gtin_13.gs1_gcp_nb
where prefix_cd between '800' and '900';

SELECT * FROM gtin_13.gs1_gcp_rc;

SELECT * FROM gtin_13.gs1_gpc
where GPC_LANG = 'EN'   ;
limit 15;

SELECT * FROM gtin_13.gs1_gpc_hier
limit 15;

SELECT * FROM gtin_13.gs1_prefix
where COUNTRY_ISO_CD ='US'
limit 10;


SELECT A.* FROM gtin_13.nutrition_us A join gtin_subset B on
A.GTIN_CD = B.GTIN_CD
limit 200;


SELECT A.* FROM gtin_13.nutrition_us A join gtin B on
A.GTIN_CD = B.GTIN_CD
limit 20;


SELECT * FROM gtin_13.label_gtin;

SELECT * FROM gtin_13.label;

SELECT A.* FROM gtin_13.brand as A join brand_owner_bsin_subset as B on
A.BSIN = B.BSIN
order by  A.BSIN;

SELECT * FROM gtin_13.brand_group;

SELECT * FROM gtin_13.brand_owner;
