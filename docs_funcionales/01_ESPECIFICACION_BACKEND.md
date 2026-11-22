# 📄 Especificación Funcional y Técnica: BACKEND (API & Servicios)
**Proyecto:** VisitaPDV (Gestión de Visitas a Puntos de Venta y Novedades)  
**Entorno de Destino:** Servidor de Aplicaciones sobre **Rocky Linux** (Compatible RHEL)  
**Propósito:** Especificación integral para reimplementación tecnológica.

---

## 1. Visión General del Backend
El Backend actúa como el núcleo centralizado de reglas de negocio, persistencia de datos, seguridad, integraciones externas (IA, notificaciones, almacenamiento multimedia) y procesamiento de eventos tanto para la aplicación web administrativa como para los dispositivos móviles de los visitadores en campo.

---

## 2. Modelo de Dominio y Base de Datos

### 2.1 Entidades Principales
1. **Usuarios (`Usuarios`)**:
   - `Id`: Identificador único (alfanumérico `USR-XXXX` o UUID).
   - `Nombre`, `Apellido`, `Email`, `Username`: Datos de identidad.
   - `PasswordHash`: Hash seguro de contraseña (originalmente BCrypt costo 12).
   - `Rol`: Denormalizado o relacionado para acceso rápido (Administrador, Supervisor, Visitador).
   - `ZonaId` / `Zona`: Zona geográfica asignada.
   - `SupervisorId`: Relación jerárquica con su supervisor directo.
   - `Activo`: Bandera de habilitación lógica.
   - `BiometriaHabilitada`: Permite autenticación biométrica en app móvil.
   - `PushToken`: Token de mensajería push (FCM).
   - `IntentosFallidos`: Contador de intentos erróneos de contraseña.
   - `BloqueadoHasta`: Fecha/hora de bloqueo temporal por fuerza bruta.
   - `UltimoLogin`: Timestamp del último acceso exitoso.
   - Auditoría: `CreatedAt`, `UpdatedAt`, `CreatedBy`, `UpdatedBy`.

2. **Roles y Permisos (`Roles`, `Permisos`, `RolPermisos`, `UsuarioRoles`)**:
   - Soporte para RBAC (Role-Based Access Control).
   - Roles base:
     - `ROL-ADMINS` (*Administrador*): Acceso total a usuarios, catálogos, configuraciones, auditoría y reportes.
     - `ROL-SUPERV` (*Supervisor*): Gestión de agendas, aprobación/cambio de estados de novedades, supervisión de visitas de su zona.
     - `ROL-VISITD` (*Visitador*): Uso móvil para realizar visitas, check-in/check-out geolocalizado y registro de novedades.

3. **Puntos de Venta (`PDV`)**:
   - `Id`: Identificador único (ej. `PDV-XXXX` o UUID).
   - `Codigo`: Código único de la farmacia (ej. `FAR-001`).
   - `Nombre`: Nombre comercial o razón social.
   - `Direccion`: Dirección física de la farmacia.
   - `Ciudad`: Ciudad o cantón (Quito, Guayaquil, etc.).
   - `Zona`: Región o zona operativa (Norte, Sur, Centro, Costa, Sierra).
   - `Responsable`: Nombre del administrador/químico de la farmacia.
   - `Telefono`: Contacto del PDV.
   - `Latitud`, `Longitud`: Coordenadas GPS en alta precisión (decimal 10,7).
   - `GeofenceMetros`: Radio de tolerancia en metros para permitir check-in/out (por defecto 100m, min 10m, max 5000m).
   - `Activo`: Estado de operación.

4. **Agenda de Visitas (`AgendaVisitas`)**:
   - `Id`: Identificador.
   - `PdvId`: Farmacia a visitar.
   - `VisitadorId`: Usuario asignado.
   - `FechaPlaneada`: Fecha/hora programada.
   - `Observaciones`: Instrucciones previas para el visitador.
   - `Completada`: Bandera que marca si la visita ya fue efectuada.

