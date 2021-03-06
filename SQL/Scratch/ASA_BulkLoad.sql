
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
	  
		New			19001	INVESTMENT_CLASSIFICATION	New		1	1	0	NULL
		Follow-On	19002	INVESTMENT_CLASSIFICATION	Follow-On 		2	1	0	NULL

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

/* Back up data
SELECT * INTO DBO.[AccountsBKP_V1] FROM  [asa].[Accounts]
SELECT * INTO [dbo].[SecuritiesBKP_V1] FROM [asa].[Securities] 
SELECT * INTO [dbo].[CompaniesBKP_V1] FROM [asa].[Companies] 
SELECT * INTO [dbo].[SecurityAccountsBKP_V1]  FROM [asa].[SecurityAccounts] 
*/

SET NOCOUNT ON

--SELECT  * FROM	[SMC_DB_ASA].[dbo].[SDFAccounts] X

/*  Read ALL the Data */

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
SELECT * FROM CTE_DATA X JOIN [asa].[Accounts] A ON  A.[AccountId] =  X.[AccountId]

--*/

BEGIN TRANSACTION T1

DECLARE @Debug TABLE([Status] varchar(max), BigString VARCHAR(max))

DECLARE @Status varchar(max)
		,@BigString varchar(MAX)
		,@DebugMode bit
SET @DebugMode  = 0

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
	,@NewAccountId BIGINT
	,@NewCompanyId BIGINT
	,@NewSecurityId  BIGINT
	,@SecurityAccountId BIGINT
	,@SecurityAccountSponsorId BIGINT
	,@RowNum int = 0
	,@MaxRowNum int = 0
	,@InvestmentClassificationid BIGINT
	,@SecurityStatusID BIGINT
	,@Sectorid bigint
	,@SubSectorid bigint

DECLARE @Data TABLE (Rownumber int
	, AccountNumber VARCHAR(255)
	, AccountName  VARCHAR(255) 
	,SecurityID  VARCHAR(255)
	,MellonName  VARCHAR(255)
	,CompanyName  VARCHAR(255)
	,InvestmentClassification  VARCHAR(255)
	,Series  VARCHAR(255) 
	,SponsorName  VARCHAR(255)
	,FirmName  VARCHAR(255)
	,Sector  VARCHAR(255)
	,SubSector  VARCHAR(255) 
	,SecurityStatus  VARCHAR(255))

INSERT INTO @Data 
SELECT Row_number() OVER (ORDER BY AccountNumber,SecurityID ) 
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

--SELECT * FROM @Data

SELECT @MaxRowNum = MAX(Rownumber) FROM @Data

--PRINT CAST(@MAXrOWnUM AS VARCHAR(5))

set @Rownum = 1

