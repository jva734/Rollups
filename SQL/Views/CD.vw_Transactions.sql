/*
===========================================================================================================================================
	View			CD.vw_Transactions
	Author			John Alton
	Date			1/27/2015
	Description		View to report data from the Custody Direct Source data to allow for common table mapping across CD and Private i
	SELECT * FROM CD.vw_Transactions

===========================================================================================================================================
	Modifications
	John			2/4/2015	Added AsOfDate. Currently set to be the EOMonth based on the transactions Effective date
	John			2/4/2015	Added logic to link to the FAS system to filter data retrieval to only accounts marked as 'Direct' Accounts
	John			1/26/2016	Added Investment AS CompanyName,''	AS [MellonAccountName],A.[FundingType] AS [MellonDescription] 
								as we require a Company NAme on all rows and these will provide a value for Orphaned Rows
	John			2/4/2016	Added Lookup table to get a accurate Account Name

Column Name
==============
DataSource
AccountNumber
SecurityID
TransactionDate
TransactionAmt
TransactionTypeLookupID
SMCLoadDate
SMCLoadDate


This table was being pulled from originally 
[SMC_DB_Mellon].[dbo].[SIDTransactionDetail]
currently modifing this to pull data from 
[SMC_DB_Mellon].[dbo].[SIDTransactionDetail]
[SMC_DB_Mellon].[dbo].[SIDTransactionDetail] TD 

SELECT * FROM	[SMC_DB_Mellon].[dbo].[SIDTransactionDetail] TD 
where [Security Description 1]  is null

SELECT * FROM CD.vw_Transactions
where companyname is null

*/

USE [SMC_DB_Performance]
GO
/*
IF object_id(N'CD.vw_Transactions', 'V') IS NOT NULL
	DROP VIEW CD.vw_Transactions
GO

CREATE VIEW CD.vw_Transactions
AS
--*/

--/*debug
declare @AccountNumber varchar(25), @SecurityID varchar(25)
set @AccountNumber = 'LSJF86000002'
set @SecurityID  = '999J27674'

--*/


;WITH CTE_FirmCodes AS (
	SELECT distinct [Firm Code] FROM [SMC_DB_Mellon].[dbo].[SIDTransactionDetail] 
	WHERE [Firm Code] NOT IN ('A400', 'A1')
)

