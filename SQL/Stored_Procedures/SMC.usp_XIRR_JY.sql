/*
===========================================================================================================================================
	Filename		SMC.usp_XIRR_JY
	Author			John Alton
	Date			11/2015
	Description		Calculate the XIRR for all year to date (JY)

	EXEC SMC.usp_XIRR_YTD
===========================================================================================================================================
*/

USE SMC_DB_Performance
GO

--/*
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_XIRR_JY' 
)
   DROP PROCEDURE SMC.usp_XIRR_JY
GO

CREATE PROCEDURE SMC.usp_XIRR_JY
AS
--*/

/*
	TEST VARIABLES
*/
DECLARE	@AccountNumber varchar(25),@SecurityID varchar(25),@MonthStart date,@MonthEnd date
SET @AccountNumber = 'LSJF30020002'; SET @SecurityID = '999F81109'
SET @MonthStart    = '2011-07-01';   SET @MonthEnd   = '2011-07-31'

--LSJF30020002	999F81109	2011-01-01	2011-07-31	1	-0.0354314039693421
--LSJFVIAIII	1205	2001-01-01	2001-07-31	1	0.0477620466201323

DECLARE @time_start AS DATETIME
DECLARE @time_end AS DATETIME
DECLARE @Debug TABLE(BigString VARCHAR(max),[ElapsedTime] FLOAT  )
DECLARE @BigString varchar(MAX)
--INSERT INTO @Debug (BigString ) values ('Test Comment')


DECLARE	 @DebugData bit
		,@DebugDataMV bit
		,@DebugDataCF bit
		,@DebugDataCF_SQL bit
		,@DebugDataXIRR bit
		,@DebugDataXIRR_SQL bit
		,@DebugDataResult bit
		,@DebugDataResult_ByAcct bit
		,@DebugDataResult_NN bit
		,@DebugElapsedTime bit

-- Default turn all debugging off 
SET @DebugData = 0
SET @DebugDataMV = @DebugData 
SET @DebugDataCF  = @DebugData 
SET @DebugDataCF_SQL = @DebugData 
SET @DebugDataXIRR  = @DebugData 
SET @DebugDataXIRR_SQL = @DebugData 
SET @DebugDataResult_ByAcct  = @DebugData
SET @DebugDataResult_NN = @DebugData
SET @DebugDataResult  = @DebugData 
SET @DebugElapsedTime = @DebugData 

-- Custom set
--SET @DebugDataMV = 1
--SET @DebugDataCF  = 1
--SET @DebugDataCF_SQL = 1
--SET @DebugDataXIRR  = 1
--SET @DebugDataXIRR_SQL = 1
--SET @DebugDataResult_ByAcct  = 1
--SET @DebugDataResult_NN = 1
--SET @DebugDataResult  = 1
--SET @DebugElapsedTime = 1

/*=============================================================
	First Drop the temp tables if they exist
=============================================================*/
IF OBJECT_ID('tempdb..#mv') IS NOT NULL
BEGIN
    DROP TABLE #mv
END
IF OBJECT_ID('tempdb..#cf') IS NOT NULL
BEGIN
    DROP TABLE #cf
END
IF OBJECT_ID('tempdb..#xirr') IS NOT NULL
BEGIN
    DROP TABLE #xirr
END
IF OBJECT_ID('tempdb..#Results') IS NOT NULL
BEGIN
    DROP TABLE #Results
END

/*=============================================================
	Create the Temp Tables
=============================================================*/
/*This will hold all the EAMV values*/
CREATE TABLE #mv (
 AccountNumber varchar(25)
,SecurityID varchar(25)
,MonthStart date
,MonthEnd date
,StartOfYear date
,eamv float
,EAMVLag1Mo float
,GroupValue int
)

/*This will hold all the transactions*/
CREATE TABLE #CF (
 AccountNumber varchar(25)
,SecurityID varchar(25)
,MonthStart date
,MonthEnd date
,StartOfYear date
,TranDate date
,TranAmt float
,GroupValue int
)
/*This will hold all the data to pass to the XIRR function*/
CREATE TABLE #xirr (
 AccountNumber varchar(25)
