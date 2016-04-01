/*

SELECT [AccountNumber]
      ,[SecurityID]
      ,[MonthEnd]
	  ,RowType
	  ,[DataSource]
	  ,[ReportedDate]
	  ,[MarketValue]
      ,[LastReportedValue]
      ,[LastReportedDate]
FROM 
--[SMC].[MonthlyPerformanceCore]
[SMC].[MonthlyPerformanceFund]
WHERE 
--RowType = 'A' AND 
[DataSource] IN ('PI','CD') --AND [LastReportedValue] is not null
ORDER BY [AccountNumber],[SecurityID],[MonthEnd]


UPDATE MP	  
	  SET [LastReportedValue] = [MarketValue]
         ,[LastReportedDate]  =	[ReportedDate]
FROM [SMC_DB_Performance].[SMC].[MonthlyPerformanceFund] MP
WHERE RowType = 'R' AND [DataSource] IN ('PI','CD')

*/

;WITH CTE_P AS (
SELECT [AccountNumber]
      ,[SecurityID]
      ,[MonthEnd]
	  ,RowType
	  ,[DataSource]
	  ,[ReportedDate]
	  ,[MarketValue]
      ,[LastReportedValue]
      ,[LastReportedDate]
FROM [SMC_DB_Performance].[SMC].[MonthlyPerformanceFund]
WHERE RowType = 'R' AND [DataSource] IN ('PI','CD')
), CTE_NULLS AS (
SELECT 
	  A.[AccountNumber] AAN
      ,A.[SecurityID] ASI
      ,A.[MonthEnd] AME
	  ,A.RowType ART
	  ,A.[DataSource] ADS 
	  ,A.[ReportedDate] ARD
	  ,A.[MarketValue] AMV
      ,A.[LastReportedValue] ALRV
      ,A.[LastReportedDate] ALRD
		,MP.MonthlyPerformanceFundid
	  ,MP.[AccountNumber]
      ,MP.[SecurityID]
      ,MP.[MonthEnd]
	  ,MP.RowType
	  ,MP.[DataSource]
	  ,MP.[ReportedDate]
	  ,MP.[MarketValue]
      ,MP.[LastReportedValue]
      ,MP.[LastReportedDate]
	FROM CTE_P A
	JOIN [SMC_DB_Performance].[SMC].[MonthlyPerformanceFund] MP ON MP.[AccountNumber] = a.[AccountNumber] and mp.[SecurityID] = A.[SecurityID]
	where MP.RowType <> 'R' and mp.[MonthEnd] > a.[MonthEnd] 
	--AND mp.[MonthEnd] < a.[MonthEnd]
)
SELECT * FROM CTE_NULLS 
ORDER BY AAN,ASI,AME,[MonthEnd]

--[AccountNumber],[SecurityID],[MonthEnd]