,CTE_CCCorrections AS(
/*=========================================================================================================
	Capital Call Corrections 
=========================================================================================================*/
-- This code is for completeness in case any Transactions Lookups require not to be filtered by Firm code
SELECT  'CD' AS DataSource,EOMONTH([Effective Date]) AS AsOfDate,TD.[Source Account Number] AS AccountNumber,TD.[Mellon Security ID] AS SecurityID,[Effective Date] as TransactionDate
,TD.[Base Cost]  AS TransactionAmt
--,TD.[Base Amount]  AS TransactionAmt
,B.TransactionTypeLookupID ,TD.[SMC Load Date] AS SMCLoadDate
--,CASE 
--	WHEN [Security Description 1] IS NULL THEN [Reporting Account Name]
--	ELSE [Security Description 1] 
--END AS CompanyName
,[Security Description 1] AS CompanyName
--,[Reporting Account Name]	AS [MellonAccountName]	
,DA.[AccountName] AS [MellonAccountName]	
,[Asset Category Description] AS [MellonDescription] 
FROM	[SMC_DB_Mellon].[dbo].[SIDTransactionDetail] TD 
		INNER JOIN  [SMC_DB_Performance].[SMC].[DirectAccounts] DA ON DA.[AccountNumber] = TD.[Source Account Number]
		INNER JOIN [SMC_DB_ASA].[asa].[Accounts] FAS ON FAS.[AccountNumber] = TD.[Source Account Number] 
		INNER JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON FL.[LookupId] = FAS.[StructureType]
		INNER JOIN  [SMC_DB_Performance].[SMC].[TransactionTypeLookup] B 
		ON	 TD.[Tax Code] = B.[TaxCode]
		AND  TD.[Transaction Code] = B.[SubTransactionCode]	
		AND  TD.[Asset Category Code] = B.[AssetCategoryCode]
WHERE  FAS.IsCustodied = 1 AND FL.LookupText = 'Direct' AND  B.[DataSource] = 'CD' AND B.TransactionTypeDesc = 'Capital Call Corrections' AND B.FirmCodeFilter = 0
)
,CTE_CapitalCallsLineItem AS(
/*=========================================================================================================
	Capital Calls
=========================================================================================================*/
-- This code is for completeness in case any Transactions Lookups require not to be filtered by Firm code
SELECT  'CD' AS DataSource,EOMONTH ( [Effective Date] ) AS AsOfDate,TD.[Source Account Number] AS AccountNumber,TD.[Mellon Security ID] AS SecurityID,[Effective Date] as TransactionDate
,TD.[Base Cost]  AS TransactionAmt
,B.TransactionTypeLookupID ,TD.[SMC Load Date] AS SMCLoadDate
--,CASE 
--	WHEN [Security Description 1] IS NULL THEN [Reporting Account Name]
--	ELSE [Security Description 1] 
--END AS CompanyName
,[Security Description 1] AS CompanyName
--,[Reporting Account Name]	AS [MellonAccountName]	
,DA.[AccountName] AS [MellonAccountName]	
,[Asset Category Description] AS [MellonDescription] 

FROM	[SMC_DB_Mellon].[dbo].[SIDTransactionDetail] TD 
		INNER JOIN  [SMC_DB_Performance].[SMC].[DirectAccounts] DA ON DA.[AccountNumber] = TD.[Source Account Number]
		INNER JOIN [SMC_DB_ASA].[asa].[Accounts] FAS ON FAS.[AccountNumber] = TD.[Source Account Number] 
		INNER JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON FL.[LookupId] = FAS.[StructureType]
		INNER JOIN  [SMC_DB_Performance].[SMC].[TransactionTypeLookup] B 
		ON	 TD.[Tax Code] = B.[TaxCode]
		AND  TD.[Transaction Code] = B.[SubTransactionCode]	
		AND  TD.[Asset Category Code] = B.[AssetCategoryCode]
WHERE FAS.IsCustodied = 1 AND FL.LookupText = 'Direct' AND  B.[DataSource] = 'CD' AND B.TransactionTypeDesc = 'Capital Calls' AND B.FirmCodeFilter = 0
)
,CTE_CashIncomeLineItemFirm AS (
/*=========================================================================================================
	Cach Income
=========================================================================================================*/
SELECT  'CD' AS DataSource,EOMONTH ( [Effective Date] ) AS AsOfDate,TD.[Source Account Number] AS AccountNumber,TD.[Mellon Security ID] AS SecurityID,[Effective Date] as TransactionDate
,TD.[Base Amount]  AS TransactionAmt
,B.TransactionTypeLookupID ,TD.[SMC Load Date] AS SMCLoadDate
--,CASE 
--	WHEN [Security Description 1] IS NULL THEN [Reporting Account Name]
--	ELSE [Security Description 1] 
--END AS CompanyName
,[Security Description 1] AS CompanyName
--,[Reporting Account Name]	AS [MellonAccountName]	
,DA.[AccountName] AS [MellonAccountName]	
,[Asset Category Description] AS [MellonDescription] 

FROM	[SMC_DB_Mellon].[dbo].[SIDTransactionDetail] TD 
		INNER JOIN  [SMC_DB_Performance].[SMC].[DirectAccounts] DA ON DA.[AccountNumber] = TD.[Source Account Number]
		INNER JOIN [SMC_DB_ASA].[asa].[Accounts] FAS ON FAS.[AccountNumber] = TD.[Source Account Number] 
		INNER JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON FL.[LookupId] = FAS.[StructureType]
		INNER JOIN  [SMC_DB_Performance].[SMC].[TransactionTypeLookup] B 
			ON	 TD.[Tax Code] = B.[TaxCode]
			AND  TD.[Transaction Code] = B.[SubTransactionCode]	
		INNER JOIN CTE_FirmCodes C ON TD.[Firm Code] = C.[Firm Code]
WHERE FAS.IsCustodied = 1 AND  FL.LookupText = 'Direct' AND  B.[DataSource] = 'CD' 
	AND B.TransactionTypeDesc = 'Cash Income'
	AND B.FirmCodeFilter = 1

)
,CTE_CashIncomeLineItemTS AS (
SELECT  'CD' AS DataSource,EOMONTH ( [Effective Date] ) AS AsOfDate,TD.[Source Account Number] AS AccountNumber,TD.[Mellon Security ID] AS SecurityID,[Effective Date] as TransactionDate
,TD.[Base Amount]  AS TransactionAmt
,B.TransactionTypeLookupID ,TD.[SMC Load Date] AS SMCLoadDate
,[Security Description 1] AS CompanyName
--,[Reporting Account Name]	AS [MellonAccountName]	
,DA.[AccountName] AS [MellonAccountName]	
,[Asset Category Description] AS [MellonDescription] 

FROM	[SMC_DB_Mellon].[dbo].[SIDTransactionDetail] TD 
		INNER JOIN  [SMC_DB_Performance].[SMC].[DirectAccounts] DA ON DA.[AccountNumber] = TD.[Source Account Number]
		INNER JOIN [SMC_DB_ASA].[asa].[Accounts] FAS ON FAS.[AccountNumber] = TD.[Source Account Number] 
		INNER JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON FL.[LookupId] = FAS.[StructureType]
		INNER JOIN  [SMC_DB_Performance].[SMC].[TransactionTypeLookup] B 
		ON	 TD.[Tax Code] = B.[TaxCode]
		AND  TD.[Transaction Code] = B.[SubTransactionCode]	
WHERE FAS.IsCustodied = 1 AND FL.LookupText = 'Direct' AND  B.[DataSource] = 'CD' 
	AND B.TransactionTypeDesc = 'Cash Income'
	AND B.FirmCodeFilter = 0

)

