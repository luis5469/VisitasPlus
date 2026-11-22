IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
GO

CREATE TABLE [Permisos] (
    [Id] varchar(10) NOT NULL,
    [Nombre] nvarchar(150) NOT NULL,
    [Modulo] nvarchar(100) NOT NULL,
    [Accion] nvarchar(100) NOT NULL,
    [Descripcion] nvarchar(500) NOT NULL,
    [CreatedAt] datetime2 NOT NULL,
    [UpdatedAt] datetime2 NOT NULL,
    CONSTRAINT [PK_Permisos] PRIMARY KEY ([Id])
);
GO

CREATE TABLE [Roles] (
    [Id] varchar(10) NOT NULL,
    [Nombre] nvarchar(100) NOT NULL,
    [Descripcion] nvarchar(500) NOT NULL,
    [Activo] bit NOT NULL,
    [CreatedAt] datetime2 NOT NULL,
    [UpdatedAt] datetime2 NOT NULL,
    CONSTRAINT [PK_Roles] PRIMARY KEY ([Id])
);
GO

CREATE TABLE [Usuarios] (
    [Id] varchar(10) NOT NULL,
    [Nombre] nvarchar(100) NOT NULL,
    [Apellido] nvarchar(100) NOT NULL,
    [Email] nvarchar(255) NOT NULL,
    [Username] nvarchar(100) NOT NULL,
    [PasswordHash] nvarchar(max) NOT NULL,
    [Rol] nvarchar(max) NOT NULL,
    [ZonaId] varchar(10) NULL,
    [SupervisorId] varchar(10) NULL,
    [Activo] bit NOT NULL DEFAULT CAST(1 AS bit),
    [BiometriaHabilitada] bit NOT NULL,
    [PushToken] nvarchar(max) NULL,
    [IntentosFallidos] int NOT NULL,
    [BloqueadoHasta] datetime2 NULL,
    [UltimoLogin] datetime2 NULL,
    [CreatedAt] datetime2 NOT NULL,
    [UpdatedAt] datetime2 NOT NULL,
    [CreatedBy] nvarchar(max) NOT NULL,
    [UpdatedBy] nvarchar(max) NULL,
    CONSTRAINT [PK_Usuarios] PRIMARY KEY ([Id])
);
GO

CREATE TABLE [RolPermisos] (
    [RolId] varchar(10) NOT NULL,
    [PermisoId] varchar(10) NOT NULL,
    CONSTRAINT [PK_RolPermisos] PRIMARY KEY ([RolId], [PermisoId]),
    CONSTRAINT [FK_RolPermisos_Permisos_PermisoId] FOREIGN KEY ([PermisoId]) REFERENCES [Permisos] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_RolPermisos_Roles_RolId] FOREIGN KEY ([RolId]) REFERENCES [Roles] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [Auditorias] (
    [Id] varchar(10) NOT NULL,
    [UsuarioId] varchar(10) NULL,
    [Accion] nvarchar(100) NOT NULL,
    [Modulo] nvarchar(100) NOT NULL,
    [EntidadAfectada] nvarchar(100) NULL,
    [EntidadId] nvarchar(100) NULL,
    [DetalleAnterior] nvarchar(max) NULL,
    [DetalleNuevo] nvarchar(max) NULL,
    [IpAddress] nvarchar(45) NULL,
    [UserAgent] nvarchar(500) NULL,
    [Exitoso] bit NOT NULL,
    [MensajeError] nvarchar(2000) NULL,
    [CreatedAt] datetime2 NOT NULL,
    [UpdatedAt] datetime2 NOT NULL,
    CONSTRAINT [PK_Auditorias] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Auditorias_Usuarios_UsuarioId] FOREIGN KEY ([UsuarioId]) REFERENCES [Usuarios] ([Id]) ON DELETE SET NULL
);
GO

