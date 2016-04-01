USE SMC_DB_Mellon
GO


SELECT * FROM [dbo].[SIDTransactionDetail]
WHERE [EFFECTIVE DATE] >= '2014-10-01'
ORDER BY [EFFECTIVE DATE] 

/*
SELECT * INTO [dbo].[SIDTransactionDetail_2016_02_16]
FROM [dbo].[SIDTransactionDetail]
*/

