USE SMC_DB_Performance
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
	 AND sys.tables.name = N'GroupControl'
)
  DROP TABLE SMC.GroupControl
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [SMC].[GroupControl](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[GroupColumn] [varchar](50) NULL,
	[GroupDesc] [varchar](50) NULL,
	[GroupActive] [bit] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [SMC].[GroupControl] ON 

GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (26, N'Portfolio, SubPortfolio', N'Portfolio + SubPortfolio', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (2, N'Portfolio', N'Portfolio', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (3, N'SubPortfolio', N'SubPortfolio', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (4, N'AssetClass', N'AssetClass', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (5, N'Strategy', N'Strategy', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (6, N'AccountVintageYear', N'AccountVintageYear', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (7, N'SDFCrossInvestment', N'SDFCrossInvestment', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (8, N'Liquidity', N'Liquidity', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (9, N'Geography', N'Geography', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (10, N'StructureType', N'StructureType', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (11, N'Portfolio, SubPortfolio, AssetClass', N'Portfolio + SubPortfolio + AssetClass', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (12, N'Portfolio, Strategy', N'Portfolio + Strategy', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (13, N'Portfolio, AccountVintageYear', N'Portfolio + AccountVintageYear', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (14, N'Portfolio, SDFCrossInvestment', N'Portfolio + SDFCrossInvestment', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (15, N'Portfolio, Liquidity', N'Portfolio + Liquidity', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (16, N'Portfolio, Geography', N'Portfolio + Geography', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (17, N'Portfolio, StructureType', N'Portfolio + StructureType', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (18, N'SubPortfolio, AssetClass', N'SubPortfolio + AssetClass', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (19, N'SubPortfolio, Strategy', N'SubPortfolio + Strategy', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (20, N'SubPortfolio, AccountVintageYear', N'SubPortfolio + AccountVintageYear', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (21, N'SubPortfolio, SDFCrossInvestment', N'SubPortfolio + SDFCrossInvestment', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (22, N'SubPortfolio, Liquidity', N'SubPortfolio + Liquidity', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (23, N'SubPortfolio, Geography', N'SubPortfolio + Geography', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (24, N'SubPortfolio, StructureType', N'SubPortfolio + StructureType', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (27, N'SubPortfolio, AccountVintageYear', N'SubPortfolio + AccountVintageYear', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (28, N'CompanyName', N'CompanyName', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (29, N'Sector', N'Sector', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (30, N'SubSector', N'SubSector', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (31, N'SubPortfolio, AssetClass, StructureType', N'SubPortfolio + AssetClass + StructureType', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (32, N'SubPortfolio, Strategy, StructureType', N'SubPortfolio + Strategy + StructureType', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (33, N'Portfolio, AssetClass', N'Portfolio + AssetClass', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (34, N'Portfolio, AssetClass, StructureType', N'Portfolio + AssetClass + StructureType', 1)
GO
INSERT [SMC].[GroupControl] ([RowID], [GroupColumn], [GroupDesc], [GroupActive]) VALUES (35, N'Portfolio, Strategy, StructureType', N'Portfolio + Strategy + StructureType', 1)
GO
SET IDENTITY_INSERT [SMC].[GroupControl] OFF
GO



