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
	 AND sys.tables.name = N'MonthlyPerformanceArchive'
)
  DROP TABLE [SMC].[MonthlyPerformanceArchive]
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [SMC].[MonthlyPerformanceArchive] (
	[MonthlyPerformanceArchiveID] [bigint] IDENTITY(1,1) NOT NULL,
	[AccountNumber] [varchar](25) NULL,
	[SecurityID] [varchar](25) NULL,
	[ReportedDate] [date] NULL,
	[MonthEnd] [date] NULL,
	[InceptionDate] [date] NULL,
	[RowType] [varchar](5) NULL,
	[DataSource] [varchar](10) NULL,
	[AccountOpened] [date] NULL,
	[AccountClosed] [date] NULL,
	[BAMV] [numeric](18, 4) NULL,
	[EAMV] [numeric](18, 4) NULL,
	[MarketValue] [numeric](18, 4) NULL,
	[ReportedPct] [float] NULL,
	[LastReportedValue] [decimal](18, 2) NULL,
	[LastReportedDate] [date] NULL,
	[TWRPMD] [float] NULL,
	[TWREMDIR] [float] NULL,
	[TWR1M] [float] NULL,
	[TWR3M] [float] NULL,
	[TWR1Yr] [float] NULL,
	[TWR3Yr] [float] NULL,
	[TWR5Yr] [float] NULL,
	[TWR7Yr] [float] NULL,
	[TWR10Yr] [float] NULL,
	[TWRCY] [float] NULL,
	[TWRJY] [float] NULL,
	[STWR] [float] NULL,
	[TWR1MReported] [float] NULL,
	[TWR3MReported] [float] NULL,
	[TWR1YrReported] [float] NULL,
	[TWRCYReported] [float] NULL,
	[TWRJYReported] [float] NULL,
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
	[MultipleDPI] [float] NULL,
	[MultipleRPI] [float] NULL,
	[MultipleTVPI] [float] NULL,
	[ACBPMD] [numeric](18, 4) NULL,
	[ACBEMDIR] [numeric](18, 4) NULL,
	[ACBReported] [numeric](18, 4) NULL,
	[Allocation] [numeric](18, 6) NULL,
	[CashFlow] [numeric](18, 6) NULL,
	[ProfitPMD] [numeric](18, 2) NULL,
	[ProfitEMDIR] [numeric](18, 2) NULL,
	[Profit1M] [numeric](18, 6) NULL,
	[Profit3M] [numeric](18, 6) NULL,
	[ProfitCY] [numeric](18, 6) NULL,
	[ProfitJY] [numeric](18, 6) NULL,
	[ProfitReported] [numeric](18, 6) NULL,
	[ContSDFPool1M] [float] NULL,
	[ContSDFPortfolio1M] [float] NULL,
	[ContSDFSubPortfolio1M] [float] NULL,
	[ContSDFAssetClass1M] [float] NULL,
	[ContSDFPool3M] [float] NULL,
	[ContSDFPortfolio3M] [float] NULL,
	[ContSDFSubPortfolio3M] [float] NULL,
	[ContSDFAssetClass3M] [float] NULL,
	[ContSDFPoolCY] [float] NULL,
	[ContSDFPortfolioCY] [float] NULL,
	[ContSDFSubPortfolioCY] [float] NULL,
	[ContSDFAssetClassCY] [float] NULL,
	[ContSDFPool1Yr] [float] NULL,
	[ContSDFPortfolio1Yr] [float] NULL,
	[ContSDFSubPortfolio1Yr] [float] NULL,
	[ContSDFAssetClass1Yr] [float] NULL,
	[AllocSDFPool] [float] NULL,
	[AllocSDFPortfolio] [float] NULL,
	[AllocSDFSubPortfolio] [float] NULL,
	[AllocSDFAssetClass] [float] NULL,
	[Commitment] [numeric](18, 4) NULL,
	[AdjCommitment] [numeric](18, 4) NULL,
	[UnfundedCommitment] [numeric](18, 4) NULL,
	[EAMVUnfundedCommitment] [numeric](18, 4) NULL,
	[FundSize] [numeric](18, 6) NULL,
	[VintageYear] [int] NULL,
	[WgtAvgPool] [numeric](18, 4) NULL,
	[WgtAvgAssetClass] [numeric](18, 4) NULL,
	[WgtAvgPortfolio] [numeric](18, 4) NULL,
	[WgtAvgSubPortfolio] [numeric](18, 4) NULL,
	[AdditionalFees] [numeric](18, 4) NULL,
	[CapitalCalls] [numeric](18, 4) NULL,
	[Distributions1M] [numeric](18, 4) NULL,
	[Distributions3M] [numeric](18, 4) NULL,
	[Distributions1Yr] [numeric](18, 4) NULL,
	[DistributionsQTD] [numeric](18, 4) NULL,
	[DistributionsYTD] [numeric](18, 4) NULL,
	[DistributionsSI] [numeric](18, 4) NULL,
	[CapitalCallsFeesFirst] [numeric](18, 4) NULL,
	[CapitalCallsFeesLast] [numeric](18, 4) NULL,
	[CapitalCallsFees1M] [numeric](18, 4) NULL,
	[CapitalCallsFees3M] [numeric](18, 4) NULL,
	[CapitalCallsFees1Yr] [numeric](18, 4) NULL,
	[CapitalCallsFeesQ1Prev] [numeric](18, 4) NULL,
	[CapitalCallsFeesQ2Prev] [numeric](18, 4) NULL,
	[CapitalCallsFeesQ3Prev] [numeric](18, 4) NULL,
	[CapitalCallsFeesQ4Prev] [numeric](18, 4) NULL,
	[CapitalCallsFeesQTD] [numeric](18, 4) NULL,
	[CapitalCallsFeesYTD] [numeric](18, 4) NULL,
	[CapitalCallsFeesSI] [numeric](18, 4) NULL,
	[Ranking] [int] NULL,
	[SMC_LoadDate] [datetime] NULL,
 CONSTRAINT [PK_MonthlyPerformanceArchive] PRIMARY KEY CLUSTERED 
(
	MonthlyPerformanceArchiveID ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

