/*==========================================================================================================================================
	View			SDF.vw_Transactions
	Author			John Alton/Daniel Pan
	Date			2/2/2015
	Description		This view will perform a union between the CD data and the PI data to deliver data as a single conbined Transactions data

	SELECT * FROM SMC.vw_Transactions TD
	INNER JOIN  [SMC_DB_Performance].[SMC].[DirectAccounts] DA ON DA.[AccountNumber] = TD.[AccountNumber]

==========================================================================================================================================*/
USE [SMC_DB_Performance]

GO

IF object_id(N'SMC.vw_Transactions', 'V') IS NOT NULL
	DROP VIEW SMC.vw_Transactions
GO

CREATE VIEW SMC.vw_Transactions

AS

SELECT  DataSource
		,AsOfDate 
		,A.AccountNumber
		,A.SecurityID
		,TransactionDate		
		,REPLACE(TransactionAmt, ',','') as TransactionAmt
		,TransactionTypeLookupID 
		,CompanyName
		,MellonAccountName
		,MellonDescription
		,SMCLoadDate
FROM	CD.vw_Transactions A

	
UNION ALL

SELECT  DataSource
		,AsOfDate 
		,A.AccountNumber
		,SecurityID
		,TransactionDate
		,TransactionAmt
		,TransactionTypeLookupID 
		,CompanyName
		,MellonAccountName
		,MellonDescription
		,SMCLoadDate
FROM	PI.vw_Transactions A


