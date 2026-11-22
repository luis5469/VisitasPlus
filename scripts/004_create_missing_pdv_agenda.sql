USE [visitapdv];
GO

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
GO

IF OBJECT_ID(N'[dbo].[PDV]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[PDV]
    (
        [Id] varchar(10) NOT NULL,
        [Codigo] nvarchar(20) NOT NULL,
        [Nombre] nvarchar(200) NOT NULL,
        [Direccion] nvarchar(300) NOT NULL,
        [Ciudad] nvarchar(100) NOT NULL,
        [Zona] nvarchar(100) NULL,
        [Responsable] nvarchar(150) NULL,
        [Telefono] nvarchar(20) NULL,
        [Latitud] decimal(10,7) NOT NULL,
        [Longitud] decimal(10,7) NOT NULL,
        [GeofenceMetros] int NOT NULL CONSTRAINT [DF_PDV_GeofenceMetros] DEFAULT 100,
        [Activo] bit NOT NULL CONSTRAINT [DF_PDV_Activo] DEFAULT CAST(1 AS bit),
        [CreatedAt] datetime2 NOT NULL CONSTRAINT [DF_PDV_CreatedAt] DEFAULT SYSUTCDATETIME(),
        [UpdatedAt] datetime2 NOT NULL CONSTRAINT [DF_PDV_UpdatedAt] DEFAULT SYSUTCDATETIME(),
        [CreatedBy] nvarchar(max) NOT NULL CONSTRAINT [DF_PDV_CreatedBy] DEFAULT N'',
        [UpdatedBy] nvarchar(max) NULL,
        CONSTRAINT [PK_PDV] PRIMARY KEY ([Id])
    );

    CREATE UNIQUE INDEX [IX_PDV_Codigo] ON [dbo].[PDV] ([Codigo]);
END;
GO

IF OBJECT_ID(N'[dbo].[AgendaVisitas]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[AgendaVisitas]
    (
        [Id] varchar(10) NOT NULL,
        [PdvId] varchar(10) NOT NULL,
        [VisitadorId] varchar(10) NOT NULL,
        [FechaPlaneada] datetime2 NOT NULL,
        [Observaciones] nvarchar(500) NULL,
        [Completada] bit NOT NULL CONSTRAINT [DF_AgendaVisitas_Completada] DEFAULT CAST(0 AS bit),
        [CreatedAt] datetime2 NOT NULL CONSTRAINT [DF_AgendaVisitas_CreatedAt] DEFAULT SYSUTCDATETIME(),
        [UpdatedAt] datetime2 NOT NULL CONSTRAINT [DF_AgendaVisitas_UpdatedAt] DEFAULT SYSUTCDATETIME(),
        [CreatedBy] nvarchar(max) NOT NULL CONSTRAINT [DF_AgendaVisitas_CreatedBy] DEFAULT N'',
        [UpdatedBy] nvarchar(max) NULL,
        CONSTRAINT [PK_AgendaVisitas] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_AgendaVisitas_PDV_PdvId] FOREIGN KEY ([PdvId]) REFERENCES [dbo].[PDV] ([Id]) ON DELETE NO ACTION,
        CONSTRAINT [FK_AgendaVisitas_Usuarios_VisitadorId] FOREIGN KEY ([VisitadorId]) REFERENCES [dbo].[Usuarios] ([Id]) ON DELETE NO ACTION
    );

    CREATE INDEX [IX_AgendaVisitas_PdvId] ON [dbo].[AgendaVisitas] ([PdvId]);
    CREATE INDEX [IX_AgendaVisitas_VisitadorId] ON [dbo].[AgendaVisitas] ([VisitadorId]);
    CREATE INDEX [IX_AgendaVisitas_FechaPlaneada] ON [dbo].[AgendaVisitas] ([FechaPlaneada]);
END;
GO

COMMIT;
GO