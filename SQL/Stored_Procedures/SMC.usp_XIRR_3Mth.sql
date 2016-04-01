/*
===========================================================================================================================================
	Filename		SMC.usp_XIRR_3Mth
	Author			John Alton
	Date			11/2015
	Description		Calculate the IRR_R for 3 Month
	EXEC SMC.usp_XIRR_3Mth
===========================================================================================================================================
*/

USE SMC_DB_Performance
GO
--/*
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_XIRR_3Mth' 
)
   DROP PROCEDURE SMC.usp_XIRR_3Mth
GO

CREATE PROCEDURE SMC.usp_XIRR_3Mth
AS
--*/

/*
	TEST VARIABLES
*/
DECLARE	@AccountNumber varchar(25),@SecurityID varchar(25),@MonthStart date,@MonthEnd date
SET @AccountNumber = 'LSJF30000002'; SET @SecurityID = '13268'
SET @MonthStart    = '2004-02-01';   SET @MonthEnd   = '2004-02-29'


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
,QtrStart date
,QtrEnd date
,eamv float
,EAMVLag3Mo float
)

/*
Populate first data for each Qtr with Lag data for start of qtr
*/
INSERT INTO #mv
SELECT 	 AccountNumber
		,SecurityID		 
		,MonthStart
		,MonthEnd 
		,QtrStart
		,QtrEnd
		,EAMV
		,EAMVLag3Mo
FROM SMC.vw_XIRR_MonthlyPerformanceCore A
WHERE AccountValid3Mo = 1 
ORDER BY  A.AccountNumber,A.SecurityID,A.QtrEnd

/*select
	select * from #mv
	where AccountNumber = @AccountNumber  and SecurityID = @SecurityID 
	order BY AccountNumber ,SecurityID, MonthEnd
*/

--Table of cash flows 
CREATE TABLE #CF (
 AccountNumber varchar(25)
,SecurityID varchar(25)
,MonthStart date
,MonthEnd date
,QtrStart date
,QtrEnd date
,TranDate date
,TranAmt float
)

INSERT INTO #cf
SELECT A.AccountNumber
		,A.SecurityID	
		,A.MonthStart	 
		,A.MonthEnd 
		,A.QtrStart
		,A.QtrEnd 
		,TransactionDate
		,TransactionAmt
FROM SMC.vw_XIRR_Transactions A
	 JOIN #MV B 
		ON  B.AccountNumber = A.AccountNumber 
		AND B.SecurityID    = A.SecurityID 
		AND B.QtrStart = A.QtrStart
		AND B.QtrEnd = A.QtrEnd
ORDER BY  A.AccountNumber,A.SecurityID,A.QtrEnd

/*select
		select * from #cf
		where AccountNumber = @AccountNumber  and SecurityID = @SecurityID 
		order BY AccountNumber ,SecurityID, TranDate
*/

CREATE TABLE #xirr (
 AccountNumber varchar(25)
,SecurityID varchar(25)
,MonthEnd date
,QtrEnd date
,dt date
,Amount float
,RowType varchar(1)
)

INSERT INTO #xirr
SELECT AccountNumber ,SecurityID ,MonthEnd ,QtrEnd 
,QtrStart ,EAMVLag3Mo ,'A'
FROM #mv

INSERT INTO #xirr
SELECT AccountNumber ,SecurityID ,MonthEnd ,QtrEnd 
,QtrEnd,EAMV ,'Z'
FROM #mv

INSERT INTO #xirr
SELECT AccountNumber ,SecurityID ,MonthEnd ,QtrEnd 
,TranDate,TranAmt ,'T'
FROM #cf

/*select
	select * from #xirr
	where AccountNumber = @AccountNumber  and SecurityID = @SecurityID 
	order BY AccountNumber ,SecurityID,MonthStart,RowType
*/

CREATE TABLE #Results (
 AccountNumber varchar(25)
,SecurityID varchar(25)
,QtrEnd date
,XIRR Float
)

INSERT INTO #Results
	SELECT AccountNumber,SecurityID,QtrEnd,[SMC_DB_Reference].wct.XIRR(Amount,dt, null) AS XIRR
FROM #xirr 
GROUP BY AccountNumber ,SecurityID, QtrEnd

/* ===========================================================
	--Test the results in SELECT
	--SELECT * FROM #XIRR WHERE XIRR is not null and xirr <> 0
	SELECT MonthlyPerformanceCoreID
				,x.AccountNumber 
				,x.SecurityID 
				,x.QtrEnd	
				,x.xirr
		FROM SMC.MonthlyPerformanceCore MPC
			INNER JOIN #Results x ON 
				x.AccountNumber = MPC.AccountNumber 
			AND x.SecurityID = MPC.SecurityID 
			AND x.QtrEnd = MPC.MonthEnd
--===========================================================*/

UPDATE MPC
	SET MPC.IRR3MReported = x.xirr
FROM SMC.MonthlyPerformanceCore MPC
	INNER JOIN #Results x ON x.AccountNumber = MPC.AccountNumber AND x.SecurityID = MPC.SecurityID AND x.QtrEnd = MPC.MonthEnd

/* ===========================================================
	--Test the UPDATE results 
		SELECT MPC.MonthlyPerformanceCoreID
				,MPC.AccountNumber
				,MPC.SecurityID		 
				,MPC.MonthEnd
				,X.IRR3MReported 
		FROM SMC.vw_XIRR_MonthlyPerformanceCore MPC
			INNER JOIN SMC.MonthlyPerformanceCore X ON x.AccountNumber = MPC.AccountNumber AND x.SecurityID = MPC.SecurityID AND x.MonthEnd = MPC.MonthEnd
		ORDER BY AccountNumber,SecurityID,MonthEnd
--	===========================================================*/

DROP TABLE #mv
DROP TABLE #cf
DROP TABLE #xirr
DROP TABLE #Results
