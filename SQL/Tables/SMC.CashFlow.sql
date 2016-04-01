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
	 AND sys.tables.name = N'CashFlow'
)
  DROP TABLE SMC.CashFlow
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE SMC.CashFlow (
	[CashFlowID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY
	,[AccountNumber] [varchar](25) NULL
	,[SecurityID] [varchar](25) NULL
	,[MonthEnd] date null
	,[MonthStart] date null

-- CD Values
	,CDCCCorrections numeric(18,2) NULL
	,CDCapitalCalls numeric(18,2) NULL
	,CDCashIncome numeric(18,2) NULL		
	,CDCashIncomeCorrection numeric(18,2) NULL
	,CDCashPrincipal numeric(18,2) NULL
	,CDCashPrincipalCorrections numeric(18,2) NULL
	,CDStockIncome numeric(18,2) NULL
	,CDStockPrincipal numeric(18,2) NULL

--PI Values
	,PICapitalCalls numeric(18,2) NULL
	,PIAdditionalFees numeric(18,2) NULL
	--,PICashPrincipal numeric(18,2) NULL
	,PICashIncome numeric(18,2) NULL
	,PICashIncomeRERoyal numeric(18,2) NULL
	,PIStockDistribution numeric(18,2) NULL
	,PIRecallableCapital numeric(18,2) NULL
	,PICashPrincipalCapitalGains numeric(18,2) NULL

-- CD Weighted Values
	,CDCCCorrectionsWGT numeric(18,2) NULL
	,CDCapitalCallsWGT numeric(18,2) NULL
	,CDCashIncomeWGT numeric(18,2) NULL
	,CDCashIncomeCorrectionWGT numeric(18,2) NULL
	,CDCashPrincipalWGT numeric(18,2) NULL
	,CDCashPrincipalCorrectionsWGT numeric(18,2) NULL
	,CDStockIncomeWGT numeric(18,2) NULL
	,CDStockPrincipalWGT numeric(18,2) NULL

--PI Weighted Values
	,PICapitalCallsWGT numeric(18,2) NULL
	,PIAdditionalFeesWGT numeric(18,2) NULL
	--,PICashPrincipalWGT numeric(18,2) NULL
	,PICashIncomeWGT numeric(18,2) NULL
	,PICashIncomeRERoyalWGT numeric(18,2) NULL
	,PIStockDistributionWGT numeric(18,2) NULL
	,PIRecallableCapitalWgt numeric(18,2) NULL
	,PICashPrincipalCapitalGainsWgt numeric(18,2) NULL

	--Sum of values for calculations
	,TotalCashFlow numeric(18,2) NULL
	--,TotalCashFlowWGT numeric(18,2) NULL
	,TotalDistribution numeric(18,2) NULL
	,TotalCapitalCalls numeric(18,2) NULL
	,TotalAdditionalFees numeric(18,2) NULL
	,EAMV_CashFlow numeric(18,2) NULL
	,EAMV_CashFlowWGT numeric(18,2) NULL

) ON [PRIMARY]

GO

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name='NCIdx_CF_AcctSecMth' AND object_id = OBJECT_ID('CashFlow')) 
BEGIN 
	CREATE UNIQUE NONCLUSTERED INDEX NCIdx_CF_AcctSecMth ON [SMC].[CashFlow]
	(
		[CashFlowID] ASC
	)
	INCLUDE ( 	[AccountNumber],
		[SecurityID],
		[MonthEnd]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
END

SET ANSI_PADDING OFF
GO


--ALTER TABLE SMC.CashFlow 
--	ADD PIIncome_WGT_CF numeric(18,2) NULL
--go
