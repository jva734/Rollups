/*
===========================================================================================================================================
	Filename		SMC_usp_IRCalculation
	Author			John Alton
	Date			2/2015
	Description		Calculate the TwrEmdIr values for Transactions that are > 10% of the BAMV
					UPDATE SMC.MonthlyPerformanceCore SET [TwrEmdIr]	= @CumulativeTWR

	exec SMC.usp_IRCalculationV2

	select 162936.50 + -38750.00 --124186.50
	select 187524.10 + -38750.00 --148774.10


===========================================================================================================================================
*/

USE [SMC_DB_Performance]
GO

/*  =============================================================================================
    NOTE - This code does not filter on Transactions marked as IR but processes all transactions based on their individual transaction date and wgt
	This is a re-write of previous code and removes the while loop to improve performance
		
*/

--/*
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_WgtedTwr' 
)
   DROP PROCEDURE SMC.usp_WgtedTwr
GO

CREATE PROCEDURE SMC.usp_WgtedTwr
AS
--*/

/*
-- NEED TO LOAD THIS DATA
--EXEC [SMC].[usp_LoadTransactionMeta]
DECLARE @AccountNumber VARCHAR(30),@SecurityID VARCHAR(30), @MonthStart date, @BM date, @EM date
SET @AccountNumber = 'LSJF35020002';SET @SecurityID = '13610'; SET @MonthStart = '2004-04-01'
SET @AccountNumber = 'LSJF30000002';SET @SecurityID = '13268'; SET @MonthStart = '2001-12-01'
SET @BM = [SMC_DB_Reference].[SMC].[ufn_BOMONTH](@MonthStart) 
SET @EM = EOMONTH(@MonthStart)
--*/

