/*
===========================================================================================================================================
	SP				SMC.usp_LoadMonthlyPerformanceCore
	Author			John Alton
	Date			10/2015
	Description		Controls the workflow process to create the table MonthlyPerformanceCore Table

	EXEC SMC.usp_LoadMonthlyPerformanceCore

	Modification
	1/22/16		John	Update data with Values from ASA System
	3/7/2016	John	If ASA SecurityStatus not "Active" or "Active Converted New", then set EAMV = 0 with the Liquidated Date equal to the valuation date of the zero EAMV

==========================================================================================================================================
*/

/*
	select count(*) from [SMC].[MonthlyPerformanceCore] --90,979

	SELECT ACCOUNTNUMBER, SECURITYID  FROM SMC_DB_Performance.[SMC].[MonthlyPerformanceCore] MPC 
	WHERE DATASOURCE = 'CD' 
	AND CompanyName is null
	AND SECURITYID = '996216495'
	GROUP BY ACCOUNTNUMBER, SECURITYID 

		ORDER BY ACCOUNTNUMBER, SECURITYID , MONTHEND

SELECT AccountNumber,SecurityID,DataSource
		,MPC.CompanyName
		,MPC.MellonAccountName 
		,MPC.PortfolioType 
		,MPC.SubPortfolioType 
		,MPC.Sector 
		,MPC.SubSector 
		,MPC.Series 
		,MPC.SecurityStatus 
		,MPC.InvestmentClassification 
		,MPC.MellonDescription 
		,MPC.SponsorName 
		,MPC.FirmName 
FROM [SMC].[MonthlyPerformanceCore] MPC
ORDER BY MPC.CompanyName

	
--*/

USE SMC_DB_Performance
GO

--/*debug only
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_LoadMonthlyPerformanceCore' 
)
   DROP PROCEDURE SMC.usp_LoadMonthlyPerformanceCore
GO

CREATE PROCEDURE SMC.usp_LoadMonthlyPerformanceCore
AS
--*/

TRUNCATE TABLE [SMC].[MonthlyPerformanceCore]

/* ==============================================================================
	Load the Reported Valuation rows
   ==============================================================================  */
INSERT INTO [SMC].[MonthlyPerformanceCore] 
		  ([AccountNumber]
           ,SecurityID           
           ,[MonthStart]
           ,[MonthEnd]
           ,[ReportedDate]
           ,[NextReportedDate]		   
		   ,[MarketValue]
		   ,[EAMV]
           ,[RowType]
		   ,DataSource
		   ,[CompanyName]
		   ,[MellonAccountName]
		   ,[MellonDescription] 
		   ,Shares
		   ,LastReportedDate
		   )
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

/* ==============================================================================
	Load Orphaned Rows
	Rows for which we have a Transaction but no Valuation Reported Values
   ==============================================================================  */
;WITH CTE_Orphans AS (
	SELECT 	 A.AccountNumber 
		,A.SecurityID
		,A.TransactionDate 
		,A.TransactionAmt
		,A.DataSource
		,EOMONTH(TransactionDate) AS MonthEnd
		,DATEADD(MONTH, DATEDIFF(MONTH, '19000101', TransactionDate), '19000101') AS MonthStart 
		,A.[CompanyName]
		,A.[MellonAccountName]
		,A.[MellonDescription] 
	FROM [SMC].Transactions A
			LEFT OUTER JOIN [SMC].[MonthlyPerformanceCore] B ON B.AccountNumber = A.AccountNumber AND B.SecurityID= A.SecurityID AND b.DataSource = a.DataSource
	WHERE B.AccountNumber IS NULL
)
/*  Get the Monthly Total of the Orphaned Transactions  */
,CTE_OrphanMonthlyTrans AS (
SELECT	 MAX(AccountNumber) AccountNumber
		,MAX(SecurityID) SecurityID		
		,MIN(MonthStart) AS MonthStart
		,MAX(MonthEnd) AS MonthEnd
		--,SUM(TransactionAmt) TransactionTotal -- jva 3/11/16
		,ABS(SUM(TransactionAmt)) TransactionTotal -- jva 3/11/16
		,MAX(DataSource) DataSource
		,MAX([CompanyName]) AS [CompanyName]
		,MAX([MellonAccountName]) AS [MellonAccountName]
		,MAX([MellonDescription]) AS [MellonDescription] 
FROM CTE_Orphans 
GROUP BY AccountNumber, SecurityID,MonthEnd
)
--select * from CTE_OrphanMonthlyTrans 
INSERT INTO [SMC].[MonthlyPerformanceCore] 
	(AccountNumber
	,SecurityID
	,MonthStart
	,MonthEnd
	,ReportedDate
	,NextReportedDate
	,MarketValue
	,[EAMV]
	,RowType
	,DataSource
	,[CompanyName]
	,[MellonAccountName]
	,[MellonDescription] 
	,LastReportedDate
	)
