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
	 AND sys.tables.name = N'Transactions'
)
  DROP TABLE [SMC].[Transactions]
GO

/****** Object:  Table [SMC].[Transactions]    Script Date: 6/9/2015 1:41:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [SMC].[Transactions](
	[TransactionID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[DataSource] [varchar](5) NOT NULL,
	[AsOfDate] [date] NULL,
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
	[SMCLoadDate] [datetime] NULL
) ON [PRIMARY]

GO


IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name='NCIdx_T_AcctSec' AND object_id = OBJECT_ID('Transactions')) 
BEGIN 
	CREATE UNIQUE NONCLUSTERED INDEX NCIdx_T_AcctSec ON [SMC].[Transactions]
	(
		TransactionID ASC
	)
	INCLUDE ([AccountNumber],
		[SecurityID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
END


SET ANSI_PADDING OFF
GO


