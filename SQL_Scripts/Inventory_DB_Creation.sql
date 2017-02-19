USE master

IF NOT EXISTS(select * from sys.databases where name='Inventory')
	CREATE DATABASE [Inventory]
		CONTAINMENT = NONE
	ON  PRIMARY 
	( NAME = N'Inventory', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\Inventory.mdf' , SIZE = 3072KB , 	FILEGROWTH = 1024KB )
	LOG ON 
	( NAME = N'Inventory_log', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\Inventory_log.ldf' , SIZE = 1024KB , FILEGROWTH = 10%)
	GO