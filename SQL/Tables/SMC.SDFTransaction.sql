
USE SMC_DB_Performance
GO
--======================
-- Drop Table template
--======================
IF EXISTS (
  SELECT *
	FROM sys.tables
	JOIN sys.schemas
	  ON sys.tables.schema_id = sys.schemas.schema_id
   WHERE sys.schemas.name = N'SMC'
	 AND sys.tables.name = N'SDFTransaction'
)
  DROP TABLE [SMC].[SDFTransaction]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [SMC].[SDFTransaction](
	[SDFTransactionID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[DataSource] [varchar](5) NOT NULL,
	[AccountNumber] [varchar](255) NULL,
	[SecurityID] [nvarchar](255) NULL,
	[TransactionDate] [date] NULL,
	[TransactionAmt] [numeric](18, 2) NULL,
	[TransactionTypeDesc] [nvarchar](255) NULL,
	[CompanyName] [nvarchar](255) NULL,
	[MellonAccountName] [nvarchar](80) NULL,
	[MellonDescription] [nvarchar](max) NULL,
	[MonthStart] Date not null,
	[MonthEnd] Date not null,
	[CreatDate] [datetime] NULL
) ON [PRIMARY]

GO

