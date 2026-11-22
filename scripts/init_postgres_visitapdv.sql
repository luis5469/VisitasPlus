-- =============================================================================
-- SCRIPT DE INICIALIZACIÓN PARA POSTGRESQL (Rocky Linux / VPS)
-- Proyecto: VisitaPDV
-- Compatible con PostgreSQL 14 / 15 / 16 (Estándar PremiaPlay / Farmaenlace)
-- =============================================================================

-- 1. CREACIÓN DE BASE DE DATOS Y USUARIO AISLADO (Ejecutar como superusuario 'postgres')
-- CREATE USER visitapdv_user WITH PASSWORD 'TU_PASSWORD_SEGURO';
-- CREATE DATABASE visitapdv OWNER visitapdv_user;
-- GRANT ALL PRIVILEGES ON DATABASE visitapdv TO visitapdv_user;
-- \c visitapdv visitapdv_user;

-- Habilitar extensión UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. TABLA: Permisos
CREATE TABLE IF NOT EXISTS "Permisos" (
    "Id" VARCHAR(10) PRIMARY KEY,
    "Nombre" VARCHAR(150) NOT NULL UNIQUE,
    "Modulo" VARCHAR(100) NOT NULL,
    "Accion" VARCHAR(100) NOT NULL,
    "Descripcion" VARCHAR(500) NOT NULL,
    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 3. TABLA: Roles
CREATE TABLE IF NOT EXISTS "Roles" (
    "Id" VARCHAR(10) PRIMARY KEY,
    "Nombre" VARCHAR(100) NOT NULL,
    "Descripcion" VARCHAR(500) NOT NULL,
    "Activo" BOOLEAN NOT NULL DEFAULT TRUE,
    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 4. TABLA: Usuarios
CREATE TABLE IF NOT EXISTS "Usuarios" (
    "Id" VARCHAR(10) PRIMARY KEY,
    "Nombre" VARCHAR(100) NOT NULL,
    "Apellido" VARCHAR(100) NOT NULL,
    "Email" VARCHAR(255) NOT NULL UNIQUE,
    "Username" VARCHAR(100) NOT NULL UNIQUE,
    "PasswordHash" TEXT NOT NULL,
    "Rol" VARCHAR(50) NOT NULL,
    "ZonaId" VARCHAR(10) NULL,
    "SupervisorId" VARCHAR(10) NULL,
    "Activo" BOOLEAN NOT NULL DEFAULT TRUE,
    "BiometriaHabilitada" BOOLEAN NOT NULL DEFAULT FALSE,
    "PushToken" TEXT NULL,
    "IntentosFallidos" INT NOT NULL DEFAULT 0,
    "BloqueadoHasta" TIMESTAMPTZ NULL,
    "UltimoLogin" TIMESTAMPTZ NULL,
    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "CreatedBy" VARCHAR(100) NOT NULL DEFAULT '',
    "UpdatedBy" VARCHAR(100) NULL
);

-- 5. TABLA: RolPermisos
CREATE TABLE IF NOT EXISTS "RolPermisos" (
    "RolId" VARCHAR(10) NOT NULL REFERENCES "Roles"("Id") ON DELETE CASCADE,
    "PermisoId" VARCHAR(10) NOT NULL REFERENCES "Permisos"("Id") ON DELETE CASCADE,
    PRIMARY KEY ("RolId", "PermisoId")
);

-- 6. TABLA: UsuarioRoles
CREATE TABLE IF NOT EXISTS "UsuarioRoles" (
    "UsuarioId" VARCHAR(10) NOT NULL REFERENCES "Usuarios"("Id") ON DELETE CASCADE,
    "RolId" VARCHAR(10) NOT NULL REFERENCES "Roles"("Id") ON DELETE NO ACTION,
    PRIMARY KEY ("UsuarioId", "RolId")
);

-- 7. TABLA: Dispositivos
CREATE TABLE IF NOT EXISTS "Dispositivos" (
    "Id" VARCHAR(10) PRIMARY KEY,
    "UsuarioId" VARCHAR(10) NOT NULL REFERENCES "Usuarios"("Id") ON DELETE CASCADE,
    "DeviceId" VARCHAR(255) NOT NULL UNIQUE,
    "Nombre" VARCHAR(200) NOT NULL,
    "Plataforma" VARCHAR(50) NOT NULL,
    "ModeloDispositivo" VARCHAR(150) NULL,
    "VersionSO" VARCHAR(50) NULL,
    "PushToken" VARCHAR(512) NULL,
    "Activo" BOOLEAN NOT NULL DEFAULT TRUE,
    "Confiable" BOOLEAN NOT NULL DEFAULT FALSE,
    "UltimoAcceso" TIMESTAMPTZ NULL,
    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 8. TABLA: RefreshTokens
CREATE TABLE IF NOT EXISTS "RefreshTokens" (
    "Id" VARCHAR(10) PRIMARY KEY,
    "UsuarioId" VARCHAR(10) NOT NULL REFERENCES "Usuarios"("Id") ON DELETE CASCADE,
    "Token" VARCHAR(512) NOT NULL UNIQUE,
    "JwtId" VARCHAR(100) NOT NULL,
    "ExpiresAt" TIMESTAMPTZ NOT NULL,
    "IsUsed" BOOLEAN NOT NULL DEFAULT FALSE,
    "IsRevoked" BOOLEAN NOT NULL DEFAULT FALSE,
    "RevokedReason" VARCHAR(300) NULL,
    "RevokedAt" TIMESTAMPTZ NULL,
    "IpAddress" VARCHAR(45) NULL,
    "UserAgent" VARCHAR(500) NULL,
    "DispositivoId" VARCHAR(10) NULL REFERENCES "Dispositivos"("Id") ON DELETE SET NULL,
    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 9. TABLA: Puntos de Venta (PDV)
CREATE TABLE IF NOT EXISTS "PDV" (
    "Id" VARCHAR(10) PRIMARY KEY,
    "Codigo" VARCHAR(20) NOT NULL UNIQUE,
    "Nombre" VARCHAR(200) NOT NULL,
    "Direccion" VARCHAR(300) NOT NULL,
    "Ciudad" VARCHAR(100) NOT NULL,
    "Zona" VARCHAR(100) NULL,
    "Responsable" VARCHAR(150) NULL,
    "Telefono" VARCHAR(20) NULL,
    "Latitud" NUMERIC(10, 7) NOT NULL,
    "Longitud" NUMERIC(10, 7) NOT NULL,
    "GeofenceMetros" INT NOT NULL DEFAULT 100,
    "Activo" BOOLEAN NOT NULL DEFAULT TRUE,
    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "CreatedBy" VARCHAR(100) NOT NULL DEFAULT '',
    "UpdatedBy" VARCHAR(100) NULL
);

-- 10. TABLA: Visitas
CREATE TABLE IF NOT EXISTS "Visitas" (
    "Id" VARCHAR(10) PRIMARY KEY,
    "PdvId" VARCHAR(10) NOT NULL REFERENCES "PDV"("Id") ON DELETE NO ACTION,
    "VisitadorId" VARCHAR(10) NOT NULL REFERENCES "Usuarios"("Id") ON DELETE NO ACTION,
    "Estado" INT NOT NULL, -- 1: EnCurso, 2: Completada, 3: Cancelada
    "LatitudInicio" NUMERIC(10, 7) NULL,
    "LongitudInicio" NUMERIC(10, 7) NULL,
    "LatitudFin" NUMERIC(10, 7) NULL,
    "LongitudFin" NUMERIC(10, 7) NULL,
    "TimestampInicio" TIMESTAMPTZ NOT NULL,
    "TimestampFin" TIMESTAMPTZ NULL,
    "ActaPdfUrl" TEXT NULL,
    "Sincronizado" BOOLEAN NOT NULL DEFAULT TRUE,
    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "CreatedBy" VARCHAR(100) NOT NULL DEFAULT '',
    "UpdatedBy" VARCHAR(100) NULL
);

-- 11. TABLA: AgendaVisitas
CREATE TABLE IF NOT EXISTS "AgendaVisitas" (
    "Id" VARCHAR(10) PRIMARY KEY,
    "PdvId" VARCHAR(10) NOT NULL REFERENCES "PDV"("Id") ON DELETE NO ACTION,
    "VisitadorId" VARCHAR(10) NOT NULL REFERENCES "Usuarios"("Id") ON DELETE NO ACTION,
    "FechaPlaneada" TIMESTAMPTZ NOT NULL,
    "Observaciones" VARCHAR(500) NULL,
    "Completada" BOOLEAN NOT NULL DEFAULT FALSE,
    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "CreatedBy" VARCHAR(100) NOT NULL DEFAULT '',
    "UpdatedBy" VARCHAR(100) NULL
);

-- 12. TABLA: Novedades
CREATE TABLE IF NOT EXISTS "Novedades" (
    "Id" VARCHAR(10) PRIMARY KEY,
    "VisitaId" VARCHAR(10) NOT NULL REFERENCES "Visitas"("Id") ON DELETE CASCADE,
    "PdvId" VARCHAR(10) NOT NULL REFERENCES "PDV"("Id") ON DELETE NO ACTION,
    "Titulo" VARCHAR(300) NOT NULL,
    "Descripcion" TEXT NOT NULL,
    "Categoria" VARCHAR(100) NOT NULL,
    "Prioridad" VARCHAR(50) NOT NULL,
    "Estado" INT NOT NULL DEFAULT 1, -- 1: Abierta, 2: EnProgreso, 3: Resuelta, etc.
    "ResponsableSolucionId" VARCHAR(10) NOT NULL,
    "ResponsableSeguimientoId" VARCHAR(10) NOT NULL,
    "FechaSeguimiento" TIMESTAMPTZ NOT NULL,
    "Sincronizado" BOOLEAN NOT NULL DEFAULT TRUE,
    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "CreatedBy" VARCHAR(100) NOT NULL DEFAULT '',
    "UpdatedBy" VARCHAR(100) NULL
);

-- 13. TABLA: NovedadHistorial
CREATE TABLE IF NOT EXISTS "NovedadHistorial" (
    "Id" VARCHAR(10) PRIMARY KEY,
    "NovedadId" VARCHAR(10) NOT NULL REFERENCES "Novedades"("Id") ON DELETE CASCADE,
    "EstadoAnterior" INT NOT NULL,
    "EstadoNuevo" INT NOT NULL,
    "Comentario" TEXT NOT NULL,
    "UsuarioId" VARCHAR(10) NOT NULL,
    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 14. TABLA: NovedadImagenes
CREATE TABLE IF NOT EXISTS "NovedadImagenes" (
    "Id" VARCHAR(10) PRIMARY KEY,
    "NovedadId" VARCHAR(10) NOT NULL REFERENCES "Novedades"("Id") ON DELETE CASCADE,
    "UrlImagen" TEXT NOT NULL,
    "NombreArchivo" VARCHAR(255) NOT NULL,
    "TamanoBytes" BIGINT NOT NULL,
    "MarcaAguaAplicada" BOOLEAN NOT NULL DEFAULT TRUE,
    "Latitud" NUMERIC(10, 7) NULL,
    "Longitud" NUMERIC(10, 7) NULL,
    "TimestampCaptura" TIMESTAMPTZ NULL,
    "SubidoPor" VARCHAR(10) NOT NULL,
    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 15. TABLA: Auditorias
CREATE TABLE IF NOT EXISTS "Auditorias" (
    "Id" VARCHAR(10) PRIMARY KEY,
    "UsuarioId" VARCHAR(10) NULL REFERENCES "Usuarios"("Id") ON DELETE SET NULL,
    "Accion" VARCHAR(100) NOT NULL,
    "Modulo" VARCHAR(100) NOT NULL,
    "EntidadAfectada" VARCHAR(100) NULL,
    "EntidadId" VARCHAR(100) NULL,
    "DetalleAnterior" TEXT NULL,
    "DetalleNuevo" TEXT NULL,
    "IpAddress" VARCHAR(45) NULL,
    "UserAgent" VARCHAR(500) NULL,
    "Exitoso" BOOLEAN NOT NULL DEFAULT TRUE,
    "MensajeError" VARCHAR(2000) NULL,
    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 16. DATOS INICIALES (SEEDS)
-- Roles
INSERT INTO "Roles" ("Id", "Activo", "CreatedAt", "Descripcion", "Nombre", "UpdatedAt")
VALUES 
('ROL-ADMINS', TRUE, CURRENT_TIMESTAMP, 'Administrador del sistema', 'Administrador', CURRENT_TIMESTAMP),
('ROL-SUPERV', TRUE, CURRENT_TIMESTAMP, 'Supervisor de zona', 'Supervisor', CURRENT_TIMESTAMP),
('ROL-VISITD', TRUE, CURRENT_TIMESTAMP, 'Visitador de puntos de venta', 'Visitador', CURRENT_TIMESTAMP)
ON CONFLICT ("Id") DO NOTHING;

-- Usuario Administrador Inicial (Admin@2024!)
INSERT INTO "Usuarios" (
    "Id", "Nombre", "Apellido", "Email", "Username",
    "PasswordHash", "Rol", "ZonaId", "SupervisorId", "Activo",
    "BiometriaHabilitada", "PushToken", "IntentosFallidos", "BloqueadoHasta",
    "UltimoLogin", "CreatedAt", "UpdatedAt", "CreatedBy", "UpdatedBy"
)
VALUES (
    'USR-ADMIN1', 'Administrador', 'Sistema', 'admin@visitapdv.com', 'admin',
    '$2a$12$Nq9v7bH6uQ5W2H6qQe8kxeW/6W6uQ5W2H6qQe8kxeW/6W6uQ5W2H6', -- Hash BCrypt de Admin@2024!
    'Administrador', 'ZONA-MAT', NULL, TRUE, FALSE, NULL, 0, NULL, NULL,
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'SYSTEM', NULL
)
ON CONFLICT ("Id") DO NOTHING;

-- Asignación de rol admin
INSERT INTO "UsuarioRoles" ("UsuarioId", "RolId")
VALUES ('USR-ADMIN1', 'ROL-ADMINS')
ON CONFLICT ("UsuarioId", "RolId") DO NOTHING;
