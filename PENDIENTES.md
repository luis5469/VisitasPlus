# 📋 VisitaPDV Admin — Análisis de Pendientes
**Fecha de revisión:** 2026-06-18  
**Analista:** Sistema  
**Versión del sistema:** 1.0.0

---

## Estado General del Sistema

| Capa | Tecnología | Estado |
|------|-----------|--------|
| Backend API | .NET 10 / Clean Architecture | ✅ Operativo |
| Sitio Admin | Blazor Server / .NET 10 | ✅ Operativo |
| App Móvil | Flutter 3.19+ | 🔧 En desarrollo |
| Base de Datos | SQL Server (SQLDIGITALEXPRES) | ⚠️ Esquema incompleto |

---

## 🔴 Módulo 1 — Gestión de Usuarios

### Estado actual
- ✅ Listado de usuarios con filtro de búsqueda
- ✅ Activar / Desactivar usuario
- ✅ Resetear intentos fallidos de login

### Pendientes

#### 1.1 Crear Usuario (Alta prioridad)
**Problema:** La pantalla `/usuarios` no tiene formulario de creación. Solo existe la opción de activar/desactivar.  
**Solución requerida:**
- [x] Formulario modal o panel lateral con campos: Nombre, Apellido, Email, Username, Contraseña, Rol, Zona
- [x] Endpoint en `AdminController` → `POST /api/admin/usuarios`
- [x] Validaciones: username único, email único, contraseña con política de seguridad
- [ ] Flexibilizar política de contraseña: quitar la obligatoriedad de letra mayúscula al crear o cambiar contraseña (backend y frontend)
- [x] Hash de contraseña con BCrypt (WorkFactor=12) al crear

#### 1.2 Editar Usuario (Alta prioridad)
**Problema:** No existe opción de edición de datos del usuario (nombre, apellido, email, rol).  
**Solución requerida:**
- [x] Botón "Editar" en cada fila de la tabla
- [x] Formulario de edición (sin contraseña obligatoria)
- [x] Endpoint `PUT /api/admin/usuarios/{id}`
- [x] Opción separada "Cambiar contraseña"

#### 1.3 Carga Masiva de Usuarios (Media prioridad)
**Problema:** No hay mecanismo para importar usuarios en bulk (ej. al onboarding de visitadores).  
**Solución requerida:**
- [ ] Botón "Importar CSV/Excel" en la pantalla de usuarios
- [ ] Plantilla descargable con columnas: Nombre, Apellido, Email, Username, Rol, Zona
- [ ] Validación fila por fila con reporte de errores
- [ ] Endpoint `POST /api/admin/usuarios/importar`
- [ ] Vista previa antes de confirmar la importación

**Formato sugerido del CSV:**
```
Nombre,Apellido,Email,Username,Rol,Zona
Juan,Pérez,jperez@farmaenlace.com,jperez,Visitador,Norte
```

---

## 🔴 Módulo 2 — Gestión de Farmacias (PDV)

### Estado actual
- ✅ Listado de farmacias
- ✅ Crear farmacia (formulario manual)
- ✅ Editar farmacia
- ✅ Activar / Desactivar farmacia
- ⚠️ Tablas `PDV` y `AgendaVisitas` faltaban → **ejecutar script `004_create_missing_pdv_agenda.sql`**

### Pendientes

#### 2.1 Selector de Mapa para Latitud/Longitud (Alta prioridad)
**Problema:** Campos Latitud y Longitud son inputs numéricos manuales. Es propenso a errores y poco práctico.  
**Solución requerida:**
- [x] Integrar mapa interactivo en el formulario (Leaflet.js + OpenStreetMap)
- [x] Al hacer clic en el mapa → autocompletar Latitud y Longitud
- [x] Búsqueda por dirección (geocoding con Nominatim)
- [x] Visualización del radio del geofence sobre el mapa
- [x] Marcador arrastrable para ajuste fino
- [ ] Reemplazar mapa por Google Maps (opcional, requiere API Key corporativa para mayor precisión de geocoding)

