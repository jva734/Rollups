/*Execute
EXECUTE SMC.usp_CompanyReport '2015-09-30 12:00:00 AM','DAPER I/DIR PRIV VEN,LSVF/DIR PUB VEN',NULL,NULL
EXECUTE SMC.usp_CompanyReport '2015-09-30 12:00:00 AM','DAPER I/DIR PRIV VEN,LSVF/DIR PUB VEN','Tim Connors,Brad Jones,Marc Andreessen',NULL

EXECUTE SMC.usp_CompanyReport '2015-12-31',NULL,NULL,NULL
SELECT 'CompanyReport_' + FORMAT( GETDATE(), 'yyyy_MM_dd', 'en-US' ) AS 'FileNAme'
*/

--
/*Testing
SELECT * 
FROM SMC.MonthlyPerformanceFund
WHERE CompanyName = 'Pure Storage'


SELECT MonthlyPerformanceFundID
	,AccountNumber,SecurityID
		,[CompanyName]
		,[PortfolioType]
		,MonthEnd
		,MellonAccountName
		,SponsorName
		,CASE 
			WHEN ASA_Account IS NULL THEN 'Realized'
			WHEN ASA_Account = 1 AND [SecurityStatus] IN ('Active','Active Converted New') THEN 'Unrealized'
			ELSE 'Realized'
		END AS RealizedStatus
		,ISNULL([SecurityStatus],'') [SecurityStatus]
		,ISNULL([Sector],'') AS [Sector]
		,ISNULL([SubSector],'')	AS [SubSector]
		,AccountClosed
		,[InceptionDate]
		,ASA_Account
		,EAMV
FROM SMC.MonthlyPerformanceFund
WHERE 
--MonthlyPerformanceFundid = 214540

	DataSource = 'CD' 
	AND MonthEnd =  '2015-12-31'
	AND CompanyName = 'AcelRx Pharmaceuticals' --'Pure Storage'

--*/

/*
=============================================
	Author John Alton 1/29/2016
	Modifications
	Date	Name	Description
	3/7/16	John	If ASA SecurityStatus not "Active" or "Active Converted New", then set EAMV = 0 with the Liquidated Date equal to the valuation date of the zero EAMV
=============================================
*/

USE SMC_DB_Performance
GO

--/*
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_CompanyReport' 
)
   DROP PROCEDURE SMC.usp_CompanyReport
GO

CREATE PROCEDURE SMC.usp_CompanyReport
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
	,@AccountNumber varchar(25)
	,@SecurityID varchar(25)

set @AccountNumber = 'LSJF86000002'; set @SecurityID  = '999K37506'
--AND SecurityID in('999K37506','99VVA74H3','99VVACYK2')

SET @QtrEndDate = '2015-12-31'

SET @SponsorName  = 'Steve Krausz '
SET @SecurityStatus  = 'Realized'

SET @AccountName = NULL
SET @AccountName = 'SBST/DIR PRV VEN'
SET @AccountName = 'OTL'

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
	,[CompanyName] VARCHAR(255)
	,[PortfolioType] varchar(255)
	,MonthEnd datetime
	,MellonAccountName NVARCHAR(80)
	,SponsorName NVARCHAR(512)
	,RealizedStatus NVARCHAR(120)
	,SecurityStatus NVARCHAR(120)
	,[Sector] NVARCHAR(240)
	,[SubSector] NVARCHAR(240)
	,[InceptionDate] DATETIME
	,InceptionDateOrder INT
	,SecurityStatusOrder INT
)

CREATE TABLE #ID (
	MonthlyPerformanceFundID BIGINT
	,[CompanyName] Varchar(200)
	,[PortfolioType] Varchar(200)
)

CREATE TABLE #AccountName (AccountName varchar(500))
--CREATE TABLE #SponsorName (SponsorName varchar(512))

/*================================================================================================
	Pre filter gets the core data we need filtered on the users parameters
================================================================================================*/
;WITH CTE_PreFilter AS (	
	SELECT MonthlyPerformanceFundID
		,[CompanyName]
		,[PortfolioType]
		,MonthEnd
		,MellonAccountName
		,SponsorName
		,CASE 
			--WHEN ASA_Account IS NULL THEN 'Realized'
			WHEN ASA_Account = 1 AND [SecurityStatus] IN ('Active','Active Converted New') THEN 'Unrealized'
			ELSE 'Realized'
		END AS RealizedStatus
		,ISNULL([SecurityStatus],'') [SecurityStatus]
		,ISNULL([Sector],'') AS [Sector]
		,ISNULL([SubSector],'')	AS [SubSector]
		,[InceptionDate]
	FROM SMC.MonthlyPerformanceFund
	WHERE DataSource = 'CD' 
		AND ASA_Account = 1
		AND MonthEnd = CAST(@QtrEndDate AS VARCHAR(20))
		AND InceptionDate <= CAST(@QtrEndDate AS VARCHAR(20))
	--and CompanyName is not null
)
--
/*
SELECT * FROM CTE_PreFilter 
WHERE 
--[CompanyName] IN ('SunRun','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin Labs)','Twitter (fka Mixer Labs)')
ORDER BY [CompanyName],[PortfolioType]

--*/

