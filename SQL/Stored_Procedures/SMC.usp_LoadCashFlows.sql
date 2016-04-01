/*
===========================================================================================================================================
	Filename		SMC_usp_LoadCashFlows
	Author			John Alton
	Date			2/17/2015
	Description		Process all the Trnasaction Types to merge into one table at Account,Security,Month level
	Change Date		Author		Desc
	5/27/15			John Alton	Changed the Data Solurce for the PI Transaction values
===========================================================================================================================================
*/

USE SMC_DB_Performance
GO

-- Drop stored procedure if it already exists
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_LoadCashFlows' 
)
   DROP PROCEDURE SMC.usp_LoadCashFlows
GO

CREATE PROCEDURE SMC.usp_LoadCashFlows
AS

TRUNCATE TABLE [SMC].[CashFlow]

/*=========================================================================================================
	Capital Call Corrections 
=========================================================================================================*/
MERGE INTO [SMC].[CashFlow] AS CF
   USING (		SELECT  AccountNumber ,SecurityID ,FirstDayOfMonth,CDCCCorrections,CDCCCorrectionsWGT 
				FROM	SMC.vw_CashFlow_CDCapitalCallCorrections
		 ) CV
      ON CF.AccountNumber = CV.AccountNumber AND CF.SecurityID = CV.SecurityID AND CF.[MonthStart] = CV.FirstDayOfMonth
WHEN MATCHED THEN
   UPDATE 
      SET CF.CDCCCorrections = CV.CDCCCorrections
		,CF.CDCCCorrectionsWGT = CV.CDCCCorrectionsWGT
WHEN NOT MATCHED THEN
    INSERT (AccountNumber ,SecurityID,MonthEnd,MonthStart,CDCCCorrections,CDCCCorrectionsWGT) VALUES 
	(CV.AccountNumber,CV.SecurityID,EOMONTH(CV.FirstDayOfMonth),CV.FirstDayOfMonth,CV.CDCCCorrections,CV.CDCCCorrectionsWGT);

/*=========================================================================================================
	Capital Calls
=========================================================================================================*/
MERGE INTO [SMC].[CashFlow] AS CF
   USING (		SELECT  AccountNumber ,SecurityID ,FirstDayOfMonth ,CDCapitalCalls,CDCapitalCallsWGT
				FROM	SMC.vw_CashFlow_CDCapitalCalls
		 ) CV
      ON CF.AccountNumber = CV.AccountNumber AND CF.SecurityID = CV.SecurityID AND CF.[MonthStart] = CV.FirstDayOfMonth
WHEN MATCHED THEN
   UPDATE 
      SET CF.CDCapitalCalls = CV.CDCapitalCalls
		, CF.CDCapitalCallsWGT = CV.CDCapitalCallsWGT
WHEN NOT MATCHED THEN
    INSERT (AccountNumber ,SecurityID,MonthEnd,MonthStart,CDCapitalCalls,CDCapitalCallsWGT) VALUES (CV.AccountNumber,CV.SecurityID,EOMONTH(CV.FirstDayOfMonth),CV.FirstDayOfMonth,CV.CDCapitalCalls,CV.CDCapitalCallsWGT);

/*=========================================================================================================
	Cash Income
=========================================================================================================*/
MERGE INTO [SMC].[CashFlow] AS CF
   USING (		SELECT  AccountNumber ,SecurityID ,FirstDayOfMonth ,CDCashIncome,CDCashIncomeWGT
				FROM	SMC.vw_CashFlow_CDCashIncome
		 ) CV
      ON CF.AccountNumber = CV.AccountNumber AND CF.SecurityID = CV.SecurityID AND CF.[MonthStart] = CV.FirstDayOfMonth
WHEN MATCHED THEN
   UPDATE 
      SET CF.CDCashIncome  = CV.CDCashIncome
	  ,	CF.CDCashIncomeWGT = CV.CDCashIncomeWGT