,CTE_CashIncomeLineItemTSA AS (
SELECT  'CD' AS DataSource,EOMONTH ( [Effective Date] ) AS AsOfDate,TD.[Source Account Number] AS AccountNumber,TD.[Mellon Security ID] AS SecurityID,[Effective Date] as TransactionDate
,TD.[Base Amount]  AS TransactionAmt
,B.TransactionTypeLookupID ,TD.[SMC Load Date] AS SMCLoadDate
--,CASE 
--	WHEN [Security Description 1] IS NULL THEN [Reporting Account Name]
--	ELSE [Security Description 1] 
--END AS CompanyName
,[Security Description 1] AS CompanyName
--,[Reporting Account Name]	AS [MellonAccountName]	
,DA.[AccountName] AS [MellonAccountName]	
,[Asset Category Description] AS [MellonDescription] 

FROM	[SMC_DB_Mellon].[dbo].[SIDTransactionDetail] TD 
		INNER JOIN  [SMC_DB_Performance].[SMC].[DirectAccounts] DA ON DA.[AccountNumber] = TD.[Source Account Number]
		INNER JOIN [SMC_DB_ASA].[asa].[Accounts] FAS ON FAS.[AccountNumber] = TD.[Source Account Number] 
		INNER JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON FL.[LookupId] = FAS.[StructureType]
		INNER JOIN  [SMC_DB_Performance].[SMC].[TransactionTypeLookup] B 
		ON	 TD.[Tax Code] = B.[TaxCode]
		AND  TD.[Transaction Code] = B.[SubTransactionCode]	
		AND  TD.[Asset Category Code] = B.[AssetCategoryCode]
WHERE FAS.IsCustodied = 1 AND FL.LookupText = 'Direct' AND  B.[DataSource] = 'CD' 
	AND B.TransactionTypeDesc = 'Cash Income'
	AND B.FirmCodeFilter = 0
)
,CTE_CashIncomeCorrectionsTS AS (
/*=========================================================================================================
	Cach Income Corrections
=========================================================================================================*/
SELECT  'CD' AS DataSource,EOMONTH ( [Effective Date] ) AS AsOfDate,TD.[Source Account Number] AS AccountNumber,TD.[Mellon Security ID] AS SecurityID,[Effective Date] as TransactionDate
,TD.[Base Amount]  AS TransactionAmt
,B.TransactionTypeLookupID ,TD.[SMC Load Date] AS SMCLoadDate
--,CASE 
--	WHEN [Security Description 1] IS NULL THEN [Reporting Account Name]
--	ELSE [Security Description 1] 
--END AS CompanyName
,[Security Description 1] AS CompanyName
--,[Reporting Account Name]	AS [MellonAccountName]	
,DA.[AccountName] AS [MellonAccountName]	
,[Asset Category Description] AS [MellonDescription] 

FROM	[SMC_DB_Mellon].[dbo].[SIDTransactionDetail] TD 
		INNER JOIN  [SMC_DB_Performance].[SMC].[DirectAccounts] DA ON DA.[AccountNumber] = TD.[Source Account Number]
		INNER JOIN [SMC_DB_ASA].[asa].[Accounts] FAS ON FAS.[AccountNumber] = TD.[Source Account Number] 
		INNER JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON FL.[LookupId] = FAS.[StructureType]
		INNER JOIN  [SMC_DB_Performance].[SMC].[TransactionTypeLookup] B 
		ON	 TD.[Tax Code] = B.[TaxCode]
		AND  TD.[Transaction Code] = B.[SubTransactionCode]	
WHERE FAS.IsCustodied = 1 AND FL.LookupText = 'Direct' AND  B.[DataSource] = 'CD' 
	AND B.TransactionTypeDesc = 'Cash Income Corrections'
	AND B.FirmCodeFilter = 0
)
,CTE_CashIncomeCorrectionsTSA AS (
SELECT  'CD' AS DataSource,EOMONTH ( [Effective Date] ) AS AsOfDate,TD.[Source Account Number] AS AccountNumber,TD.[Mellon Security ID] AS SecurityID,[Effective Date] as TransactionDate
,TD.[Base Amount]  AS TransactionAmt
,B.TransactionTypeLookupID ,TD.[SMC Load Date] AS SMCLoadDate
--,CASE 
--	WHEN [Security Description 1] IS NULL THEN [Reporting Account Name]
--	ELSE [Security Description 1] 
--END AS CompanyName
,[Security Description 1] AS CompanyName
--,[Reporting Account Name]	AS [MellonAccountName]	
,DA.[AccountName] AS [MellonAccountName]	
,[Asset Category Description] AS [MellonDescription] 

FROM	[SMC_DB_Mellon].[dbo].[SIDTransactionDetail] TD 
		INNER JOIN  [SMC_DB_Performance].[SMC].[DirectAccounts] DA ON DA.[AccountNumber] = TD.[Source Account Number]
		INNER JOIN [SMC_DB_ASA].[asa].[Accounts] FAS ON FAS.[AccountNumber] = TD.[Source Account Number] 
		INNER JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON FL.[LookupId] = FAS.[StructureType]
		INNER JOIN  [SMC_DB_Performance].[SMC].[TransactionTypeLookup] B 
		ON	 TD.[Tax Code] = B.[TaxCode]
		AND  TD.[Transaction Code] = B.[SubTransactionCode]	
		AND  TD.[Asset Category Code] = B.[AssetCategoryCode]
WHERE FAS.IsCustodied = 1 AND FL.LookupText = 'Direct' AND  B.[DataSource] = 'CD' 
	AND B.TransactionTypeDesc = 'Cash Income Corrections'
	AND B.FirmCodeFilter = 1
)

