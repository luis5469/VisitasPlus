# 💻 Especificación Funcional y Técnica: APLICACIÓN WEB DE ADMINISTRACIÓN
**Proyecto:** VisitaPDV — Portal Administrativo y de Supervisión  
**Entorno de Destino:** Servidor Web / Aplicaciones en **Rocky Linux**  
**Propósito:** Especificación de requerimientos, componentes UI/UX y flujos de usuario para reescritura tecnológica.

---

## 1. Visión y Alcance del Portal Administrativo
El Portal Web de Administración es la herramienta centralizada para supervisores zonales y directores de operaciones de Farmaenlace. Permite coordinar las visitas a farmacias, monitorear la ejecución en campo en tiempo real, auditar novedades reportadas con soporte multimedia, interactuar con el módulo de IA y supervisar el cumplimiento de los estándares operativos y legales (LOPDP).

---

## 2. Perfiles de Usuario y Permisos en el Portal
1. **Administrador (`ROL-ADMINS`)**:
   - Control total sobre usuarios (creación, edición, activación, desbloqueo, reseteo de claves).
   - Parametrización de farmacias y configuración de geocercas (geofences).
   - Consulta de la bitácora de auditoría global del sistema.
   - Gestión y cierre definitivo de novedades.
   - Acceso al Dashboard ejecutivo completo y exportación de informes oficiales.
2. **Supervisor de Zona (`ROL-SUPERV`)**:
   - Asignación y planificación de agendas de visitas a visitadores de su zona.
   - Seguimiento de novedades en farmacias bajo su jurisdicción.
   - Aprobación de soluciones, solicitud de aclaración (*Pendiente de información*) y cambio de estados en novedades.
   - Visualización de fotos, videos y documentos de soporte adjuntados por los visitadores.
   - Análisis de novedades mediante IA para validar criticidad y categoría.
   - Visualización de métricas de cumplimiento de visitas de su equipo.

---

## 3. Módulos Funcionales y Pantallas

### 3.1 Módulo de Autenticación y Seguridad
- **Pantalla `/login`**:
  - Campos: Usuario/Email y Contraseña.
  - Validación en cliente y servidor con control contra ataques de fuerza bruta (bloqueo tras 5 intentos fallidos).
  - Almacenamiento seguro del token JWT y persistencia de sesión con Refresh Token.
  - Redirección automática según rol o al Dashboard principal.
  - Barra superior de navegación con indicador del usuario activo, rol actual y botón de cierre de sesión seguro.

---

### 3.2 Módulo Dashboard Ejecutivo (`/dashboard` o `/`)
- **Objetivo:** Proporcionar visibilidad inmediata del estado de la operación de visitas y novedades.
- **Componentes Visuales:**
  1. **Tarjetas de KPIs Principales:**
     - *Visitas Planeadas*: Total de visitas programadas en el periodo.
     - *Visitas Realizadas*: Visitas finalizadas con éxito con geocerca verificada.
     - *% de Cumplimiento*: Ratio de visitas ejecutadas vs planeadas.
     - *Tiempo Promedio de Visita*: Duración promedio en minutos por farmacia.
     - *Novedades Abiertas / En Proceso*: Casos activos requiriendo atención.
     - *Novedades Vencidas*: Indicador crítico en color rojo con alerta numérica.
  2. **Gráficos Analíticos:**
     - *Distribución por Categoría*: Gráfico de pastel o barras con incidencias por tipo (Inventario, Precios, Infraestructura, Limpieza, Exhibición, etc.).
     - *Eficiencia por Visitador*: Gráfico de barras comparando porcentaje de cumplimiento y horas en campo.
     - *Heatmap Horario*: Matriz visual que muestra las horas del día y días de la semana con mayor concentración de visitas.
     - *Panel de Alertas Críticas*: Lista de farmacias sin visitar en más de 30 días o incidencias de prioridad "Crítica".
  3. **Exportación de Informes:**
     - Filtros superiores por rango de fechas (Desde - Hasta).
     - Botón de descarga en formato **PDF** (informe ejecutivo formal para gerencia) y **Excel** (datos tabulares para análisis).

---

