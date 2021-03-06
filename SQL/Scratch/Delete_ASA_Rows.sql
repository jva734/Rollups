-- Delete ASA Rows
USE SMC_DB_ASA
GO

print @@Servername


/* Back up data
SELECT * INTO DBO.[AccountsBKP] FROM  [asa].[Accounts]
SELECT * INTO [dbo].[SecuritiesBKP] FROM [asa].[Securities] 
SELECT * INTO [dbo].[CompaniesBKP] FROM [asa].[Companies] 
SELECT * INTO [dbo].[SecurityAccountsBKP]  FROM [asa].[SecurityAccounts] 
*/

/*
This links all the data together
determine best way to delete all the data
*/

/*-------------------------------------------------------------------------------------
 Read ALL the Data 
 */
;WITH CTE_DATA AS (
SELECT  X.[aCCOUNT nAME]
		,A.[AccountId]
		,S.[SecurityId]
		,C.[CompanyId]
		,SA.[SecurityAccountId]
FROM [SMC_DB_ASA].[dbo].[SDFNotInASA] X
LEFT	JOIN [asa].[Accounts] A ON A.[AccountNumber] = X.[AccountNumber]
LEFT	JOIN [asa].[Securities] S ON S.[MellonSecurityId] = X.[SecurityID]
LEFT	JOIN [asa].[Companies] C ON C.[CompanyId] = S.[CompanyId]
LEFT	JOIN [asa].[SecurityAccounts] SA ON SA.[AccountId] = A.[AccountId] AND SA.[SecurityId] = S.[SecurityId]
)
--SELECT * FROM CTE_DATA X JOIN [asa].[SecurityAccounts] SA ON SA.[SecurityAccountId] =  X.[SecurityAccountId]
SELECT * FROM CTE_DATA X JOIN  [asa].[Securities] S  ON  s.[SecurityID] =  X.[SecurityID]
--SELECT * FROM CTE_DATA X JOIN [asa].[Companies] C ON C.[CompanyId]  =  X.[CompanyId] AND C.Comment = 'SDF Bulk Load'
--SELECT * FROM CTE_DATA X JOIN [asa].[Accounts] A ON  A.[AccountId] =  X.[AccountId]


/*-------------------------------------------------------------------------------------------------------
[SecurityAccounts]
*/
BEGIN TRANSACTION T1
;WITH CTE_DATA AS (
SELECT  X.[aCCOUNT nAME]
		,A.[AccountId]
		,S.[SecurityId]
		,C.[CompanyId]
		,SA.[SecurityAccountId]
FROM [SMC_DB_ASA].[dbo].[SDFNotInASA] X
	JOIN [asa].[Accounts] A ON A.[AccountNumber] = X.[AccountNumber]
	JOIN [asa].[Securities] S ON S.[MellonSecurityId] = X.[SecurityID]
	JOIN [asa].[Companies] C ON C.[CompanyId] = S.[CompanyId]
	JOIN [asa].[SecurityAccounts] SA ON SA.[AccountId] = A.[AccountId] AND SA.[SecurityId] = S.[SecurityId]
)
SELECT * FROM CTE_DATA X JOIN [asa].[SecurityAccounts] SA ON SA.[SecurityAccountId] =  X.[SecurityAccountId]

DELETE FROM [asa].[SecurityAccounts] WHERE [SecurityAccountId] IN (SELECT [SecurityAccountId] FROM CTE_DATA)
--ROLLBACK TRANSACTION T1
COMMIT TRANSACTION T1


/*-------------------------------------------------------------------------------------------------------
[Security]
*/
BEGIN TRANSACTION T1
;WITH CTE_DATA AS (
SELECT  X.[aCCOUNT nAME]
		,A.[AccountId]
		,S.[SecurityId]
		,C.[CompanyId]
FROM [SMC_DB_ASA].[dbo].[SDFNotInASA] X
	JOIN [asa].[Accounts] A ON A.[AccountNumber] = X.[AccountNumber]
	JOIN [asa].[Securities] S ON S.[MellonSecurityId] = X.[SecurityID]
	JOIN [asa].[Companies] C ON C.[CompanyId] = S.[CompanyId]
)
SELECT * FROM CTE_DATA X JOIN  [asa].[Securities] S  ON  s.[SecurityID] =  X.[SecurityID] AND Comment = 'SDF Bulk Load'

