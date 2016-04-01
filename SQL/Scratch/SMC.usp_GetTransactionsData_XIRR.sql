-- =============================================
-- Create basic stored procedure template
-- =============================================

-- Drop stored procedure if it already exists
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_GetTransactionsData_XIRR' 
)
   DROP PROCEDURE SMC.usp_GetTransactionsData_XIRR
GO

CREATE PROCEDURE SMC.usp_GetTransactionsData_XIRR
AS

SELECT TransactionAmt
	,TransactionDate
	,DATEADD(MONTH, DATEDIFF(MONTH, '19000101', TransactionDate), '19000101') as TransactionDateStart
	,EOMONTH(TransactionDate) AS TransactionDateEnd
FROM  [SMC].[Transactions] T 
WHERE TransactionTypeDesc NOT IN ('Recallable Capital')

