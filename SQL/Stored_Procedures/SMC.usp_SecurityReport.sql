/*============================ ISSUES =============================================================================================

The file looks great! To answer your question regarding Unrealized vs Realized I would use the following rule:
•	Set all to “Realized” to start – then match with ASA and if Security Status equals “Active”, then change to “Unrealized”. 
(SEE BELOW)
I also looked through the file and have a couple of other comments that I can work with you to address:
•	I noticed that a majority of the Base Cost are negative, but they should be positive (I think Mellon data has it as a negative). Therefore, could we set a rule to make it absolute value so that all values are positive (some are already positive so I don’t want those to go negative if we just change the sign)
JVA - CONVERT SOURCE VALUE TO ABSOLUTE VALUE
•	The Multiple column is not calculating and has zero for most securities – we can work on this to get it to calculate
JVA -To review with Daniel
•	The Valuation date seems to not be working for most of the securities as most are 1/1/1900. We can work together to figure this out.

•	Lastly, I noticed that the system is still using older data, some of which we have updated over the past few weeks with this project in mind. However, our changes are not being reflected so it is hard to check that everything is correct. Is there a way to refresh the data in the system?

SELECT ' All' AS [SponsorName]
UNION ALL

FORMAT ( QtrEnd , 'd', 'en-US' )

select *
FROM SMC.MonthlyPerformanceFund MP 
--where AccountNumber = 'LSJF30020002' AND SecurityID = '99VVA9KD0' 
where AccountNumber = 'LSJF30020002' AND SecurityID = '99VVA82Y6' 

order by monthEnd desc



INNER JOIN #ID A ON A.MonthlyPerformanceFundID = MP.MonthlyPerformanceFundID

*/


/*
=============================================
	Author John Alton 1/29/2016
	Modifications
	Name			Date		Description

=============================================
DAPER I/DIR PRIV VEN,LSVF/DIR PUB VEN
EXECUTE SMC.usp_LSVFAlphaSecurity '2015-09-30 12:00:00 AM','DAPER I/DIR PRIV VEN,LSVF/DIR PUB VEN',NULL,NULL
EXECUTE SMC.usp_LSVFAlphaSecurity '2015-09-30 12:00:00 AM','DAPER I/DIR PRIV VEN,LSVF/DIR PUB VEN','Tim Connors,Brad Jones,Marc Andreessen',NULL
AND MellonAccountName  IN ('DAPER I/DIR PRIV VEN','LSVF/DIR PRIV VEN')
AND SponsorName IN ('Tim Connors','Brad Jones','Marc Andreessen')


EXECUTE SMC.usp_SecurityReport '2015-12-31',NULL,NULL,NULL
SELECT 'SecurityReport_' + FORMAT( GETDATE(), 'yyyy_MM_dd', 'en-US' ) AS 'FileNAme'

379 null company

SELECT QtrEnd FROM [SMC].QtrEndDate ORDER BY QtrEnd DESC

*/

USE SMC_DB_Performance
GO


--/*
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_SecurityReport' 
)
   DROP PROCEDURE SMC.usp_SecurityReport
GO

CREATE PROCEDURE SMC.usp_SecurityReport
	 @QtrEndDate date 
	,@AccountName NVARCHAR(MAX) = NULL
 	,@SponsorName NVARCHAR(MAX) = NULL
	,@SecurityStatus NVARCHAR(120) = NULL
AS
--*/

--
/*==========================    DEBUG   =======================================
DECLARE @QtrEndDate date 
	,@AccountName NVARCHAR(MAX)
	,@SponsorName NVARCHAR(512)
	,@SecurityStatus NVARCHAR(120)

SET @QtrEndDate = '2015-12-31'
SET @AccountName = 'DAPER I/DIR PRIV VEN'
SET @SponsorName  = 'Greg Sands'
SET @SecurityStatus  = 'Realized'

--SET @AccountName = NULL
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

IF OBJECT_ID('tempdb..#SponsorName') IS NOT NULL
BEGIN
    DROP TABLE #SponsorName
END


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
CREATE TABLE #SponsorName (SponsorName varchar(512))

INSERT INTO #PreFilter
	SELECT MonthlyPerformanceFundID
		,MonthEnd
		,MellonAccountName
		,SponsorName
		,CASE 
			WHEN ASA_Account IS NULL THEN 'Realized'
			WHEN ASA_Account = 1 AND [SecurityStatus] IN ('Active','Active Converted New') THEN 'Unrealized'
			ELSE 'Realized'
		END AS [SecurityStatus]
	FROM SMC.MonthlyPerformanceFund
	WHERE DataSource = 'CD' 
			AND MonthEnd = CAST(@QtrEndDate AS VARCHAR(20))
			AND InceptionDate <= CAST(@QtrEndDate AS VARCHAR(20))

--
/*
SELECT * FROM #PreFilter
--*/
 
SET @SQL = N'INSERT INTO #ID 
	SELECT MonthlyPerformanceFundID
	FROM #PreFilter
	WHERE 1 = 1 '

--IF @AccountName IS NOT NULL
--	BEGIN
--		SET @SQL = @SQL + ' AND MellonAccountName = ' + '''' + CAST(@AccountName AS VARCHAR(80)) + '''' 
--	END
IF @AccountName IS NOT NULL
	BEGIN
		--SET @SQL = @SQL + ' AND MellonAccountName = ' + '''' + CAST(@AccountName AS VARCHAR(80)) + '''' 
		INSERT INTO #AccountName SELECT * FROM [dbo].[ufn_SplitString](@AccountName,',')
		SET @SQL = @SQL + ' AND MellonAccountName  IN (SELECT AccountName FROM #AccountName) '

	END

