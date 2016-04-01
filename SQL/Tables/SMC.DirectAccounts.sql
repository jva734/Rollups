--SELECT * FROM [SMC].[DirectAccounts]

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
	 AND sys.tables.name = N'DirectAccounts'
)
  DROP TABLE [SMC].[DirectAccounts]
GO

/****** Object:  Table [SMC].[Transactions]    Script Date: 6/9/2015 1:41:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [SMC].[DirectAccounts](
	[DirectAccountsID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[AccountNumber] [varchar](50) NULL,
	[AccountName] [nvarchar](255) NULL,
) ON [PRIMARY]

GO

INSERT INTO [SMC].[DirectAccounts]
           ([AccountNumber]
           ,[AccountName])
     VALUES
		('LSJF30020002',	'DAPER I/DIR PRIV VEN')
		,('LSJF30170002',	'DAPER I/DIR PUB VEN')
		,('LSJF30180002',	'DAPER I/DIR PUB L/E')
		,('LSJF30220002',	'DAPER I/DIR PRV L/E')
		,('LSJF35030002',	'DAPER II/DIR PRV VEN')
		,('LSJF35160002',	'DAPER II/DIR PUB VEN')
		,('LSJF35200002',	'DAPER II/DIR PRV L/E')
		,('LSJF35210002',	'DAPER II/DIR PRV BO')
		,('LSJF35220002',	'DAPER II/DIR PR RE')
		,('LSJF45000002',	'SEVF II/DIR PRV VEN')
		,('LSJF45060002',	'SEVF II/DIR PUB VEN')
		,('LSJF45090002',	'SEVF II/DIR PRV L/E')
		,('LSJF70060002',	'SBST/DIRECT PRV VEN')
		,('LSJF70280002',	'SBST/DIR PUB VEN')
		,('LSJF70290002',	'SBST/DIR PUB L/E')
		,('LSJF70310002',	'SBST/VEN DIST')
		,('LSJF70350002',	'SBST/DIR PRV L/E')
		,('LSJF70360002',	'SBST/DIRECT BUYOUT')
		,('LSJF70430002',	'SBST/DIR PRV VEN LS')
		,('LSJF80000002',	'OTL')
		,('LSJF80010002',	'OTL/DIR PUB VEN')
		,('LSJF80020002',	'OTL/DIR PUB LE')
		,('LSJF85000002',	'LSVF/DIR PRIV VEN')
		,('LSJF85050002',	'LSVF/DIR PUB VEN')
		,('LSJF86000002',	'PVF/DIR INV-PRIVATE')
		,('LSJF86010002',	'PVF/DIR INV-PUBLIC')
		,('LSJF86020002',	'STARTX/DIRECT INV PR')
		,('LSJF86030002',	'STARTX/DIRECT INV PB')

GO

