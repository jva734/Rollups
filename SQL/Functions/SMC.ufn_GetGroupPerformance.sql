-- =============================================
-- Author:		Daniel Pan
-- Create date: 03/06/2015
-- Description:	Calculate Group TWR based on provided date range
-- 
-- SELECT * FROM SMC.ufn_GetGroupPerformance('Absolute Return', n.BeginDate, n.EndDate) 
-- =============================================

--================================================
-- Drop function template
--================================================
USE SMC_DB_Performance
GO

IF OBJECT_ID (N'SMC.ufn_GetGroupPerformance') IS NOT NULL
   DROP FUNCTION SMC.ufn_GetGroupPerformance
GO

CREATE FUNCTION SMC.ufn_GetGroupPerformance(@GroupName VARCHAR(100), @BeginDate DATE, @EndDate DATE)  RETURNS TABLE AS RETURN
(
	WITH CTE_Float AS
	(
		SELECT GroupName, MonthEnd, CONVERT(FLOAT, ProfitPMD) Profit1M, CONVERT(FLOAT, TWRPMD) TWR1M, CONVERT(FLOAT, TWRReported) TWR1MReported, CONVERT(FLOAT, ContSDFPool) ContSDFPool1M, CONVERT(FLOAT, ContSDFPortfolio) ContSDFPortfolio1M, CONVERT(FLOAT, ContSDFSubPortfolio) ContSDFSubPortfolio1M, CONVERT(FLOAT, ContSDFAssetClass) ContSDFAssetClass1M
			, CONVERT(FLOAT, CapitalCallsFees) CapitalCallsFees1M, CONVERT(FLOAT, Distributions) Distributions1M
		FROM [SMC].[MonthlyPerformanceCoreGroup]
		WHERE GroupName = @GroupName AND MonthEnd BETWEEN @BeginDate AND @EndDate
	)
	, CTE_PerformanceCum AS
	(
		SELECT @GroupName GroupName, @BeginDate BeginEnd, @EndDate EndDate, 
		(DATEDIFF(MONTH, @BeginDate, @EndDate) + 1) MonthDiff,
		SUM(Profit1M) ProfitCumulative,
		EXP(SUM(IIF(ABS([TWR1M]+1)=0,0,LOG(ABS([TWR1M]+1))))) * IIF(MIN(ABS([TWR1M]+1))=0,0,1) * (1-2*(SUM(IIF([TWR1M]+1>=0,0,1)) % 2)) - 1 TWRCumulative,
		EXP(SUM(IIF(ABS([TWR1MReported]+1)=0,0,LOG(ABS([TWR1MReported]+1))))) * IIF(MIN(ABS([TWR1MReported]+1))=0,0,1) * (1-2*(SUM(IIF([TWR1MReported]+1>=0,0,1)) % 2)) - 1 TWRReportedCumulative,
		EXP(SUM(IIF(ABS([ContSDFPool1M]+1)=0,0,LOG(ABS([ContSDFPool1M]+1))))) * IIF(MIN(ABS([ContSDFPool1M]+1))=0,0,1) * (1-2*(SUM(IIF([ContSDFPool1M]+1>=0,0,1)) % 2)) - 1 ContSDFPoolCumulative,
		EXP(SUM(IIF(ABS([ContSDFPortfolio1M]+1)=0,0,LOG(ABS([ContSDFPortfolio1M]+1))))) * IIF(MIN(ABS([ContSDFPortfolio1M]+1))=0,0,1) * (1-2*(SUM(IIF([ContSDFPortfolio1M]+1>=0,0,1)) % 2)) - 1 ContSDFPortfolioCumulative,
		EXP(SUM(IIF(ABS([ContSDFSubPortfolio1M]+1)=0,0,LOG(ABS([ContSDFSubPortfolio1M]+1))))) * IIF(MIN(ABS([ContSDFSubPortfolio1M]+1))=0,0,1) * (1-2*(SUM(IIF([ContSDFSubPortfolio1M]+1>=0,0,1)) % 2)) - 1 ContSDFSubPortfolioCumulative,
		EXP(SUM(IIF(ABS([ContSDFAssetClass1M]+1)=0,0,LOG(ABS([ContSDFAssetClass1M]+1))))) * IIF(MIN(ABS([ContSDFAssetClass1M]+1))=0,0,1) * (1-2*(SUM(IIF([ContSDFAssetClass1M]+1>=0,0,1)) % 2)) - 1 ContSDFAssetClassCumulative,
		SUM(CapitalCallsFees1M) CapitalCallsFeesCumulative,
		SUM(Distributions1M) DistributionsCumulative
		FROM CTE_Float
	)
	SELECT *,
		IIF(MonthDiff > 12, SMC_DB_Reference.dbo.POWER1(1+TWRCumulative, 1, CONVERT(float, MonthDiff)/12)-1, TWRCumulative) TWRAnnualized,
		IIF(MonthDiff > 12, SMC_DB_Reference.dbo.POWER1(1+TWRReportedCumulative, 1, CONVERT(float, MonthDiff)/12)-1, TWRReportedCumulative) TWRReportedAnnualized
	FROM CTE_PerformanceCum		
)
GO

