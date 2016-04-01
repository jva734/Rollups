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
	 AND sys.tables.name = N'BatchID'
)
  DROP TABLE SMC.BatchID
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE SMC.BatchID (
	[BatchID] [int] IDENTITY(1,1) Primary Key NOT NULL
	,[BatchName] [varchar](250) NULL
	,CreateDate datetime
	,CreateUser Varchar(20) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