WHEN NOT MATCHED THEN
    INSERT (AccountNumber ,SecurityID,MonthEnd,MonthStart,CDCashIncome,CDCashIncomeWGT) VALUES (CV.AccountNumber,CV.SecurityID,EOMONTH(CV.FirstDayOfMonth),CV.FirstDayOfMonth,CV.CDCashIncome,CV.CDCashIncomeWGT);


/*=========================================================================================================
	Cash Income Corrections
=========================================================================================================*/
MERGE INTO [SMC].[CashFlow] AS CF
   USING (		SELECT  AccountNumber ,SecurityID ,FirstDayOfMonth ,CDCashIncomeCorrection,CDCashIncomeCorrectionWGT
				FROM	SMC.vw_CashFlow_CDCashIncomeCorrection
		 ) CV
      ON CF.AccountNumber = CV.AccountNumber AND CF.SecurityID = CV.SecurityID AND CF.[MonthStart] = CV.FirstDayOfMonth
WHEN MATCHED THEN
   UPDATE 
      SET CF.CDCashIncomeCorrection 		= CV.CDCashIncomeCorrection
		, CF.CDCashIncomeCorrectionWGT  = CV.CDCashIncomeCorrectionWGT
WHEN NOT MATCHED THEN
    INSERT (AccountNumber ,SecurityID,MonthEnd,MonthStart,CDCashIncomeCorrection,CDCashIncomeCorrectionWGT) VALUES (CV.AccountNumber,CV.SecurityID,EOMONTH(CV.FirstDayOfMonth),CV.FirstDayOfMonth,CV.CDCashIncomeCorrection,CV.CDCashIncomeCorrectionWGT);


/*=========================================================================================================
	Cash Principal
=========================================================================================================*/
MERGE INTO [SMC].[CashFlow] AS CF
   USING (		SELECT  AccountNumber ,SecurityID ,FirstDayOfMonth ,CDCashPrincipal,CDCashPrincipalWGT
				FROM	SMC.vw_CashFlow_CDCashPrincipal
		 ) CV
      ON CF.AccountNumber = CV.AccountNumber AND CF.SecurityID = CV.SecurityID AND CF.[MonthStart] = CV.FirstDayOfMonth
WHEN MATCHED THEN
   UPDATE 
      SET CF.CDCashPrincipal  = CV.CDCashPrincipal
	  ,CF.CDCashPrincipalWGT  = CV.CDCashPrincipalWGT
WHEN NOT MATCHED THEN
    INSERT (AccountNumber ,SecurityID,MonthEnd,MonthStart,CDCashPrincipal,CDCashPrincipalWGT) VALUES (CV.AccountNumber,CV.SecurityID,EOMONTH(CV.FirstDayOfMonth),CV.FirstDayOfMonth,CV.CDCashPrincipal,CV.CDCashPrincipalWGT);

/*=========================================================================================================
	Cash Principal Corrections
=========================================================================================================*/
MERGE INTO [SMC].[CashFlow] AS CF
   USING (		SELECT  AccountNumber ,SecurityID ,FirstDayOfMonth ,CDCashPrincipalCorrections,CDCashPrincipalCorrectionsWGT
				FROM	SMC.vw_CashFlow_CDCashPrincipalCorrections
		 ) CV
      ON CF.AccountNumber = CV.AccountNumber AND CF.SecurityID = CV.SecurityID AND CF.[MonthStart] = CV.FirstDayOfMonth
WHEN MATCHED THEN
   UPDATE 
      SET CF.CDCashPrincipalCorrections  = CV.CDCashPrincipalCorrections
		, CF.CDCashPrincipalCorrectionsWGT = CV.CDCashPrincipalCorrectionsWGT
WHEN NOT MATCHED THEN
    INSERT (AccountNumber ,SecurityID,MonthEnd,MonthStart,CDCashPrincipalCorrections,CDCashPrincipalCorrectionsWGT) VALUES (CV.AccountNumber,CV.SecurityID,EOMONTH(CV.FirstDayOfMonth),CV.FirstDayOfMonth,CV.CDCashPrincipalCorrections,CV.CDCashPrincipalCorrectionsWGT);


