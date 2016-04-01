/*================================================================================================
	Comments:
	Filename:		SMC_vw_CashFlow_CashIncome.sql
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

IF object_id(N'SMC.vw_CashFlow_CDCashIncome', 'V') IS NOT NULL
	DROP VIEW SMC.vw_CashFlow_CDCashIncome
GO

CREATE VIEW SMC.vw_CashFlow_CDCashIncome
AS

WITH CTE_CashIncomeLineItem AS (
/*=========================================================================================================
	Cash Income
=========================================================================================================*/
SELECT  TD.AccountNumber 
		,TD.SecurityID 
		,FirstDayOfMonth = [SMC_DB_Reference].[SMC].[ufn_BOMONTH](TD.TransactionDate)
		,TD.TransactionAmt AS Income
		,CAST( TD.TransactionAmt AS NUMERIC(18,4)) * ((CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) - CAST(DAY(TD.TransactionDate) AS NUMERIC(18,4))) + 1) / (CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) -1) AS WGT_CF 
FROM	SMC.Transactions TD 
WHERE	TD.DataSource = 'CD' AND TransactionTypeDesc = 'Cash Income'
)
,CTE_CashIncomeSum AS (
/*=========================================================================================================
	Income
	CashFlow Distributions - Income Total 
=========================================================================================================*/
SELECT  AccountNumber,SecurityID,FirstDayOfMonth,SUM(Income) AS CDCashIncome,SUM(WGT_CF) AS CDCashIncomeWGT
FROM 	CTE_CashIncomeLineItem 
GROUP BY AccountNumber,SecurityID ,FirstDayOfMonth
)

SELECT  AccountNumber 
		,SecurityID 
		,FirstDayOfMonth 
		,CDCashIncome
		,CDCashIncomeWGT
FROM	CTE_CashIncomeSum					
	
GO
