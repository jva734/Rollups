/*

We did notice 2 securities that seemed to be in the wrong Account altogether (see below):
1.	Dwellers (Security ID 999K33414) – it is currently in LSJF35210002 but we think should be in LSJF86020002
	in the database I see this security linked to account LSJF70060002	SBST/DIR PRV VEN	Bay Area Venture Capital Group - Private Venture

2.	Zenflow (Security ID 999J27161) – it is currently in LSJF30020002 but we think should be in LSJF86020002
			linked with LSJF86020002	STARTX/DIRECT INV PRIVATE	Stanford StartX Fund - Private Venture

And one security with an odd account number that looks a lot like our cash security ID – XMOS Semiconductor (Security ID NA9050298). 

*/

print @@servername

SELECT * FROM [asa].[Securities] S  where [MellonSecurityId] = '999K33414'
select * from [asa].[SecurityAccounts] SA where SA.[SecurityId] = 1041
SELECT * FROM [asa].[Accounts] A where A.[AccountId] =  1058
SELECT * FROM [asa].[Accounts] A where A.[AccountNumber] =  'LSJF35210002'
SELECT * FROM [asa].[Accounts] A where A.[AccountNumber] =  'LSJF86020002'
SELECT * FROM [asa].[Companies] C where C.[CompanyId]  =  1357


SELECT * FROM [asa].[Securities] S  where [MellonSecurityId] = '999J27161'
select * from [asa].[SecurityAccounts] SA where SA.[SecurityId] = 1023
SELECT * FROM [asa].[Accounts] A where A.[AccountId] =  1222
SELECT * FROM [asa].[Accounts] A where A.[AccountNumber] =  'LSJF30020002'
SELECT * FROM [asa].[Accounts] A where A.[AccountNumber] =  'LSJF86020002'
SELECT * FROM [asa].[Companies] C where C.[CompanyId]  =  1251



;WITH CTE_DATA AS (
SELECT  
		,A.[AccountId]
		,S.[SecurityId]
		--,C.[CompanyId]
		,SA.[SecurityAccountId]
FROM [SMC_DB_ASA].[dbo].[SDFNotInASA] X
LEFT	JOIN [asa].[Accounts] A ON A.[AccountNumber] = X.[AccountNumber]
LEFT	JOIN [asa].[Securities] S ON S.[MellonSecurityId] = X.[SecurityID]
LEFT	JOIN [asa].[Companies] C ON C.[CompanyId] = S.[CompanyId]
LEFT	JOIN [asa].[SecurityAccounts] SA ON SA.[AccountId] = A.[AccountId] AND SA.[SecurityId] = S.[SecurityId]
)
--SELECT * FROM CTE_DATA X JOIN [asa].[SecurityAccounts] SA ON SA.[SecurityAccountId] =  X.[SecurityAccountId]

--SELECT * FROM CTE_DATA X JOIN [asa].[Companies] C ON C.[CompanyId]  =  X.[CompanyId] AND C.Comment = 'SDF Bulk Load'
--SELECT * FROM CTE_DATA X JOIN [asa].[Accounts] A ON  A.[AccountId] =  X.[AccountId]