CREATE TABLE [Dispositivos] (
    [Id] varchar(10) NOT NULL,
    [UsuarioId] varchar(10) NOT NULL,
    [DeviceId] nvarchar(255) NOT NULL,
    [Nombre] nvarchar(200) NOT NULL,
    [Plataforma] nvarchar(50) NOT NULL,
    [ModeloDispositivo] nvarchar(150) NULL,
    [VersionSO] nvarchar(50) NULL,
    [PushToken] nvarchar(512) NULL,
    [Activo] bit NOT NULL,
    [Confiable] bit NOT NULL,
    [UltimoAcceso] datetime2 NULL,
    [CreatedAt] datetime2 NOT NULL,
    [UpdatedAt] datetime2 NOT NULL,
    CONSTRAINT [PK_Dispositivos] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Dispositivos_Usuarios_UsuarioId] FOREIGN KEY ([UsuarioId]) REFERENCES [Usuarios] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [UsuarioRoles] (
    [UsuarioId] varchar(10) NOT NULL,
    [RolId] varchar(10) NOT NULL,
    CONSTRAINT [PK_UsuarioRoles] PRIMARY KEY ([UsuarioId], [RolId]),
    CONSTRAINT [FK_UsuarioRoles_Roles_RolId] FOREIGN KEY ([RolId]) REFERENCES [Roles] ([Id]) ON DELETE NO ACTION,
    CONSTRAINT [FK_UsuarioRoles_Usuarios_UsuarioId] FOREIGN KEY ([UsuarioId]) REFERENCES [Usuarios] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [Visitas] (
    [Id] varchar(10) NOT NULL,
    [PdvId] varchar(10) NOT NULL,
    [VisitadorId] varchar(10) NOT NULL,
    [Estado] int NOT NULL,
    [LatitudInicio] decimal(18,2) NULL,
    [LongitudInicio] decimal(18,2) NULL,
    [LatitudFin] decimal(18,2) NULL,
    [LongitudFin] decimal(18,2) NULL,
    [TimestampInicio] datetime2 NOT NULL,
    [TimestampFin] datetime2 NULL,
    [ActaPdfUrl] nvarchar(max) NULL,
    [Sincronizado] bit NOT NULL,
    [CreatedAt] datetime2 NOT NULL,
    [UpdatedAt] datetime2 NOT NULL,
    [CreatedBy] nvarchar(max) NOT NULL,
    [UpdatedBy] nvarchar(max) NULL,
    CONSTRAINT [PK_Visitas] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Visitas_Usuarios_VisitadorId] FOREIGN KEY ([VisitadorId]) REFERENCES [Usuarios] ([Id]) ON DELETE NO ACTION
);
GO

CREATE TABLE [RefreshTokens] (
    [Id] varchar(10) NOT NULL,
    [UsuarioId] varchar(10) NOT NULL,
    [Token] nvarchar(512) NOT NULL,
    [JwtId] nvarchar(100) NOT NULL,
    [ExpiresAt] datetime2 NOT NULL,
    [IsUsed] bit NOT NULL,
    [IsRevoked] bit NOT NULL,
    [RevokedReason] nvarchar(300) NULL,
    [RevokedAt] datetime2 NULL,
    [IpAddress] nvarchar(45) NULL,
    [UserAgent] nvarchar(500) NULL,
    [DispositivoId] varchar(10) NULL,
    [CreatedAt] datetime2 NOT NULL,
    [UpdatedAt] datetime2 NOT NULL,
    CONSTRAINT [PK_RefreshTokens] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_RefreshTokens_Dispositivos_DispositivoId] FOREIGN KEY ([DispositivoId]) REFERENCES [Dispositivos] ([Id]) ON DELETE SET NULL,
    CONSTRAINT [FK_RefreshTokens_Usuarios_UsuarioId] FOREIGN KEY ([UsuarioId]) REFERENCES [Usuarios] ([Id]) ON DELETE NO ACTION
);
GO

CREATE TABLE [Novedades] (
    [Id] varchar(10) NOT NULL,
    [VisitaId] varchar(10) NOT NULL,
    [PdvId] varchar(10) NOT NULL,
    [Titulo] nvarchar(max) NOT NULL,
    [Descripcion] nvarchar(max) NOT NULL,
    [Categoria] nvarchar(max) NOT NULL,
    [Prioridad] nvarchar(max) NOT NULL,
    [Estado] int NOT NULL,
    [ResponsableSolucionId] varchar(10) NOT NULL,
    [ResponsableSeguimientoId] varchar(10) NOT NULL,
    [FechaSeguimiento] datetime2 NOT NULL,
    [Sincronizado] bit NOT NULL,
    [CreatedAt] datetime2 NOT NULL,
    [UpdatedAt] datetime2 NOT NULL,
    [CreatedBy] nvarchar(max) NOT NULL,
    [UpdatedBy] nvarchar(max) NULL,
    CONSTRAINT [PK_Novedades] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Novedades_Visitas_VisitaId] FOREIGN KEY ([VisitaId]) REFERENCES [Visitas] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [NovedadHistorial] (
    [Id] varchar(10) NOT NULL,
    [NovedadId] varchar(10) NOT NULL,
    [EstadoAnterior] int NOT NULL,
    [EstadoNuevo] int NOT NULL,
    [Comentario] nvarchar(max) NOT NULL,
    [UsuarioId] varchar(10) NOT NULL,
    [CreatedAt] datetime2 NOT NULL,
    [UpdatedAt] datetime2 NOT NULL,
    CONSTRAINT [PK_NovedadHistorial] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_NovedadHistorial_Novedades_NovedadId] FOREIGN KEY ([NovedadId]) REFERENCES [Novedades] ([Id]) ON DELETE CASCADE
);
GO