5. **Visitas (`Visitas`)**:
   - `Id`: Identificador único de la visita.
   - `PdvId`: Farmacia visitada.
   - `VisitadorId`: Visitador que ejecutó la visita.
   - `Estado`: Enum (`1: EnCurso`, `2: Completada`, `3: Cancelada`).
   - `LatitudInicio`, `LongitudInicio`: Coordenadas GPS del check-in.
   - `TimestampInicio`: Fecha/hora de inicio.
   - `LatitudFin`, `LongitudFin`: Coordenadas GPS del check-out.
   - `TimestampFin`: Fecha/hora de finalización.
   - `ActaPdfUrl`: URL del comprobante o reporte de visita generado.
   - `Sincronizado`: Bandera de sincronización para operaciones originadas offline.

6. **Novedades (`Novedades`)**:
   - `Id`: Identificador de la incidencia (`NOV-XXXX` o UUID).
   - `VisitaId`: Visita durante la cual se identificó la novedad.
   - `PdvId`: Farmacia donde ocurrió.
   - `Titulo`: Resumen corto (generado manual o sugerido por IA).
   - `Descripcion`: Detalle del problema (anonimizado según LOPDP).
   - `Categoria`: Categoría temática (Inventario, Limpieza, Exhibición, Precio, Equipamiento, Infraestructura, Talento Humano, etc.).
   - `Prioridad`: Nivel de criticidad (`Baja`, `Media`, `Alta`, `Crítica`).
   - `Estado`: Enum de ciclo de vida:
     - `1: Abierta`
     - `2: EnProgreso`
     - `3: Resuelta`
     - `4: Cerrada` (estado terminal)
     - `5: Reabierta`
     - `6: Vencida` (calculado si excede la fecha de seguimiento sin resolverse)
     - `7: Cancelada`
     - `8: PendienteInformacion` (cuando supervisor requiere aclaración del visitador)
   - `ResponsableSolucionId`: Usuario encargado de corregir la falla.
   - `ResponsableSeguimientoId`: Supervisor encargado de verificar la solución.
   - `FechaSeguimiento`: Fecha límite de atención / SLA.
   - `Sincronizado`: Bandera de sincronización offline.

7. **Historial de Novedad (`NovedadHistorial`)**:
   - Registro de auditoría por cada cambio de estado:
     - `NovedadId`, `EstadoAnterior`, `EstadoNuevo`, `UsuarioId`, `Comentario`, `CreatedAt`.

8. **Archivos / Multimedia de Novedades (`NovedadImagenes`)**:
   - `Id`: Identificador del adjunto.
   - `NovedadId`: Novedad asociada.
   - `UrlImagen`: Ruta física o URL pública/firmada del archivo.
   - `NombreArchivo`: Nombre original o UUID generado.
   - `TamanoBytes`: Peso del archivo.
   - `MarcaAguaAplicada`: Indica si la foto contiene watermark (usuario, GPS, fecha/hora).
   - `Latitud`, `Longitud`: Ubicación de la captura.
   - `TimestampCaptura`: Momento exacto de toma multimedia.
   - `SubidoPor`: Usuario que cargó el archivo.

9. **Dispositivos y Tokens (`Dispositivos`, `RefreshTokens`)**:
   - Registro de dispositivos móviles para control de acceso, huella digital y push notifications.
   - Manejo de Refresh Tokens revocables con expiración y rotación.

10. **Auditoría Transaccional (`Auditorias`)**:
    - Bitácora de operaciones sensibles (cambio de contraseñas, activación/desactivación de usuarios/farmacias, asignaciones).

---

## 3. Lógica de Negocio y Algoritmos Clave

### 3.1 Algoritmo de Geofencing (Fórmula de Haversine)
- Al momento de realizar **Check-In (`IniciarVisita`)** o **Check-Out (`FinalizarVisita`)**:
  - Se obtienen las coordenadas del dispositivo ($lat_{GPS}, lon_{GPS}$).
  - Se comparan contra las coordenadas del PDV ($lat_{PDV}, lon_{PDV}$).
  - Fórmula:
    $$d = 2 \cdot R \cdot \arcsin\left(\sqrt{\sin^2\left(\frac{\Delta lat}{2}\right) + \cos(lat_1)\cos(lat_2)\sin^2\left(\frac{\Delta lon}{2}\right)}\right)$$
    donde $R = 6371000\text{ m}$.
  - Condición de éxito: $d \le \text{GeofenceMetros}$ (por defecto 100 metros).
  - Regla: Un visitador no puede iniciar una visita si ya tiene otra en estado `EnCurso`.

