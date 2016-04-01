USE [SMC_DB_Performance]
GO

/****** Object:  StoredProcedure [SMC].[usp_PMD_Calc]    Script Date: 4/1/2015 4:14:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Drop Stored Procedure 
-- =======================================================

-- Drop stored procedure if it already exists
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_TwrPmd' 
)
   DROP PROCEDURE [SMC].usp_TwrPmd
GO

CREATE PROCEDURE [SMC].usp_TwrPmd
AS

;WITH CTE_DATA AS (
	SELECT MP.[AccountNumber],MP.[SecurityID],MP.[MonthEnd],MP.RowType,ISNULL(MP.bamv,0) AS bamv,ISNULL(MP.eamv,0)  AS eamv
	,ISNULL(CF.TotalCashFlow,0) AS TotalCashFlow
	,ISNULL(CF.EAMV_CashFlowWGT,0) AS EAMV_CashFlowWGT
FROM [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore] MP
	LEFT JOIN [SMC_DB_Performance].[SMC].[CashFlow] CF
		 ON CF.AccountNumber = MP.AccountNumber 
		AND CF.SecurityID = MP.SecurityID 
		AND CF.MonthEnd	= MP.MonthEnd
--WHERE	RowType = 'R'
)
--SELECT * FROM CTE_DATA 
,CTE_ACB_PROFIT AS (
	SELECT * 
	,(EAMV - BAMV + (TotalCashFlow)) AS Profit_Calc
	,(BAMV - EAMV_CashFlowWGT) AS ACB_calc
	FROM CTE_DATA 
)
--SELECT * FROM CTE_ACB_PROFIT
,CTE_PMD AS (
	SELECT *
	,CASE WHEN ACB_calc = 0 
		THEN 0
		ELSE (Profit_Calc / ACB_calc)   
		END AS TWR_PMD_Calc
	FROM CTE_ACB_PROFIT 
)
--select * from CTE_PMD 
	UPDATE	PM
	SET		[AcbPmd]	= CAST(PMD.ACB_Calc AS FLOAT)
		   ,[ProfitPMD]	= PMD.Profit_Calc
		   ,[TWRPMD]	= PMD.TWR_PMD_Calc
		   ,[TWR_PMDEMD]= PMD.TWR_PMD_Calc
	FROM    SMC.MonthlyPerformanceCore PM
			,CTE_PMD PMD 
	WHERE PMD.AccountNumber		= PM.AccountNumber
	      AND PMD.SecurityID	= PM.SecurityID
		  AND PMD.MonthEnd		= PM.MonthEnd

--update the reported columns
UPDATE	PM
SET		AcbReported    = [AcbPmd]	
		,ProfitReported = [ProfitPMD]	
FROM    SMC.MonthlyPerformanceCore PM
--WHERE RowType = 'R'



GO

