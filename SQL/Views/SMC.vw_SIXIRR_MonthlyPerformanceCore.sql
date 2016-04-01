/*
=============================================
	Use in calculating the Since Inception XIRR
	SELECT * FROM SMC.vw_SIXIRR_MonthlyPerformanceCore
=============================================
*/
USE [SMC_DB_Performance]
GO

--/*
IF object_id(N'SMC.vw_XIRRSI_MonthlyPerformanceCore', 'V') IS NOT NULL
	DROP VIEW SMC.vw_XIRRSI_MonthlyPerformanceCore
GO

CREATE VIEW SMC.vw_XIRRSI_MonthlyPerformanceCore
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
		,CAST(EAMV AS MONEY) EAMV
		,CAST(DATEADD(dd, -1, DATEADD(qq, DATEDIFF(qq, 0, MonthEnd) +1, 0)) AS DATE) AS QtrEnd
		,ABS(CAST(ISNULL((DATEDIFF(MONTH, InceptionDate, MonthEnd) ),0) AS INT)) AS MonthsToInception
		,InceptionDate
		,(0 - ABS(CAST(LAG(EAMV,ABS(CAST(ISNULL((DATEDIFF(MONTH, InceptionDate, MonthEnd) ),0) AS INT))) OVER (PARTITION BY AccountNumber ORDER BY MonthEnd ASC) AS Float))) AS EAMVLagIncep
	FROM [SMC].[MonthlyPerformanceCore] MP
	WHERE DataSource <> 'CND'
)
SELECT * 
FROM	CTE_Data1
WHERE	MonthEnd = QtrEnd