DELETE FROM [asa].Securities WHERE SecurityID IN (SELECT SecurityID  FROM CTE_DATA) AND Comment = 'SDF Bulk Load'
--ROLLBACK TRANSACTION T1
COMMIT TRANSACTION T1


/*-------------------------------------------------------------------------------------------------------
[[Companies]]
*/
BEGIN TRANSACTION T1
SELECT * FROM [asa].[Companies] C WHERE C.Comment = 'SDF Bulk Load'
DELETE FROM [asa].[Companies] WHERE Comment = 'SDF Bulk Load'
ROLLBACK TRANSACTION T1
COMMIT TRANSACTION T1

/*-------------------------------------------------------------------------------------------------------
[Accounts]

I THINK WE MIGHT NEED TO LEAVE ACCOUTNS ALONE
*/
--BEGIN TRANSACTION T1
--;WITH CTE_DATA AS (
--SELECT  X.[aCCOUNT nAME]
--		,A.[AccountId]
--FROM [SMC_DB_ASA].[dbo].[SDFNotInASA] X
--	JOIN [asa].[Accounts] A ON A.[AccountNumber] = X.[AccountNumber]
--)
----SELECT * FROM CTE_DATA X JOIN [asa].[Accounts] A ON  A.[AccountId] =  X.[AccountId]
--DELETE FROM [asa].Accounts WHERE AccountId IN (SELECT AccountId FROM CTE_DATA) 

--;WITH CTE_DATA AS (
--SELECT  *
----DISTINCT A.AccountId 
----X.[aCCOUNT nAME],A.[AccountId]
--FROM [asa].[SecurityAccounts] SA 
--	JOIN [asa].[Accounts] A ON A.AccountId = SA.AccountId
--	JOIN [SMC_DB_ASA].[dbo].[SDFNotInASA] X ON X.[AccountNumber] = A.[AccountNumber]
--)
--DELETE FROM [asa].Accounts WHERE AccountId IN (SELECT AccountId FROM CTE_DATA) 
--ROLLBACK TRANSACTION T1

--COMMIT TRANSACTION T1


-------------------------------------------------------------------------------------------------------------------------------

--/*Account Number
--	Check for Duplicates
	--SELECT ASA.[AccountNumber],COUNT(*)
	--FROM [asa].[Accounts] ASA 
	--GROUP BY ASA.[AccountNumber]
	--HAVING COUNT(*) > 1
BEGIN TRANSACTION T1

;WITH SDF_DATA AS (
	SELECT DISTINCT ASA.[AccountId]
	FROM [SMC_DB_ASA].[dbo].[SDFNotInASA] SDF JOIN [asa].[Accounts] ASA ON ASA.[AccountNumber]  = SDF.[AccountNumber] 
)
	--SELECT ASA.*
	--FROM SDF_DATA SDF JOIN [asa].[Accounts] ASA ON ASA.[AccountId] = SDF.[AccountId]
	--ORDER BY ASA.[AccountNumber]
	DELETE [asa].[Accounts] 
	WHERE [AccountId] IN (SELECT [AccountId] FROM  SDF_DATA)
--*/

SELECT DISTINCT ASA.[AccountId]
FROM [SMC_DB_ASA].[dbo].[SDFNotInASA] SDF JOIN [asa].[Accounts] ASA ON ASA.[AccountNumber]  = SDF.[AccountNumber] 

--ROLLBACK TRANSACTION T1
COMMIT TRANSACTION T1

GO
--SYSTEM USE [SMC_DB_ASA]
GO


ALTER TABLE [asa].[SecurityAccounts] DROP CONSTRAINT [fk_SecurityAccounts_Accounts];

ALTER TABLE [asa].[SecurityAccounts] ADD CONSTRAINT [fk_SecurityAccounts_Accounts] FOREIGN KEY ([AccountId]) REFERENCES [asa].[Accounts]([AccountId]);

USE [SMC_DB_ASA]
GO

ALTER TABLE [asa].[SecurityAccounts]  WITH CHECK ADD  CONSTRAINT [fk_SecurityAccounts_Accounts] FOREIGN KEY([AccountId])
REFERENCES [asa].[Accounts] ([AccountId])
GO

