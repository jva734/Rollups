/*
===========================================================================================================================================
	SP				SMC.usp_CalcMonthlyPerformance
	Author			John Alton
	Date			01/2016
	Description		Calculate the BAMV,MARKETVALUE,EAMV FOR EACH ROW

	EXEC SMC.usp_CalcMonthlyPerformance
	select count(*) from [SMC].[MonthlyPerformanceCore] --90,979
==========================================================================================================================================
*/
USE SMC_DB_Performance
GO

--/*debug only
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_CalcMonthlyPerformance' 
)
   DROP PROCEDURE SMC.usp_CalcMonthlyPerformance
GO

CREATE PROCEDURE SMC.usp_CalcMonthlyPerformance
AS
--*/

SELECT	AccountNumber 
		,SecurityID 
		,MonthEnd		
		,RowType 
		,MarketValue 
		,BAMV 
		,EAMV 
		,CashFlow
	FROM [SMC].[MonthlyPerformanceCore] MPC 
	ORDER BY AccountNumber,SecurityID,MonthEnd


