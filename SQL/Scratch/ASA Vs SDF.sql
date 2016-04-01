---- PI Data
-------------------
--;WITH CTE_ALL_PI AS (
--	SELECT  [AccountNumber]
--		, [AccountNumber] AS SecurityID
--	FROM    [SMC_DB_ASA].[asa].[Accounts]
--)

--SELECT 'PI' AS DataSource, A.AccountNumber,SecurityID
--FROM CTE_ALL_PI A

--------------------
---- CD Data
-------------------
--;WITH CTE_CD AS (
--SELECT MIN('CD') AS DataSource
--	, ASA.[AccountNumber]
--	, S.MellonSecurityID AS SecurityID
--FROM [SMC_DB_ASA].[asa].[Accounts] ASA 
--	INNER JOIN [SMC_DB_ASA].[asa].[SecurityAccounts] SA ON SA.[Accountid] = ASA.Accountid 
--	INNER JOIN [SMC_DB_ASA].[asa].[Securities]  S ON S.securityid = SA.securityid 
--	INNER JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON FL.[LookupId] = ASA.[StructureType]
--WHERE SA.LiquidatedDate IS NOT NULL 
--  AND ASA.IsCustodied = 1 
--  AND FL.LookupText = 'Direct' 
--GROUP BY ASA.[AccountNumber],S.MellonSecurityID
--)
----INSERT INTO [SMC].[AccountClosed] (DataSource,AccountNumber,SecurityID,AccountClosed,MonthEnd)
--	SELECT 'CD' AS DataSource
--		, A.AccountNumber
--		, A.SecurityID
--	FROM CTE_CD A

/*
-----------------------------------------------------------------

-- PI Data
-----------------
;WITH CTE_ALL_PI AS (
	SELECT  [AccountNumber]
		, [AccountNumber] AS SecurityID
	FROM    [SMC_DB_ASA].[asa].[Accounts]
)
, CTE_CD AS (
SELECT 'CD' AS DataSource
	, ASA.[AccountNumber]
	, S.MellonSecurityID AS SecurityID
FROM [SMC_DB_ASA].[asa].[Accounts] ASA 
	INNER JOIN [SMC_DB_ASA].[asa].[SecurityAccounts] SA ON SA.[Accountid] = ASA.Accountid 
	INNER JOIN [SMC_DB_ASA].[asa].[Securities]  S ON S.securityid = SA.securityid 
	INNER JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON FL.[LookupId] = ASA.[StructureType]
WHERE SA.LiquidatedDate IS NOT NULL 
  AND ASA.IsCustodied = 1 
  AND FL.LookupText = 'Direct' 
GROUP BY ASA.[AccountNumber],S.MellonSecurityID
)
, CTE_ASA AS (
SELECT 'ASA' AS [Source]
		,'CD' AS DataSource
		, A.AccountNumber
		, A.SecurityID
FROM CTE_CD A
UNION ALL
SELECT 'ASA' AS [Source],'PI' AS DataSource, A.AccountNumber,SecurityID
FROM CTE_ALL_PI A
)
,CTE_SDF AS (
SELECT 'SDF' AS [Source]
		, A.DataSource
		, A.AccountNumber
		, A.SecurityID
FROM [SMC_DB_Performance].[SMC].[MonthlyPerformanceFund] A
WHERE DATASOURCE IN ('PI','CD')
GROUP BY A.DataSource, A.AccountNumber, A.SecurityID
)
SELECT A.[Source]
		,A.DataSource
		, A.AccountNumber
		, A.SecurityID
		,B.[Source]
		, B.DataSource
		, B.AccountNumber
		, B.SecurityID
FROM CTE_ASA A
left JOIN CTE_SDF B ON A.DataSource = B.DataSource AND A.ACCOUNTNUMBER = B.ACCOUNTNUMBER
where b.AccountNumber is null

union all

SELECT A.[Source]
		,A.DataSource
		, A.AccountNumber
		, A.SecurityID
		,B.[Source]
		, B.DataSource
		, B.AccountNumber
		, B.SecurityID
FROM  CTE_ASA  A
RIGHT JOIN CTE_SDF B ON A.DataSource = B.DataSource AND A.ACCOUNTNUMBER = B.ACCOUNTNUMBER
where A.AccountNumber is null


*/