;WITH CTE_Transactions_First AS (
-- Get the First Transaction Row of the Month so we can create a opening Sub Period
  SELECT AccountNumber 
		,SecurityID
		,MonthStart
		,MonthEnd
		,0 AS TransactionAmt
		,TransactionDate
		,BAMV
		,EAMV
		,Row_Number() OVER (PARTITION BY AccountNumber,SecurityID,MonthStart ORDER BY TransactionDate) AS RowNumber
	FROM [SMC_DB_Performance].[SMC].[TransactionMeta]
	WHERE RowType = 'R'
	--AccountNumber = @AccountNumber AND SecurityID = @SecurityID AND MonthStart = @MonthStart
	--GROUP BY AccountNumber,SecurityID,MonthStart
)
--select * from CTE_Transactions_First
,CTE_TransactionByDate AS (
-- Group all the Transaction on the Same Date to be treated as one
  SELECT AccountNumber 
		,SecurityID
		,MonthStart
		,MIN(MonthEnd) MonthEnd
		,SUM(TransactionAmt) TransactionAmt
		,MIN(TransactionDate)  TransactionDate
		,MIN(BAMV) BAMV
		,MIN(EAMV) EAMV
		,COUNT(*) AS Row_Count
	FROM [SMC_DB_Performance].[SMC].[TransactionMeta]
	WHERE RowType = 'R'
	-- AccountNumber = @AccountNumber AND SecurityID = @SecurityID AND MonthStart = @MonthStart
	GROUP BY AccountNumber,SecurityID,MonthStart,TransactionDate 
)
--SELECT * FROM CTE_TransactionByDate 
,CTE_Rows AS (
 SELECT AccountNumber 
		,SecurityID
		,MonthStart
		,MonthEnd
		,0 AS TransactionAmt
		,TransactionDate
		,BAMV
		,EAMV
	FROM CTE_Transactions_First 
	WHERE RowNumber = 1
UNION ALL
 SELECT AccountNumber 
		,SecurityID
		,MonthStart
		,MonthEnd
		,TransactionAmt
		,TransactionDate
		,BAMV
		,EAMV
	FROM CTE_TransactionByDate 
)
--SELECT * FROM CTE_Rows 
,CTE_TransactionData AS (
	SELECT AccountNumber 
		,SecurityID
		,MonthStart
		,MonthEnd
		,TransactionAmt
		,TransactionDate 
		,BAMV
		,EAMV
		,COUNT(*) OVER (PARTITION BY AccountNumber,SecurityID,MonthStart ORDER BY MonthStart) AS MonthTransactionRowCount  
		,COUNT(*) OVER (PARTITION BY AccountNumber,SecurityID,MonthStart ORDER BY MonthStart ROWS UNBOUNDED PRECEDING) AS RowNumber
	FROM CTE_Rows 
)
--SELECT * FROM CTE_TransactionData 
,CTE_CalcVal1 AS (
	SELECT * 
			,CASE 
				WHEN RowNumber = 1
					THEN MonthStart
				WHEN RowNumber > 1
					THEN TransactionDate
				END StartOfSubPeriod

			,CASE 
				WHEN RowNumber < MonthTransactionRowCount
					THEN DATEADD(d,-1, LEAD(TransactionDate,1) OVER (PARTITION BY AccountNumber,SecurityID,MonthStart ORDER BY MonthStart) )
				WHEN RowNumber = MonthTransactionRowCount					 
					THEN MonthEnd
				END EndOfSubPeriod
			
			--BAMV
			,CASE
				WHEN RowNumber = 1 THEN BAMV
				--WHEN RowNumber > 1 
				--	THEN LAG(cEAMV,1) OVER (PARTITION BY AccountNumber,SecurityID,MonthStart ORDER BY MonthStart) 
			END cBAMV
			
			--EAMV
			,CASE
			 	WHEN RowNumber = 1
					THEN BAMV 
			 	--WHEN RowNumber = 2
					--THEN BAMV + TransactionAmt
				--WHEN RowNumber > 1
				--	THEN LAG(EAMV,1) OVER (PARTITION BY AccountNumber,SecurityID,MonthStart ORDER BY MonthStart) + TransactionAmt
				END cEAMV

	FROM CTE_TransactionData 
)
--SELECT * FROM CTE_CalcVal1 order by AccountNumber,SecurityID,MonthStart
,CTE_CalcVal1A AS (
		SELECT * 
			--BAMV
			,CASE
				WHEN RowNumber = 1 THEN cBAMV
				WHEN RowNumber > 1 THEN LAG(cEAMV,1) OVER (PARTITION BY AccountNumber,SecurityID,MonthStart ORDER BY MonthStart) 
			END cBAMV2
			
			--EAMV
			,CASE
			 	WHEN RowNumber = 1 THEN cEAMV 
				WHEN RowNumber > 1 THEN LAG(cBAMV,1) OVER (PARTITION BY AccountNumber,SecurityID,MonthStart ORDER BY MonthStart) + TransactionAmt
			END cEAMV2
	FROM CTE_CalcVal1 
)
--SELECT * FROM CTE_CalcVal1A order by AccountNumber,SecurityID,MonthStart
,CTE_CalcVal2 AS (
	SELECT *
			,CAST(DAY(EndOfSubPeriod) AS NUMERIC(18,4)) - CAST(DAY(StartOfSubPeriod) AS NUMERIC(18,4))  + 1 AS DaysInSubPeriod
			,CAST(DAY(EOMONTH(TransactionDate))  AS NUMERIC(18,4)) AS DIM
			,((CAST(DAY(EndOfSubPeriod) AS NUMERIC(18,4)) - CAST(DAY(StartOfSubPeriod) AS NUMERIC(18,4))) + 1) / (CAST(DAY(EOMONTH(TransactionDate)) AS NUMERIC(18,4)) ) AS [Weight]

			--,((CAST(DAY(EndOfSubPeriod) AS NUMERIC(18,4)) - CAST(DAY(StartOfSubPeriod) AS NUMERIC(18,4))) + 1) AS NUMERATOR
			--,(CAST(DAY(EOMONTH(TransactionDate)) AS NUMERIC(18,4)) ) AS DENOMINATOR
	FROM CTE_CalcVal1A
)
--SELECT * FROM CTE_CalcVal2 order by AccountNumber,SecurityID,MonthStart
,CTE_CalcVal3 AS (
	SELECT * 
		,CAST((TransactionAmt * DaysInSubPeriod) / DIM AS NUMERIC(18,4)) AS WeightedAmount 
	FROM CTE_CalcVal2  
)
--SELECT * FROM CTE_CalcVal3 order by AccountNumber,SecurityID,MonthStart
,CTE_CalcVal4 AS (
	SELECT * 
			,cBAMV2 + WeightedAmount AS ACB
			,cEAMV2 - cBAMV2 - TransactionAmt AS Profit
	FROM CTE_CalcVal3  
)
--SELECT * FROM CTE_CalcVal4 order by AccountNumber,SecurityID,MonthStart
,CTE_CalcVal5 AS (
			SELECT * 

				,CASE 
					WHEN ACB > 0 
						THEN Profit/ACB 
					ELSE 0	
				END TWR
			FROM CTE_CalcVal4
)
--SELECT * FROM CTE_CalcVal5  order by AccountNumber,SecurityID,MonthStart

,CTE_CalcVal6 AS (
	SELECT AccountNumber 
		,SecurityID
		,MonthStart
		,EXP(SUM(IIF(ABS([TWR]+1)=0,0,LOG(ABS([TWR]+1))))) * IIF(MIN(ABS([TWR]+1))=0,0,1) * (1-2*(SUM(IIF([TWR]+1>=0,0,1)) % 2)) - 1 TWRCumulative
	FROM CTE_CalcVal5  
	GROUP by AccountNumber,SecurityID,MonthStart
)
--SELECT * FROM CTE_CalcVal6  order by AccountNumber,SecurityID,MonthStart

/*
SELECT MPC.AccountNumber,MPC.SecurityID,MPC.MonthStart,A.TWRCumulative
,A.AccountNumber 
,A.SecurityID
,A.MonthStart 
FROM SMC.MonthlyPerformanceCoreJVA MPC
	JOIN CTE_CalcVal6 A 
	ON  MPC.AccountNumber	= A.AccountNumber 
	AND MPC.SecurityID		= A.SecurityID
	AND MPC.MonthStart		= A.MonthStart 
order by MPC.AccountNumber,MPC.SecurityID,MPC.MonthStart
--*/

UPDATE MPC
	SET  TwrEmdIr	= A.TWRCumulative
FROM SMC.MonthlyPerformanceCore MPC
	JOIN CTE_CalcVal6 A 
	ON  MPC.AccountNumber	= A.AccountNumber 
	AND MPC.SecurityID		= A.SecurityID
	AND MPC.MonthStart		= A.MonthStart 
