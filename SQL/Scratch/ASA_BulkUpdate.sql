/*
	ASA_BulkUpdate
*/

USE SMC_DB_ASA
GO

/* Back up data
SELECT * INTO DBO.[AccountsBKP_V1] FROM  [asa].[Accounts]
SELECT * INTO [dbo].[Securities_20160321] FROM [asa].[Securities] 
SELECT * INTO [dbo].[CompaniesBKP_V1] FROM [asa].[Companies] 
SELECT * INTO [dbo].[SecurityAccountsBKP_V1]  FROM [asa].[SecurityAccounts] 

SELECT * INTO [dbo].[AccountSecurityStatus_2016_03_21] FROM [dbo].[AccountSecurityStatus]
TRUNCATE TABLE [dbo].[AccountSecurityStatus]

SELECT * FROM [SMC_DB_ASA].[dbo].[AccountSecurityStatus] X
*/

SET NOCOUNT ON

--
/*
SELECT  X.*
		,L.[LookupText]
		,A.[AccountId]		
		,S.[SecurityId]		
		,s.SecurityStatus
FROM	[SMC_DB_ASA].[dbo].[AccountSecurityStatus] X
	JOIN [asa].[Accounts] A ON A.[AccountNumber] = X.[Account Number]
	JOIN [asa].[Securities] S ON S.[MellonSecurityId] = X.[Mellon Security ID]
	JOIN [asa].[SecurityAccounts] SA ON SA.[AccountId] = A.[AccountId] AND SA.[SecurityId] = S.[SecurityId]
	JOIN [asa].[Lookups] L ON S.[SecurityStatus] = L.[LookupId] AND [LookupCategory] ='SECURITY_STATUS'
	ORDER BY A.[AccountId]				,S.[SecurityId]		


--Post Update	LSJF85050002	44934S206	Active Converted New	Write-Off	1135	10545	16004
--SELECT * FROM [asa].[Accounts] WHERE [AccountNumber] = 'LSJF85050002'
--SELECT * FROM [asa].[Securities] WHERE [MellonSecurityId] = '44934S206'

--*/

BEGIN TRANSACTION T1


DECLARE @PreData TABLE (
		DataSource varchar(20)
		,AccountNumber VARCHAR(255)
		,SecurityID  VARCHAR(255)
		,NewSecurityStatus  VARCHAR(255)
		,OldSecurityStatus VARCHAR(255)
	)
INSERT INTO @PreData
	SELECT  'Pre Update' 
			,X.[Account Number] as AccountNumber
			,X.[Mellon Security ID] as SecurityID
			,x.[Updated Security Status] as NewSecurityStatus
			,L.[LookupText] as OldSecurityStatus
FROM	 [SMC_DB_ASA].[dbo].[AccountSecurityStatus] X
	JOIN [asa].[Accounts] A ON A.[AccountNumber] = X.[Account Number]
	JOIN [asa].[Securities] S ON S.[MellonSecurityId] = X.[Mellon Security ID]
	JOIN [asa].[SecurityAccounts] SA ON SA.[AccountId] = A.[AccountId] AND SA.[SecurityId] = S.[SecurityId]
	LEFT JOIN [asa].[Lookups] L ON S.[SecurityStatus] = L.[LookupId] AND [LookupCategory] ='SECURITY_STATUS'
	ORDER BY A.[AccountId]				,S.[SecurityId]		

select * from @PreData where NewSecurityStatus  <> OldSecurityStatus 


DECLARE @Debug TABLE([Status] varchar(max), BigString VARCHAR(max))

DECLARE @Status varchar(max)
		,@BigString varchar(MAX)
		,@DebugMode bit
SET @DebugMode  = 0

DECLARE @AccountNumber NVARCHAR(50)
	,@SecurityID NVARCHAR(25)
	,@SecurityStatus  NVARCHAR(255)
	,@Processed INT
	,@NewAccountId BIGINT
	,@NewSecurityId  BIGINT
	,@SecurityAccountId BIGINT
	,@RowNum int = 0
	,@MaxRowNum int = 0
	,@SecurityStatusID BIGINT

DECLARE @Data TABLE (Rownumber int
		, AccountNumber VARCHAR(255)
		,SecurityID  VARCHAR(255)
		,SecurityStatus  VARCHAR(255)
	)

INSERT INTO @Data 
SELECT Row_number() OVER (ORDER BY [Account Number],[Mellon Security ID] ) 
	,[Account Number]
	,[Mellon Security ID]
	,[Updated Security Status]
FROM [SMC_DB_ASA].[dbo].[AccountSecurityStatus]

--SELECT * FROM @Data


SELECT @MaxRowNum = MAX(Rownumber) FROM @Data

PRINT CAST(@MaxRowNum AS VARCHAR(5))

set @Rownum = 1

