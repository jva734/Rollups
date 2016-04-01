USE [SMC_DB_Performance]
GO

/*
SELECT * FROM SMC.vw_MonthlyPerformanceFund
-- =============================================
-- Create View template
-- =============================================
*/

IF object_id(N'SMC.vw_MonthlyPerformanceFund', 'V') IS NOT NULL
	DROP VIEW SMC.vw_MonthlyPerformanceFund
GO

CREATE VIEW SMC.vw_MonthlyPerformanceFund

AS

SELECT * FROM SMC.MonthlyPerformanceFund