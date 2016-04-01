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
	 AND sys.tables.name = N'MonthlyPerformanceGroupIRRThread'
)
  DROP TABLE SMC.MonthlyPerformanceGroupIRRThread
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [SMC].[MonthlyPerformanceGroupIRRThread](
	[MonthlyPerformanceGroupIRRID] [BIGINT] IDENTITY(1,1) NOT NULL,
	[GroupName] [VARCHAR](100) NULL,
	[GroupDesc] [VARCHAR](255) NULL,
	[MonthEnd] [DATE] NULL,
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
 [SMC_LoadDate] DATETIME NULL DEFAULT getdate(), 
    CONSTRAINT [PK_MonthlyPerformanceGroupIRRThread] PRIMARY KEY CLUSTERED 
(
	[MonthlyPerformanceGroupIRRID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


