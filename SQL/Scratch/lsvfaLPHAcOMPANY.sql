/*==================================================================================
	Author John Alton 2/4/2016
	Modifications
	Name			Date		Description

====================================================================================

Execution
EXECUTE SMC.usp_LSVFAlphaSecurity '2015-09-30 12:00:00 AM','DAPER I/DIR PRIV VEN,LSVF/DIR PUB VEN',NULL,NULL
EXECUTE SMC.usp_LSVFAlphaSecurity '2015-09-30 12:00:00 AM','DAPER I/DIR PRIV VEN,LSVF/DIR PUB VEN','Tim Connors,Brad Jones,Marc Andreessen',NULL
EXECUTE SMC.usp_LSVFAlphaSecurity '2015-09-30',NULL,NULL,NULL

SELECT QtrEnd FROM [SMC].QtrEndDate ORDER BY QtrEnd DESC

*/

/*======================  lINE LEVEL Query
SELECT [AccountNumber] 
	,[CompanyName]
	,SECURITYID
	,ASA_Account
	,CASE 
		WHEN ASA_Account IS NULL THEN 'Realized'
		WHEN ASA_Account = 1 AND [SecurityStatus] = 'Active' THEN 'Unrealized'
		ELSE 'Realized'
	 END AS [Security Status]

	,ISNULL([Sector],'')  AS [Sector]
	,ISNULL([SubSector],'') AS [SubSector]
	,ISNULL([InvestmentClassification],'') AS 'New/FollowOn'
	,ISNULL([LastReportedDate],'') AS LastReportedDate


	,[InceptionDate]
	,EAMV
	,MonthEnd AS QtrEnd
	,ISNULL(EAMV,0) AS EAMVQtr
	,ISNULL([MellonAccountName],'') AS [AccountName]
	,ISNULL([Series],'') AS [Series]	
	,ISNULL([SponsorName],'') AS [SponsorName]	
	,ISNULL([FirmName],'') AS [FirmName]
FROM [SMC].[MonthlyPerformanceFund]
WHERE [AccountNumber] = 'LSJF35210002' AND DataSource = 'CD' AND MonthEnd = '2015-09-30' and CompanyName = 'Sunnova Energy Corporation'
	

WHERE [AccountNumber] = 'LSJF30020002' AND DataSource = 'CD' AND MonthEnd = '2015-09-30' and CompanyName = 'AccelOps'
--is not null
order by [AccountNumber],[CompanyName]


*/


/*
SELECT [AccountNumber] 
	,[CompanyName]
	,COUNT(SECURITYID)			AS SecurityCount
	,MAX([MellonAccountName])	AS [AccountName]
	,MAX([Series])				AS [Series]	
	,MAX([SponsorName])			AS [SponsorName]	
	,MAX([FirmName])			AS [FirmName]
	,MIN([InceptionDate])		AS [InceptionDate]
	,ISNULL(SUM(EAMV),0)				AS EAMV
	,ISNULL(SUM(ABS([CapitalCalls])),0)	AS [CapitalCalls]
	,ISNULL(SUM([Distributions1M]),0)	AS [Distributions]
	,ISNULL(SUM(AdditionalFees),0)		AS [AdditionalFees]
FROM [SMC].[MonthlyPerformanceFund]
WHERE DataSource = 'CD' AND MonthEnd = '2015-09-30'
and CompanyName is not null
GROUP by [AccountNumber],[CompanyName]
order by [AccountNumber],[CompanyName]

*/
USE SMC_DB_Performance
GO



/*
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_LSVFAlphaCompany' 
)
   DROP PROCEDURE SMC.usp_LSVFAlphaCompany
GO

CREATE PROCEDURE SMC.usp_LSVFAlphaCompany
	 @QtrEndDate date 
	,@AccountName NVARCHAR(MAX) = NULL
 	,@SponsorName NVARCHAR(MAX) = NULL
	,@SecurityStatus NVARCHAR(120) = NULL
AS
--*/

--/*==========================    DEBUG   =======================================
DECLARE @QtrEndDate date 
	,@AccountName NVARCHAR(MAX)
	,@SponsorName NVARCHAR(512)
	,@SecurityStatus NVARCHAR(120)

SET @QtrEndDate = '2015-09-30'
SET @AccountName = 'DAPER I/DIR PRIV VEN'
SET @SponsorName  = 'Greg Sands'
SET @SecurityStatus  = 'Realized'

SET @AccountName = NULL
SET @SponsorName  = NULL
SET @SecurityStatus  = NULL
--==========================    END DEBUG   =======================================
--*/

DECLARE @LastYear date = DATEADD(YY,-1,@QtrEndDate)
	,@SQL NVARCHAR(MAX)

IF OBJECT_ID('tempdb..#PreFilter') IS NOT NULL
BEGIN
    DROP TABLE #PreFilter
