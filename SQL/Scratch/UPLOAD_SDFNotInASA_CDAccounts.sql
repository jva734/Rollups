/****** Script for SelectTopNRows command from SSMS  ******/
--UPLOAD_SDFNotInASA_CDAccounts

TRUNCATE TABLE [SMC_DB_ASA].[dbo].[CDAccounts]

INSERT INTO [SMC_DB_ASA].[dbo].[CDAccounts]
      ([AccountNumber]
      ,[AccountName]
      ,[SecurityID]
      ,[CompanyName]
      ,[Processed]
	  )
SELECT [AccountNumber]
      ,[Account Name] 
      ,[SecurityID]
      ,[CompanyName]
	  ,[Processed]
  FROM [SMC_DB_ASA].[dbo].[SDFNotInASA]

--SELECT [CDAccountsID]
--      ,[AccountNumber]
--      ,[AccountName]
--      ,[SecurityID]
--      ,[CompanyName]
--      ,[Processed]
--  FROM [SMC_DB_ASA].[dbo].[CDAccounts]