SELECT AccountNumber
	,SecurityID
	,MonthStart
	,MonthEnd
	,MonthEnd
	,LEAD (A.MonthEnd,1) OVER (PARTITION BY A.AccountNumber,A.SecurityID ORDER BY A.AccountNumber,A.SecurityID,A.MonthEnd) AS NextReportedDate
	,TransactionTotal
	,TransactionTotal
	,'O'
	,DataSource
	,[CompanyName]
	,[MellonAccountName]
	,[MellonDescription] 
	,MonthEnd
FROM CTE_OrphanMonthlyTrans A

/* ==============================================================================
	Create Pre-Reported Rows
	Import the Transaction Rows that pre-date any reported valuations
   ==============================================================================  */
;WITH CTE_FirstMonths AS (
SELECT AccountNumber
		,SecurityID
		,MIN(MonthStart) AS MonthStart
		,MAX([CompanyName]) AS [CompanyName]
		,MAX([MellonAccountName]) AS [MellonAccountName]
		,MAX([MellonDescription]) AS [MellonDescription] 
	FROM [SMC].[MonthlyPerformanceCore] A
	GROUP BY AccountNumber,SecurityID
)
,CTE_PreReportedTransactionRows as (
/*Get the Transactions that exist prior to a First Reported Month Value*/
SELECT   DataSource
		,A.AccountNumber 
		,A.SecurityID
		,TransactionDate 
		,TransactionAmt
		,A.[CompanyName]
		,A.[MellonAccountName]
		,A.[MellonDescription] 
	FROM [SMC].Transactions A
	INNER JOIN CTE_FirstMonths B ON B.AccountNumber = A.AccountNumber AND B.SecurityID	= A.SecurityID 
	WHERE A.TransactionDate  < B.MonthStart
)
--select * from CTE_PreReportedTransactionRows 
,CTE_GeneratePreReportedMonths AS (
/*Get the Monthly Total of the Pre-Reported Transactions*/
SELECT	 MAX(AccountNumber) AccountNumber
		,MAX(SecurityID) SecurityID
		,MIN(DATEADD(MONTH, DATEDIFF(MONTH, '19000101', TransactionDate), '19000101')) AS MonthStart
		,MAX(EOMONTH(TransactionDate)) MonthEnd
		--,SUM(TransactionAmt) TransactionTotal
		,ABS(SUM(TransactionAmt)) TransactionTotal -- jva 3/11/16
		,MAX(DataSource) DataSource
		,COUNT(*) RECS
		,MAX([CompanyName]) AS [CompanyName]
		,MAX([MellonAccountName]) AS [MellonAccountName]
		,MAX([MellonDescription]) AS [MellonDescription] 
FROM CTE_PreReportedTransactionRows 
GROUP BY AccountNumber, SecurityID,EOMONTH(TransactionDate)
)
--SELECT * FROM CTE_GeneratePreReportedMonths 
INSERT INTO [SMC].[MonthlyPerformanceCore] 
	(AccountNumber
	,SecurityID
	,MonthStart
	,MonthEnd
	,ReportedDate
	,NextReportedDate
	,MarketValue
	,[EAMV]
	,RowType
	,DataSource
	,[CompanyName]
	,[MellonAccountName]
	,[MellonDescription] 
	,LastReportedDate
	)
SELECT AccountNumber
	,SecurityID
	,MonthStart
	,MonthEnd
	,MonthEnd
	,LEAD (A.MonthEnd,1) OVER (PARTITION BY A.AccountNumber,A.SecurityID ORDER BY A.MonthEnd) AS NextReportedDate
	,TransactionTotal
	,TransactionTotal
	,'P'
	,DataSource
	,[CompanyName]
	,[MellonAccountName]
	,[MellonDescription] 
	,MonthEnd
FROM CTE_GeneratePreReportedMonths A



