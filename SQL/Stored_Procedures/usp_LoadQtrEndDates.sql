/*
=============================================
	Procedure usp_LoadQtrEndDates
	Author John Alton 2/1/2016
	Load the Qtr End Dates since the First Transaction Date up to current Qtr End
	Modifications
	Name			Date		Description

=============================================
	EXECUTE SMC.usp_LoadQtrEndDates
	SELECT QtrEnd FROM [SMC].QtrEndDate ORDER BY QtrEnd DESC

*/

USE SMC_DB_Performance
GO

-- Drop stored procedure if it already exists
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_LoadQtrEndDates' 
)
   DROP PROCEDURE SMC.usp_LoadQtrEndDates
GO

CREATE PROCEDURE SMC.usp_LoadQtrEndDates
AS

DECLARE  @MinDate DATETIME
		,@FirstQtr DATETIME
		,@FinalQtr DATETIME
		,@CurrQtr DATETIME
		,@PrevQtr DATETIME
		,@LastMonthEnd datetime

DECLARE @CalDate TABLE(QtrEnd DATETIME)

/*Get the First Transaction to use as the starting point to get the first Qtr End*/
SELECT @MinDate = MIN(TransactionDate) FROM [SMC].Transactions
SET @FirstQtr = DATEADD(d, -1, DATEADD(q, DATEDIFF(q, 0, @MinDate) + 1, 0))
--SET @FirstQtr = FORMAT (DATEADD(d, -1, DATEADD(q, DATEDIFF(q, 0, @MinDate) + 1, 0)) , 'd', 'en-US' )
--SET @FirstQtr = FORMAT (DATEADD(d, -1, DATEADD(q, DATEDIFF(q, 0, @MinDate) + 1, 0)) , 'yyyy/MM/dd', 'en-US' )

--FORMAT ( QtrEnd , 'd', 'en-US' )
/*Get the last Qtr based on the Current Date*/
SET @FinalQtr = DATEADD(d,-1, (DATEADD(q, DATEDIFF(q, 0, GETDATE()), 0) )) 

----Last Day of Previous Month
--SELECT DATEADD(m,-1,EOMONTH(GETDATE()))

SET @LastMonthEnd = DATEADD(m,-1,EOMONTH(GETDATE()))

--select @MinDate ,@FirstQtr , @FinalQtr, @LastMonthEnd  

TRUNCATE TABLE [SMC].QtrEndDate

IF @LastMonthEnd > @FinalQtr
	BEGIN
		INSERT INTO [SMC].QtrEndDate SELECT @LastMonthEnd  
	END

--SELECT * FROM [SMC].QtrEndDate ORDER BY QtrEnd DESC


;With CTE_QTR As (
	Select @FirstQtr As QtrEnd
	Union All
	SELECT DATEADD(d, -1, DATEADD(q, DATEDIFF(q, 0, DATEADD(d,1,QtrEnd)) + 1, 0)) From CTE_QTR Where  QtrEnd < @FinalQtr	
)
INSERT INTO [SMC].QtrEndDate
	SELECT QtrEnd FROM CTE_QTR
	OPTION (MAXRECURSION 32767)

--select * from [SMC].QtrEndDate

