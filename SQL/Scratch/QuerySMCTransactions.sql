
select 
T.[AccountNumber]
,T.[MellonAccountName]
,T.[SecurityID]
,T.[CompanyName]
,S.LotDescription 
,T.[TransactionDate]
,T.[TransactionAmt]
,T.[TransactionTypeDesc]

from [SMC_DB_Performance].smc.Transactions T
	left join SMC_DB_ASA.asa.Securities	S ON S.[MellonSecurityId] = T.[SecurityID]


--where T.DataSource = 'CD' and T.[SecurityID] = '99VVA7Y64' and T.[CompanyName] = 'Alice Technologies'

where T.[AccountNumber] = 'LSJF86020002' and T.[SecurityID]  = '99VVA4597'



order by 
T.[CompanyName]
,T.[MellonAccountName]
,T.[SecurityID]
,T.[TransactionDate]

