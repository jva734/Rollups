-- =============================================
-- Filename:	smc_usp_MonthlyPerformanceArchive
-- Author:		John Alton 
-- Create date: 6/11/2015
-- Description:	Download the Data from MonthlyPerformance into MonthlyPerformanceArchive
--				Currently we only keep 1 days Archive
-- Change History:
-- Date			Developer		Description
-- =============================================

USE [SMC_DB_Performance]
GO

-- Drop stored procedure if it already exists
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_MonthlyPerformanceArchive' 
)
   DROP PROCEDURE SMC.usp_MonthlyPerformanceArchive
GO

CREATE PROCEDURE SMC.usp_MonthlyPerformanceArchive
AS
BEGIN

	TRUNCATE TABLE [SMC_DB_Performance].[SMC].[MonthlyPerformanceArchive];
	
	SET IDENTITY_INSERT [SMC_DB_Performance].[SMC].[MonthlyPerformanceArchive] ON;
	INSERT INTO [SMC_DB_Performance].[SMC].[MonthlyPerformanceArchive]
	(
		MonthlyPerformanceArchiveID, AccountNumber, SecurityID, ReportedDate, MonthEnd, InceptionDate, RowType, DataSource, AccountOpened, AccountClosed, BAMV, EAMV, MarketValue, ReportedPct, LastReportedValue, LastReportedDate, TWRPMD, TWREMDIR, TWR1M, TWR3M, TWR1Yr, TWR3Yr, TWR5Yr, TWR7Yr, TWR10Yr, TWRCY, TWRJY, STWR, TWR1MReported, TWR3MReported, TWR1YrReported, TWRCYReported, TWRJYReported, IRR1M, IRR3M, IRR1Yr, IRR3Yr, IRR5Yr, IRR7Yr, IRR10Yr, IRRCY, IRRJY, SIRR, IRR1MReported, IRR3MReported, IRR1YrReported, IRR3YrReported, IRR5YrReported, IRR7YrReported, IRR10YrReported, IRRCYReported, IRRJYReported, SIRRReported, MultipleDPI, MultipleRPI, MultipleTVPI, ACBPMD, ACBEMDIR, ACBReported, Allocation, CashFlow, ProfitPMD, ProfitEMDIR, Profit1M, Profit3M, ProfitCY, ProfitJY, ProfitReported, ContSDFPool1M, ContSDFPortfolio1M, ContSDFSubPortfolio1M, ContSDFAssetClass1M, ContSDFPool3M, ContSDFPortfolio3M, ContSDFSubPortfolio3M, ContSDFAssetClass3M, ContSDFPoolCY, ContSDFPortfolioCY, ContSDFSubPortfolioCY, ContSDFAssetClassCY, ContSDFPool1Yr, ContSDFPortfolio1Yr, ContSDFSubPortfolio1Yr, ContSDFAssetClass1Yr, AllocSDFPool, AllocSDFPortfolio, AllocSDFSubPortfolio, AllocSDFAssetClass, Commitment, AdjCommitment, UnfundedCommitment, EAMVUnfundedCommitment, FundSize, VintageYear, WgtAvgPool, WgtAvgAssetClass, WgtAvgPortfolio, WgtAvgSubPortfolio, AdditionalFees, CapitalCalls, Distributions1M, Distributions3M, Distributions1Yr, DistributionsQTD, DistributionsYTD, DistributionsSI, CapitalCallsFeesFirst, CapitalCallsFeesLast, CapitalCallsFees1M, CapitalCallsFees3M, CapitalCallsFees1Yr, CapitalCallsFeesQ1Prev, CapitalCallsFeesQ2Prev, CapitalCallsFeesQ3Prev, CapitalCallsFeesQ4Prev, CapitalCallsFeesQTD, CapitalCallsFeesYTD, CapitalCallsFeesSI, Ranking, SMC_LoadDate
	)

	SELECT 
	MonthlyPerformanceFundID, AccountNumber, SecurityID, ReportedDate, MonthEnd, InceptionDate, RowType, DataSource, AccountOpened, AccountClosed, BAMV, EAMV, MarketValue, ReportedPct, LastReportedValue, LastReportedDate, TWRPMD, TWREMDIR, TWR1M, TWR3M, TWR1Yr, TWR3Yr, TWR5Yr, TWR7Yr, TWR10Yr, TWRCY, TWRJY, STWR, TWR1MReported, TWR3MReported, TWR1YrReported, TWRCYReported, TWRJYReported, IRR1M, IRR3M, IRR1Yr, IRR3Yr, IRR5Yr, IRR7Yr, IRR10Yr, IRRCY, IRRJY, SIRR, IRR1MReported, IRR3MReported, IRR1YrReported, IRR3YrReported, IRR5YrReported, IRR7YrReported, IRR10YrReported, IRRCYReported, IRRJYReported, SIRRReported, MultipleDPI, MultipleRPI, MultipleTVPI, ACBPMD, ACBEMDIR, ACBReported, Allocation, CashFlow, ProfitPMD, ProfitEMDIR, Profit1M, Profit3M, ProfitCY, ProfitJY, ProfitReported, ContSDFPool1M, ContSDFPortfolio1M, ContSDFSubPortfolio1M, ContSDFAssetClass1M, ContSDFPool3M, ContSDFPortfolio3M, ContSDFSubPortfolio3M, ContSDFAssetClass3M, ContSDFPoolCY, ContSDFPortfolioCY, ContSDFSubPortfolioCY, ContSDFAssetClassCY, ContSDFPool1Yr, ContSDFPortfolio1Yr, ContSDFSubPortfolio1Yr, ContSDFAssetClass1Yr, AllocSDFPool, AllocSDFPortfolio, AllocSDFSubPortfolio, AllocSDFAssetClass, Commitment, AdjCommitment, UnfundedCommitment, EAMVUnfundedCommitment, FundSize, VintageYear, WgtAvgPool, WgtAvgAssetClass, WgtAvgPortfolio, WgtAvgSubPortfolio, AdditionalFees, CapitalCalls, Distributions1M, Distributions3M, Distributions1Yr, DistributionsQTD, DistributionsYTD, DistributionsSI, CapitalCallsFeesFirst, CapitalCallsFeesLast, CapitalCallsFees1M, CapitalCallsFees3M, CapitalCallsFees1Yr, CapitalCallsFeesQ1Prev, CapitalCallsFeesQ2Prev, CapitalCallsFeesQ3Prev, CapitalCallsFeesQ4Prev, CapitalCallsFeesQTD, CapitalCallsFeesYTD, CapitalCallsFeesSI, Ranking, SMC_LoadDate
	FROM [SMC_DB_Performance].[SMC].[MonthlyPerformanceFund]

	SET IDENTITY_INSERT [SMC_DB_Performance].[SMC].[MonthlyPerformanceArchive] OFF;


END
