-- Semilla de datos de demostración para VisitaPDV (PostgreSQL)

-- 1. Insertar Puntos de Venta (PDVs)
INSERT INTO "PDV" ("Id", "Codigo", "Nombre", "Direccion", "Ciudad", "Provincia", "Zona", "Canal", "Latitud", "Longitud", "RadioMetros", "Activo", "CreatedAt", "UpdatedAt", "CreatedBy")
VALUES
    ('PDV-001', 'PDV-UIO-01', 'Farmacia Central Norte', 'Av. Amazonas y Naciones Unidas', 'Quito', 'Pichincha', 'Norte', 'Farmacias', -0.1785, -78.4855, 120, TRUE, NOW() - INTERVAL '10 days', NOW(), 'admin'),
    ('PDV-002', 'PDV-UIO-02', 'Farmacia San Francisco', 'Av. 10 de Agosto y Colón', 'Quito', 'Pichincha', 'Centro-Norte', 'Farmacias', -0.2015, -78.4912, 100, TRUE, NOW() - INTERVAL '10 days', NOW(), 'admin'),
    ('PDV-003', 'PDV-GYE-01', 'Punto Malecón', 'Malecón Simón Bolívar y 9 de Octubre', 'Guayaquil', 'Guayas', 'Centro', 'Supermercados', -2.1934, -79.8801, 150, TRUE, NOW() - INTERVAL '10 days', NOW(), 'admin'),
    ('PDV-004', 'PDV-CUE-01', 'Sucursal El Vado', 'Calle Larga y Huayna Cápac', 'Cuenca', 'Azuay', 'Sur', 'Distribuidor', -2.9001, -79.0055, 100, TRUE, NOW() - INTERVAL '10 days', NOW(), 'admin')
ON CONFLICT ("Id") DO NOTHING;

-- 2. Insertar Visitas de Ejemplo
INSERT INTO "Visitas" ("Id", "PdvId", "UsuarioId", "DispositivoId", "Estado", "TimestampInicio", "TimestampFin", "LatitudInicio", "LongitudInicio", "LatitudFin", "LongitudFin", "DistanciaMetrosInicio", "DistanciaMetrosFin", "Observaciones", "CreatedAt", "UpdatedAt", "CreatedBy")
VALUES
    ('VIS-001', 'PDV-001', 'USR-ADMIN1', NULL, 3, NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days' + INTERVAL '45 minutes', -0.1784, -78.4854, -0.1784, -78.4854, 15, 15, 'Visita completada sin anomalías físicas', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days', 'admin'),
    ('VIS-002', 'PDV-002', 'USR-ADMIN1', NULL, 3, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days' + INTERVAL '30 minutes', -0.2016, -78.4913, -0.2016, -78.4913, 20, 20, 'Se detectó rotura de stock en analgésicos', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days', 'admin'),
    ('VIS-003', 'PDV-003', 'USR-ADMIN1', NULL, 3, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day' + INTERVAL '50 minutes', -2.1935, -79.8802, -2.1935, -79.8802, 25, 25, 'Revisión de material POP en exhibidores', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', 'admin')
ON CONFLICT ("Id") DO NOTHING;

-- 3. Insertar Novedades de Ejemplo
INSERT INTO "Novedades" ("Id", "VisitaId", "PdvId", "Titulo", "Descripcion", "Categoria", "Prioridad", "Estado", "ResponsableSolucionId", "ResponsableSeguimientoId", "FechaSeguimiento", "Sincronizado", "CreatedAt", "UpdatedAt", "CreatedBy")
VALUES
    ('NOV-001', 'VIS-002', 'PDV-002', 'Quiebre de stock en analgésicos', 'No se dispone de Paracetamol 500mg en estantería principal.', 'Abastecimiento', 'Alta', 1, 'USR-ADMIN1', 'USR-ADMIN1', NOW() + INTERVAL '2 days', TRUE, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days', 'admin'),
    ('NOV-002', 'VIS-003', 'PDV-003', 'Material POP deteriorado', 'El banner promocional de entrada está roto por lluvia.', 'Marketing', 'Media', 3, 'USR-ADMIN1', 'USR-ADMIN1', NOW() + INTERVAL '5 days', TRUE, NOW() - INTERVAL '1 day', NOW(), 'admin')
ON CONFLICT ("Id") DO NOTHING;
