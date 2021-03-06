/****** Script for SelectTopNRows command from SSMS  ******/


create table #Temp_PackageParameters (
    [PackageName] nvarchar(500) null
    ,[ParameterName] nvarchar(500) null
    ,[ParameterValue] nvarchar(500) null
    ,[Application] nvarchar(500) null
    ,[Category] nvarchar(500) null
	)
  
insert into #Temp_PackageParameters

SELECT 'MellonPendingTransactions_SID_D_I_PD' [PackageName]
      ,[ParameterName]
      ,[ParameterValue]
      ,[Application]
      ,[Category]
  FROM [SMC_DB_DW_Metadata].[ETL].[PackageParameters]
  where [PackageName] = 'MellonTransactions_SID_D_I_PD'

select * from #Temp_PackageParameters


insert into [SMC_DB_DW_Metadata].[ETL].[PackageParameters]
select * from #Temp_PackageParameters

SELECT [PackageName]
      ,[ParameterName]
      ,[ParameterValue]
      ,[Application]
      ,[Category]
  FROM [SMC_DB_DW_Metadata].[ETL].[PackageParameters]
  where [PackageName] = 'MellonPendingTransactions_SID_D_I_PD'


 
