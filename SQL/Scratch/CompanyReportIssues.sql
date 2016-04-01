--/*Testing

USE SMC_DB_Performance
GO

--SELECT * FROM SMC.MonthlyPerformanceFund WHERE CompanyName = 'Pure Storage'

SELECT MonthlyPerformanceFundID
	,AccountNumber,SecurityID
		,[CompanyName]
		,[PortfolioType]
		,MonthEnd
		,MellonAccountName
		,SponsorName
		,CASE 
			WHEN ASA_Account IS NULL THEN 'Realized'
			WHEN ASA_Account = 1 AND [SecurityStatus] IN ('Active','Active Converted New') THEN 'Unrealized'
			ELSE 'Realized'
		END AS RealizedStatus
		,ISNULL([SecurityStatus],'') [SecurityStatus]
		,ISNULL([Sector],'') AS [Sector]
		,ISNULL([SubSector],'')	AS [SubSector]
		,AccountClosed
		,[InceptionDate]
		,ASA_Account
		,EAMV
FROM SMC.MonthlyPerformanceFund
WHERE 
--MonthlyPerformanceFundid = 214540
--'Pure Storage'
	DataSource = 'CD' 
	AND MonthEnd =  '2015-12-31'
	--AND EAMV < 0 	
	AND CompanyName like 'amplyx%'
	
	
	in ('AcelRx Pharmaceuticals' 
,'Alkahest'
,'Atreus Pharmaceuticals'
,'Brightsource Energy'
,'Kaggle'
,'Oculeve'
,'Quanticell'
,'TwoXAR'
,'Voltage')



--*/
GO



declare @AccountNumber varchar(25), @SecurityID varchar(25)
set @AccountNumber = 'LSJF70430002'; set @SecurityID  = '00444T100'
set @AccountNumber = 'LSJF70430002'; set @SecurityID  = '999E45396'
set @AccountNumber = 'LSJF30020002'; set @SecurityID  = '99VVATQC2'
set @SecurityID  = '86771W105'
set @AccountNumber = 'LSJF86000002'; set @SecurityID  = '999J27674'
--999F08987
--999K37506
--99VVA74H3
--99VVACYK2


SELECT [CompanyName],[AccountNumber],SecurityID,MonthEnd,SecurityStatus,DataSource,RowType,[BAMV],[MarketValue],[EAMV],[CashFlow],[CapitalCalls],[Distributions1M],[AdditionalFees]
FROM SMC.MonthlyPerformanceFund
WHERE DataSource = 'CD' 
--AND EAMV < 0 
AND  AccountNumber = @AccountNumber 
AND SecurityID in('999K37506','99VVA74H3','99VVACYK2')
--SecurityID = @SecurityID  
--AND RowType ='R'
AND MonthEnd =  '2015-12-31'
order by AccountNumber , SecurityID , MonthEnd 


--vALUATIONS
go
declare @AccountNumber varchar(25), @SecurityID varchar(25)
set @AccountNumber = 'LSJF30020002'; 
set @SecurityID  = '86771W105' -- 2016
--set @SecurityID  = '999F17806' -- 2015
--set @SecurityID  = '99VVACTA0' 2015

set @SecurityID  = '90184L102' -- 2016
--set @SecurityID  = '999F20743' -- NULL
--set @SecurityID  = '99VVAEPH5' -- NULL
	SELECT  
 			 A1.AccountNumber
			,A1.SecurityID as SecurityID	
			,StartOfMonth = DATEADD(MONTH, DATEDIFF(MONTH, '19000101', A1.ReportedDate), '19000101')
			,EndOfMonth = EOMONTH(A1.ReportedDate) -- Last Day of Reported Month
			,A1.ReportedDate 
			--,LEAD (A1.ReportedDate,1,'1900-01-01') OVER (ORDER BY A1.AccountNumber ,A1.SecurityID,A1.ReportedDate) AS NextReportedDate
			,LEAD (A1.ReportedDate,1) OVER (PARTITION BY A1.AccountNumber ,A1.SecurityID,A1.ReportedDate ORDER BY A1.ReportedDate) AS NextReportedDate
			,A1.ReportedMktVal
			,A1.ReportedMktVal
			,'R'
			,A1.DataSource
			,[CompanyName]
			,[MellonAccountName]
			,[MellonDescription] 
			,Shares
			,A1.ReportedDate 
	FROM	SMC.vw_Valuations A1 

WHERE 
--AccountNumber = @AccountNumber AND 
SecurityID = @SecurityID 




--Transactions
go

declare @AccountNumber varchar(25), @SecurityID varchar(25)
set @AccountNumber = 'LSJF30020002'; set @SecurityID  = '99VVATQC2'


select * from [CD].[vw_Transactions]
where AccountNumber  = @AccountNumber and SecurityID = @SecurityID  

order by SecurityID, TransactionDate, TransactionAmt


select * from [CD].[vw_Transactions]
where SecurityID IN ('86771W105' ,'999F17806' ,'99VVACTA0' ,'90184L102' ,'999F20743' ,'99VVAEPH5' )

SELECT * FROM SMC.vw_Valuations A1 
where SecurityID IN ('86771W105' ,'999F17806' ,'99VVACTA0' ,'90184L102' ,'999F20743' ,'99VVAEPH5' )

go
declare @AccountNumber varchar(25), @SecurityID varchar(25)
set @AccountNumber = 'LSJF86000002'; set @SecurityID  = '999K37506'

SELECT MonthlyPerformanceFundID	,AccountNumber,SecurityID,[CompanyName],[PortfolioType],MonthEnd,MellonAccountName,SponsorName
		,CASE 
				WHEN ASA_Account IS NULL THEN 'Realized'
				WHEN ASA_Account = 1 AND [SecurityStatus] IN ('Active','Active Converted New') THEN 'Unrealized'
			ELSE 'Realized'
		END AS RealizedStatus
		,ISNULL([SecurityStatus],'') [SecurityStatus]
		,ISNULL([Sector],'') AS [Sector]
		,ISNULL([SubSector],'')	AS [SubSector]
		,AccountClosed
		,[InceptionDate]
		,ASA_Account
		,EAMV
FROM SMC.MonthlyPerformanceFund
where AccountNumber = @AccountNumber AND SecurityID = @SecurityID  


SELECT DISTINCT [CompanyName],[PortfolioType]
FROM SMC.MonthlyPerformanceFund
where SecurityID IN ('86771W105' ,'999F17806' ,'99VVACTA0' ,'90184L102' ,'999F20743' ,'99VVAEPH5' )