ALTER TABLE [asa].[SecurityAccounts] CHECK CONSTRAINT [fk_SecurityAccounts_Accounts]
GO



ALTER TABLE [SMC_DB_ASA].[asa].[SecurityAccounts]  ADD  CONSTRAINT [fk_SecurityAccounts_Accounts] FOREIGN KEY([AccountId])
REFERENCES [SMC_DB_ASA].[asa].[Accounts] ([AccountId])
GO

ALTER TABLE [SMC_DB_ASA].[asa].[SecurityAccounts]  WITH CHECK ADD  CONSTRAINT [fk_SecurityAccounts_Accounts] FOREIGN KEY([AccountId])
REFERENCES [SMC_DB_ASA].[asa].[Accounts] ([AccountId])
GO

SELECT ALTER TABLE  so.NAME + ' CHECK CONSTRAINT ALL'<br />FROM sysobjects so<br />WHERE xtype = 'u'<br />

ALTER TABLE [asa].[SecurityAccounts] CHECK CONSTRAINT [fk_SecurityAccounts_Accounts]
GO

/*SecurityID
--	Check for Duplicates
--;WITH CTE_DUPS AS (
--	SELECT ASA.[MellonSecurityId] ,COUNT(*) AS RowCnt
--	FROM [asa].[Securities] ASA 
--	GROUP BY ASA.[MellonSecurityId]
--	HAVING COUNT(*) > 1
--)
--	SELECT ASA.*
--	FROM CTE_DUPS D JOIN [asa].[Securities] ASA ON ASA.[MellonSecurityId] = D.[MellonSecurityId]
----	WHERE ASA.Comment = 'SDF Bulk Load'
--	ORDER BY ASA.[MellonSecurityId],comment


ALTER TABLE [asa].[SecurityAccounts] DROP CONSTRAINT [fk_SecurityAccounts_Securities]
GO

BEGIN TRANSACTION T1
;WITH SDF_DATA AS (
	SELECT DISTINCT ASA.[SecurityId]
	FROM [SMC_DB_ASA].[dbo].[SDFNotInASA] SDF JOIN [asa].[Securities] ASA ON ASA.[MellonSecurityId]  = SDF.SecurityID 
)
	--SELECT ASA.*
	--FROM SDF_DATA SDF JOIN [asa].[Securities] ASA ON ASA.[SecurityId] = SDF.[SecurityId]
	--WHERE ASA.Comment = 'SDF Bulk Load'
	--ORDER BY ASA.[MellonSecurityId]

	DELETE [asa].[Securities] 
	WHERE [SecurityId] IN (SELECT [SecurityId] FROM  SDF_DATA)

	SELECT DISTINCT ASA.[SecurityId]
	FROM [SMC_DB_ASA].[dbo].[SDFNotInASA] SDF JOIN [asa].[Securities] ASA ON ASA.[MellonSecurityId]  = SDF.SecurityID 

--ROLLBACK TRANSACTION T1
COMMIT TRANSACTION T1

ALTER TABLE [SMC_DB_ASA].[asa].[SecurityAccounts]  WITH CHECK ADD  CONSTRAINT [fk_SecurityAccounts_Securities] FOREIGN KEY([SecurityId])
REFERENCES [SMC_DB_ASA].[asa].[Securities] ([SecurityId])
GO

ALTER TABLE [asa].[SecurityAccounts] CHECK CONSTRAINT [fk_SecurityAccounts_Securities]
GO

--*/

