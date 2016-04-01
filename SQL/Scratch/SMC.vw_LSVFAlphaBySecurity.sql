/*
	SDF Perfromance Reports
	SELECT * FROM [SMC].vw_LSVFAlphaBySecurity
*/
USE SMC_DB_Performance
GO

/*
IF object_id(N'SMC.vw_LSVFAlphaBySecurity', 'V') IS NOT NULL
	DROP VIEW [SMC].vw_LSVFAlphaBySecurity
GO

CREATE VIEW [SMC].vw_LSVFAlphaBySecurity
AS

--*/
DECLARE @MonthEnd date = '2015-09-30'
DECLARE @LastYear date = DATEADD(YY,-1,@MonthEnd)

--select @MonthEnd , @LastYear 

/*
------------------------------------------------------------------------------------------------------
CTE_QtrEnd 
------------------------------------------------------------------------------------------------------
*/
;WITH CTE_QtrEnd_Base AS (
SELECT 
	AccountNumber
	,[CompanyName]
	,[SecurityID]
	,MonthEnd AS QtrEnd
	,ISNULL(EAMV,0) AS EAMVQtr
	,ISNULL([MultipleDPI],0) AS MultipleDPIQtr
	,ISNULL([MellonAccountName],'') AS [AccountName]
	,ISNULL([Series],'') AS [Series]	
	,ISNULL([SponsorName],'') AS [SponsorName]	
	,ISNULL([FirmName],'') AS [FirmName]
	,CASE [InceptionDate]
		WHEN '1900-01-01' THEN NULL
		ELSE [InceptionDate]
	END AS [InceptionDate]
	,[VintageYear]
	,CASE [SecurityStatus]
		WHEN 'Active' THEN 'Unrealized'
		ELSE 'Realized'
		END AS [Security Status]
	,ISNULL([Sector],'')  AS [Sector]
	,ISNULL([SubSector],'') AS [SubSector]
	,ISNULL([InvestmentClassification],'') AS 'New/FollowOn'
	,ISNULL([LastReportedDate],'') AS 'Valuation Date'
	,CASE [AccountClosed]
		WHEN '1900-01-01' THEN NULL
		ELSE [AccountClosed]
	 END AS [AccountClosed]
FROM SMC.MonthlyPerformanceFund MP
WHERE DataSource = 'CD' AND MonthEnd = @MonthEnd
)
/*------------------------------------------------------------------------------------------------------
SELECT DISTINCT AccountNumber,[SecurityID] FROM CTE_QtrEnd Q ORDER BY AccountNumber,[CompanyName],[SecurityID] -- 2651
--*/
/*------------------------------------------------------------------------------------------------------
SELECT * FROM CTE_QtrEnd Q ORDER BY AccountNumber,[CompanyName],[SecurityID] -- 2561
--*/


/*
------------------------------------------------------------------------------------------------------
CTE_QtrEnd_1YR
------------------------------------------------------------------------------------------------------
*/
,CTE_QtrEnd_1YR AS (
SELECT Q.*
	,MP.MonthEnd AS MonthEndLag12
	,ISNULL(EAMV,0) AS EAMVLag12
	--,ISNULL([MultipleDPI],0) AS MultipleDPILag12
	--,ISNULL([Distributions1M],0) AS [Distributions1MLag12]
FROM CTE_QtrEnd_Base  Q
	LEFT JOIN SMC.MonthlyPerformanceFund MP ON 
			Q.AccountNumber = MP.AccountNumber 
		AND Q.[SecurityID] = MP.[SecurityID]
		AND MP.DataSource = 'CD' 
		AND MP.MonthEnd = @LastYear
)
/*------------------------------------------------------------------------------------------------------
SELECT DISTINCT AccountNumber,[SecurityID] FROM CTE_Qtr_1YR ORDER BY  AccountNumber,[CompanyName],[SecurityID]
-- 2287
--*/
/*------------------------------------------------------------------------------------------------------
SELECT * FROM CTE_QtrEnd_1YR ORDER BY  AccountNumber,[CompanyName],[SecurityID] -- 2561
--*/


