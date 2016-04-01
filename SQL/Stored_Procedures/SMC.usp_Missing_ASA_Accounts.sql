/*
=============================================
	Author John Alton 3/25/2016
	This query is to report all the Accounts and Securities we have in SDF but they dont exist in ASA
	Modifications
	Date	Name	Description



	EXEC SMC.usp_Missing_ASA_Accounts
=============================================
*/
-- =============================================
-- Create basic stored procedure template
-- =============================================
USE SMC_DB_Performance
GO

-- Drop stored procedure if it already exists
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_Missing_ASA_Accounts' 
)
   DROP PROCEDURE SMC.usp_Missing_ASA_Accounts
GO

CREATE PROCEDURE SMC.usp_Missing_ASA_Accounts
AS

/*
Accounts/Securities that exist in SDF but Not in ASA
*/

;WITH CTE_SDF AS (
SELECT  A.AccountNumber
		, A.SecurityID
		,A.CompanyName
		,A.[MellonAccountName]
FROM [SMC_DB_Performance].[SMC].[MonthlyPerformanceFund] A
WHERE DATASOURCE = 'CD' 
--AND [CompanyName] IS NULL
GROUP BY a.AccountNumber, a.SecurityID,A.CompanyName,A.[MellonAccountName]
)
,CTE_ASA AS (
SELECT a.[AccountNumber]
--,a.[MellonAccountName]
	,s.[MellonSecurityId]
--,s.[MellonDescription]
--,s.[LotDescription]
--,c.[CompanyName]
FROM [SMC_DB_ASA].[asa].[Accounts] A
	join [SMC_DB_ASA].[asa].[SecurityAccounts] SA on sa.[AccountId] = a.[AccountId]
	join [SMC_DB_ASA].[asa].[Securities] S on S.[SecurityId] = sa.[SecurityId]
	--join [SMC_DB_ASA].[asa].[Companies] C ON c.[CompanyId] = s.[CompanyId]
)
SELECT   sdf.AccountNumber
		,sdf.SecurityID
		,sdf.CompanyName
		,sdf.[MellonAccountName]

FROM CTE_SDF SDF
	LEFT JOIN CTE_ASA ASA ON ASA.[AccountNumber] = SDF.[AccountNumber] AND ASA.[MellonSecurityId] = SDF.SecurityId
WHERE ASA.[AccountNumber] IS NULL
--GROUP BY SDF.AccountNumber, SDF.SecurityID
order BY SDF.AccountNumber, SDF.SecurityID

