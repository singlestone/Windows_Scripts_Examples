USE [Inventory]
IF  NOT EXISTS (SELECT * FROM sys.objects 
	WHERE object_id = OBJECT_ID(N'[dbo].[DNS]') AND type in (N'U'))
	SET ANSI_NULLS ON
	SET QUOTED_IDENTIFIER ON
	CREATE TABLE [dbo].[ADuser](
		[IPAddress] [nvarchar](MAX) NULL,
		[Name] [nvarchar](MAX) NOT NULL,
		[TTL] [nvarchar](MAX) NULL,
		[RecordClass] [nvarchar](MAX) NULL,
		[RecordType] [nvarchar](MAX) NULL,
		[RecordData] [nvarchar](MAX) NULL,
		[TimeStamp] [nvarchar](MAX) NULL,
		[ZoneName] [nvarchar](MAX) NULL,
		[DnsServerName] [nvarchar](MAX) NULL,
		[Identity] [nvarchar](MAX) NULL,
		[ServerName] [nvarchar](MAX) NULL
	) ON [PRIMARY]
GO