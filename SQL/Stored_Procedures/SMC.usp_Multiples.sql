/*
===========================================================================================================================================
	Filename		
	Author			John Alton
	Date			11/04/2015
	Description		Calculate the Multiples for SDF
===========================================================================================================================================
Formula
DPI		(Cash distributions + stock distributions)/(Calls + Additional fees)
RPI		EAMV/(Calls + Additional Fees)
TVPI	(EAMV + Cash distributions + stock distributions)/(Calls + Additional fees)

Debug Code
DECLARE @Debug TABLE(BigString VARCHAR(max))
INSERT INTO @Debug (BigString ) values ('@AccountNumber=' + @AccountNumber + ' @SecurityID=' + @SecurityID )
SELECT * FROM @Debug
==========================================================================================================================================
*/
USE [SMC_DB_Performance]
GO

-- Drop stored procedure if it already exists
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_Multiples' 
)
   DROP PROCEDURE SMC.usp_Multiples
GO

CREATE PROCEDURE SMC.usp_Multiples
AS

;WITH CTE_CashFlow AS (
	SELECT
		 AccountNumber				 
		,SecurityID			
		,MonthStart	 
		,MonthEnd			 
		,SUM([TotalDistribution]) over(partition by AccountNumber, SecurityID order by MonthEnd rows between unbounded preceding and current row ) AS TotalDistribution
		,SUM(TotalCapitalCalls)  over(partition by AccountNumber, SecurityID order by MonthEnd rows between unbounded preceding and current row ) AS TotalCapitalCall
		,SUM([TotalAdditionalFees])  over(partition by AccountNumber, SecurityID order by MonthEnd rows between unbounded preceding and current row ) AS TotalAdditionalFees
	FROM [SMC].[CashFlow] C
)
--SELECT * FROM CTE_CashFlow 
,CTE_DPI AS (
SELECT *
	,CASE 
		WHEN TotalCapitalCall + TotalAdditionalFees = 0 
			THEN 0
			ELSE TotalDistribution/((TotalCapitalCall *-1) + (TotalAdditionalFees *-1))				
	END DPI
	FROM CTE_CashFlow 
)
--SELECT * FROM CTE_DPI
,CTE_EAMV AS (
SELECT A.*
		,ISNULL(B.EAMV,0) AS EAMV
	FROM CTE_DPI A
	JOIN SMC.monthlyPerformanceCore B	ON B.AccountNumber = A.AccountNumber AND B.SecurityID = A.SecurityID AND B.MonthStart = A.MonthStart
)
--SELECT * FROM CTE_EAMV ORDER BY  AccountNumber, SecurityID ,MonthEnd
,CTE_CALC AS (
	SELECT * 

	,CASE 
		WHEN EAMV = 0 
			THEN 0
		WHEN (TotalCapitalCall + TotalAdditionalFees)= 0 
			THEN 0
		ELSE EAMV / ((TotalCapitalCall *-1) + (TotalAdditionalFees *-1))				
	END RPI
	
	,CASE 
		WHEN EAMV + TotalDistribution = 0 
			THEN 0
		WHEN (TotalCapitalCall + TotalAdditionalFees)= 0 
			THEN 0
		ELSE (EAMV + TotalDistribution)/((TotalCapitalCall *-1) + (TotalAdditionalFees *-1))				
	END TVPI
FROM CTE_EAMV 
)
UPDATE MP
	SET  MP.[MultipleDpi] = A.DPI
		,MP.[MultipleRpi] = A.RPI
		,MP.[MultipleTvpi] = A.TVPI
FROM CTE_CALC A 
JOIN [SMC].[MonthlyPerformanceCore] MP ON MP.AccountNumber = A.AccountNumber AND MP.SecurityID = A.SecurityID AND MP.MonthStart = A.MonthStart

/*
--SELECT * FROM CTE_CALC  ORDER BY  AccountNumber, SecurityID ,MonthEnd
SELECT  A.*
,MP.AccountNumber , MP.SecurityID ,MP.MonthStart 
		,MP.[MultipleDpi] 
		,MP.[MultipleRpi] 
		,MP.[MultipleTvpi]
FROM CTE_CALC A 
JOIN [SMC].[MonthlyPerformanceCore] MP ON MP.AccountNumber = A.AccountNumber AND MP.SecurityID = A.SecurityID AND MP.MonthStart = A.MonthStart
 ORDER BY  A.AccountNumber, A.SecurityID ,A.MonthEnd
*/


 