### 3.3 Módulo de Gestión de Farmacias / PDV (`/farmacias`)
- **Listado y Búsqueda:**
  - Tabla paginada de farmacias con columnas: Código, Nombre, Dirección, Ciudad, Zona, Responsable, Teléfono, Geofence (metros) y Estado (Activo/Inactivo).
  - Búsqueda reactiva por texto libre (filtro por código, nombre o ciudad).
- **Creación y Edición de Farmacias:**
  - Modal o pantalla con validación de campos obligatorios: Código único, Nombre comercial, Dirección física, Ciudad, Zona operativa, Responsable de tienda y Teléfono de contacto.
- **Componente de Mapa Interactivo (Geocodificación y Geocerca):**
  - Integración con mapas (Leaflet.js con OpenStreetMap o Google Maps JS API).
  - **Buscador de dirección (Geocoding)**: Permite ingresar una dirección o referencia urbana para centrar el mapa automáticamente.
  - **Captura por Clic**: Al hacer clic en cualquier punto del mapa, se actualizan automáticamente los inputs de Latitud y Longitud.
  - **Marcador Arrastrable (Draggable Marker)**: Permite ajuste fino arrastrando el pin hasta la puerta exacta del local.
  - **Visualización de la Geocerca**: Se dibuja un círculo dinámico sobre el mapa con el radio configurado en el campo `GeofenceMetros` (ej. 100 metros), permitiendo al supervisor verificar visualmente la zona válida para check-in.
- **Acciones Rápidas:**
  - Botón de edición de datos y geocerca.
  - Switch o botón para Activar / Desactivar la farmacia.

---

### 3.4 Módulo de Planificación y Asignación de Visitas (`/asignaciones`)
- **Objetivo:** Coordinar la agenda de visitas de los visitadores a los puntos de venta.
- **Componentes:**
  - **Formulario de Nueva Asignación:**
    - Selector desplegable de Usuario Visitador (filtrado por rol visitador y activo).
    - Selector desplegable de Farmacia (con visualización de código y nombre).
    - Selector de fecha planeada (`InputDate`).
    - Campo de observaciones o instrucciones previas para la visita.
    - Botón de confirmación y guardado.
  - **Tabla de Asignaciones:**
    - Columnas: Fecha programada, Visitador responsable, Farmacia asignada, Observaciones, Estado (Pendiente / Completada).
    - Filtros por rango de fechas y por visitador.
    - Botón de eliminación / cancelación para asignaciones pendientes que ya no se van a realizar.

---

### 3.5 Módulo de Seguimiento de Novedades / Incidencias (`/novedades`)
- **Cabecera y Contadores Rápidos:**
  - Badges interactivos superiores:
    - *Abiertas*: Incidencias pendientes de atención.
    - *En Progreso*: Casos en gestión por el responsable asignado.
    - *Pendiente de Información*: Casos que el supervisor devolvió al visitador por falta de datos.
    - *Vencidas*: Casos cuya fecha límite de seguimiento ya caducó (alerta visual destacada).
- **Barra de Filtros Multicriterio:**
  - Filtro por Estado (Abierta, En Progreso, Resuelta, Pendiente de Información, Cancelada, Vencida).
  - Filtro por Categoría y Prioridad (Baja, Media, Alta, Crítica).
  - Filtro por Farmacia y Responsable de Solución / Seguimiento.
  - Selector de rango de fechas de registro.
- **Tabla Maestra de Novedades:**
  - Filas interactivas con código de color (las novedades vencidas o críticas se destacan en rojo).
  - Datos visibles: Título, Código y Nombre de Farmacia, Categoría, Badge de Prioridad, Badge de Estado, Responsable y Fecha límite.
  - Paginación dinámica (Anterior / Siguiente, indicador de página actual).
