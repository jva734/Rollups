 UPDATE SMC.MonthlyPerformanceCore 
 SET InceptionDate = NULL
 --WHERE DataSource IN ('CD','PI')
 
;WITH CTE_InceptionValuations AS (
	SELECT	 AccountNumber
			,SecurityID
			,MIN(ReportedDate) AS InceptionDate			
	FROM SMC.vw_Valuations
	GROUP BY AccountNumber,SecurityID
)
,CTE_InceptionTransactions AS (
	SELECT	 AccountNumber
			,SecurityID
			,MIN(TransactionDate) InceptionDate			
	FROM SMC.Transactions T
    GROUP BY AccountNumber,SecurityID
)
,CTE_InceptionVT AS (
SELECT A.AccountNumber
		,A.SecurityID
		,T.InceptionDate
FROM CTE_InceptionValuations  A
	JOIN CTE_InceptionTransactions T ON A.AccountNumber = T.AccountNumber and A.SecurityID = T.SecurityID
WHERE A.InceptionDate = '1900-01-01'
)
,CTE_Inceptionp_myrly_LSJG0036 AS (
	SELECT 	 x.AccountNumber
			,x.AccountNumber SecurityID
		, MIN(x.monthend) InceptionDate
	FROM [SMC_DB_Mellon].[dbo].[p_myrly_LSJG0036] x
		INNER JOIN SMC_DB_Performance.SMC.MonthlyPerformanceCore y
		ON x.AccountNumber = y.AccountNumber
	WHERE y.DataSource = 'CND'
    GROUP BY x.AccountNumber
)
,CTE_Inception AS (
SELECT	 AccountNumber,SecurityID,InceptionDate FROM CTE_InceptionTransactions
	UNION ALL
SELECT	 AccountNumber,SecurityID,InceptionDate FROM CTE_InceptionVT
	UNION ALL
SELECT	 AccountNumber,SecurityID,InceptionDate FROM CTE_Inceptionp_myrly_LSJG0036
)
UPDATE MPC
	SET MPC.InceptionDate = CTE_I.InceptionDate
	FROM SMC.MonthlyPerformanceCore MPC INNER JOIN CTE_Inception CTE_I
		ON MPC.AccountNumber = CTE_I.AccountNumber AND MPC.SecurityID = CTE_I.SecurityID

;WITH CTE_NULLS AS (
SELECT AccountNumber,SecurityID, DATASOURCE, RowType
FROM SMC.MonthlyPerformanceCore MPC 
WHERE InceptionDate IS NULL
)
,CTE_V AS (
SELECT	 A.AccountNumber,A.SecurityID
		,MIN(T.ReportedDate) AS InceptionDate
FROM CTE_NULLS A
	JOIN SMC.vw_Valuations T on A.[AccountNumber] = T.[AccountNumber] and A.SecurityID = T.SecurityID 
	GROUP BY A.AccountNumber,A.SecurityID
)
UPDATE MPC
	SET MPC.InceptionDate = CTE_I.InceptionDate
	FROM SMC.MonthlyPerformanceCore MPC INNER JOIN CTE_V CTE_I
		ON MPC.AccountNumber = CTE_I.AccountNumber AND MPC.SecurityID = CTE_I.SecurityID


;WITH CTE_X as (
SELECT	 A.AccountNumber
		,A.SecurityID
		,t.TransactionDate
FROM smc.vw_Valuations A
join smc.Transactions  T on  A.AccountNumber = t.AccountNumber and A.SecurityID = t.SecurityID
WHERE a. ReportedDate = '1900-01-01'
)
, CTE_Y as (
SELECT	 X.AccountNumber
		,X.SecurityID
		,min(X.TransactionDate) as InceptionDate
FROM CTE_X X
group by X.AccountNumber,X.SecurityID
)
--SELECT * FROM  CTE_Y 
UPDATE MPC
	SET MPC.InceptionDate = Y.InceptionDate
	FROM CTE_Y Y INNER JOIN SMC.MonthlyPerformanceCore MPC 
		ON MPC.AccountNumber = Y.AccountNumber AND MPC.SecurityID = Y.SecurityID

SELECT  AccountNumber
		,SecurityID
FROM SMC.MonthlyPerformanceCore MPC 
WHERE INCEPTIONDATE = '1900-01-01'
GROUP BY AccountNumber,SecurityID



select * from CTE_X 

SELECT * FROM CTE_V

--,CTE_T AS (
--SELECT	 T.AccountNumber
--			,T.SecurityID
--			,T.TransactionDate
--	FROM CTE_NULLS A
--	JOIN SMC.Transactions T on A.[AccountNumber] = T.[AccountNumber] and A.SecurityID = T.SecurityID 
--)


SELECT * FROM CTE_Inception
WHERE InceptionDate = '1900-01-01'
ORDER BY AccountNumber,SecurityID,InceptionDate 

