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

IF object_id(N'SMC.vw_CashFlow_CDCashPrincipal', 'V') IS NOT NULL
	DROP VIEW SMC.vw_CashFlow_CDCashPrincipal
GO

CREATE VIEW SMC.vw_CashFlow_CDCashPrincipal
AS

WITH CTE_CashPrincipalLineItem AS (
/*=========================================================================================================
	Cash Principal Line Items
=========================================================================================================*/
SELECT  TD.AccountNumber 
		,TD.SecurityID 
		,FirstDayOfMonth = [SMC_DB_Reference].[SMC].[ufn_BOMONTH](TD.TransactionDate)
		,TD.TransactionAmt AS Principal
		,CAST( TD.TransactionAmt AS NUMERIC(18,4)) * ((CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) - CAST(DAY(TD.TransactionDate) AS NUMERIC(18,4))) + 1) / (CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) -1) AS WGT_CF 
FROM	SMC.Transactions TD 
WHERE	TD.DataSource = 'CD' AND TD.TransactionTypeDesc = 'Cash Principal'
)
,CTE_CashPrincipalSum AS (
	SELECT  AccountNumber ,SecurityID,FirstDayOfMonth,SUM(Principal) AS CDCashPrincipal,SUM(WGT_CF) AS CDCashPrincipalWGT
	FROM 	CTE_CashPrincipalLineItem 
	GROUP BY AccountNumber,SecurityID ,FirstDayOfMonth
)

SELECT  AccountNumber 
		,SecurityID 
		,FirstDayOfMonth 
		,CDCashPrincipal
		,CDCashPrincipalWGT
FROM	CTE_CashPrincipalSum				
	
GO