,CTE_RANK AS (
	SELECT A.* 
		,ROW_NUMBER() OVER(PARTITION BY [CompanyName],[PortfolioType] ORDER BY [CompanyName],[PortfolioType],[InceptionDate] ) AS InceptionDateOrder
		,ROW_NUMBER() OVER(PARTITION BY [CompanyName],[PortfolioType] ORDER BY [CompanyName],[PortfolioType],RealizedStatus DESC) AS SecurityStatusOrder
	FROM CTE_PreFilter A
)
--
/*debug
SELECT * FROM CTE_RANK 
WHERE [CompanyName] IN ('Amplyx Pharmaceuticals','SunRun','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin Labs)','Twitter (fka Mixer Labs)')
ORDER BY [CompanyName],InceptionDateOrder
--*/

INSERT INTO #PreFilter
	SELECT * FROM CTE_RANK 
--
/*debug
SELECT * FROM #PreFilter
--*/

SET @SQL = N'INSERT INTO #ID 
	SELECT MonthlyPerformanceFundID
			,[CompanyName]
			,[PortfolioType] 
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
		SET @SQL = @SQL + ' AND SponsorName = ' + '''' + CAST(@SponsorName AS VARCHAR(512)) + '''' 
		--INSERT INTO #SponsorName SELECT * FROM [dbo].[ufn_SplitString](@SponsorName,',')
		--SET @SQL = @SQL + ' AND SponsorName  IN (SELECT SponsorName FROM #SponsorName) '
	END

IF @SecurityStatus IS NOT NULL AND @SecurityStatus <> 'All'
	BEGIN
		SET @SQL = @SQL + ' AND RealizedStatus = ' + '''' + CAST(@SecurityStatus AS VARCHAR(120)) + '''' 
	END

PRINT @SQL

EXECUTE sp_executesql @SQL

--
/*
SELECT * FROM #ID 
WHERE [CompanyName] IN ('SunRun','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin Labs)','Twitter (fka Mixer Labs)')
--*/

