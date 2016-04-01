SELECT * from [SMC_DB_ASA].[dbo].[SDFNotInASA] a

	SELECT	MPC.AccountNumber as MPC_AccountNumber
			,MPC.SecurityID as MPC_SecurityID
			,sdf.CompanyNAme
	FROM  [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore] MPC
	JOIN [SMC_DB_ASA].[dbo].[SDFNotInASA] SDF ON SDF.AccountNumber = MPC.AccountNumber AND SDF.SecurityID = MPC.SecurityID
	WHERE mpc.[CompanyName] IS NULL and sdf.CompanyName is not null

	GROUP BY AccountNumber,SecurityID


select A.*
		,s.[MellonSecurityId] as ASA_SecurityID	
		,c.[CompanyName] as asa_company
from [SMC_DB_ASA].[dbo].[SDFNotInASA] a
	JOIN [SMC_DB_ASA].[asa].[Securities] S ON s.[MellonSecurityId]	= a.SecurityID
	join [SMC_DB_ASA].[asa].[Companies] C ON c.[CompanyId] = s.[CompanyId]

;WITH CTE_SDF AS (
	SELECT	AccountNumber as SDF_AccountNumber
			,SecurityID as SDF_SecurityID
	FROM  [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore] 
	WHERE [CompanyName] IS NULL
	GROUP BY AccountNumber,SecurityID
)
select 

SMC_DB_[SMC_DB_Performance]Performance
--/*Check the Company NAme

;WITH CTE_SDF AS (
	SELECT	AccountNumber as SDF_AccountNumber
			,SecurityID as SDF_SecurityID
	FROM  [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore] 
	WHERE [CompanyName] IS NULL
	GROUP BY AccountNumber,SecurityID
)
,CTE_NAME AS (
select SDF.*
		,a.*		
--		,s.[MellonSecurityId] as ASA_SecurityID	
		--,c.[CompanyName] as asa_company
from CTE_SDF SDF
	JOIN [SMC_DB_ASA].[dbo].[SDFNotInASA] A ON A.AccountNumber = SDF.SDF_AccountNumber and a.SecurityID = SDF.SDF_SecurityID
WHERE a.CompanyName is not null
)
UPDATE MPC
SET MPC.CompanyName = N.CompanyName 
FROM CTE_NAME N 
	INNER JOIN [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore] MPC ON 
	MPC.AccountNumber = n.AccountNumber and MPC.SecurityID = n.SecurityID 

	


	JOIN [SMC_DB_ASA].[asa].[Securities] S ON s.[MellonSecurityId]	= a.SecurityID
	join [SMC_DB_ASA].[asa].[Companies] C ON c.[CompanyId] = s.[CompanyId]



;WITH CTE_MPC AS (
	SELECT	AccountNumber as MPC_AccountNumber
			,SecurityID as MPC_SecurityID
	FROM  [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore] 
	WHERE [CompanyName] IS NULL
	GROUP BY AccountNumber,SecurityID
)
,CTE_NAME AS (
SELECT  *
FROM CTE_MPC MPC
	JOIN [SMC_DB_ASA].[dbo].[SDFNotInASA] SDF ON 
			SDF.AccountNumber = MPC.MPC_AccountNumber AND SDF.SecurityID = MPC.MPC_SecurityID
	WHERE SDF.CompanyName is not null
)
--SELECT * FROM CTE_NAME 
UPDATE MPC
SET MPC.CompanyName = SDF.CompanyName 
FROM CTE_NAME SDF 
	INNER JOIN [SMC].[MonthlyPerformanceCore] MPC ON 
	MPC.AccountNumber = SDF.MPC_AccountNumber 
	AND MPC.SecurityID = SDF.MPC_SecurityID 






--================================================================
;WITH CTE_MPC AS (
	SELECT	AccountNumber as MPC_AccountNumber
			,SecurityID as MPC_SecurityID
	FROM  [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore] 
	WHERE [CompanyName] IS NULL
	GROUP BY AccountNumber,SecurityID
)
SELECT   MPC_AccountNumber
		,MPC_SecurityID
		,A.AccountNumber AS ASA_AccountNumber
		,sa.[AccountId]
		,s.[MellonSecurityId] as ASA_SecurityID	
		,c.[CompanyName]		
FROM CTE_MPC MPC
	JOIN [SMC_DB_ASA].[asa].[Accounts] A ON A.AccountNumber = MPC.MPC_AccountNumber
	join [SMC_DB_ASA].[asa].[SecurityAccounts] SA on sa.[AccountId] = a.[AccountId]
	join [SMC_DB_ASA].[asa].[Securities] S on S.[SecurityId] = sa.[SecurityId] --and s.[MellonSecurityId] = MPC.MPC_SecurityID
	join [SMC_DB_ASA].[asa].[Companies] C ON c.[CompanyId] = s.[CompanyId]

--==================================================================================
NULL
;WITH CTE_MPC AS (
	SELECT	AccountNumber as MPC_AccountNumber
			,SecurityID as MPC_SecurityID
	FROM  [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore] 
	WHERE [CompanyName] IS NULL
	GROUP BY AccountNumber,SecurityID
)
--,CTE_ASA AS (
SELECT   MPC_AccountNumber
		,MPC_SecurityID
		--,A.AccountNumber AS ASA_AccountNumber
		--,sa.[AccountId]
		,s.[MellonSecurityId] as ASA_SecurityID	
		,c.[CompanyName]		
FROM CTE_MPC MPC
	JOIN [SMC_DB_ASA].[asa].[Securities] S ON s.[MellonSecurityId]	= MPC.MPC_SecurityID
	join [SMC_DB_ASA].[asa].[Companies] C ON c.[CompanyId] = s.[CompanyId]
--==================================================================================