WHILE @Rownum <= @MaxRowNum 
	BEGIN
		SELECT	@AccountNumber = AccountNumber
				,@AccountName = AccountName 
				,@SecurityID = SecurityID
				,@MellonName = MellonName
				,@CompanyName = CompanyName
				,@InvestmentClassification = InvestmentClassification   
				,@Series  = Series  
				,@SponsorName = SponsorName 
				,@FirmName = FirmName
				,@Sector = Sector
				,@SubSector = SubSector
				,@SecurityStatus = SecurityStatus
		FROM @Data
		WHERE Rownumber = @Rownum

		SET @InvestmentClassificationid = NULL
		IF EXISTS (SELECT [LookupId] FROM [SMC_DB_ASA].[asa].[Lookups] WHERE [LookupCategory] = 'INVESTMENT_CLASSIFICATION' AND [LookupText] = @InvestmentClassification)
			BEGIN
				SELECT @InvestmentClassificationid  = [LookupId]	FROM [SMC_DB_ASA].[asa].[Lookups] WHERE [LookupCategory] = 'INVESTMENT_CLASSIFICATION' AND [LookupText] = @InvestmentClassification
			END
		SET @InvestmentClassificationid = isnull(@InvestmentClassificationid,0)  

		SET @SecurityStatusID = NULL
		IF EXISTS (SELECT [LookupId] FROM [SMC_DB_ASA].[asa].[Lookups] WHERE [LookupCategory] = 'SECURITY_STATUS' AND [LookupText] = @SecurityStatus)
			BEGIN
				SELECT @SecurityStatusID = [LookupId] FROM [SMC_DB_ASA].[asa].[Lookups] WHERE [LookupCategory] = 'SECURITY_STATUS' AND [LookupText] = @SecurityStatus
			END
		SET @SecurityStatusID = isnull(@SecurityStatusID,0)  
	
		SET @Sectorid   = NULL
		IF EXISTS (SELECT [LookupId] FROM [SMC_DB_ASA].[asa].[Lookups] WHERE [LookupCategory] = 'COMPANY_SECTOR' AND [LookupText] = @Sector)
			BEGIN
				SELECT @Sectorid  = [LookupId]	FROM [SMC_DB_ASA].[asa].[Lookups] WHERE [LookupCategory] = 'COMPANY_SECTOR' AND [LookupText] = @Sector
			END
		SET @Sectorid = isnull(@Sectorid,0)  

		SET @SubSectorid = NULL
		IF EXISTS(SELECT [LookupId] FROM [SMC_DB_ASA].[asa].[Lookups] WHERE [LookupCategory] = 'COMPANY_SUB_SECTOR' AND [LookupText] = @SubSector)
			BEGIN
				SELECT @SubSectorid  = [LookupId] FROM [SMC_DB_ASA].[asa].[Lookups] WHERE [LookupCategory] = 'COMPANY_SUB_SECTOR' AND [LookupText] = @SubSector
			END
		SET @SubSectorid = isnull(@SubSectorid,0)  

    --Start processing 
	SET @NewAccountId = NULL
	SET @NewCompanyId = NULL
	SET @NewSecurityId = NULL
	SET @SecurityAccountId = NULL
	SET @SecurityAccountSponsorId = NULL
	--SET @BigString = 'AccountNumber: ' + @AccountNumber + ' SecurityID: ' + @SecurityID + ' AccountName: ' + @AccountName + ' CompanyName: ' + @CompanyName

	SET @BigString = @AccountNumber + ' AccountNumber '
				+ @AccountName + '  AccountName '
				+ @SecurityID + '  SecurityID '
				+ @MellonName + '  MellonName '
				+ @CompanyName + '  CompanyName '
				+ @InvestmentClassification + '  InvestmentClassification    '
				+ @Series  + '  Series   '
				+ @SponsorName + '  SponsorName  '
				+ @FirmName + '  FirmName '
				+ @Sector + '  Sector '
				+ cast(ISNULL(@SectorID,-1) as varchar(20))  + '  SectorID '
				+ @SubSector + '  SubSector '
				+ cast(ISNULL(@SubSectorID,-1) as varchar(20))  + ' SubSectorID '
				+ @SecurityStatus + '  SecurityStatus '
				+ cast(ISNULL(@SecurityStatusID,-1) as varchar(20))  + ' SecurityStatusID'
				
	/* ============================================================
	1. Insert into Accounts set [AccountNumber]	[MellonAccountName] [SMCAccountName][IsCustodied] = false	*/

--/*=========================================            Accounts
	set @Status =  'Row ' + cast(@Rownum as varchar(5)) + ' Check AccountNumber: ' + @AccountNumber 
	INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)

	IF EXISTS(SELECT AccountId FROM [asa].[Accounts] WHERE [AccountNumber] = @AccountNumber)
		BEGIN
			SELECT @NewAccountId = AccountId FROM [asa].[Accounts] WHERE [AccountNumber] = @AccountNumber
			set @Status = 'Row ' + cast(@Rownum as varchar(5)) + ' Exists AccountNumber ' + @AccountNumber + ' @NewAccountId = ' + cast(@NewAccountId as varchar(20))
		END
	ELSE
		--NO RECORD
		BEGIN
			set @Status =  'Row ' + cast(@Rownum as varchar(5)) + ' Create New AccountNumber ' + @AccountNumber
			IF @DebugMode = 0
				BEGIN
					INSERT INTO [asa].[Accounts] ([AccountNumber],[MellonAccountName],[SMCAccountName]) VALUES (@AccountNumber ,@AccountName ,@AccountName )
					SET @NewAccountId  = SCOPE_IDENTITY()
					set @Status = @Status + ' @NewAccountId = ' + cast(@NewAccountId as varchar(20))
				END
		END
	INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)

	IF @NewAccountId IS NULL
		INSERT INTO @Debug ([Status],BigString ) values ('Warning - @NewAccountId IS NULL',@BigString)
--*/

