/*
-- =============================================
-- Author:		Daniel Pan
-- Create date: 02/02/2015
-- Description:	Return a list of PI Reported Valuation from Private I. (SDF Account Only.)
-- 
-- Change History:
-- Date			Developer		Description
-- 1/26/16		John			Added 3 Naming columns to match those on the CD side
   1/26/2016	John			Added Investment AS CompanyName,''	AS [MellonAccountName],A.[FundingType] AS [MellonDescription] 
								as we require a Company NAme on all rows and these will provide a value for Orphaned Rows

-- Command:

select * FROM [SMC_DB_PrivateI].[dbo].[ReportedAndAdjustedValuationHistory]
where [Investment] is null

-- Select * from [PI].[vw_Valuations]
-- =============================================
*/

USE [SMC_DB_Performance]
GO

--/*
IF object_id(N'PI.vw_Valuations', 'V') IS NOT NULL
	DROP VIEW PI.vw_Valuations
GO

CREATE VIEW [PI].[vw_Valuations]
AS 
--*/

-- SDF Reported Valuation
SELECT 
	y.DataSource
	,EOMONTH(x.[Valuation Date]) AsOfDate
	,y.AccountNumber
	,CONVERT(NVARCHAR, x.[LinkIDInvestment]) SecurityID
	,x.[Valuation Date] ReportedDate
	,CONVERT(DECIMAL(18,2), REPLACE(REPLACE([Reported Valuation], 'N/A', ''), ',', '')) ReportedMktVal
	,x.SMCLoadDate
	,x.[Investment] CompanyName
	,X.[Investment]	AS [MellonAccountName]
	,X.[GroupBy1] AS [MellonDescription] 
	,0 as Shares
FROM [SMC_DB_PrivateI].[dbo].[ReportedAndAdjustedValuationHistory] x
	INNER JOIN [SMC_DB_Performance].[PI].[vw_InvestmentIDLookup] y	
ON x.[LinkIDInvestment] = y.InvestmentID
