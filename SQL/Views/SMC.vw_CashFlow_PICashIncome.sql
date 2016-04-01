/*================================================================================================
	Comments:
	Filename:		SMC_vw_CashFlow_PICashIncome
	Author:			John Alton
	Create date:	5/27/2015
	Description:	Get the Cash Income transactions
	Change History:
	Date			Developer		Description
	
================================================================================================*/

USE [SMC_DB_Performance]
GO

IF object_id(N'SMC.vw_CashFlow_PICashIncome', 'V') IS NOT NULL
	DROP VIEW SMC.vw_CashFlow_PICashIncome
GO

CREATE VIEW SMC.vw_CashFlow_PICashIncome
AS

/*=========================================================================================================
	Cash Income
=========================================================================================================*/
WITH CTE_PICashIncomeLineItem AS(
SELECT  TD.AccountNumber 
		,TD.SecurityID 
		,FirstDayOfMonth = [SMC_DB_Reference].[SMC].[ufn_BOMONTH](TD.TransactionDate)
		,TD.TransactionAmt AS CashIncome
		,CAST(TD.TransactionAmt AS NUMERIC(18,4)) * ((CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) - CAST(DAY(TD.TransactionDate) AS NUMERIC(18,4))) + 1) / CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4))  AS WGT_CF 
FROM	SMC.Transactions TD 
WHERE	TD.DataSource = 'PI' AND TransactionTypeDesc = 'Cash Income' 
)
,CTE_PICashIncomeSum AS(
/*=========================================================================================================
	Capital Calls
=========================================================================================================*/
SELECT  AccountNumber,SecurityID,FirstDayOfMonth,SUM(CashIncome) AS PICashIncome,SUM(WGT_CF) AS PICashIncomeWGT
FROM 	CTE_PICashIncomeLineItem 
GROUP BY AccountNumber,SecurityID ,FirstDayOfMonth
)
SELECT  AccountNumber 
		,SecurityID 
		,FirstDayOfMonth 
		,PICashIncome
		,PICashIncomeWGT
FROM	CTE_PICashIncomeSum  				

	
GO