/* ============================================================
	2. insert into [asa].[Companies]     	
*/
--/*Companies
	set @Status =  'Row ' + cast(@Rownum as varchar(5)) + ' Check @CompanyName: ' + @CompanyName 
	INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)

	IF EXISTS(SELECT CompanyId FROM [asa].[Companies] WHERE [CompanyName] = @CompanyName)
		BEGIN
			SELECT @NewCompanyId = CompanyId FROM [asa].[Companies] WHERE [CompanyName] = @CompanyName			
			set @Status = 'Row ' + cast(@Rownum as varchar(5)) + ' Exists CompanyName ' + @CompanyName + ' @NewCompanyId = ' + cast(@NewCompanyId as varchar(20))
		END
	ELSE
		--NO RECORD
		BEGIN
			set @Status = 'Row ' + cast(@Rownum as varchar(5)) + ' Create New CompanyName ' + @CompanyName 
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

/* ============================================================ 3. insert into [asa].[Securities] */
--/*Security/Company	

	set @Status =  'Row ' + cast(@Rownum as varchar(5)) + ' Check Security/Company @SecurityID= ' + @SecurityID + ' @CompanyId = ' + cast(@NewCompanyId as varchar(20))
	INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)

	IF EXISTS(SELECT SecurityId FROM [asa].[Securities] WHERE [MellonSecurityId] = @SecurityID)
		BEGIN
			IF EXISTS(SELECT CompanyID FROM [asa].[Securities] WHERE [MellonSecurityId] = @SecurityID AND CompanyID = @NewCompanyId)
				BEGIN
					--Both id's exist
					SELECT @NewSecurityId = SecurityId FROM [asa].[Securities] WHERE [MellonSecurityId] = @SecurityID AND CompanyID = @NewCompanyId
					set @Status =  'Row ' + cast(@Rownum as varchar(5)) + ' Exists Securities/Company ' + @SecurityID + ' @NewSecurityId = ' + cast(isnull(@NewSecurityId,'') as varchar(20)) + ' @NewCompanyId = ' + cast(@NewCompanyId as varchar(20))
				END
			ELSE
				BEGIN
				-- Company does NOT Exists 
				IF @DebugMode = 0
					BEGIN						
						INSERT INTO [asa].[Securities] 
							([CompanyId],[InvestmentClassification],[Comment],[LotDescription],[SecurityStatus],[MellonSecurityId],[MellonDescription]) 
						VALUES  (@NewCompanyId,@InvestmentClassificationid,'SDF Bulk Load',@Series,@SecurityStatusID,@SecurityID,@AccountName)					
						SET @NewSecurityId  = SCOPE_IDENTITY()
						--SET @Status =  'Row ' + cast(@Rownum as varchar(5)) + ' Create New Securities/Company ' + @SecurityID + ' @NewSecurityId = ' + cast(isnull(@NewSecurityId,'') as varchar(20)) + ' @NewCompanyId = ' + cast(@NewCompanyId as varchar(20))
						SET @Status =  'Row Create New Securities for Company: @Rownum' + cast(@Rownum as varchar(5)) 
							+ ' @NewCompanyId = ' + cast(@NewCompanyId as varchar(20))
							+ ' @InvestmentClassification" ' + @InvestmentClassification
							+ ' @Series: ' + @Series
							+ ' @SecurityStatus: ' + @SecurityStatus
							+ ' [MellonSecurityId] ' + @SecurityID
							+ ' [MellonDescription] ' + @AccountName
							+ ' @NewSecurityId = ' + cast(@NewSecurityId as varchar(20))

					END
				END
		END
	ELSE
		BEGIN
			-- Security does not exist
				IF @DebugMode = 0
					BEGIN					
						INSERT INTO [asa].[Securities] 
							([CompanyId],[InvestmentClassification],[Comment],[LotDescription],[SecurityStatus],[MellonSecurityId],[MellonDescription]) 
						VALUES  (@NewCompanyId,@InvestmentClassificationid,'SDF Bulk Load',@Series,@SecurityStatusID,@SecurityID,@AccountName)					
						SET @NewSecurityId  = SCOPE_IDENTITY()
						--SET @Status =  'Row ' + cast(@Rownum as varchar(5)) + ' Create New Securities/Company ' + @SecurityID + ' @NewSecurityId = ' + cast(isnull(@NewSecurityId,'') as varchar(20)) + ' @NewCompanyId = ' + cast(@NewCompanyId as varchar(20))
						SET @Status =  'Row Create New Securities/Company: @Rownum' + cast(@Rownum as varchar(5)) 
							+ ' @NewCompanyId = ' + cast(@NewCompanyId as varchar(20))
							+ ' @InvestmentClassification" ' + @InvestmentClassification
							+ ' @Series: ' + @Series
							+ ' @SecurityStatus: ' + @SecurityStatus
							+ ' [MellonSecurityId] ' + @SecurityID
							+ ' [MellonDescription] ' + @AccountName
							+ ' @NewSecurityId = ' + cast(@NewSecurityId as varchar(20))

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
--/*
set @Status =  'Row ' + cast(@Rownum as varchar(5)) + ' Check SecurityAccounts  Accountid: ' + cast(@NewAccountId as varchar(20)) + ' @[SecurityId] = '  + cast(isnull(@NewSecurityId,'') as varchar(20)) 
INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)

IF EXISTS(SELECT [SecurityAccountId] FROM [asa].[SecurityAccounts] WHERE Accountid = @NewAccountId and [SecurityId] = @NewSecurityId)
	BEGIN
		SELECT @SecurityAccountId  = [SecurityAccountId] FROM [asa].[SecurityAccounts] WHERE Accountid = @NewAccountId and [SecurityId] = @NewSecurityId
		SET @Status =  'Row ' + cast(@Rownum as varchar(5)) + ' Exists SecurityAccounts [SecurityAccountId] = ' +  CAST(@SecurityAccountId AS VARCHAR(20)) + ' [SecurityId] = ' + cast(isnull(@NewSecurityId,'') AS VARCHAR(20)) + ' [AccountId] = ' + CAST(@NewAccountId AS VARCHAR(20))
	END
ELSE
	BEGIN
		--[SecurityAccounts] record does not exist
		IF @DebugMode = 0
			BEGIN
				SET @Status =  'Row : @Rownum' + cast(@Rownum as varchar(5)) 
							+ ' Create New SecurityAccounts '
				INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
					SET @Status =  'INSERT INTO [asa].[SecurityAccounts] ([SecurityId],[AccountId],Sector,SubSector)  '
							+ ' VALUES	( ' 
							+  cast(@NewSecurityId as varchar(20))
							+ ',' + cast(@NewAccountId as varchar(20))
							+ ',' + cast(@Sectorid as varchar(20))
							+ ',' + cast(@SubSectorid as varchar(20))
							+ ')'

				INSERT INTO [asa].[SecurityAccounts] 
				   		([SecurityId]
						,[AccountId]
						,Sector
						,SubSector) 
				VALUES	(@NewSecurityId
						,@NewAccountId
						,@Sectorid
						,@SubSectorid)
				SET @SecurityAccountId  = SCOPE_IDENTITY()
			END
	END
	INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
	IF @SecurityAccountId IS NULL
		INSERT INTO @Debug ([Status],BigString ) values ('Warning - @SecurityAccountId (on [SecurityAccounts]) IS NULL',@BigString)
--*/


