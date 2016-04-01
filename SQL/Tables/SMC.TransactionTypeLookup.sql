USE SMC_DB_Portfolio
GO


/****** Object:  Table [SMC].[TransactionTypeLookup]    Script Date: 5/19/2015 12:42:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--======================
-- Drop Table template
--======================
IF EXISTS (
  SELECT *
	FROM sys.tables
	JOIN sys.schemas
	  ON sys.tables.schema_id = sys.schemas.schema_id
   WHERE sys.schemas.name = N'SMC'
	 AND sys.tables.name = N'TransactionTypeLookup'
)
  DROP TABLE [SMC].[TransactionTypeLookup]
GO

CREATE TABLE [SMC].[TransactionTypeLookup](
	[TransactionTypeLookupID] [bigint] IDENTITY(1,1) NOT NULL,
	[DataSource] [nvarchar](50) NOT NULL,
	[TransactionCategory] [nvarchar](50) NOT NULL,
	[TransactionTypeDesc] [nvarchar](255) NOT NULL,
	[TaxCode] [nvarchar](10) NULL,
	[SubTransactionCode] [nvarchar](10) NULL,
	[AssetCategoryCode] [nvarchar](10) NULL,
	[FirmCodeFilter] [bit] NULL,
	[LedgerFilterID] [int] NULL,
 CONSTRAINT [PK__Transact__AEC2B563243E56DE] PRIMARY KEY CLUSTERED 
(
	[TransactionTypeLookupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Capital Calls','Capital Calls','0651','B','B',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Capital Calls','Capital Calls','0651','B','E',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Capital Calls','Capital Calls','0651','B','C',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Capital Calls','Capital Calls','0651','B','L',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Capital Calls','Capital Call Corrections','0651','BC','B',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Capital Calls','Capital Call Corrections','0651','BC','E',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Capital Calls','Capital Call Corrections','0651','BC','C',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Capital Calls','Capital Call Corrections','0651','BC','L',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Principal','0151','S','B',1,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Principal','0151','S','E',1,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Principal','0151','S','C',1,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Principal','0151','S','L',1,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Principal','0158','CD','B',1,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Principal','0158','CD','E',1,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Principal','0158','CD','C',1,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Principal','0158','CD','L',1,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Principal Corrections','0151','SC','B',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Principal Corrections','0151','SC','E',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Principal Corrections','0151','SC','C',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Principal Corrections','0151','SC','L',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Principal Corrections','0158','CDC','B',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Principal Corrections','0158','CDC','E',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Principal Corrections','0158','CDC','C',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Principal Corrections','0158','CDC','L',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Income','0031','IT','',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Income','0409','CD','',1,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Income','0011','DV','',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Income','0093','CD','#055',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Income','0372','CD','',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Income Corrections','0031','ITC','',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Income Corrections','0409','CDC','',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Income Corrections','0011','DVC','',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Income Corrections','0093','CDC','#055',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Cash Income Corrections','0372','CDC','',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Stock Principal','0TFI','SD','#090',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Stock Principal','0TFO','SD','#165',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Stock Principal','0151','SD','E',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('CD','Distributions','Stock Income','0482','SD','',0,-1)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('PI','Funding','Capital Calls','','','',0,NULL)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('PI','Fees','Additional Fees','','','',0,NULL)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('PI','Distributions','Cash Principal','','','',0,NULL)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('PI','Distributions','Cash Income','','','',0,NULL)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('PI','Distributions','Cash Income RE/NR Royalties','','','',0,NULL)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('PI','Stock','Stock Distributions','','','',0,NULL)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('PI','Funding','Recallable Capital','','','',0,NULL)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('PI','Distributions','Cash Distributions','','','',0,NULL)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('PI','Funding','Funding IRR','','','',0,NULL)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('PI','AdditionalFees','AdditionalFees IRR','','','',0,NULL)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('PI','CashDistribution','CashDistribution IRR','','','',0,NULL)
INSERT INTO [SMC].[TransactionTypeLookup] ([DataSource],[TransactionCategory],[TransactionTypeDesc],[TaxCode],[SubTransactionCode],[AssetCategoryCode],[FirmCodeFilter],[LedgerFilterID]) VALUES ('PI','StockDistribution','StockDistribution IRR','','','',0,NULL)