/*=========================================================================================================
	Cash Principal Line Items - with Firm Code Filter
=========================================================================================================*/
,CTE_CashPrincipalLineItem AS (
SELECT  'CD' AS DataSource,EOMONTH ( [Effective Date] ) AS AsOfDate,TD.[Source Account Number] AS AccountNumber,TD.[Mellon Security ID] AS SecurityID,[Effective Date] as TransactionDate
,TD.[Base Amount]  AS TransactionAmt
,B.TransactionTypeLookupID,TD.[SMC Load Date] AS SMCLoadDate
--,CASE 
--	WHEN [Security Description 1] IS NULL THEN [Reporting Account Name]
--	ELSE [Security Description 1] 
--END AS CompanyName
,[Security Description 1] AS CompanyName
--,[Reporting Account Name]	AS [MellonAccountName]	
,DA.[AccountName] AS [MellonAccountName]	
,[Asset Category Description] AS [MellonDescription] 

FROM	[SMC_DB_Mellon].[dbo].[SIDTransactionDetail] TD 
		INNER JOIN  [SMC_DB_Performance].[SMC].[DirectAccounts] DA ON DA.[AccountNumber] = TD.[Source Account Number]
		INNER JOIN [SMC_DB_ASA].[asa].[Accounts] FAS ON FAS.[AccountNumber] = TD.[Source Account Number] 
		INNER JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON FL.[LookupId] = FAS.[StructureType]
		INNER JOIN  [SMC_DB_Performance].[SMC].[TransactionTypeLookup] B 
		ON	 TD.[Tax Code] = B.[TaxCode]
		AND  TD.[Transaction Code] = B.[SubTransactionCode]	
		AND  TD.[Asset Category Code] = B.[AssetCategoryCode]
		INNER JOIN CTE_FirmCodes C ON TD.[Firm Code] = C.[Firm Code]
WHERE FAS.IsCustodied = 1 AND  FL.LookupText = 'Direct' AND B.[DataSource] = 'CD' AND B.TransactionTypeDesc = 'Cash Principal' AND B.FirmCodeFilter = 1
)

