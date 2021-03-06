--The INSERT statement conflicted with the FOREIGN KEY constraint "fk_SecurityAccounts_Accounts". The conflict occurred in database "SMC_DB_ASA", table "asa.Accounts", column 'AccountId'.
USE SMC_DB_ASA
GO
SET NOCOUNT ON

/*-- Test Tables CVounts before any updates

*/

--ALTER TABLE [asa].[SecurityAccounts] DROP CONSTRAINT [fk_SecurityAccounts_Accounts] 
--GO

BEGIN TRANSACTION T1

DECLARE @Debug TABLE([Status] varchar(100), BigString VARCHAR(max))

DECLARE @Status varchar(100)
		,@BigString varchar(MAX)
		,@DebugMode bit
SET @DebugMode  = 0

DECLARE @CDAccountsID INT
      ,@AccountNumber NVARCHAR(50)
      ,@AccountName NVARCHAR(255)
      ,@SecurityID NVARCHAR(25)
      ,@CompanyName NVARCHAR(255)
      ,@Processed INT
	  ,@NewAccountId int
	  ,@NewCompanyId int
	  ,@NewSecurityId  int
	  ,@SecurityAccountId int
	  ,@Rownum int = 0

/*
DECLARE @CDAccounts TABLE(
      AccountNumber NVARCHAR(50)
      ,AccountName NVARCHAR(255)
      ,SecurityID NVARCHAR(25)
      ,CompanyName NVARCHAR(255)
)

;WITH CTE_SDF AS (
SELECT  A.AccountNumber
		,A.SecurityID
		,MAX(A.[MellonAccountName]) AS [AccountName]
		,MAX(A.[CompanyName]) AS [CompanyName]
FROM [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore] A
WHERE DATASOURCE = 'CD'  AND [CompanyName] IS NULL
GROUP BY a.AccountNumber, a.SecurityID
)
--SELECT * FROM CTE_SDF 
,CTE_CDAccounts AS (
SELECT SDF.[AccountNumber]
	  ,SDF.[AccountName]      
      ,SDF.[SecurityID]
      ,SDF.[CompanyName]  
	  ,CD.[AccountNumber] AS CD_AccountNumber
	  ,CD.[AccountName] AS CD_AccountName
      ,CD.[SecurityID] AS CD_SecurityID
      ,CD.[CompanyName] AS CD_CompanyName

	  ,CASE
		WHEN SDF.[AccountNumber] IS NULL AND CD.[AccountNumber] IS NOT NULL THEN CD.[AccountNumber] 
		ELSE SDF.[AccountNumber]
	   END AS SDF_AccountNumber

	  ,CASE
		WHEN SDF.[AccountName] IS NULL AND CD.[AccountName] IS NOT NULL THEN CD.[AccountName]
		ELSE SDF.[AccountName]   
	   END AS SDF_AccountName
	  
	  ,CASE
		WHEN SDF.[SecurityID] IS NULL AND CD.[SecurityID] IS NOT NULL THEN CD.[SecurityID]
		ELSE SDF.[SecurityID]   
	   END AS SDF_SecurityID

	  ,CASE
		WHEN SDF.[CompanyName]  IS NULL AND CD.[CompanyName] IS NOT NULL THEN CD.[CompanyName] 
		ELSE SDF.[CompanyName]  
	   END AS SDF_CompanyName
  FROM CTE_SDF SDF   
		LEFT JOIN [SMC_DB_ASA].[dbo].[CDAccounts] CD ON CD.[AccountNumber] = SDF.AccountNumber AND CD.[SecurityID] = SDF.[SecurityID]
	--WHERE CD.[AccountNumber] IS NOT NULL
)
--SELECT * FROM CTE_CDAccounts 
,CTE_ASA AS (
SELECT a.[AccountNumber] AS ASA_AccountNumber
		,a.[MellonAccountName] AS ASA_AccountName
		,s.[MellonSecurityId] AS ASA_SecurityID
		,c.[CompanyName] AS ASA_CompanyName
FROM [SMC_DB_ASA].[asa].[Accounts] A
	join [SMC_DB_ASA].[asa].[SecurityAccounts] SA on sa.[AccountId] = a.[AccountId]
	LEFT join [SMC_DB_ASA].[asa].[Securities] S on S.[SecurityId] = sa.[SecurityId]
	LEFT join [SMC_DB_ASA].[asa].[Companies] C ON c.[CompanyId] = s.[CompanyId]
)
--SELECT * FROM CTE_ASA 
INSERT INTO @CDAccounts 
SELECT   SDF.SDF_AccountNumber
		,SDF.SDF_AccountName
		,SDF.SDF_SecurityID
		,SDF.SDF_CompanyName
		--,ASA.ASA_AccountNumber
		--,ASA.ASA_AccountName
		--,ASA_SecurityID
		--,ASA_CompanyName
FROM CTE_CDAccounts SDF
	LEFT JOIN CTE_ASA ASA ON ASA.ASA_AccountNumber = SDF.SDF_AccountNumber AND ASA.ASA_SecurityID = SDF.SDF_SecurityID
WHERE ASA.ASA_AccountNumber IS NULL
--GROUP BY SDF.SDF_AccountNumber, SDF.SecurityID
order BY SDF.SDF_AccountNumber, SDF.SecurityID


--SELECT * FROM @CDAccounts 
*/

