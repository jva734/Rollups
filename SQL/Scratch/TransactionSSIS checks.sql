print @@servername --SMC-SQL\SMCSQLSP

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [Source Account Name]
      ,[Source Account Number]
	  ,[Mellon Security ID]
      ,[Effective Date]
      ,[Posted Date]
      ,[Reported Date]
      ,[Firm Code]

      ,[Base Amount]
      ,[Base Cost]
      ,[Shares]
      ,[Sub Transaction Code]
     ,[Tax Code]
      ,[Tax Code Description]
  FROM [SMC_DB_Mellon].[dbo].[SIDTransactionDetail]
  where [Reported Date] >= '2015-09-15'
  order by [Reported Date]


select count(*) FROM [SMC_DB_Mellon].[dbo].[SIDTransactionDetail] where [Reported Date] >= '2014-10-01' --original 21941
select count(*) FROM [SMC_DB_Mellon].[dbo].[SIDTransactionDetail] where [Reported Date] >= '2015-09-15' -- 8987 -- 6268
 

select count(*) FROM [SMC_DB_Mellon].[dbo].[SIDTransactionDetail] where [Posted Date] >= '2014-10-01'  --current 18975

select count(*) FROM [SMC_DB_Mellon].[dbo].[SIDTransactionDetail] where [Effective Date] >= '2014-10-01'  --current 18370


--DELETE FROM [SMC_DB_Mellon].[dbo].[SIDTransactionDetail]  where [Reported Date] >= '2014-10-01' --22,221

SELECT [Source Account Name]
      ,[Source Account Number]
	  ,[Mellon Security ID]
      ,[Effective Date]
      ,[Posted Date]
      ,[Reported Date]
      ,[Firm Code]

      ,[Base Amount]
      ,[Base Cost]
      ,[Shares]
      ,[Sub Transaction Code]
     ,[Tax Code]
      ,[Tax Code Description]
  FROM [SMC_DB_Mellon].[dbo].[SIDTransactionDetail]
where [Source Account Number] = 'LSJF86000002'
and 	[Mellon Security ID] = '999J27674'




select * FROM [SMC_DB_Mellon].[dbo].[SIDTransactionDetail] where [Reported Date] >= '2015-09-15' -- 6236 -- 6268
