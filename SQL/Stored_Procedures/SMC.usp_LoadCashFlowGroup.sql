-- =============================================
-- Author:		Daniel Pan
-- Create date: 02/26/2015
-- Description:	Populate CashFlowGroup table
-- 
-- EXEC [SMC].[usp_LoadCashFlowGroup]
-- 00:00:23
-- =============================================
-- =============================================
-- Create basic stored procedure template
-- =============================================
USE SMC_DB_Performance
GO


-- Drop stored procedure if it already exists
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_LoadCashFlowGroup' 
)
   DROP PROCEDURE SMC.usp_LoadCashFlowGroup
GO

CREATE PROCEDURE [SMC].[usp_LoadCashFlowGroup]
AS

BEGIN

	-- reading GroupControl Table and looping through to calculate Group performance columns
	DECLARE @sqlIRR VARCHAR(MAX)

	-- Get the number of rows in the looping table
	DECLARE @RowIDCurr INT, @RowIDMax INT
	SELECT @RowIDCurr = MIN(RowID), @RowIDMax = MAX(RowID) FROM [SMC].[GroupControl]


	-- Declare variables to hold the data which we get after looping each record 
	DECLARE @GroupColumn VARCHAR(50), @GroupDesc VARCHAR(50)

	-- Truncate group cashflow table
	TRUNCATE TABLE [SMC].[CashFlowGroup]

	-- Loop through the rows of a table and insert group calculation to group performance table
	WHILE (@RowIDCurr <= @RowIDMax)
	BEGIN
		-- Get the data from table and set to variables
		SELECT TOP 1 @GroupColumn = GroupColumn, @GroupDesc = GroupDesc FROM [SMC].[GroupControl] WHERE RowID >= @RowIDCurr ORDER BY RowID

		SET @sqlIRR = '		
			-- Build CashFlow
			INSERT INTO SMC.CashFlowGroup ([GroupName],[GroupDesc],[CFType],[CFDate],[CFAmt])
			-- Get BAMV for Group
			SELECT ISNULL(RTRIM(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',',')),''NULL'') + '' - '' + ISNULL(RTRIM(CONVERT(VARCHAR,') + ')),''NULL'') GroupName, ''' + @GroupDesc + ''' GroupDesc, ''BAMV'' CFType, MonthEnd CFDate, SUM(BAMarketValuePMD) CFAmt
			FROM [SMC].[vw_FactMonthlyPerformance]
			WHERE ISNULL(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',','),'''') NOT IN ('''',''NA'',''0'') AND ISNULL(CONVERT(VARCHAR,') + '),'''') NOT IN ('''',''NA'',''0'')
				AND DataSource <> ''CND''
			GROUP BY MonthEnd, ISNULL(RTRIM(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',',')),''NULL'') + '' - '' + ISNULL(RTRIM(CONVERT(VARCHAR,') + ')),''NULL'')
			UNION ALL
			-- Get Transaction for Group
			SELECT ISNULL(RTRIM(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',',')),''NULL'') + '' - '' + ISNULL(RTRIM(CONVERT(VARCHAR,') + ')),''NULL'') GroupName, ''' + @GroupDesc + ''' GroupDesc, ''Transaction'' CFType, TransactionDate CFDate, SUM(TransactionAmt) CFAmt
			FROM [SMC].[vw_FactTransactionMeta]
			WHERE ISNULL(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',','),'''') NOT IN ('''',''NA'',''0'') AND ISNULL(CONVERT(VARCHAR,') + '),'''') NOT IN ('''',''NA'',''0'')
				AND DataSource <> ''CND''
			GROUP BY TransactionDate, ISNULL(RTRIM(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',',')),''NULL'') + '' - '' + ISNULL(RTRIM(CONVERT(VARCHAR,') + ')),''NULL'')
			UNION ALL
			-- Get EAMV for Group
			SELECT ISNULL(RTRIM(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',',')),''NULL'') + '' - '' + ISNULL(RTRIM(CONVERT(VARCHAR,') + ')),''NULL'') GroupName, ''' + @GroupDesc + ''' GroupDesc, ''EAMV'' CFType, MonthEnd CFDate, SUM(EAMarketValuePMD) CFAmt
			FROM [SMC].[vw_FactMonthlyPerformance]
			WHERE ISNULL(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',','),'''') NOT IN ('''',''NA'',''0'') AND ISNULL(CONVERT(VARCHAR,') + '),'''') NOT IN ('''',''NA'',''0'')
				AND DataSource <> ''CND''
			GROUP BY MonthEnd, ISNULL(RTRIM(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',',')),''NULL'') + '' - '' + ISNULL(RTRIM(CONVERT(VARCHAR,') + ')),''NULL'')
			'

		PRINT (@sqlIRR)
		EXEC (@sqlIRR)

		-- Increment the iterator
		SET @RowIDCurr = @RowIDCurr + 1
	END

END