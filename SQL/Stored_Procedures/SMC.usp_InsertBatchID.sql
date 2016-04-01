USE SMC_DB_Performance
GO

-- Drop stored procedure if it already exists
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'SMC'
     AND SPECIFIC_NAME = N'usp_InsertBatchID' 
)
   DROP PROCEDURE SMC.usp_InsertBatchID
GO

CREATE PROCEDURE SMC.usp_InsertBatchID
	@Name varchar(250)	
	,@BatchID INT OUTPUT
AS

INSERT INTO [SMC].[BatchID]
           ([BatchName]
           ,[CreateDate]
           ,[CreateUser])
     VALUES
           (@Name 
           ,GETDATE()
           ,CURRENT_USER)

SELECT @BatchID = SCOPE_IDENTITY() 