/*
------------------------------------------------------------------------------------------------------
CTE_Qtr_SecurityStatus_Values
------------------------------------------------------------------------------------------------------
if ASA Security Status = "Active" or "Write-Off" then include all capital calls and distributions for that security	
if ASA Security Status = "Write-Off Converted Old" then include all capital calls but exclude all distributions for that security	
if ASA Security Status = "Write-Off Converted New" or "Active Converted New" then exclude all capital calls but include all distributions for that security	

if ASA SecurityStatus not "Active" or "Active Converted New", then set EAMV = 0 with the Liquidated Date equal to the valuation date of the zero EAMV

STATUS											CAPITAL CALLS	DISTRIBUTIONS
 "Active" OE "Write-Off"							include			include
 "Write-Off Converted Old"							include			exclude
 "Write-Off Converted New"/"Active Converted New"   exclude			include

*/
;WITH CTE_Qtr_SecurityStatus_Values AS (
	SELECT A.MonthlyPerformanceFundID
			,A.[CompanyName]
			,A.[PortfolioType]
			,ISNULL([SecurityStatus],'') [SecurityStatus]
			,EAMV EAMV_Orig
			,[CapitalCalls] AS CapitalCalls_Orig
			,Distributions1M as Distributions1MQtr
			,CASE
				WHEN ISNULL([SecurityStatus],'') IN ('Active','Write-Off','Write-Off Converted Old') THEN [CapitalCalls]
				WHEN ISNULL([SecurityStatus],'') IN ('Write-Off Converted New', 'Active Converted New') THEN 0
				ELSE [CapitalCalls]
			END AS CapitalCallsQtr


			,CASE
				WHEN ISNULL([SecurityStatus],'') IN ('Active','Write-Off','Write-Off Converted New', 'Active Converted New') THEN [Distributions1M]
				WHEN ISNULL([SecurityStatus],'') IN ('Write-Off Converted Old') THEN 0
				ELSE [Distributions1M]
			END AS DistributionsQtr

			,CASE
				WHEN ISNULL([SecurityStatus],'') IN ('Write-Off', 'Write-Off Converted New', 'Write-Off Converted Old') THEN 0
				ELSE EAMV
			END AS EamvQtr

			,CASE
				WHEN ISNULL([SecurityStatus],'') IN ('Write-Off', 'Write-Off Converted New', 'Write-Off Converted Old') AND [AccountClosed] IS NOT NULL THEN [AccountClosed]
				WHEN ISNULL([SecurityStatus],'') IN ('Write-Off', 'Write-Off Converted New', 'Write-Off Converted Old') AND [AccountClosed] IS NULL THEN LastReportedDate
				ELSE LastReportedDate
			END AS LastReportedDate_Mix

	FROM #ID A 
		INNER JOIN SMC.MonthlyPerformanceFund MP ON A.MonthlyPerformanceFundID = MP.MonthlyPerformanceFundID
--WHERE MP.[CompanyName] = '3D Solid Compression' AND MP.[PortfolioType] = 'PVF'
)
--
/* debug
SELECT Q.* 
FROM CTE_Qtr_SecurityStatus_Values Q 
WHERE q.[CompanyName] IN ('Amplyx Pharmaceuticals','SunRun','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin Labs)','Twitter (fka Mixer Labs)')
--WHERE CompanyName = 'Pure Storage'
--*/

/*
------------------------------------------------------------------------------------------------------
CTE_Qtr_Base1
------------------------------------------------------------------------------------------------------
*/
,CTE_Qtr_Base1 AS (
SELECT  
		ROW_NUMBER() OVER(ORDER BY A.[CompanyName],A.[PortfolioType]) AS Rownum
		,MAX(A.MonthlyPerformanceFundID) AS MonthlyPerformanceFundID
		--,[AccountNumber] 		
		,A.[CompanyName]
		,A.[PortfolioType]
		,COUNT(SECURITYID)					AS SecurityCount
		,MAX(MonthEnd)						AS QtrEnd
		,MAX([MellonAccountName])			AS [AccountName]
		,MAX([Series])						AS [Series]	
		,MAX([SponsorName])					AS [SponsorName]	
		,MAX([FirmName])					AS [FirmName]
		,MIN([InceptionDate])				AS [InceptionDate]
		,MAX([InceptionDate])				AS [LastInceptionDate]
		,ISNULL(SUM(SS.EamvQtr),0)			AS EAMVQtr
		,ISNULL(SUM(ABS(SS.CapitalCallsQtr)),0)	AS [CapitalCalls]
		,ISNULL(SUM(SS.DistributionsQtr),0)	AS [Distributions]
		,ISNULL(SUM(AdditionalFees),0)		AS [AdditionalFees]
		,MAX(SS.LastReportedDate_Mix)		AS LastReportedDate_Mix
		,MAX([AccountClosed])				AS [AccountClosed]					
	FROM #ID A 
		INNER JOIN CTE_Qtr_SecurityStatus_Values SS ON A.MonthlyPerformanceFundID = SS.MonthlyPerformanceFundID
		INNER JOIN SMC.MonthlyPerformanceFund MP ON A.MonthlyPerformanceFundID = MP.MonthlyPerformanceFundID
	GROUP BY A.[CompanyName],A.[PortfolioType]
)
--
/* debug
SELECT Q.* FROM CTE_Qtr_Base1 Q 
WHERE q.[CompanyName] IN ('SunRun','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin Labs)','Twitter (fka Mixer Labs)')
ORDER BY [CompanyName],[PortfolioType]
--*/


