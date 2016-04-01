/*==========================================================================================================================================
	View			CND.vw_MonthlyPerformance
	Author			John Alton/Daniel Pan
	Date			2/2/2015
	Description		This view will perform a union between the CD data and the PI data to deliver data as a single conbined Transactions data
	Select * FROM CND.vw_MonthlyPerformanceCalc
==========================================================================================================================================*/
USE [SMC_DB_Performance]
GO

-- Drop Existing View
IF object_id(N'CND.vw_MonthlyPerformance', 'V') IS NOT NULL
	DROP VIEW CND.vw_MonthlyPerformance
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW CND.vw_MonthlyPerformance
AS

WITH CTE_Inception AS
(	-- Get the Account Inception Date by checking if earliest date that account exists in table.
	SELECT AccountNumber
			, MIN(monthend) InceptionDate
			,datediff(m,MIN([MonthEnd]) , MAX([MonthEnd]) ) as MthCount
	FROM [SMC_DB_Mellon].[dbo].[p_myrly_LSJG0036]
    GROUP BY AccountNumber
)
,CTE_Monthly AS
(	-- Get SDF CND Accounts with its AssetClass, Portfolio and Strategy
    -- BAMV = ACB
	-- MarketValue = NAV
	-- Profit = EAMV - BAMV  (EAMV has embedded the Cash Flow)
	SELECT a.MonthEnd
		,a.AccountNumber
		,a.AccountName
		,a.MarketValue
		,h.InceptionDate
		,H.MthCount		

		-- Custodied Flag
		,b.IsCustodied

		-- Base Value
		,ISNULL(a.BAMarketValuePMD,0) ACBPmd
		,ISNULL(a.BAMarketValueEMD,0) BAMV
		,ISNULL(a.EAMarketValueEMD,0) EAMV
		,ISNULL(a.MonthlyReturnEMD,0) MonthlyReturn
		,CONVERT(FLOAT,ISNULL(a.MonthlyReturnEMD,0))/100 TWR1M

		-- Account Grouping
		,ISNULL(e.LookupText,'') AccountPool
		,ISNULL(c.LookupText,'') AssetClass
		,ISNULL(d.LookupText,'') Portfolio
		,ISNULL(g.LookupText,'') SubPortfolio
		,ISNULL(f.LookupText,'') StructureType

		-- Check if Account is open within 3Mo, 1Y, 3Y, 5Y, 7Y and 10Y.
		,IIF(LAG(a.MonthEnd,2) OVER (PARTITION BY a.AccountNumber ORDER BY a.MonthEnd ASC) >= h.InceptionDate,1,0) AccountValid3Mo
		,IIF(LAG(a.MonthEnd,11) OVER (PARTITION BY a.AccountNumber ORDER BY a.MonthEnd ASC) >= h.InceptionDate,1,0) AccountValid1Yr
		,IIF(LAG(a.MonthEnd,23) OVER (PARTITION BY a.AccountNumber ORDER BY a.MonthEnd ASC) >= h.InceptionDate,1,0) AccountValid2Yr
		,IIF(LAG(a.MonthEnd,35) OVER (PARTITION BY a.AccountNumber ORDER BY a.MonthEnd ASC) >= h.InceptionDate,1,0) AccountValid3Yr
		,IIF(LAG(a.MonthEnd,59) OVER (PARTITION BY a.AccountNumber ORDER BY a.MonthEnd ASC) >= h.InceptionDate,1,0) AccountValid5Yr
		,IIF(LAG(a.MonthEnd,83) OVER (PARTITION BY a.AccountNumber ORDER BY a.MonthEnd ASC) >= h.InceptionDate,1,0) AccountValid7Yr
		,IIF(LAG(a.MonthEnd,119) OVER (PARTITION BY a.AccountNumber ORDER BY a.MonthEnd ASC) >= h.InceptionDate,1,0) AccountValid10Yr
        
		,(EAMarketValueEMD - BAMarketValueEMD) ProfitEMD
		,(EAMarketValuePMD - BAMarketValuePMD) ProfitPMD

	-- Join with Fund Admin Tables
	FROM [SMC_DB_Mellon].[dbo].[p_myrly_LSJG0036] a 
		LEFT JOIN  [SMC_DB_ASA].[asa].[Accounts] b
			ON a.AccountNumber = b.AccountNumber
		LEFT JOIN [SMC_DB_ASA].[asa].Lookups c
			ON b.AssetClass = c.LookupId
		LEFT JOIN [SMC_DB_ASA].[asa].Lookups d
			ON b.PortfolioType = d.LookupId
		LEFT JOIN [SMC_DB_ASA].[asa].Lookups e
			ON b.AccountPool = e.LookupId
		LEFT JOIN [SMC_DB_ASA].[asa].Lookups f
			ON b.StructureType = f.LookupId
		LEFT JOIN [SMC_DB_ASA].[asa].Lookups g
			ON b.SubPortfolioType = g.LookupId
		INNER JOIN CTE_Inception h
			ON b.AccountNumber = h.AccountNumber
	WHERE b.IsCustodied = 1 AND f.LookupText = 'Non-Direct'
		 --WHERE a.AccountNumber = 'LSJF30180002'
)
,CTE_Lag AS
(
	SELECT *

	-- TWR Lag for Year 1		
	,ISNULL(LAG(TWR1M,1,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag1
	,ISNULL(LAG(TWR1M,2,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag2
	,ISNULL(LAG(TWR1M,3,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag3
	,ISNULL(LAG(TWR1M,4,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag4
	,ISNULL(LAG(TWR1M,5,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag5
	,ISNULL(LAG(TWR1M,6,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag6
	,ISNULL(LAG(TWR1M,7,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag7
	,ISNULL(LAG(TWR1M,8,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag8
	,ISNULL(LAG(TWR1M,9,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag9
	,ISNULL(LAG(TWR1M,10,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag10
	,ISNULL(LAG(TWR1M,11,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag11
		
	-- TWR Lag for Year 2
	,ISNULL(LAG(TWR1M,12,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag12
	,ISNULL(LAG(TWR1M,13,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag13
	,ISNULL(LAG(TWR1M,14,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag14
	,ISNULL(LAG(TWR1M,15,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag15
	,ISNULL(LAG(TWR1M,16,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag16
	,ISNULL(LAG(TWR1M,17,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag17
	,ISNULL(LAG(TWR1M,18,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag18
	,ISNULL(LAG(TWR1M,19,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag19
	,ISNULL(LAG(TWR1M,20,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag20
	,ISNULL(LAG(TWR1M,21,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag21
	,ISNULL(LAG(TWR1M,22,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag22
	,ISNULL(LAG(TWR1M,23,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag23

	-- TWR Lag for Year 3
	,ISNULL(LAG(TWR1M,24,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag24
	,ISNULL(LAG(TWR1M,25,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag25
	,ISNULL(LAG(TWR1M,26,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag26
	,ISNULL(LAG(TWR1M,27,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag27
	,ISNULL(LAG(TWR1M,28,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag28
	,ISNULL(LAG(TWR1M,29,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag29
	,ISNULL(LAG(TWR1M,30,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag30
	,ISNULL(LAG(TWR1M,31,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag31
	,ISNULL(LAG(TWR1M,32,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag32
	,ISNULL(LAG(TWR1M,33,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag33
	,ISNULL(LAG(TWR1M,34,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag34
	,ISNULL(LAG(TWR1M,35,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag35

	-- TWR Lag for Year 4
	,ISNULL(LAG(TWR1M,36,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag36
	,ISNULL(LAG(TWR1M,37,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag37
	,ISNULL(LAG(TWR1M,38,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag38
	,ISNULL(LAG(TWR1M,39,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag39
	,ISNULL(LAG(TWR1M,40,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag40
	,ISNULL(LAG(TWR1M,41,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag41
	,ISNULL(LAG(TWR1M,42,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag42
	,ISNULL(LAG(TWR1M,43,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag43
	,ISNULL(LAG(TWR1M,44,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag44
	,ISNULL(LAG(TWR1M,45,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag45
	,ISNULL(LAG(TWR1M,46,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag46
	,ISNULL(LAG(TWR1M,47,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag47

	-- TWR Lag for Year 5
	,ISNULL(LAG(TWR1M,48,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag48
	,ISNULL(LAG(TWR1M,49,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag49
	,ISNULL(LAG(TWR1M,50,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag50
	,ISNULL(LAG(TWR1M,51,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag51
	,ISNULL(LAG(TWR1M,52,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag52
	,ISNULL(LAG(TWR1M,53,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag53
	,ISNULL(LAG(TWR1M,54,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag54
	,ISNULL(LAG(TWR1M,55,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag55
	,ISNULL(LAG(TWR1M,56,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag56
	,ISNULL(LAG(TWR1M,57,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag57
	,ISNULL(LAG(TWR1M,58,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag58
	,ISNULL(LAG(TWR1M,59,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag59

	-- TWR Lag for Year 6
	,ISNULL(LAG(TWR1M,60,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag60
	,ISNULL(LAG(TWR1M,61,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag61
	,ISNULL(LAG(TWR1M,62,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag62
	,ISNULL(LAG(TWR1M,63,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag63
	,ISNULL(LAG(TWR1M,64,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag64
	,ISNULL(LAG(TWR1M,65,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag65
	,ISNULL(LAG(TWR1M,66,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag66
	,ISNULL(LAG(TWR1M,67,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag67
	,ISNULL(LAG(TWR1M,68,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag68
	,ISNULL(LAG(TWR1M,69,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag69
	,ISNULL(LAG(TWR1M,70,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag70
	,ISNULL(LAG(TWR1M,71,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag71

	-- TWR Lag for Year 7
	,ISNULL(LAG(TWR1M,72,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag72
	,ISNULL(LAG(TWR1M,73,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag73
	,ISNULL(LAG(TWR1M,74,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag74
	,ISNULL(LAG(TWR1M,75,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag75
	,ISNULL(LAG(TWR1M,76,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag76
	,ISNULL(LAG(TWR1M,77,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag77
	,ISNULL(LAG(TWR1M,78,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag78
	,ISNULL(LAG(TWR1M,79,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag79
	,ISNULL(LAG(TWR1M,80,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag80
	,ISNULL(LAG(TWR1M,81,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag81
	,ISNULL(LAG(TWR1M,82,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag82
	,ISNULL(LAG(TWR1M,83,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag83

	-- TWR Lag for Year 8
	,ISNULL(LAG(TWR1M,84,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag84
	,ISNULL(LAG(TWR1M,85,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag85
	,ISNULL(LAG(TWR1M,86,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag86
	,ISNULL(LAG(TWR1M,87,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag87
	,ISNULL(LAG(TWR1M,88,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag88
	,ISNULL(LAG(TWR1M,89,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag89
	,ISNULL(LAG(TWR1M,90,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag90
	,ISNULL(LAG(TWR1M,91,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag91
	,ISNULL(LAG(TWR1M,92,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag92
	,ISNULL(LAG(TWR1M,93,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag93
	,ISNULL(LAG(TWR1M,94,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag94
	,ISNULL(LAG(TWR1M,95,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag95

	-- TWR Lag for Year 9
	,ISNULL(LAG(TWR1M,96,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag96
	,ISNULL(LAG(TWR1M,97,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag97
	,ISNULL(LAG(TWR1M,98,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag98
	,ISNULL(LAG(TWR1M,99,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag99
	,ISNULL(LAG(TWR1M,100,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag100
	,ISNULL(LAG(TWR1M,101,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag101
	,ISNULL(LAG(TWR1M,102,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag102
	,ISNULL(LAG(TWR1M,103,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag103
	,ISNULL(LAG(TWR1M,104,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag104
	,ISNULL(LAG(TWR1M,105,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag105
	,ISNULL(LAG(TWR1M,106,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag106
	,ISNULL(LAG(TWR1M,107,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag107

	-- TWR Lag for Year 10
	,ISNULL(LAG(TWR1M,108,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag108
	,ISNULL(LAG(TWR1M,109,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag109
	,ISNULL(LAG(TWR1M,110,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag110
	,ISNULL(LAG(TWR1M,111,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag111
	,ISNULL(LAG(TWR1M,112,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag112
	,ISNULL(LAG(TWR1M,113,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag113
	,ISNULL(LAG(TWR1M,114,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag114
	,ISNULL(LAG(TWR1M,115,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag115
	,ISNULL(LAG(TWR1M,116,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag116
	,ISNULL(LAG(TWR1M,117,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag117
	,ISNULL(LAG(TWR1M,118,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag118
	,ISNULL(LAG(TWR1M,119,0) OVER (PARTITION BY [AccountNumber] ORDER BY [MonthEnd] ASC) , 0) AS TWRLag119

	FROM CTE_Monthly
)

SELECT *

-- TWR3Mnth
,IIF(AccountValid3Mo = 1,(((1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2)) - 1),null) AS TWR3M



-- TWR 1Yr
,IIF(AccountValid1Yr = 1,(((1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2) * (1 + TWRLag3) * (1 + TWRLag4) * (1 + TWRLag5) * (1 + TWRLag6) * (1 + TWRLag7) * (1 + TWRLag8) * (1 + TWRLag9) * (1 + TWRLag10) * (1 + TWRLag11)) - 1),NULL) AS TWR1Yr

-- TWR 3Yr 
,IIF(AccountValid3Yr = 1,SMC_DB_Reference.SMC.ufn_PowerWrapper(	
  	  ((1+ TWR1M) * (1+ TWRLag1) * (1+ TWRLag2) * (1+ TWRLag3) * (1+ TWRLag4) * (1+ TWRLag5) 
	* (1+ TWRLag6) * (1+ TWRLag7) * (1+ TWRLag8) * (1+ TWRLag9) * (1+ TWRLag10) * (1+ TWRLag11)
	* (1+ TWRLag12) * (1+ TWRLag13) * (1+ TWRLag14) * (1+ TWRLag15) * (1+ TWRLag16) * (1+ TWRLag17)
	* (1+ TWRLag18) * (1+ TWRLag19) * (1+ TWRLag20) * (1+ TWRLag21) * (1+ TWRLag22) * (1+ TWRLag23)
	* (1+ TWRLag24) * (1+ TWRLag25) * (1+ TWRLag26) * (1+ TWRLag27) * (1+ TWRLag28) * (1+ TWRLag29)
	* (1+ TWRLag30) * (1+ TWRLag31) * (1+ TWRLag32) * (1+ TWRLag33) * (1+ TWRLag34) * (1+ TWRLag35))
	,1,3)-1,null) AS TWR3Yr


-- TWR5YRValid
,IIF(AccountValid5Yr = 1,SMC_DB_Reference.SMC.ufn_PowerWrapper(
  	  ((1+ TWR1M) * (1+ TWRLag1) * (1+ TWRLag2) * (1+ TWRLag3) * (1+ TWRLag4) * (1+ TWRLag5) 
	* (1+ TWRLag6) * (1+ TWRLag7) * (1+ TWRLag8) * (1+ TWRLag9) * (1+ TWRLag10) * (1+ TWRLag11)
	* (1+ TWRLag12) * (1+ TWRLag13) * (1+ TWRLag14) * (1+ TWRLag15) * (1+ TWRLag16) * (1+ TWRLag17)
	* (1+ TWRLag18) * (1+ TWRLag19) * (1+ TWRLag20) * (1+ TWRLag21) * (1+ TWRLag22) * (1+ TWRLag23)
	* (1+ TWRLag24) * (1+ TWRLag25) * (1+ TWRLag26) * (1+ TWRLag27) * (1+ TWRLag28) * (1+ TWRLag29)
	* (1+ TWRLag30) * (1+ TWRLag31) * (1+ TWRLag32) * (1+ TWRLag33) * (1+ TWRLag34) * (1+ TWRLag35)
	* (1+ TWRLag36) * (1+ TWRLag37) * (1+ TWRLag38) * (1+ TWRLag39) * (1+ TWRLag40) * (1+ TWRLag41)
	* (1+ TWRLag42) * (1+ TWRLag43) * (1+ TWRLag44) * (1+ TWRLag45) * (1+ TWRLag46) * (1+ TWRLag47)
	* (1+ TWRLag48) * (1+ TWRLag49) * (1+ TWRLag50) * (1+ TWRLag51) * (1+ TWRLag52) * (1+ TWRLag53)
	* (1+ TWRLag54) * (1+ TWRLag55) * (1+ TWRLag56) * (1+ TWRLag57) * (1+ TWRLag58) * (1+ TWRLag59)
	),1,5)-1,null) AS TWR5Yr
	
-- TWR7YRValid
,IIF(AccountValid7Yr = 1,SMC_DB_Reference.SMC.ufn_PowerWrapper(
  	  ((1+ TWR1M) * (1+ TWRLag1) * (1+ TWRLag2) * (1+ TWRLag3) * (1+ TWRLag4) * (1+ TWRLag5) 
	* (1+ TWRLag6) * (1+ TWRLag7) * (1+ TWRLag8) * (1+ TWRLag9) * (1+ TWRLag10) * (1+ TWRLag11)
	* (1+ TWRLag12) * (1+ TWRLag13) * (1+ TWRLag14) * (1+ TWRLag15) * (1+ TWRLag16) * (1+ TWRLag17)
	* (1+ TWRLag18) * (1+ TWRLag19) * (1+ TWRLag20) * (1+ TWRLag21) * (1+ TWRLag22) * (1+ TWRLag23)
	* (1+ TWRLag24) * (1+ TWRLag25) * (1+ TWRLag26) * (1+ TWRLag27) * (1+ TWRLag28) * (1+ TWRLag29)
	* (1+ TWRLag30) * (1+ TWRLag31) * (1+ TWRLag32) * (1+ TWRLag33) * (1+ TWRLag34) * (1+ TWRLag35)	
	* (1+ TWRLag36) * (1+ TWRLag37) * (1+ TWRLag38) * (1+ TWRLag39) * (1+ TWRLag40) * (1+ TWRLag41)
	* (1+ TWRLag42) * (1+ TWRLag43) * (1+ TWRLag44) * (1+ TWRLag45) * (1+ TWRLag46) * (1+ TWRLag47)
	* (1+ TWRLag48) * (1+ TWRLag49) * (1+ TWRLag50) * (1+ TWRLag51) * (1+ TWRLag52) * (1+ TWRLag53)
	* (1+ TWRLag54) * (1+ TWRLag55) * (1+ TWRLag56) * (1+ TWRLag57) * (1+ TWRLag58) * (1+ TWRLag59)
	* (1+ TWRLag60) * (1+ TWRLag61) * (1+ TWRLag62) * (1+ TWRLag63) * (1+ TWRLag64) * (1+ TWRLag65)
	* (1+ TWRLag66) * (1+ TWRLag67) * (1+ TWRLag68) * (1+ TWRLag69) * (1+ TWRLag70) * (1+ TWRLag71)
	* (1+ TWRLag72) * (1+ TWRLag73) * (1+ TWRLag74) * (1+ TWRLag75) * (1+ TWRLag76) * (1+ TWRLag77)
	* (1+ TWRLag78) * (1+ TWRLag79) * (1+ TWRLag80) * (1+ TWRLag81) * (1+ TWRLag82) * (1+ TWRLag83)
	),1,7)-1,null) AS TWR7Yr

-- TWR10YRValid
,IIF(AccountValid10Yr = 1,SMC_DB_Reference.SMC.ufn_PowerWrapper(
  	  ((1+ TWR1M) * (1+ TWRLag1) * (1+ TWRLag2) * (1+ TWRLag3) * (1+ TWRLag4) * (1+ TWRLag5) 
	* (1+ TWRLag6) * (1+ TWRLag7) * (1+ TWRLag8) * (1+ TWRLag9) * (1+ TWRLag10) * (1+ TWRLag11)
	* (1+ TWRLag12) * (1+ TWRLag13) * (1+ TWRLag14) * (1+ TWRLag15) * (1+ TWRLag16) * (1+ TWRLag17)
	* (1+ TWRLag18) * (1+ TWRLag19) * (1+ TWRLag20) * (1+ TWRLag21) * (1+ TWRLag22) * (1+ TWRLag23)
	* (1+ TWRLag24) * (1+ TWRLag25) * (1+ TWRLag26) * (1+ TWRLag27) * (1+ TWRLag28) * (1+ TWRLag29)
	* (1+ TWRLag30) * (1+ TWRLag31) * (1+ TWRLag32) * (1+ TWRLag33) * (1+ TWRLag34) * (1+ TWRLag35)	
	* (1+ TWRLag36) * (1+ TWRLag37) * (1+ TWRLag38) * (1+ TWRLag39) * (1+ TWRLag40) * (1+ TWRLag41)
	* (1+ TWRLag42) * (1+ TWRLag43) * (1+ TWRLag44) * (1+ TWRLag45) * (1+ TWRLag46) * (1+ TWRLag47)
	* (1+ TWRLag48) * (1+ TWRLag49) * (1+ TWRLag50) * (1+ TWRLag51) * (1+ TWRLag52) * (1+ TWRLag53)
	* (1+ TWRLag54) * (1+ TWRLag55) * (1+ TWRLag56) * (1+ TWRLag57) * (1+ TWRLag58) * (1+ TWRLag59)
	* (1+ TWRLag60) * (1+ TWRLag61) * (1+ TWRLag62) * (1+ TWRLag63) * (1+ TWRLag64) * (1+ TWRLag65)
	* (1+ TWRLag66) * (1+ TWRLag67) * (1+ TWRLag68) * (1+ TWRLag69) * (1+ TWRLag70) * (1+ TWRLag71)
	* (1+ TWRLag72) * (1+ TWRLag73) * (1+ TWRLag74) * (1+ TWRLag75) * (1+ TWRLag76) * (1+ TWRLag77)
	* (1+ TWRLag78) * (1+ TWRLag79) * (1+ TWRLag80) * (1+ TWRLag81) * (1+ TWRLag82) * (1+ TWRLag83)
	* (1+ TWRLag84) * (1+ TWRLag85) * (1+ TWRLag86) * (1+ TWRLag87) * (1+ TWRLag88) * (1+ TWRLag89)
	* (1+ TWRLag90) * (1+ TWRLag91) * (1+ TWRLag92) * (1+ TWRLag93) * (1+ TWRLag94) * (1+ TWRLag95)
	* (1+ TWRLag96) * (1+ TWRLag97) * (1+ TWRLag98) * (1+ TWRLag99) * (1+ TWRLag100) * (1+ TWRLag101)
	* (1+ TWRLag102) * (1+ TWRLag103) * (1+ TWRLag104) * (1+ TWRLag105) * (1+ TWRLag106) * (1+ TWRLag107)
	* (1+ TWRLag108) * (1+ TWRLag109) * (1+ TWRLag110) * (1+ TWRLag111) * (1+ TWRLag112) * (1+ TWRLag113)
	* (1+ TWRLag114) * (1+ TWRLag115) * (1+ TWRLag116) * (1+ TWRLag117) * (1+ TWRLag118) * (1+ TWRLag119)
	),1,10)-1,NULL) AS TWR10Yr





-- TWR CY
,CASE MONTH(MonthEnd)
	WHEN 1 THEN TWR1M
	WHEN 2 THEN (((1 + TWR1M) * (1 + TWRLag1))- 1)
	WHEN 3 THEN (( (1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2)) - 1)
	WHEN 4 THEN (((1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2) * (1 + TWRLag3)) - 1)
	WHEN 5 THEN (((1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2) * (1 + TWRLag3) * (1 + TWRLag4)) - 1)
	WHEN 6 THEN (((1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2) * (1 + TWRLag3) * (1 + TWRLag4) * (1 + TWRLag5)) - 1)
	WHEN 7 THEN (((1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2) * (1 + TWRLag3) * (1 + TWRLag4) * (1 + TWRLag5) * (1 + TWRLag6)) - 1)
	WHEN 8 THEN (((1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2) * (1 + TWRLag3) * (1 + TWRLag4) * (1 + TWRLag5) * (1 + TWRLag6) * (1 + TWRLag7)) - 1)
	WHEN 9 THEN (((1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2) * (1 + TWRLag3) * (1 + TWRLag4) * (1 + TWRLag5) * (1 + TWRLag6) * (1 + TWRLag7) * (1 + TWRLag8)) - 1)
	WHEN 10 THEN (((1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2) * (1 + TWRLag3) * (1 + TWRLag4) * (1 + TWRLag5) * (1 + TWRLag6) * (1 + TWRLag7) * (1 + TWRLag8) * (1 + TWRLag9)) - 1)
	WHEN 11 THEN (((1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2) * (1 + TWRLag3) * (1 + TWRLag4) * (1 + TWRLag5) * (1 + TWRLag6) * (1 + TWRLag7) * (1 + TWRLag8) * (1 + TWRLag9) * (1 + TWRLag10)) - 1)
	WHEN 12 THEN (((1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2) * (1 + TWRLag3) * (1 + TWRLag4) * (1 + TWRLag5) * (1 + TWRLag6) * (1 + TWRLag7) * (1 + TWRLag8) * (1 + TWRLag9) * (1 + TWRLag10) * (1 + TWRLag11)) - 1)
END TWRCY

-- TWRJY
,CASE MONTH(MonthEnd)
	WHEN 1 THEN (((1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2) * (1 + TWRLag3) * (1 + TWRLag4) * (1 + TWRLag5) * (1 + TWRLag6)) - 1)
	WHEN 2 THEN (((1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2) * (1 + TWRLag3) * (1 + TWRLag4) * (1 + TWRLag5) * (1 + TWRLag6) * (1 + TWRLag7)) - 1)
	WHEN 3 THEN (((1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2) * (1 + TWRLag3) * (1 + TWRLag4) * (1 + TWRLag5) * (1 + TWRLag6) * (1 + TWRLag7) * (1 + TWRLag8)) - 1)
	WHEN 4 THEN (((1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2) * (1 + TWRLag3) * (1 + TWRLag4) * (1 + TWRLag5) * (1 + TWRLag6) * (1 + TWRLag7) * (1 + TWRLag8) * (1 + TWRLag9)) - 1)
	WHEN 5 THEN (((1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2) * (1 + TWRLag3) * (1 + TWRLag4) * (1 + TWRLag5) * (1 + TWRLag6) * (1 + TWRLag7) * (1 + TWRLag8) * (1 + TWRLag9) * (1 + TWRLag10)) - 1)
	WHEN 6 THEN (((1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2) * (1 + TWRLag3) * (1 + TWRLag4) * (1 + TWRLag5) * (1 + TWRLag6) * (1 + TWRLag7) * (1 + TWRLag8) * (1 + TWRLag9) * (1 + TWRLag10) * (1 + TWRLag11)) - 1)
	WHEN 7 THEN TWR1M
	WHEN 8 THEN (((1 + TWR1M) * (1 + TWRLag1))- 1)
	WHEN 9 THEN (( (1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2)) - 1)
	WHEN 10 THEN (((1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2) * (1 + TWRLag3)) - 1)
	WHEN 11 THEN (((1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2) * (1 + TWRLag3) * (1 + TWRLag4)) - 1) 
	WHEN 12 THEN (((1 + TWR1M) * (1 + TWRLag1) * (1 + TWRLag2) * (1 + TWRLag3) * (1 + TWRLag4) * (1 + TWRLag5)) - 1) 
END TWRJY

FROM CTE_Lag

GO


