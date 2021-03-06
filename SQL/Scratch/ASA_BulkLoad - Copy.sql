
--The INSERT statement conflicted with the FOREIGN KEY constraint "fk_SecurityAccounts_Accounts". The conflict occurred in database "SMC_DB_ASA", table "asa.Accounts", column 'AccountId'.
/*
column for SDFAccounts mapping
SELECT [AccountNumber]	= accounts.[AccountNumber]
      ,[Account Name]	= accounts.[MellonAccountName]
      ,[SecurityID]		= [asa].[Securities].[MellonSecurityId]
      ,[Mellon Name]	= [asa].[Securities].[MellonDescription]
      ,[Company Name]	= [asa].[Companies].[CompanyName]
      ,[Inception Date]
      ,[Cost Basis]
      ,[Investment Classification]	= [asa].[Securities].[InvestmentClassification]
      ,[Series]						= [asa].[Securities].[LotDescription]
      ,[Sponsor Name]				= [asa].[SecurityAccountSponsors].[SponsorName]
      ,[Firm Name]					= [asa].[SecurityAccountSponsors].[FirmName]
      ,[Sector]						= [asa].[SecurityAccounts].[Sector]
      ,[Sub Sector]					= [asa].[SecurityAccounts].[SubSector]
      ,[Security Status]			= [asa].[Securities].[SecurityStatus]
  FROM [SMC_DB_ASA].[dbo].[SDFAccounts]

*/

USE SMC_DB_ASA
GO

SET NOCOUNT ON


/*-------------------------------------------------------------------------------------
 Read ALL the Data 
 */
 /*
;WITH CTE_DATA AS (
SELECT  X.[ACCOUNT NAME]
		,A.[AccountId]
		,S.[SecurityId]
		,C.[CompanyId]
		,SA.[SecurityAccountId]
		,SAS.[SecurityAccountSponsorId]
FROM	[SMC_DB_ASA].[dbo].[SDFAccounts] X
LEFT	JOIN [asa].[Accounts] A ON A.[AccountNumber] = X.[AccountNumber]
LEFT	JOIN [asa].[Securities] S ON S.[MellonSecurityId] = X.[SecurityID]
LEFT	JOIN [asa].[Companies] C ON C.[CompanyId] = S.[CompanyId]
LEFT	JOIN [asa].[SecurityAccounts] SA ON SA.[AccountId] = A.[AccountId] AND SA.[SecurityId] = S.[SecurityId]
LEFT	JOIN [asa].[SecurityAccountSponsors] SAS ON SAS.[SecurityAccountId] = SA.[SecurityAccountID]
)
--SELECT * FROM CTE_DATA X JOIN [asa].[SecurityAccountSponsors] SAS ON SAS.[SecurityAccountSponsorId] =  X.[SecurityAccountSponsorId]
--SELECT * FROM CTE_DATA X JOIN [asa].[SecurityAccounts] SA ON SA.[SecurityAccountId] =  X.[SecurityAccountId]
--SELECT * FROM CTE_DATA X JOIN  [asa].[Securities] S  ON  s.[SecurityID] =  X.[SecurityID]
--SELECT * FROM CTE_DATA X JOIN [asa].[Companies] C ON C.[CompanyId]  =  X.[CompanyId] --AND C.Comment = 'SDF Bulk Load'
--SELECT * FROM CTE_DATA X JOIN [asa].[Accounts] A ON  A.[AccountId] =  X.[AccountId]
--*/

--BEGIN TRANSACTION T1

DECLARE @Debug TABLE([Status] varchar(100), BigString VARCHAR(max))

DECLARE @Status varchar(100)
		,@BigString varchar(MAX)
		,@DebugMode bit
SET @DebugMode  = 1

DECLARE @AccountNumber NVARCHAR(50)
	,@AccountName NVARCHAR(255)
	,@SecurityID NVARCHAR(25)
	,@CompanyName NVARCHAR(255)
	,@MellonName NVARCHAR(255)
	,@InvestmentClassification  NVARCHAR(255)
	,@Series  NVARCHAR(255)
	,@SponsorName  NVARCHAR(255)
	,@FirmName  NVARCHAR(255)
	,@Sector  NVARCHAR(255)
	,@SubSector  NVARCHAR(255)
	,@SecurityStatus  NVARCHAR(255)
	,@Processed INT
	,@NewAccountId int
	,@NewCompanyId int
	,@NewSecurityId  int
	,@SecurityAccountId int
	,@SecurityAccountSponsorId int
	,@Rownum int = 0