,CTE_Qtr_Base1A AS (
	SELECT A.[PortfolioType],A.[CompanyName],ISNULL(SUM(Shares),0) AS Shares
	FROM #ID A 
		LEFT JOIN SMC.MonthlyPerformanceFund MP ON A.MonthlyPerformanceFundID = MP.MonthlyPerformanceFundID AND MP.SecurityStatus IN ('Active','Active Converted New')
--	WHERE MP.SecurityStatus IN ('Active','Active Converted New')
	GROUP by A.[CompanyName],A.[PortfolioType]
)
--
/* debug
SELECT Q.* FROM CTE_Qtr_Base1A Q  
WHERE [CompanyName] IN ('SunRun','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin Labs)','Twitter (fka Mixer Labs)')
ORDER BY [CompanyName],[PortfolioType] 
--*/

,CTE_Qtr_Base1B AS (
	SELECT X.*, Y.Shares
	FROM CTE_Qtr_Base1 X
	 	INNER JOIN CTE_Qtr_Base1A Y ON X.[CompanyName] = Y.[CompanyName] AND X.[PortfolioType] = Y.[PortfolioType]
)
--
/* debug
SELECT Q.* FROM CTE_Qtr_Base1B Q  
--WHERE [CompanyName] = 'Brightsource Energy' 
WHERE [CompanyName] IN ('SunRun','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin Labs)','Twitter (fka Mixer Labs)')
ORDER BY [CompanyName],[PortfolioType] 
--*/

,CTE_Qtr_Base2 AS (
	SELECT Q.*
		,P.[Sector]
		,P.[SubSector]
	FROM CTE_Qtr_Base1B Q 
		JOIN #PreFilter P ON P.[PortfolioType] = Q.[PortfolioType] AND P.[CompanyName] = Q.[CompanyName] AND P.InceptionDateOrder = 1
)
--
/* debug
SELECT Q.* FROM CTE_Qtr_Base2 Q 
--WHERE [CompanyName] IN ('SunRun','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin Labs)','Twitter (fka Mixer Labs)')
ORDER BY [CompanyName] ,[PortfolioType]
--*/

,CTE_Qtr_Base3 AS (
	SELECT Q.*
		,P.RealizedStatus
	FROM CTE_Qtr_Base2 Q 
		JOIN #PreFilter P ON P.[PortfolioType] = Q.[PortfolioType] AND P.[CompanyName] = Q.[CompanyName] AND P.SecurityStatusOrder = 1
)
--
/* debug
SELECT * FROM CTE_Qtr_Base3 q
WHERE q.[CompanyName] IN ('SunRun','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin Labs)','Twitter (fka Mixer Labs)')
order BY [CompanyName] ,[PortfolioType]
--*/