/*=========================================================================================================
	CD Stock Income 
=========================================================================================================*/
MERGE INTO [SMC].[CashFlow] AS CF
   USING (		SELECT  AccountNumber ,SecurityID ,FirstDayOfMonth ,CDStockIncome,CDStockIncomeWGT
				FROM	SMC.vw_CashFlow_CDStockIncome
		 ) CV
      ON CF.AccountNumber = CV.AccountNumber AND CF.SecurityID = CV.SecurityID AND CF.[MonthStart] = CV.FirstDayOfMonth
WHEN MATCHED THEN
   UPDATE 
      SET CF.CDStockIncome  = CV.CDStockIncome
		  ,CF.CDStockIncomeWGT  = CV.CDStockIncomeWGT
WHEN NOT MATCHED THEN
    INSERT (AccountNumber ,SecurityID,MonthEnd,MonthStart,CDStockIncome,CDStockIncomeWGT) VALUES (CV.AccountNumber,CV.SecurityID,EOMONTH(CV.FirstDayOfMonth),CV.FirstDayOfMonth,CV.CDStockIncome,CV.CDStockIncomeWGT);

/*=========================================================================================================
	Stock Principal 
=========================================================================================================*/
MERGE INTO [SMC].[CashFlow] AS CF
   USING (		SELECT  AccountNumber ,SecurityID ,FirstDayOfMonth ,CDStockPrincipal ,CDStockPrincipalWGT
				FROM	SMC.vw_CashFlow_CDStockPrincipal
		 ) CV
      ON CF.AccountNumber = CV.AccountNumber AND CF.SecurityID = CV.SecurityID AND CF.[MonthStart] = CV.FirstDayOfMonth
WHEN MATCHED THEN
   UPDATE 
      SET CF.CDStockPrincipal  = CV.CDStockPrincipal
		, CF.CDStockPrincipalWGT  = CV.CDStockPrincipalWGT
WHEN NOT MATCHED THEN
    INSERT (AccountNumber ,SecurityID,MonthEnd,MonthStart,CDStockPrincipal,CDStockPrincipalWGT) VALUES (CV.AccountNumber,CV.SecurityID,EOMONTH(CV.FirstDayOfMonth),CV.FirstDayOfMonth,CV.CDStockPrincipal,CV.CDStockPrincipalWGT);


/*=========================================================================================================
	PI Capital Calls
=========================================================================================================*/
MERGE INTO [SMC].[CashFlow] AS CF
   USING (		SELECT  AccountNumber ,SecurityID ,FirstDayOfMonth ,PICapitalCalls ,PICapitalCallsWGT
				FROM	SMC.vw_CashFlow_PICapitalCalls
		 ) CV
      ON CF.AccountNumber = CV.AccountNumber AND CF.SecurityID = CV.SecurityID AND CF.[MonthStart] = CV.FirstDayOfMonth
WHEN MATCHED THEN
   UPDATE 
      SET CF.PICapitalCalls  = CV.PICapitalCalls 
		,CF.PICapitalCallsWGT = CV.PICapitalCallsWGT
WHEN NOT MATCHED THEN
    INSERT (AccountNumber ,SecurityID,MonthEnd,MonthStart,PICapitalCalls,PICapitalCallsWGT) VALUES (CV.AccountNumber,CV.SecurityID,EOMONTH(CV.FirstDayOfMonth),CV.FirstDayOfMonth,CV.PICapitalCalls ,CV.PICapitalCallsWGT);

