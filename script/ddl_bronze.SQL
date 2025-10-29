Use master;
GO
--Drop and recreate the 'DataWarehouse' database

if exists(Select 1 from sys.database where name='DataWarehouse')
begin
Alter Database DataWarehouse set single_user with rollback immediate;
drop DataBase DataWarehouse;
End;
GO

-- Create 'DataWarehouse' database
create database DataWarehouse;
go

use DataWarehouse;
go

-- Create Schemas
Create Schema bronze ;
Go
Create Schema silver;
go
Create Schema gold;
go

--check whether the table exists inn database(do it before creating any table i didnt write for all tables)
if object_id('bronze.crm_cust_info', 'U') is not null
  DROP TABLE bronze.crm_cust_info;

  
	--DDL Data definition language defines the structure of database tables
	if object_id('bronze.crm_cust_info', 'U') is not null
  DROP TABLE bronze.crm_cust_info;
	create table bronze.crm_cust_info (
	cst_id int,
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_material_status nvarchar(50),
	cst_gndr nvarchar(50),
	cst_create_date DATE
	) 

	create table bronze.crm_prd_info(
	prd_id int,
	prd_key nvarchar(50),
	prd_nm nvarchar(50),
	prd_cost float,
	prd_line nvarchar(50),
	prd_start_dt DATE,
	prd_end_dt  DATE
	)
	alter table bronze.crm_prd_info
	alter column prd_end_dt datetime;

	create table bronze.crm_sales_details (
	sls_ord_num nvarchar(50),
	sls_prd_key nvarchar(50),
	sls_cust_id int,
	sls_order_dt date,
	sls_ship_dt date,
	sls_due_dt date,
	sls_sales int,
	sls_quantity int,
	sls_price int
	)

	alter table bronze.crm_sales_details
	add sls_due_dt int
	create table bronze.erp_cust_AZ12 (
	cid nvarchar(50),
	BDATE DATE,
	GEN nvarchar(6)
	)

	create table bronze.erp_LOC_A101 (
	Cid nvarchar(50),
	CNTRY nvarchar(50)
	)

	create table bronze.erp_PX_CAT_G1V2 (
	id nvarchar(50),
	cat nvarchar(50),
	subcat nvarchar(50),
	maintanance nvarchar(3)
	)
	exec bronze.load_bronze
	Create or alter procedure bronze.load_bronze as 
 Begin

 --TRACK ETL DURATİON Helps to identify bottlenecks, optimize performance, monitor trends,detect issues
 DECLARE @start_time DATEtime, @end_time DATEtime, @batch_start_time Datetime, @batch_end_time Datetime;
	Begin try

		 SET @end_time =GETDATE();
		 print '=========================================================';
		 print 'Loading Bronze Layer';
		 print '=========================================================';
		 print '=========================================================';
		 print' Loading CRM Tables';
		 print '=========================================================';
		 Print '>> Truncating bronze.crm_cust_info';
		 SET @batch_start_time = GETDATE();
		 SET @start_time =GETDATE();
		 Print '>> Truncating bronze.crm_cust_info'
		--Truncate Quickly delete all rows from a table, resetting it to an empty state;
		Truncate table bronze.crm_cust_info;

		--Fetching data from the datasource
		BULK insert bronze.crm_cust_info
		from 'C:\sql-data-warehouse-project\datasets\source_crm/cust_info.csv'
		With(
		 firstrow = 2,
		 fieldterminator = ',',
		 tablock
		);
		
		print '>> Load Duration' + cast(Datediff(second,@start_time,@end_time) as nvarchar) + 'seconds';
		Truncate table bronze.crm_prd_info

		BULK insert bronze.crm_prd_info
		from 'C:\sql-data-warehouse-project\datasets\source_crm/prd_info.csv'
		With(
		 firstrow = 2,
		 fieldterminator = ',',
		 tablock
		)
		 print '=========================================================';
		  print ' Loading ERP Tables';
		  print '=========================================================';
	
		Truncate table bronze.crm_sales_details
		BULK insert bronze.crm_sales_details
		from 'C:\sql-data-warehouse-project\datasets\source_crm/sales_details.csv'
		With(
		 firstrow = 2,
		 fieldterminator = ',',
		 tablock
		)Truncate table bronze.erp_CUST_AZ12
		BULK insert bronze.erp_CUST_AZ12
		from 'C:\sql-data-warehouse-project\datasets\source_erp/CUST_AZ12.csv'
		With(
		 firstrow = 2,
		 fieldterminator = ',',
		 tablock
		)Truncate table bronze.erp_LOC_A101
		BULK insert bronze.erp_LOC_A101
		from 'C:\sql-data-warehouse-project\datasets\source_erp/LOC_A101.csv'
		With(
		 firstrow = 2,
		 fieldterminator = ',',
		 tablock
		 )Truncate table bronze.erp_PX_CAT_G1V2
		 BULK insert bronze.erp_PX_CAT_G1V2
		from 'C:\sql-data-warehouse-project\datasets\source_erp/PX_CAT_G1V2.csv'
		With(
		 firstrow = 2,
		 fieldterminator = ',',
		 tablock
		)
		 SET @batch_end_time =GETDATE();
		 print '============================================'
		 print' Total Duraiton: ' + cast(Datediff(second,@batch_start_time, @batch_end_time) as NVARCHAR) + 'seconds';
		 print '=============================================='
	end try
	begin catch 
	print'================================================'
	print 'ERROR occured during bronze layer '
	print 'Error Message' + ERROR_MESSAGE();
	print 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
	print 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
	print'================================================'
	end catch
END

---- perform the under script if you need to uptade dta daily basis(stored procedure)
exec bronze.load_bronze

--QUALİTY CHECK Check that the data has not shifted and is in the correct columns
select * from bronze.crm_cust_info
select count(*) from bronze.crm_cust_info


----------------------------------------------
 
