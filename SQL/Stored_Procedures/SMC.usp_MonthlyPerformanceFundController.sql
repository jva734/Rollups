/*
===========================================================================================================================================
	SP				SMC.usp_MonthlyPerformanceFundController
	Filename		SMC.usp_MonthlyPerformanceFundController
	Author			John Alton
	Date			1/27/2015
	Description		Controls the workflow process to create the table MonthlyPerformanceFund

	exec [SMC_DB_Performance].[SMC].[usp_MonthlyPerformanceFundController]
	select count(*) from [SMC].[MonthlyPerformanceCore]
	select * from [SMC].[MonthlyPerformanceCore]
	SELECT * FROM [SMC_DB_Performance].[SMC].[MonthlyPerformanceLog] WHERE BatchID IN (SELECT MAX(BatchID) FROM [SMC_DB_Performance].SMC.BatchID)

===========================================================================================================================================
Debug Code
DECLARE @Debug TABLE(BigString VARCHAR(max))
INSERT INTO @Debug (BigString ) values ('@AccountNumber=' + @AccountNumber + ' @SecurityID=' + @SecurityID )
SELECT * FROM @Debug
PRINT @@SERVERNAME

BEGIN TRY
   
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber;
	+ ': ERROR'  + ' ' + STR(ERROR_NUMBER())
END CATCH;
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT

==========================================================================================================================================
*/
USE [SMC_DB_Performance]
GO

--/*debug only
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_MonthlyPerformanceFundController' 
)
   DROP PROCEDURE SMC.usp_MonthlyPerformanceFundController
GO

CREATE PROCEDURE SMC.usp_MonthlyPerformanceFundController
AS
--*/

DECLARE @RowCount int

DECLARE @MasterTaskName varchar(250)
        ,@MasterStoredProcedureName varchar(50)
        ,@MasterStartedTask datetime
        ,@MasterEndedTask datetime
        ,@MasterElapsedTime varchar(10)
        ,@MasterComments varchar(500)
		,@BatchID INT;

DECLARE @TaskName varchar(250)
        ,@StoredProcedureName varchar(50)
        ,@StartedTask datetime
        ,@EndedTask datetime
        ,@ElapsedTime varchar(10)
        ,@Comments varchar(500)

DECLARE @DayofWeek varchar(10)	
		,@MonthlyPerformanceLogID INT


/*log the task being executed*/
SET @MonthlyPerformanceLogID  = 0
SET @MasterTaskName = 'SMC Monthly Performance Master Job Start'
SET @MasterStoredProcedureName = 'SMC_usp_MonthlyValuesController'
SET @MasterStartedTask = GETDATE();
SET @MasterComments = 'Executes all the individual tasks to ultimately create the MonthlyPerformance table'
SET @MasterEndedTask = NULL
SET @MasterElapsedTime = ''

/*==========================
	Get the next BatchID
==========================*/
set @BatchID  = 0
BEGIN TRY
	EXEC SMC.usp_InsertBatchID @MasterTaskName, @BatchID OUTPUT
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber;
	SET @MasterComments = @MasterComments + ' : ERROR '  + ' ' + STR(ERROR_NUMBER())
END CATCH;
EXEC SMC.usp_LogUpsert @BatchID,@MasterTaskName,@MasterStoredProcedureName,@MasterStartedTask,@MasterEndedTask,@MasterElapsedTime,@MasterComments, @MonthlyPerformanceLogID OUTPUT
SET @MonthlyPerformanceLogID  = 0

/*==============================================================================================
	Step 1) Truncate tables Clean out the data
==============================================================================================*/
TRUNCATE TABLE [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore]
TRUNCATE TABLE [SMC_DB_Performance].[SMC].[MonthlyPerformanceFund]
TRUNCATE TABLE [SMC_DB_Performance].[SMC].[Transactions]
TRUNCATE TABLE [SMC_DB_Performance].[SMC].[CashFlow]
--TRUNCATE TABLE [SMC_DB_Performance].[SMC].[TransactionMeta]


SELECT @RowCount = COUNT(*) FROM CD.vw_Transactions
--PRINT 'Row Count for CD.vw_Transactions: ' + CAST(@RowCount AS VARCHAR(10))
/*log the task being executed*/
SET @TaskName = 'Get Row Count for CD.vw_Transactions '
SET @StoredProcedureName = 'SQL'
SET @StartedTask = GETDATE();
SET @Comments = 'Row Count for CD.vw_Transactions: ' + CAST(@RowCount AS VARCHAR(10))
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT

SELECT @RowCount = COUNT(*) FROM PI.vw_Transactions
--PRINT 'PI.vw_Transactions ' + CAST(@RowCount AS VARCHAR(10))
SET @MonthlyPerformanceLogID  = 0
SET @TaskName = 'Get Row Count for PI.vw_Transactions '
SET @StoredProcedureName = 'SQL'
SET @StartedTask = GETDATE();
SET @Comments = 'Row Count for PI.vw_Transactions: ' + CAST(@RowCount AS VARCHAR(10))
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT


SELECT @RowCount = COUNT(*) FROM CD.vw_Valuations
--PRINT 'CD.vw_Valuations ' + CAST(@RowCount AS VARCHAR(10))
SET @MonthlyPerformanceLogID  = 0
SET @TaskName = 'Get Row Count for CD.vw_Valuations '
SET @StoredProcedureName = 'SQL'
SET @StartedTask = GETDATE();
SET @Comments = 'Row Count for CD.vw_Valuations: ' + CAST(@RowCount AS VARCHAR(10))
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT

SELECT @RowCount = COUNT(*) FROM PI.vw_Valuations
--PRINT 'PI.vw_Valuations ' + CAST(@RowCount AS VARCHAR(10))
SET @MonthlyPerformanceLogID  = 0
SET @TaskName = 'Get Row Count for PI.vw_Valuations '
SET @StoredProcedureName = 'SQL'
SET @StartedTask = GETDATE();
SET @Comments = 'Row Count for PI.vw_Valuations: ' + CAST(@RowCount AS VARCHAR(10))
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT


/*log the task being executed*/
SET @MonthlyPerformanceLogID  = 0
SET @TaskName = 'LoadTransactionsTable'
SET @StoredProcedureName = 'SMC.LoadTransactionsTable'
SET @StartedTask = GETDATE();
SET @Comments = 'Currently Running....'
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT

EXEC SMC.usp_LoadTransactionsTable

SET @Comments = 'Transfer the Data from the Transactions View into a table'
SET @EndedTask = GETDATE();
select @ElapsedTime = convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )/3600)+':'+convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )%3600/60)+':'+convert(varchar(5),(DateDiff(s, @StartedTask, @EndedTask )%60))
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT

/*==============================================================================================
	Step 2) Create CashFlow using view to sum monthly totals for capital calls and distr for Account.Security,Month
	Populate table to store cash values per account security Month
==============================================================================================*/
/*log the task being executed*/
SET @TaskName = 'LoadCashFlows'
SET @StoredProcedureName = 'SMC.usp_LoadCashFlows'
SET @StartedTask = GETDATE();
SET @Comments = 'Currently Running....'
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT

BEGIN TRY
	EXEC SMC.usp_LoadCashFlows   
	SET @Comments = 'From the Transactions rollup the cash flows for the month'
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber;
	SET @Comments = 'From the Transactions rollup the cash flows for the month'	+ ': ERROR'  + ' ' + STR(ERROR_NUMBER())
END CATCH;
SET @EndedTask = GETDATE();
select @ElapsedTime = convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )/3600)+':'+convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )%3600/60)+':'+convert(varchar(5),(DateDiff(s, @StartedTask, @EndedTask )%60))
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT

/*==============================================================================================
	Step 3) Create Monthly Values for Reported, Adjusted,Orphaned and Pre-Reported 
	From the data we have in the vw_Valuations and vw_Transactions populate [Mellon].[SDFMonthly]
==============================================================================================*/
/*log the task being executed*/
SET @TaskName = 'Load Monthly Performance Core Data'
SET @StoredProcedureName = 'SMC.usp_LoadMonthlyPerformanceCore'
SET @StartedTask = GETDATE();
SET @Comments = 'Currently Running....'
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT

BEGIN TRY
	EXEC SMC.usp_LoadMonthlyPerformanceCore   
	SET @Comments = 'This Process Loads the Reported Market Values, Orphaned Transactions and creates Adjusted Filler rows'	
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber;
	SET @Comments = 'This Process Loads the Reported Market Values, Orphaned Transactions and creates Adjusted Filler rows'	+ ': ERROR'  + ' ' + STR(ERROR_NUMBER())