END

IF OBJECT_ID('tempdb..#ID') IS NOT NULL
BEGIN
    DROP TABLE #ID
END

IF OBJECT_ID('tempdb..#AccountName') IS NOT NULL
BEGIN
    DROP TABLE #AccountName
END

--IF OBJECT_ID('tempdb..#SponsorName') IS NOT NULL
--BEGIN
--    DROP TABLE #SponsorName
--END


CREATE TABLE #PreFilter (
MonthlyPerformanceFundID BIGINT
,MonthEnd datetime
,MellonAccountName NVARCHAR(80)
,SponsorName NVARCHAR(512)
,SecurityStatus NVARCHAR(120)
)

CREATE TABLE #ID (
MonthlyPerformanceFundID BIGINT
)

CREATE TABLE #AccountName (AccountName varchar(500))
--CREATE TABLE #SponsorName (SponsorName varchar(512))

INSERT INTO #PreFilter
	SELECT MonthlyPerformanceFundID
		,MonthEnd
		,MellonAccountName
		,SponsorName
		,CASE 
			WHEN ASA_Account IS NULL THEN 'Realized'
			WHEN ASA_Account = 1 AND [SecurityStatus] = 'Active' THEN 'Unrealized'
			ELSE 'Realized'
		END AS [SecurityStatus]
	FROM SMC.MonthlyPerformanceFund
	WHERE DataSource = 'CD' AND MonthEnd = CAST(@QtrEndDate AS VARCHAR(20))

--SELECT * FROM #PreFilter
 
SET @SQL = N'INSERT INTO #ID 
	SELECT MonthlyPerformanceFundID
	FROM #PreFilter
	WHERE 1 = 1 '

IF @AccountName IS NOT NULL
	BEGIN
		INSERT INTO #AccountName SELECT * FROM [dbo].[ufn_SplitString](@AccountName,',')
		SET @SQL = @SQL + ' AND MellonAccountName  IN (SELECT AccountName FROM #AccountName) '
		--SET @SQL = @SQL + ' AND MellonAccountName = ' + '''' + CAST(@AccountName AS VARCHAR(80)) + '''' 
	END
IF @SponsorName IS NOT NULL
	BEGIN	
		--INSERT INTO #SponsorName SELECT * FROM [dbo].[ufn_SplitString](@SponsorName,',')
		--SET @SQL = @SQL + ' AND SponsorName  IN (SELECT SponsorName FROM #SponsorName) '
		SET @SQL = @SQL + ' AND SponsorName = ' + '''' + CAST(@SponsorName AS VARCHAR(512)) + '''' 
	END
IF @SecurityStatus IS NOT NULL AND @SecurityStatus <> 'All'
	BEGIN
		SET @SQL = @SQL + ' AND SecurityStatus = ' + '''' + CAST(@SecurityStatus AS VARCHAR(120)) + '''' 
	END

--PRINT @SQL

EXECUTE sp_executesql @SQL

--SELECT * FROM #ID 

 
/*
------------------------------------------------------------------------------------------------------
CTE_QtrEnd 
------------------------------------------------------------------------------------------------------
*/
;WITH CTE_QtrEnd_Base AS (
	SELECT [AccountNumber] 
		,[CompanyName]
		,COUNT(SECURITYID)			AS SecurityCount
		,MAX(MonthEnd) AS QtrEnd
		,MAX([MellonAccountName])	AS [AccountName]
		,MAX([Series])				AS [Series]	
		,MAX([SponsorName])			AS [SponsorName]	
		,MAX([FirmName])			AS [FirmName]
		,MIN([InceptionDate])		AS [InceptionDate]
		,ISNULL(SUM(EAMV),0)				AS EAMV
		,ISNULL(SUM(ABS([CapitalCalls])),0)	AS [CapitalCalls]
		,ISNULL(SUM([Distributions1M]),0)	AS [Distributions]
		,ISNULL(SUM(AdditionalFees),0)		AS [AdditionalFees]
		,ISNULL(MAX([Sector]),'')  AS [Sector]
		,ISNULL(MAX([SubSector]),'') AS [SubSector]
		,ISNULL(MAX([InvestmentClassification]),'') AS 'New/FollowOn'
		,ISNULL(MAX([LastReportedDate]),'') AS LastReportedDate
		,MAX([AccountClosed]) AS [AccountClosed]		
		,MAX(CAST(ISNULL(ASA_Account,0) AS INT)) AS ASA_AccountMAX

		,MAX([SecurityStatus]) AS SecurityStatusMAX
		,MIN([SecurityStatus]) AS SecurityStatusMIN
	FROM SMC.MonthlyPerformanceFund MP 
		INNER JOIN #ID A ON A.MonthlyPerformanceFundID = MP.MonthlyPerformanceFundID
		and CompanyName is not null
	GROUP by [AccountNumber],[CompanyName]
)
--/*------------------------------------------------------------------------------------------------------
SELECT Q.*
	,CASE 
		WHEN ASA_AccountMAX IS NULL THEN 'Realized'
		WHEN ASA_AccountMAX = 1 AND SecurityStatusMAX = 'Active' THEN 'Unrealized'
		ELSE 'Realized'
	 END AS [Security Status]
 FROM CTE_QtrEnd_Base Q ORDER BY SecurityCount

--AccountNumber,[CompanyName]
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
SELECT * FROM CTE_QtrEnd_1YR ORDER BY  AccountNumber,[CompanyName],[SecurityID] -- 2561
--*/


