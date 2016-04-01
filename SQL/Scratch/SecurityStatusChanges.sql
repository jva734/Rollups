USE [SMC_DB_ASA]
GO


print @@servername

/****** Script for SelectTopNRows command from SSMS  ******/
/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [LookupCategory]
      ,[CategoryDescription]
  FROM [SMC_DB_ASA].[asa].[LookupCategories]


SELECT TOP 1000 [LookupId]
      ,[LookupCategory]
      ,[LookupText]
      ,[LookupValue]
      ,[Sequence]
      ,[IsActive]
      ,[IsEditable]
      ,[ParentLookupId]
  FROM [SMC_DB_ASA].[asa].[Lookups]
  where [LookupCategory] = 'SECURITY_STATUS'

  /*
  Under "Security Status" within ASA Securities, change the drop-down menu value of "Acquired" to "Converted Old". Change existing "Acquired" to "Write-Off Converted Old"
  LookupId	LookupCategory	LookupText	LookupValue	Sequence	IsActive	IsEditable	ParentLookupId
16001	SECURITY_STATUS	Active		1	1	0	NULL
16002	SECURITY_STATUS	Sold		2	1	0	NULL
16003	SECURITY_STATUS	Acquired		3	1	0	NULL
16004	SECURITY_STATUS	Write-Off		4	1	0	NULL


3	ASA	Under "Security Status" within ASA Securities, change the drop-down menu value of "Sold" to "Write-Off Converted New". Change existing "Sold" to "Write-Off Converted New"			



Sorry I mis-typed the instruction. We want to change the drop-down menu and all existing "Acquired" to "Write-Off Converted Old"

Similarly, we want to change the drop-down and all existing "Sold" to "Write-Off Converted New". 

Lastly, we want to create a new value in the drop-down menu for "Active Converted New" but not set any existing securities to that Security Status as we will do that manually once it's setup. 

We can definitely chat next week if you have more questions or clarifications. 

  */

  print @@ServerName

BEGIN TRANSACTION T1

	-- RENAME Acquired
  UPDATE [SMC_DB_ASA].[asa].[Lookups] SET LookupText = 'Write-Off Converted Old' WHERE LookupId = 16003

  -- RENAME Sold
  UPDATE [SMC_DB_ASA].[asa].[Lookups] SET LookupText = 'Write-Off Converted New' WHERE LookupId = 16002

	INSERT INTO [asa].[Lookups]
		([LookupId],[LookupCategory],[LookupText],[LookupValue],[Sequence],[IsActive],[IsEditable],[ParentLookupId])
	VALUES
		(16005,'SECURITY_STATUS','Active Converted New','',5,1,0,NULL)
	
	SELECT * FROM [SMC_DB_ASA].[asa].[Lookups] where [LookupCategory] = 'SECURITY_STATUS'

--ROLLBACK TRANSACTION T1
COMMIT TRANSACTION T1