### 3.2 Protocolo de Anonimización Dual LOPDP Ecuador
Para cumplir con la Ley Orgánica de Protección de Datos Personales de Ecuador:
- **Capa 1: Reglas Deterministas Locales (Regex y Algoritmos)**:
  - **Email**: Expresión regular RFC 5322 $\rightarrow$ `[EMAIL_ANONIMIZADO]`.
  - **Teléfonos**: Fijos locales y celulares de Ecuador (`\b(?:\+?593|0)(9\d{8}|[2-7]\d{7})\b`) $\rightarrow$ `[TELEFONO_ANONIMIZADO]`.
  - **Cédula de Identidad Ecuatoriana**:
    - Detección de patrones de 10 dígitos.
    - Validación del dígito verificador mediante **Algoritmo Módulo 10**:
      - Provincias válidas: `01` a `24`, o `30`.
      - Tercer dígito menor a `6` para personas naturales.
      - Coeficientes: `[2, 1, 2, 1, 2, 1, 2, 1, 2]`. Multiplicación, resta de 9 si producto $\ge 10$, suma total y residuo respecto a decena superior.
      - Si es válida $\rightarrow$ `[CEDULA_ANONIMIZADA]`.
- **Capa 2: Análisis Semántico con IA (LLM / NLP)**:
  - Detección contextual de nombres de clientes o empleados, direcciones domiciliarias privadas o datos de salud sensibles.
  - Reemplazo por etiquetas normalizadas (`[NOMBRE_ANONIMIZADO]`, `[DIRECCION_ANONIMIZADA]`).
  - Modo Resiliente: Si el servicio LLM no responde o no está disponible, el sistema preserva el resultado de la Capa 1 (fallback transparente).

### 3.3 Motor de IA para Categorización y Criticidad de Novedades
- Entrada: Descripción de la novedad en lenguaje natural (ej. *"El techo sobre la percha de analgésicos tiene una gotera activa que moja cajas de producto y cables eléctricos"*).
- Procesamiento: Prompt de sistema instruyendo al modelo a devolver JSON estructurado con:
  - `categoria`: Categoría sugerida estándar o nueva de 1 a 2 palabras.
  - `prioridad`: Enum `Baja | Media | Alta | Crítica`.
  - `tituloSugerido`: Frase corta y ejecutiva.
  - `justificacion`: Explicación concisa en español del impacto operativo y nivel de riesgo.

### 3.4 Flujo de Estados de Novedades
- `Abierta` $\rightarrow$ `EnProgreso` $\rightarrow$ `Resuelta` $\rightarrow$ `Cerrada`
- Si la descripción no es clara para el supervisor: `Abierta` $\rightarrow$ `PendienteInformacion` (requiere comentario obligatorio solicitando información al visitador).
- Si la fecha actual $> FechaSeguimiento$ y no está resuelta: El sistema la etiqueta como `Vencida`.
- Cada transición crea inmutablemente un registro en `NovedadHistorial`.

### 3.5 Almacenamiento y Optimización de Archivos Multimedia
- Soporte para subida de fotos (JPG, PNG), videos cortos (MP4, max 3 min) y documentos (PDF, XLSX, DOCX).
- Redimensionamiento y compresión automática de imágenes (máximo ancho 1920px, calidad JPEG 80%).
- Entrega de archivos: En entornos de nube mediante URLs prefirmadas (SAS / S3 presigned URLs); en Rocky Linux mediante servicio de archivos estáticos autenticado o servidor de objetos compatible (MinIO / Nginx X-Accel-Redirect).

---

## 4. Catálogo Completo de Endpoints REST

### 4.1 Autenticación y Perfil (`/api/auth`)
| Método | Endpoint | Descripción | Requiere Auth |
|---|---|---|:---:|
| `POST` | `/api/auth/login` | Inicia sesión con Username/Email + Password. Retorna Access Token JWT + Refresh Token. | No |
| `POST` | `/api/auth/refresh` | Renueva Access Token utilizando un Refresh Token válido y no revocado. | No |
| `POST` | `/api/auth/logout` | Revoca el Refresh Token actual e invalida la sesión. | Sí |
| `GET` | `/api/auth/me` | Obtiene los datos del usuario en sesión, roles y permisos asociados. | Sí |

