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

IF object_id(N'SMC.vw_CashFlow_PIAdditionalFees', 'V') IS NOT NULL
	DROP VIEW SMC.vw_CashFlow_PIAdditionalFees
GO

CREATE VIEW SMC.vw_CashFlow_PIAdditionalFees
AS
/*=========================================================================================================
	Additional Fees
=========================================================================================================*/
WITH CTE_PIAdditionalFees AS(
SELECT  TD.AccountNumber 
		,TD.SecurityID 
		,FirstDayOfMonth = [SMC_DB_Reference].[SMC].[ufn_BOMONTH](TD.TransactionDate)
		,TD.TransactionAmt AS AdditionalFees
		,CAST( TD.TransactionAmt AS NUMERIC(18,4)) * ((CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) - CAST(DAY(TD.TransactionDate) AS NUMERIC(18,4))) + 1) / CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) AS WGT_CF 
FROM	SMC.Transactions TD 
WHERE	TD.DataSource = 'PI' AND TransactionTypeDesc = 'Additional Fees'   
)
,CTE_PIAdditionalFeesSum AS(
	SELECT  AccountNumber ,SecurityID,FirstDayOfMonth,SUM(AdditionalFees) AS PIAdditionalFees ,SUM(WGT_CF) AS PIAdditionalFeesWGT
	FROM 	CTE_PIAdditionalFees  
	GROUP BY AccountNumber,SecurityID ,FirstDayOfMonth
)

SELECT  AccountNumber 
		,SecurityID 
		,FirstDayOfMonth 
		,PIAdditionalFees 
		,PIAdditionalFeesWGT
FROM	CTE_PIAdditionalFeesSum				

GO