/* 5. insert into [asa].[SecurityAccountSponsors] */
--/*===================================================================================================================
set @Status =  'Row ' + cast(@Rownum as varchar(5)) + ' Check SecurityAccountSponsors @SecurityAccountId : ' + cast(ISNULL(@SecurityAccountId ,'') as varchar(20)) 
INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)

IF EXISTS(SELECT [SecurityAccountSponsorId] FROM [asa].SecurityAccountSponsors WHERE [SecurityAccountId] = @SecurityAccountId)
	BEGIN
		SELECT @SecurityAccountSponsorId  = SecurityAccountSponsorId FROM [asa].SecurityAccountSponsors WHERE  [SecurityAccountId] = @SecurityAccountId
		SET @Status =  'Row ' + cast(@Rownum as varchar(5)) + ' Exists SecurityAccountSponsors [SecurityAccountSponsorId] = ' +  CAST( @SecurityAccountSponsorId AS VARCHAR(20)) 
	
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
				set @Status = 'Row ' + cast(@Rownum as varchar(5)) + ' Create New [SecurityAccountSponsors] @@SecurityAccountId = ' + CAST(@SecurityAccountId AS VARCHAR(10))   
			END
	END
	INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
	IF @SecurityAccountSponsorId IS NULL
		INSERT INTO @Debug ([Status],BigString ) values ('Warning - @SecurityAccountSponsorId  (on [SecurityAccountSponsors]) IS NULL',@BigString)

--*/

	SET @Rownum = @Rownum + 1;