,SecurityID varchar(25)
,MonthStart date
,StartOfYear date
,dt date
,Amount float
,RowType varchar(1)
,GroupValue int
)
/*This will hold all the data containing the results*/
CREATE TABLE #Results (
 AccountNumber varchar(25)
,SecurityID varchar(25)
,StartOfYear date
,MonthEnd date
,GroupValue INT
,XIRR float
)


/*================================================================
	VARIABLES
================================================================*/
DECLARE @SQLCmd NVARCHAR(MAX)
		,@GroupValue int

SET @GroupValue = 1;


/*================================================================
	Loop for each month
================================================================*/

WHILE @GroupValue <= 12
BEGIN
SET @time_start = GETDATE() 
/*
Get the MArket Value data for each month with last months EAMV
*/
INSERT INTO #mv
SELECT 	 AccountNumber
		,SecurityID		 
		,MonthStart
		,MonthEnd 
		,StartOfYear
		,EAMV
		,EAMVLag1Mo
		,JY_GroupValue
FROM SMC.vw_XIRR_MonthlyPerformanceCoreYTD A
WHERE JY_GroupValue = @GroupValue
ORDER BY  A.AccountNumber,A.SecurityID,A.MonthEnd

/* ======================================= DEBUG ============================= */
IF @DebugDataMV = 1
BEGIN
	select * from #mv
	where AccountNumber = @AccountNumber  and SecurityID = @SecurityID 
	order BY AccountNumber ,SecurityID, MonthEnd
END
/* ======================================= DEBUG ============================= */

SET @SQLCmd = 'INSERT INTO #cf SELECT A.AccountNumber,A.SecurityID,A.MonthStart,A.MonthEnd,A.StartOfYear,TransactionDate,TransactionAmt,A.JY_Group'
SET @SQLCmd = @SQLCmd + CAST(@GroupValue AS VARCHAR(2) );
SET @SQLCmd = @SQLCmd + ' FROM SMC.vw_XIRR_Transactions A JOIN #MV B ON  B.AccountNumber = A.AccountNumber AND B.SecurityID = A.SecurityID AND B.MonthEnd = A.MonthEnd ORDER BY A.AccountNumber,A.SecurityID,A.MonthEnd'

IF @DebugDataCF_SQL = 1
	INSERT INTO @Debug (BigString,[ElapsedTime] ) values (@SQLCmd,NULL)

EXECUTE sp_executesql @SQLCmd

/* ======================================= DEBUG ============================= */
IF @DebugDataCF = 1
	BEGIN
		select * from #cf
		where AccountNumber = @AccountNumber  and SecurityID = @SecurityID 
		order BY AccountNumber ,SecurityID, TranDate
	END
/* ======================================= DEBUG ============================= */


INSERT INTO #xirr
SELECT AccountNumber 
	,SecurityID 
	,MonthStart
	,StartOfYear 
	,StartOfYear 
	,EAMVLag1Mo 
	,'A'
	,GroupValue 
FROM #mv

INSERT INTO #xirr
	SELECT AccountNumber 
		,SecurityID 
		,MonthEnd 
		,StartOfYear 
		,MonthEnd 
		,EAMV 
		,'Z'
		,GroupValue
FROM #mv
--select * from #xirr order BY AccountNumber ,SecurityID, dt

INSERT INTO #xirr
SELECT 
	AccountNumber 
	,SecurityID 
	,MonthStart
	,StartOfYear 
	,TranDate
	,TranAmt 
	,'T'
	,GroupValue
FROM #cf

/* ======================================= DEBUG ============================= */
IF @DebugDataXIRR = 1
	BEGIN
		select * from #xirr
		where AccountNumber = @AccountNumber  and SecurityID = @SecurityID 
		order BY AccountNumber ,SecurityID,MonthStart,RowType
	END