/*=========================================================================================================
	PI Additional Fees
=========================================================================================================*/
MERGE INTO [SMC].[CashFlow] AS CF
   USING (		SELECT  AccountNumber ,SecurityID ,FirstDayOfMonth ,PIAdditionalFees ,PIAdditionalFeesWGT
				FROM	SMC.vw_CashFlow_PIAdditionalFees
		 ) CV
      ON CF.AccountNumber = CV.AccountNumber AND CF.SecurityID = CV.SecurityID AND CF.[MonthStart] = CV.FirstDayOfMonth
WHEN MATCHED THEN
   UPDATE 
      SET CF.PIAdditionalFees = CV.PIAdditionalFees
	  ,CF.PIAdditionalFeesWGT = CV.PIAdditionalFeesWGT
WHEN NOT MATCHED THEN
    INSERT (AccountNumber ,SecurityID,MonthEnd,MonthStart,PIAdditionalFees,PIAdditionalFeesWGT) VALUES (CV.AccountNumber,CV.SecurityID,EOMONTH(CV.FirstDayOfMonth),CV.FirstDayOfMonth,CV.PIAdditionalFees,CV.PIAdditionalFeesWGT);


/*=========================================================================================================
	PI Cash Principal
	** Note this was changed from PICashPrincipal to PICashPrincipalCapitalGains
=========================================================================================================*/
MERGE INTO [SMC].[CashFlow] AS CF
   USING (		SELECT  AccountNumber ,SecurityID ,FirstDayOfMonth ,PICashPrincipal,PICashPrincipalWGT
				FROM	SMC.vw_CashFlow_PICashPrincipal
		 ) CV
      ON CF.AccountNumber = CV.AccountNumber AND CF.SecurityID = CV.SecurityID AND CF.[MonthStart] = CV.FirstDayOfMonth
WHEN MATCHED THEN
   UPDATE 
      SET CF.PICashPrincipalCapitalGains = CV.PICashPrincipal
		,CF.PICashPrincipalCapitalGainswgt  = CV.PICashPrincipalWGT
WHEN NOT MATCHED THEN
    INSERT (AccountNumber ,SecurityID,MonthEnd,MonthStart,PICashPrincipalCapitalGains,PICashPrincipalCapitalGainswgt) VALUES (CV.AccountNumber,CV.SecurityID,EOMONTH(CV.FirstDayOfMonth),CV.FirstDayOfMonth,CV.PICashPrincipal,CV.PICashPrincipalWGT);

/*=========================================================================================================
	PI Cash Income
=========================================================================================================*/
MERGE INTO [SMC].[CashFlow] AS CF
   USING (		SELECT  AccountNumber ,SecurityID ,FirstDayOfMonth ,PICashIncome,PICashIncomeWGT 
				FROM	SMC.vw_CashFlow_PICashIncome
		 ) CV
      ON CF.AccountNumber = CV.AccountNumber AND CF.SecurityID = CV.SecurityID AND CF.[MonthStart] = CV.FirstDayOfMonth
WHEN MATCHED THEN
   UPDATE 
      SET CF.PICashIncome = CV.PICashIncome
		,CF.PICashIncomeWGT = CV.PICashIncomeWGT
WHEN NOT MATCHED THEN
    INSERT (AccountNumber ,SecurityID,MonthEnd,MonthStart,PICashIncome,PICashIncomeWGT) VALUES (CV.AccountNumber,CV.SecurityID,EOMONTH(CV.FirstDayOfMonth),CV.FirstDayOfMonth,CV.PICashIncome,CV.PICashIncomeWGT);


/*=========================================================================================================
	PI Cash Income 'Cash Income RE/NR Royalties'
=========================================================================================================*/
MERGE INTO [SMC].[CashFlow] AS CF
   USING (		SELECT  AccountNumber ,SecurityID ,FirstDayOfMonth ,PICashIncome_RE_Royal,PICashIncome_RE_RoyalWGT 
				FROM	SMC.vw_CashFlow_PICashIncome_RE_Royal
		 ) CV
      ON CF.AccountNumber = CV.AccountNumber AND CF.SecurityID = CV.SecurityID AND CF.[MonthStart] = CV.FirstDayOfMonth
