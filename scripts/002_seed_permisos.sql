-- =============================================
-- Script: 002_seed_permisos.sql
-- Descripción: Permisos por módulo para VisitaPDV
-- =============================================

SET NOCOUNT ON;

DECLARE @permisos TABLE (
    Id       VARCHAR(10),
    Nombre   NVARCHAR(150),
    Modulo   NVARCHAR(100),
    Accion   NVARCHAR(100),
    Descripcion NVARCHAR(500),
    CreatedAt DATETIME2,
    UpdatedAt DATETIME2
);

INSERT INTO @permisos VALUES
    ('PER-VIS-V',  'Visitas.Ver',        'Visitas',    'Ver',        'Ver visitas propias',                        GETUTCDATE(), GETUTCDATE()),
    ('PER-VIS-C',  'Visitas.Crear',      'Visitas',    'Crear',      'Crear nuevas visitas',                       GETUTCDATE(), GETUTCDATE()),
    ('PER-VIS-E',  'Visitas.Editar',     'Visitas',    'Editar',     'Editar visitas pendientes',                  GETUTCDATE(), GETUTCDATE()),
    ('PER-VIS-D',  'Visitas.Eliminar',   'Visitas',    'Eliminar',   'Eliminar visitas',                           GETUTCDATE(), GETUTCDATE()),
    ('PER-VIS-VT', 'Visitas.VerTodas',   'Visitas',    'VerTodas',   'Ver todas las visitas de la zona',           GETUTCDATE(), GETUTCDATE()),
    ('PER-NOV-V',  'Novedades.Ver',      'Novedades',  'Ver',        'Ver novedades propias',                      GETUTCDATE(), GETUTCDATE()),
    ('PER-NOV-C',  'Novedades.Crear',    'Novedades',  'Crear',      'Registrar novedades',                        GETUTCDATE(), GETUTCDATE()),
    ('PER-NOV-A',  'Novedades.Aprobar',  'Novedades',  'Aprobar',    'Aprobar o rechazar novedades',               GETUTCDATE(), GETUTCDATE()),
    ('PER-USR-V',  'Usuarios.Ver',       'Usuarios',   'Ver',        'Ver lista de usuarios',                      GETUTCDATE(), GETUTCDATE()),
    ('PER-USR-C',  'Usuarios.Crear',     'Usuarios',   'Crear',      'Crear usuarios',                             GETUTCDATE(), GETUTCDATE()),
    ('PER-USR-E',  'Usuarios.Editar',    'Usuarios',   'Editar',     'Editar usuarios',                            GETUTCDATE(), GETUTCDATE()),
    ('PER-USR-D',  'Usuarios.Eliminar',  'Usuarios',   'Eliminar',   'Desactivar usuarios',                        GETUTCDATE(), GETUTCDATE()),
    ('PER-REP-V',  'Reportes.Ver',       'Reportes',   'Ver',        'Ver reportes de zona',                       GETUTCDATE(), GETUTCDATE()),
    ('PER-REP-EX', 'Reportes.Exportar',  'Reportes',   'Exportar',   'Exportar reportes',                          GETUTCDATE(), GETUTCDATE()),
    ('PER-ADM-CF', 'Admin.Config',       'Admin',      'Config',     'Configuración general del sistema',          GETUTCDATE(), GETUTCDATE());

INSERT INTO Permisos (Id, Nombre, Modulo, Accion, Descripcion, CreatedAt, UpdatedAt)
SELECT Id, Nombre, Modulo, Accion, Descripcion, CreatedAt, UpdatedAt
FROM @permisos p
WHERE NOT EXISTS (SELECT 1 FROM Permisos WHERE Nombre = p.Nombre);

PRINT '>> Permisos insertados.';
GO
