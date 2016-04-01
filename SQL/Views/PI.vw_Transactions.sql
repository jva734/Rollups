/*
-- =============================================
-- Author:		Daniel Pan/ John Alton
-- Create date: 02/02/2015
-- Description:	Return a list of PI Transactions from Private I. (SDF Account Only.)
-- 
-- Change History:
-- Date			Developer		Description
-- 5/21/15		John Alton		Added Cash income and Stock Adjustments
-- 5/27/2014	John Alton		Changed Data Source to  [SMC_DB_PrivateI].[dbo].[TransactionHistoryExport]
	1/26/2016	John			Added Investment AS CompanyName,''	AS [MellonAccountName],A.[FundingType] AS [MellonDescription] 
								as we require a Company NAme on all rows and these will provide a value for Orphaned Rows
	john			2/25/16		Expanded the selection to include the Shares Column

-- Command:
-- Select * from [PI].[vw_Transactions]
-- Select * from [SMC_DB_Performance].[SMC].[TransactionTypeLookup] 
SELECT * FROM [SMC_DB_PrivateI].[dbo].[TransactionHistoryExport] 
WHERE Investment IS NULL

select * FROM [SMC_DB_PrivateI].[dbo].[TransactionHistoryExport] A
-- =============================================
*/

USE [SMC_DB_Performance]
GO
/*
IF object_id(N'PI.vw_Transactions', 'V') IS NOT NULL
	DROP VIEW PI.vw_Transactions
GO

CREATE VIEW [PI].[vw_Transactions]
AS 
--*/

