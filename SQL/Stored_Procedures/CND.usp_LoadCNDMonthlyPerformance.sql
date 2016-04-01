/*
===========================================================================================
	Filename:		Portfolio_CND_usp_LoadMonthlyPerformance
	Author:			John Alton / Daniel Pan
	Create date:	11/21/2014
	Description:	This SP will insert the data for CND
	Change History:
	Date	Developer		Description
	2/4/15	John			Moved to Portfolio DB
=============================================================================================
*/

USE [SMC_DB_Performance]
GO

-- Drop stored procedure if it already exists
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'CND'
     AND SPECIFIC_NAME = N'usp_LoadCNDMonthlyPerformance' 
)
   DROP PROCEDURE CND.usp_LoadCNDMonthlyPerformance
GO

CREATE PROCEDURE CND.usp_LoadCNDMonthlyPerformance
AS

-- Delete CND accounts
DELETE [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore]
WHERE DataSource = 'CND';

-- Insert CND accounts
INSERT INTO [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore]
(	
	[DataSource]
	,[RowType]
	,[AccountNumber]
	,[SecurityID]
	,[ReportedDate]
	,[MonthEnd]
    ,[MarketValue]
    ,[ACBPmd]
	,[EAMV]
	,[BAMV]
	,[LastReportedValue]
	,[LastReportedDate]
	,[TWRPmd]
    ,[ProfitPMD]
)

SELECT

	'CND' [DataSource]
	,'R' [RowType]	
	,[AccountNumber]
	,[AccountNumber] SecurityID
	,[MonthEnd] [ReportedDate]
	,[MonthEnd]
	,[MarketValue]
	,[ACBPmd]
	,[EAMV]
	,[BAMV]
	,[MarketValue] [LastReportedValue] -- reports ISNULL(a.BAMarketValueEMD,0) ACB
	,[MonthEnd] [LastReportedDate]
	,[TWR1M] [TWRPmd] --MonthlyReturnEMD
	,[ProfitPMD]

FROM [SMC_DB_Performance].[CND].vw_MonthlyPerformance
-----------------------WHERE accountnumber = 'LSJF30110002'

-- Populate the latest full month of CND data to partial month
DECLARE @MaxMonthSDF DATE, @MaxMonthCND DATE

-- Get the last month date from Core 
SELECT @MaxMonthSDF = MAX(MonthEnd)
FROM SMC_DB_Performance.smc.MonthlyPerformanceCore

-- Get the last month date from CND
SELECT @MaxMonthCND = MAX(MonthEnd)
FROM SMC_DB_Performance.smc.MonthlyPerformanceCore
WHERE DataSource = 'CND'

-- Populate the latest full month of CND data to partial month

IF @MaxMonthSDF > @MaxMonthCND 
	INSERT INTO [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore]
	(	
		[DataSource]
		,[RowType]
		,[AccountNumber]
		,[SecurityID]
		,[ReportedDate]
		,[MonthEnd]
		,[MarketValue]
		,AcbPmd
		,[EAMV]
		,[BAMV]
		,[LastReportedValue]
		,[LastReportedDate]
		,[TWRPmd]
		,[ProfitPMD]
	)
	SELECT 
		[DataSource]
		,[RowType]
		,[AccountNumber]
		,[SecurityID]
		,[ReportedDate]
		,@MaxMonthSDF [MonthEnd]
		,[MarketValue]
		,AcbPmd
		,[EAMV]
		,[BAMV]
		,[LastReportedValue]
		,[LastReportedDate]
		,[TWRPmd]
		,[ProfitPMD]
	FROM SMC_DB_Performance.smc.MonthlyPerformanceCore
	WHERE DataSource = 'CND' AND Monthend = @MaxMonthCND





	



