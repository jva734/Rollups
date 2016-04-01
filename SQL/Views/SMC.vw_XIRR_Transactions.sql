/*
=============================================
	Author John Alton
	Date	Nov 2015
	Description: View to return Trnasactions with extra calculated columns

	SELECT * FROM SMC.vw_XIRR_Transactions
	WHERE [AccountNumber] = 'LSJF30000002' AND [SecurityID] = '13268'
	ORDER BY [AccountNumber],[SecurityID],TransactionDate
=============================================
*/
USE [SMC_DB_Performance]
GO

--/*
IF object_id(N'SMC.vw_XIRR_Transactions', 'V') IS NOT NULL
	DROP VIEW SMC.vw_XIRR_Transactions
GO

CREATE VIEW SMC.vw_XIRR_Transactions
AS
--*/

WITH CTE_Data1 AS (
SELECT
	[AccountNumber]
	,[SecurityID]
	,TransactionAmt
	,CAST(TransactionDate AS Date) TransactionDate 
	,CAST( DATEADD(MONTH, DATEDIFF(MONTH, '19000101', TransactionDate), '19000101') AS DATE) as MonthStart
	,EOMONTH(TransactionDate) AS MonthEnd
	,CAST(DATEADD(qq, DATEDIFF(qq, 0, TransactionDate), 0) AS DATE) AS QtrStart
	,CAST(DATEADD(dd, -1, DATEADD(qq, DATEDIFF(qq, 0, TransactionDate) +1, 0)) AS DATE) AS QtrEnd
	,CAST(DATEADD(yy, DATEDIFF(yy,0,TransactionDate), 0) AS DATE) AS StartOfYear
	,MONTH(TransactionDate)  as TranMonth

FROM  [SMC].[Transactions] T 
WHERE TransactionTypeDesc NOT IN ('Recallable Capital')
)
,CTE_Data2 AS (
	SELECT * 
		--,DATEADD(m, -3, MonthEnd) AS MonthEndLag3
		,CAST(DATEADD(m, -12, QtrEnd) AS DATE) AS MonthEndLag1Yr
		,CAST(DATEADD(m, -36, QtrEnd) AS DATE) AS MonthEndLag3Yr
		,CAST(DATEADD(m, -60, QtrEnd) AS DATE) AS MonthEndLag5Yr
		,CAST(DATEADD(m, -84, QtrEnd) AS DATE) AS MonthEndLag7Yr
		,CAST(DATEADD(m, -120, QtrEnd) AS DATE) AS MonthEndLag10Yr

	,CASE MONTH(TransactionDate) 
		WHEN 1 THEN 1
	END Group1

	,CASE MONTH(TransactionDate) 
		WHEN 1 THEN 2
		WHEN 2 THEN 2
	END Group2

	,CASE MONTH(TransactionDate) 
		WHEN 1 THEN 3
		WHEN 2 THEN 3
		WHEN 3 THEN 3
	END Group3

	,CASE MONTH(TransactionDate) 
		WHEN 1 THEN 4
		WHEN 2 THEN 4
		WHEN 3 THEN 4
		WHEN 4 THEN 4
	END Group4

	,CASE MONTH(TransactionDate) 
		WHEN 1 THEN 5
		WHEN 2 THEN 5
		WHEN 3 THEN 5
		WHEN 4 THEN 5
		WHEN 5 THEN 5
	END Group5

	,CASE MONTH(TransactionDate) 
		WHEN 1 THEN 6
		WHEN 2 THEN 6
		WHEN 3 THEN 6
		WHEN 4 THEN 6
		WHEN 5 THEN 6
		WHEN 6 THEN 6
	END Group6

	,CASE MONTH(TransactionDate) 
		WHEN 1 THEN 7
		WHEN 2 THEN 7
		WHEN 3 THEN 7
		WHEN 4 THEN 7
		WHEN 5 THEN 7
		WHEN 6 THEN 7
		WHEN 7 THEN 7
	END Group7

	,CASE MONTH(TransactionDate) 
		WHEN 1 THEN 8
		WHEN 2 THEN 8
		WHEN 3 THEN 8
		WHEN 4 THEN 8
		WHEN 5 THEN 8
		WHEN 6 THEN 8
		WHEN 7 THEN 8
		WHEN 8 THEN 8
	END Group8

	,CASE MONTH(TransactionDate) 
		WHEN 1 THEN 9
		WHEN 2 THEN 9
		WHEN 3 THEN 9
		WHEN 4 THEN 9
		WHEN 5 THEN 9
		WHEN 6 THEN 9
		WHEN 7 THEN 9
		WHEN 8 THEN 9
		WHEN 9 THEN 9
	END Group9

	,CASE MONTH(TransactionDate) 
		WHEN 1 THEN 10
		WHEN 2 THEN 10
		WHEN 3 THEN 10
		WHEN 4 THEN 10
		WHEN 5 THEN 10
		WHEN 6 THEN 10
		WHEN 7 THEN 10
		WHEN 8 THEN 10
		WHEN 9 THEN 10
		WHEN 10 THEN 10
	END Group10

	,CASE MONTH(TransactionDate) 
		WHEN 1 THEN 11
		WHEN 2 THEN 11
		WHEN 3 THEN 11
		WHEN 4 THEN 11
		WHEN 5 THEN 11
		WHEN 6 THEN 11
		WHEN 7 THEN 11
		WHEN 8 THEN 11
		WHEN 9 THEN 11
		WHEN 10 THEN 11
		WHEN 11 THEN 11
	END Group11

	,CASE MONTH(TransactionDate) 
		WHEN 1 THEN 12
		WHEN 2 THEN 12
		WHEN 3 THEN 12
		WHEN 4 THEN 12
		WHEN 5 THEN 12
		WHEN 6 THEN 12
		WHEN 7 THEN 12
		WHEN 8 THEN 12
		WHEN 9 THEN 12
		WHEN 10 THEN 12
		WHEN 11 THEN 12
		WHEN 12 THEN 12
	END Group12


	,CASE MONTH(TransactionDate) 
		WHEN 7 THEN 1
	END JY_Group1

	,CASE MONTH(TransactionDate) 
		WHEN 7 THEN 2
		WHEN 8 THEN 2
	END JY_Group2

	,CASE MONTH(TransactionDate) 
		WHEN 7 THEN 3
		WHEN 8 THEN 3
		WHEN 9 THEN 3
	END JY_Group3

	,CASE MONTH(TransactionDate) 
		WHEN 7 THEN 4
		WHEN 8 THEN 4
		WHEN 9 THEN 4
		WHEN 10 THEN 4
	END JY_Group4

	,CASE MONTH(TransactionDate) 
		WHEN 7 THEN 5
		WHEN 8 THEN 5
		WHEN 9 THEN 5
		WHEN 10 THEN 5
		WHEN 11 THEN 5
	END JY_Group5

	,CASE MONTH(TransactionDate) 
		WHEN 7 THEN 6
		WHEN 8 THEN 6
		WHEN 9 THEN 6
		WHEN 10 THEN 6
		WHEN 11 THEN 6
		WHEN 12 THEN 6
	END JY_Group6

	,CASE MONTH(TransactionDate) 
		WHEN 7 THEN 7
		WHEN 8 THEN 7
		WHEN 9 THEN 7
		WHEN 10 THEN 7
		WHEN 11 THEN 7
		WHEN 12 THEN 7
		WHEN 1 THEN 7
	END JY_Group7

	,CASE MONTH(TransactionDate) 
		WHEN 7 THEN 8
		WHEN 8 THEN 8
		WHEN 9 THEN 8
		WHEN 10 THEN 8
		WHEN 11 THEN 8
		WHEN 12 THEN 8
		WHEN 1 THEN 8
		WHEN 2 THEN 8
	END JY_Group8

	,CASE MONTH(TransactionDate) 
		WHEN 7 THEN 9
		WHEN 8 THEN 9
		WHEN 9 THEN 9
		WHEN 10 THEN 9
		WHEN 11 THEN 9
		WHEN 12 THEN 9
		WHEN 1 THEN 9
		WHEN 2 THEN 9
		WHEN 3 THEN 9
	END JY_Group9

	,CASE MONTH(TransactionDate) 
		WHEN 7 THEN 10
		WHEN 8 THEN 10
		WHEN 9 THEN 10
		WHEN 10 THEN 10
		WHEN 11 THEN 10
		WHEN 12 THEN 10
		WHEN 1 THEN 10
		WHEN 2 THEN 10
		WHEN 3 THEN 10
		WHEN 4 THEN 10
	END JY_Group10

	,CASE MONTH(TransactionDate) 
		WHEN 7 THEN 11
		WHEN 8 THEN 11
		WHEN 9 THEN 11
		WHEN 10 THEN 11
		WHEN 11 THEN 11
		WHEN 12 THEN 11
		WHEN 1 THEN 11
		WHEN 2 THEN 11
		WHEN 3 THEN 11
		WHEN 4 THEN 11
		WHEN 5 THEN 11
	END JY_Group11

	,CASE MONTH(TransactionDate) 
		WHEN 7 THEN 12
		WHEN 8 THEN 12
		WHEN 9 THEN 12
		WHEN 10 THEN 12
		WHEN 11 THEN 12
		WHEN 12 THEN 12
		WHEN 1 THEN 12
		WHEN 2 THEN 12
		WHEN 3 THEN 12
		WHEN 4 THEN 12
		WHEN 5 THEN 12
		WHEN 6 THEN 12
	END JY_Group12

	FROM CTE_Data1
)
SELECT * FROM CTE_Data2
--ORDER BY AccountNumber,SecurityID,MonthEnd


/*
SELECT 
	[AccountNumber]
	,[SecurityID]
	,TransactionAmt
	,TransactionDate 
	,MonthStart
	,MonthEnd
	,QtrStart
	,QtrEnd
	,StartOfYear
	,TranMonth
	,Group1
	,Group2
	,Group3
	,Group4
	,Group5
	,Group6
	,Group7
	,Group8
	,Group9
	,Group10
,Group11
,Group12
	,Group7
FROM CTE_Data2
order by [AccountNumber],[SecurityID],[MonthStart]
--*/