/*

------------------------------------------------------------------------------------------------------
CTE_YR Get values for these accounts for 12 months ago
------------------------------------------------------------------------------------------------------
*/
,CTE_Yr_EAMV AS (
	SELECT A.MonthlyPerformanceFundID
			,A.[CompanyName]
			,A.[PortfolioType] 
			,MP.MonthEnd AS MonthEnd_Yr
			,ISNULL(MP.[SecurityStatus],'') [SecurityStatus_YR]
			,EAMV AS EAMV_OrigYear
			,CASE
				WHEN ISNULL(MP.[SecurityStatus],'') NOT IN ('Active', 'Active Converted New') THEN 0
				ELSE EAMV
			 END AS Eamv_YR
			 ,MP.[Distributions1M] Distribution_YR
	FROM #ID A
		JOIN SMC.MonthlyPerformanceFund MP ON A.[CompanyName] = MP.[CompanyName] AND A.[PortfolioType] = MP.[PortfolioType] 
		WHERE MP.DataSource = 'CD' AND MP.MonthEnd = @LastYear
)
--
/* debug
SELECT * FROM CTE_Yr_EAMV 
WHERE [CompanyName] IN ('SunRun','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin Labs)','Twitter (fka Mixer Labs)')
--*/

,CTE_YR AS (
SELECT	Q.[PortfolioType],Q.[CompanyName]
		,MAX(Yr.MonthEnd_Yr)		AS MonthEndLag12
		,ISNULL(SUM(Yr.Eamv_YR),0)	AS EAMVLag12
		,ISNULL(SUM(Yr.Distribution_YR),0)	AS Distribution_Lag12
FROM CTE_Qtr_Base3  Q
	LEFT JOIN CTE_Yr_EAMV Yr ON Q.[PortfolioType] = Yr.[PortfolioType] AND Q.[CompanyName] = Yr.[CompanyName]
GROUP BY Q.[CompanyName],Q.[PortfolioType]
)
--
/*debug 
SELECT * FROM CTE_YR 
WHERE [CompanyName] IN ('SunRun','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin Labs)','Twitter (fka Mixer Labs)')
ORDER BY [CompanyName],[PortfolioType]
--*/

/*
--=======================================================================================================
CTE_SUMQtr 
=======================================================================================================--*/
--jva
,CTE_SUMQtr_1 AS (
SELECT  Q.[PortfolioType]	
		,Q.[CompanyName]
		,CASE
			WHEN ISNULL([SecurityStatus],'') IN ('Active','Write-Off','Write-Off Converted Old') THEN MP.[CapitalCalls]
			WHEN ISNULL([SecurityStatus],'') IN ('Write-Off Converted New', 'Active Converted New') THEN 0
		ELSE MP.[CapitalCalls]
		END AS CapitalCallsByStatus

		,CASE
			WHEN ISNULL([SecurityStatus],'') IN ('Active','Write-Off','Write-Off Converted New', 'Active Converted New') THEN MP.[Distributions1M]
			WHEN ISNULL([SecurityStatus],'') IN ('Write-Off Converted Old') THEN 0
			ELSE MP.[Distributions1M]
		END AS DistributionsByStatus
		,MP.AdditionalFees
FROM CTE_Qtr_Base3 Q
	LEFT JOIN SMC.MonthlyPerformanceFund MP ON Q.[PortfolioType] = MP.[PortfolioType] AND Q.[CompanyName] = MP.[CompanyName]
		AND MP.DataSource = 'CD' 
		AND MP.MonthEnd <= @QtrEndDate 
)
,CTE_SUMQtr AS (
SELECT  Q.[PortfolioType]	
		,Q.[CompanyName]
		,SUM(ABS(A.CapitalCallsByStatus)) AS [CapitalCallsTotalQtr]
		,SUM(A.DistributionsByStatus) AS [DistributionsTotalQtr]
		,SUM(A.AdditionalFees) AS AdditionalFeesTotalQtr
FROM CTE_Qtr_Base3 Q
	LEFT JOIN CTE_SUMQtr_1 A ON Q.[PortfolioType] = A.[PortfolioType] AND Q.[CompanyName] = A.[CompanyName]
GROUP BY Q.[CompanyName],Q.[PortfolioType]
)
--
/*debug ------------------------------------------------------------------------------------------------------
SELECT * FROM CTE_SUMQtr Q 
WHERE [CompanyName] IN ('Amplyx Pharmaceuticals') --,'SunRun','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin Labs)','Twitter (fka Mixer Labs)')
ORDER BY Q.[CompanyName],Q.[PortfolioType]
--*/

