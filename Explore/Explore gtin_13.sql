
/* Explore GTIN_13 tables - Randy Lisbona 10/29/2016 */
/* Summarize record counts in all tables */
select * from information_schema.tables where information_schema.tables.table_schema = 'gtin_13';
flush tables;

/* this is giving a slightly different record count for some tables, not sure why, use individual queries instead
select TABLE_NAME, TABLE_ROWS from information_schema.tables where information_schema.tables.table_schema = 'gtin_13';

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

/* select record counts from all tables */
select 'brand' as 'TABLE_NAME', count(*) as 'TABLE_ROWS' from gtin_13.brand union
select 'brand_owner' as 'TABLE_NAME', count(*) as 'TABLE_ROWS' from gtin_13.brand_owner union
select 'brand_owner_bsin' as 'TABLE_NAME', count(*) as 'TABLE_ROWS' from gtin_13.brand_owner_bsin union
select 'brand_type' as 'TABLE_NAME', count(*) as 'TABLE_ROWS' from gtin_13.brand_type union
select 'gs1_gcp' as 'TABLE_NAME', count(*) as 'TABLE_ROWS'  from gtin_13.gs1_gcp union
select 'gs1_gcp_nb' as 'TABLE_NAME', count(*) as 'TABLE_ROWS'  from gtin_13.gs1_gcp_nb union
select 'gs1_gcp_rc' as 'TABLE_NAME', count(*) as 'TABLE_ROWS'  from gtin_13.gs1_gcp_rc union
select 'gs1_gpc' as 'TABLE_NAME', count(*) as 'TABLE_ROWS'  from gtin_13.gs1_gpc union
select 'gs1_gpc_hier' as 'TABLE_NAME', count(*) as 'TABLE_ROWS'  from gtin_13.gs1_gpc_hier union
select 'gs1_prefix' as 'TABLE_NAME', count(*)  as 'TABLE_ROWS' from gtin_13.gs1_prefix union
select 'gtin' as 'TABLE_NAME', count(*) as 'TABLE_ROWS'  from gtin_13.gtin union
select 'nutrition_us' as 'TABLE_NAME', count(*) as 'TABLE_ROWS'  from gtin_13.nutrition_us union
select 'pkg_type' as 'TABLE_NAME', count(*) as 'TABLE_ROWS'  from gtin_13.pkg_type;

/* Individual tables */

drop view if exists brand_owner_bsin_subset;
create view brand_owner_bsin_subset as
SELECT * FROM gtin_13.brand_owner_bsin 
where OWNER_CD between 27 and 30
order by OWNER_CD, BSIN;

SELECT * FROM gtin_13.brand_type;

SELECT * FROM gtin_13.pkg_type;


select distinct(pkg_type_cd) from gtin;  /* Check how many package types there are: 23 rows returned */

select distinct(GCP_CD) from gtin;  /* 52918 distinct rows returned for Company code */

/* 15,502 distinct brand single identification number (BSIN) matched in gtin */
select count(*) as Freq, A.GCP_CD, A.BSIN, B.BRAND_NM from gtin_13.gtin A join gtin_13.brand B on a.BSIN = B.BSIN GROUP BY A.GCP_CD, A.BSIN, B.BRAND_NM ;  

select A.GTIN_CD, A.GCP_CD, A.BSIN, B.BRAND_NM 
from gtin_13.gtin A left join gtin_13.brand B on a.BSIN = B.BSIN 
GROUP BY A.GCP_CD, A.BSIN, B.BRAND_NM
order by A.GTIN_CD ;  /* 62,849 of 922,000 gtin records have BSIN codes */
 
select distinct(length(GTIN_CD)) from gtin;  /* check this syntax */
select  GTIN_CD, length(GTIN_CD) as GTIN_LEN, GCP_CD, length(GCP_CD) as GCP_LEN from gtin order by length(GTIN_CD);  

select A.GPC_NM, B.GTIN_CD, B.GPC_S_CD, B.GPC_C_CD, B.GPC_C_CD, B.PRODUCT_LINE from 
     gtin_13.gs1_gpc 			A 									/* 1,673,000 rows returned -Product names in various languages			*/
join gtin_13.gtin 				B on B.GPC_B_CD 		= A.GPC_CD ; /*and A.GPC_LANG = "EN";*/

select M_G, M_OZ, count(*) from gtin_13.gtin
group by M_G, M_OZ;  

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

/* find records with 73410 anywhere in the GCP_CD field */
SELECT A.*  FROM gtin_13.gs1_gcp A 
where A.GCP_CD REGEXP '.73410.';

