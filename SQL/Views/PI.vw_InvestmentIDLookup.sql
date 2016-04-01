-- =============================================
-- Author:		Daniel Pan
-- Create date: 01/28/2015
-- Description:	Account Number to Investment ID Mapping From Private I. (SDF Account Only.)
-- 
-- Change History:
-- Date			Developer		Description
--
-- Command:
-- Select * from [PI].[vw_InvestmentIDLookup]
-- =============================================

USE [SMC_DB_Performance]
GO

IF object_id(N'PI.vw_InvestmentIDLookup', 'V') IS NOT NULL
	DROP VIEW PI.vw_InvestmentIDLookup
GO

CREATE VIEW [PI].[vw_InvestmentIDLookup]
AS 
	-- Limited to SDF Accounts from Private I Table
	SELECT DISTINCT 
		'PI' DataSource,
		r.[Account Number] AccountNumber,
		r.LinkIDInvestment AS InvestmentID,
		r.Investment
	FROM SMC_DB_PrivateI.dbo.ReportedAndAdjustedValuationHistory r
	WHERE (r.GroupBy1 = 'Separately Managed Funds'
		OR r.GroupBy1 LIKE 'Stanford Venture Pool%')
		AND r.Investment <> 'Total'
		AND ISNULL(r.[Account Number],'') <> ''

