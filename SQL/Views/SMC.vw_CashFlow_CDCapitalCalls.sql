/*================================================================================================
	Comments:
	Filename:		SMC_vw_CashFlow_CapitalCalls
	Author:			John Alton
	Create date:	1.8.15
	Description:	Calculate SMC Cash Flow
	Change History:
	Date			Developer		Description
	
The formula for Multiples is

(Current Market Value + Total Distributions + Distribution Corrections) / (Total Capital Calls + Total Capital Call Corrections)

================================================================================================*/

USE [SMC_DB_Performance]
GO

IF object_id(N'SMC.vw_CashFlow_CDCapitalCalls', 'V') IS NOT NULL
	DROP VIEW SMC.vw_CashFlow_CDCapitalCalls
GO

CREATE VIEW SMC.vw_CashFlow_CDCapitalCalls
AS

WITH CTE_CapitalCallsLineItem AS(
/*=========================================================================================================
	Capital Calls
=========================================================================================================*/
SELECT  TD.AccountNumber 
		,TD.SecurityID 
		,FirstDayOfMonth = [SMC_DB_Reference].[SMC].[ufn_BOMONTH](TD.TransactionDate)
		,TD.TransactionAmt AS CapitalCall
		,CAST(TD.TransactionAmt AS NUMERIC(18,4)) * ((CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) - CAST(DAY(TD.TransactionDate) AS NUMERIC(18,4))) + 1) / (CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) -1) AS WGT_CF 
		,[TransactionTypeDesc]
FROM	SMC.Transactions TD 
WHERE	TD.DataSource = 'CD' AND TransactionTypeDesc = 'Capital Calls'
)
,CTE_CapitalCallsSum AS(
/*=========================================================================================================
	Capital Calls
=========================================================================================================*/
SELECT  AccountNumber,SecurityID,FirstDayOfMonth,[TransactionTypeDesc],SUM(CapitalCall) AS CDCapitalCalls,SUM(WGT_CF) AS CDCapitalCallsWGT
FROM 	CTE_CapitalCallsLineItem 
GROUP BY AccountNumber,SecurityID ,FirstDayOfMonth,[TransactionTypeDesc] 
)


SELECT  AccountNumber 
		,SecurityID 
		,FirstDayOfMonth 
		,CDCapitalCalls
		,CDCapitalCallsWGT
FROM	CTE_CapitalCallsSum				
	
GO