/***********************   The deeper we go (linking more tables) the fewer matching records we find  **************************************/
/*                         Recommend using primarily the gtin table and brand table, gts_gcp doesn't have much useful information **********/

select A.* from 
     gtin_13.gs1_gcp 			A 									/* 1,673,000 rows                 Global Company Prefixes			*/
join gtin_13.gtin 				B on A.GCP_CD 		= B.GCP_CD  	/*   918,000 rows matched 923,000 GTIN product item codes			*/
join gtin_13.brand 				D on B.BSIN 		= D.BSIN  		/*   527,000 rows matched   4,100 Brand names						*/
join gtin_13.brand_owner_bsin 	E on D.BSIN 		= E.BSIN		/*    86,500 rows matched     581 Brand owner code of Brand		    */
join gtin_13.brand_owner 		F on E.OWNER_CD 	= F.OWNER_CD	/*    86,500 rows matched      32 Brand owner name of owner code	*/
join gtin_13.nutrition_us 		C on B.GTIN_CD 		= C.GTIN_CD		/*        52 rows matched     231 Nutrition information of item	    */
join gtin_13.pkg_type 			G on B.PKG_TYPE_CD  = G.pkg_type_cd  /*        0 rows matched      42 Package description of item       */



/* extract example rows from each table */

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

select Count(*) from gtin_13.gtin where BSIN is null;

select count(*), length(trim(leading '0' from GTIN_CD)) as length from gtin_13.gtin group by length(trim(leading '0' from GTIN_CD));

/* count number of rows by brand URL */
select count(*) , BRAND_LINK from gtin_13.brand group BY BRAND_LINK order by count(*) DESC;

/* count number of rows where the Global Location Number name is null or '', these are just showing the country that issued the code  512,813 rows */
select count(*), ifnull(GLN_CD,'') as GLN_CD, GLN_NM from gtin_13.gs1_gcp group by ifnull(GLN_CD,''), GLN_NM order by count(*) desc;

/* count the records that have a Gloal Location Number Code 505,740 */
select count(*), GLN_CD from gtin_13.gs1_gcp group by GLN_CD having not isnull(GLN_CD) order by count(*) desc;


/* Data for chart of Global Location Numbers*/
select GCP_CD, ifnull(GLN_CD,'') as GLN_CD, GLN_NM from gtin_13.gs1_gcp 
where is null(GLN_NM)
order by ifnull(GLN_CD,''), GCP_CD ;

/*Returns 1,095,279 rows with '' Global Location numbers out of 1,549,550*/
select GCP_CD, GLN_CD, GLN_NM from gtin_13.gs1_gcp 
where GLN_CD = ''
order by GLN_CD ;

/* Returns 540580 Global Location Numbers with company codes out of 1,549,550*/
select GCP_CD, GLN_CD, GLN_NM from gtin_13.gs1_gcp 
where GLN_CD <> '' and not (GLN_NM like '%GS1%' or GLN_NM like '%Unknown country%' or GLN_NM = '' or GLN_NM like 'Prefix never allocated%' or GLN_NM like 'ReturnCode%');
order by GLN_NM ;

/* Returns 35,066 rows that have a Global Location Number but only the country that issued it, no company */
select GCP_CD, GLN_CD, GLN_NM from gtin_13.gs1_gcp 
where GLN_CD <> '' and GLN_NM like '%GS1%';
order by GLN_CD ;

/* Returns 2739 rows with an garbage GLN_NM */
select GCP_CD, GLN_CD, GLN_NM from gtin_13.gs1_gcp 
where GLN_CD <> '' and ( GLN_NM like '%Unknown country%' or GLN_NM = '' or GLN_NM like 'Prefix never allocated%' or GLN_NM like 'ReturnCode%')
order by GLN_CD ;


/* Overall summary table */
select Status, count(*) from (
	select  GLN_CD, GLN_NM,
			case 
				when GLN_NM like '%GS1%' then 'GS1 Issue Country only'
				when GLN_CD  = '' then 'Invalid or Missing'
				when GLN_NM like '%Unknown country%' or GLN_NM = '' or GLN_NM like 'Prefix never allocated%' or GLN_NM like 'ReturnCode%' then 'Invalid or Missing'
				else 'Global Location Number found'
			end as Status
 from gtin_13.gs1_gcp  ) as derivedtable
 group by Status
 order by count(*) desc;
 
 /* end Randy Lisbona exporatory queries */
