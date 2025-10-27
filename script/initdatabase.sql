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
create datavase DataWarehouse;
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
