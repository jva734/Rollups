/*
=============================================
	
	SELECT * FROM SMC.vw_XIRR_MonthlyPerformanceCore
=============================================
*/
USE [SMC_DB_Performance]
GO

--/*
IF object_id(N'SMC.vw_XIRR_MonthlyPerformanceCore', 'V') IS NOT NULL
	DROP VIEW SMC.vw_XIRR_MonthlyPerformanceCore
GO

CREATE VIEW SMC.vw_XIRR_MonthlyPerformanceCore
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
		,DATEADD(m, -3, MonthEnd) AS MonthEndLag3
		,DATEADD(m, -12, MonthEnd) AS MonthEndLag1Yr
		,DATEADD(m, -36, MonthEnd) AS MonthEndLag3Yr
		,DATEADD(m, -60, MonthEnd) AS MonthEndLag5Yr
		,DATEADD(m, -84, MonthEnd) AS MonthEndLag7Yr
		,DATEADD(m, -120, MonthEnd) AS MonthEndLag10Yr
		,CAST(EAMV AS MONEY) EAMV
		,(0 - ABS(CAST(LAG(MP.EAMV,3) OVER (PARTITION BY MP.AccountNumber ORDER BY MP.MonthEnd ASC) AS Float))) AS EAMVLag3Mo
		,(0 - ABS(CAST(LAG(MP.EAMV,12) OVER (PARTITION BY MP.AccountNumber ORDER BY MP.MonthEnd ASC) AS Float))) AS EAMVLag1Yr
		,(0 - ABS(CAST(LAG(MP.EAMV,36) OVER (PARTITION BY MP.AccountNumber ORDER BY MP.MonthEnd ASC) AS Float))) AS EAMVLag3Yr
		,(0 - ABS(CAST(LAG(MP.EAMV,60) OVER (PARTITION BY MP.AccountNumber ORDER BY MP.MonthEnd ASC) AS Float))) AS EAMVLag5Yr
		,(0 - ABS(CAST(LAG(MP.EAMV,84) OVER (PARTITION BY MP.AccountNumber ORDER BY MP.MonthEnd ASC) AS Float))) AS EAMVLag7Yr
		,(0 - ABS(CAST(LAG(MP.EAMV,120) OVER (PARTITION BY MP.AccountNumber ORDER BY MP.MonthEnd ASC) AS Float))) AS EAMVLag10Yr

		,DATEADD(qq, DATEDIFF(qq, 0, MonthEnd), 0) AS QtrStart
		,CAST(DATEADD(dd, -1, DATEADD(qq, DATEDIFF(qq, 0, MonthEnd) +1, 0)) AS DATE) AS QtrEnd

		,InceptionDate
		-- Check if Account is open within 3Mo, 1Y, 3Y, 5Y, 7Y and 10Y.
		,IIF(LAG(MP.MonthEnd,2) OVER (PARTITION BY MP.AccountNumber ORDER BY MP.MonthEnd ASC) >= MP.InceptionDate,1,0) AccountValid3Mo
		,IIF(LAG(MP.MonthEnd,11) OVER (PARTITION BY MP.AccountNumber ORDER BY MP.MonthEnd ASC) >= MP.InceptionDate,1,0) AccountValid1Yr
		,IIF(LAG(MP.MonthEnd,35) OVER (PARTITION BY MP.AccountNumber ORDER BY MP.MonthEnd ASC) >= MP.InceptionDate,1,0) AccountValid3Yr
		,IIF(LAG(MP.MonthEnd,59) OVER (PARTITION BY MP.AccountNumber ORDER BY MP.MonthEnd ASC) >= MP.InceptionDate,1,0) AccountValid5Yr
		,IIF(LAG(MP.MonthEnd,83) OVER (PARTITION BY MP.AccountNumber ORDER BY MP.MonthEnd ASC) >= MP.InceptionDate,1,0) AccountValid7Yr
		,IIF(LAG(MP.MonthEnd,119) OVER (PARTITION BY MP.AccountNumber ORDER BY MP.MonthEnd ASC) >= MP.InceptionDate,1,0) AccountValid10Yr

	FROM [SMC].[MonthlyPerformanceCore] MP
	WHERE DataSource <> 'CND'
--	where MP.AccountNumber = 'LSJF60010002' AND MP.SecurityID = '13049'
)
SELECT * FROM CTE_Data1 
WHERE  MonthEnd = QtrEnd
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
