/*================================================================================================
	Comments:
	Filename:		vw_CashFlow
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

IF object_id(N'SMC.vw_CashFlow_CDCashPrincipalCorrections', 'V') IS NOT NULL
	DROP VIEW SMC.vw_CashFlow_CDCashPrincipalCorrections
GO

CREATE VIEW SMC.vw_CashFlow_CDCashPrincipalCorrections
AS

WITH CTE_CashPrincipalCorrectionsLineItem  AS(
/*=========================================================================================================
	Cash Principal Corrections
=========================================================================================================*/
SELECT  TD.AccountNumber 
		,TD.SecurityID 
		,FirstDayOfMonth = [SMC_DB_Reference].[SMC].[ufn_BOMONTH](TD.TransactionDate)
		,TD.TransactionAmt AS Correction
		,CAST( TD.TransactionAmt AS NUMERIC(18,4)) * ((CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) - CAST(DAY(TD.TransactionDate) AS NUMERIC(18,4))) + 1) / (CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) -1) AS WGT_CF 
FROM	SMC.Transactions TD 
		--INNER JOIN [SMC_DB_Performance].[SMC].[TransactionTypeLookup] TL ON TL.TransactionTypeLookupID = TD.TransactionTypeLookupID
WHERE	TD.DataSource = 'CD' AND TransactionTypeDesc = 'Cash Principal Corrections'   
)
,CTE_CashPrincipalCorrectionsSum AS(
	SELECT  AccountNumber ,SecurityID,FirstDayOfMonth,SUM(Correction) AS CDCashPrincipalCorrections ,SUM(WGT_CF) AS CDCashPrincipalCorrectionsWGT
	FROM 	CTE_CashPrincipalCorrectionsLineItem  
	GROUP BY AccountNumber,SecurityID ,FirstDayOfMonth
)

SELECT  AccountNumber 
		,SecurityID 
		,FirstDayOfMonth 
		,CDCashPrincipalCorrections
		,CDCashPrincipalCorrectionsWGT
FROM	CTE_CashPrincipalCorrectionsSum				
	
GO
