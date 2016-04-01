-- =============================================
-- Author:		Daniel Pan
-- Create date: 02/26/2015
-- Description:	Populate MonthlyPerformanceCoreGroup table
-- 
-- EXEC [SMC].[usp_LoadMonthlyPerformanceCoreGroup]
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
     AND SPECIFIC_NAME = N'usp_LoadMonthlyPerformanceCoreGroup' 
)
   DROP PROCEDURE SMC.usp_LoadMonthlyPerformanceCoreGroup
GO

CREATE PROCEDURE [SMC].[usp_LoadMonthlyPerformanceCoreGroup]
AS

BEGIN

	-- reading GroupControl Table and looping through to calculate Group performance columns
	DECLARE @sql VARCHAR(MAX), @select VARCHAR(MAX), @join VARCHAR(MAX), @column VARCHAR(MAX), @insert VARCHAR(MAX)

	-- Get the number of rows in the looping table
	DECLARE @RowIDCurr INT, @RowIDMax INT
	SELECT @RowIDCurr = MIN(RowID), @RowIDMax = MAX(RowID) FROM [SMC].[GroupControl]

	-- SMC_LoadDate
	DECLARE @SMC_LoadDate VARCHAR(30)
	SELECT @SMC_LoadDate = CONVERT(VARCHAR, GETDATE(), 121)

	-- Declare variables to hold the data which we get after looping each record 
	DECLARE @GroupColumn VARCHAR(50), @GroupDesc VARCHAR(50)

	-- Truncate group core table
	TRUNCATE TABLE [SMC].[MonthlyPerformanceCoreGroup]

	-- Loop through the rows of a table and insert group calculation to group performance table
	WHILE (@RowIDCurr <= @RowIDMax)
	BEGIN
		-- Get the data from table and set to variables
		SELECT TOP 1 @GroupColumn = GroupColumn, @GroupDesc = GroupDesc FROM [SMC].[GroupControl] WHERE RowID >= @RowIDCurr ORDER BY RowID

		SET @select = ''	
		SET @column = ''
		SET @join = '' 
		SET @insert = ''
	
		-- Portfolio + SubPortfolio
		IF (CHARINDEX('Portfolio', @GroupColumn) > 0 AND CHARINDEX('SubPortfolio', @GroupColumn) > 0 AND CHARINDEX('+', @GroupColumn) > 0)
		OR 
		-- Portfolio + AssetClass
		(CHARINDEX('Portfolio', @GroupColumn) > 0 AND CHARINDEX('SubPortfolio', @GroupColumn) = 0 AND CHARINDEX('AssetClass', @GroupColumn) > 0)
		BEGIN
			-- Contribution to Portfolio
			SET @select = @select + ', Portfolio '	
			SET @insert = @insert + ', [PortfolioTotal], [ContSDFPortfolio] '
			SET @column = @column + ', d.[PortfolioTotal], IIF(d.[PortfolioTotal]=0, 0, (a.[ACBPMD]/d.[PortfolioTotal]) * a.[TWRPMD]) ContSDFPortfolio '
			SET @join = @join + 'LEFT JOIN CTE_PortfolioTotal d	ON a.MonthEnd = d.MonthEnd AND a.Portfolio = d.Portfolio ' 
		END
		---- Portfolio + AssetClass
		--IF (CHARINDEX('Portfolio', @GroupColumn) > 0 AND CHARINDEX('SubPortfolio', @GroupColumn) = 0 AND CHARINDEX('AssetClass', @GroupColumn) > 0)
		--BEGIN
		--	-- Contribution to SubPortfolio
		--	SET @select = @select + ', SubPortfolio '	
		--	SET @insert = @insert + ', [SubPortfolioTotal], [ContSDFSubPortfolio] '
		--	SET @column = @column + ', e.[SubPortfolioTotal], IIF(e.[SubPortfolioTotal]=0, 0, (a.[ACBPMD]/e.[SubPortfolioTotal]) * a.[TWRPMD]) ContSDFSubPortfolio '
		--	SET @join = @join + 'LEFT JOIN CTE_SubPortfolioTotal e ON a.MonthEnd = e.MonthEnd AND a.SubPortfolio = e.SubPortfolio ' 
		--END
		-- AssetClass
		--IF CHARINDEX('AssetClass', @GroupColumn) > 0
		--BEGIN
		--	SET @select = @select + ',AssetClass '	
		--	SET @insert = @insert + ', [AssetClassTotal], [ContSDFAssetClass1M] '
		--	SET @column = @column + ', f.[AssetClassTotal], IIF(f.[AssetClassTotal]=0, 0, (a.[ACB]/f.[AssetClassTotal]) * a.[TWR1M]) ContSDFAssetClass1M '
		--	SET @join = @join + 'LEFT JOIN CTE_AssetClassTotal f ON a.MonthEnd = f.MonthEnd AND f.AssetClass = f.AssetClass ' 
		--END

		SET @sql = '
			-- Prepare Aggregate Columns
			;WITH CTE_Group AS
			(	-- Calculate Group Measures
				SELECT MonthEnd, ISNULL(RTRIM(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',',')),''NULL'') + '' - '' + ISNULL(RTRIM(CONVERT(VARCHAR,') + ')),''NULL'') GroupName,
					--SUM(BAMarketValuePMD) BAMarketValuePMD,
					--SUM(EAMarketValuePMD) EAMarketValuePMD,
					SUM(ProfitPMD) ProfitPMD, 
					SUM([ProfitReported]) ProfitReported, 
					SUM(ACBPMD) ACBPMD, 
					SUM(ACBReported) ACBReported, 
					SUM(EAMarketValuePMD) EAMV,
					SUM(MarketValue) MarketValue,
					IIF(SUM(ACBPMD)=0,0,CONVERT(FLOAT,SUM(ProfitPMD))/CONVERT(FLOAT,SUM(ACBPMD))) TWRPMD,
					IIF(SUM(ACBReported)=0,0,CONVERT(FLOAT,SUM(ProfitReported))/CONVERT(FLOAT,SUM(ACBReported))) TWRReported,
					IIF(SUM(CapitalCalls) + SUM(AdditionalFees)=0,0, CONVERT(FLOAT, SUM(Distributions) / (SUM(CapitalCalls) + SUM(AdditionalFees)))) MultipleDPI,
					IIF(SUM(CapitalCalls) + SUM(AdditionalFees)=0,0, CONVERT(FLOAT, SUM(EAMarketValuePMD) / (SUM(CapitalCalls) + SUM(AdditionalFees)))) MultipleRPI,
					IIF(SUM(CapitalCalls) + SUM(AdditionalFees)=0,0, CONVERT(FLOAT, (SUM(EAMarketValuePMD) + SUM(Distributions)) / (SUM(CapitalCalls) + SUM(AdditionalFees)))) MultipleTVPI,
					SUM(CommitmentAmt) Commitment, 
					SUM(AdjCommitmentAmt) AdjCommitment, 
					SUM(UnfundedCommitment) UnfundedCommitment,
					SUM(EAMVUnfundedCommitment) EAMVUnfundedCommitment,
					SUM(CapitalCalls) CapitalCalls,
					SUM(Distributions) Distributions,
					SUM(CapitalCallsFees) CapitalCallsFees, 
					SUM(CapitalCallsFees) CapitalCallsFeesFirst, 
					SUM(CapitalCallsFees) CapitalCallsFeesLast 								
					'
		
			SET @sql = @sql + @select

			SET @sql = @sql + '
				FROM SMC.vw_FactMonthlyPerformance
				WHERE ISNULL(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',','),'''') NOT IN ('''',''NA'',''0'') AND ISNULL(CONVERT(VARCHAR,') + '),'''') NOT IN ('''',''NA'',''0'')
				GROUP BY MonthEnd, ' + @GroupColumn + '
				--, PoolTotal, PortfolioTotal, SubPortfolioTotal, AssetClassTotal
			)
			, CTE_Reported AS
			(	-- Reported MV only
				SELECT MonthEnd, ISNULL(RTRIM(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',',')),''NULL'') + '' - '' + ISNULL(RTRIM(CONVERT(VARCHAR,') + ')),''NULL'') GroupName,
					SUM(EAMarketValuePMD) MVReported
				FROM SMC.vw_FactMonthlyPerformance
				WHERE ISNULL(CONVERT(VARCHAR,' + REPLACE(@GroupColumn,',','),'''') NOT IN ('''',''NA'',''0'') AND ISNULL(CONVERT(VARCHAR,') + '),'''') NOT IN ('''',''NA'',''0'')
				--AND RowType = ''R''
				AND ReportedPct = 1
				GROUP BY MonthEnd, ' + @GroupColumn + '
			)
			, CTE_Inception AS
			(	-- Get minimum date as inception date
				SELECT GroupName, MIN(MonthEnd) InceptionDate, MIN(MonthEnd) MinMonthEnd, MAX(MonthEnd) MaxMonthEnd
				FROM CTE_Group
				GROUP BY GroupName
			)
			, CTE_PoolTotal AS
			(
				SELECT MonthEnd, SUM(ACBPMD) PoolTotal
				FROM [SMC].[vw_FactMonthlyPerformance]
				GROUP BY MonthEnd
			)
			, CTE_PortfolioTotal AS
			(
				SELECT MonthEnd, Portfolio, SUM(ACBPMD) PortfolioTotal
				FROM [SMC].[vw_FactMonthlyPerformance]
				GROUP BY MonthEnd, Portfolio
			)
			, CTE_SubPortfolioTotal AS
			(
				SELECT MonthEnd, SubPortfolio, SUM(ACBPMD) SubPortfolioTotal
				FROM [SMC].[vw_FactMonthlyPerformance]
				GROUP BY MonthEnd, SubPortfolio
			)
			, CTE_AssetClassTotal AS
			(
				SELECT MonthEnd, AssetClass, SUM(ACBPMD) AssetClassTotal
				FROM [SMC].[vw_FactMonthlyPerformance]
				GROUP BY MonthEnd, AssetClass
			)
			-- insert into Group Core Table
			INSERT INTO [SMC].[MonthlyPerformanceCoreGroup] ([GroupName], [GroupDesc],[MonthEnd], [InceptionDate], [MinMonthEnd], [MaxMonthEnd], [ProfitPMD], [ProfitReported], [ACBPMD], [ACBReported], [EAMV], [MarketValue], [TWRPMD], [TWRReported], [MultipleDPI], [MultipleRPI], [MultipleTVPI], [Commitment], [AdjCommitment], [UnfundedCommitment], [EAMVUnfundedCommitment], [MVReported], [PoolTotal], [ContSDFPool], [CapitalCalls], [Distributions], [CapitalCallsFees], [CapitalCallsFeesFirst], [CapitalCallsFeesLast] '

			SET @sql = @sql + @insert
			
			SET @sql = @sql + ', [SMC_LoadDate])
			SELECT a.GroupName, ''' + @GroupDesc + ''' GroupDesc, a.MonthEnd, b.InceptionDate, b.MinMonthEnd, b.MaxMonthEnd, a.ProfitPMD, a.ProfitReported, a.ACBPMD, a.ACBReported, a.EAMV, a.MarketValue, a.TWRPMD, a.TWRReported, a.MultipleDPI, a.MultipleRPI, a.MultipleTVPI, a.Commitment, a.AdjCommitment, a.UnfundedCommitment, a.EAMVUnfundedCommitment, r.MVReported
			,c.[PoolTotal],IIF(c.[PoolTotal]=0, 0, (a.[ACBPMD]/c.[PoolTotal]) * a.[TWRPMD]) ContSDFPool, a.[CapitalCalls], a.[Distributions], a.[CapitalCallsFees], a.[CapitalCallsFeesFirst], a.[CapitalCallsFeesLast] '

			SET @sql = @sql + @column

			SET @sql = @sql + ',''' + @SMC_LoadDate + ''' 
			FROM CTE_Group a
				INNER JOIN CTE_Inception b
					ON a.GroupName = b.GroupName	
				LEFT JOIN CTE_PoolTotal c
					ON a.MonthEnd = c.MonthEnd 
				LEFT JOIN CTE_Reported r
					ON a.MonthEnd = r.MonthEnd AND a.GroupName = r.GroupName 
			'

			SET @sql = @sql + @join 					

		PRINT (@sql)
		EXEC (@sql)

		-- Increment the iterator
		SET @RowIDCurr = @RowIDCurr + 1
	END

END