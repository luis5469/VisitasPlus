INSERT INTO "PDV" ("Id", "Codigo", "Nombre", "Direccion", "Ciudad", "Zona", "Responsable", "Telefono", "Latitud", "Longitud", "GeofenceMetros", "Activo")
VALUES 
('PDV-000001', 'FAR-001', 'Farmaenlace Matriz', 'Av. De la Prensa N45-12', 'Quito', 'Norte', 'Ana López', '022345678', -0.180653, -78.489123, 100, TRUE),
('PDV-000002', 'FAR-002', 'Farmacia Principal Centro', 'Guayaquil y Chile', 'Quito', 'Centro', 'Carlos Andrade', '022987654', -0.224123, -78.512345, 100, TRUE),
('PDV-000003', 'FAR-003', 'Farmacia Farmaenlace Sur', 'Av. Maldonado y Quitumbe', 'Quito', 'Sur', 'María Belén', '022765432', -0.301234, -78.543210, 150, TRUE)
ON CONFLICT ("Id") DO NOTHING;