/*Company
/*Check for Duplicates
;WITH CTE_DUPS AS (
	SELECT ASA.[CompanyName] ,COUNT(*) AS RowCnt
	FROM [asa].[Companies] ASA 
	GROUP BY ASA.[CompanyName]
	HAVING COUNT(*) > 1
)
	SELECT ASA.*
	FROM CTE_DUPS D JOIN [asa].[Companies] ASA ON ASA.CompanyName = D.CompanyName
--	WHERE ASA.Comment = 'SDF Bulk Load'
	ORDER BY ASA.CompanyName,comment
*/
BEGIN TRANSACTION T1
;WITH SDF_DATA AS (
	SELECT DISTINCT ASA.[CompanyId]
	FROM [SMC_DB_ASA].[dbo].[SDFNotInASA] SDF JOIN ASA.[Companies] ASA ON ASA.CompanyName  = SDF.CompanyName 
)
	--SELECT ASA.*
	--FROM SDF_DATA SDF JOIN [asa].[Companies] ASA ON ASA.[CompanyId] = SDF.[CompanyId]
	--WHERE ASA.Comment = 'SDF Bulk Load'
	--ORDER BY ASA.CompanyName
	DELETE [asa].[Companies] 
	WHERE CompanyName IN (SELECT CompanyName FROM  SDF_DATA) AND Comment = 'SDF Bulk Load'

	SELECT DISTINCT ASA.[CompanyId]
	FROM [SMC_DB_ASA].[dbo].[SDFNotInASA] SDF JOIN ASA.[Companies] ASA ON ASA.CompanyName  = SDF.CompanyName 


--ROLLBACK TRANSACTION T1
COMMIT TRANSACTION T1

--*/


/*SecurityID-Company
;WITH SDF_DATA AS (
	SELECT S.[SecurityId],C.[CompanyId]
	FROM [SMC_DB_ASA].[dbo].[SDFNotInASA] SDF 
			JOIN [asa].[Securities] S
				ON S.[MellonSecurityId]  = SDF.SecurityID 
			JOIN ASA.[Companies] C 
				ON C.CompanyName  = SDF.CompanyName 
)
	SELECT *
	FROM SDF_DATA SDF 
			JOIN [asa].[Securities] ASA ON ASA.[SecurityId] = SDF.[SecurityId] AND ASA.Comment = 'SDF Bulk Load'
			JOIN [asa].[Companies]  C ON C.[CompanyId] = SDF.[CompanyId] AND C.Comment = 'SDF Bulk Load'
--*/


/*Account Security
ALTER TABLE [asa].[SecurityAccountSponsors] DROP CONSTRAINT [fk_SecurityAccountSponsors_SecurityAccounts]
GO

BEGIN TRANSACTION T1

;WITH SDF_DATA AS (
	SELECT DISTINCT sa.SecurityAccountID
	--, A.[AccountId],s.[SecurityId]
	FROM [SMC_DB_ASA].[dbo].[SDFNotInASA] SDF 
			JOIN [asa].[Accounts] A ON A.[AccountNumber]  = SDF.[AccountNumber] 
			JOIN [asa].[Securities] S ON S.[MellonSecurityId]  = SDF.SecurityID 
			JOIN [asa].[SecurityAccounts] SA ON SA.[AccountId] = a.[AccountId] AND SA.SecurityID = S.SecurityID
)
	--SELECT * FROM [asa].[SecurityAccounts] WHERE SecurityAccountID IN (SELECT SecurityAccountID FROM SDF_DATA) 
DELETE [asa].[SecurityAccounts]
WHERE SecurityAccountID IN (SELECT SecurityAccountID FROM SDF_DATA) 

SELECT DISTINCT sa.SecurityAccountID, A.[AccountId],s.[SecurityId]
FROM [SMC_DB_ASA].[dbo].[SDFNotInASA] SDF 
		JOIN [asa].[Accounts] A ON A.[AccountNumber]  = SDF.[AccountNumber] 
		JOIN [asa].[Securities] S ON S.[MellonSecurityId]  = SDF.SecurityID 
		JOIN [asa].[SecurityAccounts] SA ON SA.[AccountId] = a.[AccountId] AND SA.SecurityID = S.SecurityID

--rollback TRANSACTION T1
COMMIT TRANSACTION T1

ALTER TABLE [asa].[SecurityAccountSponsors]  WITH CHECK ADD  CONSTRAINT [fk_SecurityAccountSponsors_SecurityAccounts] FOREIGN KEY([SecurityAccountId])
REFERENCES [asa].[SecurityAccounts] ([SecurityAccountId])
GO

ALTER TABLE [asa].[SecurityAccountSponsors] CHECK CONSTRAINT [fk_SecurityAccountSponsors_SecurityAccounts]
GO


--*/


/*
SELECT [AccountNumber]
      ,[Account Name]
      ,[SecurityID]
      ,[CompanyName]
      ,[Processed]
  FROM [SMC_DB_ASA].[dbo].[SDFNotInASA]
*/