-- Check the Company NAme
;WITH CTE_SDF AS (
	SELECT	AccountNumber as SDF_AccountNumber
			,SecurityID as SDF_SecurityID
	FROM  [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore] 
	WHERE [CompanyName] IS NULL 
		AND DataSource = 'CD' 
		--AND [AccountNumber] = 'LSJF30020002' and SecurityID = '206994105'
	GROUP BY AccountNumber,SecurityID
)
, CTE_NAME AS (
SELECT   SDF_AccountNumber
		,SDF_SecurityID
		,A.AccountNumber AS ASA_AccountNumber
		,sa.[AccountId]
		,s.[MellonSecurityId] as ASA_SecurityID	
		,c.[CompanyName]		
		,SA.[SecurityAccountId]
FROM CTE_SDF SDF
	JOIN [SMC_DB_ASA].[asa].[Accounts] A ON A.AccountNumber = SDF_AccountNumber
	join [SMC_DB_ASA].[asa].[SecurityAccounts] SA on sa.[AccountId] = a.[AccountId]
	join [SMC_DB_ASA].[asa].[Securities] S on S.[SecurityId] = sa.[SecurityId] and s.[MellonSecurityId] = SDF_SecurityID
	join [SMC_DB_ASA].[asa].[Companies] C ON c.[CompanyId] = s.[CompanyId]
)
--SELECT * FROM CTE_NAME SDF 
UPDATE MPC
SET MPC.CompanyName = SDF.CompanyName 
FROM CTE_NAME SDF 
	INNER JOIN [SMC].[MonthlyPerformanceCore] MPC ON 
	MPC.AccountNumber = SDF.SDF_AccountNumber 
	AND MPC.SecurityID = SDF.SDF_SecurityID 


/* ==============================================================================
	Now we have all the Report Orphaned and Prior Transaction in the table
	Update NextReportedDate TO THE NEXT RECORD
   ==============================================================================  */
;WITH CTE_NextReportDate AS (
	SELECT AccountNumber
		  ,SecurityID
		  ,MonthStart
		  ,MonthEnd
		  ,LEAD (A.MonthEnd,1) OVER (ORDER BY A.AccountNumber,A.SecurityID,A.MonthStart ) AS NextReportedDate
	FROM [SMC].[MonthlyPerformanceCore] A
)
--SELECT * FROM CTE_NextReportDate ORDER BY AccountNumber,SecurityID,MonthStart 
UPDATE MPC
	SET MPC.NextReportedDate = A.NextReportedDate
	FROM CTE_NextReportDate A
	INNER JOIN [SMC].[MonthlyPerformanceCore] MPC
			ON  A.AccountNumber = MPC.AccountNumber 
			AND A.SecurityID    = MPC.SecurityID 
			AND A.MonthStart    = MPC.MonthStart
	

/* ==============================================================================
	Update NextReportedDate = LastDay of Last Month
   ==============================================================================  */
DECLARE @LastMonthEnd DATE
--SET @LastMonthEnd  = DATEADD(DAY, -(DAY(GETDATE())), GETDATE()) -- End of Last Month
SET @LastMonthEnd  = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())+1,0)) -- End of Current Month
--PRINT @LastMonthEnd  

UPDATE [SMC].[MonthlyPerformanceCore]
	SET NextReportedDate = @LastMonthEnd  
WHERE NextReportedDate IS NULL 
	OR NextReportedDate = '1900-01-31'
	OR NextReportedDate = '1900-01-01'

;WITH CTE_MaxDate as (
SELECT AccountNumber,SecurityID,max(MonthEnd) MonthEnd, @LastMonthEnd  AS LastMonthEnd  
FROM [SMC].[MonthlyPerformanceCore]  A
GROUP BY AccountNumber,SecurityID
)
UPDATE MPC
	SET MPC.NextReportedDate = A.LastMonthEnd
FROM CTE_MaxDate A
	,[SMC].[MonthlyPerformanceCore] MPC
WHERE A.AccountNumber = MPC.AccountNumber 
		AND A.SecurityID    = MPC.SecurityID 
		AND A.MonthEnd    = MPC.MonthEnd



--/* ==============================================================================
	--Create Adjusted Rows
	--The first CTE dt will create a list of dates for the first day of each Month from the Start Date to the End Date
	--CTE_Rows will link the Monthly Performance table to the list of Dates and select all the interveaning rows. These will represent all the rows between Reported Rows
--DECLARE @AccountNumber VARCHAR(30),@SecurityID VARCHAR(30)
--set @AccountNumber = 'LSJF70730002';set @SecurityID = '30992'; 
--==============================================================================  */

/* ==============================================================================
   Create Start and End Dates
   ==============================================================================  */
declare @AccountNumber varchar(25), @SecurityID varchar(25)
set @AccountNumber = 'LSJF86000002'; set @SecurityID  = '99VVAMDU1'