DECLARE db_cursor CURSOR FOR  
SELECT AccountNumber
		,[Account Name]
		,SecurityID
		,CompanyName
FROM [SMC_DB_ASA].[dbo].[SDFNotInASA]
WHERE CompanyName IS NOT NULL

--FROM @CDAccounts WHERE CompanyName IS NOT NULL
set @Rownum = 1
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @AccountNumber,@AccountName,@SecurityID,@CompanyName

WHILE @@FETCH_STATUS = 0   
BEGIN   
    --Start processing 
	SET @NewAccountId = NULL
	SET @NewCompanyId = NULL
	SET @NewSecurityId = NULL
	SET @SecurityAccountId = NULL
	SET @BigString = NULL

	SELECT @BigString = ''
	SELECT @BigString = @BigString + 'AccountNumber: ' + @AccountNumber
	SELECT @BigString = @BigString + ' SecurityID: ' + @SecurityID
	SELECT @BigString = @BigString + ' AccountName: ' + @AccountName
	SELECT @BigString = @BigString + ' CompanyName: ' + @CompanyName

	/* ============================================================
	1. Insert into Accounts 
		set [AccountNumber]
			[MellonAccountName] 
			[SMCAccountName]
			[IsCustodied] = false
		capture new [AccountId]
	*/
	SELECT @NewAccountId = AccountId FROM [asa].[Accounts] WHERE [AccountNumber] = @AccountNumber
	IF @NewAccountId IS NULL
		BEGIN
			set @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Create New AccountNumber ' + @AccountNumber
			IF @DebugMode = 1 
			BEGIN				
				INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
			END ELSE 
				BEGIN					
					INSERT INTO [asa].[Accounts]
						   ([AccountNumber]
						   ,[MellonAccountName]
						   ,[SMCAccountName]
						   )
					VALUES (@AccountNumber 
						,@AccountName 
						,@AccountName 
						)
					SET @NewAccountId  = SCOPE_IDENTITY()
					set @Status = @Status + ' @NewAccountId = ' + cast(@NewAccountId as varchar(20))
					INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
				END
		END
	ELSE
		BEGIN
			set @Status = 'Row ' + cast(@Rownum as varchar(2)) + ' Exists AccountNumber ' + @AccountNumber + ' @NewAccountId = ' + cast(@NewAccountId as varchar(20))
			INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
		END
	/* ============================================================
	2. insert into [asa].[Companies]
		set [CompanyName]
			[Comment] = 'SDF Bulk Load'
		capture new [CompanyId]
	*/
	SELECT @NewCompanyId = CompanyId FROM [asa].[Companies] WHERE [CompanyName] = @CompanyName
	IF @NewCompanyId IS NULL
		BEGIN
			--set @Status = 'Row ' + cast(@Rownum as varchar(2)) + ' Create New CompanyName ' + @CompanyName + ' @NewCompanyId = ' + cast(ISNULL(@NewCompanyId,-1) as varchar(20))
			set @Status = 'Row ' + cast(@Rownum as varchar(2)) + ' Create New CompanyName ' + @CompanyName 
			IF @DebugMode = 1 
				BEGIN					
					INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
				END 
			ELSE 
				BEGIN					
					
					INSERT INTO [asa].[Companies]
						   ([CompanyName],[Comment])
					VALUES (@CompanyName ,'SDF Bulk Load')
						SET @NewCompanyId  = SCOPE_IDENTITY()
					set @Status = @Status + ' @NewCompanyId = ' + cast(ISNULL(@NewCompanyId,-1) as varchar(20))
					INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
				END
		END
	ELSE
		BEGIN
			set @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Exists CompanyName ' + @CompanyName  + ' @NewCompanyId = ' + cast(@NewCompanyId as varchar(20))
			INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
		END

	/* ============================================================
	3. insert into [asa].[Securities]
		SET [MellonSecurityId]
			[MellonDescription] = [MellonAccountName] 
			[CompanyId] = new [CompanyId]
		capture new [SecurityId]
	*/
