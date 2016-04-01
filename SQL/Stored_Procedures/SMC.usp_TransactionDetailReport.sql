/*=============================================
	Author			John Alton
	Date			2/3/2016
	Description		Transaction Detail Report for CD

	Modifications


SELECT DISTINCT MonthStart FROM [SMC].[Transactions] ORDER BY MonthStart desc
SELECT DISTINCT MonthEnd FROM [SMC].[Transactions] ORDER BY MonthEnd desc

declare @StartDate date,@EndDate date
SET @StartDate = '1985-05-01'; SET @EndDate = getdate()
--select @StartDate ,@EndDate 
EXEC SMC.usp_TransactionDetailReport @StartDate, @EndDate

SELECT 'TransactionDetailReport_' + FORMAT( GETDATE(), 'yyyy_MM_dd', 'en-US' ) AS 'FileNAme'

EXEC SMC.usp_TransactionDetailReport @StartDate, @EndDate
SELECT 'TransactionDetailReport_' + FORMAT( GETDATE(), 'yyyy_MM_dd', 'en-US' ) AS 'FileNAme'

select MIN([TransactionDate]) AS FirstTransaction, MAX([TransactionDate]) AS LastTransaction
from smc.Transactions 

select * from SMC.MonthlyPerformanceFund

 =============================================
 */

USE SMC_DB_Performance
GO

--
/*Execution
declare @StartDate date,@EndDate date
--SET @StartDate = '1985-05-14'; SET @EndDate = getdate()
--SET @StartDate = '2016-01-01'; SET @EndDate = getdate()
SET @StartDate = '2016-01-01'; SET @EndDate = '2016-03-31'
EXEC SMC.usp_TransactionDetailReport @StartDate, @EndDate
SELECT 'TransactionDetailReport_' + FORMAT( GETDATE(), 'yyyy_MM_dd', 'en-US' ) AS 'FileNAme'
--*/

--/*
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_TransactionDetailReport' 
)
   DROP PROCEDURE SMC.usp_TransactionDetailReport
GO

CREATE PROCEDURE SMC.usp_TransactionDetailReport
	@StartDate date
	,@EndDate date
AS
--*/


--
/*Debug
declare @StartDate date,@EndDate date
SET @StartDate = '1985-05-14'; SET @EndDate = getdate()
--*/

declare @MonthStartDate date
		,@MonthEndDate date
SET @MonthStartDate  = @StartDate;
SET @MonthEndDate  = @EndDate 


;WITH CTE_NAMES AS (
	SELECT MP.[AccountNumber],MP.[SecurityID],MP.CompanyName, MAX(MonthEnd) AS MonthEnd, MAX(CAST(ISNULL(MP.ASA_Account,0) AS INT)) AS ASA_Account
	FROM SMC.MonthlyPerformanceFund MP 
	--WHERE MP.CompanyName IS NOT NULL
	GROUP BY MP.[AccountNumber],MP.[SecurityID],MP.CompanyName
)
SELECT 
	T.[AccountNumber]
	,T.[SecurityID]
	,CASE 
		WHEN N.CompanyName IS NULL THEN T.[MellonAccountName]
		ELSE N.CompanyName
	END AS CompanyName
	,T.[MellonAccountName]	
	,S.LotDescription 
	,T.[TransactionDate]
	,T.[TransactionAmt]
	,T.[TransactionTypeDesc]
	,CASE 
		WHEN ASA_Account = 1 THEN 'Yes'
		ELSE 'No'
	END AS 'ASA Exists'

from smc.Transactions T
	left join SMC_DB_ASA.asa.Securities	S ON S.[MellonSecurityId] = T.[SecurityID]
	LEFT JOIN CTE_NAMES N ON N.[AccountNumber] = T.[AccountNumber] AND N.[SecurityID] = T.[SecurityID] 


where T.DataSource = 'CD' and T.MonthStart >= @MonthStartDate  and T.MonthEnd <= @MonthEndDate
order by 
T.[CompanyName]
,T.[MellonAccountName]
,T.[SecurityID]
,T.[TransactionDate]


GO