/*
--=======================================================================================================
CTE_SUMQtr 
--=======================================================================================================
--*/
,CTE_SUMQtr AS (
SELECT  Q.AccountNumber	
		,Q.[SecurityID]	
		,SUM(ABS([CapitalCalls])) AS [CapitalCallsTotalQtr]
		,SUM([Distributions1M]) AS [DistributionsTotalQtr]
		,SUM(AdditionalFees) AS AdditionalFeesTotalQtr

	--,SUM([CapitalCalls]) OVER (PARTITION BY Q.AccountNumber,Q.[SecurityID]) AS [CapitalCallsTotalQtr]
	--,SUM([Distributions1M]) OVER (PARTITION BY Q.AccountNumber,Q.[SecurityID]) AS [DistributionsTotalQtr]
FROM CTE_QtrEnd_1YR Q
	LEFT JOIN SMC.MonthlyPerformanceFund MP ON 
			Q.AccountNumber = MP.AccountNumber 
		AND Q.[SecurityID] = MP.[SecurityID]
		AND MP.DataSource = 'CD' 
		AND MP.MonthEnd <= @QtrEndDate 
GROUP BY Q.AccountNumber,Q.[SecurityID]

)
/*------------------------------------------------------------------------------------------------------
SELECT * FROM CTE_QtrEnd_1YR_SUMQtr Q ORDER BY Q.AccountNumber,Q.[SecurityID]
--*/

/*
--=======================================================================================================
CTE_SUMYr
--=======================================================================================================
--*/
,CTE_SUMYr AS (
SELECT   Q.AccountNumber	
		,Q.[SecurityID]	
	,SUM(ABS([CapitalCalls])) AS [CapitalCallsTotalYr]
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
/*
Final Results
*/
SELECT 
	 Q.AccountNumber
	,Q.[AccountName]
	,Q.[SecurityID]
	,Q.[CompanyName]
	,Q.[Series]	
	,Q.[SponsorName]
	,Q.[FirmName]
	,CAST(Q.[InceptionDate] AS VARCHAR(10)) AS [Inception Date]
	,YEAR(Q.[InceptionDate]) AS 'Vintage Year'
	,SQ.[CapitalCallsTotalQtr] AS [Base Cost]
	,SQ.[DistributionsTotalQtr] AS [Distributed]
	,Q.EAMVQtr AS EAMV
	,CASE 
		WHEN (Q.EAMVQtr + DistributionsTotalQtr) = 0 THEN 0
		WHEN (CapitalCallsTotalQtr + AdditionalFeesTotalQtr)= 0 THEN 0
		ELSE ((Q.EAMVQtr + DistributionsTotalQtr) / (CapitalCallsTotalQtr + DistributionsTotalQtr))
	END 'Multiple TVP'

	,(Q.EAMVQtr + SQ.[CapitalCallsTotalQtr] - SQ.[DistributionsTotalQtr]) AS 'Appreciation ITD'
	,(Q.EAMVQtr + SQ.[CapitalCallsTotalQtr] - SQ.[DistributionsTotalQtr]) - (Q.EAMVLag12 + [DistributionsTotalYr] - [CapitalCallsTotalYr]) AS 'Appreciation 1Yr'
	,Q.[Sector] + ' ' + Q.[SubSector] AS [Sector]
	,[New/FollowON]
	,Q.[Security Status]
	,CAST(LastReportedDate AS VARCHAR(10)) AS [Valuation Date] 
	,[AccountClosed]

	--,CASE RTRIM(LTRIM(Q.[AccountClosed]))
	--	WHEN '1900-01-01' THEN ''
	--	ELSE [AccountClosed]
	-- END AS [AccountClosed]


FROM CTE_QtrEnd_1YR Q 
	LEFT JOIN CTE_SUMQtr  SQ ON Q.AccountNumber = SQ.AccountNumber AND Q.[SecurityID] = SQ.[SecurityID]
	LEFT JOIN CTE_SUMYr   SY ON Q.AccountNumber = SY.AccountNumber AND Q.[SecurityID] = SY.[SecurityID]

ORDER BY Q.AccountNumber,[AccountName],Q.[CompanyName],Q.[SecurityID]


GO