**Opciones de implementación:**
| Opción | Ventaja | Costo |
|--------|---------|-------|
| Leaflet.js + OpenStreetMap | Gratis, sin API key | Gratuito ✅ |
| Google Maps JS API | Mayor precisión geocoding | Requiere API key |
| Azure Maps | Integrado con stack Microsoft | Requiere suscripción |

#### 2.2 Carga Masiva de Farmacias (Alta prioridad)
**Problema:** Farmaenlace tiene cientos de puntos de venta. La carga manual no es viable.  
**Solución requerida:**
- [ ] Botón "Importar CSV" en la pantalla de farmacias
- [ ] Plantilla descargable
- [ ] Validación de duplicados por `Codigo`
- [ ] Endpoint `POST /api/admin/farmacias/importar`
- [ ] Reporte de resultado: X creadas, Y actualizadas, Z errores
- [ ] Vista previa paginada antes de confirmar

**Formato sugerido del CSV:**
```
Codigo,Nombre,Direccion,Ciudad,Zona,Responsable,Telefono,Latitud,Longitud,GeofenceMetros
FAR001,Farmacia Norte,Av. Principal 123,Quito,Norte,Ana López,022345678,-0.2295,-78.5243,150
```

#### 2.3 Vista de Mapa General de Farmacias (Media prioridad)
- [ ] Tab "Mapa" en la sección de Farmacias
- [ ] Marcadores por farmacia (verde=activa, rojo=inactiva)
- [ ] Popup con datos del PDV y novedades recientes al clic
- [ ] Filtros por zona y estado

---

## 🔴 Módulo 3 — Seguimiento de Novedades (NUEVO)

### Estado actual del Backend
- ✅ `NovedadesController` implementado con CRUD completo
- ✅ Filtros por estado, categoría, prioridad, PDV, responsable, fechas
- ✅ Cambio de estado con comentario (`PATCH /{id}/estado`)
- ✅ Subida de imágenes con geolocalización
- ✅ Endpoints: novedades vencidas, mis-novedades, por PDV, por visita

### Estado actual del Frontend Admin
- ❌ **No existe página de Novedades en el Admin Web**
- ❌ No aparece en el menú de navegación

### Pendientes — UI Completa de Novedades

#### 3.1 Listado de Novedades (Alta prioridad)
- [ ] Nueva página `Novedades.razor` en ruta `/novedades`
- [ ] Agregar al menú lateral de navegación
- [ ] Tabla paginada: Título, PDV, Categoría, Prioridad, Estado, Responsable, Fecha límite
- [ ] Filtros: Estado, Categoría, Prioridad, PDV, Responsable, Rango de fechas
- [ ] Resaltado en rojo de novedades **vencidas**
- [ ] Badges de conteo por estado

#### 3.2 Detalle de Novedad (Alta prioridad)
- [ ] Panel lateral o modal al seleccionar una novedad
- [ ] Campos: Título, Descripción, PDV, Categoría, Prioridad
- [ ] Timeline de historial de cambios de estado
- [x] Visualización y descarga de archivos adjuntos (fotos, videos, documentos de soporte)
- [ ] Datos de responsables (solución y seguimiento)

#### 3.7 Visualización de Archivos Adjuntos (Alta prioridad)
**Solución requerida (Sitio Web Admin):**
- [x] Galería interactiva para previsualización de imágenes y reproducción de videos adjuntos (subidos desde la app móvil).
- [x] Opción para descargar documentos de soporte (PDF, Excel, Word, etc.).
- [x] *Nota: En la administración web únicamente se visualizan y descargan archivos; la carga de archivos se realiza exclusivamente desde la App Móvil.*
- [x] Soporte en backend API para recibir, almacenar y servir los archivos adjuntos provenientes de la App Móvil.

