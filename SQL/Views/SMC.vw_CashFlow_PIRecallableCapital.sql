/*================================================================================================
	Comments:
	Filename:		SMC_vw_CashFlow_PIRecallableCapital.sql
	Author:			John Alton
	Create date:	1.8.15
	Description:	Calculate SMC Cash Flow
	Change History:
	Date			Developer		Description
	
================================================================================================*/

USE [SMC_DB_Performance]
GO

IF object_id(N'SMC.vw_CashFlow_PIRecallableCapital', 'V') IS NOT NULL
	DROP VIEW SMC.vw_CashFlow_PIRecallableCapital
GO


CREATE VIEW SMC.vw_CashFlow_PIRecallableCapital
AS

/*=========================================================================================================
	PI Recallable Capital
=========================================================================================================*/
WITH CTE_PICashIncome_RecallableCapitalLineItem AS(
SELECT  TD.AccountNumber 
		,TD.SecurityID 
		,FirstDayOfMonth = [SMC_DB_Reference].[SMC].[ufn_BOMONTH](TD.TransactionDate)
		,TD.TransactionAmt AS RecallableCapital
		,CAST(TD.TransactionAmt AS NUMERIC(18,4)) * ((CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) - CAST(DAY(TD.TransactionDate) AS NUMERIC(18,4))) + 1) / CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4))  AS WGT_CF 
FROM	SMC.Transactions TD 
WHERE	TD.DataSource = 'PI' AND TransactionTypeDesc = 'Recallable Capital'
)
,CTE_PICashIncome_RecallableCapitalSum AS(
/*=========================================================================================================
	Capital Calls
=========================================================================================================*/
SELECT  AccountNumber,SecurityID,FirstDayOfMonth,SUM(RecallableCapital) AS PIRecallableCapital, SUM(WGT_CF) AS PIRecallableCapitalWGT
FROM 	CTE_PICashIncome_RecallableCapitalLineItem  
GROUP BY AccountNumber,SecurityID ,FirstDayOfMonth
)
SELECT  AccountNumber 
		,SecurityID 
		,FirstDayOfMonth 
		,PIRecallableCapital 
		,PIRecallableCapitalWGT
FROM	CTE_PICashIncome_RecallableCapitalSum

	
GO
