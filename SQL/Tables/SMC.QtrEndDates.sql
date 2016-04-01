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
	 AND sys.tables.name = N'QtrEndDate'
)
  DROP TABLE [SMC].[QtrEndDate]
GO

/****** Object:  Table SMC.AccountClosed Script Date: 4/29/2015 9:56:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [SMC].QtrEndDate(
	[QtrEndDateID] [int] IDENTITY(1,1) NOT NULL,
	[QtrEnd] [date] NULL
PRIMARY KEY CLUSTERED 
(
	[QtrEndDateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

