USE SMC_DB_Performance
GO
DECLARE @AccountNumber VARCHAR(30),@SecurityID VARCHAR(30)
set @AccountNumber = 'LSJF70730002';set @SecurityID = '30992'; 

;WITH CTE_First_Record AS
(      
	   SELECT MPC.AccountNumber
			 ,MPC.SecurityID
			 ,MIN(MPC.MonthEnd) MinMonthEnd
	   FROM [SMC].[MonthlyPerformanceCore] MPC 
       GROUP BY MPC.AccountNumber,MPC.SecurityID
)
,CTE_Account AS
(      -- First Record       
	   SELECT MPC.MonthlyPerformanceCoreID
				,MPC.AccountNumber
				,MPC.SecurityID
				,MPC.MonthEnd
				,MPC.RowType
				,MPC.CashFlow
				,MPC.EAMV
				,CONVERT(DECIMAL(30,4), MPC.EAMV) AS CalcEAMVPrev 
				--,CAST(MPC.EAMV AS DECIMAL(20,4)) AS CalcEAMVPrev 
				,EOMONTH(DATEADD(MONTH, 1, MPC.MonthEnd)) MonthEndNext
       FROM [SMC].[MonthlyPerformanceCore] MPC 
	    INNER JOIN CTE_First_Record y ON MPC.AccountNumber = Y.AccountNumber AND MPC.SecurityID = Y.SecurityID AND MPC.MonthEnd = Y.MinMonthEnd
       UNION ALL
       -- Rest of Records
	   	   SELECT MPC.MonthlyPerformanceCoreID
				,MPC.AccountNumber
       			,MPC.SecurityID
				,MPC.MonthEnd
				,MPC.RowType
				,MPC.CashFlow
				,MPC.EAMV
				,CASE
					WHEN MPC.RowType <> 'A' THEN MPC.EAMV
					ELSE CONVERT(DECIMAL(30,4), Y.CalcEAMVPrev - ISNULL(MPC.CashFlow,0)) 
				END AS CalcEAMVPrev 

				,EOMONTH(DATEADD(MONTH, 1, MPC.MonthEnd)) MonthEndNext
	   FROM [SMC].[MonthlyPerformanceCore] MPC 
		INNER JOIN CTE_Account y 
	          ON MPC.AccountNumber = y.AccountNumber 
			  AND MPC.SecurityID = Y.SecurityID
			  AND  MPC.MonthEnd = y.MonthEndNext
)
-- Display All Records
SELECT *
FROM CTE_Account
ORDER BY AccountNumber,SecurityID,MonthEnd
OPTION (MAXRECURSION 32767)


;WITH CTE_BAMV AS (
	SELECT 
		MonthlyPerformanceCoreID
		,LAG(EAMV,1) OVER (ORDER BY  AccountNumber,SecurityID,MonthEnd) AS LagEAMV
	FROM [SMC].[MonthlyPerformanceCore] MPC 
)
UPDATE MPC 
	SET MPC.BAMV = A.LagEAMV
		,MPC.MarketValue = MPC.EAMV
FROM [SMC].[MonthlyPerformanceCore] MPC 
	JOIN CTE_BAMV A ON A.MonthlyPerformanceCoreID = MPC.MonthlyPerformanceCoreID


	
	WHERE   AccountNumber = @AccountNumber AND SecurityID = @SecurityID

