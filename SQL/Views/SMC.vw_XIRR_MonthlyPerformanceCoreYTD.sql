/*
=============================================
	
	SELECT * FROM SMC.vw_XIRR_MonthlyPerformanceCore
=============================================
*/
USE [SMC_DB_Performance]
GO

--/*
IF object_id(N'SMC.vw_XIRR_MonthlyPerformanceCoreYTD', 'V') IS NOT NULL
	DROP VIEW SMC.vw_XIRR_MonthlyPerformanceCoreYTD
GO

CREATE VIEW SMC.vw_XIRR_MonthlyPerformanceCoreYTD
AS
--*/

WITH CTE_Data1 AS (
	SELECT 
		MonthlyPerformanceCoreID
		,RowType
		,DataSource
		,AccountNumber
		,SecurityID		 
		,MonthStart
		,MonthEnd
		,CAST(DATEADD(yy, DATEDIFF(yy,0,MonthEnd), 0) AS DATE) AS StartOfYear
		--,CAST( DATEADD(ms,-3,DATEADD(yy,0,DATEADD(yy,DATEDIFF(yy,0,MonthEnd),0))) AS DATE) AS StartOfYear
		,DATEADD(m, -3, MonthEnd) AS MonthEndLag3
		,DATEADD(m, -12, MonthEnd) AS MonthEndLag1Yr
		,DATEADD(m, -36, MonthEnd) AS MonthEndLag3Yr
		,DATEADD(m, -60, MonthEnd) AS MonthEndLag5Yr
		,DATEADD(m, -84, MonthEnd) AS MonthEndLag7Yr
		,DATEADD(m, -120, MonthEnd) AS MonthEndLag10Yr
		,CAST(EAMV AS MONEY) EAMV
		
		,(0 - ABS(CAST(LAG(EAMV,1) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) AS Float))) AS EAMVLag1Mo
		,(0 - ABS(CAST(LAG(EAMV,2) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) AS Float))) AS EAMVLag2Mo
		,(0 - ABS(CAST(LAG(EAMV,3) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) AS Float))) AS EAMVLag3Mo
		,(0 - ABS(CAST(LAG(EAMV,4) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) AS Float))) AS EAMVLag4Mo
		,(0 - ABS(CAST(LAG(EAMV,5) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) AS Float))) AS EAMVLag5Mo
		,(0 - ABS(CAST(LAG(EAMV,6) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) AS Float))) AS EAMVLag6Mo
		,(0 - ABS(CAST(LAG(EAMV,7) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) AS Float))) AS EAMVLag7Mo
		,(0 - ABS(CAST(LAG(EAMV,8) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) AS Float))) AS EAMVLag8Mo
		,(0 - ABS(CAST(LAG(EAMV,9) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) AS Float))) AS EAMVLag9Mo
		,(0 - ABS(CAST(LAG(EAMV,10) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) AS Float))) AS EAMVLag10Mo
		,(0 - ABS(CAST(LAG(EAMV,11) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) AS Float))) AS EAMVLag11Mo

		,(0 - ABS(CAST(  LAG(EAMV,12) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) AS Float))) AS EAMVLag1Yr
		,(0 - ABS(CAST(  LAG(EAMV,36) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) AS Float))) AS EAMVLag3Yr
		,(0 - ABS(CAST(  LAG(EAMV,60) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) AS Float))) AS EAMVLag5Yr
		,(0 - ABS(CAST(  LAG(EAMV,84) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) AS Float))) AS EAMVLag7Yr
		,(0 - ABS(CAST(  LAG(EAMV,120) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) AS Float))) AS EAMVLag10Yr

		--,DATEADD(qq, DATEDIFF(qq, 0, MonthEnd), 0) AS QtrStart
		--,CAST(DATEADD(dd, -1, DATEADD(qq, DATEDIFF(qq, 0, MonthEnd) +1, 0)) AS DATE) AS QtrEnd

		,InceptionDate
		-- Check if Account is open within 3Mo, 1Y, 3Y, 5Y, 7Y and 10Y.
		,IIF(LAG(MonthEnd,1) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) >= InceptionDate,1,0) AccountValid1Mo
		,IIF(LAG(MonthEnd,2) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) >= InceptionDate,1,0) AccountValid3Mo
		,IIF(LAG(MonthEnd,11) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) >= InceptionDate,1,0) AccountValid1Yr
		,IIF(LAG(MonthEnd,35) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) >= InceptionDate,1,0) AccountValid3Yr
		,IIF(LAG(MonthEnd,59) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) >= InceptionDate,1,0) AccountValid5Yr
		,IIF(LAG(MonthEnd,83) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) >= InceptionDate,1,0) AccountValid7Yr
		,IIF(LAG(MonthEnd,119) OVER (PARTITION BY AccountNumber,SecurityID ORDER BY MonthEnd ASC) >= InceptionDate,1,0) AccountValid10Yr

		,MONTH(MonthEnd) as GroupValue
	FROM [SMC].[MonthlyPerformanceCore]
	WHERE DataSource <> 'CND'
--	where AccountNumber = 'LSJF60010002' AND SecurityID = '13049'
)
, CTE_Data2 AS (
	SELECT * 
	,CASE GroupValue
		WHEN 7 THEN 1 
		WHEN 8 THEN 2
		WHEN 9 THEN 3
		WHEN 10 THEN 4
		WHEN 11 THEN 5
		WHEN 12 THEN 6
		WHEN 1 THEN 7
		WHEN 2 THEN 8
		WHEN 3 THEN 9
		WHEN 4 THEN 10
		WHEN 5 THEN 11
		WHEN 6 THEN 12
	END JY_GroupValue
	FROM CTE_Data1 
)

SELECT * FROM CTE_Data2

--order by [AccountNumber],[SecurityID],[MonthStart]

/*
SELECT [AccountNumber]
,[SecurityID]
,[MonthStart]
,[MonthEnd]
,MonthEndLag3
,MonthEndLag1Yr
,QtrStart
,QtrEnd
,[EAMV]
,EAMVLag3Mo
,EAMVLag1Yr
,AccountValid1Yr
FROM CTE_Data1
WHERE  MonthEnd = QtrEnd
order by [AccountNumber],[SecurityID],[MonthStart]
--*/
