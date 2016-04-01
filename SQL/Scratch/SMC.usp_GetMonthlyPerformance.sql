/*
===========================================================================================================================================
	SP				SMC.usp_GetMonthlyPerformance
	Author			John Alton
	Date			01/2016
	Description		Calculate the BAMV,MARKETVALUE,EAMV FOR EACH ROW

	EXEC SMC.usp_GetMonthlyPerformance
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
     AND SPECIFIC_NAME = N'usp_GetMonthlyPerformance' 
)
   DROP PROCEDURE SMC.usp_GetMonthlyPerformance
GO

CREATE PROCEDURE SMC.usp_GetMonthlyPerformance
AS
--*/

DECLARE @AccountNumber VARCHAR(30),@SecurityID VARCHAR(30)
set @AccountNumber = 'LSJF70730002';set @SecurityID = '30992'; 

SELECT	ROW_NUMBER() OVER(ORDER BY AccountNumber,SecurityID,MonthStart) AS ID
		,ROW_NUMBER() OVER(PARTITION BY AccountNumber,SecurityID ORDER BY AccountNumber,SecurityID) AS AccountID
		,MonthlyPerformanceCoreID
		,AccountNumber 
		,SecurityID 
		,MonthEnd		
		,RowType 
		,ISNULL(BAMV,0) BAMV
		,ISNULL(MarketValue ,0) MarketValue 
		,ISNULL(EAMV ,0) EAMV 
		,ISNULL(CashFlow,0) AS CashFlow
	FROM [SMC].[MonthlyPerformanceCore] MPC 
	--WHERE   AccountNumber = @AccountNumber AND SecurityID = @SecurityID
	ORDER BY AccountNumber,SecurityID,MonthEnd


