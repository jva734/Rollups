

SELECT  
TD.[Source Account Number] AS AccountNumber
,TD.[Mellon Security ID] AS SecurityID
,C.CompanyNAme
,TD.[Effective Date] as TransactionDate
,TD.[Base Cost]  AS TransactionAmt_Cost
,TD.[Base Amount] AS TransactionAmt_Amount
,TD.[Tax Code] 
,TD.[Transaction Code]
,TD.[Asset Category Code]
,[Firm Code] 

from [SMC_DB_Mellon].[dbo].[SIDTransactionDetail] TD
	left join SMC_DB_ASA.asa.Securities	S ON S.[MellonSecurityId] = TD.[Mellon Security ID] 
	left join SMC_DB_ASA.asa.Companies C ON c.CompanyID = s.CompanyID

WHERE TD.[Transaction Code] = 'FC' AND [Firm Code] NOT IN ('A400', 'A1')
ORDER BY TD.[Asset Category Code]


SELECT  TD.[Tax Code] ,TD.[Transaction Code] ,TD.[Asset Category Code], SUM(TD.[Base Amount] )AS TotalAmount, COUNT(*) AS TransactionCount
from [SMC_DB_Mellon].[dbo].[SIDTransactionDetail] TD
WHERE TD.[Transaction Code] = 'FC' AND [Firm Code] NOT IN ('A400', 'A1')
GROUP BY TD.[Tax Code] ,TD.[Transaction Code] ,TD.[Asset Category Code]
order by TD.[Tax Code] ,TD.[Transaction Code] ,TD.[Asset Category Code]





--Non Validated Tax Codes '0000','0001','0195','0LPB'
--Validated Tax Codes ,'0151','0651'
  
  
  
  

WHERE TD.[Transaction Code] = 'FC' AND [Firm Code] IN ('A400','A1') --1459




where TD.[Source Account Number] = 'LSJF86020002' and [Mellon Security ID]  = '99VVA4597'

where [Mellon Security ID] = '99VVA8BS9'

where [Mellon Security ID] = '99VVA7Y64' 


