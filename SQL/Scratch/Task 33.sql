
/*
Account Number LSJF86020002 and the following security IDs 999J14789, 99VVA8A27, and 99VVA8A19 have 7 duplicate transactions that are being double-counted in the distributions and capital calls of the security
*/

SELECT  [SMC Load Date], count(*) as Rows
FROM	[SMC_DB_Mellon].[dbo].[SIDTransactionDetail] TD 
group by [SMC Load Date]
order by [SMC Load Date] desc


declare @AccountNumber varchar(25), @SecurityID varchar(25)
set @AccountNumber = 'LSJF86000002'
set @SecurityID  = '999J27674'
set @SecurityID  = '99VVA6L78'
set @SecurityID  = '999J27674'


SELECT  TD.[Source Account Number] AS AccountNumber
	,TD.[Mellon Security ID] AS SecurityID
	,[Effective Date] as TransactionDate
	,TD.[Base Cost]  AS TransactionAmt
	,[Security Description 1] AS CompanyName
	--,DA.[AccountName] AS [MellonAccountName]	
	,[Asset Category Description] AS [MellonDescription] 
	,TD.[Tax Code] 
	,TD.[Transaction Code] 
	,TD.[Asset Category Code] 
	,TD.[SMC Load Date] AS SMCLoadDate

FROM	[SMC_DB_Mellon].[dbo].[SIDTransactionDetail] TD 
where TD.[Source Account Number]  = @AccountNumber
and TD.[Mellon Security ID] = @SecurityID  
order by TD.[SMC Load Date] 

TD.[Mellon Security ID], [Effective Date] ,TD.[Base Cost] 


in ('999J14789') --, '99VVA8A27','99VVA8A19')

		INNER JOIN  [SMC_DB_Performance].[SMC].[DirectAccounts] DA ON DA.[AccountNumber] = TD.[Source Account Number]
where TD.[Source Account Number]  = 'LSJF86020002' and TD.[Mellon Security ID] in ('999J14789') --, '99VVA8A27','99VVA8A19')
order by TD.[Mellon Security ID], [Effective Date] ,TD.[Base Cost] 


go
use [SMC_DB_Performance]
go

declare @AccountNumber varchar(25), @SecurityID varchar(25)
set @AccountNumber = 'LSJF30020002'; set @SecurityID  = '99VVATQC2'

select * from [CD].[vw_Transactions]
where AccountNumber  = @AccountNumber and SecurityID = @SecurityID  
order by SecurityID, TransactionDate, TransactionAmt



SELECT  'CD' AS DataSource
,EOMONTH ( [Effective Date] ) AS AsOfDate
,TD.[Source Account Number] AS AccountNumber
,TD.[Mellon Security ID] AS SecurityID
,[Effective Date] as TransactionDate
,TD.[Base Amount]  AS TransactionAmt
--,B.TransactionTypeLookupID ,TD.[SMC Load Date] AS SMCLoadDate
,[Security Description 1] AS CompanyName
--,DA.[AccountName] AS [MellonAccountName]	
,[Asset Category Description] AS [MellonDescription] 

FROM	[SMC_DB_Mellon].[dbo].[SIDTransactionDetail] TD 
		INNER JOIN  [SMC_DB_Performance].[SMC].[DirectAccounts] DA ON DA.[AccountNumber] = TD.[Source Account Number]
		--INNER JOIN  [SMC_DB_Performance].[SMC].[TransactionTypeLookup] B 
		--	ON	 TD.[Tax Code] = B.[TaxCode]
		--		AND  TD.[Transaction Code] = B.[SubTransactionCode]	
		--		AND  TD.[Asset Category Code] = B.[AssetCategoryCode]
--		INNER JOIN [SMC_DB_ASA].[asa].[Accounts] FAS ON FAS.[AccountNumber] = TD.[Source Account Number] 
--		INNER JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON FL.[LookupId] = FAS.[StructureType]

WHERE 
--FAS.IsCustodied = 1 AND FL.LookupText = 'Direct' AND  
	B.[DataSource] = 'CD' 
	AND B.TransactionTypeDesc = 'Cash Income'

	AND B.FirmCodeFilter = 0
ID	DataSource	TransactionCategory	TransactionTypeDesc	TaxCode	SubTransactionCode	AssetCategoryCode	FirmCodeFilter	LedgerFilterID
25	CD	        Distributions	    Cash Income	        0031	IT		                                0	                -1



================================================================================
USE [SMC_DB_Performance]
GO

declare @AccountNumber varchar(25), @SecurityID varchar(25)
set @AccountNumber = 'LSJF86000002'
set @SecurityID  = '999J27674'

--,CTE_CashIncomeLineItemTS AS (
SELECT  'CD' AS DataSource
	,EOMONTH ( [Effective Date] ) AS AsOfDate
	,TD.[Source Account Number] AS AccountNumber
	,TD.[Mellon Security ID] AS SecurityID
	,[Effective Date] as TransactionDate
	,TD.[Base Amount]  AS TransactionAmt
	--,B.TransactionTypeLookupID 
	,TD.[SMC Load Date] AS SMCLoadDate
	,[Security Description 1] AS CompanyName
	--,[Reporting Account Name]	AS [MellonAccountName]	
	--,DA.[AccountName] AS [MellonAccountName]	
	,[Asset Category Description] AS [MellonDescription] 
FROM	[SMC_DB_Mellon].[dbo].[SIDTransactionDetail] TD 
where TD.[Source Account Number]  = @AccountNumber AND TD.[Mellon Security ID]  = @SecurityID 
order by [Effective Date],TD.[Base Amount]  desc


		--INNER JOIN  [SMC_DB_Performance].[SMC].[DirectAccounts] DA ON DA.[AccountNumber] = TD.[Source Account Number]
--		INNER JOIN [SMC_DB_ASA].[asa].[Accounts] FAS ON FAS.[AccountNumber] = TD.[Source Account Number] 
		INNER JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON FL.[LookupId] = FAS.[StructureType]
		INNER JOIN  [SMC_DB_Performance].[SMC].[TransactionTypeLookup] B 
		ON	 TD.[Tax Code] = B.[TaxCode]
		AND  TD.[Transaction Code] = B.[SubTransactionCode]	
WHERE FAS.IsCustodied = 1 AND FL.LookupText = 'Direct' AND  B.[DataSource] = 'CD' 
	AND B.TransactionTypeDesc = 'Cash Income'
	AND B.FirmCodeFilter = 0
	and TD.[Source Account Number]  = @AccountNumber AND TD.[Mellon Security ID]  = @SecurityID 

-------------------------------------------------------------------------
go
use [SMC_DB_Performance]
go

declare @AccountNumber varchar(25), @SecurityID varchar(25)
set @AccountNumber = 'LSJF70430002'
set @SecurityID  = '00444T100'

select * 
from smc.Transactions
where AccountNumber  = @AccountNumber and SecurityID = @SecurityID  
order by SecurityID, TransactionDate, TransactionAmt

