/*================================================================================================
	Comments:
	Filename:		vw_CashFlow_PICashIncome_RE_Royal
	Author:			John Alton
	Create date:	1.8.15
	Description:	Calculate SMC Cash Flow
	Change History:
	Date			Developer		Description
	
================================================================================================*/

USE [SMC_DB_Performance]
GO

IF object_id(N'SMC.vw_CashFlow_PICashIncome_RE_Royal', 'V') IS NOT NULL
	DROP VIEW SMC.vw_CashFlow_PICashIncome_RE_Royal
GO


CREATE VIEW SMC.vw_CashFlow_PICashIncome_RE_Royal
AS

/*=========================================================================================================
	Cash Income Adj
=========================================================================================================*/
WITH CTE_PICashIncome_RE_RoyalLineItem AS(
SELECT  TD.AccountNumber 
		,TD.SecurityID 
		,FirstDayOfMonth = [SMC_DB_Reference].[SMC].[ufn_BOMONTH](TD.TransactionDate)
		,TD.TransactionAmt AS CashIncomeRERoyal
		,CAST(TD.TransactionAmt AS NUMERIC(18,4)) * ((CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) - CAST(DAY(TD.TransactionDate) AS NUMERIC(18,4))) + 1) / CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4))  AS WGT_CF 
FROM	SMC.Transactions TD 
		--INNER JOIN [SMC_DB_Performance].[SMC].[TransactionTypeLookup] TL ON TL.TransactionTypeLookupID = TD.TransactionTypeLookupID
WHERE	TD.DataSource = 'PI' AND TransactionTypeDesc = 'Cash Income RE/NR Royalties'
)
,CTE_PICashIncome_RE_RoyalSum AS(
/*=========================================================================================================
	Capital Calls
=========================================================================================================*/
SELECT  AccountNumber,SecurityID,FirstDayOfMonth,SUM(CashIncomeRERoyal) AS PICashIncome_RE_Royal, SUM(WGT_CF) AS PICashIncome_RE_RoyalWGT
FROM 	CTE_PICashIncome_RE_RoyalLineItem  
GROUP BY AccountNumber,SecurityID ,FirstDayOfMonth
)
SELECT  AccountNumber 
		,SecurityID 
		,FirstDayOfMonth 
		,PICashIncome_RE_Royal 
		,PICashIncome_RE_RoyalWGT
FROM	CTE_PICashIncome_RE_RoyalSum

	
GO