--/*Security/Company	
	IF EXISTS(SELECT SecurityId FROM [asa].[Securities] WHERE [MellonSecurityId] = @SecurityID)
		BEGIN
			IF EXISTS(SELECT SecurityId FROM [asa].[Securities] WHERE [MellonSecurityId] = @SecurityID AND CompanyID = @NewCompanyId)

		END
	 
	SELECT @NewSecurityId = SecurityId FROM [asa].[Securities] WHERE [MellonSecurityId] = @SecurityID --and CompanyID = @NewCompanyId

	IF @NewSecurityId IS NULL
		BEGIN
			IF @DebugMode = 1 
			BEGIN
				set @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Create New [Securities] ' + @SecurityID --+ ' @@NewSecurityId = ' + cast(@NewSecurityId as varchar(20))
				INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
			END 
			ELSE 
				BEGIN
				set @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Create New [Securities] ' + @SecurityID + ' @@NewSecurityId = ' + cast(@NewSecurityId as varchar(20))
				INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
				INSERT INTO [asa].[Securities]
					   ([CompanyId]
						,[Comment]
						,[MellonSecurityId]
						,[MellonDescription]
					)
					VALUES (
						@NewCompanyId
						,'SDF Bulk Load'
						,@SecurityID
						,@AccountName
						)
					SET @NewSecurityId  = SCOPE_IDENTITY()
				END
		END
	ELSE
		BEGIN
			set @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Exists Securities ' + @SecurityID  + ' @@NewSecurityId = ' + cast(@NewSecurityId as varchar(20))
			INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
		END
--*/

/*Security/Company	
	SELECT @NewSecurityId = SecurityId FROM [asa].[Securities] WHERE [MellonSecurityId] = @SecurityID and CompanyID = @NewCompanyId
	IF @NewSecurityId IS NULL
		BEGIN
			IF @DebugMode = 1 
			BEGIN
				set @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Create New [Securities] ' + @SecurityID --+ ' @@NewSecurityId = ' + cast(@NewSecurityId as varchar(20))
				INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
			END 
			ELSE 
				BEGIN
				set @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Create New [Securities] ' + @SecurityID + ' @@NewSecurityId = ' + cast(@NewSecurityId as varchar(20))
				INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
				INSERT INTO [asa].[Securities]
					   ([CompanyId]
						,[Comment]
						,[MellonSecurityId]
						,[MellonDescription]
					)
					VALUES (
						@NewCompanyId
						,'SDF Bulk Load'
						,@SecurityID
						,@AccountName
						)
					SET @NewSecurityId  = SCOPE_IDENTITY()
				END
		END
	ELSE
		BEGIN
			set @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Exists Securities ' + @SecurityID  + ' @@NewSecurityId = ' + cast(@NewSecurityId as varchar(20))
			INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
		END
--*/
			
	/* ============================================================
	4. insert into [asa].[SecurityAccounts]
			SET [SecurityId] = new [SecurityId]
			[AccountId] = new AccountId
	*/

	SELECT @SecurityAccountId = [SecurityAccountId] FROM [asa].[SecurityAccounts] 
	WHERE Accountid = @NewAccountId and [SecurityId] = @NewSecurityId
	IF @SecurityAccountId IS NULL
		BEGIN
			IF @DebugMode = 1 
			BEGIN
				set @Status = 'Row ' + cast(@Rownum as varchar(2)) + ' Create New [SecurityAccounts] AccountId: ' + CAST(ISNULL(@NewAccountId,'') AS VARCHAR(10)) + ' [SecurityId]: ' + CAST(ISNULL(@NewSecurityId,'') AS VARCHAR(10))
				INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
			END ELSE BEGIN

				set @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Create New [SecurityAccounts] AccountId: ' + CAST(ISNULL(@NewAccountId,'') AS VARCHAR(10)) + ' [SecurityId]: ' + CAST(ISNULL(@NewSecurityId,'') AS VARCHAR(10))
				INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)

				INSERT INTO [asa].[SecurityAccounts]
			           ([SecurityId]
			           ,[AccountId]
					   )
					VALUES (
					@NewSecurityId
					,@NewAccountId
					)
				END
		END
	ELSE
		BEGIN
			set @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Exists SecurityAccounts ' +  CAST(ISNULL(@SecurityAccountId,'') AS VARCHAR(20))
			INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
		END

	--UPDATE CDAccounts set Processed = 1 where CDAccountsID = @CDAccountsID 
	set @Rownum = @Rownum + 1
	--Finish processing 
	FETCH NEXT FROM db_cursor INTO @AccountNumber,@AccountName,@SecurityID,@CompanyName

END   

CLOSE db_cursor   
DEALLOCATE db_cursor 

SELECT * FROM @Debug


--ROLLBACK TRANSACTION T1
COMMIT TRANSACTION T1

--ALTER TABLE [asa].[SecurityAccounts]  WITH CHECK ADD  CONSTRAINT [fk_SecurityAccounts_Accounts] FOREIGN KEY([AccountId])
--REFERENCES [asa].[Accounts] ([AccountId])
--GO

