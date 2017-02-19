USE master
ALTER DATABASE Inventory SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
IF EXISTS(select * from sys.databases where name='Inventory')
DROP DATABASE Inventory