END CATCH;
SET @EndedTask = GETDATE();
select @ElapsedTime = convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )/3600)+':'+convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )%3600/60)+':'+convert(varchar(5),(DateDiff(s, @StartedTask, @EndedTask )%60))
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT

/*=======================================================================
	6) Update the Account Closed Date for PI and CD data
	Update the AccountClosed Date from the ASA System 
	Update the BAMV,EAMV,MarketValue to NULL and RowType = 'C' for rows after an Account has closed
=====================================================================================================================*/
SET @TaskName = 'Update Closed Accounts'
SET @StoredProcedureName = 'SMC.usp_ClosedAccounts'
SET @StartedTask = GETDATE();
SET @Comments = 'Currently Running....'
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT

BEGIN TRY
	EXEC SMC.usp_ClosedAccounts   
	SET @Comments = 'Update the BAMV,EAMV,MarketValue to NULL and RowType = C for rows after an Account has closed'	
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber;
	SET @Comments = 'Update the BAMV,EAMV,MarketValue to NULL and RowType = C for rows after an Account has closed'	+ ': ERROR'  + ' ' + STR(ERROR_NUMBER())
END CATCH;
SET @EndedTask = GETDATE();
select @ElapsedTime = convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )/3600)+':'+convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )%3600/60)+':'+convert(varchar(5),(DateDiff(s, @StartedTask, @EndedTask )%60))
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT


/*=======================================================================
	POPULATE THE [SMC].QtrEndDate Table
=====================================================================================================================*/
SET @TaskName = 'Populate [SMC].QtrEndDate Table'
SET @StoredProcedureName = 'SMC.usp_LoadQtrEndDates'
SET @StartedTask = GETDATE();
SET @Comments = 'Currently Running....'
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT


BEGIN TRY
	EXEC SMC.usp_LoadQtrEndDates   
	SET @Comments = 'Create Table of Qtr End Date to be used in SSRS Reports Date Selector'	
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber;
	SET @Comments = 'Create Table of Qtr End Date to be used in SSRS Reports Date Selector'	+ ': ERROR'  + ' ' + STR(ERROR_NUMBER())
END CATCH;

SET @EndedTask = GETDATE();
select @ElapsedTime = convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )/3600)+':'+convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )%3600/60)+':'+convert(varchar(5),(DateDiff(s, @StartedTask, @EndedTask )%60))
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT

/*===================================================================================================================
	Process the TransactionMeta table to calculate PMD for ALL Transactions
	We do this LAST because PMD ACB and Profit override anything calculated from IR
=====================================================================================================================*/
/*log the task being executed*/
SET @TaskName = 'usp_TwrPmd'
SET @StoredProcedureName = 'SMC.usp_TwrPmd'
SET @StartedTask = GETDATE();
SET @Comments = 'Currently Running....'
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT


BEGIN TRY
	EXEC SMC.usp_TwrPmd;   
	SET @Comments = 'Calculate the TWR PMD for All Reported values'	
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber;
	SET @Comments = 'Calculate the TWR PMD for All Reported values'	+ ': ERROR'  + ' ' + STR(ERROR_NUMBER())
END CATCH;

SET @EndedTask = GETDATE();
select @ElapsedTime = convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )/3600)+':'+convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )%3600/60)+':'+convert(varchar(5),(DateDiff(s, @StartedTask, @EndedTask )%60))
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT


/*===================================================================================================================
	Calculate the IRR for Adjusted and Reported 1M,3M,1YR,3YR,5YR,7YR,10YR,CY,JY,SI
=====================================================================================================================*/
/*log the task being executed*/
SET @TaskName = 'Calculate the XIRR for Official Qtr Ends'
SET @StoredProcedureName = 'SMC.usp_XIRR_wrapper'
SET @StartedTask = GETDATE();
SET @Comments = 'Currently Running....'
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT

BEGIN TRY
	EXEC SMC.usp_XIRR_wrapper;   
	SET @Comments = 'Calculate the IRR for Reported 1M,3M,1YR,3YR,5YR,7YR,10YR,CY,JY,SI  for Official Qtr Ends'
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber;
	SET @Comments = 'Calculate the IRR for Reported 1M,3M,1YR,3YR,5YR,7YR,10YR,CY,JY,SI  for Official Qtr Ends'	+ ': ERROR'  + ' ' + STR(ERROR_NUMBER())
