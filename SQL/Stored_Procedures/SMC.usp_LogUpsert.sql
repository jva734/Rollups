USE [SMC_DB_Performance]
GO
-- =============================================
-- Create basic stored procedure template
-- =============================================

-- Drop stored procedure if it already exists
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_LogUpsert' 
)
   DROP PROCEDURE [SMC].[usp_LogUpsert]
GO

--/*
CREATE PROCEDURE [SMC].[usp_LogUpsert] (
	@BatchID int
    ,@TaskName varchar(250)
    ,@StoredProcedureName varchar(50)
    ,@StartedTask datetime
    ,@EndedTask datetime
    ,@ElapsedTime varchar(10)
    ,@Comments varchar(500)
	,@MonthlyPerformanceLogID INT output
)
AS
--*/

--
/*DEBUG

DECLARE @TaskName varchar(250)
        ,@StoredProcedureName varchar(50)
        ,@StartedTask datetime
        ,@EndedTask datetime
        ,@ElapsedTime varchar(10)
        ,@Comments varchar(500)
		,@BatchID INT
		,@MonthlyPerformanceLogID INT

SET @TaskName = 'Get Row Count for PI.vw_Transactions '
SET @StoredProcedureName = 'SQL'
SET @StartedTask = GETDATE();
SET @Comments = 'Row Count for PI.vw_Transactions: ' 
SET @BatchID = 200
SET @MonthlyPerformanceLogID = 0
--*/

	IF NOT EXISTS (SELECT * FROM [SMC].[MonthlyPerformanceLog] WHERE MonthlyPerformanceLogID = @MonthlyPerformanceLogID)
		BEGIN
			--PRINT 'NEW ROW'
			INSERT INTO [SMC].[MonthlyPerformanceLog]
					   ([BatchID]
					   ,[TaskName]
					   ,[StoredProcedureName]
					   ,[StartedTask]
					   ,[Comments])
				 VALUES
					  (
		   				@BatchID 
						,@TaskName
						,@StoredProcedureName
						,@StartedTask 
						,@Comments 
						)
			SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
			SELECT @MonthlyPerformanceLogID = SCOPE_IDENTITY() 
		END
	ELSE
		BEGIN
			--PRINT 'UPDATE ROW'
			UPDATE [SMC].[MonthlyPerformanceLog]
				   SET [EndedTask] = @EndedTask 
					   ,[ElapsedTime] = @ElapsedTime
					   ,[Comments] = @Comments 
			WHERE MonthlyPerformanceLogID  = @MonthlyPerformanceLogID 
			SET @MonthlyPerformanceLogID = 0
		END

GO


