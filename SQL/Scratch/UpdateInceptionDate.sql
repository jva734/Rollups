/****** Script for SelectTopNRows command from SSMS  ******/

select *  FROM [SMC_DB_ASA].[dbo].[SDFNotInASA]  order by [AccountNumber],[SecurityID]

BEGIN TRANSACTION T1
;WITH CTE_INC AS (
SELECT A.[AccountNumber],A.[SecurityID],MIN(MPF.InceptionDate) AS InceptionDate, COUNT(*) AS CNT
FROM [SMC_DB_ASA].[dbo].[SDFNotInASA] A
	JOIN [SMC_DB_Performance].[SMC].[MonthlyPerformanceFund] MPF ON A.[AccountNumber] = MPF.[AccountNumber] AND A.[SecurityID] = MPF.[SecurityID]
GROUP BY A.[AccountNumber],A.[SecurityID]
)
--SELECT A.*
--FROM CTE_INC B
--JOIN [SMC_DB_ASA].[dbo].[SDFNotInASA] A ON A.[AccountNumber] = B.[AccountNumber] AND A.[SecurityID] = B.[SecurityID]
UPDATE A
SET A.InceptionDate = B.InceptionDate
FROM CTE_INC B
JOIN [SMC_DB_ASA].[dbo].[SDFNotInASA] A ON A.[AccountNumber] = B.[AccountNumber] AND A.[SecurityID] = B.[SecurityID]

select * FROM [SMC_DB_ASA].[dbo].[SDFNotInASA] order by [AccountNumber],[SecurityID]

--ROLLBACK TRANSACTION T1
COMMIT TRANSACTION T1


--AccountNumber	SecurityID	InceptionDate


/*
Capital Calls
*/
--LSJF70430002	00444T100	2011-02-11

BEGIN TRANSACTION T1

;WITH CTE_CC AS(
  SELECT [AccountNumber],[SecurityID],SUM([CapitalCalls]) AS TotCapitalCalls
  FROM [SMC_DB_Performance].[SMC].[MonthlyPerformanceFund] 
  GROUP by [AccountNumber],[SecurityID]
)
--SELECT b.*
--FROM CTE_CC B
--JOIN [SMC_DB_ASA].[dbo].[SDFNotInASA] A ON A.[AccountNumber] = B.[AccountNumber] AND A.[SecurityID] = B.[SecurityID]

UPDATE A
SET A.TotalCapitalCalls = B.TotCapitalCalls
FROM CTE_CC B
JOIN [SMC_DB_ASA].[dbo].[SDFNotInASA] A ON A.[AccountNumber] = B.[AccountNumber] AND A.[SecurityID] = B.[SecurityID]


select * FROM [SMC_DB_ASA].[dbo].[SDFNotInASA] order by [AccountNumber],[SecurityID]

--ROLLBACK TRANSACTION T1

COMMIT TRANSACTION T1


SELECT [AccountNumber],[SecurityID],SUM([CapitalCalls]) AS TotCapitalCalls
  FROM [SMC_DB_Performance].[SMC].[MonthlyPerformanceFund] 
  WHERE [AccountNumber] = 'LSJF30020002' AND [SecurityID] = '00971T101'
  GROUP by [AccountNumber],[SecurityID]


SELECT A.[AccountNumber],A.[SecurityID],MPF.InceptionDate,CapitalCalls
FROM [SMC_DB_ASA].[dbo].[SDFNotInASA] A
	JOIN [SMC_DB_Performance].[SMC].[MonthlyPerformanceFund] MPF ON A.[AccountNumber] = MPF.[AccountNumber] AND A.[SecurityID] = MPF.[SecurityID]
WHERE a.[AccountNumber] = 'LSJF30020002' AND a.[SecurityID] = '00971T101'

  SELECT [AccountNumber],[SecurityID],MonthEnd,InceptionDate,[CapitalCalls]
  FROM [SMC_DB_Performance].[SMC].[MonthlyPerformanceFund] WHERE [AccountNumber] = 'LSJF80000002' AND [SecurityID] = '99VVAQWM9'
  order by [AccountNumber],[SecurityID],MonthEnd