;WITH CTE_CALC_EAMV0 AS (
	SELECT 
		AccountNumber AS CurrAccountNumber
		,SecurityID   AS CurrSecurityID 
		,MonthStart AS CurrMonthStart 
		,RowType AS CurrRowType 
		,ReportedDate AS CurrReportedDate 
		,BAMV AS CurrBAMV 
		,MarketValue  AS CurrMarketValue  
		,EAMV AS CurrEAMV 
		,CashFlow AS CurrCashFlow 
		,CASE 
			WHEN  RowType <> 'A' THEN 0
			WHEN  RowType = 'A' THEN 
			COUNT(*) OVER (PARTITION BY AccountNumber,SecurityID,ReportedDate,RowType ROWS UNBOUNDED PRECEDING)
		END AdjCount
		,CASE 
			WHEN  RowType <> 'A' THEN EAMV
			else null
		END CalcEAMV
	FROM [SMC].[MonthlyPerformanceCore] MPC 
	WHERE   AccountNumber = @AccountNumber AND SecurityID = @SecurityID
)
--select * from CTE_CALC_EAMV0 ORDER BY CurrMonthStart
,CTE_CALC_EAMV1 AS (
-- Get the First Adjustment Row and link to its previous Reported Row
	SELECT  
		-- A Row
		CurrAccountNumber,CurrSecurityID ,CurrMonthStart ,CurrRowType ,CurrBAMV ,CurrEAMV ,CurrCashFlow ,AdjCount,A.CalcEAMV 
		--MPC Row
		,MPC.RowType AS PrevRowType ,MPC.EAMV  AS PrevEAMV  
		,MPC.EAMV - ISNULL(CurrCashFlow,0) AS CalcEAMV1
	FROM CTE_CALC_EAMV0 A
		JOIN [SMC].[MonthlyPerformanceCore] MPC ON MPC.AccountNumber = A.CurrAccountNumber AND MPC.SecurityID = A.CurrSecurityID 
		AND MPC.MonthEnd = DATEADD(day,-1,A.CurrMonthStart)
	WHERE A.AdjCount =1
)
--SELECT * FROM CTE_CALC_EAMV1 ORDER BY CurrAccountNumber,CurrSecurityID,CurrMonthStart
,CTE_CALC_EAMV2 AS (
-- Get the 2nd Adjustment for and link to the rist adjustment row with its calculated EAMV
	SELECT  
		A.*
  		 --A.CurrAccountNumber,A.CurrSecurityID ,A.CurrMonthStart ,A.CurrRowType ,A.CurrBAMV ,A.CurrEAMV ,A.CurrCashFlow ,A.AdjCount,A.CalcEAMV
		,B.CurrAccountNumber as AccountNumberA1
		,B.CurrSecurityID as PrevSecurityIDA1
		,B.CurrMonthStart  as PrevMonthStartA1
		,B.CalcEAMV1
		,B.CalcEAMV1 - ISNULL(A.CurrCashFlow,0) AS CalcEAMV2
		--,B.CalcEAMV1	,B.CalcEAMV1 - ISNULL(b.CurrCashFlow,0) AS CalcEAMV2
	FROM CTE_CALC_EAMV0 A
	   LEFT JOIN CTE_CALC_EAMV1 B ON A.CurrAccountNumber = B.CurrAccountNumber 		AND A.CurrSecurityID = B.CurrSecurityID 		
	   AND A.CurrMonthStart = DATEADD(M,1,B.CurrMonthStart)
	--	 JOIN [SMC].[MonthlyPerformanceCore] MPC ON MPC.AccountNumber = B.CurrAccountNumber AND MPC.SecurityID = B.CurrSecurityID AND MPC.MonthStart = B.CurrMonthStart
	WHERE A.AdjCount=2
)
--SELECT * FROM CTE_CALC_EAMV2 ORDER BY CurrAccountNumber,CurrSecurityID,CurrMonthStart
,CTE_CALC_EAMV99 AS (
SELECT CurrAccountNumber,CurrSecurityID,CurrMonthStart,CurrRowType,CurrCashFlow,CalcEAMV
FROM CTE_CALC_EAMV0 
WHERE AdjCount = 0
UNION ALL
SELECT CurrAccountNumber,CurrSecurityID,CurrMonthStart,CurrRowType,CurrCashFlow,CalcEAMV1
FROM CTE_CALC_EAMV1
UNION ALL
SELECT CurrAccountNumber,CurrSecurityID,CurrMonthStart,CurrRowType,CurrCashFlow,CalcEAMV2
FROM CTE_CALC_EAMV2
)
SELECT * FROM CTE_CALC_EAMV99
ORDER BY CurrAccountNumber,CurrSecurityID,CurrMonthStart