END CATCH;
SET @EndedTask = GETDATE();
select @ElapsedTime = convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )/3600)+':'+convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )%3600/60)+':'+convert(varchar(5),(DateDiff(s, @StartedTask, @EndedTask )%60))
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT


/*===================================================================================================================
	Process the TransactionMeta table to calculate Multiples
=====================================================================================================================*/
/*log the task being executed*/
SET @TaskName = 'SMC.usp_Multiples'
SET @StoredProcedureName = 'SMC.usp_Multiples'
SET @StartedTask = GETDATE();
SET @Comments = 'Currently Running....'
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT

BEGIN TRY
	EXEC SMC.usp_Multiples;   
	SET @Comments = 'Process the TransactionMeta table to Calculate the Multiples'
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber;
	SET @Comments = 'Process the TransactionMeta table to Calculate the Multiples' + ': ERROR'  + ' ' + STR(ERROR_NUMBER())
END CATCH;
SET @EndedTask = GETDATE();
select @ElapsedTime = convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )/3600)+':'+convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )%3600/60)+':'+convert(varchar(5),(DateDiff(s, @StartedTask, @EndedTask )%60))
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT

/*===================================================================================================================
	Determine the Reported Frequency for PI Funds
=====================================================================================================================*/
/*log the task being executed*/
SET @TaskName = 'SMC.usp_ReportedFrequencyPI'
SET @StoredProcedureName = 'SMC.usp_ReportedFrequencyPI'
SET @StartedTask = GETDATE();
SET @Comments = 'Currently Running....'
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT


BEGIN TRY
   EXEC SMC.usp_ReportedFrequencyPI;
   SET @Comments = 'Determine the Reported Frequency for PI Funds'
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber;
	SET @Comments = 'Determine the Reported Frequency for PI Funds'	+ ': ERROR'  + ' ' + STR(ERROR_NUMBER())
END CATCH;
SET @EndedTask = GETDATE();
select @ElapsedTime = convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )/3600)+':'+convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )%3600/60)+':'+convert(varchar(5),(DateDiff(s, @StartedTask, @EndedTask )%60))
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT

/*===================================================================================================================
	Determine the Reported Frequency for CD Funds
=====================================================================================================================*/
/*log the task being executed*/
SET @TaskName = 'SMC.usp_ReportedFrequencyCD'
SET @StoredProcedureName = 'SMC.usp_ReportedFrequencyCD'
SET @StartedTask = GETDATE();
SET @Comments = 'Currently Running....'
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT


BEGIN TRY
	EXEC SMC.usp_ReportedFrequencyCD 
	SET @Comments = 'Determine the Reported Frequency for CD Funds'	
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber;
	SET @Comments = 'Determine the Reported Frequency for CD Funds'	+ ': ERROR'  + ' ' + STR(ERROR_NUMBER())
END CATCH;
SET @EndedTask = GETDATE();
select @ElapsedTime = convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )/3600)+':'+convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )%3600/60)+':'+convert(varchar(5),(DateDiff(s, @StartedTask, @EndedTask )%60))
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT


/*==============================================================================================
	Load the CND Data to Core
==============================================================================================*/
/*log the task being executed*/
SET @TaskName = 'LoadCNDMonthlyPerformance to Core'
SET @StoredProcedureName = 'usp_LoadCNDMonthlyPerformance'
SET @StartedTask = GETDATE();
SET @Comments = 'Currently Running....'
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT

BEGIN TRY
	EXEC CND.usp_LoadCNDMonthlyPerformance  
	SET @Comments = 'Load CND Monthly Performance'	
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber;
	SET @Comments = 'Load CND Monthly Performance'	+ ': ERROR'  + ' ' + STR(ERROR_NUMBER())
END CATCH;
SET @EndedTask = GETDATE();
select @ElapsedTime = convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )/3600)+':'+convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )%3600/60)+':'+convert(varchar(5),(DateDiff(s, @StartedTask, @EndedTask )%60))
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT

/*==============================================================================================
	Update Fund Contribution
==============================================================================================*/
/*log the task being executed*/
SET @TaskName = 'Update InceptionDate, Contribution'
SET @StoredProcedureName = 'SMC.usp_FundContribution'
SET @StartedTask = GETDATE();
SET @Comments = 'Currently Running....'
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT


BEGIN TRY
	EXEC SMC.usp_FundContribution 
	SET @Comments = 'Update InceptionDate, Contribution SMC.MonthlyPerformanceCore'	
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber;
	SET @Comments = 'Update InceptionDate, Contribution SMC.MonthlyPerformanceCore'	+ ': ERROR'  + ' ' + STR(ERROR_NUMBER())
END CATCH;
SET @EndedTask = GETDATE();
select @ElapsedTime = convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )/3600)+':'+convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )%3600/60)+':'+convert(varchar(5),(DateDiff(s, @StartedTask, @EndedTask )%60))
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT


/*==============================================================================================
	Populate table Monthly Performance Fund
	 this table replace Monthly Performance
==============================================================================================*/
/*log the task being executed*/
SET @TaskName = 'Load Table Monthly Performance Fund'
SET @StoredProcedureName = 'SMC.usp_LoadMonthlyPerformanceFund'
SET @StartedTask = GETDATE();
SET @Comments = 'Currently Running....'
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT


BEGIN TRY
	EXEC SMC.usp_LoadMonthlyPerformanceFund   
	SET @Comments = 'Transfer data from MonthlyPerformanceCore into MonthlyPerformanceFund and calculate remaining values'
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber;
	SET @Comments = 'Transfer data from MonthlyPerformanceCore into MonthlyPerformanceFund and calculate remaining values' 	+ ': ERROR'  + ' ' + STR(ERROR_NUMBER())
END CATCH;

SET @EndedTask = GETDATE();
select @ElapsedTime = convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )/3600)+':'+convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )%3600/60)+':'+convert(varchar(5),(DateDiff(s, @StartedTask, @EndedTask )%60))
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT


/*===================================================================================================================
	Archive Monthly Performance
=====================================================================================================================*/
/*log the task being executed*/
SET @TaskName = 'Archive Monthly Performance'
SET @StoredProcedureName = 'exec SMC.usp_MonthlyPerformanceArchive'
SET @StartedTask = GETDATE();
SET @Comments = 'Currently Running....'
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT

BEGIN TRY
	exec SMC.usp_MonthlyPerformanceArchive   
	SET @Comments = 'Transfer table MonthlyPerformance into MonthlyPerformanceArchive'
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber;
	SET @Comments = 'Transfer table MonthlyPerformance into MonthlyPerformanceArchive' + ': ERROR'  + ' ' + STR(ERROR_NUMBER())
END CATCH;

SET @EndedTask = GETDATE();
select @ElapsedTime = convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )/3600)+':'+convert(varchar(5),DateDiff(s, @StartedTask, @EndedTask )%3600/60)+':'+convert(varchar(5),(DateDiff(s, @StartedTask, @EndedTask )%60))
EXEC SMC.usp_LogUpsert @BatchID,@TaskName,@StoredProcedureName,@StartedTask,@EndedTask,@ElapsedTime,@Comments, @MonthlyPerformanceLogID  OUTPUT

/*==============================================================================================
	Log the total Processing Time
==============================================================================================*/
SET @MonthlyPerformanceLogID  = 0
SET @MasterTaskName = 'SMC Monthly Performance Master Job End'
SET @MasterStoredProcedureName = 'SMC_usp_MonthlyValuesController'
SET @MasterComments = 'Executes all the individual tasks to ultimately create the MonthlyPerformance table'
SET @MasterEndedTask = GETDATE();
select @MasterElapsedTime = convert(varchar(5),DateDiff(s, @MasterStartedTask, @MasterEndedTask  )/3600)+':'+convert(varchar(5),DateDiff(s, @MasterStartedTask, @MasterEndedTask  )%3600/60)+':'+convert(varchar(5),(DateDiff(s, @MasterStartedTask, @MasterEndedTask  )%60))
EXEC SMC.usp_LogUpsert @BatchID,@MasterTaskName,@MasterStoredProcedureName,@MasterStartedTask,@MasterEndedTask,@MasterElapsedTime,@MasterComments, @MonthlyPerformanceLogID  OUTPUT