#### 3.3 Cambio de Estado con Flujo (Alta prioridad)
- [ ] Botón "Cambiar Estado" en el detalle
- [ ] Flujo de estados permitido (incluyendo el estado "Pendiente de subir información" en caso de no entenderse la novedad):
  ```
  Abierta ──→ En Proceso ──→ Resuelta
     │            │
     ├─→ Cancelada←─┘
     │
     └─→ Pendiente de subir información (si el supervisor no comprende la novedad)
  ```
- [ ] Comentario obligatorio al cambiar estado (especialmente detallando qué información falta cuando se pasa a "Pendiente de subir información")
- [ ] Registro automático en historial al cambiar de estado
- [ ] Llamada a `PATCH /api/novedades/{id}/estado`

#### 3.3.1 Módulo de Inteligencia Artificial (NLP / LLM) (Media prioridad)
- [x] Diseñar e implementar un módulo de inteligencia artificial basado en procesamiento de lenguaje natural (NLP) e integración de APIs de modelos de lenguaje grande (LLM), que permita interpretar de manera automática las descripciones textuales de las novedades de visitas, clasificar su categoría y predecir su criticidad para agilizar la derivación y resolución (Completado e integrado con Gemini 3.5 Flash en Blazor y Flutter).

#### 3.3.2 Gobernanza de Datos y Privacidad (LOPDP Ecuador) (Alta prioridad)
- [x] Establecer un protocolo de gobernanza de datos y privacidad en la solución móvil y web, asegurando el cumplimiento de la Ley Orgánica de Protección de Datos Personales (LOPDP) de Ecuador mediante mecanismos de anonimización activa de datos personales e información sensible registrada en las visitas. (Completado con anonimización activa dual: regex local + Gemini AI).

#### 3.4 Asignación de Responsables (Alta prioridad)
- [ ] Selector de usuario para "Responsable de Solución"
- [ ] Selector de usuario para "Responsable de Seguimiento"
- [ ] Date picker para fecha límite de seguimiento
- [ ] Indicador visual cuando hay novedades sin asignar

#### 3.5 KPIs de Novedades en Dashboard (Media prioridad)
- [ ] Tarjeta: Total novedades abiertas
- [ ] Tarjeta: Novedades vencidas (alerta crítica)
- [ ] Tarjeta: Resueltas este mes
- [ ] Gráfico de distribución por categoría

#### 3.6 Exportar Reporte (Baja prioridad)
- [ ] Exportar a Excel con filtros aplicados
- [ ] Reporte ejecutivo por PDV y estado

---

## 🟡 Módulo 4 — Base de Datos

### Pendientes

#### 4.1 Scripts Faltantes (Crítico — bloquea funcionamiento)
- [x] Ejecutados todos los scripts correctamente. Las tablas `PDV`, `AgendaVisitas` y los datos iniciales (roles, permisos y usuario administrador) ya existen y están configurados en la base de datos `visitapdv`.

#### 4.2 Tabla Novedades (Verificar)
- [x] Confirmado que existe la tabla `Novedades`, `NovedadHistorial` y `NovedadImagenes` en la base de datos.

---

## 🟡 Módulo 5 — App Móvil Flutter

### Estado actual
- ✅ Proyecto Flutter creado con estructura limpia
- ✅ Dependencias declaradas en `pubspec.yaml` (BLoC, Dio, Hive, Geolocator, etc.)

### Pendientes Core

#### 5.1 Autenticación
- [ ] Pantalla de Login con validación
- [ ] Integración con biometría (local_auth)
- [ ] Almacenamiento seguro de tokens (flutter_secure_storage)

#### 5.2 Visitas
- [x] Dashboard del visitador: mis farmacias del día
- [ ] Check-in de visita con geolocalización y geofence
- [ ] Captura de fotos durante la visita (image_picker)
- [ ] Modo offline con sincronización (Hive)