DECLARE @Data TABLE (Rownumber int, AccountNumber VARCHAR(50), AccountName  VARCHAR(255) ,SecurityID  VARCHAR(50),MellonName  VARCHAR(255),CompanyName  VARCHAR(255),InvestmentClassification  VARCHAR(25)
,Series  VARCHAR(25) ,SponsorName  VARCHAR(255),FirmName  VARCHAR(255),Sector  VARCHAR(25),SubSector  VARCHAR(25) ,SecurityStatus  VARCHAR(25))

--Row_number() OVER (PARTITION BY AccountNumber,SecurityID ) ,AccountNumber, AccountName  ,SecurityID  ,MellonName  ,CompanyName  ,InvestmentClassification  ,Series  ,SponsorName  ,FirmName  ,Sector  ,SubSector  ,SecurityStatus 
INSERT INTO @Data 
SELECT 
Row_number() OVER (ORDER BY AccountNumber,SecurityID ) 
,AccountNumber
,[Account Name]
,SecurityID
,[Mellon Name]
,[Company Name]
,[Investment Classification]
,Series
,[Sponsor Name]
,[Firm Name]
,[Sector]
,[Sub Sector]
,[Security Status]
FROM [SMC_DB_ASA].[dbo].[SDFAccounts]

SELECT * FROM @Data

DECLARE db_cursor CURSOR FOR  
SELECT 
AccountNumber
,[Account Name]
,SecurityID
,[Mellon Name]
,[Company Name]
,[Investment Classification]
,Series
,[Sponsor Name]
,[Firm Name]
,[Sector]
,[Sub Sector]
,[Security Status]
FROM [SMC_DB_ASA].[dbo].[SDFAccounts]

set @Rownum = 1
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @AccountNumber,@AccountName,@SecurityID,@MellonName,@CompanyName,@InvestmentClassification  ,@Series  ,@SponsorName ,@FirmName,@Sector,@SubSector,@SecurityStatus

WHILE @@FETCH_STATUS = 0   
BEGIN   
    --Start processing 
	SET @NewAccountId = NULL
	SET @NewCompanyId = NULL
	SET @NewSecurityId = NULL
	SET @SecurityAccountId = NULL
	SET @SecurityAccountSponsorId = NULL
	SET @BigString = 'AccountNumber: ' + @AccountNumber + ' SecurityID: ' + @SecurityID + ' AccountName: ' + @AccountName + ' CompanyName: ' + @CompanyName

	/* ============================================================
	1. Insert into Accounts set [AccountNumber]	[MellonAccountName] [SMCAccountName][IsCustodied] = false
	*/
--/*Accounts
	set @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Check AccountNumber: ' + @AccountNumber 
	INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)

	--IF EXISTS(SELECT AccountId FROM [asa].[Accounts] WHERE [AccountNumber] = @AccountNumber)
	--	BEGIN
	--		SELECT @NewAccountId = AccountId FROM [asa].[Accounts] WHERE [AccountNumber] = @AccountNumber
	--		set @Status = 'Row ' + cast(@Rownum as varchar(2)) + ' Exists AccountNumber ' + @AccountNumber + ' @NewAccountId = ' + cast(@NewAccountId as varchar(20))
	--	END
	--ELSE
	--	--NO RECORD
	--	BEGIN
	--		set @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Create New AccountNumber ' + @AccountNumber
	--		IF @DebugMode = 0
	--			BEGIN
	--				INSERT INTO [asa].[Accounts] ([AccountNumber],[MellonAccountName],[SMCAccountName]) VALUES (@AccountNumber ,@AccountName ,@AccountName )
	--				SET @NewAccountId  = SCOPE_IDENTITY()
	--				set @Status = @Status + ' @NewAccountId = ' + cast(@NewAccountId as varchar(20))
	--			END
	--	END
	--INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)

	--IF @NewAccountId IS NULL
	--	INSERT INTO @Debug ([Status],BigString ) values ('Warning - @NewAccountId IS NULL',@BigString)
--*/

