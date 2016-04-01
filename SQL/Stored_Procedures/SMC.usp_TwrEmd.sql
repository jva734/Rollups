/*
===========================================================================================================================================
	Filename		SMC.usp_TwrEmd
	Author			John Alton
	Date			7/ 2015
	Description		Calculate the TWR_EMD for the First Month 
					For Accounts that have a Closed date Calculate the TWR_EMD for the Last Month 
===========================================================================================================================================
*/
USE [SMC_DB_Performance]
GO

/*
		NOTE
		This code needs to be reviewed especialy the cross apply procedure whhich have a while loop this needs to be re-written
		see usp_WgtedTwr as an example
*/
-- =============================================
-- Create basic stored procedure template
-- =============================================
--/*
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_TwrEmd' 
)
   DROP PROCEDURE SMC.usp_TwrEmd
GO

CREATE PROCEDURE SMC.usp_TwrEmd
AS
--*/

-- Calculate the TWREMD for the First month
DECLARE @CTE_First TABLE (AccountNumber varchar(50), SecurityID varchar(25),TransactionDate date)
DECLARE @CTE_MONTH TABLE (AccountNumber varchar(50), SecurityID varchar(25),TransactionDate date, MonthStart date, [MonthEnd] DATE )
DECLARE @CTE_RowCount TABLE (AccountNumber varchar(50), SecurityID varchar(25),MonthStart date, [MonthEnd] DATE,[Rows] int )

INSERT INTO @CTE_First 
	SELECT	[AccountNumber]
			,SecurityID
			,MIN(TransactionDate) as TransactionDate
	FROM	[SMC_DB_Performance].[SMC].[Transactions] 
	GROUP BY [AccountNumber],SecurityID

INSERT INTO @CTE_MONTH 
	SELECT *
	,[SMC_DB_Reference].[SMC].[ufn_BOMONTH](TransactionDate) AS MonthStart
	,EOMONTH(TransactionDate) as MonthEnd
	FROM @CTE_First 
--SELECT * FROM @CTE_MONTH 

INSERT INTO @CTE_RowCount 
	SELECT   A.[AccountNumber]
			,A.SecurityID		
			,MonthStart
			,MonthEnd
			,COUNT(*) AS [Rows]
	FROM @CTE_MONTH A
		,[SMC_DB_Performance].[SMC].[Transactions] T 
	WHERE T.[AccountNumber] = A.[AccountNumber] AND T.SecurityID = A.SecurityID AND T.TransactionDate >= A.MonthStart AND T.TransactionDate <= A.MonthEnd 
	GROUP BY A.[AccountNumber],A.SecurityID,MonthStart,MonthEnd
--SELECT * FROM @CTE_RowCount 

/* Process Accounts where there is only 1 Transaction in the first Month*/
;WITH CTE_RESULTS_1 AS (
	SELECT A.*,TWR_EMD.*
	FROM @CTE_RowCount AS A
	CROSS APPLY  SMC.ufn_TWREMD_SingleTranOpen(AccountNumber,SecurityID,MonthEnd) AS TWR_EMD
	WHERE A.[Rows] = 1
)
MERGE INTO [SMC].[MonthlyPerformanceCore] MP 
    USING (
		   SELECT     *
		   	FROM      CTE_RESULTS_1
         ) TWREMD_1
      ON MP.[AccountNumber] = TWREMD_1.[AccountNumber]
	 AND MP.SecurityID	= TWREMD_1.SecurityID	 
	 AND  MP.MonthEnd = TWREMD_1.MonthEnd
WHEN MATCHED THEN
   UPDATE 
   SET TWREMDIR  = TWREMD_1.TWREMD
   ,TWR_PMDEMD= TWREMD_1.TWREMD;


/* Process Accounts where there is MORE than 1 Transactions in the first Month*/
;WITH CTE_RESULTS_2 AS (
	SELECT A.*,TWR_EMD.*
	FROM @CTE_RowCount AS A
	CROSS APPLY  SMC.ufn_TWREMD_MultiTranOpen(AccountNumber,SecurityID,MonthEnd) AS TWR_EMD
	WHERE A.[Rows] > 1
)
MERGE INTO [SMC].[MonthlyPerformanceCore] MP 
    USING (
		   SELECT     *
		   	FROM      CTE_RESULTS_2
         ) TWREMD_2
      ON MP.[AccountNumber] = TWREMD_2.[AccountNumber]
	 AND MP.SecurityID	= TWREMD_2.SecurityID	 
	 AND  MP.MonthEnd = TWREMD_2.MonthEnd
