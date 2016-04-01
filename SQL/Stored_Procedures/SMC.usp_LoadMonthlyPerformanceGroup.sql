-- =============================================
-- Author:		Daniel Pan
-- Create date: 02/26/2015
-- Description:	Populate MonthlyPerformanceGroup table
-- 
-- EXEC [SMC].[usp_LoadMonthlyPerformanceGroup]
-- 4:43
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
     AND SPECIFIC_NAME = N'usp_LoadMonthlyPerformanceGroup' 
)
   DROP PROCEDURE SMC.usp_LoadMonthlyPerformanceGroup
GO

CREATE PROCEDURE [SMC].[usp_LoadMonthlyPerformanceGroup]
AS

BEGIN
	-- Truncate group core table
	TRUNCATE TABLE [SMC].[MonthlyPerformanceGroup]
	--13:08

	-- SMC_LoadDate
	DECLARE @SMC_LoadDate VARCHAR(30)
	SELECT @SMC_LoadDate = CONVERT(VARCHAR, GETDATE(), 121)

	;WITH CTE_PerformancePeriodic AS
	(
		SELECT DISTINCT m.GroupName, m.GroupDesc, m.MonthEnd, n.ShortDesc, n.BeginDate, n.EndDate, t.TWRCumulative, t.TWRAnnualized, t.ProfitCumulative, t.TWRReportedCumulative, t.TWRReportedAnnualized, t.ContSDFPoolCumulative, t.ContSDFPortfolioCumulative, t.ContSDFSubPortfolioCumulative, t.ContSDFAssetClassCumulative, t.CapitalCallsFeesCumulative, t.DistributionsCumulative
		FROM [SMC].[MonthlyPerformanceCoreGroup] m
		CROSS APPLY SMC.ufn_GetPeriodic(m.InceptionDate, m.MonthEnd) n
		CROSS APPLY SMC.ufn_GetGroupPerformance(m.GroupName, n.BeginDate, n.EndDate) t
		--WHERE m.GroupName = 'Absolute Return'
		--ORDER BY ShortDesc
	)
	, CTE_PerformanceUnPivot AS
	(	-- Unpivot TWR, Contribution, Profit columns
		SELECT GroupName, GroupDesc, MonthEnd, PerformanceCol + '_' + ShortDesc PerformanceCol, PerformanceVal
		FROM CTE_PerformancePeriodic src
		UNPIVOT (
			PerformanceVal
			FOR PerformanceCol IN (TWRAnnualized, ProfitCumulative, TWRReportedAnnualized, ContSDFPoolCumulative, ContSDFPortfolioCumulative, ContSDFSubPortfolioCumulative, ContSDFAssetClassCumulative, CapitalCallsFeesCumulative, DistributionsCumulative)
		) unpiv
	)
    , CTE_PerformancePivot AS
	(	-- Pivot Periodic columns
		SELECT GroupName, GroupDesc, MonthEnd, 
			[ProfitCumulative_1M],
			[ProfitCumulative_3M],
			[ProfitCumulative_CYTD],
			[ProfitCumulative_JYTD],

			[TWRAnnualized_1M],
			[TWRAnnualized_3M],
			[TWRAnnualized_1Yr],
			[TWRAnnualized_3Yr],
			[TWRAnnualized_5Yr],
			[TWRAnnualized_7Yr],
			[TWRAnnualized_10Yr],
			[TWRAnnualized_CYTD],
			[TWRAnnualized_JYTD],
			[TWRAnnualized_SI],

			[TWRReportedAnnualized_1M],
			[TWRReportedAnnualized_3M],
			[TWRReportedAnnualized_1Yr],
			[TWRReportedAnnualized_CYTD],
			[TWRReportedAnnualized_JYTD],

			[ContSDFPoolCumulative_1M],
			[ContSDFPoolCumulative_3M],
			[ContSDFPoolCumulative_1Yr],
			[ContSDFPoolCumulative_CYTD],

			[ContSDFPortfolioCumulative_1M],
			[ContSDFPortfolioCumulative_3M],
			[ContSDFPortfolioCumulative_1Yr],
			[ContSDFPortfolioCumulative_CYTD],

			[ContSDFSubPortfolioCumulative_1M],
			[ContSDFSubPortfolioCumulative_3M],
			[ContSDFSubPortfolioCumulative_1Yr],
			[ContSDFSubPortfolioCumulative_CYTD],

			[ContSDFAssetClassCumulative_1M],
			[ContSDFAssetClassCumulative_3M],
			[ContSDFAssetClassCumulative_1Yr],
			[ContSDFAssetClassCumulative_CYTD],

			[DistributionsCumulative_1M],
			[DistributionsCumulative_3M],
			[DistributionsCumulative_1Yr],
			[DistributionsCumulative_CYQTD],
			[DistributionsCumulative_CYTD],
			[DistributionsCumulative_SI],

			[CapitalCallsFeesCumulative_1M],
			[CapitalCallsFeesCumulative_3M],
			[CapitalCallsFeesCumulative_PrevQ1],
			[CapitalCallsFeesCumulative_PrevQ2],
			[CapitalCallsFeesCumulative_PrevQ3],
			[CapitalCallsFeesCumulative_PrevQ4],
			[CapitalCallsFeesCumulative_1Yr],
			[CapitalCallsFeesCumulative_CYQTD],
			[CapitalCallsFeesCumulative_CYTD],
			[CapitalCallsFeesCumulative_SI]

		FROM CTE_PerformanceUnPivot s
		PIVOT
		(
		  SUM(PerformanceVal)
		  FOR PerformanceCol IN (
			[ProfitCumulative_1M],
			[ProfitCumulative_3M],
			[ProfitCumulative_CYTD],
			[ProfitCumulative_JYTD],

			[TWRAnnualized_1M],
			[TWRAnnualized_3M],
			[TWRAnnualized_1Yr],
			[TWRAnnualized_3Yr],
			[TWRAnnualized_5Yr],
			[TWRAnnualized_7Yr],
			[TWRAnnualized_10Yr],
			[TWRAnnualized_CYTD],
			[TWRAnnualized_JYTD],
			[TWRAnnualized_SI],

			[TWRReportedAnnualized_1M],
			[TWRReportedAnnualized_3M],
			[TWRReportedAnnualized_1Yr],
			[TWRReportedAnnualized_CYTD],
			[TWRReportedAnnualized_JYTD],

			[ContSDFPoolCumulative_1M],
			[ContSDFPoolCumulative_3M],
			[ContSDFPoolCumulative_1Yr],
			[ContSDFPoolCumulative_CYTD],

			[ContSDFPortfolioCumulative_1M],
			[ContSDFPortfolioCumulative_3M],
			[ContSDFPortfolioCumulative_1Yr],
			[ContSDFPortfolioCumulative_CYTD],

			[ContSDFSubPortfolioCumulative_1M],
			[ContSDFSubPortfolioCumulative_3M],
			[ContSDFSubPortfolioCumulative_1Yr],
			[ContSDFSubPortfolioCumulative_CYTD],

			[ContSDFAssetClassCumulative_1M],
			[ContSDFAssetClassCumulative_3M],
			[ContSDFAssetClassCumulative_1Yr],
			[ContSDFAssetClassCumulative_CYTD],

			[DistributionsCumulative_1M],
			[DistributionsCumulative_3M],
			[DistributionsCumulative_1Yr],
			[DistributionsCumulative_CYQTD],
			[DistributionsCumulative_CYTD],
			[DistributionsCumulative_SI],

			[CapitalCallsFeesCumulative_1M],
			[CapitalCallsFeesCumulative_3M],
			[CapitalCallsFeesCumulative_PrevQ1],
			[CapitalCallsFeesCumulative_PrevQ2],
			[CapitalCallsFeesCumulative_PrevQ3],
			[CapitalCallsFeesCumulative_PrevQ4],
			[CapitalCallsFeesCumulative_1Yr],
			[CapitalCallsFeesCumulative_CYQTD],
			[CapitalCallsFeesCumulative_CYTD],
			[CapitalCallsFeesCumulative_SI]
			)
		) piv
	)

	INSERT INTO [SMC].[MonthlyPerformanceGroup] (GroupName, GroupDesc, MonthEnd, InceptionDate, ACBPMD, ACBReported, EAMV, MarketValue, ReportedPct, MultipleDPI, MultipleRPI, MultipleTVPI, Commitment, AdjCommitment, UnfundedCommitment, EAMVUnfundedCommitment, 
		TWR1M, TWR3M, TWR1Yr, TWR3Yr, TWR5Yr, TWR7Yr, TWR10Yr, TWRCY, TWRJY, STWR, TWR1MReported, TWR3MReported, TWR1YrReported, TWRCYReported, TWRJYReported, Profit1M, Profit3M, ProfitCY, ProfitJY, Profit1MReported,
		ContSDFPool1M, ContSDFPool3M, ContSDFPool1Yr, ContSDFPoolCY, 
		ContSDFPortfolio1M, ContSDFPortfolio3M, ContSDFPortfolio1Yr, ContSDFPortfolioCY,
		ContSDFSubPortfolio1M, ContSDFSubPortfolio3M, ContSDFSubPortfolio1Yr, ContSDFSubPortfolioCY,
		ContSDFAssetClass1M, ContSDFAssetClass3M, ContSDFAssetClass1Yr, ContSDFAssetClassCY, 
		CapitalCalls, AdditionalFees,

		Distributions1M, Distributions3M, Distributions1Yr, DistributionsQTD, DistributionsYTD, DistributionsSI, 
		CapitalCallsFeesFirst, CapitalCallsFeesLast, CapitalCallsFees1M, CapitalCallsFees3M, CapitalCallsFees1Yr, CapitalCallsFeesQ1Prev, CapitalCallsFeesQ2Prev, CapitalCallsFeesQ3Prev, CapitalCallsFeesQ4Prev, CapitalCallsFeesQTD, CapitalCallsFeesYTD, CapitalCallsFeesSI, SMC_LoadDate
		)
	SELECT DISTINCT m.GroupName, m.GroupDesc, m.MonthEnd, m.InceptionDate, m.ACBPMD, m.ACBReported, m.EAMV, m.MarketValue, IIF(ISNULL(m.EAMV, 0) = 0, 0, m.MVReported/m.EAMV) ReportedPct, --m.TWR1M,
			m.MultipleDPI, m.MultipleRPI, m.MultipleTVPI, m.Commitment, m.AdjCommitment, m.UnfundedCommitment, m.EAMVUnfundedCommitment,
			t.[TWRAnnualized_1M],
			t.[TWRAnnualized_3M],
			t.[TWRAnnualized_1Yr],
			t.[TWRAnnualized_3Yr],
			t.[TWRAnnualized_5Yr],
			t.[TWRAnnualized_7Yr],
			t.[TWRAnnualized_10Yr],
			t.[TWRAnnualized_CYTD],
			t.[TWRAnnualized_JYTD],
			t.[TWRAnnualized_SI],
			t.[TWRReportedAnnualized_1M],
			t.[TWRReportedAnnualized_3M],
			t.[TWRReportedAnnualized_1Yr],
			t.[TWRReportedAnnualized_CYTD],
			t.[TWRReportedAnnualized_JYTD],
			m.ProfitPMD [Profit1M],
			t.[ProfitCumulative_3M],
			t.[ProfitCumulative_CYTD],
			t.[ProfitCumulative_JYTD],
			m.ProfitReported [Profit1MReported],
			t.[ContSDFPoolCumulative_1M],
			t.[ContSDFPoolCumulative_3M],
			t.[ContSDFPoolCumulative_1Yr],
			t.[ContSDFPoolCumulative_CYTD],
			t.[ContSDFPortfolioCumulative_1M],
			t.[ContSDFPortfolioCumulative_3M],
			t.[ContSDFPortfolioCumulative_1Yr],
			t.[ContSDFPortfolioCumulative_CYTD],
			t.[ContSDFSubPortfolioCumulative_1M],
			t.[ContSDFSubPortfolioCumulative_3M],
			t.[ContSDFSubPortfolioCumulative_1Yr],
			t.[ContSDFSubPortfolioCumulative_CYTD],
			t.[ContSDFAssetClassCumulative_1M],
			t.[ContSDFAssetClassCumulative_3M],
			t.[ContSDFAssetClassCumulative_1Yr],
			t.[ContSDFAssetClassCumulative_CYTD],
			m.[CapitalCalls], m.[AdditionalFees],	                

			t.[DistributionsCumulative_1M],
			t.[DistributionsCumulative_3M],
			t.[DistributionsCumulative_1Yr],
			t.[DistributionsCumulative_CYQTD],
			t.[DistributionsCumulative_CYTD],
			t.[DistributionsCumulative_SI],
			m.CapitalCallsFeesFirst, m.CapitalCallsFeesLast, 
			t.[CapitalCallsFeesCumulative_1M],
			t.[CapitalCallsFeesCumulative_3M],
			t.[CapitalCallsFeesCumulative_PrevQ1],
			t.[CapitalCallsFeesCumulative_PrevQ2],
			t.[CapitalCallsFeesCumulative_PrevQ3],
			t.[CapitalCallsFeesCumulative_PrevQ4],
			t.[CapitalCallsFeesCumulative_1Yr],
			t.[CapitalCallsFeesCumulative_CYQTD],
			t.[CapitalCallsFeesCumulative_CYTD],
			t.[CapitalCallsFeesCumulative_SI],
			@SMC_LoadDate
	FROM [SMC].[MonthlyPerformanceCoreGroup] m
	LEFT JOIN CTE_PerformancePivot t
	ON m.GroupName = t.GroupName AND m.MonthEnd = t.MonthEnd
	--WHERE m.GroupName = 'DAPER'


END