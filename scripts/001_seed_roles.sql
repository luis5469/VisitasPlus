-- =============================================
-- Script: 001_seed_roles.sql
-- Descripción: Roles base del sistema VisitaPDV
-- =============================================

SET NOCOUNT ON;

IF NOT EXISTS (SELECT 1 FROM Roles WHERE Id = 'ROL-VISITD')
BEGIN
    INSERT INTO Roles (Id, Nombre, Descripcion, Activo, CreatedAt, UpdatedAt)
    VALUES
        ('ROL-VISITD', 'Visitador',     'Visitador de puntos de venta', 1, GETUTCDATE(), GETUTCDATE()),
        ('ROL-SUPERV', 'Supervisor',    'Supervisor de zona',           1, GETUTCDATE(), GETUTCDATE()),
        ('ROL-ADMINS', 'Administrador', 'Administrador del sistema',    1, GETUTCDATE(), GETUTCDATE());

    PRINT '>> Roles insertados correctamente.';
END
ELSE
    PRINT '>> Roles ya existen, se omite inserción.';
GO