#### 5.3 Novedades en App
- [ ] Registrar novedad desde la app
- [ ] Ver mis novedades asignadas
- [x] Tomar fotos y videos directamente desde la cámara del dispositivo móvil para la novedad
- [x] Adjuntar documentos y archivos multimedia (fotos de galería, videos) para subirlos a la novedad

---

## 📊 Resumen de Prioridades

| # | Pendiente | Módulo | Prioridad | Esfuerzo |
|---|-----------|--------|-----------|----------|
| 1 | Ejecutar `004_create_missing_pdv_agenda.sql` | BD | ✅ Completado | - |
| 2 | Página Novedades: listado + detalle + estados | Admin Web | 🔴 Alta | 3 días |
| 3 | Crear y editar usuario | Admin Web + API | 🔴 Alta | 1 día |
| 4 | Carga masiva de farmacias CSV | Admin Web + API | 🔴 Alta | 2 días |
| 5 | Selector de mapa Leaflet (lat/lon) | Admin Web | ✅ Completado | - |
| 12 | Reemplazar mapa por Google Maps | Admin Web | 🟢 Baja | 0.5 días |
| 6 | Asignación de responsables en novedades | Admin Web | 🔴 Alta | 1 día |
| 13 | Visualizar documentos, fotos y videos (Novedades) | Admin Web | ✅ Completado | - |
| 14 | Capturar y subir fotos/videos/documentos | App Móvil + API | ✅ Completado | - |
| 7 | Carga masiva de usuarios CSV | Admin Web + API | 🟡 Media | 2 días |
| 8 | Mapa general de farmacias | Admin Web | 🟡 Media | 1 día |
| 9 | KPIs de novedades en dashboard | Admin Web | 🟡 Media | 0.5 días |
| 10 | App móvil Flutter (funcionalidad core) | App | 🟡 Media | 2 semanas |
| 11 | Exportar reporte de novedades | Admin Web + API | 🟢 Baja | 1 día |
| 15 | Módulo de IA (NLP/LLM) para novedades | Módulo 3 | ✅ Completado | - |
| 16 | Protocolo de gobernanza de datos y LOPDP | Seguridad / Web / Móvil | ✅ Completado | - |

---

## 🎨 Módulo 6 — Diseño UI/UX

### Estado actual
- ⚠️ Sitio Admin usa Bootstrap genérico sin identidad visual propia
- ⚠️ App Flutter usa Material Design por defecto sin personalización
- ❌ No existe sistema de diseño (design system) definido
- ❌ No hay guía de colores, tipografía ni componentes unificados

### Pendientes

#### 6.1 Design System — Identidad Visual (Alta prioridad)
**Objetivo:** Crear una identidad visual coherente para VisitaPDV / Farmaenlace.  
**Solución requerida:**
- [ ] Definir paleta de colores corporativa (primario, secundario, neutros, alertas)
- [ ] Seleccionar tipografía principal (ej. Inter, Roboto, Outfit)
- [ ] Documentar tokens de diseño: espaciados, radios, sombras
- [ ] Crear guía de componentes reutilizables

**Paleta sugerida base:**
| Token | Color sugerido | Uso |
|-------|---------------|-----|
| `--primary` | `#1B6CA8` (azul Farmaenlace) | Botones, links, headers |
| `--secondary` | `#00A651` (verde farmacia) | Éxito, activo, confirmación |
| `--danger` | `#E63946` | Errores, alertas, bloqueos |
| `--neutral` | `#1E293B` | Texto principal |
| `--surface` | `#F8FAFC` | Fondos de cards |

---

#### 6.2 Rediseño del Sitio Admin (Blazor) (Alta prioridad)
**Problema:** La interfaz actual usa Bootstrap básico, sin diseño premium ni experiencia de usuario optimizada.  
**Solución requerida:**

**Layout general:**
- [ ] Sidebar con gradiente oscuro y logo VisitaPDV
- [ ] Header con avatar de usuario, nombre y rol
- [ ] Breadcrumb en cada sección
- [ ] Modo oscuro / claro (toggle)

