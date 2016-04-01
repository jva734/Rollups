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
	 AND sys.tables.name = N'MonthlyPerformanceGroup'
)
  DROP TABLE SMC.MonthlyPerformanceGroup
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [SMC].[MonthlyPerformanceGroup](
	[MonthlyPerformanceGroupID] [BIGINT] IDENTITY(1,1) NOT NULL,
	[GroupName] [VARCHAR](100) NULL,
	[GroupDesc] [VARCHAR](255) NULL,
	[MonthEnd] [DATE] NULL,
	[InceptionDate] [DATE] NULL,
	[ACBPMD] [NUMERIC](18, 4) NULL,
	[ACBReported] [NUMERIC](18, 4) NULL,
	[EAMV] [NUMERIC](18, 4) NULL,
	[MarketValue] [NUMERIC](18, 4) NULL,
	[ReportedPct] [FLOAT] NULL,
	[TWR1M] [FLOAT] NULL,
	[TWR3M] [FLOAT] NULL,
	[TWR1Yr] [FLOAT] NULL,
	[TWR3Yr] [FLOAT] NULL,
	[TWR5Yr] [FLOAT] NULL,
	[TWR7Yr] [FLOAT] NULL,
	[TWR10Yr] [FLOAT] NULL,
	[TWRCY] [FLOAT] NULL,
	[TWRJY] [FLOAT] NULL,
	[STWR] [FLOAT] NULL,
	[TWR1MReported] [FLOAT] NULL,
	[TWR3MReported] [FLOAT] NULL,
	[TWR1YrReported] [FLOAT] NULL,
	[TWRCYReported] [FLOAT] NULL,
	[TWRJYReported] [FLOAT] NULL,
	[ContSDFPool1M] [FLOAT] NULL,
	[ContSDFPortfolio1M] [FLOAT] NULL,
	[ContSDFSubPortfolio1M] [FLOAT] NULL,
	[ContSDFAssetClass1M] [FLOAT] NULL,
	[ContSDFPool3M] [FLOAT] NULL,
	[ContSDFPortfolio3M] [FLOAT] NULL,
	[ContSDFSubPortfolio3M] [FLOAT] NULL,
	[ContSDFAssetClass3M] [FLOAT] NULL,
	[ContSDFPoolCY] [FLOAT] NULL,
	[ContSDFPortfolioCY] [FLOAT] NULL,
	[ContSDFSubPortfolioCY] [FLOAT] NULL,
	[ContSDFAssetClassCY] [FLOAT] NULL,
	[ContSDFPool1Yr] [FLOAT] NULL,
	[ContSDFPortfolio1Yr] [FLOAT] NULL,
	[ContSDFSubPortfolio1Yr] [FLOAT] NULL,
	[ContSDFAssetClass1Yr] [FLOAT] NULL,
	[MultipleDPI] [FLOAT] NULL,
	[MultipleRPI] [FLOAT] NULL,
	[MultipleTVPI] [FLOAT] NULL,
	[Profit1M] [NUMERIC](18, 6) NULL,
	[Profit3M] [NUMERIC](18, 6) NULL,
	[ProfitCY] [NUMERIC](18, 6) NULL,
	[ProfitJY] [NUMERIC](18, 6) NULL,
	[Profit1MReported] [NUMERIC](18, 6) NULL,
	[Commitment] [NUMERIC](18, 4) NULL,
	[AdjCommitment] [NUMERIC](18, 4) NULL,
	[UnfundedCommitment] [NUMERIC](18, 4) NULL,
	[EAMVUnfundedCommitment] [NUMERIC](18, 4) NULL,
	[AdditionalFees] [NUMERIC](18, 4) NULL,
	[CapitalCalls] [NUMERIC](18, 4) NULL,
	[Distributions1M] [NUMERIC](18, 4) NULL,
	[Distributions3M] [NUMERIC](18, 4) NULL,
	[Distributions1Yr] [NUMERIC](18, 4) NULL,
	[DistributionsQTD] [NUMERIC](18, 4) NULL,
	[DistributionsYTD] [NUMERIC](18, 4) NULL,
	[DistributionsSI] [NUMERIC](18, 4) NULL,
	[CapitalCallsFeesFirst] [NUMERIC](18, 4) NULL,
	[CapitalCallsFeesLast] [NUMERIC](18, 4) NULL,
	[CapitalCallsFees1M] [NUMERIC](18, 4) NULL,
	[CapitalCallsFees3M] [NUMERIC](18, 4) NULL,
	[CapitalCallsFees1Yr] [NUMERIC](18, 4) NULL,
	[CapitalCallsFeesQ1Prev] [NUMERIC](18, 4) NULL,
	[CapitalCallsFeesQ2Prev] [NUMERIC](18, 4) NULL,
	[CapitalCallsFeesQ3Prev] [NUMERIC](18, 4) NULL,
	[CapitalCallsFeesQ4Prev] [NUMERIC](18, 4) NULL,
	[CapitalCallsFeesQTD] [NUMERIC](18, 4) NULL,
	[CapitalCallsFeesYTD] [NUMERIC](18, 4) NULL,
	[CapitalCallsFeesSI] [NUMERIC](18, 4) NULL,
 [SMC_LoadDate] DATETIME NULL DEFAULT getdate(), 
    CONSTRAINT [PK_MonthlyPerformanceGroup] PRIMARY KEY CLUSTERED 
(
	[MonthlyPerformanceGroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