WHEN MATCHED THEN
   UPDATE 
   SET TWREMDIR  = TWREMD_2.TWREMD
   ,TWR_PMDEMD= TWREMD_2.TWREMD;


-- Calculate the TWREMD for the Last month
DECLARE @CTE_Closed TABLE (AccountNumber varchar(50), SecurityID varchar(25),AccountClosed date)
DECLARE @CTE_LastMonth TABLE (AccountNumber varchar(50), SecurityID varchar(25),AccountClosed DATE , MonthStart date, [MonthEnd] date)
DECLARE @CTE_ClosedRowCount TABLE (AccountNumber varchar(50), SecurityID varchar(25),MonthStart date, [MonthEnd] DATE,[Rows] int )

-- Get the Accounts that have a Closed Date
INSERT INTO @CTE_Closed 
SELECT   AccountNumber
		,SecurityID
		,MAX(AccountClosed) AS AccountClosed		
FROM [SMC].[MonthlyPerformanceCore] 
WHERE AccountClosed IS NOT NULL
GROUP BY [AccountNumber],SecurityID

-- Get the Start and Close of that closing month
INSERT INTO @CTE_LastMonth 
	SELECT AccountNumber
			,SecurityID
			,AccountClosed		
			,[SMC_DB_Reference].[SMC].[ufn_BOMONTH](AccountClosed) AS MonthStart
			,EOMONTH(AccountClosed) as MonthEnd
	FROM @CTE_Closed 

--SELECT * FROM @CTE_LastMonth 

-- Get the Row Count for the closing month
INSERT INTO @CTE_ClosedRowCount 
	SELECT   A.[AccountNumber]
			,A.SecurityID		
			,MonthStart
			,MonthEnd
			,COUNT(*) AS [Rows]
	FROM @CTE_LastMonth A
		,[SMC_DB_Performance].[SMC].[Transactions] T 
	WHERE T.[AccountNumber] = A.[AccountNumber] AND T.SecurityID = A.SecurityID AND T.TransactionDate >= A.MonthStart AND T.TransactionDate <= A.MonthEnd 
	GROUP BY A.[AccountNumber],A.SecurityID,MonthStart,MonthEnd

--SELECT * FROM @CTE_ClosedRowCount
 /* Process Accounts where there is only 1 Transaction in the first Month*/
;WITH CTE_RESULTS_Closed_1 AS (
	SELECT A.*,TWR_EMD.*
	FROM @CTE_ClosedRowCount AS A
	CROSS APPLY  SMC.ufn_TWREMD_SingleTranClose(AccountNumber,SecurityID,MonthEnd) AS TWR_EMD
	WHERE A.[Rows] = 1
)
--SELECT * FROM CTE_RESULTS_Closed_1 
MERGE INTO [SMC].[MonthlyPerformanceCore] MP 
    USING (
		   SELECT     *
		   	FROM      CTE_RESULTS_Closed_1
         ) TWREMD_Closed_1
      ON MP.[AccountNumber] = TWREMD_Closed_1.[AccountNumber]
	 AND MP.SecurityID	= TWREMD_Closed_1.SecurityID	 
	 AND  MP.MonthEnd = TWREMD_Closed_1.MonthEnd
WHEN MATCHED THEN
   UPDATE 
   SET TWREMDIR  = TWREMD_Closed_1.TWREMD
   ,TWR_PMDEMD= TWREMD_Closed_1.TWREMD;

/* Process Accounts where there is MORE than 1 Transactions in the first Month*/
;WITH CTE_RESULTS_Closed_2 AS (
	SELECT A.*,TWR_EMD.*
	FROM @CTE_ClosedRowCount AS A
	CROSS APPLY  SMC.ufn_TWREMD_MultiTranClose(AccountNumber,SecurityID,MonthEnd) AS TWR_EMD
	WHERE A.[Rows] > 1
)
MERGE INTO [SMC].[MonthlyPerformanceCore] MP 
    USING (
		   SELECT     *
		   	FROM      CTE_RESULTS_Closed_2
         ) TWREMD_Closed_2
      ON MP.[AccountNumber] = TWREMD_Closed_2.[AccountNumber]
	 AND MP.SecurityID	= TWREMD_Closed_2.SecurityID	 
	 AND  MP.MonthEnd = TWREMD_Closed_2.MonthEnd
WHEN MATCHED THEN
   UPDATE 
   SET TWREMDIR  = TWREMD_Closed_2.TWREMD
   ,TWR_PMDEMD= TWREMD_Closed_2.TWREMD;
   