WHEN MATCHED THEN
   UPDATE 
      SET CF.PICashIncomeRERoyal = CV.PICashIncome_RE_Royal
		,CF.PICashIncomeRERoyalWGT = CV.PICashIncome_RE_RoyalWGT
WHEN NOT MATCHED THEN
    INSERT(AccountNumber,SecurityID,MonthEnd,MonthStart,PICashIncomeRERoyal,PICashIncomeRERoyalWGT) VALUES (CV.AccountNumber,CV.SecurityID,EOMONTH(CV.FirstDayOfMonth),CV.FirstDayOfMonth,CV.PICashIncome_RE_Royal,CV.PICashIncome_RE_RoyalWGT);


/*=========================================================================================================
	PI Stock Distribution 
=========================================================================================================*/
MERGE INTO [SMC].[CashFlow] AS CF
   USING (		SELECT  AccountNumber ,SecurityID ,FirstDayOfMonth ,PIStockDistribution,PIStockDistributionWGT
				FROM	SMC.vw_CashFlow_PIStockDistribution
		 ) CV
      ON CF.AccountNumber = CV.AccountNumber AND CF.SecurityID = CV.SecurityID AND CF.[MonthStart] = CV.FirstDayOfMonth
WHEN MATCHED THEN
   UPDATE 
      SET CF.PIStockDistribution = CV.PIStockDistribution
		,CF.PIStockDistributionWGT = CV.PIStockDistributionWGT
WHEN NOT MATCHED THEN
    INSERT (AccountNumber,SecurityID,MonthEnd,MonthStart,PIStockDistribution,PIStockDistributionWGT) VALUES (CV.AccountNumber,CV.SecurityID,EOMONTH(CV.FirstDayOfMonth),CV.FirstDayOfMonth,CV.PIStockDistribution,CV.PIStockDistributionWGT);

/*=========================================================================================================
	PI Recallable Capital
=========================================================================================================*/
MERGE INTO [SMC].[CashFlow] AS CF
   USING (		SELECT  AccountNumber ,SecurityID ,FirstDayOfMonth ,PIRecallableCapital,PIRecallableCapitalWGT
				FROM	SMC.vw_CashFlow_PIRecallableCapital
		 ) CV
      ON CF.AccountNumber = CV.AccountNumber AND CF.SecurityID = CV.SecurityID AND CF.[MonthStart] = CV.FirstDayOfMonth
WHEN MATCHED THEN
   UPDATE 
      SET CF.PIRecallableCapital = CV.PIRecallableCapital
		,CF.PIRecallableCapitalWGT = CV.PIRecallableCapitalWGT
WHEN NOT MATCHED THEN
    INSERT (AccountNumber,SecurityID,MonthEnd,MonthStart,PIRecallableCapital,PIRecallableCapitalWGT) 
	VALUES (CV.AccountNumber,CV.SecurityID,EOMONTH(CV.FirstDayOfMonth),CV.FirstDayOfMonth,CV.PIRecallableCapital,CV.PIRecallableCapitalWGT);

/*
	Calculate the Cash Distributions to Include Capital Gains
	*NOTE Column PICashPrincipal is based on column CashDistribution from Table [SMC_DB_PrivateI].[dbo].[TransactionHistoryExport]
	A.CashDistribution AS TransactionAmt, -- note we are getting CashDistribution and calling it Principal
*/
--UPDATE [SMC].[CashFlow] 
--	SET PICashPrincipalCapitalGains = ISNULL(PICashPrincipal,0) - (ISNULL(PICashIncome,0)  + ISNULL(PICashIncomeRERoyal,0) )
--		,PICashPrincipalCapitalGainswgt = ISNULL(PICashPrincipalWGT,0) - ( ISNULL(PICashIncomeWGT,0) + ISNULL(PICashIncomeRERoyalWGT,0))


/*=========================================================================================================
	Calculate total Cash Flow
=========================================================================================================*/