/*--PHASE 2
;WITH CTE_SDF AS (
SELECT 'SDF' AS [Source]
		, A.DataSource
		, A.AccountNumber
		, A.SecurityID
		,[CompanyName]
		,[MellonAccountName]
		,[MellonDescription]
FROM [SMC_DB_Performance].[SMC].[MonthlyPerformanceFund] A
WHERE DATASOURCE = 'CD'
)
,CTE_ASA AS (
SELECT 
'ASA' AS [Source]
,a.[AccountNumber]
,a.[MellonAccountName]
,s.[MellonSecurityId]
,s.[MellonDescription]
,s.[LotDescription]
,c.[CompanyName]
FROM [SMC_DB_ASA].[asa].[Accounts] A
	join [SMC_DB_ASA].[asa].[SecurityAccounts] SA on sa.[AccountId] = a.[AccountId]
	join [SMC_DB_ASA].[asa].[Securities] S on S.[SecurityId] = sa.[SecurityId]
	join [SMC_DB_ASA].[asa].[Companies] C ON c.[CompanyId] = s.[CompanyId]
)
SELECT  *
FROM CTE_SDF SDF
	LEFT JOIN CTE_ASA ASA ON ASA.[AccountNumber] = SDF.[AccountNumber] AND ASA.[MellonSecurityId] = SDF.SecurityId
WHERE ASA.[AccountNumber] IS NULL
order BY SDF.AccountNumber, SDF.SecurityID

------------------------------------------------------------------------------------------------------------------------------------
*/


/*
Accounts/Securities that exist in SDF but Not in ASA
*/

;WITH CTE_SDF AS (
SELECT  A.AccountNumber
		, A.SecurityID
		,A.CompanyName
		,A.[MellonAccountName]
FROM [SMC_DB_Performance].[SMC].[MonthlyPerformanceFund] A
WHERE DATASOURCE = 'CD' 
--AND [CompanyName] IS NULL
GROUP BY a.AccountNumber, a.SecurityID,A.CompanyName,A.[MellonAccountName]
)
,CTE_ASA AS (
SELECT a.[AccountNumber]
--,a.[MellonAccountName]
	,s.[MellonSecurityId]
--,s.[MellonDescription]
--,s.[LotDescription]
--,c.[CompanyName]
FROM [SMC_DB_ASA].[asa].[Accounts] A
	join [SMC_DB_ASA].[asa].[SecurityAccounts] SA on sa.[AccountId] = a.[AccountId]
	join [SMC_DB_ASA].[asa].[Securities] S on S.[SecurityId] = sa.[SecurityId]
	--join [SMC_DB_ASA].[asa].[Companies] C ON c.[CompanyId] = s.[CompanyId]
)
SELECT   sdf.AccountNumber
		, sdf.SecurityID
		,sdf.CompanyName
		,sdf.[MellonAccountName]

FROM CTE_SDF SDF
	LEFT JOIN CTE_ASA ASA ON ASA.[AccountNumber] = SDF.[AccountNumber] AND ASA.[MellonSecurityId] = SDF.SecurityId
WHERE ASA.[AccountNumber] IS NULL
--GROUP BY SDF.AccountNumber, SDF.SecurityID
order BY SDF.AccountNumber, SDF.SecurityID




/*
-- PHASE 3
SELECT 
 T.[AccountNumber]
,T.[SecurityID]
,T.[CompanyName] AS [Security Description 1]
,T.[MellonAccountName] AS [Reporting Account Name]
,T.[MellonDescription] AS [Asset Category Description] 
FROM [SMC_DB_Performance].[CD].[vw_Transactions] T

SELECT 
 V.[AccountNumber]
,V.[SecurityID]
,V.[CompanyName] AS [SecurityDescription1]
,V.[MellonAccountName] AS [ReportingAccountName]
,V.[MellonDescription] AS [AssetCategoryDescription]
FROM [SMC_DB_Performance].[CD].vw_Valuations V
GO

;WITH CTE_VIEWS AS (
SELECT 
 T.[AccountNumber]
,T.[SecurityID]
,T.[CompanyName] AS [Security Description 1]
,T.[MellonAccountName] AS [Reporting Account Name]
,T.[MellonDescription] AS [Asset Category Description] 
,V.[AccountNumber] AS vAccount
,V.[SecurityID] as vSecurity
,V.[CompanyName] AS [SecurityDescription1]
,V.[MellonAccountName] AS [ReportingAccountName]
,V.[MellonDescription] AS [AssetCategoryDescription]
,CASE
	WHEN T.[CompanyName] = V.[CompanyName] then 1
	else 0
 END AS NameMatched

FROM [SMC_DB_Performance].[CD].[vw_Transactions] T
	JOIN [SMC_DB_Performance].[CD].vw_Valuations V ON t.[AccountNumber] = V.[AccountNumber] AND T.[SecurityId] = V.SecurityId
where T.[CompanyName] is null and v.[CompanyName] is not null
)
SELECT
 v.[AccountNumber]
,v.[SecurityID]
,v.[SecurityDescription1]
,MP.CompanyName
FROM CTE_VIEWS V
	JOIN [SMC_DB_Performance].[SMC].MonthlyPerformanceFund MP ON MP.[AccountNumber] = V.[AccountNumber] AND MP.[SecurityId] = V.SecurityId
GROUP BY v.[AccountNumber],v.[SecurityID],v.[SecurityDescription1],MP.CompanyName



SELECT COUNT(*) FROM [SMC_DB_Performance].[SMC].MonthlyPerformanceCore WHERE COMPANYNAME IS NULL
SELECT COUNT(*) FROM [SMC_DB_Performance].[SMC].MonthlyPerformanceFund WHERE COMPANYNAME IS NULL

*/