/* ============================================================
	2. insert into [asa].[Companies]     	
*/
/*Companies
	set @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Check @CompanyName: ' + @CompanyName 
	INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)

	IF EXISTS(SELECT CompanyId FROM [asa].[Companies] WHERE [CompanyName] = @CompanyName)
		BEGIN
			SELECT @NewCompanyId = CompanyId FROM [asa].[Companies] WHERE [CompanyName] = @CompanyName			
			set @Status = 'Row ' + cast(@Rownum as varchar(2)) + ' Exists CompanyName ' + @CompanyName + ' @NewCompanyId = ' + cast(@NewCompanyId as varchar(20))
		END
	ELSE
		--NO RECORD
		BEGIN
			set @Status = 'Row ' + cast(@Rownum as varchar(2)) + ' Create New CompanyName ' + @CompanyName 
			IF @DebugMode = 0
				BEGIN
					INSERT INTO [asa].[Companies] ([CompanyName],[Comment])	VALUES (@CompanyName ,'SDF Bulk Load')
					SET @NewCompanyId  = SCOPE_IDENTITY()
					set @Status = @Status + ' @NewCompanyId = ' + cast(ISNULL(@NewCompanyId,-1) as varchar(20))
				END
		END
	INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)

	IF @NewCompanyId IS NULL
		INSERT INTO @Debug ([Status],BigString ) values ('Warning - @NewCompanyId IS NULL',@BigString)

--*/

/* ============================================================
	3. insert into [asa].[Securities]
*/
/*Security/Company	
	set @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Check Security/Company @SecurityID= ' + @SecurityID + ' @CompanyId = ' + cast(@NewCompanyId as varchar(20))
	INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)

	IF EXISTS(SELECT SecurityId FROM [asa].[Securities] WHERE [MellonSecurityId] = @SecurityID)
		BEGIN
			IF EXISTS(SELECT CompanyID FROM [asa].[Securities] WHERE [MellonSecurityId] = @SecurityID AND CompanyID = @NewCompanyId)
				BEGIN
					--Both id's exist
					SELECT @NewSecurityId = SecurityId FROM [asa].[Securities] WHERE [MellonSecurityId] = @SecurityID AND CompanyID = @NewCompanyId
					set @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Exists Securities/Company ' + @SecurityID + ' @NewSecurityId = ' + cast(isnull(@NewSecurityId,'') as varchar(20)) + ' @NewCompanyId = ' + cast(@NewCompanyId as varchar(20))
				END
			ELSE
				BEGIN
				-- Company does NOT Exists 
				IF @DebugMode = 0
					BEGIN						
						INSERT INTO [asa].[Securities] 
								([CompanyId],[Comment],[MellonSecurityId],[MellonDescription],[InvestmentClassification],[LotDescription],[SecurityStatus]) 
						VALUES  (@NewCompanyId,'SDF Bulk Load',@SecurityID,@AccountName,@InvestmentClassification,@Series,@SecurityStatus)
						SET @NewSecurityId  = SCOPE_IDENTITY()
						SET @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Create New Securities/Company ' + @SecurityID + ' @NewSecurityId = ' + cast(isnull(@NewSecurityId,'') as varchar(20)) + ' @NewCompanyId = ' + cast(@NewCompanyId as varchar(20))
					END
				END
		END
	ELSE
		BEGIN
			-- Security does not exist
				IF @DebugMode = 0
					BEGIN
						INSERT INTO [asa].[Securities] 
								([CompanyId],[Comment],[MellonSecurityId],[MellonDescription],[InvestmentClassification],[LotDescription],[SecurityStatus]) 
						VALUES  (@NewCompanyId,'SDF Bulk Load',@SecurityID,@AccountName,@InvestmentClassification,@Series,@SecurityStatus)
						SET @NewSecurityId  = SCOPE_IDENTITY()
						SET @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Create New Securities/Company ' + @SecurityID + ' @NewSecurityId = ' + cast(isnull(@NewSecurityId,'') as varchar(20)) + ' @NewCompanyId = ' + cast(@NewCompanyId as varchar(20))
					END
		END	 
	INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
	
	IF @NewSecurityId IS NULL
		INSERT INTO @Debug ([Status],BigString ) values ('Warning - @NewSecurityId IS NULL',@BigString)
	IF @NewCompanyId IS NULL
		INSERT INTO @Debug ([Status],BigString ) values ('Warning - @NewCompanyId (on Securities) IS NULL',@BigString)
--*/