### 4.2 Administración y Usuarios (`/api/admin`)
| Método | Endpoint | Descripción | Requiere Rol |
|---|---|---|:---:|
| `GET` | `/api/admin/usuarios` | Lista paginada y filtrable de usuarios (búsqueda por nombre, email, rol, zona). | Admin / Sup |
| `POST` | `/api/admin/usuarios` | Crea un nuevo usuario con validación de unicidad de username/email y rol. | Admin |
| `PUT` | `/api/admin/usuarios/{id}` | Actualiza datos del usuario (nombre, apellido, email, rol, zona, supervisor). | Admin |
| `HttpPatch` | `/api/admin/usuarios/{id}/activo` | Activa o desactiva lógicamente un usuario. | Admin |
| `POST` | `/api/admin/usuarios/{id}/reset-intentos` | Resetea contador de intentos fallidos y desbloquea cuenta. | Admin |
| `PUT` | `/api/admin/usuarios/{id}/password` | Cambio administrativo de contraseña (con hash BCrypt/Argon2). | Admin |
| `GET` | `/api/admin/farmacias` | Lista general de farmacias / PDV con coordenadas y estado. | Admin / Sup |
| `POST` | `/api/admin/farmacias` | Registra nueva farmacia con geolocalización y geofence en metros. | Admin |
| `PUT` | `/api/admin/farmacias/{id}` | Modifica datos o coordenadas de una farmacia existente. | Admin |
| `HttpPatch` | `/api/admin/farmacias/{id}/activo` | Activa o desactiva un PDV. | Admin |
| `GET` | `/api/admin/asignaciones` | Lista de agendas planificadas filtradas por fecha o visitador. | Admin / Sup |
| `POST` | `/api/admin/asignaciones` | Crea una nueva asignación de visita para un visitador y fecha dada. | Admin / Sup |
| `DELETE` | `/api/admin/asignaciones/{id}` | Elimina o cancela una asignación de visita programada. | Admin / Sup |
| `GET` | `/api/admin/roles` | Lista el catálogo de roles del sistema. | Admin |
| `GET` | `/api/admin/permisos` | Lista todos los permisos granulares del sistema. | Admin |
| `GET` | `/api/admin/auditoria` | Consulta la bitácora de auditoría del sistema con filtros de fecha y acción. | Admin |

### 4.3 Puntos de Venta para Operación (`/api/pdv`)
| Método | Endpoint | Descripción | Requiere Auth |
|---|---|---|:---:|
| `GET` | `/api/pdv` | Obtiene lista de farmacias activas disponibles para el usuario o su zona. | Sí |
| `GET` | `/api/pdv/{id}` | Obtiene el detalle completo de un PDV. | Sí |

### 4.4 Visitas (`/api/visitas`)
| Método | Endpoint | Descripción | Requiere Auth |
|---|---|---|:---:|
| `GET` | `/api/visitas` | Retorna el historial de visitas realizadas por el usuario logueado. | Sí |
| `POST` | `/api/visitas/iniciar` | Inicia visita validando geofence y verificando que no haya visita activa. | Sí |
| `POST` | `/api/visitas/finalizar` | Finaliza la visita en curso validando geofence de salida y calculando duración. | Sí |

