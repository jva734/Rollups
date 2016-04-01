USE [SMC_DB_Performance]
GO

/****** Object:  Table [SMC].[MonthlyPerformanceCoreTemp]    Script Date: 1/22/2016 11:03:21 AM ******/
IF EXISTS (
  SELECT *
	FROM sys.tables
	JOIN sys.schemas
	  ON sys.tables.schema_id = sys.schemas.schema_id
   WHERE sys.schemas.name = N'SMC'
	 AND sys.tables.name = N'MonthlyPerformanceCoreTemp'
	)
	DROP TABLE [SMC].[MonthlyPerformanceCoreTemp]


/****** Object:  Table [SMC].[MonthlyPerformanceCoreTemp]    Script Date: 1/22/2016 11:03:21 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [SMC].[MonthlyPerformanceCoreTemp](
	[MonthlyPerformanceCoreID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyName] [nvarchar](255) NULL,
	[MellonAccountName] [nvarchar](80) NULL,
	[MellonDescription] [nvarchar](max) NULL,

	[AccountNumber] [varchar](25) NULL,
	[SecurityID] [varchar](25) NULL,
	[MonthStart] [date] NULL,
	[StartAdjustedValuesDate] [date] NULL,
	[ReportedDate] [date] NULL,
	[MonthEnd] [date] NULL,
	[InceptionDate] [date] NULL,
	[NextMonthStart] [date] NULL,
	[NextReportedDate] [date] NULL,
	[RowType] [varchar](5) NULL,
	[DataSource] [varchar](10) NULL,
	[AccountOpened] [date] NULL,
	[AccountClosed] [date] NULL,
	[MarketValue] [numeric](18, 6) NULL,
	[BAMV] [decimal](18, 4) NULL,
	[EAMV] [decimal](18, 4) NULL,
	[MVReported] [decimal](18, 4) NULL,
	[ReportedPct] [numeric](18, 6) NULL,
	[LastReportedValue] [decimal](18, 4) NULL,
	[LastReportedDate] [date] NULL,

	[SponsorName] [nvarchar](512) NULL,
	[FirmName] [nvarchar](512) NULL,
	[PortfolioType] [nvarchar](120) NULL,
	[SubPortfolioType] [nvarchar](120) NULL,
	[Sector] [nvarchar](120) NULL,
	[SubSector] [nvarchar](120) NULL,
	[Series] [nvarchar](1000) NULL,
	[SecurityStatus] [nvarchar](120) NULL,
	[InvestmentClassification] [nvarchar](120) NULL,



	[AcbReported] [numeric](18, 2) NULL,
	[Allocation] [numeric](18, 6) NULL,
	[ProfitPmd] [float] NULL,
	[ProfitReported] [float] NULL,
	[TWRPmd] [float] NULL,
	[TWRReported] [float] NULL,
	[TwrEmdIr] [float] NULL,
	[TWR_PMDEMD] [float] NULL,
	[AcbPmd] [numeric](18, 4) NULL,
	[AcbEmdIr] [numeric](18, 4) NULL,
	[ProfitEmdIr] [numeric](18, 4) NULL,
	[MultipleDpi] [numeric](18, 6) NULL,
	[MultipleRpi] [numeric](18, 6) NULL,
	[MultipleTvpi] [numeric](18, 6) NULL,
	[CashFlow] [numeric](18, 6) NULL,
	[ContSDFPool] [float] NULL,
	[ContSDFPortfolio] [float] NULL,
	[ContSDFSubPortfolio] [float] NULL,
	[ContSDFAssetClass] [float] NULL,
	[AllocSDFPool] [float] NULL,
	[AllocSDFAssetClass] [float] NULL,
	[AllocSDFPortfolio] [float] NULL,
	[AllocSDFSubPortfolio] [float] NULL,
	[Distributions] [float] NULL,
	[CapitalCalls] [numeric](18, 4) NULL,
	[AdditionalFees] [numeric](18, 4) NULL,
	[CapitalCallsFees] [float] NULL,
	[CapitalCallsFeesLast] [numeric](18, 6) NULL,
	[CapitalCallsFeesFirst] [numeric](18, 6) NULL,
	[Commitment] [numeric](18, 4) NULL,
	[AdjCommitment] [numeric](18, 4) NULL,
	[UnFundedCommitment] [numeric](18, 6) NULL,
	[EAMVUnFundedCommitment] [numeric](18, 6) NULL,
	[FundSize] [numeric](18, 6) NULL,
	[VintageYear] [int] NULL,
	[IRR1M] [float] NULL,
	[IRR3M] [float] NULL,
	[IRR1Yr] [float] NULL,
	[IRR3Yr] [float] NULL,
	[IRR5Yr] [float] NULL,
	[IRR7Yr] [float] NULL,
	[IRR10Yr] [float] NULL,
	[IRRCY] [float] NULL,
	[IRRJY] [float] NULL,
	[SIRR] [float] NULL,
	[IRR1MReported] [float] NULL,
	[IRR3MReported] [float] NULL,
	[IRR1YrReported] [float] NULL,
	[IRR3YrReported] [float] NULL,
	[IRR5YrReported] [float] NULL,
	[IRR7YrReported] [float] NULL,
	[IRR10YrReported] [float] NULL,
	[IRRCYReported] [float] NULL,
	[IRRJYReported] [float] NULL,
	[SIRRReported] [float] NULL,
	[FileName] [varchar](100) NULL,
	[SMCLoadDT] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


