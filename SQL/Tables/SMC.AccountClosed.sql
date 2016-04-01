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
	 AND sys.tables.name = N'AccountClosed'
)
  DROP TABLE [SMC].[AccountClosed]
GO

/****** Object:  Table SMC.AccountClosed Script Date: 4/29/2015 9:56:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [SMC].[AccountClosed](
	[AccountClosedID] [int] IDENTITY(1,1) NOT NULL,
	[DataSource] [varchar](10) NULL,
	[AccountNumber] [varchar](25) NULL,
	[SecurityID] [varchar](25) NULL,
	[AccountClosed] [date] NULL,
	[MonthEnd] [date] NULL
PRIMARY KEY CLUSTERED 
(
	[AccountClosedID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO


/*
	INITIAL LOAD
	Pre load this table with existing Account Closed Dates
	TRUNCATE TABLE [SMC].[AccountClosed] 
*/

------------------
-- PI Data
-----------------
;WITH CTE_ALL AS (
	SELECT  [AccountNumber],SMCCloseDate AS AccountClosed
	FROM    [SMC_DB_ASA].[asa].[Accounts]
	WHERE	SMCCloseDate IS NOT NULL
	UNION 
	SELECT AccountNumber, MellonCloseDate  AS AccountClosed
	FROM [SMC_DB_ASA].[asa].[Accounts]
	WHERE MellonCloseDate IS NOT NULL
)
,CTE_GROUP AS (
	SELECT [AccountNumber],MIN(AccountClosed) AS AccountClosed
	FROM CTE_ALL 
	GROUP BY AccountNumber 
)
INSERT INTO [SMC].[AccountClosed] 
	(DataSource,AccountNumber,AccountClosed,MonthEnd)
	SELECT 'PI', AccountNumber, AccountClosed,EOMONTH(AccountClosed) AS MonthEnd
	FROM CTE_GROUP 

------------------
-- CD Data
-----------------
INSERT INTO [SMC].[AccountClosed] 
	(DataSource,AccountNumber,SecurityID,AccountClosed,MonthEnd)
SELECT MIN('CD') AS DataSource
	, ASA.[AccountNumber]
	, S.MellonSecurityID
	, MIN(SA.LiquidatedDate) AS AccountClosed 
	, EOMONTH(MIN(SA.LiquidatedDate)) AS MonthEnd
FROM [SMC_DB_ASA].[asa].[Accounts] ASA 
	INNER JOIN [SMC_DB_ASA].[asa].[SecurityAccounts] SA ON SA.[Accountid] = ASA.Accountid 
	INNER JOIN [SMC_DB_ASA].[asa].[Securities]  S ON S.securityid = SA.securityid 
	INNER JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON FL.[LookupId] = ASA.[StructureType]
WHERE SA.LiquidatedDate IS NOT NULL 
  AND ASA.IsCustodied = 1 
  AND FL.LookupText = 'Direct' 
GROUP BY ASA.[AccountNumber],S.MellonSecurityID
