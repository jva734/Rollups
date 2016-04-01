-- =============================================
-- Author:		Daniel Pan
-- Create date: 07/31/2015
-- Description:	Calculate Fund TWR based on provided date range
-- 
-- SELECT * FROM SMC.ufn_GetFundPerformance('Absolute Return', n.BeginDate, n.EndDate) 
-- =============================================

--================================================
-- Drop function template
--================================================
USE [SMC_DB_Performance]
GO

IF OBJECT_ID (N'SMC.ufn_GetFundPerformance') IS NOT NULL
   DROP FUNCTION SMC.ufn_GetFundPerformance
GO

CREATE FUNCTION SMC.ufn_GetFundPerformance(@AccountNumber VARCHAR(25), @SecurityID VARCHAR(25), @BeginDate DATE, @EndDate DATE)  RETURNS TABLE AS RETURN
(
	WITH CTE_PerformanceCum AS
	(
		SELECT @AccountNumber AccountNumber, @SecurityID SecurityID, @BeginDate BeginEnd, @EndDate EndDate, 
		(DATEDIFF(MONTH, @BeginDate, @EndDate) + 1) MonthDiff,
		SUM(ProfitPMD) ProfitCumulative,
		EXP(SUM(IIF(ABS([TWRPMD]+1)=0,0,LOG(ABS([TWRPMD]+1))))) * IIF(MIN(ABS([TWRPMD]+1))=0,0,1) * (1-2*(SUM(IIF([TWRPMD]+1>=0,0,1)) % 2)) - 1 TWRCumulative,
		EXP(SUM(IIF(ABS([TWRReported]+1)=0,0,LOG(ABS([TWRReported]+1))))) * IIF(MIN(ABS([TWRReported]+1))=0,0,1) * (1-2*(SUM(IIF([TWRReported]+1>=0,0,1)) % 2)) - 1 TWRReportedCumulative,
		EXP(SUM(IIF(ABS([ContSDFPool]+1)=0,0,LOG(ABS([ContSDFPool]+1))))) * IIF(MIN(ABS([ContSDFPool]+1))=0,0,1) * (1-2*(SUM(IIF([ContSDFPool]+1>=0,0,1)) % 2)) - 1 ContSDFPoolCumulative,
		EXP(SUM(IIF(ABS([ContSDFPortfolio]+1)=0,0,LOG(ABS([ContSDFPortfolio]+1))))) * IIF(MIN(ABS([ContSDFPortfolio]+1))=0,0,1) * (1-2*(SUM(IIF([ContSDFPortfolio]+1>=0,0,1)) % 2)) - 1 ContSDFPortfolioCumulative,
		EXP(SUM(IIF(ABS([ContSDFSubPortfolio]+1)=0,0,LOG(ABS([ContSDFSubPortfolio]+1))))) * IIF(MIN(ABS([ContSDFSubPortfolio]+1))=0,0,1) * (1-2*(SUM(IIF([ContSDFSubPortfolio]+1>=0,0,1)) % 2)) - 1 ContSDFSubPortfolioCumulative,
		EXP(SUM(IIF(ABS([ContSDFAssetClass]+1)=0,0,LOG(ABS([ContSDFAssetClass]+1))))) * IIF(MIN(ABS([ContSDFAssetClass]+1))=0,0,1) * (1-2*(SUM(IIF([ContSDFAssetClass]+1>=0,0,1)) % 2)) - 1 ContSDFAssetClassCumulative,
		SUM(CapitalCallsFees) CapitalCallsFeesCumulative,
		SUM(Distributions) DistributionsCumulative
		FROM [SMC].[MonthlyPerformanceCore]
		WHERE AccountNumber = @AccountNumber AND SecurityID = @SecurityID AND MonthEnd BETWEEN @BeginDate AND @EndDate
	)
	SELECT *,
		IIF(MonthDiff > 12, SMC_DB_Reference.dbo.POWER1(1+TWRCumulative, 1, CONVERT(float, MonthDiff)/12)-1, TWRCumulative) TWRAnnualized
		,IIF(MonthDiff > 12, SMC_DB_Reference.dbo.POWER1(1+TWRReportedCumulative, 1, CONVERT(float, MonthDiff)/12)-1, TWRReportedCumulative) TWRReportedAnnualized
	FROM CTE_PerformanceCum		
)
GO

