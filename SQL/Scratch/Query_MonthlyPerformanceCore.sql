USE [SMC_DB_Performance]
GO

PRINT @@SERVERNAME

declare @AccountName varchar(25), @AccountNumber varchar(25),@SecurityID varchar(25),@MonthEnd date,@MonthStart date,@Duration int
set @AccountNumber = 'LSJF70730002';set @SecurityID = '30992'; set @MonthEnd = '2015-11-30'
set @AccountNumber = 'LSJF60250002';set @SecurityID = '30904'; set @MonthEnd = '2015-10-31'

/* First Record per account/sec
SELECT AccountNumber
	,SecurityID
	,MIN(MonthStart) AS MonthStart
	FROM [SMC].[MonthlyPerformanceCore] A
	WHERE AccountNumber = @AccountNumber and SecurityID = @SecurityID
	GROUP BY AccountNumber,SecurityID
*/

/*[SMC].[MonthlyPerformanceCore]
select MonthlyPerformanceCoreID,AccountNumber, SecurityID, MonthStart
--, MonthEnd, ReportedDate, RowType, DataSource
, BAMV, MarketValue, EAMV, CashFlow,[ProfitPMD],[TWRPMD]	
FROM [SMC].[MonthlyPerformanceCore]
WHERE AccountNumber = @AccountNumber and SecurityID = @SecurityID and MonthEnd = @MonthEnd
--and MonthEnd >= @Monthstart and MonthEnd <= @MonthEnd and MonthEnd = @MonthEnd 
order by AccountNumber,SecurityID,MonthEnd 
*/

--/*[SMC].[MonthlyPerformanceFund]
--, MonthEnd, ReportedDate, RowType, DataSource
select AccountNumber, SecurityID, MonthEnd
, BAMV, MarketValue, EAMV, CashFlow,[ProfitPMD],[TWRPMD]	
FROM [SMC].[MonthlyPerformanceFund]
WHERE AccountNumber = @AccountNumber and SecurityID = @SecurityID and MonthEnd = @MonthEnd
--and MonthEnd >= @Monthstart and MonthEnd <= @MonthEnd and MonthEnd = @MonthEnd 
order by AccountNumber,SecurityID,MonthEnd 
--*/

/*
--CASH FLOW
GO


declare @AccountName varchar(25), @AccountNumber varchar(25),@SecurityID varchar(25),@MonthEnd date,@MonthStart date,@Duration int
set @AccountNumber = 'LSJF60250002';set @SecurityID = '30904'; set @MonthEnd = '2015-10-31'

SELECT * FROM SMC.CASHFLOW
WHERE AccountNumber = @AccountNumber and SecurityID = @SecurityID
AND MonthEnd  = @MonthEnd 
order by MonthEnd 
--*/