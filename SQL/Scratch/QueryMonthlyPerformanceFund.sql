
select 
[AccountNumber]
,[SecurityID]
,[MonthEnd]
,[CompanyName]
,[EAMV]
,[ReportedDate]

from [SMC].[MonthlyPerformanceFund]
where 
--[AccountNumber] = 'LSJF86020002' and [SecurityID] = '999J10191'
[AccountNumber] = 'LSJF86020002' and [SecurityID] = '99VVA4597'


ORDER BY [AccountNumber],[SecurityID],[MonthEnd]
