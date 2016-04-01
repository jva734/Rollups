-- =============================================
-- Create basic stored procedure template
-- =============================================
USE SMC_DB_Performance
GO


IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_XIRR_wrapper' 
)
   DROP PROCEDURE SMC.usp_XIRR_wrapper
GO

CREATE PROCEDURE SMC.usp_XIRR_wrapper 
AS

SET NOCOUNT ON

/* 1 Month*/
EXEC SMC.usp_XIRR_1Mth

/* 3 Month*/
EXEC SMC.usp_XIRR_3Mth

/* 1 Year */
EXEC SMC.usp_XIRR_1Yr

/* 3 Year */
EXEC SMC.usp_XIRR_3Yr

/* 5 Year */
EXEC SMC.usp_XIRR_5Yr

/* 7 Year */
EXEC SMC.usp_XIRR_7Yr

/* 10 Year */
EXEC SMC.usp_XIRR_10Yr

/* Year To Date (CY)*/
EXEC SMC.usp_XIRR_YTD

/* Year To Date (JY)*/
EXEC SMC.usp_XIRR_JY

/* Since Inception */
EXEC SMC.usp_XIRR_SI