END -- END WHILE

SELECT * FROM @Debug


--/*

;WITH CTE_DATA AS (
SELECT 'Accounts' as TableName,  X.[ACCOUNT NAME],A.[AccountId]
FROM	[SMC_DB_ASA].[dbo].[SDFAccounts] X
JOIN [asa].[Accounts] A ON A.[AccountNumber] = X.[AccountNumber]
)
SELECT * FROM CTE_DATA X JOIN [asa].[Accounts] A ON  A.[AccountId] =  X.[AccountId]


;WITH CTE_DATA AS (
SELECT  'Companies' as TableName,   X.[ACCOUNT NAME],A.[AccountId],S.[SecurityId],C.[CompanyId]
FROM	[SMC_DB_ASA].[dbo].[SDFAccounts] X
JOIN [asa].[Accounts] A ON A.[AccountNumber] = X.[AccountNumber]
JOIN [asa].[Securities] S ON S.[MellonSecurityId] = X.[SecurityID]
JOIN [asa].[Companies] C ON C.[CompanyId] = S.[CompanyId]
)
SELECT * FROM CTE_DATA X JOIN [asa].[Companies] C ON C.[CompanyId]  =  X.[CompanyId] AND C.Comment = 'SDF Bulk Load'

;WITH CTE_DATA AS (
SELECT  'Securities' as TableName,  X.[ACCOUNT NAME],A.[AccountId],S.[SecurityId]
FROM	[SMC_DB_ASA].[dbo].[SDFAccounts] X
JOIN [asa].[Accounts] A ON A.[AccountNumber] = X.[AccountNumber]
JOIN [asa].[Securities] S ON S.[MellonSecurityId] = X.[SecurityID]
)
SELECT * FROM CTE_DATA X JOIN  [asa].[Securities] S  ON  s.[SecurityID] =  X.[SecurityID] AND s.Comment = 'SDF Bulk Load'
 
;WITH CTE_DATA AS (
SELECT  'SecurityAccounts' as TableName,  X.[ACCOUNT NAME],A.[AccountId],S.[SecurityId],C.[CompanyId],SA.[SecurityAccountId]
FROM	[SMC_DB_ASA].[dbo].[SDFAccounts] X
JOIN [asa].[Accounts] A ON A.[AccountNumber] = X.[AccountNumber]
JOIN [asa].[Securities] S ON S.[MellonSecurityId] = X.[SecurityID]
JOIN [asa].[Companies] C ON C.[CompanyId] = S.[CompanyId]
JOIN [asa].[SecurityAccounts] SA ON SA.[AccountId] = A.[AccountId] AND SA.[SecurityId] = S.[SecurityId]

)
SELECT * FROM CTE_DATA X JOIN [asa].[SecurityAccounts] SA ON SA.[SecurityAccountId] =  X.[SecurityAccountId]


;WITH CTE_DATA AS (
SELECT  'SecurityAccountSponsors' as TableName,  X.[ACCOUNT NAME],A.[AccountId],S.[SecurityId],C.[CompanyId],SA.[SecurityAccountId],SAS.[SecurityAccountSponsorId]
FROM	[SMC_DB_ASA].[dbo].[SDFAccounts] X
JOIN [asa].[Accounts] A ON A.[AccountNumber] = X.[AccountNumber]
JOIN [asa].[Securities] S ON S.[MellonSecurityId] = X.[SecurityID]
JOIN [asa].[Companies] C ON C.[CompanyId] = S.[CompanyId]
JOIN [asa].[SecurityAccounts] SA ON SA.[AccountId] = A.[AccountId] AND SA.[SecurityId] = S.[SecurityId]
JOIN [asa].[SecurityAccountSponsors] SAS ON SAS.[SecurityAccountId] = SA.[SecurityAccountID]
)
SELECT * FROM CTE_DATA X JOIN [asa].[SecurityAccountSponsors] SAS ON SAS.[SecurityAccountSponsorId] =  X.[SecurityAccountSponsorId]



--*/

--SELECT * FROM @Debug
--where status like 'INSERT INTO%'

--ROLLBACK TRANSACTION T1

COMMIT TRANSACTION T1


