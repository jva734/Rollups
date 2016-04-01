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
	 AND sys.tables.name = N'XIRR_MonthlyPerformance'
)
  DROP TABLE SMC.XIRR_MonthlyPerformance
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [SMC].[XIRR_MonthlyPerformance](
	[XIRR_MonthlyPerformanceID] [INT] IDENTITY(1,1) NOT NULL
	,[AccountNumber] [VARCHAR](25) NULL
	,[SecurityID] [VARCHAR](25) NULL
	,[MonthStart] [DATE] NULL
	,[MonthEnd] [DATE] NULL
	,MonthEndLag3 [DATE] NULL
	,MonthEndLag12 [DATE] NULL
	,MonthEndLag36 [DATE] NULL
	,MonthEndLag60 [DATE] NULL
	,MonthEndLag84 [DATE] NULL
	,MonthEndLag120 [DATE] NULL
	,[EAMV] [DECIMAL](18, 4) NULL
PRIMARY KEY CLUSTERED 
(
	[XIRR_MonthlyPerformanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

