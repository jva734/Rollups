-- =============================================
-- Author:		Daniel Pan
-- Create date: 02/02/2015
-- Description:	Return a list of Commits from Private I. (SDF Account Only.)
-- 
-- Change History:
-- Date			Developer		Description
--
-- Command:
-- Select * from [PI].[vw_CommitsExport]
-- =============================================

USE [SMC_DB_Performance]
GO
IF object_id(N'PI.vw_CommitsExport', 'V') IS NOT NULL
	DROP VIEW PI.vw_CommitsExport
GO

CREATE VIEW [PI].[vw_CommitsExport]
AS 
-- SDF Commits
SELECT 
	y.DataSource,
	y.AccountNumber,
	x.FundSize,
	x.CommitmentAmt,
	x.AdjCommitmentAmt,
	x.VintageYear,
	z.RecallableCapitalDistributions,
	x.SMCLoadDate
FROM [SMC_DB_PrivateI].[dbo].[CommitsExport] x
	INNER JOIN [SMC_DB_Performance].[PI].[vw_InvestmentIDLookup] y	
ON x.[CommitID] = y.InvestmentID
	LEFT JOIN SMC_DB_PrivateI.dbo.UnfundedCommitmentsDetailExport z
ON x.[CommitID] = z.InvestmentID AND CONVERT(DATE, x.SMCLoadDate) = CONVERT(DATE, z.SMCLoadDate)