WITH CTE_CapitalCalls AS (
	SELECT 
		B.DataSource,
		EOMONTH (A.EffectiveDate) AS AsOfDate, 
		B.AccountNumber,
		CONVERT(NVARCHAR,A.InvestmentID) SecurityID,
		A.EffectiveDate AS TransactionDate,
		(A.Funding * -1) AS TransactionAmt,
		'Capital Calls' AS TransactionTypeDesc,
		EOMONTH (A.EffectiveDate) AS SMCLoadDate -- Temp Code as we do not have an SMCLoadDate column yet
		,A.Investment AS CompanyName
		,''	AS [MellonAccountName]	
		,A.[FundingType] AS [MellonDescription] 
	FROM [SMC_DB_PrivateI].[dbo].[TransactionHistoryExport] A
	INNER JOIN [SMC_DB_Performance].[PI].[vw_InvestmentIDLookup] B ON	A.[InvestmentID] = B.InvestmentID
	WHERE A.Funding  <> 0
)
, CTE_AdditionalFees AS (
	SELECT 
		B.DataSource,
		EOMONTH (A.EffectiveDate) AS AsOfDate, 
		B.AccountNumber,
		CONVERT(NVARCHAR,A.InvestmentID) SecurityID,
		A.EffectiveDate AS TransactionDate,
		(A.AdditionalFees * -1) AS TransactionAmt,
		'Additional Fees' AS TransactionTypeDesc,
		EOMONTH (A.EffectiveDate) AS SMCLoadDate -- Temp Code as we do not have an SMCLoadDate column yet
		,A.Investment AS CompanyName
		,''	AS [MellonAccountName]	
		,A.[FundingType] AS [MellonDescription] 
	FROM [SMC_DB_PrivateI].[dbo].[TransactionHistoryExport] A
	INNER JOIN [SMC_DB_Performance].[PI].[vw_InvestmentIDLookup] B ON	A.[InvestmentID] = B.InvestmentID
	WHERE A.AdditionalFees  <> 0
)
-- SELECT CashReturnOfPrincipal + CashCapitalGainLoss AS CashPrincipalCapitalGains
, CTE_CashPrincipal AS (
	SELECT 
		B.DataSource,
		EOMONTH (A.EffectiveDate) AS AsOfDate, 
		B.AccountNumber,
		CONVERT(NVARCHAR,A.InvestmentID) SecurityID,
		A.EffectiveDate AS TransactionDate,
		ISNULL(A.CashReturnOfPrincipal,0)  + ISNULL(A.CashCapitalGainLoss,0) AS TransactionAmt, 
		'Cash Principal' AS TransactionTypeDesc,
		EOMONTH (A.EffectiveDate) AS SMCLoadDate -- Temp Code as we do not have an SMCLoadDate column yet
		,A.Investment AS CompanyName
		,''	AS [MellonAccountName]	
		,A.[FundingType] AS [MellonDescription] 
	FROM [SMC_DB_PrivateI].[dbo].[TransactionHistoryExport] A
	INNER JOIN [SMC_DB_Performance].[PI].[vw_InvestmentIDLookup] B ON	A.[InvestmentID] = B.InvestmentID
	WHERE (ISNULL(A.CashReturnOfPrincipal,0) <> 0 )  OR (ISNULL(A.CashCapitalGainLoss,0) <> 0 )
)
, CTE_CashIncome AS (
	SELECT 
		B.DataSource,
		EOMONTH (A.EffectiveDate) AS AsOfDate, 
		B.AccountNumber,
		CONVERT(NVARCHAR,A.InvestmentID) SecurityID,
		A.EffectiveDate AS TransactionDate,
		A.[CashIncome] AS TransactionAmt,
		'Cash Income' AS TransactionTypeDesc,
		EOMONTH (A.EffectiveDate) AS SMCLoadDate -- Temp Code as we do not have an SMCLoadDate column yet
		,A.Investment AS CompanyName
		,''	AS [MellonAccountName]	
		,A.[FundingType] AS [MellonDescription] 

	FROM [SMC_DB_PrivateI].[dbo].[TransactionHistoryExport] A
	INNER JOIN [SMC_DB_Performance].[PI].[vw_InvestmentIDLookup] B ON	A.[InvestmentID] = B.InvestmentID
	WHERE A.CashIncome <> 0
	AND A.CashIncomeType	NOT IN ('Royalties','RE/NR Income')
)
, CTE_CashIncome_RE_Royal AS (
	SELECT 
		B.DataSource,
		EOMONTH (A.EffectiveDate) AS AsOfDate, 
		B.AccountNumber,
		CONVERT(NVARCHAR,A.InvestmentID) SecurityID,
		A.EffectiveDate AS TransactionDate,
		A.[CashIncome] AS TransactionAmt,
		'Cash Income RE/NR Royalties' AS TransactionTypeDesc,
		EOMONTH (A.EffectiveDate) AS SMCLoadDate -- Temp Code as we do not have an SMCLoadDate column yet
		,A.Investment AS CompanyName
		,''	AS [MellonAccountName]	
		,A.[FundingType] AS [MellonDescription] 

	FROM [SMC_DB_PrivateI].[dbo].[TransactionHistoryExport] A
	INNER JOIN [SMC_DB_Performance].[PI].[vw_InvestmentIDLookup] B ON	A.[InvestmentID] = B.InvestmentID
	WHERE A.CashIncome <> 0
	AND A.CashIncomeType IN ('Royalties','RE/NR Income')
)

, CTE_StockDistribution AS (
	SELECT 
		B.DataSource,
		EOMONTH (A.EffectiveDate) AS AsOfDate, 
		B.AccountNumber,
		CONVERT(NVARCHAR,A.InvestmentID) SecurityID,
		A.EffectiveDate AS TransactionDate,
		A.StockDistribution AS TransactionAmt,
		'Stock Distributions' AS TransactionTypeDesc,
		EOMONTH (A.EffectiveDate) AS SMCLoadDate -- Temp Code as we do not have an SMCLoadDate column yet
		,A.Investment AS CompanyName
		,''	AS [MellonAccountName]	
		,A.[FundingType] AS [MellonDescription] 

	FROM [SMC_DB_PrivateI].[dbo].[TransactionHistoryExport] A
	INNER JOIN [SMC_DB_Performance].[PI].[vw_InvestmentIDLookup] B ON	A.[InvestmentID] = B.InvestmentID
	WHERE A.StockDistribution  <> 0
)

