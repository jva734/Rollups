/*
select [CompanyName]
,[MellonAccountName]
,[MellonDescription]
,[AccountNumber]
,[SecurityID]
,inceptiondate
 from [SMC].[MonthlyPerformanceFund]
where companyname like 'brightsource%'
--order by inceptiondate


select * from [SMC].[Transactions]
where datasource = 'cd'
and securityid = '99vva8x14'
*/
/*
TransactionID	DataSource	AsOfDate	AccountNumber	SecurityID	TransactionDate	TransactionAmt	TransactionTypeDesc	CompanyName	MellonAccountName	MellonDescription	MonthStart	MonthEnd	SMCLoadDate
214	CD	2015-12-31	LSJF85000002	99VVA8X14	2015-12-22	33332.19	Capital Calls	EVERLAW INC SERIES A PFD	LSVF/DIR PRIV VEN	EQUITY	2015-12-01	2015-12-31	2015-12-23 00:12:26.000
*/

-- Check the Company NAme
;WITH CTE_SDF AS (
	SELECT	AccountNumber as SDF_AccountNumber
			,SecurityID as SDF_SecurityID
	FROM  [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore] 
	WHERE DataSource = 'CD' 
	--WHERE [CompanyName] IS NULL AND DataSource = 'CD' 
		--AND [AccountNumber] = 'LSJF30020002' and SecurityID = '206994105'
	GROUP BY AccountNumber,SecurityID
)
, CTE_NAME AS (
SELECT   SDF_AccountNumber
		,SDF_SecurityID
		,A.AccountNumber AS ASA_AccountNumber
		,sa.[AccountId]
		,s.[MellonSecurityId] as ASA_SecurityID	
		,c.[CompanyName]		
		,SA.[SecurityAccountId]
FROM CTE_SDF SDF
	JOIN [SMC_DB_ASA].[asa].[Accounts] A ON A.AccountNumber = SDF_AccountNumber
	join [SMC_DB_ASA].[asa].[SecurityAccounts] SA on sa.[AccountId] = a.[AccountId]
	join [SMC_DB_ASA].[asa].[Securities] S on S.[SecurityId] = sa.[SecurityId] and s.[MellonSecurityId] = SDF_SecurityID
	join [SMC_DB_ASA].[asa].[Companies] C ON c.[CompanyId] = s.[CompanyId]
)
SELECT * FROM CTE_NAME SDF 
WHERE 
ORDER BY [CompanyName]



--UPDATE MPC
--SET MPC.CompanyName = SDF.CompanyName 
--FROM CTE_NAME SDF 
--	INNER JOIN [SMC].[MonthlyPerformanceCore] MPC ON 
--	MPC.AccountNumber = SDF.SDF_AccountNumber 
--	AND MPC.SecurityID = SDF.SDF_SecurityID 

