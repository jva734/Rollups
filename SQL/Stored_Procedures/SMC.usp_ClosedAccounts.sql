/*
===========================================================================================================================================
	Filename		SMC.usp_ClosedAccounts
	Author			John Alton
	Date			6/2015
	Description		
	1	Get the latest Account Closed Dates from the ASA system 
	2	For closed accounts set their post close values null
	3	update [SMC].[TransactionMeta] and set [ClosedAccount],[EMD_Flag]
===========================================================================================================================================

*/


--
/*Testing
USE [SMC_DB_Performance]
GO
SELECT * 
FROM [SMC].[AccountClosed] 
WHERE 
--AccountNumber = 'LSJF85050002' and  
SecurityID = '74624M102'

DELETE FROM [SMC].[AccountClosed] 
WHERE 
--AccountNumber = 'LSJF85050002' and  
SecurityID = '74624M102'
--*/

USE [SMC_DB_Performance]
GO
-- =============================================
-- Create basic stored procedure template
-- =============================================
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_ClosedAccounts' 
)
   DROP PROCEDURE SMC.usp_ClosedAccounts
GO

CREATE PROCEDURE SMC.usp_ClosedAccounts
AS

/*
  Get the latest set of Account Clsoed Date for PI Data
*/
------------------
-- PI Data
-----------------
;WITH CTE_ALL_PI AS (
	SELECT  [AccountNumber],SMCCloseDate AS AccountClosed
	FROM    [SMC_DB_ASA].[asa].[Accounts]
	WHERE	SMCCloseDate IS NOT NULL
	UNION 
	SELECT AccountNumber, MellonCloseDate  AS AccountClosed
	FROM [SMC_DB_ASA].[asa].[Accounts]
	WHERE MellonCloseDate IS NOT NULL
)
,CTE_GROUP AS (
	SELECT [AccountNumber],MIN(AccountClosed) AS AccountClosed
	FROM CTE_ALL_PI 
	GROUP BY AccountNumber 
)
INSERT INTO [SMC].[AccountClosed] (DataSource,AccountNumber,AccountClosed,MonthEnd)
	SELECT 'PI' AS DataSource, A.AccountNumber, A.AccountClosed,EOMONTH(A.AccountClosed) AS MonthEnd
	FROM CTE_GROUP A
	LEFT JOIN  [SMC].[AccountClosed] B ON B.AccountNumber = A.AccountNumber AND B.DataSource = 'PI'
	WHERE B.AccountNumber IS NULL

------------------
-- CD Data
-----------------
;WITH CTE_CD AS (
SELECT MIN('CD') AS DataSource
	, ASA.[AccountNumber]
	, S.MellonSecurityID AS SecurityID
	, MIN(SA.LiquidatedDate) AS AccountClosed 
	, EOMONTH(MIN(SA.LiquidatedDate)) AS MonthEnd
FROM [SMC_DB_ASA].[asa].[Accounts] ASA 
	INNER JOIN [SMC_DB_ASA].[asa].[SecurityAccounts] SA ON SA.[Accountid] = ASA.Accountid 
	INNER JOIN [SMC_DB_ASA].[asa].[Securities]  S ON S.securityid = SA.securityid 
	INNER JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON FL.[LookupId] = ASA.[StructureType]
WHERE SA.LiquidatedDate IS NOT NULL  
	AND ASA.IsCustodied = 1 
	AND FL.LookupText = 'Direct' 
GROUP BY ASA.[AccountNumber],S.MellonSecurityID

)
INSERT INTO [SMC].[AccountClosed] (DataSource,AccountNumber,SecurityID,AccountClosed,MonthEnd)
	SELECT 'CD' AS DataSource
		, A.AccountNumber
		, A.SecurityID
		, A.AccountClosed
		,EOMONTH(A.AccountClosed) AS MonthEnd
	FROM CTE_CD A
	LEFT JOIN  [SMC].[AccountClosed] B 
		ON B.AccountNumber = A.AccountNumber 
		AND B.SecurityID = A.SecurityID	
		AND B.DataSource = 'CD'
	WHERE B.AccountNumber IS NULL





/*=======================================================================
	6) Update the Account Closed Date for PI Data (By Account)
	Update the AccountClosed Date from the ASA System for PI data
=======================================================================*/
UPDATE MPC
   SET [AccountClosed] = AC.AccountClosed
	,EAMV = NULL
	,MarketValue = NULL
	,RowType = 'C'      
FROM [SMC].[MonthlyPerformanceCore] MPC
	,[SMC].[AccountClosed] AC
WHERE MPC.DataSource = 'PI'
  AND MPC.AccountNumber  = AC.AccountNumber
  AND MPC.MonthEnd >= AC.MonthEnd

----------------

UPDATE MPC
   SET [AccountClosed] = AC.AccountClosed
	,EAMV = NULL
	,MarketValue = NULL
	,RowType = 'C'      
FROM [SMC].[MonthlyPerformanceCore] MPC
	,[SMC].[AccountClosed] AC
WHERE MPC.DataSource = 'CD'
  AND MPC.AccountNumber  = AC.AccountNumber
  AND MPC.SecurityID = AC.SecurityID
  AND MPC.MonthEnd >= AC.AccountClosed --MonthEnd

;WITH CTE_CloseMonth AS (
	SELECT MonthlyPerformanceCoreID, AccountNumber, SecurityID, MonthEnd, AccountClosed
	FROM smc.MonthlyPerformanceCore
	WHERE AccountClosed IS NOT NULL 
--	AND AccountNumber = 'LSJF35210002' AND SecurityID = '996223293'
	AND MonthEnd > EOMONTH(AccountClosed)
--	order by AccountNumber, SecurityID, MonthEnd
)
UPDATE MP 
	SET  BAMV = NULL
FROM [SMC].[MonthlyPerformanceCore] MP 
	,CTE_CloseMonth A 
WHERE MP.MonthlyPerformanceCoreID = A.MonthlyPerformanceCoreID
  
  
/*=======================================================================
	Update the [ClosedAccount] BOOLEAN to True for the matching AccountClosed data
	if the Account Closed then set its EMD_Flag to true also
=======================================================================*/
UPDATE TM
	 SET [ClosedAccount] = 1
		,[EMD_Flag] = 1
	FROM [SMC].[TransactionMeta] TM
		,[SMC].[MonthlyPerformanceCore] A
	WHERE A.AccountNumber = TM.AccountNumber 
	  AND A.SecurityID = TM.SecurityID 
	  AND A.MonthEnd = TM.MonthEnd
	  AND A.[AccountClosed] IS NOT NULL

