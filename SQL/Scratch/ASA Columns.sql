/*

Get the following data from ASA

Companies	asa	CompanyName

Accounts	asa	AccountNumber
Accounts	asa	MellonAccountName
Accounts	asa	PortfolioType
Accounts	asa	SubPortfolioType
Accounts	asa	LiquidatedDate		

Securities	asa	MellonSecurityId
Securities	asa	LotDescription
Securities	asa	SecurityStatus
Securities	asa	InvestmentClassification
Securities	asa	MellonDescription


SecurityAccounts	asa	Sector
SecurityAccounts	asa	SubSector

SecurityAccountSponsors	asa	SponsorName
SecurityAccountSponsors	asa	FirmName
SecurityAccounts	asa	LiquidatedDate

*/
SELECT   C.CompanyName
		,A.[AccountNumber]
		,S.MellonSecurityId

		,A.MellonAccountName
		--,A.PortfolioType
		,PT.LookupText AS 'PortfolioType'
		--,A.SubPortfolioType
		,SPT.LookupText AS 'SubPortfolioType'
		,SEC.LookupText AS 'Sector'
		,SSEC.LookupText AS 'SubSector'

		,S.LotDescription AS 'Series'
		--,S.SecurityStatus
		,SEC_STATUS.LookupText AS 'Security Status'

		--,S.InvestmentClassification
		,INV_CLAS.LookupText AS 'InvestmentClassification'
		,S.MellonDescription

		,SAS.SponsorName
		,SAS.FirmName
		--,A.LiquidatedDate		
		,SA.LiquidatedDate
FROM [SMC_DB_ASA].[asa].[Accounts] A
	LEFT JOIN [SMC_DB_ASA].[asa].[SecurityAccounts] SA ON SA.[Accountid] = A.Accountid 
	LEFT JOIN [SMC_DB_ASA].[asa].[Securities]  S ON S.securityid = SA.securityid 	
	LEFT JOIN [SMC_DB_ASA].[asa].[SecurityAccountSponsors] SAS ON SAS.[SecurityAccountId] = SA.[SecurityAccountId]
	LEFT JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON FL.[LookupId] = A.[StructureType]
	LEFT JOIN [SMC_DB_ASA].[asa].[Lookups] PT ON PT.[LookupId] = A.[PortfolioType]
	LEFT JOIN [SMC_DB_ASA].[asa].[Lookups] SPT ON SPT.[LookupId] = A.SubPortfolioType
	LEFT JOIN [SMC_DB_ASA].[asa].Companies C  ON s.CompanyId = c.CompanyId
	LEFT JOIN [SMC_DB_ASA].[asa].Lookups SEC  ON SA.SubSector = SEC.LookupId
	LEFT JOIN [SMC_DB_ASA].[asa].Lookups SSEC  ON SA.Sector = SSEC.LookupId
	LEFT JOIN [SMC_DB_ASA].[asa].Lookups SEC_STATUS  ON SEC_STATUS.LookupId = S.SecurityStatus
	LEFT JOIN [SMC_DB_ASA].[asa].Lookups INV_CLAS ON INV_CLAS.LookupId = S.InvestmentClassification

WHERE A.IsCustodied = 1 
  AND FL.LookupText = 'Direct' 
 --AND A.AccountNumber  = 'LSJF30020002'

 ORDER BY A.[AccountNumber],S.MellonSecurityID

 SELECT mpc.[AccountNumber],mpc.DataSource
      ,a.[MellonAccountName]
      ,[SMCAccountName]
      ,[IsCustodied]
      ,[ManagerName]
      ,[PrimaryFundLegalName]

FROM [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore] MPC 
inner join [SMC_DB_ASA].[asa].[Accounts] A on a.[AccountNumber] = mpc.[AccountNumber]
where mpc.datasource = 'PI'

