-- =============================================
-- Author:		Daniel Pan/John Alton
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
--/*debug only
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_FundContribution' 
)
   DROP PROCEDURE SMC.usp_FundContribution
GO

CREATE PROCEDURE SMC.usp_FundContribution
AS


/*
	Update Contribution
*/

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

GO