/**
-- Prepare Core table for coding re-written 
-- 00:00:16

DROP TABLE [SMC].[MonthlyPerformanceCore];

CREATE TABLE [SMC].[MonthlyPerformanceCore](
	[MonthlyPerformanceCoreID] [INT] IDENTITY(1,1) NOT NULL,
	[AccountNumber] [VARCHAR](25) NULL,
	[SecurityID] [VARCHAR](25) NULL,
	[MonthStart] [DATE] NULL,
	[StartAdjustedValuesDate] [DATE] NULL,
	[ReportedDate] [DATE] NULL,
	[MonthEnd] [DATE] NULL,
	[InceptionDate] [DATE] NULL,
	[NextMonthStart] [DATE] NULL,
	[NextReportedDate] [DATE] NULL,
	[RowType] [VARCHAR](5) NULL,
	[DataSource] [VARCHAR](10) NULL,
	[AccountOpened] [DATE] NULL,
	[AccountClosed] [DATE] NULL,
	[MarketValue] [NUMERIC](18, 6) NULL,
	[BAMV] [DECIMAL](18, 4) NULL,
	[EAMV] [DECIMAL](18, 4) NULL,
	[MVReported] [DECIMAL](18, 4) NULL,
	[ReportedPct] [NUMERIC](18, 6) NULL,
	[LastReportedValue] [DECIMAL](18, 4) NULL,
	[LastReportedDate] [DATE] NULL,
	[AcbReported] [NUMERIC](18, 2) NULL,
	[Allocation] [NUMERIC](18, 6) NULL,
	[ProfitPmd] [FLOAT] NULL,
	[ProfitReported] [FLOAT] NULL,
	[TWRPmd] [FLOAT] NULL,
	[TWRReported] [FLOAT] NULL,
	[TwrEmdIr] [FLOAT] NULL,
	[AcbPmd] [NUMERIC](18, 4) NULL,
	[AcbEmdIr] [NUMERIC](18, 4) NULL,
	[ProfitEmdIr] [NUMERIC](18, 4) NULL,
	[MultipleDpi] [NUMERIC](18, 6) NULL,
	[MultipleRpi] [NUMERIC](18, 6) NULL,
	[MultipleTvpi] [NUMERIC](18, 6) NULL,
	[CashFlow] [NUMERIC](18, 6) NULL,

	[ContSDFPool] [FLOAT] NULL,
	[ContSDFPortfolio] [FLOAT] NULL,
	[ContSDFSubPortfolio] [FLOAT] NULL,
	[ContSDFAssetClass] [FLOAT] NULL,

	[AllocSDFPool] [FLOAT] NULL,
	[AllocSDFAssetClass] [FLOAT] NULL,
	[AllocSDFPortfolio] [FLOAT] NULL,
	[AllocSDFSubPortfolio] [FLOAT] NULL,

	[Distributions] [FLOAT] NULL,
	[CapitalCalls] [NUMERIC](18, 4) NULL,
	[AdditionalFees] [NUMERIC](18, 4) NULL,
	[CapitalCallsFees] [FLOAT] NULL,
	[CapitalCallsFeesLast] [NUMERIC](18, 6) NULL,
	[CapitalCallsFeesFirst] [NUMERIC](18, 6) NULL,
	[Commitment] [NUMERIC](18, 4) NULL,
	[AdjCommitment] [NUMERIC](18, 4) NULL,
	[UnFundedCommitment] [NUMERIC](18, 6) NULL,
	[EAMVUnFundedCommitment] [NUMERIC](18, 6) NULL,
	[FundSize] [NUMERIC](18, 6) NULL,
	[VintageYear] [INT] NULL,

	[IRR1M] [FLOAT] NULL,
	[IRR3M] [FLOAT] NULL,
	[IRR1Yr] [FLOAT] NULL,
	[IRR3Yr] [FLOAT] NULL,
	[IRR5Yr] [FLOAT] NULL,
	[IRR7Yr] [FLOAT] NULL,
	[IRR10Yr] [FLOAT] NULL,
	[IRRCY] [FLOAT] NULL,
	[IRRJY] [FLOAT] NULL,
	[SIRR] [FLOAT] NULL,
	[IRR1MReported] [FLOAT] NULL,
	[IRR3MReported] [FLOAT] NULL,
	[IRR1YrReported] [FLOAT] NULL,
	[IRR3YrReported] [FLOAT] NULL,
	[IRR5YrReported] [FLOAT] NULL,
	[IRR7YrReported] [FLOAT] NULL,
	[IRR10YrReported] [FLOAT] NULL,
	[IRRCYReported] [FLOAT] NULL,
	[IRRJYReported] [FLOAT] NULL,
	[SIRRReported] [FLOAT] NULL,

	[FileName] [VARCHAR](100) NULL,
	[SMCLoadDT] [DATETIME] NULL
) ON [PRIMARY]

GO


-- Populate MonthlyPerformanceCore
TRUNCATE TABLE [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore];

INSERT INTO [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore] ([AccountNumber]
      ,[SecurityID]
      ,[MonthStart]
      ,[StartAdjustedValuesDate]
      ,[ReportedDate]
      ,[MonthEnd]
	  ,[InceptionDate]
      ,[NextMonthStart]
      ,[NextReportedDate]
      ,[RowType]
      ,[DataSource]
      ,[AccountOpened]
      ,[AccountClosed]
      ,[MarketValue]
      ,[BAMV]
      ,[EAMV]
      ,[ReportedPct]
      ,[LastReportedValue]
      ,[LastReportedDate]
      ,[AcbReported]
      ,[Allocation]
      ,[ProfitPmd]
      ,[ProfitReported]
      ,[TWRPmd]
      ,[TWRReported]
      ,[TwrEmdIr]
      ,[AcbPmd]
      ,[AcbEmdIr]
      ,[ProfitEmdIr]
      ,[MultipleDpi]
      ,[MultipleRpi]
      ,[MultipleTvpi]
      ,[CashFlow]
      ,[Distributions]

      ,[CapitalCalls]
      ,[AdditionalFees]
      ,[CapitalCallsFees]
      ,[CapitalCallsFeesLast]
      ,[CapitalCallsFeesFirst]
      ,[UnFundedCommitment]
      ,[EAMVUnFundedCommitment]
	  ,IRR1M, IRR3M, IRR1Yr, IRR3Yr, IRR5Yr, IRR7Yr, IRR10Yr, IRRCY, IRRJY, SIRR, IRR1MReported, IRR3MReported, IRR1YrReported, IRR3YrReported, IRR5YrReported, IRR7YrReported, IRR10YrReported, IRRCYReported, IRRJYReported, SIRRReported
      ,[FileName]
      ,[SMCLoadDT])
SELECT [AccountNumber]
      ,[SecurityID]
      ,[MonthStart]
      ,[StartAdjustedValuesDate]
      ,[ReportedDate]
      ,[MonthEnd]
	  ,NULL InceptionDate
      ,[NextMonthStart]
      ,[NextReportedDate]
      ,[RowType]
      ,[DataSource]
      ,[AccountOpened]
      ,[AccountClosed]
      ,[MarketValue]
      ,[BAMV]
      ,[EAMV]
      ,[ReportedPct]
      ,[LastReportedValue]
      ,[LastReportedDate]
      ,[AcbReported]
      ,[Allocation]
      ,[ProfitPmd]
      ,[ProfitReported]
      ,[TWRPmd]
      ,[TWRPmd] TWRReported
      ,[TwrEmdIr]
      ,[AcbPmd]
      ,[AcbEmdIr]
      ,[ProfitEmdIr]
      ,[MultipleDpi]
      ,[MultipleRpi]
      ,[MultipleTvpi]
      ,[CashFlow]
      ,[Distributions]
      ,[CapitalCalls]
      ,[AdditionalFees]
      ,[CapitalCallsFees1Mo] [CapitalCallsFees]
      ,[CapitalCallsFeesLast]
      ,[CapitalCallsFeesFirst]
      ,[UnFundedCommitment]
      ,[EAMVUnFundedCommitment]
	  ,IRR1M, IRR3M, IRR1Yr, IRR3Yr, IRR5Yr, IRR7Yr, IRR10Yr, IRRCY, IRRJY, SIRR, IRR1MReported, IRR3MReported, IRR1YrReported, IRR3YrReported, IRR5YrReported, IRR7YrReported, IRR10YrReported, IRRCYReported, IRRJYReported, SIRRReported
      ,[FileName]
      ,[SMCLoadDT]
  FROM [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore]

-- Update InceptionDate
;WITH CTE_Inception AS
(
	SELECT	AccountNumber
			,SecurityID
			,MIN(TransactionDate) InceptionDate			
	FROM [SMC_DB_Performance].SMC.Transactions T
    GROUP BY AccountNumber,SecurityID
	UNION ALL
	-- CND
	SELECT x.AccountNumber
			,x.AccountNumber SecurityID
		, MIN(x.monthend) InceptionDate
	FROM [SMC_DB_Mellon].[dbo].[p_myrly_LSJG0036] x
		INNER JOIN SMC_DB_Performance.SMC.MonthlyPerformanceCore y
		ON x.AccountNumber = y.AccountNumber
	WHERE y.DataSource = 'CND'
    GROUP BY x.AccountNumber
)
UPDATE x
SET x.InceptionDate = y.InceptionDate
FROM [SMC_DB_Performance].SMC.MonthlyPerformanceCore x 
	INNER JOIN CTE_Inception y
	ON x.AccountNumber = y.AccountNumber AND x.SecurityID = y.SecurityID


-- Update Contribution
;WITH CTE_Lookup AS
(
	SELECT 
		 a.*
		--,datediff(m,MIN(a.[MonthEnd]) , MAX(a.[MonthEnd]) ) as MthCount
		-- Account Grouping
		,ISNULL(c.LookupText,'') AssetClass
		,ISNULL(d.LookupText,'') Portfolio
		,ISNULL(g.LookupText,'') SubPortfolio

	FROM [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore] A 
		LEFT JOIN [SMC_DB_ASA].[asa].[Accounts] B ON a.AccountNumber	= b.AccountNumber
		LEFT JOIN [SMC_DB_ASA].[asa].Lookups	C ON b.AssetClass		= c.LookupId
		LEFT JOIN [SMC_DB_ASA].[asa].Lookups	D ON b.PortfolioType	= d.LookupId
		LEFT JOIN [SMC_DB_ASA].[asa].Lookups	G ON b.SubPortfolioType = g.LookupId
)
, CTE_Cont AS
(
	SELECT AccountNumber, SecurityID, MonthEnd
		,SUM(LastReportedValue) OVER(PARTITION BY MonthEnd) MVReported

		,CASE WHEN SUM(BAMV) OVER(PARTITION BY MonthEnd) = 0
			THEN 0
			ELSE (BAMV/SUM(BAMV) OVER(PARTITION BY MonthEnd) * [TWRPmd]) 
			END ContSDFPool
		-- Asset Class
		,CASE WHEN SUM(BAMV) OVER(PARTITION BY MonthEnd, AssetClass) = 0 
			THEN 0
			ELSE (BAMV/SUM(BAMV) OVER(PARTITION BY MonthEnd, AssetClass) * TWRPmd)
			END ContSDFAssetClass
		-- Portfolio
		,CASE WHEN SUM(BAMV) OVER(PARTITION BY MonthEnd, Portfolio) = 0
			THEN 0
			ELSE (BAMV/SUM(BAMV) OVER(PARTITION BY MonthEnd, Portfolio) * TWRPmd) 
			END ContSDFPortfolio
		-- Sub-Portfolio
		,CASE WHEN SUM(BAMV) OVER(PARTITION BY MonthEnd, SubPortfolio) = 0
			THEN 0
			ELSE (BAMV/SUM(BAMV) OVER(PARTITION BY MonthEnd, SubPortfolio) * TWRPmd) 
			END ContSDFSubPortfolio

		-- Allocation Calculation for AssetClass, Portfolio, SubPortfolio, Strategy
		-- Formula: EAMV (Fund)/EAMV (Group)
		,CASE WHEN SUM(EAMV) OVER(PARTITION BY MonthEnd) = 0
			THEN 0 
			ELSE (EAMV/SUM(EAMV) OVER(PARTITION BY MonthEnd))
			END PctEAMVPool
		,CASE WHEN SUM(EAMV) OVER(PARTITION BY MonthEnd, AssetClass) = 0
			THEN 0 
			ELSE (EAMV/SUM(EAMV) OVER(PARTITION BY MonthEnd, AssetClass))
			END PctEAMVAssetClass
		,CASE WHEN SUM(EAMV) OVER(PARTITION BY MonthEnd, Portfolio) = 0
			THEN 0
			ELSE (EAMV/SUM(EAMV) OVER(PARTITION BY MonthEnd, Portfolio)) 
			END PctEAMVPortfolio
		,CASE WHEN SUM(EAMV) OVER(PARTITION BY MonthEnd, SubPortfolio) = 0
			THEN 0
			ELSE (EAMV/SUM(EAMV) OVER(PARTITION BY MonthEnd, SubPortfolio)) 
			END PctEAMVSubPortfolio

	FROM CTE_Lookup
)

UPDATE x
	SET x.MVReported = y.MVReported
		,x.ContSDFPool = y.ContSDFPool
		,x.ContSDFAssetClass = y.ContSDFAssetClass
		,x.ContSDFPortfolio = y.ContSDFPortfolio
		,x.ContSDFSubPortfolio = y.ContSDFSubPortfolio
		,x.AllocSDFPool = y.PctEAMVPool
		,x.AllocSDFAssetClass = y.PctEAMVAssetClass
		,x.AllocSDFPortfolio = y.PctEAMVPortfolio
		,x.AllocSDFSubPortfolio = y.PctEAMVSubPortfolio
FROM CTE_Lookup x 
	INNER JOIN CTE_Cont y
	ON x.AccountNumber = y.AccountNumber AND x.SecurityId = y.SecurityID AND x.MonthEnd = y.MonthEnd

-- Update Commitment, AdjCommitment, VintageYear, FundSize
UPDATE x
SET x.VintageYear = y.VintageYear
	,x.Commitment = y.CommitmentAmt 
	,x.AdjCommitment = y.AdjCommitmentAmt
	,x.FundSize = y.FundSize
FROM [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore] x 
		INNER JOIN PI.vw_CommitsExport y 
		ON x.DataSource = y.DataSource AND x.AccountNumber = y.AccountNumber
**/
   