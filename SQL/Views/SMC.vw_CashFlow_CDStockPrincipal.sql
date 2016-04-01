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

IF object_id(N'SMC.vw_CashFlow_CDStockPrincipal', 'V') IS NOT NULL
	DROP VIEW SMC.vw_CashFlow_CDStockPrincipal
GO

CREATE VIEW SMC.vw_CashFlow_CDStockPrincipal
AS

/*=========================================================================================================
	Stock Principal Line Items
=========================================================================================================*/

WITH CTE_StockPrincipalLineItem AS (
SELECT  TD.AccountNumber 
		,TD.SecurityID 
		,FirstDayOfMonth = [SMC_DB_Reference].[SMC].[ufn_BOMONTH](TD.TransactionDate)
		,TD.TransactionAmt AS StockPrincipal
		,CAST( TD.TransactionAmt AS NUMERIC(18,4)) * ((CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) - CAST(DAY(TD.TransactionDate) AS NUMERIC(18,4))) + 1) / (CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) -1) AS WGT_CF 
FROM	SMC.Transactions TD 
		--INNER JOIN [SMC_DB_Performance].[SMC].[TransactionTypeLookup] TL ON TL.TransactionTypeLookupID = TD.TransactionTypeLookupID
WHERE	TD.DataSource = 'CD' AND TransactionTypeDesc = 'Stock Principal'
)
,CTE_StockPrincipalSum AS (
	SELECT  AccountNumber ,SecurityID,FirstDayOfMonth,SUM(StockPrincipal) AS CDStockPrincipal,SUM(WGT_CF) AS CDStockPrincipalWGT
	FROM 	CTE_StockPrincipalLineItem 
	GROUP BY AccountNumber,SecurityID ,FirstDayOfMonth
)

SELECT  AccountNumber 
		,SecurityID 
		,FirstDayOfMonth 
		,CDStockPrincipal
		,CDStockPrincipalWGT
FROM	CTE_StockPrincipalSum				
	
GO
