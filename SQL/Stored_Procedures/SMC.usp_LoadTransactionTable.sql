/*=============================================
	Author			John Alton
	Date			2/3/2016
	Description		Load Transaction 

	Modifications

EXEC SMC.usp_LoadTransactionsTable

SELECT * FROM [SMC].[Transactions] TD
WHERE DataSource = 'CD'
and CompanyName is null


 =============================================
 */
USE [SMC_DB_Performance]
GO

-- Drop stored procedure if it already exists
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_LoadTransactionsTable' 
)
   DROP PROCEDURE SMC.usp_LoadTransactionsTable
GO

CREATE PROCEDURE SMC.usp_LoadTransactionsTable
AS

TRUNCATE TABLE [SMC].[Transactions]

INSERT INTO [SMC].[Transactions]
	([DataSource] 
	,[AsOfDate] 
	,[AccountNumber] 
	,[SecurityID] 
	,[TransactionDate] 
	,[TransactionAmt] 
	,TransactionTypeDesc 
	,CompanyName
	,MellonAccountName
	,MellonDescription
	,MonthStart
	,MonthEnd
	,[SMCLoadDate] 
	)
SELECT  TD.DataSource
		,TD.AsOfDate 
		,TD.AccountNumber
		,TD.SecurityID
		,TD.TransactionDate
		,TD.TransactionAmt 
		,TL.TransactionTypeDesc
		,TD.CompanyName
		,TD.MellonAccountName
		,TD.MellonDescription		
		,DATEADD(MONTH, DATEDIFF(MONTH, '19000101', TransactionDate), '19000101') AS MonthStart 
		,EOMONTH(TransactionDate) AS MonthEnd
		,TD.SMCLoadDate
FROM	SMC.vw_Transactions TD
		INNER JOIN [SMC_DB_Performance].[SMC].[TransactionTypeLookup] TL ON TL.TransactionTypeLookupID = TD.TransactionTypeLookupID


;WITH CTE_COMP AS (
SELECT AccountNumber, [SecurityID] 
FROM  [SMC].[Transactions] TD
WHERE TD.DataSource = 'CD' AND TD.CompanyName IS NULL
)
,CTE_NAME AS (
SELECT   A.*
		,C.CompanyName
FROM CTE_COMP A
	JOIN [SMC_DB_ASA].[asa].[Securities]  S ON S.[MellonSecurityID] = A.securityid 	
	JOIN [SMC_DB_ASA].[asa].Companies C  ON s.CompanyId = c.CompanyId
)
--SELECT A.* , T.*
--FROM CTE_NAME A 
--INNER JOIN [SMC].[Transactions] T ON T.AccountNumber = A.AccountNumber and T.SecurityID = A.SecurityID 
UPDATE T
SET T.CompanyName = A.CompanyName 
FROM CTE_NAME A 
	INNER JOIN [SMC].[Transactions] T ON T.AccountNumber = A.AccountNumber and T.SecurityID = A.SecurityID 










