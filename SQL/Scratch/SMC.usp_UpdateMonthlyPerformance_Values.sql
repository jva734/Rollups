/*
===========================================================================================================================================
	SP				SMC.usp_UpdateMonthlyPerformance_Values
	Author			John Alton
	Date			01/2016
	Description		Calculate the BAMV,MARKETVALUE,EAMV FOR EACH ROW

	EXEC SMC.usp_UpdateMonthlyPerformance_Values
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
     AND SPECIFIC_NAME = N'usp_UpdateMonthlyPerformance_Values' 
)
   DROP PROCEDURE SMC.usp_UpdateMonthlyPerformance_Values
GO

CREATE PROCEDURE SMC.usp_UpdateMonthlyPerformance_Values
(
	@MonthlyPerformanceCoreID int
	,@BAMV  NUMERIC(18,4)
	,@MarketValue NUMERIC(18,4)
	,@EAMV  NUMERIC(18,4)
)
AS
--*/

UPDATE [SMC].[MonthlyPerformanceCore] 
	SET MarketValue = @MarketValue
		,BAMV = @BAMV
		,EAMV = @EAMV
	WHERE MonthlyPerformanceCoreID = @MonthlyPerformanceCoreID
