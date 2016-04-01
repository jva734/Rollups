/*================================================================================================
	Comments:
	Filename:		SMC_vw_CashFlow_PICashPrincipal
	Author:			John Alton
	Create date:	5/27/2015
	Description:	Get the Cash Principal transactions
	Change History:
	Date			Developer		Description
	
================================================================================================*/

USE SMC_DB_Performance
GO

IF object_id(N'SMC.vw_CashFlow_PICashPrincipal', 'V') IS NOT NULL
	DROP VIEW SMC.vw_CashFlow_PICashPrincipal
GO

CREATE VIEW SMC.vw_CashFlow_PICashPrincipal
AS

/*=========================================================================================================
	Cash Principal
=========================================================================================================*/
WITH CTE_PICashPrincipalLineItem AS(
SELECT  TD.AccountNumber 
		,TD.SecurityID 
		,FirstDayOfMonth = [SMC_DB_Reference].[SMC].[ufn_BOMONTH](TD.TransactionDate)
		,TD.TransactionAmt AS CashPrincipal
		--,0 * ((CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) - CAST(DAY(TD.TransactionDate) AS NUMERIC(18,4))) + 1) / (CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) -1) AS WGT_CF 
		,CAST( TD.TransactionAmt AS NUMERIC(18,4)) * ((CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) - CAST(DAY(TD.TransactionDate) AS NUMERIC(18,4))) + 1) / CAST(DAY(EOMONTH(TD.TransactionDate)) AS NUMERIC(18,4)) AS WGT_CF 
FROM	SMC.Transactions TD 
WHERE	TD.DataSource = 'PI' AND TransactionTypeDesc = 'Cash Principal'
)
,CTE_PICashPrincipalSum AS(
/*=========================================================================================================
	Capital Calls
=========================================================================================================*/
SELECT  AccountNumber,SecurityID,FirstDayOfMonth,SUM(CashPrincipal) AS PICashPrincipal,SUM(WGT_CF) AS PICashPrincipalWGT
FROM 	CTE_PICashPrincipalLineItem 
GROUP BY AccountNumber,SecurityID ,FirstDayOfMonth
)
SELECT  AccountNumber 
		,SecurityID 
		,FirstDayOfMonth 
		,PICashPrincipal
		,PICashPrincipalWGT
FROM	CTE_PICashPrincipalSum 				
	
GO