IF @SponsorName IS NOT NULL
	BEGIN	
		INSERT INTO #SponsorName SELECT * FROM [dbo].[ufn_SplitString](@SponsorName,',')
		SET @SQL = @SQL + ' AND SponsorName  IN (SELECT SponsorName FROM #SponsorName) '


	--	SET @SQL = @SQL + ' AND SponsorName = ' + '''' + CAST(@SponsorName AS VARCHAR(512)) + '''' 
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
SELECT 
	AccountNumber
	,[CompanyName]
	,[SecurityID]
	,MonthEnd AS QtrEnd

	,CASE
		WHEN ISNULL([SecurityStatus],'') IN ('Write-Off', 'Write-Off Converted New', 'Write-Off Converted Old') THEN 0
		ELSE EAMV
	END AS EamvQtr

	,CASE
		WHEN ISNULL([SecurityStatus],'') IN ('Write-Off', 'Write-Off Converted New', 'Write-Off Converted Old') AND [AccountClosed] IS NOT NULL THEN [AccountClosed]
		WHEN ISNULL([SecurityStatus],'') IN ('Write-Off', 'Write-Off Converted New', 'Write-Off Converted Old') AND [AccountClosed] IS NULL THEN LastReportedDate
		ELSE LastReportedDate
	END AS LastReportedDate_Mix
	,[AccountClosed]

	,ISNULL([MellonAccountName],'') AS [AccountName]
	,ISNULL([Series],'') AS [Series]	
	,ISNULL([SponsorName],'') AS [SponsorName]	
	,ISNULL([FirmName],'') AS [FirmName]
	,CASE [InceptionDate]
		WHEN '1900-01-01' THEN NULL
		ELSE [InceptionDate]
	END AS [InceptionDate]
	,[VintageYear]
	,Shares

	,CASE 
		WHEN ASA_Account IS NULL THEN 'Realized'
		WHEN ASA_Account = 1 AND [SecurityStatus] IN ('Active','Active Converted New') THEN 'Unrealized'
		ELSE 'Realized'
	 END AS [Security Status]

	,ISNULL([Sector],'')  AS [Sector]
	,ISNULL([SubSector],'') AS [SubSector]
	,ISNULL([InvestmentClassification],'') AS 'New/FollowOn'
	,ASA_Account
FROM SMC.MonthlyPerformanceFund MP INNER JOIN #ID A ON A.MonthlyPerformanceFundID = MP.MonthlyPerformanceFundID

--WHERE DataSource = 'CD' AND MonthEnd = @QtrEndDate
)
--
/*------------------------------------------------------------------------------------------------------
SELECT * FROM CTE_QtrEnd_Base Q 
where AccountNumber = 'LSJF30020002' AND SecurityID = '99VVA9KD0'
ORDER BY AccountNumber,[CompanyName],[SecurityID] -- 2561
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
	 Q.QtrEnd
	,Q.AccountNumber
	,Q.[AccountName]
	,Q.[SecurityID]
	,Q.[CompanyName]
	,Q.[Series]	
	,Q.[SponsorName]
	,Q.[FirmName]
	,CAST(Q.[InceptionDate] AS VARCHAR(10)) AS [Inception Date]
	,YEAR(Q.[InceptionDate]) AS 'Vintage Year'
	,Q.Shares
	,SQ.[CapitalCallsTotalQtr] AS [Base Cost]
	,SQ.[DistributionsTotalQtr] AS [Distributed]
	,Q.EAMVQtr AS EAMV
	,CASE 
		WHEN (Q.EAMVQtr + DistributionsTotalQtr) = 0 THEN 0
		WHEN (CapitalCallsTotalQtr + AdditionalFeesTotalQtr)= 0 THEN 0
		ELSE ((Q.EAMVQtr + DistributionsTotalQtr) / (CapitalCallsTotalQtr + AdditionalFeesTotalQtr))
	END 'Multiple TVP'

	,(Q.EAMVQtr + SQ.[DistributionsTotalQtr] - SQ.[CapitalCallsTotalQtr]) AS 'Appreciation ITD'

	--,(Q.EAMVQtr + SQ.[CapitalCallsTotalQtr] - SQ.[DistributionsTotalQtr]) - (Q.EAMVLag12 + [DistributionsTotalYr] - [CapitalCallsTotalYr]) AS 'Appreciation 1Yr'
	,(Q.EAMVQtr + SQ.[CapitalCallsTotalQtr] - SQ.[DistributionsTotalQtr]) - (Q.EAMVLag12 + [DistributionsTotalYr]) AS 'Appreciation 1Yr'

	,Q.[Sector] + ' ' + Q.[SubSector] AS [Sector]
	,[New/FollowON]
	,Q.[Security Status]
	,CAST(Q.LastReportedDate_Mix AS VARCHAR(10)) AS [Valuation Date] 
	,ISNULL(Q.[AccountClosed],'') [AccountClosed]
	,CASE 
		WHEN ASA_Account IS NOT NULL THEN 'Yes'
		ELSE 'No'
	END AS 'ASA Exists'
FROM CTE_QtrEnd_1YR Q 
	LEFT JOIN CTE_SUMQtr  SQ ON Q.AccountNumber = SQ.AccountNumber AND Q.[SecurityID] = SQ.[SecurityID]
	LEFT JOIN CTE_SUMYr   SY ON Q.AccountNumber = SY.AccountNumber AND Q.[SecurityID] = SY.[SecurityID]

--where Q.SecurityID = '14141R309'

ORDER BY Q.AccountNumber,[AccountName],Q.[CompanyName],Q.[SecurityID]


GO

