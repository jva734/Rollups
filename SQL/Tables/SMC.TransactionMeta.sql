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
	 AND sys.tables.name = N'TransactionMeta'
)
  DROP TABLE [SMC].[TransactionMeta]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [SMC].[TransactionMeta] (
	[TransactionMetaID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY
	,[AccountNumber] [varchar](25) NULL
	,[SecurityID] [varchar](25) NULL
	,[MonthStart] date null
	,MonthEnd date NULL
	,[ReportedDate] date null
	,[MarketValue] [numeric](18,2) NULL
	,BAMV [numeric](18, 2) NULL
	,EAMV [numeric](18, 2) NULL
	,TransactionDate date null
	,TransactionAmt [numeric](18, 2) NULL
	,[Weight] [numeric](18,6) NULL
	,[WgtAmount] [numeric](18,6) NULL
	,[TotalWgtAmount] [numeric](18,6) NULL
	,[CashFlow] [numeric](18,2) NULL
	,[EAMV_CashFlow] [numeric](18,6) NULL
	,AcbPmd [numeric](18,6) NULL
	,ProfitPmd [numeric](18,6) NULL
	,[TWRPmd] [numeric](18,6) NULL
	,[TWR-IR] [numeric](18,6) NULL
	,[WGT_CF] [numeric](18,6) NULL
	,TransactionTypeDesc [Nvarchar](100) NULL
	,PeriodType [Nvarchar](5) NULL
	,OpenedAccount bit null
	,ClosedAccount bit null
	,[RowType] [varchar](5) NULL
	,[DataSource] [varchar](10) NULL
	,BAMV_Calc [numeric](18, 2) NULL
	,EAMV_Calc [numeric](18, 2) NULL
	,EMD_Flag BIT null
	,[QtrStart] datetime NULL
	,[QtrEnd] datetime NULL
	,[IsQtr1] bit NULL
	,[IsQtr2] bit NULL
	,[IsQtr3] bit NULL
	,[IsQtr4] bit NULL
	,Processed BIT null
) ON [PRIMARY]
GO

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name='NCIdx_TM_AcctSec' AND object_id = OBJECT_ID('TransactionMeta')) 
BEGIN 
	CREATE UNIQUE NONCLUSTERED INDEX NCIdx_TM_AcctSec ON [SMC].[TransactionMeta]
	(
		TransactionMetaID ASC
	)
	INCLUDE ([AccountNumber],
		[SecurityID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
END

SET ANSI_PADDING OFF
GO

--alter table [SMC].[TransactionMeta] 
--add Processed BIT null
--go

--alter table [SMC].[TransactionMeta] 
--add MonthEnd DATE NULL
--go

--alter table [SMC].[TransactionMeta] 
--add EMD_Flag BIT null
--go


--alter table [SMC].TransactionMeta
--	add 	[QtrStart] datetime NULL
--go

--alter table [SMC].TransactionMeta
--	add 	[QtrEnd] datetime NULL
--go

--alter table [SMC].TransactionMeta
-- add [IsQtr1] bit NULL
--go

--alter table [SMC].TransactionMeta
-- add [IsQtr2] bit NULL
--go

--alter table [SMC].TransactionMeta
-- add [IsQtr3] bit NULL
--go
--alter table [SMC].TransactionMeta
-- add [IsQtr4] bit NULL
--go

--alter table [SMC].TransactionMeta
-- add [EAMV_CashFlow] [numeric](18,6) NULL
--go
