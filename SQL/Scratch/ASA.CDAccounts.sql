--SELECT * FROM [SMC].[DirectAccounts]

USE [SMC_DB_ASA]
GO
--======================
-- Drop Table template
--======================
IF EXISTS (
  SELECT *
	FROM sys.tables
	JOIN sys.schemas
	  ON sys.tables.schema_id = sys.schemas.schema_id
   WHERE sys.schemas.name = N'DBO'
	 AND sys.tables.name = N'CDAccounts'
)
  DROP TABLE [DBO].[CDAccounts]
GO

/****** Object:  Table [SMC].[Transactions]    Script Date: 6/9/2015 1:41:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [DBO].[CDAccounts] (
	[CDAccountsID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[AccountNumber] [varchar](50) NULL,	
	[AccountName] [varchar](255) NULL,
	[SecurityID] [nvarchar](25) NULL,
	[CompanyName] [nvarchar](255) NULL,
	Processed int null,
) ON [PRIMARY]

GO