/**
-- Method 1
WITH CTE_Performance AS
(
	SELECT m.GroupName, m.MonthEnd, n.ShortDesc, n.BeginDate, n.EndDate, t.TWRCumulative, t.TWRAnnualized, t.ProfitCumulative, t.TWRReportedCumulative, t.TWRReportedAnnualized
	FROM [SMC].[MonthlyPerformanceCoreGroup] m
	CROSS APPLY SMC.ufn_GetPeriodic(m.InceptionDate, m.MonthEnd) n
	CROSS APPLY SMC.ufn_GetGroupPerformance(m.GroupName, n.BeginDate, n.EndDate) t
	WHERE m.GroupName = 'DAPER'
)
, CTE_TWR AS
(
	SELECT GroupName, MonthEnd, 
		SUM(TWRAnnualized.[1M]) [1M], SUM(TWRAnnualized.[3M]) [3M], SUM(TWRAnnualized.[1Yr]) [1Yr], SUM(TWRAnnualized.[3Yr]) [3Yr], SUM(TWRAnnualized.[5Yr]) [5Yr], SUM(TWRAnnualized.[7Yr]) [7Yr], SUM(TWRAnnualized.[10Yr]) [10Yr], SUM(TWRAnnualized.[CY]) [CY], SUM(TWRAnnualized.[JY]) [JY], SUM(TWRAnnualized.[SI]) [SI]
	FROM CTE_Performance AS SourceTable
	PIVOT
	(
		SUM(TWRAnnualized)
		FOR ShortDesc IN ([1M], [3M], [1Yr], [3Yr], [5Yr], [7Yr], [10Yr], [CY], [JY], [SI])
	) AS TWRAnnualized
	Group BY GroupName, MonthEnd
)
, CTE_Profit AS
(
	SELECT GroupName, MonthEnd, 
		SUM(ProfitCumulative.[1M]) [1M], SUM(ProfitCumulative.[3M]) [3M], SUM(ProfitCumulative.[CY]) [CY], SUM(ProfitCumulative.[JY]) [JY]
	FROM CTE_Performance AS SourceTable
	PIVOT
	(	SUM(ProfitCumulative)
		FOR ShortDesc IN ([1M], [3M], [CY], [JY])
	) AS ProfitCumulative
	Group BY GroupName, MonthEnd
)
Select TWR.GroupName, TWR.MonthEnd, TWR.[1M], TWR.[3M], TWR.[1Yr], TWR.[3Yr], TWR.[5Yr], TWR.[7Yr], TWR.[10Yr], TWR.[CY], TWR.[JY], TWR.[SI], Profit.[1M], Profit.[3M], Profit.[CY], Profit.[JY]
From CTE_TWR TWR 
	INNER JOIN CTE_Profit Profit
	ON TWR.GroupName = Profit.GroupName AND TWR.MonthEnd = Profit.MonthEnd

-- Method 2
WITH CTE_Performance AS
(
	SELECT m.GroupName, m.MonthEnd, n.ShortDesc, n.BeginDate, n.EndDate, CONVERT(float, t.TWRCumulative) TWRCumulative, CONVERT(float, t.TWRAnnualized) TWRAnnualized, CONVERT(float, t.ProfitCumulative) ProfitCumulative, CONVERT(float, t.TWRReportedCumulative) TWRReportedCumulative, CONVERT(float, t.TWRReportedAnnualized) TWRReportedAnnualized, t.ContSDFPoolCumulative, t.ContSDFPortfolioCumulative, t.ContSDFSubPortfolioCumulative, t.ContSDFAssetClassCumulative
	FROM [SMC].[MonthlyPerformanceCoreGroup] m
	CROSS APPLY SMC.ufn_GetPeriodic(m.InceptionDate, m.MonthEnd) n
	CROSS APPLY SMC.ufn_GetGroupPerformance(m.GroupName, n.BeginDate, n.EndDate) t
	WHERE m.GroupName = 'DAPER'
)
, CTE_UnPivot AS
(
	SELECT GroupName, MonthEnd, PerformanceCol + '_' + ShortDesc PerformanceCol, PerformanceVal
	FROM CTE_Performance src
	UNPIVOT (
		PerformanceVal
		for PerformanceCol in (TWRCumulative, TWRAnnualized, ProfitCumulative, TWRReportedCumulative, TWRReportedAnnualized, ContSDFPoolCumulative, ContSDFPortfolioCumulative, ContSDFSubPortfolioCumulative, ContSDFAssetClassCumulative)
	) unpiv
)
SELECT GroupName, MonthEnd, 
	[ProfitCumulative_1M],
	[ProfitCumulative_3M],
	[ProfitCumulative_1Yr],
	[ProfitCumulative_3Yr],
	[ProfitCumulative_5Yr],
	[ProfitCumulative_7Yr],
	[ProfitCumulative_10Yr],
	[ProfitCumulative_CY],
	[ProfitCumulative_JY],
	[ProfitCumulative_SI],
	[TWRAnnualized_1M],
	[TWRAnnualized_3M],
	[TWRAnnualized_1Yr],
	[TWRAnnualized_3Yr],
	[TWRAnnualized_5Yr],
	[TWRAnnualized_7Yr],
	[TWRAnnualized_10Yr],
	[TWRAnnualized_CY],
	[TWRAnnualized_JY],
	[TWRAnnualized_SI],
	[TWRCumulative_1M],
	[TWRCumulative_3M],
	[TWRCumulative_1Yr],
	[TWRCumulative_3Yr],
	[TWRCumulative_5Yr],
	[TWRCumulative_7Yr],
	[TWRCumulative_10Yr],
	[TWRCumulative_CY],
	[TWRCumulative_JY],
	[TWRCumulative_SI],
	[TWRReportedAnnualized_1M],
	[TWRReportedAnnualized_3M],
	[TWRReportedAnnualized_1Yr],
	[TWRReportedAnnualized_3Yr],
	[TWRReportedAnnualized_5Yr],
	[TWRReportedAnnualized_7Yr],
	[TWRReportedAnnualized_10Yr],
	[TWRReportedAnnualized_CY],
	[TWRReportedAnnualized_JY],
	[TWRReportedAnnualized_SI],
	[TWRReportedCumulative_1M],
	[TWRReportedCumulative_3M],
	[TWRReportedCumulative_1Yr],
	[TWRReportedCumulative_3Yr],
	[TWRReportedCumulative_5Yr],
	[TWRReportedCumulative_7Yr],
	[TWRReportedCumulative_10Yr],
	[TWRReportedCumulative_CY],
	[TWRReportedCumulative_JY],
	[TWRReportedCumulative_SI],    
	[ContSDFPoolCumulative_1M],
	[ContSDFPoolCumulative_3M],
	[ContSDFPoolCumulative_1Yr],
	[ContSDFPoolCumulative_CY],
	[ContSDFPortfolioCumulative_1M],
	[ContSDFPortfolioCumulative_3M],
	[ContSDFPortfolioCumulative_1Yr],
	[ContSDFPortfolioCumulative_CY],
	[ContSDFSubPortfolioCumulative_1M],
	[ContSDFSubPortfolioCumulative_3M],
	[ContSDFSubPortfolioCumulative_1Yr],
	[ContSDFSubPortfolioCumulative_CY],
	[ContSDFAssetClassCumulative_1M],
	[ContSDFAssetClassCumulative_3M],
	[ContSDFAssetClassCumulative_1Yr],
	[ContSDFAssetClassCumulative_CY]

FROM CTE_UnPivot s
PIVOT
(
  SUM(PerformanceVal)
  FOR PerformanceCol in (
	[ProfitCumulative_1M],
	[ProfitCumulative_3M],
	[ProfitCumulative_1Yr],
	[ProfitCumulative_3Yr],
	[ProfitCumulative_5Yr],
	[ProfitCumulative_7Yr],
	[ProfitCumulative_10Yr],
	[ProfitCumulative_CY],
	[ProfitCumulative_JY],
	[ProfitCumulative_SI],
	[TWRAnnualized_1M],
	[TWRAnnualized_3M],
	[TWRAnnualized_1Yr],
	[TWRAnnualized_3Yr],
	[TWRAnnualized_5Yr],
	[TWRAnnualized_7Yr],
	[TWRAnnualized_10Yr],
	[TWRAnnualized_CY],
	[TWRAnnualized_JY],
	[TWRAnnualized_SI],
	[TWRCumulative_1M],
	[TWRCumulative_3M],
	[TWRCumulative_1Yr],
	[TWRCumulative_3Yr],
	[TWRCumulative_5Yr],
	[TWRCumulative_7Yr],
	[TWRCumulative_10Yr],
	[TWRCumulative_CY],
	[TWRCumulative_JY],
	[TWRCumulative_SI],
	[TWRReportedAnnualized_1M],
	[TWRReportedAnnualized_3M],
	[TWRReportedAnnualized_1Yr],
	[TWRReportedAnnualized_3Yr],
	[TWRReportedAnnualized_5Yr],
	[TWRReportedAnnualized_7Yr],
	[TWRReportedAnnualized_10Yr],
	[TWRReportedAnnualized_CY],
	[TWRReportedAnnualized_JY],
	[TWRReportedAnnualized_SI],
	[TWRReportedCumulative_1M],
	[TWRReportedCumulative_3M],
	[TWRReportedCumulative_1Yr],
	[TWRReportedCumulative_3Yr],
	[TWRReportedCumulative_5Yr],
	[TWRReportedCumulative_7Yr],
	[TWRReportedCumulative_10Yr],
	[TWRReportedCumulative_CY],
	[TWRReportedCumulative_JY],
	[TWRReportedCumulative_SI],
	[ContSDFPoolCumulative_1M],
	[ContSDFPoolCumulative_3M],
	[ContSDFPoolCumulative_1Yr],
	[ContSDFPoolCumulative_CY],
	[ContSDFPortfolioCumulative_1M],
	[ContSDFPortfolioCumulative_3M],
	[ContSDFPortfolioCumulative_1Yr],
	[ContSDFPortfolioCumulative_CY],
	[ContSDFSubPortfolioCumulative_1M],
	[ContSDFSubPortfolioCumulative_3M],
	[ContSDFSubPortfolioCumulative_1Yr],
	[ContSDFSubPortfolioCumulative_CY],
	[ContSDFAssetClassCumulative_1M],
	[ContSDFAssetClassCumulative_3M],
	[ContSDFAssetClassCumulative_1Yr],
	[ContSDFAssetClassCumulative_CY]	    
  )
) piv
ORDER BY MonthEnd

**/
   