DECLARE @CalDate TABLE(MonthStart date)
Declare @fromDate date;
Declare @toDate date;
SELECT @fromDate = MIN(TransactionDate) FROM [SMC].Transactions
SELECT @fromDate = DATEADD(MONTH, DATEDIFF(MONTH, '19000101', @fromDate), '19000101')
SELECT @toDate = DATEADD(yy, DATEDIFF(yy,0,getdate()) + 1, -1) -- Get the LAst Day of the Year
;With dt As (
	Select @fromDate As MonthStart
	Union All
	Select DateAdd(m, 1, MonthStart) From dt Where  MonthStart < @toDate	
)
INSERT INTO @CalDate 
	SELECT MonthStart FROM dt
	OPTION (MAXRECURSION 32767)
--select * from @CalDate
;WITH CTE_AdjustedRows1 AS (
	SELECT MonthlyPerformanceCoreID
		,DataSource
		,RowType
		,'A' as RowTypea
		,AccountNumber
		,SecurityID
		,ReportedDate
		,NextReportedDate
		,MarketValue
		,BAMV
		,EAMV
		,DateAdd(d, -1, DATEADD(MONTH, DATEDIFF(MONTH, '19000101', MPC.NextReportedDate), '19000101')) AS EndDate
		,[CompanyName],[MellonAccountName],[MellonDescription] 
		,Shares
	FROM [SMC].[MonthlyPerformanceCore] MPC 
)
--SELECT * FROM CTE_AdjustedRows1 WHERE AccountNumber = @AccountNumber AND SecurityID = @SecurityID  
,CTE_AdjustedRows2 AS (
SELECT AR.* 
	,DT.MonthStart    
	,EOMONTH(dt.MonthStart)	AS MonthEnd
	,DateAdd(m, 1, dt.MonthStart) AS NewNextReportedDate
	,MarketValue AS LastReportedValue
	,ReportedDate as LastReportedDate
FROM @CalDate DT 
	JOIN CTE_AdjustedRows1 AR ON DT.MonthStart BETWEEN AR.ReportedDate AND AR.EndDate
)
--SELECT * FROM CTE_AdjustedRows2 
--WHERE   AccountNumber = @AccountNumber AND SecurityID = @SecurityID
--ORDER BY AccountNumber,SecurityID,MonthStart
INSERT INTO [SMC].[MonthlyPerformanceCore] 
	(AccountNumber,SecurityID,MonthStart,MonthEnd,ReportedDate,NextReportedDate
	,MarketValue,EAMV
	,RowType,DataSource,LastReportedValue,LastReportedDate
	,[CompanyName],[MellonAccountName],[MellonDescription],Shares 
	)
SELECT 
	AccountNumber,SecurityID,MonthStart,MonthEnd,ReportedDate,LEAD (MonthEnd,1) OVER (ORDER BY AccountNumber,SecurityID,MonthStart )
	,MarketValue
	--,LAG(EAMV,1) OVER (ORDER BY AccountNumber,SecurityID,MonthStart )
	,EAMV
	,'A',DataSource,LastReportedValue,LastReportedDate
	,[CompanyName],[MellonAccountName],[MellonDescription],Shares
FROM CTE_AdjustedRows2 
--WHERE   AccountNumber = @AccountNumber AND SecurityID = @SecurityID
ORDER BY AccountNumber,SecurityID,MonthStart