/*
--=======================================================================================================
CTE_QtrEnd_1YR_SUMQtr 
--=======================================================================================================
--*/
,CTE_SUMQtr AS (
SELECT  Q.AccountNumber	
		,Q.[SecurityID]	
		,SUM([CapitalCalls]) AS [CapitalCallsTotalQtr]
		,SUM([Distributions1M]) AS [DistributionsTotalQtr]
	--,SUM([CapitalCalls]) OVER (PARTITION BY Q.AccountNumber,Q.[SecurityID]) AS [CapitalCallsTotalQtr]
	--,SUM([Distributions1M]) OVER (PARTITION BY Q.AccountNumber,Q.[SecurityID]) AS [DistributionsTotalQtr]
FROM CTE_QtrEnd_1YR Q
	LEFT JOIN SMC.MonthlyPerformanceFund MP ON 
			Q.AccountNumber = MP.AccountNumber 
		AND Q.[SecurityID] = MP.[SecurityID]
		AND MP.DataSource = 'CD' 
		AND MP.MonthEnd <= @MonthEnd 
GROUP BY Q.AccountNumber,Q.[SecurityID]
)
/*------------------------------------------------------------------------------------------------------
SELECT * FROM CTE_QtrEnd_1YR_SUMQtr Q
ORDER BY Q.AccountNumber,Q.[SecurityID]
--*/

/*
--=======================================================================================================
CTE_QtrEnd_1YR_SUMQtr 
--=======================================================================================================
--*/
,CTE_SUMYr AS (
SELECT   Q.AccountNumber	
		,Q.[SecurityID]	
	,SUM([CapitalCalls]) AS [CapitalCallsTotalYr]
	,SUM([Distributions1M]) AS [DistributionsTotalYr]
FROM CTE_QtrEnd_1YR Q
	LEFT JOIN SMC.MonthlyPerformanceFund MP ON 
			Q.AccountNumber = MP.AccountNumber 
		AND Q.[SecurityID] = MP.[SecurityID]
		AND MP.DataSource = 'CD' 
		AND MP.MonthEnd <= @LastYear 
GROUP BY Q.AccountNumber,Q.[SecurityID]
)
/*------------------------------------------------------------------------------------------------------
SELECT * FROM CTE_QtrEnd_1YR_SUMQtr_SUMYr -- 2709
--*/
-- JVA UP TO HERE
SELECT 
	 Q.AccountNumber
	,Q.[AccountName]
	,Q.[SecurityID]
	,Q.[CompanyName]
	,Q.[Series]	
	,Q.[SponsorName]
	,Q.[FirmName]
	,Q.[InceptionDate]
	,YEAR(Q.[InceptionDate]) AS 'Vintage Year'
	,SQ.[CapitalCallsTotalQtr] AS [Base Cost]
	,SQ.[DistributionsTotalQtr] AS [Distributed]
	,Q.EAMVQtr AS EAMV
	,Q.MultipleDPIQtr AS 'Multiple TVP'
	,(Q.EAMVQtr + SQ.[CapitalCallsTotalQtr] - SQ.[DistributionsTotalQtr]) AS 'Appreciation ITD'
	,(Q.EAMVQtr + SQ.[CapitalCallsTotalQtr] - SQ.[DistributionsTotalQtr]) - (Q.EAMVLag12 + [DistributionsTotalYr] - [CapitalCallsTotalYr]) AS 'Appreciation 1Yr'
	,Q.[Sector] + ' ' + Q.[SubSector] AS [Sector]
	,[New/FollowON]
	,Q.[Security Status]
	,[Valuation Date]
	,[AccountClosed]

FROM CTE_QtrEnd_1YR Q 
	LEFT JOIN CTE_SUMQtr  SQ ON Q.AccountNumber = SQ.AccountNumber AND Q.[SecurityID] = SQ.[SecurityID]
	LEFT JOIN CTE_SUMYr   SY ON Q.AccountNumber = SY.AccountNumber AND Q.[SecurityID] = SY.[SecurityID]

ORDER BY Q.AccountNumber,Q.[CompanyName],Q.[SecurityID]
