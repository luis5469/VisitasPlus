# 📱 Especificación Funcional y Técnica: APLICACIÓN MÓVIL
**Proyecto:** VisitaPDV — Aplicación Móvil de Campo para Visitadores  
**Entorno de Conexión:** Servidor de Aplicaciones en **Rocky Linux**  
**Propósito:** Especificación funcional, flujos operativos, capacidades offline y multimedia para reescritura de la app móvil.

---

## 1. Visión y Propósito de la Aplicación Móvil
La aplicación móvil es la herramienta operativa de los **visitadores de puntos de venta** en sus recorridos diarios a las farmacias de Farmaenlace. Su objetivo primordial es garantizar el cumplimiento del plan de visitas mediante validación estricta de geolocalización (geocercas), captura inmutable de evidencias multimedia (fotos con marca de agua, video y documentos), registro de novedades con asistencia de inteligencia artificial y capacidad total de operación fuera de línea (offline-first).

---

## 2. Requerimientos Funcionales y Módulos

### 2.1 Módulo de Autenticación, Biometría y Sesión Segura
- **Login Inicial:**
  - Formulario con campos de Usuario o Correo y Contraseña.
  - Validación de credenciales contra la API y almacenamiento del Access Token y Refresh Token en almacenamiento seguro del sistema operativo (Keychain en iOS, Keystore / EncryptedSharedPreferences en Android).
- **Autenticación Biométrica:**
  - Tras el primer inicio de sesión exitoso, la app ofrece activar el desbloqueo mediante Biometría (Huella Dactilar o Reconocimiento Facial).
  - En ingresos posteriores, el visitador puede acceder de forma instantánea sin digitar la contraseña.
- **Protección contra Fuerza Bruta y Lockout:**
  - Si se cometen intentos erróneos repetidos, la app presenta la pantalla de bloqueo temporal (`lockout_page`) informando el tiempo de espera.
- **Detección de Conectividad y Resiliencia:**
  - Monitoreo en segundo plano del estado de red (Wi-Fi, Datos Móviles o Sin Conexión).
  - Barra superior persistente o banner que notifica discretamente cuando el dispositivo está en modo *Offline*.

---

### 2.2 Módulo de Agenda Diaria y Control de Visitas (Check-In / Check-Out)

#### A. Agenda de Farmacias del Día (Home / Dashboard)
- Listado ordenado de las farmacias asignadas para la jornada actual.
- Cada tarjeta de farmacia muestra:
  - Código y Nombre de la Farmacia.
  - Dirección física y Ciudad.
  - Distancia en tiempo real en metros o kilómetros calculada mediante GPS entre la posición actual del visitador y las coordenadas del PDV.
  - Badge de estado: `Pendiente`, `En Curso`, `Completada`.

#### B. Check-In Geocercado (Iniciar Visita)
- Al presionar **"Iniciar Visita"**:
  1. La aplicación solicita la ubicación GPS de alta precisión del dispositivo.
  2. Calcula la distancia mediante la **Fórmula de Haversine** contra las coordenadas del PDV.
  3. **Validación de Geocerca**:
     - Si la distancia es $\le$ al radio configurado para la farmacia (ej. 100 metros), el sistema permite iniciar la visita y registra el timestamp y las coordenadas exactas de ingreso.
     - Si la distancia es $>$ al radio permitido, se bloquea el inicio y se muestra una alerta visual informando la distancia faltante (ej. *"Se encuentra a 340 metros. Debe estar a menos de 100 m del punto de venta"*).
  4. **Restricción de Concurrencia**: No se permite iniciar una visita si ya existe otra visita activa sin finalizar.

#### C. Durante la Visita
- La farmacia activa se destaca visualmente con temporizador de permanencia (tiempo transcurrido).
- Acciones disponibles durante la visita:
  - Reportar una o varias novedades / incidencias encontradas en la farmacia.
  - Ver el historial de novedades previas de ese punto de venta para verificar si problemas anteriores fueron corregidos.

#### D. Check-Out Geocercado (Finalizar Visita)
- Al presionar **"Finalizar Visita"**:
  - Se verifica nuevamente la posición GPS para certificar que el visitador se encuentra cerrando la visita en el lugar de los hechos.
  - Se registra el timestamp de salida y se calcula la duración total de la inspección.
  - Se genera un resumen de la visita con las novedades levantadas y se marca la agenda como `Completada`.

---

### 2.3 Módulo de Captura y Registro de Novedades con IA

#### A. Creación de Incidencia
- El visitador completa el formulario de novedad:
  - **Título sugerido** o ingresado.
  - **Descripción libre** del problema observado (ej. fallas de refrigeración de vacunas, perchas vacías, rotulación deteriorada, goteras, etc.).
  - **Categoría** (Inventario, Precios, Exhibición, Limpieza, Equipamiento, Infraestructura, etc.).
  - **Prioridad** (Baja, Media, Alta, Crítica).
  - **Asignación de Responsable** (si se conoce) y fecha tentativa de seguimiento.

