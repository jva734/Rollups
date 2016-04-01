/*================================================================================================
	Comments:
	Filename:		vw_SMCCashFlow
	Author:			John Alton
	Create date:	1.8.15
	Description:	Calculate SMC Cash Flow
	Change History:
	Date			Developer		Description
	
================================================================================================*/

USE [SMC_DB_Performance]
GO

IF object_id(N'SMC.vw_CashFlow_PICapitalCalls', 'V') IS NOT NULL
	DROP VIEW SMC.vw_CashFlow_PICapitalCalls
GO

CREATE VIEW SMC.vw_CashFlow_PICapitalCalls
AS

/*=========================================================================================================
	Capital Calls
=========================================================================================================*/
WITH CTE_PICapitalCallsLineItem AS(
SELECT  TD.AccountNumber 
		,TD.SecurityID 
		,FirstDayOfMonth = [SMC_DB_Reference].[SMC].[ufn_BOMONTH](TD.TransactionDate)
		,TD.TransactionAmt AS CapitalCall
		,CAST(TD.TransactionAmt AS NUMERIC(18,4)) * ((CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) - CAST(DAY(TD.TransactionDate) AS NUMERIC(18,4))) + 1) / CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4))  AS WGT_CF 
FROM	SMC.Transactions TD 
WHERE	TD.DataSource = 'PI' AND TransactionTypeDesc = 'Capital Calls'
)
,CTE_PICapitalCallsSum AS(
/*=========================================================================================================
	Capital Calls
=========================================================================================================*/
SELECT  AccountNumber,SecurityID,FirstDayOfMonth,SUM(CapitalCall) AS PICapitalCalls ,SUM(WGT_CF) AS PICapitalCallsWGT
FROM 	CTE_PICapitalCallsLineItem 
GROUP BY AccountNumber,SecurityID ,FirstDayOfMonth
)
SELECT  AccountNumber 
		,SecurityID 
		,FirstDayOfMonth 
		,PICapitalCalls  
		,PICapitalCallsWGT
FROM	CTE_PICapitalCallsSum				

	
GO