/*
	Modification
	1/22/16	John	Update data with Values from ASA System
*/
;WITH CTE_ASA_DATA_DIRECT AS (
SELECT   C.CompanyName
		,A.[AccountNumber]
		,S.MellonSecurityId
		,A.MellonAccountName
		,PT.LookupText AS 'PortfolioType'
		,SPT.LookupText AS 'SubPortfolioType'
		,SEC.LookupText AS 'Sector'
		,SSEC.LookupText AS 'SubSector'
		,S.LotDescription AS 'Series'
		,SEC_STATUS.LookupText AS 'SecurityStatus'
		,INV_CLAS.LookupText AS 'InvestmentClassification'
		,S.MellonDescription
		,SAS.SponsorName
		,SAS.FirmName
		,SA.LiquidatedDate
FROM [SMC_DB_ASA].[asa].[Accounts] A
	LEFT JOIN [SMC_DB_ASA].[asa].[SecurityAccounts] SA ON SA.[Accountid] = A.Accountid 
	LEFT JOIN [SMC_DB_ASA].[asa].[Securities]  S ON S.securityid = SA.securityid 	
	LEFT JOIN [SMC_DB_ASA].[asa].[SecurityAccountSponsors] SAS ON SAS.[SecurityAccountId] = SA.[SecurityAccountId]
	LEFT JOIN [SMC_DB_ASA].[asa].[Lookups] FL ON  FL.[LookupId] = A.[StructureType]
	LEFT JOIN [SMC_DB_ASA].[asa].[Lookups] PT ON PT.[LookupCategory] = 'ACCOUNT_COMPANY_PORTFOLIO_TYPE' AND PT.[LookupId] = A.[PortfolioType]
	LEFT JOIN [SMC_DB_ASA].[asa].[Lookups] SPT ON SPT.[LookupCategory] = 'ACCOUNT_COMPANY_SUB_PORTFOLIO_TYPE' AND  SPT.[LookupId] = A.SubPortfolioType
	LEFT JOIN [SMC_DB_ASA].[asa].Companies C  ON s.CompanyId = c.CompanyId
	LEFT JOIN [SMC_DB_ASA].[asa].Lookups SEC  ON  SEC.[LookupCategory] = 'COMPANY_SECTOR' AND  SEC.LookupId = SA.Sector
	LEFT JOIN [SMC_DB_ASA].[asa].Lookups SSEC  ON SSEC.[LookupCategory] = 'COMPANY_SUB_SECTOR' AND  SSEC.LookupId = SA.SubSector
	LEFT JOIN [SMC_DB_ASA].[asa].Lookups SEC_STATUS  ON SEC_STATUS.[LookupCategory] = 'SECURITY_STATUS' AND SEC_STATUS.LookupId = S.SecurityStatus
	LEFT JOIN [SMC_DB_ASA].[asa].Lookups INV_CLAS ON INV_CLAS.[LookupCategory] = 'INVESTMENT_CLASSIFICATION' AND INV_CLAS.LookupId = S.InvestmentClassification

WHERE A.IsCustodied = 1 
  AND FL.LookupText = 'Direct' 
  --AND C.CompanyName IS NOT NULL
)
UPDATE MPC
	SET MPC.CompanyName = ASA.CompanyName
		,MPC.MellonAccountName = ASA.MellonAccountName
		,MPC.PortfolioType = ASA.PortfolioType
		,MPC.SubPortfolioType = ASA.SubPortfolioType
		,MPC.Sector = ASA.Sector
		,MPC.SubSector = ASA.SubSector
		,MPC.Series = ASA.Series
		,MPC.SecurityStatus = ASA.SecurityStatus
		,MPC.InvestmentClassification = ASA.InvestmentClassification
		,MPC.MellonDescription = ASA.MellonDescription
		,MPC.SponsorName = ASA.SponsorName
		,MPC.FirmName = ASA.FirmName
		,MPC.ASA_Account = 1
FROM [SMC].[MonthlyPerformanceCore] MPC
	INNER JOIN CTE_ASA_DATA_DIRECT ASA ON MPC.[AccountNumber] = ASA.[AccountNumber] AND MPC.SecurityID = ASA.MellonSecurityId


/*
	Modification
	1/22/16	John	Update data with Values from ASA System
	SELECT A.[AccountNumber]
      ,a.[MellonAccountName]
      ,[SMCAccountName]
      ,[ManagerName]
      ,[PrimaryFundLegalName]
	  --,fl.LookupText 
FROM [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore] MPC 
	inner join [SMC_DB_ASA].[asa].[Accounts] A on a.[AccountNumber] = mpc.[AccountNumber]
where mpc.datasource = 'PI'

*/
UPDATE MPC 
SET    MPC.CompanyName = A.[SMCAccountName]
	  ,MPC.SponsorName = A.[ManagerName]
	  ,MPC.ASA_Account = 1
FROM [SMC_DB_Performance].[SMC].[MonthlyPerformanceCore] MPC 
	inner join [SMC_DB_ASA].[asa].[Accounts] A on a.[AccountNumber] = mpc.[AccountNumber]
where mpc.datasource = 'PI'
AND A.[SMCAccountName] IS NOT NULL



/* For debug only
SELECT AccountNumber,SecurityID,MonthStart,MonthEnd,ReportedDate ,MarketValue,EAMV,RowType,DataSource,LastReportedValue,LastReportedDate
FROM [SMC].[MonthlyPerformanceCore] 
WHERE   RowType = 'A' --and AccountNumber = 'LSJF70730002'
ORDER BY AccountNumber,SecurityID,MonthStart
--*/--1-8 jva

/*===========================================================================================================
	Update the MPC with CashFlow and calculate the EAMV
	Only update the Newly created RowType of A (the EAMV of Reported Rows is the Market Value
===========================================================================================================*/
UPDATE MPC
SET MPC.CashFlow = CF.EAMV_CashFlow 
FROM [SMC].[MonthlyPerformanceCore] MPC JOIN SMC.CashFlow CF   ON  
		CF.AccountNumber = MPC.AccountNumber 
	AND CF.SecurityID    = MPC.SecurityID 
	AND CF.MonthStart    = MPC.MonthStart


