/*
	SDF Perfromance Reports
*/
USE SMC_DB_Performance
GO
/*
IF object_id(N'SMC.vw_LSVFAlphaByCompany', 'V') IS NOT NULL
	DROP VIEW [SMC].vw_LSVFAlphaByCompany
GO

CREATE VIEW [SMC].vw_LSVFAlphaByCompany
AS
--*/

DECLARE @MonthEnd date = '2015-09-30'
DECLARE @LastYear date = DATEADD(YY,-1,@MonthEnd)

select @MonthEnd , @LastYear 

;WITH CTE_1YR AS (
SELECT 
	AccountNumber
	,[SecurityID]
	,MonthEnd
	,ISNULL(EAMV,0) AS EAMVLag12
	,ISNULL([MultipleDPI],0) AS MultipleDPILag12
	,ISNULL([Distributions1M],0) AS [Distributions1MLag12]
FROM SMC.MonthlyPerformanceFund
WHERE DataSource = 'CD'
  AND MonthEnd = @LastYear
)
SELECT * FROM CTE_1YR 

;WITH CTE_1 AS (
SELECT 
	AccountNumber
	,ISNULL([MellonAccountName],'') AS [AccountName]
	,[SecurityID]
	,ISNULL([CompanyName],'') AS [CompanyName]
	,ISNULL([Series],'') AS [Series]	
	,ISNULL([FirmName],'') AS [FirmName]
	,CASE [InceptionDate]
		WHEN '1900-01-01' THEN NULL
		ELSE [InceptionDate]
	END AS [InceptionDate]
	,ISNULL([VintageYear],'') AS 'Vintage Yr'
	,ISNULL([CapitalCalls],0) AS BaseCost
	,ISNULL([Distributions1M],0) AS [Distributed]
	,ISNULL(EAMV,0) AS EAMV
	,ISNULL([MultipleDPI],0) AS [Multiple TVP]
	,ISNULL([Distributions1M],0) AS [Distributions1M]
	,ISNULL([CapitalCalls],0) AS [CapitalCalls]
    ,ISNULL(LAG(EAMV,12,0) OVER (PARTITION BY [AccountNumber],[SecurityID] ORDER BY [MonthEnd] ASC) , 0) AS EAMVLag12
	,ISNULL(LAG([Distributions1M],12,0) OVER (PARTITION BY [AccountNumber],[SecurityID] ORDER BY [MonthEnd] ASC) , 0) AS Distributions1MLag12
	,ISNULL([Sector] + ' ' + [SubSector],'') AS Sector
	,ISNULL([InvestmentClassification],'') AS 'New/FollowOn'
	,CASE [SecurityStatus]
		WHEN 'Active' THEN 'Unrealized'
		ELSE 'Realized'
		END AS [Security Status]
	,ISNULL([LastReportedDate],'') AS [LastReportedDate]
	----,CASE [AccountClosed]
	----	WHEN '1900-01-01' THEN ''
	----	WHEN ISNULL([AccountClosed],'') THEN ''
	----	ELSE [AccountClosed]
	---- END AS 'Liquidated Date'
	,ISNULL([AccountClosed],'') AS [AccountClosed]
FROM SMC.MonthlyPerformanceFund
WHERE DataSource = 'CD'
and MonthEnd = '2015-09-30'
--GROUP BY AccountNumber,SecurityID,[CompanyName]
)
SELECT *
FROM CTE_1
ORDER BY AccountNumber,[CompanyName]



--SELECT 
--	AccountNumber	
--	,SecurityID
--	,MAX(ISNULL([MellonAccountName],'')) AS [AccountName]
--	,[CompanyName]
--	,MAX(ISNULL([SponsorName],'')) AS [SponsorName]
--	,MAX(ISNULL([FirmName],'')) AS [FirmName]

--	,CASE [InceptionDate]
--		WHEN '1900-01-01' THEN NULL
--		ELSE [InceptionDate]
--	END AS [InceptionDate]