#### B. Asistente Inteligente en Campo (Integración Gemini LLM)
- Botón **"Analizar con IA"** junto a la descripción:
  - El visitador redacta la novedad con sus propias palabras o dictado de voz.
  - El motor de IA analiza el texto y devuelve:
    1. Una categoría normalizada coherente.
    2. Un nivel de criticidad justificado por el impacto operativo.
    3. Un título conciso y estandarizado.
  - El visitador puede aceptar la recomendación con un solo toque, optimizando los tiempos de digitación en campo.

#### C. Anonimización Activa LOPDP
- Antes de almacenar o transmitir cualquier texto, la aplicación ejecuta el filtro de privacidad para enmascarar automáticamente números de cédula ecuatorianos válidos, teléfonos celulares/fijos y correos electrónicos de terceros para proteger la privacidad en cumplimiento legal.

---

### 2.4 Módulo Multimedia en Terreno: Cámara con Watermark, Video y Documentos

#### A. Fotos con Marca de Agua Criptográfica/Visual (Watermark)
- Captura directa desde la cámara del smartphone.
- **Estampado automático e irreversible sobre la imagen capturada**:
  - Nombre y apellido del visitador.
  - Fecha y hora exacta de la toma (`YYYY-MM-DD HH:mm:ss`).
  - Coordenadas geográficas (`Lat: -0.2295, Lon: -78.5243`).
  - Código y nombre de la farmacia.
- Redimensión y compresión inteligente en el dispositivo para reducir consumo del plan de datos (JPEG calidad 85%, resolución máx 1920px).

#### B. Grabación de Video de Evidencia
- Soporte para grabar videos cortos (hasta 3 minutos) directamente desde la app.
- Indispensable para registrar goteras, fallas en cortinas eléctricas de seguridad, problemas de climatización o ruidos en motores de frío.

#### C. Adjuntar Documentos de Soporte
- Selector de archivos para adjuntar actas firmadas, guías de remisión o reportes técnicos en formato PDF, Word o Excel.

---

### 2.5 Arquitectura de Operación Fuera de Línea (Offline-First) y Sincronización

#### A. Almacenamiento Local en el Dispositivo
- Base de datos local embebida (Hive o SQLite / WatermelonDB) que almacena:
  - Catálogo de farmacias asignadas.
  - Visitas iniciadas y finalizadas localmente.
  - Novedades redactadas en zonas sin señal de internet.
  - Cola de archivos multimedia (`imagen_offline_queue`).

#### B. Cola Transaccional de Sincronización (`SyncQueue`)
- Cuando el visitador realiza acciones sin señal celular:
  1. Cada evento (check-in, novedad, archivo multimedia, check-out) se almacena con un UUID único y un timestamp secuencial.
  2. Los archivos multimedia quedan guardados en el almacenamiento privado del teléfono.
- En cuanto el servicio de conectividad detecta que se restablece la conexión a internet (Wi-Fi o 4G/5G):
  1. El servicio `SyncService` se despierta automáticamente en segundo plano.
  2. Procesa la cola enviando primero las visitas, luego las novedades y finalmente la carga de archivos pesados.
  3. Al recibir confirmación `200 OK` del backend en Rocky Linux, marca los registros locales como `Sincronizado = true` y libera espacio de almacenamiento local.

---

### 2.6 Módulo de Perfil e Historial del Visitador
- **Historial de Visitas**: Registro de las visitas anteriores del visitador con filtros por fecha, mostrando tiempos de permanencia y novedades levantadas.
- **Perfil de Usuario**: Visualización de los datos del visitador, zona operativa y opciones de configuración (activar/desactivar biometría, limpiar caché local, cerrar sesión).

---

## 3. Guía de Reescritura y Compatibilidad Tecnológica

Para el desarrollo de la nueva app móvil conectada al servidor Rocky Linux:
1. **Opciones Tecnológicas Recomendadas**:
   - **Flutter (Continuidad Dart)**: Excelente rendimiento nativo compilado, BLoC / Riverpod para estado, Hive / Isar para base de datos offline y soporte unificado para Android e iOS.
   - **React Native (Expo / TypeScript)**: Muy versátil con bibliotecas como WatermelonDB o SQLite para soporte offline-first y expo-camera para marcas de agua.
   - **Kotlin Multiplatform (KMP)** o **Nativo Android (Kotlin) / iOS (Swift)**: Si se busca el máximo control sobre servicios de geolocalización en background.
2. **Configuración de Conectividad con Rocky Linux**:
   - La app se comunica con el servidor mediante HTTPS utilizando certificados SSL válidos (Let's Encrypt / DigiCert) configurados en el reverse proxy Nginx de Rocky Linux.
   - Configuración de `baseUrl`:
     - Pruebas en red local: IP privada del servidor (ej. `https://192.168.1.100/api`).
     - Producción: Dominio corporativo oficial (ej. `https://visitapdv.farmaenlace.com/api`).

