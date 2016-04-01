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
	 AND sys.tables.name = N'XIRR_Transactions'
)
  DROP TABLE [SMC].XIRR_Transactions
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [SMC].XIRR_Transactions (
	[XIRR_TransactionsID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY
	,[AccountNumber] [varchar](25) NULL
	,[SecurityID] [varchar](25) NULL
	,[MonthStart] date null
	,[MonthEnd] date NULL
	,TransactionDate date null
	,TransactionAmt [numeric](18, 2) NULL
) ON [PRIMARY]
GO