**Componentes a rediseñar:**
- [ ] **Login:** Pantalla dividida (imagen izquierda + formulario derecha), animación de entrada
- [ ] **Dashboard:** Cards con métricas animadas, gráficos con Chart.js o ApexCharts
- [ ] **Tablas:** Estilo moderno con hover, paginación, ordenamiento y exportar
- [ ] **Formularios:** Labels flotantes, validaciones inline, feedback visual
- [ ] **Modales:** Bordes redondeados, overlay suave, cierre con Escape
- [ ] **Notificaciones:** Toasts con animación slide-in desde la derecha
- [ ] **Badges de estado:** Colores semánticos con íconos (✅ Activo, ⛔ Bloqueado)

**Paleta aplicada:**
- [ ] Reemplazar Bootstrap default con variables CSS personalizadas
- [ ] Agregar Google Font (Inter o Outfit)
- [ ] Micro-animaciones en botones y transiciones de página

---

#### 6.3 Rediseño de la App Móvil (Flutter) (Alta prioridad)
**Problema:** La app usa Material Design genérico sin personalización de Farmaenlace.  
**Solución requerida:**

**Tema y colores:**
- [x] Definir `ThemeData` personalizado con colores Farmaenlace
- [x] `ColorScheme.fromSeed` con color semilla corporativo
- [x] Fuente: Google Fonts `Inter` o `Roboto`
- [ ] Modo oscuro implementado con `ThemeMode.system`

**Pantallas a diseñar:**
- [ ] **Splash Screen:** Logo animado con lottie, transición suave al login
- [x] **Login:** Fondo con gradiente, logo centrado, campos con bordes redondeados, botón con ripple
- [x] **Dashboard visitador:** Cards con sombra suave, íconos de colores, pull-to-refresh
- [ ] **Lista de farmacias del día:** Chips de estado (pendiente/completada), progress indicator
- [ ] **Formulario de visita:** Stepper visual (paso 1, 2, 3), validación en tiempo real
- [ ] **Registro de novedad:** Cámara integrada con previsualización, selector de categoría con íconos
- [x] **Perfil de usuario:** Avatar con iniciales, estadísticas del mes

**UX específicos:**
- [ ] Feedback háptico al registrar visita exitosa
- [ ] Animaciones de transición entre pantallas (Hero + FadeThrough)
- [ ] Skeleton loading en lugar de spinners genéricos
- [x] Bottom navigation bar con badges de notificación

---

#### 6.4 Assets y Recursos Visuales (Media prioridad)
- [ ] Logo VisitaPDV en SVG (versión clara y oscura)
- [ ] Iconografía consistente (usar `phosphor_flutter` o `flutter_icons`)
- [ ] Ilustraciones para pantallas vacías (empty states)
- [ ] Animaciones Lottie para: login exitoso, carga, error de conexión
- [ ] Favicon para el sitio admin web

---

#### 6.5 Responsive Design — Sitio Admin (Media prioridad)
- [ ] Sidebar colapsable en pantallas < 1024px
- [ ] Tablas con scroll horizontal en móvil
- [ ] Formularios en columna única en pantallas pequeñas
- [ ] Menú hamburguesa en mobile

---

---

## 🚀 Plan de Acción Sugerido — Sprint 1 (1 semana)

| Día | Tarea |
|-----|-------|
| Lunes | Ejecutar scripts BD + implementar Crear/Editar usuario |
| Martes | Página Novedades: listado con filtros y badges |
| Miércoles | Detalle + Cambio de estado + Timeline de historial |
| Jueves | Mapa Leaflet para coordenadas en Farmacias |
| Viernes | Carga masiva CSV (farmacias) + pruebas integrales |

---

*Documento generado con base en análisis del código fuente de VisitaPDV v1.0.0*  
*Ruta del proyecto: `VisitaPDV\admin\`, `VisitaPDV\backend\`, `VisitaPDV\visitapdv_app\`*
