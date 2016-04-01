USE SMC_DB_Performance
GO

-- =============================================
-- Create basic stored procedure template
-- =============================================

--/* Drop stored procedure if it already exists
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_LoadTransactionMeta' 
)
   DROP PROCEDURE [SMC].[usp_LoadTransactionMeta]
GO

CREATE PROCEDURE [SMC].[usp_LoadTransactionMeta]
AS
--*/

TRUNCATE TABLE [SMC].[TransactionMeta]

;WITH CTE_Trans AS (
	SELECT   TD.AccountNumber
		,TD.SecurityID
		,TD.TransactionDate
		,ISNULL(TD.TransactionAmt,0) TransactionAmt
		,EOMONTH(TD.TransactionDate) MonthEnd
		,TD.TransactionTypeDesc
		,DataSource
	FROM	[SMC_DB_Performance].SMC.Transactions TD 
)
--SELECT * FROM CTE_Trans 
,CTE_Accounts AS (
SELECT   A.AccountNumber
		,A.SecurityID
		,A.MonthStart
		,A.MonthEnd
		,A.ReportedDate
		,ISNULL(A.MarketValue,0) MarketValue
		,ISNULL(A.BAMV,0) BAMV
		,ISNULL(A.EAMV,0) EAMV
		,TD.TransactionDate
		,TD.TransactionAmt
		,TD.TransactionTypeDesc
		,((CAST(DAY(TD.MonthEnd) AS NUMERIC(18,4)) - CAST(DAY(TD.TransactionDate) AS NUMERIC(18,4))) + 1) / (CAST(DAY(TD.MonthEnd) AS NUMERIC(18,4)) -1) AS Wgt
		,CAST(TD.TransactionAmt AS NUMERIC(18,4)) * ((CAST(DAY(TD.MonthEnd) AS NUMERIC(18,4)) - CAST(DAY(TD.TransactionDate) AS NUMERIC(18,4))) + 1) / CAST(DAY(TD.MonthEnd) AS NUMERIC(18,4))  AS WeightedAmount
		,CASE 
				WHEN (TD.TransactionAmt > 0 AND A.BAMV > 0) AND ((TD.TransactionAmt/A.BAMV) > 0.10) THEN 'IR'
				ELSE 'PMD'
		END PeriodType 
		,0 AS OpenedAccount 
		,0 AS ClosedAccount 
		,A.RowType
		,A.DataSource
FROM	[SMC_DB_Performance].[SMC].[MonthlyPerformanceCore] A 
		INNER JOIN CTE_Trans TD 
			 ON TD.AccountNumber	= A.AccountNumber 
			AND TD.SecurityID		= A.SecurityID 
			AND TD.MonthEnd			= A.MonthEnd
)
--select * from CTE_Accounts 
,CTE_TransMeta AS (
	SELECT TM.* 
		,ISNULL(C.[EAMV_CashFlowWGT],0) EAMV_CashFlowWGT
		,ISNULL(C.TotalCashFlow,0) TotalCashFlow
		,ISNULL(C.EAMV_CashFlow,0) EAMV_CashFlow
	FROM CTE_Accounts TM
	JOIN [SMC_DB_Performance].[SMC].[CashFlow] C  
	ON C.AccountNumber = TM.AccountNumber 
	AND C.SecurityID = TM.SecurityID 
	AND C.MonthEnd = TM.MonthEnd

)
--select * from CTE_TransMeta 
INSERT INTO [SMC].[TransactionMeta]	
	(AccountNumber
	,SecurityID
	,MonthStart
	,MonthEnd
	,ReportedDate
	,MarketValue
	,BAMV
	,EAMV
	,TransactionDate
	,TransactionAmt
	,TransactionTypeDesc
	,[Weight]
	,WgtAmount
	,TotalWgtAmount
	,[CashFlow]
	,EAMV_CashFlow
	,PeriodType
	,OpenedAccount
	,ClosedAccount
	,RowType
	,DataSource
	)
SELECT   AccountNumber
		,SecurityID
		,MonthStart
		,MonthEnd
		,ReportedDate
		,MarketValue
		,BAMV
		,EAMV
		,TransactionDate
		,TransactionAmt
		,TransactionTypeDesc
		,Wgt
		,WeightedAmount
		,EAMV_CashFlowWGT
		,TotalCashFlow
		,EAMV_CashFlow
		,PeriodType 
		,0 AS OpenedAccount 
		,0 AS ClosedAccount 
		,RowType
		,DataSource
FROM	CTE_TransMeta 

