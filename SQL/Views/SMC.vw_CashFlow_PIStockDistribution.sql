/*================================================================================================
	Comments:
	Filename:		SMC_vw_CashFlow_PIStockDistribution
	Author:			John Alton
	Create date:	5/27/2015
	Description:	Get the PI Stock Distribution transactions
	Change History:
	Date			Developer		Description
	
================================================================================================*/

USE [SMC_DB_Performance]
GO

IF object_id(N'SMC.vw_CashFlow_PIStockDistribution', 'V') IS NOT NULL
	DROP VIEW SMC.vw_CashFlow_PIStockDistribution
GO

CREATE VIEW SMC.vw_CashFlow_PIStockDistribution
AS

/*=========================================================================================================
	PI Stock Distribution
=========================================================================================================*/
WITH CTE_PIStockDistributionLineItem AS(
SELECT  TD.AccountNumber 
		,TD.SecurityID 
		,FirstDayOfMonth = [SMC_DB_Reference].[SMC].[ufn_BOMONTH](TD.TransactionDate)
		,TD.TransactionAmt AS StockDistribution
		--,0 * ((CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) - CAST(DAY(TD.TransactionDate) AS NUMERIC(18,4))) + 1) / (CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) -1) AS WGT_CF 
		,CAST( TD.TransactionAmt AS NUMERIC(18,4)) * ((CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) - CAST(DAY(TD.TransactionDate) AS NUMERIC(18,4))) + 1) / CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) AS WGT_CF 
FROM	SMC.Transactions TD 
WHERE	TD.DataSource = 'PI' AND TransactionTypeDesc = 'Stock Distributions'
)
,CTE_PIStockDistributionSum AS(
/*=========================================================================================================
	Capital Calls
=========================================================================================================*/
SELECT  AccountNumber,SecurityID,FirstDayOfMonth,SUM(StockDistribution) AS PIStockDistribution, SUM(WGT_CF) AS PIStockDistributionWGT
FROM 	CTE_PIStockDistributionLineItem 
GROUP BY AccountNumber,SecurityID ,FirstDayOfMonth
)
SELECT  AccountNumber 
		,SecurityID 
		,FirstDayOfMonth 
		,PIStockDistribution
		,PIStockDistributionWGT
FROM	CTE_PIStockDistributionSum 				
	
GO
