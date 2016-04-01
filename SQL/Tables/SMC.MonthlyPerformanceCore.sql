USE [SMC_DB_Performance]
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
	 AND sys.tables.name = N'MonthlyPerformanceCore'
)
  DROP TABLE [SMC].[MonthlyPerformanceCore]
GO

/****** Object:  Table [SMC].[MonthlyPerformanceCore]    Script Date: 4/29/2015 9:56:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [SMC].[MonthlyPerformanceCore](
	[MonthlyPerformanceCoreID] [INT] IDENTITY(1,1) NOT NULL,
	[CompanyName] [nvarchar](255) NULL,
	[MellonAccountName] [nvarchar](80) NULL,
	[MellonDescription] [nvarchar](max) NULL,
	[AccountNumber] [VARCHAR](25) NULL,
	[SecurityID] [VARCHAR](25) NULL,
	[MonthStart] [DATE] NULL,
	[StartAdjustedValuesDate] [DATE] NULL,
	[ReportedDate] [DATE] NULL,
	[MonthEnd] [DATE] NULL,
	[InceptionDate] [DATE] NULL,
	[LastTransactionDate] DATE NULL,
	[NextMonthStart] [DATE] NULL,
	[NextReportedDate] [DATE] NULL,
	[RowType] [VARCHAR](5) NULL,
	[DataSource] [VARCHAR](10) NULL,
	[AccountOpened] [DATE] NULL,
	[AccountClosed] [DATE] NULL,
	[MarketValue] [NUMERIC](18, 6) NULL,
	[BAMV] [DECIMAL](18, 4) NULL,
	[EAMV] [DECIMAL](18, 4) NULL,
	[MVReported] [DECIMAL](18, 4) NULL,
	[ReportedPct] [NUMERIC](18, 6) NULL,
	[LastReportedValue] [DECIMAL](18, 4) NULL,
	[LastReportedDate] [DATE] NULL,
	Shares INT null,
	[SponsorName] [nvarchar](512) NULL,
	[FirmName] [nvarchar](512) NULL,
	[PortfolioType] [nvarchar](120) NULL,
	[SubPortfolioType] [nvarchar](120) NULL,
	[Sector] [nvarchar](120) NULL,
	[SubSector] [nvarchar](120) NULL,
	[Series] [nvarchar](1000) NULL,
	[SecurityStatus] [nvarchar](120) NULL,
	[InvestmentClassification] [nvarchar](120) NULL,

	[AcbReported] [NUMERIC](18, 2) NULL,
	[Allocation] [NUMERIC](18, 6) NULL,
	[ProfitPmd] [FLOAT] NULL,
	[ProfitReported] [FLOAT] NULL,
	[TWRPmd] [FLOAT] NULL,
	[TWRReported] [FLOAT] NULL,
	[TwrEmdIr] [FLOAT] NULL,
	TWR_PMDEMD [FLOAT] null,
	[AcbPmd] [NUMERIC](18, 4) NULL,
	[AcbEmdIr] [NUMERIC](18, 4) NULL,
	[ProfitEmdIr] [NUMERIC](18, 4) NULL,
	[MultipleDpi] [NUMERIC](18, 6) NULL,
	[MultipleRpi] [NUMERIC](18, 6) NULL,
	[MultipleTvpi] [NUMERIC](18, 6) NULL,
	[CashFlow] [NUMERIC](18, 6) NULL,

	[ContSDFPool] [FLOAT] NULL,
	[ContSDFPortfolio] [FLOAT] NULL,
	[ContSDFSubPortfolio] [FLOAT] NULL,
	[ContSDFAssetClass] [FLOAT] NULL,

	[AllocSDFPool] [FLOAT] NULL,
	[AllocSDFAssetClass] [FLOAT] NULL,
	[AllocSDFPortfolio] [FLOAT] NULL,
	[AllocSDFSubPortfolio] [FLOAT] NULL,

	[Distributions] [FLOAT] NULL,
	[CapitalCalls] [NUMERIC](18, 4) NULL,
	[AdditionalFees] [NUMERIC](18, 4) NULL,
	[CapitalCallsFees] [FLOAT] NULL,
	[CapitalCallsFeesLast] [NUMERIC](18, 6) NULL,
	[CapitalCallsFeesFirst] [NUMERIC](18, 6) NULL,
	[Commitment] [NUMERIC](18, 4) NULL,
	[AdjCommitment] [NUMERIC](18, 4) NULL,
	[UnFundedCommitment] [NUMERIC](18, 6) NULL,
	[EAMVUnFundedCommitment] [NUMERIC](18, 6) NULL,
	[FundSize] [NUMERIC](18, 6) NULL,
	[VintageYear] [INT] NULL,

	[IRR1M] [FLOAT] NULL,
	[IRR3M] [FLOAT] NULL,
	[IRR1Yr] [FLOAT] NULL,
	[IRR3Yr] [FLOAT] NULL,
	[IRR5Yr] [FLOAT] NULL,
	[IRR7Yr] [FLOAT] NULL,
	[IRR10Yr] [FLOAT] NULL,
	[IRRCY] [FLOAT] NULL,
	[IRRJY] [FLOAT] NULL,
	[SIRR] [FLOAT] NULL,
	[IRR1MReported] [FLOAT] NULL,
	[IRR3MReported] [FLOAT] NULL,
	[IRR1YrReported] [FLOAT] NULL,
	[IRR3YrReported] [FLOAT] NULL,
	[IRR5YrReported] [FLOAT] NULL,
	[IRR7YrReported] [FLOAT] NULL,
	[IRR10YrReported] [FLOAT] NULL,
	[IRRCYReported] [FLOAT] NULL,
	[IRRJYReported] [FLOAT] NULL,
	[SIRRReported] [FLOAT] NULL,
	[ASA_Account] BIT NULL,
	[FileName] [VARCHAR](100) NULL,
	[SMCLoadDT] [DATETIME] NULL
		
PRIMARY KEY CLUSTERED 
(
	[MonthlyPerformanceCoreID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name='NCIdx_MPC_AcctSecMth' AND object_id = OBJECT_ID('MonthlyPerformanceCore')) 
BEGIN 
	CREATE UNIQUE NONCLUSTERED INDEX [NCIdx_MPC_AcctSecMth] ON [SMC].[MonthlyPerformanceCore]
	(
		[MonthlyPerformanceCoreID] ASC
	)
	INCLUDE ( 	[AccountNumber],
		[SecurityID],
		[MonthEnd]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
END


SET ANSI_PADDING OFF
GO

--USE [SMC_DB_Performance]
--GO

--alter table [SMC].[MonthlyPerformanceCore]
--	add  LastTransactionDate DATETIME NULL
--go

--alter table [SMC].[MonthlyPerformanceCore]
--	add  IncepTWR numeric(18,6) null
--go


--EXEC sp_rename '[SMC].[MonthlyPerformanceCore].[[CapitalCallsFeesQ1Prev]]', 'CapitalCallsFeesQ1Prev', 'COLUMN';
--go
--EXEC sp_rename '[SMC].[MonthlyPerformanceCore].[CapitalCallsFeesQ2Prev]', 'CapitalCallsFeesQ2Prev', 'COLUMN';
--go
--EXEC sp_rename '[SMC].[MonthlyPerformanceCore].[CapitalCallsFeesQ3Prev]', 'CapitalCallsFeesQ3Prev', 'COLUMN';
--go
--EXEC sp_rename '[SMC].[MonthlyPerformanceCore].[CapitalCallsFeesQ4Prev]', 'CapitalCallsFeesQ4Prev', 'COLUMN';
--go


--alter table [SMC].[MonthlyPerformanceCore]
--	add  TWR_PMDEMD [FLOAT] null
--go

--alter table [SMC].[MonthlyPerformanceCore]
--	add  EAMVUnFundedCommitment numeric(18,6) null
--go

--alter table [SMC].[MonthlyPerformanceCore]
--	add  [CapitalCallsFeesQ1Prev] [numeric](18, 6) NULL
--go
--alter table [SMC].[MonthlyPerformanceCore]
--	add  [CapitalCallsFeesQ2Prev] [numeric](18, 6) NULL
--go
--alter table [SMC].[MonthlyPerformanceCore]
--	add  [CapitalCallsFeesQ3Prev] [numeric](18, 6) NULL
--go
--alter table [SMC].[MonthlyPerformanceCore]
--	add  [CapitalCallsFeesQ4Prev] [numeric](18, 6) NULL
--go

--alter table [SMC].[MonthlyPerformanceCore]
--	add  [CapitalCallsFeesQ1Prev] [numeric](18, 6) NULL
--go
--alter table [SMC].[MonthlyPerformanceCore]
--	add  [CapitalCallsFeesQ2Prev] [numeric](18, 6) NULL
--go
--alter table [SMC].[MonthlyPerformanceCore]
--	add  [CapitalCallsFeesQ3Prev] [numeric](18, 6) NULL
--go
--alter table [SMC].[MonthlyPerformanceCore]
--	add  [CapitalCallsFeesQ4Prev] [numeric](18, 6) NULL
--go

--alter table [SMC].[MonthlyPerformanceCore]
--	add [CapitalCallsFeesQ1] [numeric](18, 6) NULL
--go
--alter table [SMC].[MonthlyPerformanceCore]
--	add [CapitalCallsFeesQ2] [numeric](18, 6) NULL
--go
--alter table [SMC].[MonthlyPerformanceCore]
--	add [CapitalCallsFeesQ3] [numeric](18, 6) NULL
--go
--alter table [SMC].[MonthlyPerformanceCore]
--	add [CapitalCallsFeesQ4] [numeric](18, 6) NULL
--go

--alter table [SMC].[MonthlyPerformanceCore]
--	add [CapitalCallsFees1Yr] [numeric](18, 6) NULL
--go

--alter table [SMC].[MonthlyPerformanceCore]
--	add [Distributions1M] [numeric](18, 6) NULL
--go

--alter table [SMC].[MonthlyPerformanceCore]
--	add [Distributions3M] [numeric](18, 6) NULL
--go

--alter table [SMC].[MonthlyPerformanceCore]
--	add [Distributions1Yr] [numeric](18, 6) NULL
--go

--alter table [SMC].[MonthlyPerformanceCore]
--	add [CapitalCallsSI]  [numeric](18, 6) NULL
--go

--EXEC sp_rename '[SMC].[MonthlyPerformanceCore].[Distributions1Mo]', 'Distributions1M', 'COLUMN';
--go
