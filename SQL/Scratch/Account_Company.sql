
;WITH CTE_DATA AS (
SELECT  'Companies' as TableName,   X.[ACCOUNT NAME],A.[AccountId],S.[SecurityId],C.[CompanyId]
FROM	[SMC_DB_ASA].[dbo].[SDFAccounts] X
JOIN [asa].[Accounts] A ON A.[AccountNumber] = X.[AccountNumber]
JOIN [asa].[Securities] S ON S.[MellonSecurityId] = X.[SecurityID]
JOIN [asa].[Companies] C ON C.[CompanyId] = S.[CompanyId]
)
SELECT * FROM CTE_DATA X JOIN [asa].[Companies] C ON C.[CompanyId]  =  X.[CompanyId] AND C.Comment = 'SDF Bulk Load'

SELECT   A.AccountNumber 
		,sa.[AccountId]
		,s.[MellonSecurityId] 
		,c.[CompanyName]		
		,SA.[SecurityAccountId]
FROM [SMC_DB_ASA].[asa].[Accounts] A 
	join [SMC_DB_ASA].[asa].[SecurityAccounts] SA on sa.[AccountId] = a.[AccountId]
	join [SMC_DB_ASA].[asa].[Securities] S on S.[SecurityId] = sa.[SecurityId] 
	join [SMC_DB_ASA].[asa].[Companies] C ON c.[CompanyId] = s.[CompanyId]
where A.AccountNumber = 'LSJF30020002'




-- Check the Company NAme
;WITH CTE_SDF AS (
	SELECT	AccountNumber as SDF_AccountNumber
			,SecurityID as SDF_SecurityID
	FROM  [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore] 
	WHERE [CompanyName] IS NULL 
		AND DataSource = 'CD' 
	GROUP BY AccountNumber,SecurityID
)
, CTE_NAME AS (
SELECT   SDF_AccountNumber
		,SDF_SecurityID
		,a.[AccountId]
		,A.AccountNumber AS ASA_AccountNumber
		--,sa.[AccountId]
		--,s.[MellonSecurityId] as ASA_SecurityID	
		--,c.[CompanyName]		
		--,SA.[SecurityAccountId]
FROM CTE_SDF SDF
	JOIN [SMC_DB_ASA].[asa].[Accounts] A ON A.AccountNumber = SDF_AccountNumber
	--join [SMC_DB_ASA].[asa].[SecurityAccounts] SA on sa.[AccountId] = a.[AccountId]
	--=left join [SMC_DB_ASA].[asa].[Securities] S on S.[SecurityId] = sa.[SecurityId] and s.[MellonSecurityId] = SDF_SecurityID
	--left join [SMC_DB_ASA].[asa].[Companies] C ON c.[CompanyId] = s.[CompanyId]
)
SELECT * FROM CTE_NAME SDF 

