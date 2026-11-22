USE [visitapdv];
GO

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
GO

-- Seed test PDVs
IF NOT EXISTS (SELECT 1 FROM [dbo].[PDV] WHERE [Id] = 'PDV-000001')
BEGIN
    INSERT INTO [dbo].[PDV] ([Id], [Codigo], [Nombre], [Direccion], [Ciudad], [Zona], [Responsable], [Telefono], [Latitud], [Longitud], [GeofenceMetros], [Activo])
    VALUES ('PDV-000001', 'PDV-000001', 'Farmaenlace Matriz', 'Av. De la Prensa N45-12', 'Quito', 'Norte', 'Ana López', '022345678', -0.180653, -78.489123, 100, 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[PDV] WHERE [Id] = 'PDV-0000')
BEGIN
    INSERT INTO [dbo].[PDV] ([Id], [Codigo], [Nombre], [Direccion], [Ciudad], [Zona], [Responsable], [Telefono], [Latitud], [Longitud], [GeofenceMetros], [Activo])
    VALUES ('PDV-0000', 'PDV-0000', 'Farmacia Principal Centro', 'Guayaquil y Chile', 'Quito', 'Centro', 'Carlos Andrade', '022987654', -0.224123, -78.512345, 100, 1);
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[PDV] WHERE [Id] = 'PDV-000002')
BEGIN
    INSERT INTO [dbo].[PDV] ([Id], [Codigo], [Nombre], [Direccion], [Ciudad], [Zona], [Responsable], [Telefono], [Latitud], [Longitud], [GeofenceMetros], [Activo])
    VALUES ('PDV-000002', 'PDV-000002', 'Farmacia Farmaenlace Sur', 'Av. Maldonado y Quitumbe', 'Quito', 'Sur', 'María Belén', '022765432', -0.301234, -78.543210, 150, 1);
END;

COMMIT;
GO
