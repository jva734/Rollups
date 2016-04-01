/*================================================================================================
	Comments:
	Filename:		vw_CashFlow
	Author:			John Alton
	Create date:	1.8.15
	Description:	Calculate Cash Flow
	Change History:
	Date			Developer		Description
	
The formula for Multiples is

(Current Market Value + Total Distributions + Distribution Corrections) / (Total Capital Calls + Total Capital Call Corrections)

================================================================================================*/

USE SMC_DB_Performance
GO

IF object_id(N'[SMC].vw_CashFlow_CDCapitalCallCorrections', 'V') IS NOT NULL
	DROP VIEW [SMC].vw_CashFlow_CDCapitalCallCorrections
GO

CREATE VIEW [SMC].vw_CashFlow_CDCapitalCallCorrections
AS

WITH CTE_CD_CCCorrectionsLineItem  AS(
/*=========================================================================================================
	Capital Call Corrections 
=========================================================================================================*/
SELECT  TD.AccountNumber 
		,TD.SecurityID 
		,FirstDayOfMonth = [SMC_DB_Reference].[SMC].[ufn_BOMONTH](TD.TransactionDate)
		,TD.TransactionAmt AS Correction
		,CAST(TD.TransactionAmt AS NUMERIC(18,4)) * ((CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) - CAST(DAY(TD.TransactionDate) AS NUMERIC(18,4))) + 1) / (CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) -1) AS WGT_CF 

FROM	SMC.Transactions TD 
WHERE	TD.DataSource = 'CD' AND [TransactionTypeDesc] = 'Capital Call Corrections'
)
,CTE_CD_CCCorrectionsSum AS(
	SELECT  AccountNumber ,SecurityID,FirstDayOfMonth,SUM(Correction) AS CDCCCorrections ,SUM(WGT_CF) AS CDCCCorrectionsWGT
	FROM 	CTE_CD_CCCorrectionsLineItem  
	GROUP BY AccountNumber,SecurityID ,FirstDayOfMonth
)


SELECT  AccountNumber 
		,SecurityID 
		,FirstDayOfMonth 
		,CDCCCorrections
		,CDCCCorrectionsWGT
FROM	CTE_CD_CCCorrectionsSum				


GO