, CTE_CashPrincipalCorrections AS(
-- This code is for completeness in case any Transactions Lookups require not to be filtered by Firm code
SELECT  'CD' AS DataSource,EOMONTH ( [Effective Date] ) AS AsOfDate,TD.[Source Account Number] AS AccountNumber,TD.[Mellon Security ID] AS SecurityID,[Effective Date] as TransactionDate
,TD.[Base Amount]  AS TransactionAmt
,B.TransactionTypeLookupID ,TD.[SMC Load Date] AS SMCLoadDate
--,CASE [Security Description 1] 
--	WHEN NULL THEN [Reporting Account Name]
--	ELSE [Security Description 1] 
--END AS CompanyName
,[Security Description 1] AS CompanyName
--,[Reporting Account Name]	AS [MellonAccountName]	
,DA.[AccountName] AS [MellonAccountName]	
,[Asset Category Description] AS [MellonDescription] 

FROM	[SMC_DB_Mellon].[dbo].[SIDTransactionDetail] TD 
		INNER JOIN  [SMC_DB_Performance].[SMC].[DirectAccounts] DA ON DA.[AccountNumber] = TD.[Source Account Number]
		INNER JOIN [SMC_DB_ASA].[asa].[Accounts] FAS ON FAS.[AccountNumber] = TD.[Source Account Number] 
		INNER JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON FL.[LookupId] = FAS.[StructureType]
		INNER JOIN  [SMC_DB_Performance].[SMC].[TransactionTypeLookup] B 
		ON	 TD.[Tax Code] = B.[TaxCode]
		AND  TD.[Transaction Code] = B.[SubTransactionCode]	
		AND  TD.[Asset Category Code] = B.[AssetCategoryCode]
WHERE FAS.IsCustodied = 1 AND FL.LookupText = 'Direct' AND  B.[DataSource] = 'CD' AND B.TransactionTypeDesc = 'Cash Principal Corrections' AND B.FirmCodeFilter = 0
)
,CTE_StockIncomeLineItem AS (
/*=========================================================================================================
	Stock Income
	CashFlow Distributions - Income Total Part 1
=========================================================================================================*/
SELECT  'CD' AS DataSource,EOMONTH ( [Effective Date] ) AS AsOfDate,TD.[Source Account Number] AS AccountNumber,TD.[Mellon Security ID] AS SecurityID,[Effective Date] as TransactionDate
,TD.[Base Amount]  AS TransactionAmt
,B.TransactionTypeLookupID ,TD.[SMC Load Date] AS SMCLoadDate
--,CASE [Security Description 1] 
--	WHEN NULL THEN [Reporting Account Name]
--	ELSE [Security Description 1] 
--END AS CompanyName
,[Security Description 1] AS CompanyName
--,[Reporting Account Name]	AS [MellonAccountName]	
,DA.[AccountName] AS [MellonAccountName]	
,[Asset Category Description] AS [MellonDescription] 

FROM	[SMC_DB_Mellon].[dbo].[SIDTransactionDetail] TD 
		INNER JOIN  [SMC_DB_Performance].[SMC].[DirectAccounts] DA ON DA.[AccountNumber] = TD.[Source Account Number]
		INNER JOIN [SMC_DB_ASA].[asa].[Accounts] FAS ON FAS.[AccountNumber] = TD.[Source Account Number] 
		INNER JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON FL.[LookupId] = FAS.[StructureType]
		INNER JOIN  [SMC_DB_Performance].[SMC].[TransactionTypeLookup] B 
		ON	 TD.[Tax Code] = B.[TaxCode]
		AND  TD.[Transaction Code] = B.[SubTransactionCode]	
WHERE FAS.IsCustodied = 1 AND FL.LookupText = 'Direct' AND  B.[DataSource] = 'CD' 
	AND B.TransactionTypeDesc = 'Stock Income'
	AND B.FirmCodeFilter = 0
)
,CTE_StockPrincipalLineItem AS (
SELECT  'CD' AS DataSource,EOMONTH ( [Effective Date] ) AS AsOfDate,TD.[Source Account Number] AS AccountNumber,TD.[Mellon Security ID] AS SecurityID,[Effective Date] as TransactionDate
,TD.[Base Amount]  AS TransactionAmt
,B.TransactionTypeLookupID ,TD.[SMC Load Date] AS SMCLoadDate
--,CASE [Security Description 1] 
--	WHEN NULL THEN [Reporting Account Name]
--	ELSE [Security Description 1] 
--END AS CompanyName
,[Security Description 1] AS CompanyName
--,[Reporting Account Name]	AS [MellonAccountName]	
,DA.[AccountName] AS [MellonAccountName]	
,[Asset Category Description] AS [MellonDescription] 

FROM	[SMC_DB_Mellon].[dbo].[SIDTransactionDetail] TD 
		INNER JOIN  [SMC_DB_Performance].[SMC].[DirectAccounts] DA ON DA.[AccountNumber] = TD.[Source Account Number]
		INNER JOIN [SMC_DB_ASA].[asa].[Accounts] FAS ON FAS.[AccountNumber] = TD.[Source Account Number] 
		INNER JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON FL.[LookupId] = FAS.[StructureType]
		INNER JOIN  [SMC_DB_Performance].[SMC].[TransactionTypeLookup] B 
		ON	 TD.[Tax Code] = B.[TaxCode]
		AND  TD.[Transaction Code] = B.[SubTransactionCode]	
		AND  TD.[Asset Category Code] = B.[AssetCategoryCode]
WHERE FAS.IsCustodied = 1 AND FL.LookupText = 'Direct' AND  B.[DataSource] = 'CD' AND B.TransactionTypeDesc = 'Stock Principal' AND B.FirmCodeFilter = 0
)

