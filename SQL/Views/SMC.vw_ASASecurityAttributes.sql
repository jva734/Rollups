
/* 
	Author		John Alton	
	Date		2/24/2016
	Description	Get the Inception Date and the LAst Reported Valuation Date for each Account/Security combination

	-------------------------------------------------------------------------------------------------------------------------
	Modifications:
	Name		Date		Description
	-------------------------------------------------------------------------------------------------------------------------

Testing

SELECT   AccountNumber
		,[SecurityID]
		,InceptionDate
		,[LastReportedDate]
		,DataSource
FROM [SMC].[MonthlyPerformanceFund]
WHERE AccountNumber = 'LSJF30020002' AND [SecurityID] = '996213039'
ORDER BY InceptionDate 

--ORDER BY [LastReportedDate] DESC
LSJF30020002	996213039	2009-12-07	2009-12-31
*/

USE [SMC_DB_Performance]
GO

IF object_id(N'SMC.vw_ASASecurityAttributes', 'V') IS NOT NULL
	DROP VIEW SMC.vw_ASASecurityAttributes
GO

CREATE VIEW SMC.vw_ASASecurityAttributes
AS

SELECT   AccountNumber
		,[SecurityID]
		,MIN(InceptionDate) AS InceptionDate
		,MAX([LastReportedDate]) AS LastValuationDate
FROM [SMC_DB_Performance].[SMC].[MonthlyPerformanceFund]
WHERE DataSource <> 'CND'
GROUP BY  AccountNumber,[SecurityID]


