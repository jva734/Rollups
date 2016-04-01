-- =====	========================================
-- Author:		Daniel Pan
-- Create date: 03/06/2015
-- Description:	Return date range for 1M, 3M, 1Yr, 3Yr, 5Yr, 7Yr, 10Yr, CY, JY, SI
-- 
/**
SELECT *
FROM [SMC].[ufn_GetPeriodic] ('2000-09-11','2013-01-30')
**/
-- =============================================

--================================================
-- Drop function template
--================================================
USE [SMC_DB_Performance]
GO

IF OBJECT_ID (N'SMC.ufn_GetPeriodic') IS NOT NULL
   DROP FUNCTION SMC.ufn_GetPeriodic
GO

CREATE FUNCTION SMC.ufn_GetPeriodic(@BeginDate DATE, @EndDate DATE)
	RETURNS @Periodic
		TABLE (ID TINYINT IDENTITY, LongDesc VARCHAR(50), ShortDesc VARCHAR(50), BeginDate DATE, EndDate DATE)

AS
BEGIN
	DECLARE @MonthDiff int
	SET @MonthDiff = (DATEDIFF(MONTH, @BeginDate, @EndDate) + 1)
	
	IF @MonthDiff >= 1
		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('1 Month', '1M', DATEADD(d, 1, EOMONTH(@EndDate,-1)), @EndDate)
	ELSE
		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('1 Month', '1M', NULL, @EndDate)

	IF @MonthDiff >= 3 
		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('3 Months', '3M', DATEADD(d, 1, EOMONTH(DATEADD(m, -3, @EndDate))), @EndDate)
	ELSE
		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('3 Months', '3M', NULL, @EndDate)

	IF @MonthDiff >= 12 
		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('1 Year', '1Yr', DATEADD(d, 1, EOMONTH(DATEADD(m, -12, @EndDate))), @EndDate)
	ELSE
		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('1 Year', '1Yr', NULL, @EndDate)

	IF @MonthDiff >= 36
		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('3 Years', '3Yr', DATEADD(d, 1, EOMONTH(DATEADD(m, -36, @EndDate))), @EndDate)
	ELSE
		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('3 Years', '3Yr', NULL, @EndDate)

	IF @MonthDiff >= 60
		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('5 Years', '5Yr', DATEADD(d, 1, EOMONTH(DATEADD(m, -60, @EndDate))), @EndDate)
	ELSE
		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('5 Years', '5Yr', NULL, @EndDate)

	IF @MonthDiff >= 84
		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('7 Years', '7Yr', DATEADD(d, 1, EOMONTH(DATEADD(m, -84, @EndDate))), @EndDate)
	ELSE
		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('7 Years', '7Yr', NULL, @EndDate)

	IF @MonthDiff >= 120
		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('10 Years', '10Yr', DATEADD(d, 1, EOMONTH(DATEADD(m, -120, @EndDate))), @EndDate)
	ELSE
		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('10 Years', '10Yr', NULL, @EndDate)

	IF CONVERT(VARCHAR, YEAR(@EndDate)) + '-01-31' < @BeginDate
		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('CYTD', 'CYTD', DATEADD(d, 1, EOMONTH(@BeginDate,-1)), @EndDate)
	ELSE 
		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('CYTD', 'CYTD', CONVERT(VARCHAR, YEAR(@EndDate)) + '-01-01', @EndDate)

	IF Month(@EndDate) >= 7
		IF CONVERT(VARCHAR, YEAR(@EndDate)) + '-07-31' < @BeginDate
			INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
			VALUES('JYTD', 'JYTD', DATEADD(d, 1, EOMONTH(@BeginDate,-1)), @EndDate)
		ELSE
			INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
			VALUES('JYTD', 'JYTD', CONVERT(VARCHAR, YEAR(@EndDate)) + '-07-01', @EndDate)
    Else
		IF CONVERT(VARCHAR, YEAR(@EndDate)-1) + '-07-31' < @BeginDate
			INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
			VALUES('JYTD', 'JYTD', DATEADD(d, 1, EOMONTH(@BeginDate,-1)), @EndDate)
		ELSE
			INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
			VALUES('JYTD', 'JYTD', CONVERT(VARCHAR, YEAR(@EndDate)-1) + '-07-01', @EndDate)

	DECLARE @QtrNum INT 
	SELECT @QtrNum = DATENAME(qq, @EndDate)

	INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
	VALUES
	('Prev. Quarter 1', 'PrevQ1', IIF(@BeginDate < dateadd(quarter, datediff(quarter, 0, @EndDate) - 1, 0), dateadd(quarter, datediff(quarter, 0, @EndDate) - 1, 0), IIF(@BeginDate < dateadd(quarter, datediff(quarter, -1, @EndDate) - 1, -1), @BeginDate, NULL)), IIF(@BeginDate < dateadd(quarter, datediff(quarter, -1, @EndDate) - 1, -1), dateadd(quarter, datediff(quarter, -1, @EndDate) - 1, -1), NULL)),
	('Prev. Quarter 2', 'PrevQ2', IIF(@BeginDate < dateadd(quarter, datediff(quarter, 0, @EndDate) - 2, 0), dateadd(quarter, datediff(quarter, 0, @EndDate) - 2, 0), IIF(@BeginDate < dateadd(quarter, datediff(quarter, -1, @EndDate) - 2, -1), @BeginDate, NULL)), IIF(@BeginDate < dateadd(quarter, datediff(quarter, -1, @EndDate) - 2, -1), dateadd(quarter, datediff(quarter, -1, @EndDate) - 2, -1), NULL)),
	('Prev. Quarter 3', 'PrevQ3', IIF(@BeginDate < dateadd(quarter, datediff(quarter, 0, @EndDate) - 3, 0), dateadd(quarter, datediff(quarter, 0, @EndDate) - 3, 0), IIF(@BeginDate < dateadd(quarter, datediff(quarter, -1, @EndDate) - 3, -1), @BeginDate, NULL)), IIF(@BeginDate < dateadd(quarter, datediff(quarter, -1, @EndDate) - 3, -1), dateadd(quarter, datediff(quarter, -1, @EndDate) - 3, -1), NULL)),
	('Prev. Quarter 4', 'PrevQ4', IIF(@BeginDate < dateadd(quarter, datediff(quarter, 0, @EndDate) - 4, 0), dateadd(quarter, datediff(quarter, 0, @EndDate) - 4, 0), IIF(@BeginDate < dateadd(quarter, datediff(quarter, -1, @EndDate) - 4, -1), @BeginDate, NULL)), IIF(@BeginDate < dateadd(quarter, datediff(quarter, -1, @EndDate) - 4, -1), dateadd(quarter, datediff(quarter, -1, @EndDate) - 4, -1), NULL))

	-- CY Return Q1
	IF @QtrNum = 1 
	BEGIN
		--INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		--VALUES
		--('JY Quarter 3', 'JYQ3', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)-1) + '-07-01', CONVERT(VARCHAR, YEAR(@EndDate)-1) + '-07-01', NULL), IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)-1) + '-09-30', CONVERT(VARCHAR, YEAR(@EndDate)-1) + '-09-30', NULL)),
		--('JY Quarter 4', 'JYQ4', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)-1) + '-10-01', CONVERT(VARCHAR, YEAR(@EndDate)-1) + '-10-01', NULL), IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)-1) + '-12-31', CONVERT(VARCHAR, YEAR(@EndDate)-1) + '-12-31', NULL)),
		--('JY Quarter 1', 'JYQ1', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)) + '-01-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-01-01', @BeginDate), @EndDate),
		--('JY Quarter 2', 'JYQ2', NULL, NULL) 

		--INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		--VALUES('CY Quarter 1', 'CYQ1', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)) + '-01-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-01-01', @BeginDate), @EndDate),
		--('CY Quarter 2', 'CYQ2', NULL, NULL), 
		--('CY Quarter 3', 'CYQ3', NULL, NULL), 
		--('CY Quarter 4', 'CYQ4', NULL, NULL)

		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('CY QTD', 'CYQTD', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)) + '-01-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-01-01', @BeginDate), @EndDate)

		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('JY QTD', 'JYQTD', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)) + '-01-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-01-01', @BeginDate), @EndDate)
	END
	ELSE IF @QtrNum = 2
	BEGIN
		--INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		--VALUES
		--('JY Quarter 3', 'JYQ3', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)-1) + '-07-01', CONVERT(VARCHAR, YEAR(@EndDate)-1) + '-07-01', NULL), IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)-1) + '-09-30', CONVERT(VARCHAR, YEAR(@EndDate)-1) + '-09-30', NULL)),
		--('JY Quarter 4', 'JYQ4', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)-1) + '-10-01', CONVERT(VARCHAR, YEAR(@EndDate)-1) + '-10-01', NULL), IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)-1) + '-12-31', CONVERT(VARCHAR, YEAR(@EndDate)-1) + '-12-31', NULL)),
		--('JY Quarter 1', 'JYQ1', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)) + '-01-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-01-01', NULL), IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)) + '-03-31', CONVERT(VARCHAR, YEAR(@EndDate)) + '-03-01', NULL)),
		--('JY Quarter 2', 'JYQ2', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)) + '-04-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-04-01', @BeginDate), @EndDate)

		--INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		--VALUES ('CY Quarter 1', 'CYQ1', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)) + '-01-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-01-01', @BeginDate), CONVERT(VARCHAR, YEAR(@EndDate)) + '-03-31'),
		--('CY Quarter 2', 'CYQ2', CONVERT(VARCHAR, YEAR(@EndDate)) + '-04-01', @EndDate),
		--('CY Quarter 3', 'CYQ3', NULL, NULL), 
		--('CY Quarter 4', 'CYQ4', NULL, NULL)

		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('CY QTD', 'CYQTD', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)) + '-04-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-04-01', @BeginDate), @EndDate)

		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('JY QTD', 'JYQTD', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)) + '-04-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-04-01', @BeginDate), @EndDate)	
	END
	ELSE IF @QtrNum = 3
	BEGIN
		--INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		--VALUES
		--('JY Quarter 3', 'JYQ3', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)) + '-07-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-07-01', @BeginDate), @EndDate),
		--('JY Quarter 4', 'JYQ4', NULL, NULL),
		--('JY Quarter 1', 'JYQ1', NULL, NULL),
		--('JY Quarter 2', 'JYQ2', NULL, NULL)
		
		--INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		--VALUES('CY Quarter 1', 'CYQ1', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)) + '-01-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-01-01', @BeginDate), CONVERT(VARCHAR, YEAR(@EndDate)) + '-03-31'),
		--('CY Quarter 2', 'CYQ2', CONVERT(VARCHAR, YEAR(@EndDate)) + '-04-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-06-30'),
		--('CY Quarter 3', 'CYQ3', CONVERT(VARCHAR, YEAR(@EndDate)) + '-07-01', @EndDate),
		--('CY Quarter 4', 'CYQ4', NULL, NULL)

		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('CY QTD', 'CYQTD', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)) + '-07-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-07-01', @BeginDate), @EndDate)

		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('JY QTD', 'JYQTD', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)) + '-07-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-07-01', @BeginDate), @EndDate)
	END
	ELSE IF @QtrNum = 4
	BEGIN
		--INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		--VALUES
		--('JY Quarter 3', 'JYQ3', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)) + '-07-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-07-01', NULL), IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)) + '-09-30', CONVERT(VARCHAR, YEAR(@EndDate)) + '-09-30', NULL)),
		--('JY Quarter 4', 'JYQ4', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)) + '-10-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-10-01', @BeginDate), @EndDate),
		--('JY Quarter 1', 'JYQ1', NULL, NULL),
		--('JY Quarter 2', 'JYQ2', NULL, NULL) 

		--INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		--VALUES('CY Quarter 1', 'CYQ1', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)) + '-01-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-01-01', @BeginDate), CONVERT(VARCHAR, YEAR(@EndDate)) + '-03-31'),
		--('CY Quarter 2', 'CYQ2', CONVERT(VARCHAR, YEAR(@EndDate)) + '-04-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-06-30'),
		--('CY Quarter 3', 'CYQ3', CONVERT(VARCHAR, YEAR(@EndDate)) + '-07-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-09-30'),
		--('CY Quarter 4', 'CYQ4', CONVERT(VARCHAR, YEAR(@EndDate)) + '-10-01', @EndDate)

		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('CY QTD', 'CYQTD', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)) + '-10-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-10-01', @BeginDate), @EndDate)

		INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
		VALUES('JY QTD', 'JYQTD', IIF(@BeginDate < CONVERT(VARCHAR, YEAR(@EndDate)) + '-10-01', CONVERT(VARCHAR, YEAR(@EndDate)) + '-10-01', @BeginDate), @EndDate)
	END
	IF @MonthDiff >= 1
	INSERT INTO @Periodic (LongDesc, ShortDesc, BeginDate, EndDate)
	VALUES('Since Inception', 'SI', DATEADD(d, 1, EOMONTH(@BeginDate,-1)), @EndDate)


	RETURN
END
GO


   