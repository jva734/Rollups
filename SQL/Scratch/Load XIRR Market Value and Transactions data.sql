-- Load XIRR Market Value and Transactions data

USE SMC_DB_Performance
GO

TRUNCATE TABLE SMC.XIRR_MonthlyPerformance

INSERT INTO SMC.XIRR_MonthlyPerformance
SELECT 	 AccountNumber
		,SecurityID		 
		,MonthStart
		,MonthEnd 
		,MonthEndLag3 
		,MonthEndLag12 
		,MonthEndLag36 
		,MonthEndLag60 
		,MonthEndLag84 
		,MonthEndLag120 
		,EAMV
FROM SMC.vw_XIRR_MonthlyPerformanceCore


select * from SMC.XIRR_MonthlyPerformance


TRUNCATE TABLE [SMC].[XIRR_Transactions]

INSERT INTO [SMC].[XIRR_Transactions]
SELECT 	 AccountNumber
		,SecurityID		 
		,MonthStart
		,MonthEnd 
		,TransactionDate
		,TransactionAmt
FROM SMC.vw_XIRR_Transactions

SELECT * FROM [SMC].[XIRR_Transactions]

