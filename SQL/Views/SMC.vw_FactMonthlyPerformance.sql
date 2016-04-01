-- =============================================
-- Author:		Daniel Pan
-- Create date: 02/26/2015
-- Description:	Combine Account Lookups with MonthlyPerformance table
-- 
-- Select * from [SMC].[vw_FactMonthlyPerformance]
-- =============================================
USE SMC_DB_Performance
GO


IF object_id(N'SMC.vw_FactMonthlyPerformance', 'V') IS NOT NULL
	DROP VIEW SMC.vw_FactMonthlyPerformance
GO

CREATE VIEW [SMC].[vw_FactMonthlyPerformance]
	AS 

WITH CTE_AccountSecurity AS
(
	SELECT a.AccountNumber, s.MellonSecurityId as SecurityId, secl.LookupText as Sector, sunsecl.LookupText SubSector, c.CompanyName
	FROM [SMC_DB_ASA].[asa].Accounts a
	  INNER JOIN [SMC_DB_ASA].[asa].[SecurityAccounts] sa
	   ON a.AccountId = sa.AccountId

	  LEFT JOIN [SMC_DB_ASA].[asa].Securities s
	   ON sa.SecurityId = s.SecurityId

	  LEFT JOIN [SMC_DB_ASA].[asa].Lookups secl
	   ON sa.Sector = secl.LookupId

	  LEFT JOIN [SMC_DB_ASA].[asa].Lookups sunsecl
	   ON sa.SubSector = sunsecl.LookupId

	  LEFT JOIN [SMC_DB_ASA].[asa].Companies c
	   ON s.CompanyId = c.CompanyId
)
, CTE_Lookup AS
(
	SELECT 
		-- Account Grouping
		ISNULL(e.LookupText,'') AccountPool
		,ISNULL(d.LookupText,'') Portfolio
		,ISNULL(g.LookupText,'') SubPortfolio
		,b.AccountVintageYear
		,ISNULL(c.LookupText,'') AssetClass
		,ISNULL(i.LookupText,'') Strategy
		,ISNULL(j.LookupText,'') SDFCrossInvestment
		,ISNULL(k.LookupText,'') Liquidity
		,ISNULL(f.LookupText,'') StructureType
		,ISNULL(m.LookupText,'') [Geography]
		,ISNULL(p.CompanyName,'') [CompanyName]
		,ISNULL(p.Sector,'') [Sector]
		,ISNULL(p.SubSector,'') [SubSector]

		--,a.[MonthlyPerformanceCoreID]
		,a.[AccountNumber]
		,a.[SecurityID]
		--,a.[StartAdjustedValuesDate]
		,a.[ReportedDate]
		,a.[MonthEnd]
		--,a.[NextReportedDate]
		,a.[RowType]
		,a.[DataSource]
		,a.[AccountOpened]
		,a.[AccountClosed]
		,a.[MarketValue]
		,a.[BAMV] [BAMarketValuePMD]

		,a.[EAMV] [EAMarketValuePMD]

		,a.[CashFlow]
		,a.[ReportedPct]
		,a.[TWRPMD]

		,a.[ACBPMD]
		,a.[ACBReported]

		,a.[ProfitPMD]
		,a.[ProfitReported]

		,a.[MultipleDPI]
		,a.[MultipleRPI]
		,a.[MultipleTVPI]

		,a.Distributions1M Distributions
		,a.CapitalCalls
		,a.AdditionalFees
		,a.CapitalCallsFees1M CapitalCallsFees
		,a.CapitalCallsFeesFirst
		,a.CapitalCallsFeesLast

		,n.[CommitmentAmt]
		,n.[AdjCommitmentAmt]
		,n.[RecallableCapitalDistributions]

		,a.UnfundedCommitment
		,a.EAMVUnfundedCommitment
	FROM [SMC].[MonthlyPerformance] a
		INNER JOIN [SMC_DB_ASA].[asa].[Accounts] b
			ON a.AccountNumber = b.AccountNumber
		LEFT JOIN [SMC_DB_ASA].asa.Lookups c
			ON b.AssetClass = c.LookupId
		LEFT JOIN [SMC_DB_ASA].asa.Lookups d
			ON b.PortfolioType = d.LookupId
		LEFT JOIN [SMC_DB_ASA].asa.Lookups e
			ON b.AccountPool = e.LookupId
		LEFT JOIN [SMC_DB_ASA].asa.Lookups f
			ON b.StructureType = f.LookupId
		LEFT JOIN [SMC_DB_ASA].asa.Lookups g
			ON b.SubPortfolioType = g.LookupId
		LEFT JOIN [SMC_DB_ASA].asa.Lookups i
			ON b.Strategy = i.LookupId
		LEFT JOIN [SMC_DB_ASA].asa.Lookups j
			ON b.SDFCrossInvestment = j.LookupId
		LEFT JOIN [SMC_DB_ASA].asa.Lookups k
			ON b.Liquidity = k.LookupId
		LEFT JOIN [SMC_DB_ASA].asa.Lookups m
			ON b.[Geography] = m.LookupId
		LEFT JOIN PI.vw_CommitsExport n
			ON a.DataSource = n.DataSource AND a.AccountNumber = n.AccountNumber
		LEFT JOIN CTE_AccountSecurity p
			ON a.AccountNumber = p.AccountNumber AND a.SecurityID = p.SecurityId
)
SELECT	*,
	SUM(ACBPMD) OVER(PARTITION BY MonthEnd) PoolTotal,
	SUM(ACBPMD) OVER(PARTITION BY MonthEnd, AssetClass) AssetClassTotal,
	SUM(ACBPMD) OVER(PARTITION BY MonthEnd, Portfolio) PortfolioTotal,
	SUM(ACBPMD) OVER(PARTITION BY MonthEnd, SubPortfolio) SubPortfolioTotal
FROM CTE_Lookup