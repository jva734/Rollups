USE [SMC_DB_Performance]
GO
-- =============================================
-- Create basic stored procedure template
-- =============================================

-- Drop stored procedure if it already exists
--/*
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_GetMPCData_XIRR' 
)
   DROP PROCEDURE SMC.usp_GetMPCData_XIRR
GO


CREATE PROCEDURE SMC.usp_GetMPCData_XIRR
AS
--*/

;WITH CTE_Data1 AS (
	SELECT 
		MonthlyPerformanceCoreID
		,RowType
		,DataSource
		,AccountNumber
		,SecurityID		 
		,MonthStart
		,MonthEnd
		,DATEADD(m, -3, MonthEnd) AS MonthEndLag3
		,DATEADD(m, -12, MonthEnd) AS MonthEndLag12
		,DATEADD(m, -36, MonthEnd) AS MonthEndLag36
		,DATEADD(m, -60, MonthEnd) AS MonthEndLag60
		,DATEADD(m, -84, MonthEnd) AS MonthEndLag84
		,DATEADD(m, -120, MonthEnd) AS MonthEndLag120
		,(0 - ABS(CAST([EAMV] AS Float))) EAMV
		,DATEADD(d, -1, DATEADD(q, DATEDIFF(q, 0, MonthEnd) + 1, 0)) AS QtrEnd
		,InceptionDate
				-- Check if Account is open within 3Mo, 1Y, 3Y, 5Y, 7Y and 10Y.
		,IIF(LAG(MP.MonthEnd,2) OVER (PARTITION BY MP.AccountNumber ORDER BY MP.MonthEnd ASC) >= MP.InceptionDate,1,0) AccountValid3Mo
		,IIF(LAG(MP.MonthEnd,11) OVER (PARTITION BY MP.AccountNumber ORDER BY MP.MonthEnd ASC) >= MP.InceptionDate,1,0) AccountValid1Yr
		,IIF(LAG(MP.MonthEnd,23) OVER (PARTITION BY MP.AccountNumber ORDER BY MP.MonthEnd ASC) >= MP.InceptionDate,1,0) AccountValid2Yr
		,IIF(LAG(MP.MonthEnd,35) OVER (PARTITION BY MP.AccountNumber ORDER BY MP.MonthEnd ASC) >= MP.InceptionDate,1,0) AccountValid3Yr
		,IIF(LAG(MP.MonthEnd,59) OVER (PARTITION BY MP.AccountNumber ORDER BY MP.MonthEnd ASC) >= MP.InceptionDate,1,0) AccountValid5Yr
		,IIF(LAG(MP.MonthEnd,83) OVER (PARTITION BY MP.AccountNumber ORDER BY MP.MonthEnd ASC) >= MP.InceptionDate,1,0) AccountValid7Yr
		,IIF(LAG(MP.MonthEnd,119) OVER (PARTITION BY MP.AccountNumber ORDER BY MP.MonthEnd ASC) >= MP.InceptionDate,1,0) AccountValid10Yr

	FROM [SMC].[MonthlyPerformanceCore] MP
	WHERE DataSource <> 'CND'
--	where MP.AccountNumber = 'LSJF60010002' AND MP.SecurityID = '13049'
)
--,CTE_Data2 AS (
--	SELECT * FROM CTE_Data1
--	WHERE  MonthEnd = QtrEnd
--)
SELECT * FROM CTE_Data1 
WHERE  MonthEnd = QtrEnd
ORDER BY AccountNumber,SecurityID,MonthEnd
