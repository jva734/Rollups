/****** Script for SelectTopNRows command from SSMS  ******/
SELECT DISTINCT [SMC Load Date]
FROM [SMC_DB_Mellon].[dbo].[SIDTransactionDetail]
ORDER BY [SMC Load Date] DESC


SELECT [SMC Load Date], count(*)
FROM [SMC_DB_Mellon].[dbo].[SIDTransactionDetail]
group by [SMC Load Date]
order by [SMC Load Date] desc

SELECT * FROM [SMC_DB_Mellon].[dbo].[SIDTransactionDetail] WHERE [SMC Load Date] >= '2016-02-18 10:27:06.000' -- '2016-02-17 16:53:05.000'
DELETE FROM [SMC_DB_Mellon].[dbo].[SIDTransactionDetail] WHERE [SMC Load Date] >= '2016-02-17 16:53:05.000'

SELECT * FROM [SMC_DB_Mellon].[dbo].[SIDTransactionDetail] WHERE [Effective Date] >= '2014-10-01'


DELETE FROM [SMC_DB_Mellon].[dbo].[SIDTransactionDetail] WHERE [Effective Date] >= '2014-10-01'


select DATEADD(m, -6,getdate()) as LastDate

DECLARE @CutOffDate date 
set @CutOffDate  = DATEADD(m, -6,getdate()) 
--select @CutOffDate  

SELECT * FROM [SMC_DB_Mellon].[dbo].[SIDTransactionDetail] WHERE [Effective Date] >= @CutOffDate 

DELETE FROM [SMC_DB_Mellon].[dbo].[SIDTransactionDetail] WHERE [Effective Date] >= @CutOffDate 

go

DECLARE @CutOffDate date = DATEADD(m, -6,getdate()) 
DELETE FROM [SMC_DB_Mellon].[dbo].[SIDTransactionDetail] WHERE [Effective Date] >= @CutOffDate 