CREATE TABLE [NovedadImagenes] (
    [Id] varchar(10) NOT NULL,
    [NovedadId] varchar(10) NOT NULL,
    [UrlImagen] nvarchar(max) NOT NULL,
    [NombreArchivo] nvarchar(max) NOT NULL,
    [TamanoBytes] bigint NOT NULL,
    [MarcaAguaAplicada] bit NOT NULL,
    [Latitud] decimal(18,2) NULL,
    [Longitud] decimal(18,2) NULL,
    [TimestampCaptura] datetime2 NULL,
    [SubidoPor] varchar(10) NOT NULL,
    [CreatedAt] datetime2 NOT NULL,
    [UpdatedAt] datetime2 NOT NULL,
    CONSTRAINT [PK_NovedadImagenes] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_NovedadImagenes_Novedades_NovedadId] FOREIGN KEY ([NovedadId]) REFERENCES [Novedades] ([Id]) ON DELETE CASCADE
);
GO

INSERT INTO [Roles] ([Id], [Activo], [CreatedAt], [Descripcion], [Nombre], [UpdatedAt])
VALUES ('ROL-VISITD', CAST(1 AS bit), '2024-01-01T00:00:00.0000000Z', N'Visitador de puntos de venta', N'Visitador', '2024-01-01T00:00:00.0000000Z'),
('ROL-SUPERV', CAST(1 AS bit), '2024-01-01T00:00:00.0000000Z', N'Supervisor de zona', N'Supervisor', '2024-01-01T00:00:00.0000000Z'),
('ROL-ADMINS', CAST(1 AS bit), '2024-01-01T00:00:00.0000000Z', N'Administrador del sistema', N'Administrador', '2024-01-01T00:00:00.0000000Z');
GO

CREATE INDEX [IX_Auditorias_CreatedAt] ON [Auditorias] ([CreatedAt]);
GO

CREATE INDEX [IX_Auditorias_UsuarioId] ON [Auditorias] ([UsuarioId]);
GO

CREATE UNIQUE INDEX [IX_Dispositivos_DeviceId] ON [Dispositivos] ([DeviceId]);
GO

CREATE INDEX [IX_Dispositivos_UsuarioId] ON [Dispositivos] ([UsuarioId]);
GO

CREATE INDEX [IX_Novedades_VisitaId] ON [Novedades] ([VisitaId]);
GO

CREATE INDEX [IX_NovedadHistorial_NovedadId] ON [NovedadHistorial] ([NovedadId]);
GO

CREATE INDEX [IX_NovedadImagenes_NovedadId] ON [NovedadImagenes] ([NovedadId]);
GO

CREATE UNIQUE INDEX [IX_Permisos_Nombre] ON [Permisos] ([Nombre]);
GO

CREATE INDEX [IX_RefreshTokens_DispositivoId] ON [RefreshTokens] ([DispositivoId]);
GO

CREATE UNIQUE INDEX [IX_RefreshTokens_Token] ON [RefreshTokens] ([Token]);
GO

CREATE INDEX [IX_RefreshTokens_UsuarioId] ON [RefreshTokens] ([UsuarioId]);
GO

CREATE UNIQUE INDEX [IX_Roles_Nombre] ON [Roles] ([Nombre]);
GO

CREATE INDEX [IX_RolPermisos_PermisoId] ON [RolPermisos] ([PermisoId]);
GO

CREATE INDEX [IX_UsuarioRoles_RolId] ON [UsuarioRoles] ([RolId]);
GO

CREATE UNIQUE INDEX [IX_Usuarios_Email] ON [Usuarios] ([Email]);
GO

CREATE UNIQUE INDEX [IX_Usuarios_Username] ON [Usuarios] ([Username]);
GO

CREATE INDEX [IX_Visitas_VisitadorId] ON [Visitas] ([VisitadorId]);
GO


INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260513045729_InitialAuth', N'8.0.11');
GO

COMMIT;
GO