### 4.5 Novedades (`/api/novedades`)
| Método | Endpoint | Descripción | Requiere Auth |
|---|---|---|:---:|
| `GET` | `/api/novedades` | Listado paginado con filtros (estado, categoría, prioridad, PDV, responsable, fechas). | Sí |
| `GET` | `/api/novedades/{id}` | Detalle de novedad con galería de archivos e historial de estados. | Sí |
| `GET` | `/api/novedades/visita/{visitaId}` | Obtiene las novedades registradas durante una visita específica. | Sí |
| `GET` | `/api/novedades/pdv/{pdvId}` | Obtiene el historial de novedades de una farmacia. | Sí |
| `GET` | `/api/novedades/mis-novedades` | Novedades asignadas al usuario actual (para solución o seguimiento). | Sí |
| `GET` | `/api/novedades/vencidas` | Novedades cuya fecha límite ha expirado sin ser resueltas. | Sí |
| `POST` | `/api/novedades` | Crea una nueva novedad (asociada a una visita y PDV). | Sí |
| `POST` | `/api/novedades/analizar-ia` | Envía texto libre a Gemini para obtener categoría, prioridad y título sugerido. | Sí |
| `PUT` | `/api/novedades/{id}` | Actualiza datos generales o reasigna responsables de una novedad. | Sí |
| `HttpPatch` | `/api/novedades/{id}/estado` | Cambia de estado (con comentario obligatorio e inserción en historial). | Sí |
| `DELETE` | `/api/novedades/{id}` | Elimina lógicamente una novedad (solo administradores). | Admin |
| `POST` | `/api/novedades/{id}/imagenes` | Sube archivo multimedia (foto con watermark/video/documento) a la novedad. | Sí |
| `GET` | `/api/novedades/{id}/imagenes/{imagenId}/sas` | Genera enlace temporal de acceso al archivo multimedia. | Sí |
| `DELETE` | `/api/novedades/{id}/imagenes/{imagenId}` | Elimina un archivo adjunto. | Sí |

### 4.6 Seguridad y Anonimización LOPDP (`/api/seguridad`)
| Método | Endpoint | Descripción | Requiere Auth |
|---|---|---|:---:|
| `POST` | `/api/seguridad/anonymize` | Anonimiza un texto arbitrario ejecutando Capa 1 (Regex/Módulo 10) + Capa 2 (Gemini). | Sí |

### 4.7 Dashboard Analítico (`/api/dashboard`)
| Método | Endpoint | Descripción | Requiere Auth |
|---|---|---|:---:|
| `GET` | `/api/dashboard` | Resumen de métricas: KPIs de cumplimiento, incidencias por categoría, heatmap horario, alertas. | Sí |
| `GET` | `/api/dashboard/exportar` | Descarga el reporte consolidado del dashboard en formato PDF o Excel. | Sí |

---

## 5. Arquitectura para Despliegue en Rocky Linux

Para migrar exitosamente a un servidor de aplicaciones con **Rocky Linux 9**:

1. **Opciones Tecnológicas Recomendadas para la Reescritura**:
   - **Opción A (Continuidad C# .NET 8 / 10 LTS)**: Se compila con `dotnet publish -c Release -r linux-x64 --self-contained` o se ejecuta con el runtime .NET de Rocky Linux (`dnf install dotnet-sdk-8.0`).
   - **Opción B (Python / FastAPI o Django Ninja)**: Excelente soporte nativo para librerías de IA, validación Pydantic, async I/O y ejecución bajo Gunicorn / Uvicorn con `systemd`.
   - **Opción C (Node.js / NestJS o TypeScript Express)**: Alto rendimiento I/O, arquitectura modular similar a Clean Architecture, ejecutado con PM2 o contenedores.
   - **Opción D (Go / Gin o Fiber)**: Máximo rendimiento, binario único autocontenido, mínimo consumo de memoria RAM y CPU en Rocky Linux.

2. **Base de Datos en Linux**:
   - **PostgreSQL 16+ con extensión PostGIS**: Ideal para reemplazar SQL Server, aportando soporte geográfico nativo de alto rendimiento para geofences e indexación espacial `GIST`.
   - O bien **SQL Server on Linux**: Microsoft provee paquetes oficiales `.rpm` para RHEL / Rocky Linux 9.

3. **Almacenamiento de Archivos Multimedia**:
   - Sustituir Azure Blob Storage directo por **MinIO** (S3 compatible autohospedado en Rocky Linux) o almacenamiento en volumen local protegido servido vía **Nginx reverse proxy** con autenticación JWT o tokens temporales.

4. **Infraestructura en Rocky Linux**:
   - Gestor de procesos: `systemd` para servicios nativos o **Podman / Docker Compose** para despliegue inmutable.
   - Reverse Proxy: **Nginx** o **Caddy** gestionando terminación SSL (Let's Encrypt), compresión gzip/brotli y limitación de tasa (rate limiting).
   - Firewall: `firewalld` abriendo únicamente puertos `80/tcp` y `443/tcp`.
   - Seguridad: Configuración de políticas de **SELinux** (`httpd_can_network_connect = 1`).