;WITH CTE_First_Record AS
(      
	   SELECT MPC.AccountNumber
			 ,MPC.SecurityID
			 ,MIN(MPC.MonthEnd) MinMonthEnd
	   FROM [SMC].[MonthlyPerformanceCore] MPC 
       GROUP BY MPC.AccountNumber,MPC.SecurityID
)
,CTE_Account AS
(      -- First Record       
	   SELECT MPC.MonthlyPerformanceCoreID
				,MPC.AccountNumber
				,MPC.SecurityID
				,MPC.MonthEnd
				,MPC.RowType
				,MPC.CashFlow
				,MPC.EAMV
				,CONVERT(DECIMAL(30,4), MPC.EAMV) AS CalcEAMVPrev 
				--,CAST(MPC.EAMV AS DECIMAL(20,4)) AS CalcEAMVPrev 
				,EOMONTH(DATEADD(MONTH, 1, MPC.MonthEnd)) MonthEndNext
       FROM [SMC].[MonthlyPerformanceCore] MPC 
	    INNER JOIN CTE_First_Record y ON MPC.AccountNumber = Y.AccountNumber AND MPC.SecurityID = Y.SecurityID AND MPC.MonthEnd = Y.MinMonthEnd
       UNION ALL
       -- Rest of Records
	   	   SELECT MPC.MonthlyPerformanceCoreID
				,MPC.AccountNumber
       			,MPC.SecurityID
				,MPC.MonthEnd
				,MPC.RowType
				,MPC.CashFlow
				,MPC.EAMV
				,CASE
					WHEN MPC.RowType <> 'A' THEN MPC.EAMV
					WHEN ISNULL(MPC.CashFlow,0) > Y.CalcEAMVPrev THEN 0
					ELSE CONVERT(DECIMAL(30,4), Y.CalcEAMVPrev - ISNULL(MPC.CashFlow,0)) 
				END AS CalcEAMVPrev 
				,EOMONTH(DATEADD(MONTH, 1, MPC.MonthEnd)) MonthEndNext
	   FROM [SMC].[MonthlyPerformanceCore] MPC 
		INNER JOIN CTE_Account y 
	          ON MPC.AccountNumber = y.AccountNumber 
			  AND MPC.SecurityID = Y.SecurityID
			  AND  MPC.MonthEnd = y.MonthEndNext
)
-- Update Records
	UPDATE MPC 
		SET MPC.EAMV = Y.CalcEAMVPrev
	FROM CTE_Account Y
		JOIN [SMC].[MonthlyPerformanceCore] MPC
		          ON MPC.MonthlyPerformanceCoreID = y.MonthlyPerformanceCoreID 
OPTION (MAXRECURSION 32767)

/*=============================================================
	Set the BAMV = to the previous rows EAMV
	Also set the Market Value = to the current EAMV
=============================================================*/
;WITH CTE_BAMV AS (
	SELECT 
		MonthlyPerformanceCoreID
		,LAG(EAMV,1) OVER (ORDER BY  AccountNumber,SecurityID,MonthEnd) AS LagEAMV
	FROM [SMC].[MonthlyPerformanceCore] MPC 
)
UPDATE MPC 
	SET MPC.BAMV = A.LagEAMV
		,MPC.MarketValue = MPC.EAMV
FROM [SMC].[MonthlyPerformanceCore] MPC 
	JOIN CTE_BAMV A ON A.MonthlyPerformanceCoreID = MPC.MonthlyPerformanceCoreID

/*=============================================================
	Set the First BAMV = NULL
declare @AccountName varchar(25), @AccountNumber varchar(25),@SecurityID varchar(25),@MonthEnd date,@MonthStart date,@Duration int
set @AccountNumber = 'LSJF70730002';set @SecurityID = '30992'; set @MonthEnd = '2015-11-30'
WHERE AccountNumber = @AccountNumber and SecurityID = @SecurityID
=============================================================*/
;WITH CTE_First_Record AS
(      
	   SELECT MIN(MonthlyPerformanceCoreID)  AS MonthlyPerformanceCoreID
			 ,MPC.AccountNumber
			 ,MPC.SecurityID
			 ,MIN(MPC.MonthEnd) MinMonthEnd
	   FROM [SMC].[MonthlyPerformanceCore] MPC 
       GROUP BY MPC.AccountNumber,MPC.SecurityID
)
--SELECT * FROM CTE_First_Record
UPDATE MPC 
	SET MPC.BAMV = NULL
