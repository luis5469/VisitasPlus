-- =============================================
-- Script: 003_seed_admin_user.sql
-- Descripción: Usuario administrador inicial
-- Password: Admin@2024! (BCrypt WorkFactor=12)
-- IMPORTANTE: Cambiar password en producción
-- =============================================

SET NOCOUNT ON;

DECLARE @adminId   VARCHAR(10) = 'USR-ADMINS';
DECLARE @adminRolId VARCHAR(10) = 'ROL-ADMINS'; -- Administrador

-- Password hash de "Admin@2024!" con BCrypt WorkFactor=12
DECLARE @passwordHash NVARCHAR(MAX) = '$2a$12$0Ew0hvGxEUHPfOePqGbU.uqcsLc0Snqq3n9aDQ8xtrT5/X6SgO8pi';

IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE Id = @adminId)
BEGIN
    INSERT INTO Usuarios 
        (Id, Nombre, Apellido, Email, Username, PasswordHash, Rol, Activo, 
         BiometriaHabilitada, IntentosFallidos, CreatedAt, UpdatedAt, CreatedBy)
    VALUES
        (@adminId, 'Administrador', 'Sistema', 'admin@visitapdv.com', 'admin',
         @passwordHash, 'Administrador', 1, 0, 0, GETUTCDATE(), GETUTCDATE(), 'system');

    PRINT '>> Usuario admin creado: admin@visitapdv.com / Admin@2024!';
END
ELSE
    PRINT '>> Usuario admin ya existe.';

-- Asignar rol Administrador
IF NOT EXISTS (SELECT 1 FROM UsuarioRoles WHERE UsuarioId = @adminId AND RolId = @adminRolId)
BEGIN
    INSERT INTO UsuarioRoles (UsuarioId, RolId) VALUES (@adminId, @adminRolId);
    PRINT '>> Rol Administrador asignado al usuario admin.';
END
GO

-- Asignar TODOS los permisos al rol Administrador
INSERT INTO RolPermisos (RolId, PermisoId)
SELECT 'ROL-ADMINS', Id
FROM Permisos
WHERE NOT EXISTS (
    SELECT 1 FROM RolPermisos rp
    WHERE rp.RolId  = 'ROL-ADMINS'
      AND rp.PermisoId = Permisos.Id
);

PRINT '>> Permisos asignados al rol Administrador.';
GO
