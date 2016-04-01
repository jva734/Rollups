/*================================================================================================
	Comments:
	Filename:		vw_SMCCashFlow
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

IF object_id(N'SMC.vw_CashFlow_CDCashIncomeCorrection', 'V') IS NOT NULL
	DROP VIEW SMC.vw_CashFlow_CDCashIncomeCorrection
GO

CREATE VIEW SMC.vw_CashFlow_CDCashIncomeCorrection
AS

WITH CTE_CashIncomeCorrectionLineItem AS (
/*=========================================================================================================
	Cash Income Corrections
=========================================================================================================*/
SELECT  TD.AccountNumber 
		,TD.SecurityID 
		,FirstDayOfMonth = [SMC_DB_Reference].[SMC].[ufn_BOMONTH](TD.TransactionDate)
		,TD.TransactionAmt AS Income
		,CAST( TD.TransactionAmt AS NUMERIC(18,4)) * ((CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) - CAST(DAY(TD.TransactionDate) AS NUMERIC(18,4))) + 1) / (CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) -1) AS WGT_CF 
FROM	SMC.Transactions TD 
		--INNER JOIN [SMC_DB_Performance].[SMC].[TransactionTypeLookup] TL ON TL.TransactionTypeLookupID = TD.TransactionTypeLookupID
WHERE	TD.DataSource = 'CD' AND TransactionTypeDesc = 'Cash Income Corrections'
)
,CTE_CashIncomeCorrectionSum AS (
/*=========================================================================================================
	Income
	CashFlow Distributions - Income Total 
=========================================================================================================*/
SELECT  AccountNumber,SecurityID,FirstDayOfMonth,SUM(Income) AS CDCashIncomeCorrection,SUM(WGT_CF) AS CDCashIncomeCorrectionWGT
FROM 	CTE_CashIncomeCorrectionLineItem 
GROUP BY AccountNumber,SecurityID ,FirstDayOfMonth
)

SELECT  AccountNumber 
		,SecurityID 
		,FirstDayOfMonth 
		,CDCashIncomeCorrection
		,CDCashIncomeCorrectionWGT
FROM	CTE_CashIncomeCorrectionSum				

GO
