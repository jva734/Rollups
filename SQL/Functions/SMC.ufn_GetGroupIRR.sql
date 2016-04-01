-- =============================================
-- Author:		Daniel Pan
-- Create date: 03/26/2015
-- Description:	Pass Group CashFlow and Calculate XIRR
-- 
-- SELECT SMC.ufn_GetGroupIRR('SBST', '2014-10-01', '2014-10-31') 
-- =============================================

--================================================
-- Drop function template
--================================================
USE [SMC_DB_Performance]
GO

IF OBJECT_ID (N'SMC.ufn_GetGroupIRR') IS NOT NULL
   DROP FUNCTION SMC.ufn_GetGroupIRR
GO

CREATE FUNCTION [SMC].[ufn_GetGroupIRR]
(
	@GroupName	VARCHAR(255)
	,@ShortDesc VARCHAR(15)
	,@BeginDate	DATE
	,@EndDate DATE
)
RETURNS FLOAT 
AS
BEGIN
	DECLARE @XIRR FLOAT

	SET @XIRR = NULL

	IF @BeginDate IS NOT NULL AND @EndDate IS NOT NULL
	BEGIN
		SELECT @XIRR = [SMC_DB_REFERENCE].wct.XIRR(CFAmt, CFDate, NULL)
		FROM 
		(	
			-- Get EAMV and BAMV
			-- initial valuation will be treated as a synthetic cash outflow 
			-- Always turn the Valuation to negative sign
			SELECT GroupName, CFType, CFDate, (ABS(CFAmt) * -1) CFAmt
			FROM SMC.CashFlowGroup
			WHERE CFDate = EOMONTH(DATEADD(d, -1, @BeginDate))
				AND CFType = 'EAMV'
				AND GroupName = @GroupName
				-- Ingore BAMV if calculating SI
				AND @ShortDesc <> 'SI'
				--AND GroupName = 'SBST'
			UNION ALL
			-- Get Transactions
			-- Turn the cash flow to negative sign if InceptionDate = MonthEnd (First Month)
			SELECT GroupName, CFType, CFDate, 
				CASE WHEN EOMONTH(@BeginDate) = EOMONTH(@EndDate) THEN
					ABS(CFAmt) * -1.000
				ELSE
					CFAmt
				END
			FROM SMC.CashFlowGroup
			WHERE CFDate BETWEEN @BeginDate AND @EndDate
				AND CFType = 'Transaction'
				AND GroupName = @GroupName
				--AND GroupName = 'SBST'
			UNION ALL
			-- Get EAMV
			-- the ending market value will be a synthetic cash inflow
			-- keep the Valuation sign without changing it
			SELECT GroupName, CFType, CFDate, CFAmt
			FROM SMC.CashFlowGroup
			WHERE CFDate = EOMONTH(@EndDate)
				AND CFType = 'EAMV'
				AND GroupName = @GroupName
			--AND GroupName = 'SBST'	
		) x
	END

	DECLARE @DayDiff INT, @DayYear INT

	-- Get the DateDiff
	SELECT @DayDiff = DATEDIFF(dd,@BeginDate,@EndDate)
	-- Get total days in year
	SELECT @DayYear = DATEPART(dy,DATEFROMPARTS(YEAR(@EndDate),12,31))

	-- Deannualize for 3 months
	IF (@ShortDesc = '3M')
	BEGIN
		SELECT @XIRR = SMC_DB_Reference.SMC.ufn_PowerWrapper(1+@XIRR,1.0,4.0)-1 
	END
	-- Deannualize if @DayDiff less than @DayYear for SI
	IF (@ShortDesc = 'SI') AND (@DayDiff < @DayYear)
	BEGIN
		SELECT @XIRR = SMC_DB_Reference.SMC.ufn_PowerWrapper(1+@XIRR,cast(@DayDiff as float),cast(@DayYear as float))-1 
	END
		
	RETURN @XIRR
END

GO
