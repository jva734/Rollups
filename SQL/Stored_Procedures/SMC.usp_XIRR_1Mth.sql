/*
===========================================================================================================================================
	Filename		SMC.usp_XIRR_1Mth
	Author			John Alton
	Date			11/2015
	Description		Calculate the IRR_R for 1 Month
	EXEC SMC.usp_XIRR_1Mth
===========================================================================================================================================
*/

USE SMC_DB_Performance
GO

IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_XIRR_1Mth' 
)
   DROP PROCEDURE SMC.usp_XIRR_1Mth
GO

CREATE PROCEDURE SMC.usp_XIRR_1Mth
AS

/*=============================================================
	First Drop the temp tables if they exist
=============================================================*/
IF OBJECT_ID('tempdb..#xirr_CashFlow') IS NOT NULL
BEGIN
    DROP TABLE #xirr_CashFlow
END
IF OBJECT_ID('tempdb..#Results') IS NOT NULL
BEGIN
    DROP TABLE #Results
END


/*This will hold all the cash flows (the EAMV and the transactions*/
CREATE TABLE #xirr_CashFlow (
DataSource varchar(1)
,AccountNumber varchar(25)
,SecurityID varchar(25)
,CFDate date
,MonthEnd date
,CFAmt FLOAT
)
/*Insert the data from MPC this will give us the EAMV for each selected Month End (i.e. end of each qtr)*/
INSERT INTO #xirr_CashFlow 
SELECT 'M'
		,AccountNumber
		,SecurityID		 
		,MonthEnd as CFDate
		,MonthEnd
		,EAMV
FROM SMC.vw_XIRR_MonthlyPerformanceCore
ORDER BY AccountNumber,SecurityID,MonthEnd

/*Insert the data from the TransactionMeta table*/
INSERT INTO #xirr_CashFlow 
SELECT 'T'
		,AccountNumber
		,SecurityID		 
		,TransactionDate
		,MonthEnd
		,TransactionAmt
FROM SMC.vw_XIRR_Transactions
ORDER BY AccountNumber,SecurityID,MonthEnd

/*
SELECT * FROM #xirr_CashFlow 
ORDER BY AccountNumber,SecurityID,MonthEnd
DROP TABLE #xirr_CashFlow 
--*/


CREATE TABLE #Results (
AccountNumber varchar(25),
SecurityID varchar(25),
MonthEnd	date,
xirr FLOAT
)


INSERT INTO #Results
SELECT	x.AccountNumber 
		,x.SecurityID 
		,x.MonthEnd	
		,[SMC_DB_Reference].wct.XIRR(CFAmt ,CFDate , NULL) AS XIRR
FROM
	#xirr_CashFlow X
GROUP BY
	x.AccountNumber 
	,x.SecurityID 
	,x.MonthEnd	

/* ===========================================================
	Test the results in SELECT
	===========================================================
	--SELECT * FROM #XIRR WHERE XIRR is not null and xirr <> 0
	SELECT MonthlyPerformanceCoreID
				,x.AccountNumber 
				,x.SecurityID 
				,x.MonthEnd	
				,x.xirr
		FROM SMC.MonthlyPerformanceCore MPC
			INNER JOIN ##Results x ON x.AccountNumber = MPC.AccountNumber AND x.SecurityID = MPC.SecurityID AND x.MonthEnd = MPC.MonthEnd
--===========================================================*/

/*	===========================================================
	UPDATE SMC.MonthlyPerformanceCore WITH THE xirr value
	===========================================================*/

UPDATE MPC
	SET MPC.IRR1MReported = x.xirr
FROM SMC.MonthlyPerformanceCore MPC
	INNER JOIN #Results x ON x.AccountNumber = MPC.AccountNumber AND x.SecurityID = MPC.SecurityID AND x.MonthEnd = MPC.MonthEnd

/* ===========================================================
	Test the UPDATE results 
	===========================================================
		SELECT MPC.MonthlyPerformanceCoreID
				,MPC.AccountNumber
				,MPC.SecurityID		 
				,MPC.MonthEnd
				,X.IRR1MReported 
		FROM SMC.vw_XIRR_MonthlyPerformanceCore MPC
			INNER JOIN SMC.MonthlyPerformanceCore X ON x.AccountNumber = MPC.AccountNumber AND x.SecurityID = MPC.SecurityID AND x.MonthEnd = MPC.MonthEnd
		ORDER BY AccountNumber,SecurityID,MonthEnd
--	===========================================================*/


DROP TABLE #Results
DROP TABLE #xirr_CashFlow 


