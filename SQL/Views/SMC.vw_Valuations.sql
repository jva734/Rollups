
/*==========================================================================================================================================
	View			SMC.vw_Valuations
	Author			John Alton/Daniel Pan
	Date			2/2/2015
	Description		This view will perform a union between the CD data and the PI data to deliver data as a single conbined valuations data
==========================================================================================================================================*/
USE [SMC_DB_Performance]
GO

--/*
IF object_id(N'SMC.vw_Valuations', 'V') IS NOT NULL
	DROP VIEW SMC.vw_Valuations
GO

CREATE VIEW SMC.vw_Valuations
AS
--*/

SELECT
	DataSource
	,AsOfDate	
	,AccountNumber	
	,SecurityID
	,ReportedDate	
	,ReportedMktVal
	,SMCLoadDate	
	,[CompanyName]
	,[MellonAccountName]
	,[MellonDescription] 	
	,Shares
FROM CD.vw_Valuations	

UNION ALL

SELECT
	DataSource
	,AsOfDate	
	,AccountNumber	
	,SecurityID
	,ReportedDate	
	,ReportedMktVal
	,SMCLoadDate	
	,[CompanyName]
	,[MellonAccountName]
	,[MellonDescription] 
	,Shares
FROM PI.vw_Valuations	