IF @DebugDataXIRR_SQL = 1
BEGIN
	select '(' + '''' + 'EAMV' + '''' + ',' + CAST(ISNULL(Amount,0) AS VARCHAR(20)) + ',' + '''' + CAST(dt AS VARCHAR(20)) + '''' + ',NULL)' as [IN]
	from #xirr
	WHERE AccountNumber = @AccountNumber  AND  SecurityID = @SecurityID AND MonthStart  = @MonthStart AND RowType= 'A'
	UNION ALL
	select ',(' + '''' + 'TRAN' + '''' + ',' + CAST(Amount AS VARCHAR(20)) + ',' + '''' + CAST(dt AS VARCHAR(20)) + '''' + ',NULL)'  as [IN]
	from #xirr
	WHERE AccountNumber = @AccountNumber  AND  SecurityID = @SecurityID AND MonthStart  = @MonthStart AND RowType= 'T'
	--order BY AccountNumber ,SecurityID, dt
	UNION ALL
	select ',(' + '''' + 'EAMV' + '''' + ',' + CAST(ISNULL(Amount,0) AS VARCHAR(20)) + ',' + '''' + CAST(dt AS VARCHAR(20)) + '''' + ',NULL)'  as [IN]
	from #xirr
	WHERE AccountNumber = @AccountNumber  AND  SecurityID = @SecurityID AND MonthStart  = @MonthEnd
	AND RowType= 'Z'
END
/* ======================================= DEBUG ============================= */

INSERT INTO #Results 
SELECT	AccountNumber
		,SecurityID
		,StartOfYear
		,MAX(dt) as MonthEnd
		,GroupValue
		,[SMC_DB_Reference].wct.XIRR(Amount,dt, null) AS XIRR 
FROM	#xirr 
GROUP BY AccountNumber ,SecurityID, StartOfYear, GroupValue

-- Increment the loop by 1 (to get the next month)
SET @GroupValue = @GroupValue + 1

-- Clear out the data tables
DELETE FROM #mv
DELETE FROM #cf
DELETE FROM #xirr

SET @time_end = GETDATE()

IF @DebugElapsedTime = 1
	INSERT INTO @Debug (BigString,[ElapsedTime] ) values (cast(@GroupValue as varchar(2)) + ' -1',DATEDIFF(ms,@time_start,@time_end)/1000e+00)

END -- End of While Loop

/*
SELECT * FROM #Results
--*/

/* ===========================================================
	--Test the results in SELECT
	SELECT MonthlyPerformanceCoreID
				,x.AccountNumber 
				,x.SecurityID 
				,x.MonthEnd	
				,x.xirr
		FROM SMC.MonthlyPerformanceCore MPC
			INNER JOIN #Results x ON 
				x.AccountNumber = MPC.AccountNumber 
			AND x.SecurityID = MPC.SecurityID 
			AND x.MonthEnd = MPC.MonthEnd
--*/

UPDATE MPC
	SET MPC.IRRJYReported = x.xirr
FROM SMC.MonthlyPerformanceCore MPC
	INNER JOIN #Results x ON x.AccountNumber = MPC.AccountNumber AND x.SecurityID = MPC.SecurityID AND x.MonthEnd = MPC.MonthEnd

/* ===========================================================
	--Test the UPDATE results 
		SELECT MPC.MonthlyPerformanceCoreID
				,MPC.AccountNumber
				,MPC.SecurityID		 
				,MPC.MonthEnd
				,X.IRRCYReported 
		FROM SMC.vw_XIRR_MonthlyPerformanceCore MPC
			INNER JOIN SMC.MonthlyPerformanceCore X ON x.AccountNumber = MPC.AccountNumber AND x.SecurityID = MPC.SecurityID AND x.MonthEnd = MPC.MonthEnd
		ORDER BY AccountNumber,SecurityID,MonthEnd
--	===========================================================*/



/* ======================================= DEBUG ============================= */
IF @DebugDataResult_ByAcct = 1
	BEGIN
		SELECT * FROM #Results 
		where  AccountNumber = @AccountNumber  and SecurityID = @SecurityID 
		ORDER BY AccountNumber ,SecurityID, StartOfYear
	END
IF @DebugDataResult_NN = 1
BEGIN
	SELECT * FROM #Results 
	where  XIRR is not null and XIRR <> 0
	ORDER BY AccountNumber ,SecurityID, StartOfYear
END
IF @DebugDataResult = 1
BEGIN
	SELECT * FROM #Result 
	ORDER BY AccountNumber ,SecurityID, MonthEnd 
END
/* ======================================= DEBUG ============================= */


-- Finlaly drop the temp tables
DROP TABLE #mv
DROP TABLE #cf
DROP TABLE #xirr
DROP TABLE #Results


IF @DebugDataCF_SQL = 1
BEGIN
	SELECT * FROM @Debug
END
