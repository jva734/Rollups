USE SMC_DB_Performance
GO

/****** Object:  Table [SMC].[GroupControlThread]    Script Date: 12/4/2015 9:18:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [SMC].[GroupControlThread](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[GroupColumn] [varchar](50) NULL,
	[GroupDesc] [varchar](50) NULL,
	[GroupActive] [bit] NULL,
	[ThreadID] [int] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


