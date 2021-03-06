/*
===========================================================================================================================================
	View			CD.vw_Valuations
	Author			John Alton
	Date			1/27/2015
	Description		View to report data from the Custody Direct Source data to allow for common table mapping across CD and Private i
===========================================================================================================================================
	Modifications
	John			2/4/2015	Added AsOfDate. Currently set to be the EOMonth based on the valuations Price date
	John			2/4/2015	Added logic to link to the FAS system to filter data retrieval to only accounts marked as 'Direct' Accounts
	john			1/25/16		Expanded the selection to include some naming columns that will go into the MonthlyPerformance Files
								[CompanyName]		= [SecurityDescription1]
								[MellonAccountName] = [ReportingAccountName]
								[MellonDescription] = [AssetCategoryDescription]
	john			2/25/16		Expanded the selection to include the Shares Column

Views		
CD.vw_Valuations		
Column Name	Data Type	Note
AsOfDate	Date	Historical Date
DataSource	Nvarchar(10)	CD, PrivateI
AccountNumber	Nvarchar(100)	
SecurityID	Nvarchar(50)	CD:SecurityID varchar(50)
ReportedDate	Date	CD: Price Date
ReportedMktVal	Numeric (18,4)	USD dollar
SMCLoadDate	DateTime	

originally this data was being pulled from [SMC_DB_Mellon].[dbo].[Holdings]
temporarily moved to [SMC_DB_Mellon].[dbo].[Holdings]
[SMC_DB_Mellon].[dbo].[Holdings] 


SELECT * FROM  CD.vw_Valuations	
WHERE [CompanyName] IS NULL

SELECT AccountNumber FROM  CD.vw_Valuations	
group by AccountNumber


*/

USE [SMC_DB_Performance]
GO

--/*
IF object_id(N'CD.vw_Valuations', 'V') IS NOT NULL
	DROP VIEW CD.vw_Valuations		
GO

CREATE VIEW CD.vw_Valuations		
AS
--*/

/*
There are multiple rows por the same Month due to Public securities
We need to filter these out and just take the last one
*/
WITH CTE_SOURCE AS (
-- Filter out multiple Reported Values in the same Month, Only get the last one
	SELECT
	SourceAccountNumber
	,[MellonSecurityID]	
	,EOMONTH([PriceDate]) AS MonthEnd
	,MAX([PriceDate]) AS ReportedDate

FROM [SMC_DB_Mellon].[dbo].[Holdings] A
GROUP BY	
	SourceAccountNumber
	,[MellonSecurityID]
	,EOMONTH([PriceDate]) 

)
,CTE_GROUP AS (
SELECT
	 A1.SourceAccountNumber as AccountNumber	
	,A1.[MellonSecurityID] as SecurityID
	,A1.ReportedDate	
	,A.[BaseMarketValue]  as ReportedMktVal
	--,A1.MonthEnd AS AsOfDate
	,A.SMCLoadDate
	,A.[SecurityDescription1]	AS [CompanyName]
	--,A.[ReportingAccountName]	AS [MellonAccountName]
	,DA.[AccountName] AS [MellonAccountName]	
	,A.[AssetCategoryDescription] AS [MellonDescription] 
	,ISNULL(A.Shares,0) AS Shares
FROM CTE_SOURCE A1
	INNER JOIN [SMC_DB_Mellon].[dbo].[Holdings] A 
			ON  A.SourceAccountNumber	= A1.SourceAccountNumber 
			AND A.[MellonSecurityID]		= A1.[MellonSecurityID] 
			AND A.[PriceDate]		= A1.ReportedDate
	INNER JOIN  [SMC_DB_Performance].[SMC].[DirectAccounts] DA ON DA.[AccountNumber] = A.SourceAccountNumber
	INNER JOIN [SMC_DB_ASA].[asa].[Accounts] FAS ON FAS.[AccountNumber] = A.SourceAccountNumber 
	INNER JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON FL.[LookupId] = FAS.[StructureType]
	WHERE FL.LookupText = 'Direct'
)
--SELECT * FROM CTE_GROUP

,CTE_SINGLE AS (
SELECT 
	 AccountNumber
    ,SecurityID
	,MAX(ReportedDate) AS ReportedDate
	,MAX(ReportedMktVal) AS ReportedMktVal
	,MAX(SMCLoadDate)	 SMCLoadDate
	,MAX([CompanyName]) AS [CompanyName]
	,MAX([MellonAccountName]) AS [MellonAccountName]
	,MAX([MellonDescription]) AS [MellonDescription] 
	,SUM(Shares) AS Shares
  FROM CTE_GROUP 
  GROUP BY
       [AccountNumber]
      ,[SecurityID]
      ,EOMONTH(ReportedDate)
	having  count(*) = 1
)
--SELECT * FROM CTE_SINGLE
,CTE_SUM AS (
SELECT 
	   AccountNumber
      ,SecurityID
      ,MAX(ReportedDate) AS ReportedDate
	  ,SUM(ReportedMktVal) as ReportedMktVal
	  ,MAX(SMCLoadDate)	 SMCLoadDate
	  ,MAX([CompanyName]) AS [CompanyName]
	  ,MAX([MellonAccountName]) AS [MellonAccountName]
	  ,MAX([MellonDescription]) AS [MellonDescription] 
	  ,SUM(Shares) AS Shares
  FROM CTE_GROUP 
  GROUP BY
       AccountNumber
      ,SecurityID
      ,EOMONTH(ReportedDate)
	having  count(*) >1
)
--SELECT * FROM CTE_SUM
,CTE_UNION AS (
SELECT 'CD' AS DataSource	
		,AccountNumber
		,SecurityID
		,ReportedDate
		,ReportedMktVal
		,EOMONTH(ReportedDate)  AsOfDate
		,SMCLoadDate
		,[CompanyName]
		,[MellonAccountName]
		,[MellonDescription] 
		,Shares
FROM CTE_SINGLE A
UNION ALL
SELECT 'CD' AS DataSource	
		,AccountNumber
		,SecurityID
		,ReportedDate
		,ReportedMktVal
		,EOMONTH(ReportedDate)  AsOfDate
		,SMCLoadDate
		,[CompanyName]
		,[MellonAccountName]
		,[MellonDescription] 
		,Shares
FROM CTE_SUM 
)
SELECT * FROM CTE_UNION 