--/*prod code
SELECT * FROM CTE_CCCorrections  --0
UNION ALL
SELECT * FROM CTE_CapitalCallsLineItem -- 472
UNION ALL
SELECT * FROM CTE_CashIncomeLineItemFirm --275
UNION ALL
SELECT * FROM CTE_CashIncomeLineItemTS
UNION ALL
SELECT * FROM CTE_CashIncomeLineItemTSA
UNION ALL
SELECT * FROM CTE_CashIncomeCorrectionsTS --0
UNION ALL
SELECT * FROM CTE_CashIncomeCorrectionsTSA --0
UNION ALL
SELECT * FROM CTE_CashPrincipalLineItem	--173
UNION ALL
SELECT * FROM CTE_StockIncomeLineItem	--0
UNION ALL
SELECT * FROM CTE_StockPrincipalLineItem --0 
--*/



--SELECT * FROM CTE_CCCorrections  --0
--UNION ALL
--SELECT * FROM CTE_CapitalCallsLineItem -- 472
--WHERE AccountNumber = @AccountNumber AND SecurityID = @SecurityID 
--UNION ALL
--SELECT * FROM CTE_CashIncomeLineItemFirm --275
--WHERE AccountNumber = @AccountNumber AND SecurityID = @SecurityID 
--UNION ALL

--SELECT * FROM CTE_CashIncomeLineItemTS
--WHERE AccountNumber = @AccountNumber AND SecurityID = @SecurityID 
--UNION ALL
--SELECT * FROM CTE_CashIncomeLineItemTSA
----where TransactionTypeLookupID   = 26
--UNION ALL
--SELECT * FROM CTE_CashIncomeCorrectionsTS --0
--UNION ALL
--SELECT * FROM CTE_CashIncomeCorrectionsTSA --0
------where TransactionTypeLookupID = 26
--UNION ALL
--SELECT * FROM CTE_CashPrincipalLineItem	--173
----where TransactionTypeLookupID IN (9,10,11,12)
--UNION ALL
--SELECT * FROM CTE_StockIncomeLineItem	--0
----where TransactionTypeLookupID = 38
--UNION ALL
--SELECT * FROM CTE_StockPrincipalLineItem --0 
--where TransactionTypeLookupID = 37
--order by TransactionTypeLookupID

