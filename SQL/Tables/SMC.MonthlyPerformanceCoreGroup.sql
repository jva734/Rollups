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
	 AND sys.tables.name = N'MonthlyPerformanceCoreGroup'
)
  DROP TABLE SMC.MonthlyPerformanceCoreGroup
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [SMC].[MonthlyPerformanceCoreGroup](
	[MonthlyPerformanceCoreGroupID] [BIGINT] IDENTITY(1,1) NOT NULL,
	[GroupName] [VARCHAR](100) NULL,
	[GroupDesc] [VARCHAR](255) NULL,
	[MonthEnd] [DATE] NULL,
	[InceptionDate] [DATE] NULL,
	[MinMonthEnd] [DATE] NULL,
	[MaxMonthEnd] [DATE] NULL,
	[ACBPMD] [NUMERIC](18, 4) NULL,
	[ACBReported] [NUMERIC](18, 4) NULL,
	[EAMV] [NUMERIC](18, 4) NULL,
	[MarketValue] [NUMERIC](18, 4) NULL,
	[MVReported] [NUMERIC](18, 4) NULL,
	[TWRPMD] [FLOAT] NULL,
	[TWRReported] [FLOAT] NULL,
	[MultipleDPI] [FLOAT] NULL,
	[MultipleRPI] [FLOAT] NULL,
	[MultipleTVPI] [FLOAT] NULL,
	[ProfitPMD] [NUMERIC](18, 6) NULL,
	[ProfitReported] [NUMERIC](18, 6) NULL,
	[Commitment] [NUMERIC](18, 4) NULL,
	[AdjCommitment] [NUMERIC](18, 4) NULL,
	[UnfundedCommitment] [NUMERIC](18, 4) NULL,
	[EAMVUnfundedCommitment] [NUMERIC](18, 4) NULL,
	[PoolTotal] [NUMERIC](18, 4) NULL,
	[PortfolioTotal] [NUMERIC](18, 4) NULL,
	[SubPortfolioTotal] [NUMERIC](18, 4) NULL,
	[AssetClassTotal] [NUMERIC](18, 4) NULL,
	[ContSDFPool] [FLOAT] NULL,
	[ContSDFPortfolio] [FLOAT] NULL,
	[ContSDFSubPortfolio] [FLOAT] NULL,
	[ContSDFAssetClass] [FLOAT] NULL,
	[AdditionalFees] [NUMERIC](18, 4) NULL,
	[CapitalCalls] [NUMERIC](18, 4) NULL,
	[Distributions] [NUMERIC](18, 4) NULL,
	[CapitalCallsFees] [NUMERIC](18, 4) NULL,
	[CapitalCallsFeesFirst] [NUMERIC](18, 4) NULL,
	[CapitalCallsFeesLast] [NUMERIC](18, 4) NULL,
 [SMC_LoadDate] DATETIME NULL DEFAULT getdate(), 
    CONSTRAINT [PK_MonthlyPerformanceCoreGroup] PRIMARY KEY CLUSTERED 
(
	[MonthlyPerformanceCoreGroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


