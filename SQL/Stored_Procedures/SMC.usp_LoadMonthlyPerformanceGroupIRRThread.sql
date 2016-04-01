-- =============================================
-- Author:		Daniel Pan
-- Create date: 02/26/2015
-- Description:	Populate MonthlyPerformanceGroupIRRThread table
-- 
-- EXEC [SMC].[usp_LoadMonthlyPerformanceGroupIRRThread]
-- 45:03 IRR Only
-- 40:04 IRRReported Only
-- 01:23:33 IRR AND IRRReported
-- =============================================

-- =============================================
-- Create basic stored procedure template
-- Exec SMC.usp_LoadMonthlyPerformanceGroupIRRThread 4
-- =============================================
USE SMC_DB_Performance
GO


-- Drop stored procedure if it already exists
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_LoadMonthlyPerformanceGroupIRRThread' 
)
   DROP PROCEDURE SMC.usp_LoadMonthlyPerformanceGroupIRRThread
GO

CREATE PROCEDURE [SMC].[usp_LoadMonthlyPerformanceGroupIRRThread]
	@ThreadID INT
AS

BEGIN

	-- reading GroupControl Table and looping through to calculate Group performance columns
	DECLARE @sql VARCHAR(MAX), @sqlext VARCHAR(MAX)

	-- Get the number of rows in the looping table
	DECLARE @RowIDCurr INT

	-- SMC_LoadDate
	DECLARE @SMC_LoadDate VARCHAR(30)
	SELECT @SMC_LoadDate = CONVERT(VARCHAR, GETDATE(), 121)
		 
	DECLARE @GroupControlThread TABLE (
		[RowID] [INT] NOT NULL,
		[GroupColumn] [VARCHAR](50) NULL,
		[GroupDesc] [VARCHAR](50) NULL,
		[GroupActive] [BIT] NULL,
		[ThreadID] [INT] NULL
	)

	-- Get the groupings for specified thread id
	INSERT INTO @GroupControlThread
	SELECT * FROM [SMC].[GroupControlThread] WHERE ThreadID = @ThreadID

	-- Declare variables to hold the data which we get after looping each record 
	DECLARE @GroupColumn VARCHAR(50), @GroupDesc VARCHAR(255)

	-- Truncate group core table
	--TRUNCATE TABLE [SMC].[MonthlyPerformanceGroupIRRThread]

	-- Loop through the rows of a table and insert group calculation to group performance table
	WHILE Exists(SELECT * FROM @GroupControlThread)
	BEGIN
		-- Get the data from table and set to variables
		SELECT TOP 1 @RowIDCurr = RowID, @GroupColumn = GroupColumn, @GroupDesc = GroupDesc FROM @GroupControlThread ORDER BY RowID

		SET @sql = '
			-- Populate Group Performance MonthEnd and InceptionDate
			;WITH CTE_Group AS
			(	-- Calculate Group Measures
				SELECT MonthEnd, ISNULL(RTRIM(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',',')),''NULL'') + '' - '' + ISNULL(RTRIM(CONVERT(VARCHAR,') + ')),''NULL'') GroupName,
					''' + @GroupDesc + ''' GroupDesc
				FROM SMC.vw_FactMonthlyPerformance
				WHERE ISNULL(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',','),'''') NOT IN ('''',''NA'',''0'') AND ISNULL(CONVERT(VARCHAR,') + '),'''') NOT IN ('''',''NA'',''0'')
				AND DataSource <> ''CND''
				GROUP BY MonthEnd, ' + @GroupColumn + '
			)
			, CTE_Inception AS
			(	-- Get minimum date as inception date
				SELECT GroupName, Min(MonthEnd) InceptionDate
				FROM CTE_Group
				GROUP BY GroupName
			)
			INSERT INTO [SMC].[MonthlyPerformanceGroupIRRThread] (GroupName, GroupDesc, MonthEnd, IRR1M, IRR3M, IRR1Yr, IRR3Yr, IRR5Yr, IRR7Yr, IRR10Yr, IRRCY, IRRJY, SIRR, IRR1MReported, IRR3MReported, IRR1YrReported, IRR3YrReported, IRR5YrReported, IRR7YrReported, IRR10YrReported, IRRCYReported, IRRJYReported, SIRRReported, SMC_LoadDate)

			SELECT x.GroupName, x.GroupDesc, x.MonthEnd, PivotTable.[IRR_1M], PivotTable.[IRR_3M], PivotTable.[IRR_1Yr], PivotTable.[IRR_3Yr], PivotTable.[IRR_5Yr], PivotTable.[IRR_7Yr], PivotTable.[IRR_10Yr], PivotTable.[IRR_CYTD], PivotTable.[IRR_JYTD], PivotTable.[IRR_SI], PivotTable.[IRRReported_1M], PivotTable.[IRRReported_3M], PivotTable.[IRRReported_1Yr], PivotTable.[IRRReported_3Yr], PivotTable.[IRRReported_5Yr], PivotTable.[IRRReported_7Yr], PivotTable.[IRRReported_10Yr], PivotTable.[IRRReported_CYTD], PivotTable.[IRRReported_JYTD], PivotTable.[IRRReported_SI], ''' + @SMC_LoadDate + '''
			FROM CTE_Group x LEFT JOIN
			(
				SELECT GroupName, GroupDesc, MonthEnd, PerformanceCol + ''_'' + ShortDesc PerformanceCol, PerformanceVal
				FROM 
				(	-- Calculate IRR and IRRReported
					SELECT m.GroupName, m.GroupDesc, m.MonthEnd, n.*, 
						-- Calculate IRR
						-- Only process if its quarter end
						CASE WHEN n.BeginDate IS NULL OR n.EndDate IS NULL OR (n.EndDate <> DATEADD(d, -1, DATEADD(q, DATEDIFF(q, 0, n.EndDate) + 1, 0))) 
							THEN NULL
							ELSE SMC.ufn_GetGroupIRR(m.GroupName, n.ShortDesc, n.BeginDate, n.EndDate) 
						END IRR,
						-- Calculate IRRReported
						CASE WHEN n.BeginDate IS NULL OR n.EndDate IS NULL 
							THEN NULL 
							ELSE 
							-- Deannualize if @DayDiff less than @DayYear
							IIF(n.ShortDesc = ''SI'' AND DATEDIFF(dd,n.BeginDate,n.EndDate) < DATEPART(dy,DATEFROMPARTS(YEAR(n.EndDate),12,31)), SMC_DB_Reference.SMC.ufn_PowerWrapper(1+t.IRR,cast(DATEDIFF(dd,n.BeginDate,n.EndDate) as float),cast(DATEPART(dy,DATEFROMPARTS(YEAR(n.EndDate),12,31)) as float))-1, 
								IIF(n.ShortDesc = ''3M'', SMC_DB_Reference.SMC.ufn_PowerWrapper(1+t.IRR,1.0,4.0)-1, t.IRR))
						END IRRReported
					FROM 
					(
						SELECT x.GroupName, x.GroupDesc, y.InceptionDate, x.MonthEnd
						FROM CTE_Group x
							LEFT JOIN CTE_Inception y
							ON x.GroupName = y.GroupName
					) m
					CROSS APPLY SMC.ufn_GetPeriodic(m.InceptionDate, m.MonthEnd) n '
			SET @sqlext = '
					-- Only process if its quarter end
					CROSS APPLY 
					(	SELECT [SMC_DB_REFERENCE].wct.XIRR(CFAmt, CFDate, NULL) IRR
						FROM 
						(	
							-- Get EAMV and BAMV
							-- initial valuation will be treated as a synthetic cash outflow 
							-- Always turn the Valuation to negative sign
							SELECT ISNULL(RTRIM(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',',')),''NULL'') + '' - '' + ISNULL(RTRIM(CONVERT(VARCHAR,') + ')),''NULL'') GroupName, ''ERMV'' CFName, MonthEnd CFDate, ABS(SUM(EAMarketValuePMD)) * -1.000 CFAmt
							FROM [SMC].[vw_FactMonthlyPerformance]
							WHERE MonthEnd = EOMONTH(DateAdd(d, -1, n.BeginDate))
								AND ISNULL(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',','),'''') NOT IN ('''',''NA'',''0'') AND ISNULL(CONVERT(VARCHAR,') + '),'''') NOT IN ('''',''NA'',''0'')
								AND ISNULL(RTRIM(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',',')),''NULL'') + '' - '' + ISNULL(RTRIM(CONVERT(VARCHAR,') + ')),''NULL'') = m.GroupName
								AND AccountNumber IN 
								(	--Only Account which has reported market value
									SELECT DISTINCT AccountNumber
									FROM [SMC].[vw_FactMonthlyPerformance]
									WHERE MonthEnd = EOMONTH(n.EndDate)
										AND ISNULL(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',','),'''') NOT IN ('''',''NA'',''0'') AND ISNULL(CONVERT(VARCHAR,') + '),'''') NOT IN ('''',''NA'',''0'')
										AND ISNULL(RTRIM(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',',')),''NULL'') + '' - '' + ISNULL(RTRIM(CONVERT(VARCHAR,') + ')),''NULL'') = m.GroupName
										AND RowType = ''R''
								)
								-- Ingore BRMV if Begin Month = Inception Month
								AND n.ShortDesc <> ''SI''
							GROUP BY MonthEnd, ' + @GroupColumn + '
						
							-- Get Transactions
							-- Turn the cash flow to negative sign if InceptionDate = MonthEnd (First Month)
							UNION ALL
							-- Get Transaction for Group
							SELECT ISNULL(RTRIM(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',',')),''NULL'') + '' - '' + ISNULL(RTRIM(CONVERT(VARCHAR,') + ')),''NULL'') GroupName, ''TRANSACTION'' CFName, TransactionDate CFDate,
								CASE WHEN EOMONTH(n.BeginDate ) = EOMONTH(n.EndDate) THEN ABS(SUM(TransactionAmt)) * -1.000
									ELSE SUM(TransactionAmt)
								END CFAmt
							FROM [SMC].[vw_FactTransactionMeta]
							WHERE TransactionDate BETWEEN n.BeginDate AND n.EndDate
								AND ISNULL(RTRIM(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',',')),''NULL'') + '' - '' + ISNULL(RTRIM(CONVERT(VARCHAR,') + ')),''NULL'') = m.GroupName
								AND ISNULL(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',','),'''') NOT IN ('''',''NA'',''0'') AND ISNULL(CONVERT(VARCHAR,') + '),'''') NOT IN ('''',''NA'',''0'')
								AND AccountNumber IN 
								(	--Only Account which has reported market value
									SELECT DISTINCT AccountNumber
									FROM [SMC].[vw_FactMonthlyPerformance]
									WHERE MonthEnd = EOMONTH(n.EndDate)
										AND ISNULL(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',','),'''') NOT IN ('''',''NA'',''0'') AND ISNULL(CONVERT(VARCHAR,') + '),'''') NOT IN ('''',''NA'',''0'')
										AND ISNULL(RTRIM(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',',')),''NULL'') + '' - '' + ISNULL(RTRIM(CONVERT(VARCHAR,') + ')),''NULL'') = m.GroupName
										AND RowType = ''R''
								)
							GROUP BY TransactionDate, ' + @GroupColumn + '
													
							-- Get EAMV
							-- the ending market value will be a synthetic cash inflow
							-- keep the Valuation sign without changing it
							UNION ALL
							-- Get EAMV for Group
							SELECT ISNULL(RTRIM(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',',')),''NULL'') + '' - '' + ISNULL(RTRIM(CONVERT(VARCHAR,') + ')),''NULL'') GroupName, ''ERMV'' CFName, MonthEnd CFDate, SUM(EAMarketValuePMD) CFAmt
							FROM [SMC].[vw_FactMonthlyPerformance]
							WHERE MonthEnd = EOMONTH(n.EndDate)
								AND ISNULL(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',','),'''') NOT IN ('''',''NA'',''0'') AND ISNULL(CONVERT(VARCHAR,') + '),'''') NOT IN ('''',''NA'',''0'')
								AND ISNULL(RTRIM(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',',')),''NULL'') + '' - '' + ISNULL(RTRIM(CONVERT(VARCHAR,') + ')),''NULL'') = m.GroupName
								AND RowType = ''R''
							GROUP BY MonthEnd, ' + @GroupColumn + '
						) x
						WHERE n.BeginDate IS NOT NULL AND n.EndDate IS NOT NULL
						AND n.EndDate = DATEADD(d, -1, DATEADD(q, DATEDIFF(q, 0, n.EndDate) + 1, 0)) 
					) t
				) src
				UNPIVOT (
					PerformanceVal
					FOR PerformanceCol IN (IRR, IRRReported)
				) unpiv
			) AS SourceTable
			PIVOT
			(
				SUM(PerformanceVal)
				FOR PerformanceCol IN ([IRR_1M], [IRR_3M], [IRR_1Yr], [IRR_3Yr], [IRR_5Yr], [IRR_7Yr], [IRR_10Yr], [IRR_CYTD], [IRR_JYTD], [IRR_SI], [IRRReported_1M], [IRRReported_3M], [IRRReported_1Yr], [IRRReported_3Yr], [IRRReported_5Yr], [IRRReported_7Yr], [IRRReported_10Yr], [IRRReported_CYTD], [IRRReported_JYTD], [IRRReported_SI])
			) AS PivotTable
			ON x.GroupName = PivotTable.GroupName AND x.MonthEnd = PivotTable.MonthEnd
			--GROUP BY GroupName, MonthEnd
			'


		PRINT (@sql + @sqlext)
		EXEC (@sql + @sqlext)

		-- Increment the iterator
		DELETE @GroupControlThread WHERE RowID = @RowIDCurr		
	END


END