,CTE_InceptionTransactions AS (
	SELECT	 AccountNumber
			,SecurityID
			,MIN(TransactionDate) InceptionDate			
	FROM SMC.Transactions T
    GROUP BY AccountNumber,SecurityID
)
,CTE_Inception AS (
SELECT	 AccountNumber,SecurityID,InceptionDate FROM CTE_InceptionValuations
	UNION ALL
SELECT	 AccountNumber,SecurityID,InceptionDate FROM CTE_InceptionTransactions
	UNION ALL
SELECT	 AccountNumber,SecurityID,InceptionDate FROM CTE_Inceptionp_myrly_LSJG0036
)
,CTE_InceptionDate AS (
SELECT	 AccountNumber	,SecurityID	,MIN(InceptionDate) AS InceptionDate 
--SELECT	 AccountNumber	,SecurityID	,InceptionDate 
	FROM CTE_InceptionValuations
	GROUP BY AccountNumber,SecurityID
)
SELECT * FROM CTE_InceptionDate 

WHERE InceptionDate = '2999-12-31'


ORDER BY InceptionDate DESC





FROM CTE_InceptionB A
WHERE A.InceptionDate = '2999-12-31'

	join smc.Transactions T on A.[AccountNumber] = T.[AccountNumber] and A.SecurityID = T.SecurityID 
WHERE A.InceptionDate = '2999-12-31'




,CTE_InceptionC AS (
	
	SELECT	2 src,AccountNumber
			,SecurityID
			,MIN(TransactionDate) InceptionDate			
	FROM SMC.Transactions T
    GROUP BY AccountNumber,SecurityID
	
	--UNION ALL
	
	--SELECT	AccountNumber
	--		,SecurityID
	--		,MIN(ReportedDate) InceptionDate			
	--FROM SMC.MonthlyPerformanceCore 
 --   GROUP BY AccountNumber,SecurityID

	UNION ALL
	-- CND
	SELECT 3 src
			,x.AccountNumber
			,x.AccountNumber SecurityID
		, MIN(x.monthend) InceptionDate
	FROM [SMC_DB_Mellon].[dbo].[p_myrly_LSJG0036] x
		INNER JOIN SMC_DB_Performance.SMC.MonthlyPerformanceCore y
		ON x.AccountNumber = y.AccountNumber
	WHERE y.DataSource = 'CND'
    GROUP BY x.AccountNumber
)
, CTE_Inception AS (
	SELECT	src,AccountNumber
			,SecurityID
			,MIN(InceptionDate) InceptionDate			
	FROM CTE_InceptionB
    GROUP BY src,AccountNumber,SecurityID
)
SELECT * FROM CTE_Inception A
	join smc.Transactions T on A.[AccountNumber] = T.[AccountNumber] and A.SecurityID = T.SecurityID 
WHERE A.InceptionDate = '2999-12-31'


'1900-01-01'


UPDATE MPC
SET MPC.InceptionDate = CTE_I.InceptionDate
FROM SMC.MonthlyPerformanceCore MPC
	INNER JOIN CTE_Inception CTE_I
	ON MPC.AccountNumber = CTE_I.AccountNumber AND MPC.SecurityID = CTE_I.SecurityID


	================================
	
;WITH CTE_NULL AS (
SELECT AccountNumber,SecurityID
FROM [SMC].[MonthlyPerformanceCore] MPC
WHERE DATASOURCE = 'CD' AND MPC.CompanyName IS NULL
GROUP BY AccountNumber,SecurityID
)
SELECT	MPC.AccountNumber
		,MPC.SecurityID
		,MPC.DataSource
		,MPC.MonthEnd
		,MPC.CompanyName
		,MPC.MellonAccountName 
		,MPC.PortfolioType 
		,MPC.SubPortfolioType 
		,MPC.Sector 
		,MPC.SubSector 
		,MPC.Series 
		,MPC.SecurityStatus 
		,MPC.InvestmentClassification 
		,MPC.MellonDescription 
		,MPC.SponsorName 
		,MPC.FirmName 
FROM CTE_NULL A 
	JOIN [SMC].[MonthlyPerformanceCore] MPC ON A.AccountNumber = MPC.AccountNumber AND A.SecurityID = MPC.SecurityID
ORDER BY A.AccountNumber,A.SecurityID

/*
LSJF30020002	006994107
*/
SELECT [AccountNumber]  FROM [SMC].[MonthlyPerformanceCore] 
WHERE DATASOURCE = 'CD' AND CompanyName IS NULL
GROUP BY [AccountNumber]  


SELECT ',' + '''' + SecurityID + '''' FROM [SMC].[MonthlyPerformanceCore] 
WHERE DATASOURCE = 'CD' AND CompanyName IS NULL
GROUP BY SecurityID


WHERE [AccountNumber] = 'LSJF30020002' and SecurityID = '006994107'
ORDER BY MonthEnd


SELECT * FROM smc.Transactions 
WHERE 
--[AccountNumber] = 'LSJF86020002' and SecurityID = '999J11827'
[AccountNumber] = 'LSJF30020002' and SecurityID = '996098760'

SELECT * FROM smc.vw_Valuations
WHERE 
[AccountNumber] = 'LSJF30020002' and SecurityID = '996098760'

--[AccountNumber] = 'LSJF30020002' and SecurityID = '457669208'


SELECT A.AccountNumber,A.SecurityID, ReportedDate,t.AccountNumber,t.SecurityID, t.TransactionDate
FROM smc.vw_Valuations A
join smc.Transactions  T on  A.AccountNumber = t.AccountNumber and A.SecurityID = t.SecurityID
WHERE a. ReportedDate = '1900-01-01'


