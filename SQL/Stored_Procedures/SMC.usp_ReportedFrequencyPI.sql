/*
===========================================================================================================================================
	Filename		SMC.usp_ReportedFrequencyPI
	Author			John Alton
	Date			4/3/2015
	Description		Determin the Reported Frequency for each Funds Reported Date
===========================================================================================================================================
*/

USE [SMC_DB_Performance]
go

-- Drop stored procedure if it already exists
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_ReportedFrequencyPI' 
)
   DROP PROCEDURE SMC.usp_ReportedFrequencyPI
GO

CREATE PROCEDURE SMC.usp_ReportedFrequencyPI
AS

DECLARE @StartDate date = '1992-01-01'
		,@EndDate date = '2021-01-01'

;WITH CTE_Months as
 (
 SELECT @StartDate as MonthEndDate
 UNION ALL 
 SELECT EOMONTH(dateadd(MM , 1, MonthEndDate)) AS MonthEndDate
 FROM CTE_Months 
 WHERE dateadd (MM, 1, MonthEndDate) < @EndDate 
 )
,CTE_QTR AS (
	SELECT 
		YEAR(MonthEndDate) AS Yr
		,MONTH(MonthEndDate) AS MonthNumber
		,MonthEndDate
		,DATEADD(d, -1, DATEADD(q, DATEDIFF(q, 0, MonthEndDate) + 1, 0)) AS QtrEndDate 		
		,CASE 
			WHEN MONTH(MonthEndDate) IN(1,2,3) THEN 1
			WHEN MONTH(MonthEndDate) IN(4,5,6) THEN 2
			WHEN MONTH(MonthEndDate) IN(7,8,9) THEN 3
			WHEN MONTH(MonthEndDate) IN(10,11,12) THEN 4
		END	QtrNumber
		,convert(date, DATEADD(day,-1,DATEADD(month,6,DATEADD(year,YEAR(MonthEndDate)-1900,0))) ) AS SemiAnnual
		,DATEADD(yy, DATEDIFF(yy,0,MonthEndDate) + 1, -1) AS YearEndDate
	FROM CTE_Months 
)
,CTE_AccountsPI AS (
SELECT MonthlyPerformanceCoreID
    ,A.AccountNumber
	,A.SecurityID 
	,A.MonthEnd AS ReportedDate
	,A.DataSource
	,A.RowType 
	,[LookupCategory]
	,[LookupText] AS Frequency
	,d.*
	FROM	[SMC].[MonthlyPerformanceCore] A
	INNER JOIN [SMC_DB_ASA].[asa].[Accounts] ASA ON ASA.[AccountNumber] = A.AccountNumber
	INNER JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON FL.[LookupId] = ASA.[Frequency]
	LEFT JOIN CTE_QTR D ON D.MonthEndDate = A.ReportedDate
	WHERE A.DataSource = 'PI' AND A.RowType = 'R'	
)
,CTE_ReportedPercent AS (
	SELECT *
		, CASE
			WHEN Frequency = 'M' AND ReportedDate = MonthEndDate THEN 100
			WHEN Frequency = 'Q' AND ReportedDate = QtrEndDate THEN 100
			WHEN Frequency = 'SA' AND (ReportedDate = SemiAnnual OR ReportedDate = YearEndDate) THEN 100
			WHEN Frequency = 'A' AND ReportedDate = YearEndDate THEN 100
			ELSE 0
		END AS ReportedPercent	
	FROM CTE_AccountsPI 

)
UPDATE [SMC].[MonthlyPerformanceCore]
	SET [ReportedPct] = RP.ReportedPercent	
FROM [SMC].[MonthlyPerformanceCore] MPC
	INNER JOIN CTE_ReportedPercent RP ON RP.MonthlyPerformanceCoreID = MPC.MonthlyPerformanceCoreID
OPTION (MAXRECURSION 366)

/* */
UPDATE [SMC].[MonthlyPerformanceCore]
	SET [ReportedPct] = 100
WHERE DataSource = 'PI' AND RowType = 'A'


GO