- **Panel Lateral de Detalle de Novedad:**
  - Al seleccionar una fila se despliega el panel de control completo:
  1. **Información y Anonimización LOPDP:**
     - Visualización del título y descripción detallada de la novedad.
     - Los datos de identificación personal (nombres de terceros, teléfonos, correos y cédulas) se presentan anonimizados conforme a la LOPDP.
  2. **Asignación de Responsables y SLA:**
     - Modificación de: Responsable de Solución, Responsable de Seguimiento y Fecha Límite.
     - Botón de guardado de responsabilidades.
  3. **Asistente de Inteligencia Artificial (Gemini):**
     - Botón destacado: *"Analizar con IA"*.
     - El sistema envía la descripción al LLM y muestra una tarjeta con:
       - Categoría sugerida (ej. *Infraestructura*).
       - Nivel de criticidad recomendado (*Crítica* o *Alta*).
       - Título conciso sugerido.
       - Justificación técnica del impacto.
     - Botón *"Aplicar Sugerencia IA"* que actualiza automáticamente los campos de la novedad en la base de datos.
  4. **Galería Multimedia y Documental (Exclusiva de Visualización en Web):**
     - *Regla operativa*: La carga de archivos multimedia se realiza exclusivamente desde el terreno mediante la App Móvil. La web ofrece el visor y descarga.
     - **Fotos**: Muestra miniaturas de las fotografías con visualizador modal con zoom, fecha de captura y coordenadas GPS.
     - **Videos**: Reproductor HTML5 integrado para reproducir videos cortos tomados en la farmacia.
     - **Documentos de soporte**: Listado con íconos para previsualizar o descargar archivos PDF, Word o Excel adjuntados a la incidencia.
  5. **Línea de Tiempo (Timeline Histórico):**
     - Visualización cronológica de cada cambio de estado: Usuario que efectuó el cambio, fecha/hora exacta, estado previo, nuevo estado y comentario ingresado.
  6. **Flujo de Cambio de Estado:**
     - Selector del nuevo estado permitido según el flujo:
       - De `Abierta` $\rightarrow$ `En Progreso` | `Resuelta` | `Cancelada` | `Pendiente de Información`.
     - Campo de texto obligatorio para ingresar el comentario del supervisor (imprescindible para justificar resoluciones o detallar qué información falta cuando se pasa a *Pendiente de información*).
     - Botón de confirmación de transición.

---

### 3.6 Módulo de Gestión de Usuarios (`/usuarios`)
- **Listado y Filtros:**
  - Búsqueda de usuarios por nombre, apellido, username, email o zona.
  - Visualización del estado del usuario (Activo / Bloqueado / Inactivo) y contador de intentos fallidos.
- **Acciones Administrativas:**
  - **Crear Usuario**: Modal con campos Nombre, Apellido, Email único, Username único, Contraseña inicial, Rol (Admin, Supervisor, Visitador) y Zona.
  - **Editar Usuario**: Actualización de datos personales, zona y rol.
  - **Activar / Desactivar**: Switch para habilitar o deshabilitar acceso al sistema.
  - **Desbloquear Cuenta**: Botón para resetear a 0 los intentos fallidos si el usuario bloqueó su cuenta.
  - **Cambiar Contraseña**: Modal administrativo para resetear la contraseña del usuario.

---

### 3.7 Módulo de Auditoría del Sistema (`/auditoria`)
- Consulta de registros de auditoría inmutables:
  - Timestamp, Usuario que realizó la acción, Módulo, Tipo de Acción (Creación, Modificación, Cambio de Estado, Login), IP origen y resultado (Exitoso / Error).
  - Filtro por usuario o fechas para investigaciones de control interno.

---

## 4. Guía de Reescritura y Migración Web en Rocky Linux

Para el nuevo desarrollo web:
1. **Opciones de Framework Frontend Moderno**:
   - **React / Next.js** o **Vue.js 3 / Nuxt.js** o **Angular**: Tecnologías SPA/SSR líderes con soporte para componentes ricos, Leaflet, gráficos (Chart.js / ApexCharts) y carga asíncrona.
   - **Continuidad Blazor**: Si se opta por Blazor WebAssembly o Blazor Server sobre .NET 8 / 10 en Linux, funciona de manera nativa en Rocky Linux.
2. **Servicio Web en Rocky Linux**:
   - Compilación de assets estáticos (`npm run build` $\rightarrow$ carpeta `dist/`).
   - Servido directo por **Nginx** en Rocky Linux a velocidad máxima con compresión Gzip/Brotli y encabezados de seguridad HTTP (HSTS, CSP, X-Frame-Options).
   - El frontend consume la API REST a través del proxy reverso `/api` configurado en Nginx, eliminando problemas de CORS.