, CTE_RecallableCapital AS (
	SELECT 
		B.DataSource,
		EOMONTH (A.EffectiveDate) AS AsOfDate, 
		B.AccountNumber,
		CONVERT(NVARCHAR,A.InvestmentID) SecurityID,
		A.EffectiveDate AS TransactionDate,
		A.CashRecallableCapital AS TransactionAmt,
		'Recallable Capital' AS TransactionTypeDesc,
		EOMONTH (A.EffectiveDate) AS SMCLoadDate -- Temp Code as we do not have an SMCLoadDate column yet
		,A.Investment AS CompanyName
		,''	AS [MellonAccountName]	
		,A.[FundingType] AS [MellonDescription] 

	FROM [SMC_DB_PrivateI].[dbo].[TransactionHistoryExport] A
	INNER JOIN [SMC_DB_Performance].[PI].[vw_InvestmentIDLookup] B ON	A.[InvestmentID] = B.InvestmentID
	WHERE A.CashRecallableCapital  <> 0
)
--, CTE_IRR_Funding AS (
--	SELECT 
--		B.DataSource,
--		EOMONTH (A.EffectiveDate) AS AsOfDate, 
--		B.AccountNumber,
--		CONVERT(NVARCHAR,A.InvestmentID) SecurityID,
--		A.EffectiveDate AS TransactionDate,
--		(A.Funding * -1) AS TransactionAmt,
--		'Funding IRR' AS TransactionTypeDesc,
--		EOMONTH (A.EffectiveDate) AS SMCLoadDate -- Temp Code as we do not have an SMCLoadDate column yet
--	FROM [SMC_DB_PrivateI].[dbo].[TransactionHistoryExport] A
--	INNER JOIN [SMC_DB_Performance].[PI].[vw_InvestmentIDLookup] B ON	A.[InvestmentID] = B.InvestmentID
--	WHERE A.Funding  <> 0
--)
--, CTE_IRR_AdditionalFees AS (
--	SELECT 
--		B.DataSource,
--		EOMONTH (A.EffectiveDate) AS AsOfDate, 
--		B.AccountNumber,
--		CONVERT(NVARCHAR,A.InvestmentID) SecurityID,
--		A.EffectiveDate AS TransactionDate,
--		(A.AdditionalFees * -1) AS TransactionAmt,
--		'AdditionalFees IRR' AS TransactionTypeDesc,
--		EOMONTH (A.EffectiveDate) AS SMCLoadDate -- Temp Code as we do not have an SMCLoadDate column yet
--	FROM [SMC_DB_PrivateI].[dbo].[TransactionHistoryExport] A
--	INNER JOIN [SMC_DB_Performance].[PI].[vw_InvestmentIDLookup] B ON	A.[InvestmentID] = B.InvestmentID
--	WHERE A.[AdditionalFees]  <> 0
--)
--, CTE_IRR_CashDistribution AS (
--	SELECT 
--		B.DataSource,
--		EOMONTH (A.EffectiveDate) AS AsOfDate, 
--		B.AccountNumber,
--		CONVERT(NVARCHAR,A.InvestmentID) SecurityID,
--		A.EffectiveDate AS TransactionDate,
--		A.[CashDistribution] AS TransactionAmt,
--		'CashDistribution IRR' AS TransactionTypeDesc,
--		EOMONTH (A.EffectiveDate) AS SMCLoadDate -- Temp Code as we do not have an SMCLoadDate column yet
--	FROM [SMC_DB_PrivateI].[dbo].[TransactionHistoryExport] A
--	INNER JOIN [SMC_DB_Performance].[PI].[vw_InvestmentIDLookup] B ON	A.[InvestmentID] = B.InvestmentID
--	WHERE A.[CashDistribution]  <> 0
--)
--, CTE_IRR_StockDistribution AS (
--	SELECT 
--		B.DataSource,
--		EOMONTH (A.EffectiveDate) AS AsOfDate, 
--		B.AccountNumber,
--		CONVERT(NVARCHAR,A.InvestmentID) SecurityID,
--		A.EffectiveDate AS TransactionDate,
--		A.StockDistribution AS TransactionAmt,
--		'StockDistribution IRR' AS TransactionTypeDesc,
--		EOMONTH (A.EffectiveDate) AS SMCLoadDate -- Temp Code as we do not have an SMCLoadDate column yet
--	FROM [SMC_DB_PrivateI].[dbo].[TransactionHistoryExport] A
--	INNER JOIN [SMC_DB_Performance].[PI].[vw_InvestmentIDLookup] B ON	A.[InvestmentID] = B.InvestmentID
--	WHERE A.StockDistribution <> 0
--)