/* ============================================================
	4. insert into [asa].[SecurityAccounts]
*/
/*
set @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Check SecurityAccounts  Accountid: ' + cast(@NewAccountId as varchar(20)) + ' @[SecurityId] = '  + cast(isnull(@NewSecurityId,'') as varchar(20)) 
INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)

IF EXISTS(SELECT [SecurityAccountId] FROM [asa].[SecurityAccounts] WHERE Accountid = @NewAccountId and [SecurityId] = @NewSecurityId)
	BEGIN
		SELECT @SecurityAccountId  = [SecurityAccountId] FROM [asa].[SecurityAccounts] WHERE Accountid = @NewAccountId and [SecurityId] = @NewSecurityId
		SET @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Exists SecurityAccounts [SecurityAccountId] = ' +  CAST(@SecurityAccountId AS VARCHAR(20)) + ' [SecurityId] = ' + cast(isnull(@NewSecurityId,'') AS VARCHAR(20)) + ' [AccountId] = ' + CAST(@NewAccountId AS VARCHAR(20))
	END
ELSE
	BEGIN
		--[SecurityAccounts] record does not exist
		IF @DebugMode = 0
			BEGIN
				INSERT INTO [asa].[SecurityAccounts] 
				   		([SecurityId],[AccountId],Sector,SubSector) 
				VALUES	(@NewSecurityId,@NewAccountId,@Sector,@SubSector)
				SET @SecurityAccountId  = SCOPE_IDENTITY()
				set @Status = 'Row ' + cast(@Rownum as varchar(2)) + ' Create New [SecurityAccounts] @SecurityAccountId = ' + CAST(@SecurityAccountId AS VARCHAR(10))   + 'AccountId: ' + CAST(@NewAccountId AS VARCHAR(10)) + ' [SecurityId]: ' + cast(isnull(@NewSecurityId,'') AS VARCHAR(10)) 
			END
	END
	INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
	IF @SecurityAccountId IS NULL
		INSERT INTO @Debug ([Status],BigString ) values ('Warning - @SecurityAccountId (on [SecurityAccounts]) IS NULL',@BigString)
--*/

/* ============================================================
	5. insert into [asa].[SecurityAccountSponsors]
*/
/*
set @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Check SecurityAccountSponsors @SecurityAccountId : ' + cast(ISNULL(@SecurityAccountId ,'') as varchar(20)) 
INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)

IF EXISTS(SELECT [SecurityAccountSponsorId] FROM [asa].SecurityAccountSponsors WHERE [SecurityAccountId] = @SecurityAccountId)
	BEGIN
		SELECT @SecurityAccountSponsorId  = SecurityAccountSponsorId FROM [asa].SecurityAccountSponsors WHERE  [SecurityAccountId] = @SecurityAccountId
		SET @Status =  'Row ' + cast(@Rownum as varchar(2)) + ' Exists SecurityAccountSponsors [SecurityAccountSponsorId] = ' +  CAST( @SecurityAccountSponsorId AS VARCHAR(20)) 
	
	END
ELSE
	BEGIN
		--[SecurityAccounts] record does not exist
		IF @DebugMode = 0
			BEGIN
				INSERT INTO [asa].SecurityAccountSponsors 
				   		([SecurityAccountId],[SponsorName],[FirmName]) 
				VALUES	(@SecurityAccountId,@SponsorName,@FirmName)
				SET @SecurityAccountId  = SCOPE_IDENTITY()
				set @Status = 'Row ' + cast(@Rownum as varchar(2)) + ' Create New [SecurityAccountSponsors] @@SecurityAccountId = ' + CAST(@SecurityAccountId AS VARCHAR(10))   
			END
	END
	INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
	IF @SecurityAccountSponsorId IS NULL
		INSERT INTO @Debug ([Status],BigString ) values ('Warning - @SecurityAccountSponsorId  (on [SecurityAccountSponsors]) IS NULL',@BigString)

	set @Rownum = @Rownum + 1
	--Finish processing 
	FETCH NEXT FROM db_cursor INTO @AccountNumber,@AccountName,@SecurityID,@CompanyName
--*/
END   

CLOSE db_cursor   
DEALLOCATE db_cursor 

SELECT * FROM @Debug

ROLLBACK TRANSACTION T1

--COMMIT TRANSACTION T1