/*
--=======================================================================================================
CTE_SUMYr
--=======================================================================================================--*/
,CTE_SUMYr_1 AS (
SELECT  Q.[PortfolioType]	
		,Q.[CompanyName]
		,CASE
			WHEN ISNULL([SecurityStatus],'') IN ('Active','Write-Off','Write-Off Converted Old') THEN MP.[CapitalCalls]
			WHEN ISNULL([SecurityStatus],'') IN ('Write-Off Converted New', 'Active Converted New') THEN 0
		ELSE MP.[CapitalCalls]
		END AS CapitalCallsByStatus

		,CASE
			WHEN ISNULL([SecurityStatus],'') IN ('Active','Write-Off','Write-Off Converted New', 'Active Converted New') THEN MP.[Distributions1M]
			WHEN ISNULL([SecurityStatus],'') IN ('Write-Off Converted Old') THEN 0
			ELSE MP.[Distributions1M]
		END AS DistributionsByStatus
		,MP.AdditionalFees
FROM CTE_Qtr_Base3 Q
	LEFT JOIN SMC.MonthlyPerformanceFund MP ON Q.[PortfolioType] = MP.[PortfolioType] AND Q.[CompanyName] = MP.[CompanyName]
		AND MP.DataSource = 'CD' 
		AND MP.MonthEnd <= @LastYear 
)
,CTE_SUMYr AS (
SELECT   Q.[PortfolioType]	
		,Q.[CompanyName]
		,SUM(ABS(A.CapitalCallsByStatus)) AS [CapitalCallsTotalYr]
		,SUM(A.DistributionsByStatus) AS [DistributionsTotalYr]
FROM CTE_Qtr_Base3  Q
	LEFT JOIN CTE_SUMYr_1 A ON Q.[PortfolioType] = A.[PortfolioType] AND Q.[CompanyName] = A.[CompanyName]
GROUP BY Q.[CompanyName],Q.[PortfolioType]
)
--
/*debug ------------------------------------------------------------------------------------------------------
SELECT * FROM CTE_SUMYr
WHERE [CompanyName] IN ('SunRun','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin Labs)','Twitter (fka Mixer Labs)')
ORDER BY [CompanyName],[PortfolioType]
--*/


/*
Final Results
*/
SELECT 
	Q.QtrEnd
	 ,Q.[AccountName]
	,Q.[CompanyName]
	,Q.[PortfolioType]
	,Q.[SponsorName]
	,LTRIM(RTRIM(Q.[FirmName])) AS [FirmName]
	,Q.[InceptionDate] AS [Inception Date]
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

	,(Q.EAMVQtr + SQ.[CapitalCallsTotalQtr] - SQ.[DistributionsTotalQtr]) - (Y.EAMVLag12 + [DistributionsTotalYr]) AS 'Appreciation 1Yr'
	,Q.[Sector] 
	,Q.[SubSector] 
	,Q.RealizedStatus
	,Q.LastReportedDate_Mix AS [Valuation Date] 
	,CASE 
		WHEN Q.RealizedStatus = 'Unrealized' THEN NULL
		ELSE [AccountClosed]
	END LiquidatedDate
FROM CTE_Qtr_Base3 Q
	     JOIN CTE_YR       Y ON Q.[PortfolioType] = Y.[PortfolioType]  AND Y.[CompanyName] = Q.[CompanyName]
	LEFT JOIN CTE_SUMQtr  SQ ON Q.[PortfolioType] = SQ.[PortfolioType] AND Q.[CompanyName] = SQ.[CompanyName]
	LEFT JOIN CTE_SUMYr   SY ON Q.[PortfolioType] = SY.[PortfolioType] AND Q.[CompanyName] = SY.[CompanyName]

--WHERE q.[CompanyName] IN ('Amplyx Pharmaceuticals','SunRun','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin & Mixer Labs)','Twitter (fka Bluefin Labs)','Twitter (fka Mixer Labs)')

ORDER BY Q.[CompanyName],Q.[PortfolioType],[AccountName]
--,Q.[InceptionDate] 