FROM [SMC].[MonthlyPerformanceCore] MPC 
	JOIN CTE_First_Record A ON A.MonthlyPerformanceCoreID = MPC.MonthlyPerformanceCoreID



/*===================================================================================================
	SET the EAMV
;WITH CTE_RUNNING_EAMV_1 AS (
	SELECT ROW_NUMBER() OVER(ORDER BY AccountNumber,SecurityID,MonthStart) AS ID, 
		AccountNumber,SecurityID,MonthStart,EAMV,CashFlow,RowType
    FROM [SMC].[MonthlyPerformanceCore] MPC 
), CTE_RUNNING_EAMV AS (
	SELECT ID,AccountNumber,SecurityID,MonthStart,EAMV,CashFlow,RowType,C,RunningEAMV=MAX(EAMV) OVER (PARTITION BY c)
	FROM
	(
		SELECT ID,AccountNumber,SecurityID,MonthStart,EAMV,CashFlow,RowType
			,c=COUNT(EAMV) OVER (ORDER BY ID)
		FROM CTE_RUNNING_EAMV_1
	) a
)
UPDATE MPC
	SET  MPC.EAMV = X.RunningEAMV
	FROM [SMC].[MonthlyPerformanceCore] MPC 
	JOIN CTE_RUNNING_EAMV X 
		 ON X.AccountNumber = MPC.AccountNumber 
	    AND X.SecurityID    = MPC.SecurityID 
	    AND X.MonthStart    = MPC.MonthStart
===================================================================================================*/


/* ==============================================================================
	Reset NextReportedDate TO THE NEXT RECORD
	At this point because new rows have been added we need to re-set Next Reported Date
   ==============================================================================  */
;WITH CTE_MPC AS (
	SELECT MonthlyPerformanceCoreID
		,MPC.AccountNumber
		,MPC.SecurityID
		,MPC.MonthStart
		,MPC.MonthEnd
		,LEAD (MPC.MonthEnd,1) OVER (ORDER BY MPC.AccountNumber,MPC.SecurityID,MPC.MonthStart) AS NextReportedDate
	FROM [SMC].[MonthlyPerformanceCore] MPC 
)
UPDATE MPC
	SET MPC.NextReportedDate = A.NextReportedDate
FROM CTE_MPC A
	INNER JOIN [SMC].[MonthlyPerformanceCore] MPC ON 
	MPC.MonthlyPerformanceCoreID = A.MonthlyPerformanceCoreID 

/* ==============================================================================
	Update NextReportedDate = LastDay of Last Month
	select NextReportedDate from [SMC].[MonthlyPerformanceCore]
	WHERE NextReportedDate IS NULL
if debug
DECLARE @LastMonthEnd DATE
SET @LastMonthEnd  = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())+1,0)) -- End of Current Month
DECLARE @LastMonthEnd DATE
SET @LastMonthEnd  = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())+1,0)) -- End of Current Month

   ==============================================================================  */
UPDATE [SMC].[MonthlyPerformanceCore]
	SET NextReportedDate = @LastMonthEnd  
WHERE NextReportedDate IS NULL


/*====================================================================================================================
	Update the Distributions ,CapitalCalls ,AdditionalFees from CashFlow to MonthlyPErformance
		SELECT MonthlyPerformanceCoreID,RowType,AccountNumber,SecurityID,MonthStart,BAMV,MarketValue,EAMV,CashFlow,	Distributions,CapitalCalls,AdditionalFees
		FROM [SMC].[MonthlyPerformanceCore] MPC
		ORDER BY MPC.AccountNumber,MPC.SecurityID,MPC.MonthStart
 ====================================================================================================================*/
UPDATE MPC
 SET Distributions	= ISNULL(CF.TotalDistribution,0)
	,CapitalCalls	= ISNULL(CF.TotalCapitalCalls,0)
	,AdditionalFees = ISNULL(CF.TotalAdditionalFees,0)
	,ProfitPMD = EAMV - BAMV - ISNULL(TotalCashFlow,0)
FROM [SMC].[MonthlyPerformanceCore] MPC 
	JOIN SMC.CashFlow CF 
	 ON CF.AccountNumber = MPC.AccountNumber 
	AND CF.SecurityID    = MPC.SecurityID 
	AND CF.MonthStart    = MPC.MonthStart



/*====================================================================================================================
	Update InceptionDate
 ====================================================================================================================*/
 ;WITH CTE_InceptionDates_1 AS