SELECT 
    A.DataSource,
	A.AsOfDate,
	A.AccountNumber,
	A.SecurityID,
	A.TransactionDate,
	A.TransactionAmt,
	B.TransactionTypeLookupID,
	A.SMCLoadDate
	,A.CompanyName
	,A.[MellonAccountName]	
	,A.[MellonDescription] 
	,0 as Shares
FROM CTE_CapitalCalls A 
	INNER JOIN  [SMC_DB_Performance].[SMC].[TransactionTypeLookup] B
ON A.DataSource = B.DataSource AND A.TransactionTypeDesc = B.TransactionTypeDesc

UNION ALL

SELECT 
    A.DataSource,
	A.AsOfDate,
	A.AccountNumber,
	A.SecurityID,
	A.TransactionDate,
	A.TransactionAmt,
	B.TransactionTypeLookupID,
	A.SMCLoadDate
	,A.CompanyName
	,A.[MellonAccountName]	
	,A.[MellonDescription] 
	,0 as Shares
FROM CTE_AdditionalFees A 
	INNER JOIN  [SMC_DB_Performance].[SMC].[TransactionTypeLookup] B
ON A.DataSource = B.DataSource AND A.TransactionTypeDesc = B.TransactionTypeDesc


UNION ALL


SELECT 
    A.DataSource,
	A.AsOfDate,
	A.AccountNumber,
	A.SecurityID,
	A.TransactionDate,
	A.TransactionAmt,
	B.TransactionTypeLookupID,
	A.SMCLoadDate
	,A.CompanyName
	,A.[MellonAccountName]	
	,A.[MellonDescription] 
	,0 as Shares
FROM CTE_CashPrincipal A 
	INNER JOIN  [SMC_DB_Performance].[SMC].[TransactionTypeLookup] B
ON A.DataSource = B.DataSource AND A.TransactionTypeDesc = B.TransactionTypeDesc

UNION ALL

SELECT 
    A.DataSource,
	A.AsOfDate,
	A.AccountNumber,
	A.SecurityID,
	A.TransactionDate,
	A.TransactionAmt,
	B.TransactionTypeLookupID,
	A.SMCLoadDate
	,A.CompanyName
	,A.[MellonAccountName]	
	,A.[MellonDescription] 
	,0 as Shares
FROM CTE_CashIncome A 
	INNER JOIN  [SMC_DB_Performance].[SMC].[TransactionTypeLookup] B
ON A.DataSource = B.DataSource AND A.TransactionTypeDesc = B.TransactionTypeDesc

UNION ALL

SELECT 
    A.DataSource,
	A.AsOfDate,
	A.AccountNumber,
	A.SecurityID,
	A.TransactionDate,
	A.TransactionAmt,
	B.TransactionTypeLookupID,
	A.SMCLoadDate
	,A.CompanyName
	,A.[MellonAccountName]	
	,A.[MellonDescription] 
	,0 as Shares
FROM CTE_CashIncome_RE_Royal A 
	INNER JOIN  [SMC_DB_Performance].[SMC].[TransactionTypeLookup] B
ON A.DataSource = B.DataSource AND A.TransactionTypeDesc = B.TransactionTypeDesc


UNION ALL

SELECT 
    A.DataSource,
	A.AsOfDate,
	A.AccountNumber,
	A.SecurityID,
	A.TransactionDate,
	A.TransactionAmt,
	B.TransactionTypeLookupID,
	A.SMCLoadDate
	,A.CompanyName
	,A.[MellonAccountName]	
	,A.[MellonDescription] 
	,0 as Shares
FROM CTE_StockDistribution A 
	INNER JOIN  [SMC_DB_Performance].[SMC].[TransactionTypeLookup] B
ON A.DataSource = B.DataSource AND A.TransactionTypeDesc = B.TransactionTypeDesc


UNION ALL

SELECT 
    A.DataSource,
	A.AsOfDate,
	A.AccountNumber,
	A.SecurityID,
	A.TransactionDate,
	A.TransactionAmt,
	B.TransactionTypeLookupID,
	A.SMCLoadDate
	,A.CompanyName
	,A.[MellonAccountName]	
	,A.[MellonDescription] 
	,0 as Shares
FROM CTE_RecallableCapital A 
	INNER JOIN  [SMC_DB_Performance].[SMC].[TransactionTypeLookup] B
ON A.DataSource = B.DataSource AND A.TransactionTypeDesc = B.TransactionTypeDesc

