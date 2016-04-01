/*
===========================================================================================================================================
	Filename		SMC.usp_XIRR_7Yr
	Author			John Alton
	Date			11/2015
	Description		Calculate the XIRR for 7 year

	EXEC SMC.usp_XIRR_7Yr
===========================================================================================================================================
*/

USE SMC_DB_Performance
GO

--/*
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_XIRR_7Yr' 
)
   DROP PROCEDURE SMC.usp_XIRR_7Yr
GO

CREATE PROCEDURE SMC.usp_XIRR_7Yr
AS

--*/

--/*	TEST VARIABLES
	DECLARE	@AccountNumber varchar(25),@SecurityID varchar(25),@MonthStart date,@MonthEnd date
	SET @AccountNumber = 'LSJF30000002'; SET @SecurityID = '13268'
	SET @MonthStart    = '2004-02-01';   SET @MonthEnd   = '2004-02-29'
--*/

/*=============================================================
	First Drop the temp tables if they exist
=============================================================*/
IF OBJECT_ID('tempdb..#mv') IS NOT NULL
BEGIN
    DROP TABLE #mv
END

IF OBJECT_ID('tempdb..#CF') IS NOT NULL
BEGIN
    DROP TABLE #CF
END
IF OBJECT_ID('tempdb..#xirr') IS NOT NULL
BEGIN
    DROP TABLE #xirr
END

IF OBJECT_ID('tempdb..#Results') IS NOT NULL
BEGIN
    DROP TABLE #Results
END

/*This will hold all the cash flows (the EAMV and the transactions*/
CREATE TABLE #mv (
 AccountNumber varchar(25)
,SecurityID varchar(25)
,MonthStart date
,MonthEnd date
,YrStart date
,YrEnd date
,eamv float
,EAMVLag float
)

/*
Populate first data for each Qtr with Lag data for start of qtr
*/
INSERT INTO #mv
SELECT 	 AccountNumber
		,SecurityID		 
		,MonthStart
		,MonthEnd 
		,MonthEndLag7Yr 
		,MonthEnd 
		,EAMV
		,EAMVLag7Yr
FROM SMC.vw_XIRR_MonthlyPerformanceCore A
WHERE AccountValid7Yr = 1 
ORDER BY  A.AccountNumber,A.SecurityID,A.QtrEnd

/*select
select * from #mv 
WHERE AccountNumber = @AccountNumber  AND  SecurityID = @SecurityID AND MonthEnd   = @MonthEnd  
order BY AccountNumber ,SecurityID, MonthEnd
--*/

--Create a bunch of cash flows 
CREATE TABLE #CF (
 AccountNumber varchar(25)
,SecurityID varchar(25)
,MonthStart date
,MonthEnd date
,YrStart date
,YrEnd date
,TranDate date
,TranAmt float
)

INSERT INTO #cf
SELECT   A.AccountNumber
		,A.SecurityID	
		,A.MonthStart	 
		,A.MonthEnd 		
		,A.MonthEndLag7Yr
		,A.MonthEnd
		,B.TransactionDate
		,B.TransactionAmt
FROM 
	SMC.vw_XIRR_MonthlyPerformanceCore A
	,SMC.vw_XIRR_Transactions B
WHERE   A.AccountValid7Yr	= 1 
	AND B.AccountNumber		= A.AccountNumber 
	AND B.SecurityID		= A.SecurityID 
	AND B.TransactionDate	> A.MonthEndLag7Yr
	AND B.TransactionDate	<= A.MonthEnd
ORDER BY A.AccountNumber,A.SecurityID,A.MonthEnd,B.TransactionDate

/*select
		select * from #cf
		where AccountNumber = @AccountNumber  and SecurityID = @SecurityID 
		order BY AccountNumber ,SecurityID, TranDate
*/



CREATE TABLE #xirr (
 AccountNumber varchar(25)
,SecurityID varchar(25)
,MonthEnd date
,YrEnd date
,dt date
,Amount float
,RowType varchar(1)
)

INSERT INTO #xirr
SELECT AccountNumber ,SecurityID ,MonthEnd ,YrEnd 
,YrStart ,EAMVLag ,'A'
FROM #mv

INSERT INTO #xirr
SELECT AccountNumber ,SecurityID ,MonthEnd ,YrEnd 
,MonthEnd,EAMV ,'Z'
FROM #mv

INSERT INTO #xirr
SELECT AccountNumber ,SecurityID ,MonthEnd ,YrEnd 
,TranDate,TranAmt ,'T'
FROM #cf

/*select
select * from #xirr
WHERE AccountNumber = @AccountNumber  AND  SecurityID = @SecurityID AND MonthEnd = @MonthEnd  
order BY AccountNumber ,SecurityID, dt
--*/

CREATE TABLE #Results (
 AccountNumber varchar(25)
,SecurityID varchar(25)
,YrEnd date
,XIRR Float
)

INSERT INTO #Results
SELECT AccountNumber,SecurityID,YrEnd,[SMC_DB_Reference].wct.XIRR(Amount,dt, null) AS XIRR
FROM #xirr 
GROUP BY AccountNumber ,SecurityID, YrEnd

/*
SELECT * FROM #Results
--*/

/* ===========================================================
	--Test the results in SELECT
	SELECT MonthlyPerformanceCoreID
				,x.AccountNumber 
				,x.SecurityID 
				,x.YrEnd	
				,x.xirr
		FROM SMC.MonthlyPerformanceCore MPC
			INNER JOIN #Results x ON 
				x.AccountNumber = MPC.AccountNumber 
			AND x.SecurityID = MPC.SecurityID 
			AND x.YrEnd = MPC.MonthEnd
--*/

UPDATE MPC
	SET MPC.IRR7YrReported = x.xirr
FROM SMC.MonthlyPerformanceCore MPC
	INNER JOIN #Results x ON x.AccountNumber = MPC.AccountNumber AND x.SecurityID = MPC.SecurityID AND x.YrEnd = MPC.MonthEnd

/* ===========================================================
	--Test the UPDATE results 
		SELECT MPC.MonthlyPerformanceCoreID
				,MPC.AccountNumber
				,MPC.SecurityID		 
				,MPC.MonthEnd
				,X.IRR7YrReported 
		FROM SMC.vw_XIRR_MonthlyPerformanceCore MPC
			INNER JOIN SMC.MonthlyPerformanceCore X ON x.AccountNumber = MPC.AccountNumber AND x.SecurityID = MPC.SecurityID AND x.MonthEnd = MPC.MonthEnd
		ORDER BY AccountNumber,SecurityID,MonthEnd
--	===========================================================*/

DROP TABLE #mv
DROP TABLE #cf
DROP TABLE #xirr
DROP TABLE #Results