WHILE @Rownum <= @MaxRowNum 
	BEGIN
		SELECT	@AccountNumber = [AccountNumber]
				,@SecurityID = SecurityID
				,@SecurityStatus = SecurityStatus
		FROM @Data
		WHERE Rownumber = @Rownum

		SET @SecurityStatusID = NULL
		IF EXISTS (SELECT [LookupId] FROM [SMC_DB_ASA].[asa].[Lookups] WHERE [LookupCategory] = 'SECURITY_STATUS' AND [LookupText] = @SecurityStatus)
			BEGIN
				SELECT @SecurityStatusID = [LookupId] FROM [SMC_DB_ASA].[asa].[Lookups] WHERE [LookupCategory] = 'SECURITY_STATUS' AND [LookupText] = @SecurityStatus
			END
		SET @SecurityStatusID = isnull(@SecurityStatusID,0)  
	
    --Start processing 
	SET @NewAccountId = NULL
	SET @NewSecurityId = NULL
	SET @SecurityAccountId = NULL
	--SET @BigString = 'AccountNumber: ' + @AccountNumber + ' SecurityID: ' + @SecurityID + ' AccountName: ' + @AccountName + ' CompanyName: ' + @CompanyName

	SET @BigString = @AccountNumber + ' AccountNumber '
				+ @SecurityID + '  SecurityID '
				+ cast(ISNULL(@SecurityStatusID,-1) as varchar(20))  + ' SecurityStatusID'
				
--
/*=========================================            Accounts
	set @Status =  'Row ' + cast(@Rownum as varchar(5)) + ' Check AccountNumber: ' + @AccountNumber 
	INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
--*/

--/*
	IF EXISTS(SELECT AccountId FROM [asa].[Accounts] WHERE [AccountNumber] = @AccountNumber)
		BEGIN
			SELECT @NewAccountId = AccountId FROM [asa].[Accounts] WHERE [AccountNumber] = @AccountNumber
			set @Status = 'Row ' + cast(@Rownum as varchar(5)) + ' Exists AccountNumber ' + @AccountNumber + ' @NewAccountId = ' + cast(@NewAccountId as varchar(20))
		END
	ELSE
		--NO RECORD
		BEGIN
			set @Status = 'Row ' + cast(@Rownum as varchar(5)) + ' NOT Exists AccountNumber ' + @AccountNumber + ' @NewAccountId = ' + cast(@NewAccountId as varchar(20))
		END
	INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)

	--IF @NewAccountId IS NULL
	--	INSERT INTO @Debug ([Status],BigString ) values ('Warning - @NewAccountId IS NULL',@BigString)
--*/

--/*Security

	--set @Status =  'Row ' + cast(@Rownum as varchar(5)) + ' Check Security @SecurityID= ' + @SecurityID 
	--INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)

	IF EXISTS(SELECT SecurityId FROM [asa].[Securities] WHERE [MellonSecurityId] = @SecurityID)
		BEGIN
			SELECT @NewSecurityId = SecurityId FROM [asa].[Securities] WHERE [MellonSecurityId] = @SecurityID 
			set @Status =  'Row ' + cast(@Rownum as varchar(5)) + ' Exists Securities ' + @SecurityID + ' @NewSecurityId = ' + cast(isnull(@NewSecurityId,'') as varchar(20)) 
		END
	ELSE
		BEGIN
			-- Security does not exist
			set @Status =  'Row ' + cast(@Rownum as varchar(5)) + ' NOT Exists Securities ' + @SecurityID 
		END	 
	INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)
	
--*/


/* [asa].[SecurityAccounts] */

--/*
IF EXISTS(SELECT [SecurityAccountId] FROM [asa].[SecurityAccounts] WHERE Accountid = @NewAccountId and [SecurityId] = @NewSecurityId)
	BEGIN			
		SET @Status =  'Row ' + cast(@Rownum as varchar(5)) + ' Exists SecurityAccounts ' + @AccountNumber + ' AccountNumber ' 	+ @SecurityID + '  SecurityID '
		
		IF @DebugMode = 0
			BEGIN
				UPDATE [asa].[Securities] 
					SET [SecurityStatus] = @SecurityStatusID
					WHERE [SecurityId] = @NewSecurityId
			END		
	END
	ELSE
		BEGIN
		SET @Status =  'Row ' + cast(@Rownum as varchar(5)) + ' NOT Exists SecurityAccounts ' + @AccountNumber + ' AccountNumber ' 	+ @SecurityID + '  SecurityID '
		END
	INSERT INTO @Debug ([Status],BigString ) values (@Status,@BigString)


SET @Rownum = @Rownum + 1;

END -- END WHILE

IF @DebugMode = 1
	BEGIN
		SELECT * FROM @Debug
		where [Status] like '%NOT%'
	END

--select * from @PreData 

--/*
SELECT  'Post Update' 
		,X.*
		,L.[LookupText]
		,A.[AccountId]		
		,S.[SecurityId]		
		,s.SecurityStatus
FROM	[SMC_DB_ASA].[dbo].[AccountSecurityStatus] X
	JOIN [asa].[Accounts] A ON A.[AccountNumber] = X.[Account Number]
	JOIN [asa].[Securities] S ON S.[MellonSecurityId] = X.[Mellon Security ID]
	JOIN [asa].[SecurityAccounts] SA ON SA.[AccountId] = A.[AccountId] AND SA.[SecurityId] = S.[SecurityId]
	JOIN [asa].[Lookups] L ON S.[SecurityStatus] = L.[LookupId] AND [LookupCategory] ='SECURITY_STATUS'
--	where x.[Updated Security Status] <> L.[LookupText]  
	ORDER BY A.[AccountId]				,S.[SecurityId]		
	
--*/


IF @DebugMode = 1
	BEGIN
		ROLLBACK TRANSACTION T1
	END
ELSE
	BEGIN
		COMMIT TRANSACTION T1
	END