UPDATE [SMC].[CashFlow] 

/*TotalCashFlow is used to calculate Profit as in: (EAMV - BAMV + (TotalCashFlow)) AS Profit_Calc */
	SET TotalCashFlow = 
		ISNULL(CDCCCorrections ,0)
		+ ISNULL(CDCapitalCalls,0) 
		+ ISNULL(CDCashIncome,0) 
		+ ISNULL(CDCashIncomeCorrection,0)
		+ ISNULL(CDCashPrincipal,0) 
		+ ISNULL(CDCashPrincipalCorrections,0) 
		+ ISNULL(CDStockIncome,0)  
		+ ISNULL(CDStockPrincipal,0) 
		+ ISNULL(PICapitalCalls ,0) 
		+ ISNULL(PIAdditionalFees ,0)
		+ ISNULL(PICashPrincipalCapitalGains ,0) 
		+ ISNULL(PICashIncome ,0) 
		+ ISNULL(PICashIncomeRERoyal ,0) 
		+ ISNULL(PIStockDistribution ,0) 

/* TotalDistribution used Multiples*/
	,TotalDistribution = 
		  ISNULL(CDCashIncome,0) 
		+ ISNULL(CDCashIncomeCorrection,0)
		+ ISNULL(CDCashPrincipal,0) 
		+ ISNULL(CDCashPrincipalCorrections,0) 
		+ ISNULL(CDStockIncome,0)  
		+ ISNULL(CDStockPrincipal,0) 
		+ ISNULL(PICashPrincipalCapitalGains ,0) 
		+ ISNULL(PICashIncome ,0) 
		+ ISNULL(PICashIncomeRERoyal ,0) 
		+ ISNULL(PIStockDistribution,0) 
		
/* EAMV_CashFlow used in EAMV e.g. EAMV = BAMV - cash flows (includes income that we include, excludes add'l fees and income we exclude)*/
	,EAMV_CashFlow = 
  		  ISNULL(CDCCCorrections ,0)
		+ ISNULL(CDCapitalCalls,0) 
		+ ISNULL(CDCashPrincipal,0) 
		+ ISNULL(CDCashPrincipalCorrections,0) 
		+ ISNULL(CDStockPrincipal,0) 
		+ ISNULL(CDCashIncome,0) 
		+ ISNULL(CDCashIncomeCorrection,0)
		+ ISNULL(PICapitalCalls ,0) 
		+ ISNULL(PICashPrincipalCapitalGains ,0) 
		+ ISNULL(PIStockDistribution ,0) 
		+ ISNULL(PICashIncome ,0) 

/* EAMV_CashFlowWGT used in ACB e.g. (BAMV - EAMV_CashFlowWGT) AS ACB_calc*/
	,EAMV_CashFlowWGT = 
  		  ISNULL(CDCCCorrectionsWGT ,0)
		+ ISNULL(CDCapitalCallsWGT,0) 
		+ ISNULL(CDCashPrincipalWGT,0) 
		+ ISNULL(CDCashPrincipalCorrectionsWGT,0) 
		+ ISNULL(CDStockPrincipalWGT,0) 
		+ ISNULL(CDCashIncomeWGT,0) 
		+ ISNULL(CDCashIncomeCorrectionWGT,0) 
		+ ISNULL(PICapitalCallsWGT,0) 
		+ ISNULL(PICashPrincipalCapitalGainswgt,0) 
		+ ISNULL(PIStockDistributionWGT,0) 
		+ ISNULL(PICashIncomeWGT,0) 

			
/* TotalCapitalCalls used in Multiples*/ 
	, TotalCapitalCalls = 
		ISNULL(CDCCCorrections ,0)
		+ ISNULL(CDCapitalCalls,0) 
		+ ISNULL(PICapitalCalls ,0) 

/* TotalAdditionalFees used in Multiples*/ 
	,TotalAdditionalFees =
		ISNULL(PIAdditionalFees ,0)