(
	SELECT	AccountNumber
			,SecurityID
			,TransactionDate AS InceptionDate			
	FROM SMC.Transactions T

	UNION ALL

	SELECT	AccountNumber
			,SecurityID
			,CASE 
				WHEN ReportedDate = '1900-01-01' THEN '2999-12-31'
				ELSE ReportedDate 
			END AS InceptionDate			
	FROM SMC.MonthlyPerformanceCore 

	UNION ALL
	-- CND
	SELECT   x.AccountNumber
			,x.AccountNumber AS SecurityID
		    --,x.monthend AS InceptionDate
			,CASE 
				WHEN x.monthend = '1900-01-01' THEN '2999-12-31'
				ELSE x.monthend 
			END AS InceptionDate			
	FROM [SMC_DB_Mellon].[dbo].[p_myrly_LSJG0036] x
		INNER JOIN SMC_DB_Performance.SMC.MonthlyPerformanceCore y
			ON x.AccountNumber = y.AccountNumber
		WHERE y.DataSource = 'CND'
)
, CTE_InceptionDates_2 AS (
	SELECT	AccountNumber
			,SecurityID
			,MIN(InceptionDate) InceptionDate			
	FROM CTE_InceptionDates_1 
    GROUP BY AccountNumber,SecurityID
)
UPDATE MPC
SET MPC.InceptionDate = CTE_I.InceptionDate
FROM SMC.MonthlyPerformanceCore MPC
	INNER JOIN CTE_InceptionDates_2 CTE_I
	ON MPC.AccountNumber = CTE_I.AccountNumber AND MPC.SecurityID = CTE_I.SecurityID


/*====================================================================================================================
	Update LastTransactionDate
 ====================================================================================================================*/
 ;WITH CTE_LastTransactionDate_1 AS
(
	SELECT	AccountNumber,SecurityID
			,MAX(TransactionDate) AS LastTransactionDate
	FROM SMC.Transactions T
	GROUP BY AccountNumber,SecurityID

	UNION ALL

	SELECT	a.AccountNumber
			,a.SecurityID
			,MAX(a.ReportedDate) AS LastTransactionDate
	FROM	SMC.MonthlyPerformanceCore A
		LEFT JOIN SMC.Transactions T on a.AccountNumber = t.AccountNumber and a.SecurityID = t.SecurityID
	WHERE t.AccountNumber IS NULL AND A.RowType = 'R'
	GROUP BY a.AccountNumber,a.SecurityID

)
, CTE_LastTransactionDate_2 AS (
	SELECT	AccountNumber
			,SecurityID
			,MAX(LastTransactionDate) LastTransactionDate			
	FROM CTE_LastTransactionDate_1 
    GROUP BY AccountNumber,SecurityID
)
--select * from CTE_LastTransactionDate_2 
UPDATE MPC
SET MPC.LastTransactionDate = CTE_I.LastTransactionDate
FROM SMC.MonthlyPerformanceCore MPC
	INNER JOIN CTE_LastTransactionDate_2 CTE_I
		ON MPC.AccountNumber = CTE_I.AccountNumber AND MPC.SecurityID = CTE_I.SecurityID


 /*
 ;WITH CTE_Inception1 AS
(
	SELECT	AccountNumber
			,SecurityID
			,MIN(TransactionDate) InceptionDate			
	FROM SMC.Transactions T
	WHERE [AccountNumber] = 'LSJF86020002' and SecurityID = '999J11827'
    GROUP BY AccountNumber,SecurityID
	

	UNION ALL
	SELECT	AccountNumber
			,SecurityID
			,MIN(ReportedDate) InceptionDate			
	FROM SMC.MonthlyPerformanceCore 
	WHERE [AccountNumber] = 'LSJF86020002' and SecurityID = '999J11827'
    GROUP BY AccountNumber,SecurityID
)
, CTE_Inception AS (
	SELECT	AccountNumber
			,SecurityID
			,MIN(InceptionDate) InceptionDate			
	FROM CTE_Inception1
    GROUP BY AccountNumber,SecurityID

	UNION ALL
	-- CND
	SELECT x.AccountNumber
			,x.AccountNumber SecurityID
		, MIN(x.monthend) InceptionDate
	FROM [SMC_DB_Mellon].[dbo].[p_myrly_LSJG0036] x
		INNER JOIN SMC_DB_Performance.SMC.MonthlyPerformanceCore y
		ON x.AccountNumber = y.AccountNumber
	WHERE y.DataSource = 'CND'
    GROUP BY x.AccountNumber
)
UPDATE MPC
SET MPC.InceptionDate = CTE_I.InceptionDate
FROM SMC.MonthlyPerformanceCore MPC
	INNER JOIN CTE_Inception CTE_I
	ON MPC.AccountNumber = CTE_I.AccountNumber AND MPC.SecurityID = CTE_I.SecurityID
*/
