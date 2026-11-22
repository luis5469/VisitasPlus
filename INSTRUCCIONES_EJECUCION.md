# 🚀 Guía de Configuración y Ejecución del Sistema VisitaPDV

Esta guía contiene las instrucciones detalladas para poner en marcha todos los componentes del sistema **VisitaPDV**: la base de datos SQL Server, el backend API (.NET 10), el sitio web de administración (Blazor Server) y la aplicación móvil (Flutter).

---

## 🛠️ Requisitos Previos

Antes de comenzar, asegúrate de tener instalado el siguiente software en tu equipo:
1. **SDK de .NET 10**: Necesario para compilar y ejecutar el Backend y el Sitio Web Admin.
2. **SQL Server & SQL Server Management Studio (SSMS)**: Instancia de base de datos local (por defecto se asume la instancia `SQLDIGITALEXPRES`).
3. **SDK de Flutter (versión 3.19 o superior)**: Necesario para ejecutar la aplicación móvil.
4. **IDE / Herramientas de Desarrollo**:
   - Visual Studio 2022 / Visual Studio Code (con extensiones de C# y Flutter/Dart).
   - Android Studio (para el emulador de Android) o Xcode (si estás en macOS para simular iOS).

---

## 💾 Paso 1: Configuración de la Base de Datos (SQL Server)

El sistema utiliza SQL Server como base de datos relacional. Sigue estos pasos para prepararla:

1. **Configurar la cadena de conexión**:
   Abre el archivo [appsettings.json](file:///c:/Users/lcabascang/Downloads/Download_1/MBA_Transformacion_Digital/Titulacion_I/VisitaPDV/backend/src/VisitaPDV.API/appsettings.json) en el Backend y verifica la cadena de conexión bajo `ConnectionStrings.DefaultConnection`. Por defecto es:
   ```json
   "DefaultConnection": "Server=.\\SQLDIGITALEXPRES;Database=visitapdv;Trusted_Connection=True;TrustServerCertificate=True;"
   ```
   *Si tu instancia de SQL Server tiene otro nombre (por ejemplo `localhost` o `SQLEXPRESS`), modifícalo allí.*

2. **Ejecutar los scripts de base de datos**:
   Abre **SQL Server Management Studio (SSMS)**, conéctate a tu instancia, crea una base de datos vacía llamada `visitapdv`, y ejecuta los scripts ubicados en la carpeta [scripts](file:///c:/Users/lcabascang/Downloads/Download_1/MBA_Transformacion_Digital/Titulacion_I/VisitaPDV/scripts) en el siguiente **orden estricto**:

   | Orden | Archivo | Descripción |
   |:---:|---|---|
   | **1** | [`000_EF_Migration_InitialAuth.sql`](file:///c:/Users/lcabascang/Downloads/Download_1/MBA_Transformacion_Digital/Titulacion_I/VisitaPDV/scripts/000_EF_Migration_InitialAuth.sql) | Crea las tablas base de autenticación y usuarios. |
   | **2** | [`001_seed_roles.sql`](file:///c:/Users/lcabascang/Downloads/Download_1/MBA_Transformacion_Digital/Titulacion_I/VisitaPDV/scripts/001_seed_roles.sql) | Inserta los roles predeterminados (*Administrador*, *Supervisor*, *Visitador*). |
   | **3** | [`002_seed_permisos.sql`](file:///c:/Users/lcabascang/Downloads/Download_1/MBA_Transformacion_Digital/Titulacion_I/VisitaPDV/scripts/002_seed_permisos.sql) | Inserta los permisos del sistema. |
   | **4** | [`003_seed_admin_user.sql`](file:///c:/Users/lcabascang/Downloads/Download_1/MBA_Transformacion_Digital/Titulacion_I/VisitaPDV/scripts/003_seed_admin_user.sql) | Crea el usuario administrador por defecto. |
   | **5** | [`004_create_missing_pdv_agenda.sql`](file:///c:/Users/lcabascang/Downloads/Download_1/MBA_Transformacion_Digital/Titulacion_I/VisitaPDV/scripts/004_create_missing_pdv_agenda.sql) | Crea las tablas de Puntos de Venta (PDV) y Agenda de Visitas. |
   | **6** | [`005_seed_pdv.sql`](file:///c:/Users/lcabascang/Downloads/Download_1/MBA_Transformacion_Digital/Titulacion_I/VisitaPDV/scripts/005_seed_pdv.sql) | Inserta farmacias iniciales (PDV) de prueba. |

### 🔑 Credenciales de Acceso Iniciales (Seeded)
El script `003_seed_admin_user.sql` crea un usuario administrador inicial con el cual podrás iniciar sesión en el sitio web de administración:
* **Usuario (Username o Email):** `admin` o `admin@visitapdv.com`
* **Contraseña:** `Admin@2024!`

---

## 🖥️ Paso 2: Ejecutar el Backend (API .NET 10)

La API proporciona todos los endpoints para el sitio web y la app móvil.

1. Abre tu terminal de comandos (PowerShell / Command Prompt).
2. Tienes dos opciones para ejecutarlo:
   - **Opción A (Recomendada desde la carpeta `VisitaPDV`):**
     ```powershell
     dotnet run --project backend/src/VisitaPDV.API
     ```
   - **Opción B (Navegando a la carpeta del proyecto API):**
     ```powershell
     cd "c:\OneD\BI\OneDrive - Farmaenlace\Documentos\Personales\MBA_Transformacion_Digital\Titulacion_I\VisitaPDV\backend\src\VisitaPDV.API"
     dotnet run
     ```
4. El backend se iniciará localmente. Por defecto estará escuchando en:
   - **HTTP:** `http://localhost:5284`
   - **HTTPS:** `https://localhost:7088`
5. Puedes acceder a la documentación interactiva en Swagger abriendo en tu navegador:
   🔗 **`http://localhost:5284/swagger`** o **`https://localhost:7088/swagger`**

---

## 🌐 Paso 3: Ejecutar el Sitio Web de Administración (Blazor Server)

El sitio web permite a los supervisores y administradores gestionar usuarios, farmacias, planificar visitas y realizar seguimiento a novedades.

1. Abre una nueva pestaña o ventana de la terminal.
2. Tienes dos opciones para ejecutarlo:
   - **Opción A (Recomendada desde la carpeta `VisitaPDV`):**
     ```powershell
     dotnet run --project admin/VisitaPDV.Admin
     ```
   - **Opción B (Navegando a la carpeta del proyecto Admin):**
     ```powershell
     cd "c:\OneD\BI\OneDrive - Farmaenlace\Documentos\Personales\MBA_Transformacion_Digital\Titulacion_I\VisitaPDV\admin\VisitaPDV.Admin"
     dotnet run
     ```
3. Verifica la configuración de la API en el archivo [appsettings.json](file:///c:/OneD/BI/OneDrive%20-%20Farmaenlace/Documentos/Personales/MBA_Transformacion_Digital/Titulacion_I/VisitaPDV/admin/VisitaPDV.Admin/appsettings.json):
   ```json
   "ApiBaseUrl": "http://localhost:5284"
   ```
   *Debe apuntar a la URL HTTP donde esté corriendo la API del backend.*
4. El portal se iniciará localmente en la URL configurada en su perfil de lanzamiento:
   🔗 **`http://localhost:5000`**
5. Abre tu navegador, navega a esa dirección e ingresa con las credenciales por defecto (`admin` / `Admin@2024!`).

---

## 📱 Paso 4: Ejecutar la Aplicación Móvil (Flutter)

La aplicación móvil es utilizada por los visitadores en el campo para registrar visitas, check-in, fotos, geolocalización y reportar novedades.

1. Abre una nueva ventana de la terminal.
2. Dirígete a la carpeta de la app móvil:
   ```powershell
   cd "c:\OneD\BI\OneDrive - Farmaenlace\Documentos\Personales\MBA_Transformacion_Digital\Titulacion_I\VisitaPDV\visitapdv_app"
   ```
3. Configura la URL de la API:
   Abre el archivo [api_constants.dart](file:///c:/Users/lcabascang/Downloads/Download_1/MBA_Transformacion_Digital/Titulacion_I/VisitaPDV/visitapdv_app/lib/core/constants/api_constants.dart) y verifica el parámetro `baseUrl`:
   ```dart
   static const String baseUrl = 'http://10.0.2.2:5284/api';
   ```
   - **Emulador Android**: Usa `http://10.0.2.2:5284/api` (la dirección loopback especial para conectar al localhost de la máquina host).
   - **Simulador iOS**: Usa `http://localhost:5284/api`.
   - **Dispositivo Físico**: Reemplaza con la dirección IP local de tu computador (ej. `http://192.168.100.50:5284/api`). Tu dispositivo móvil y tu PC deben estar conectados a la misma red Wi-Fi.
4. Obtén las dependencias del proyecto Flutter:
   ```powershell
   flutter pub get
   ```
5. Asegúrate de tener un emulador activo o tu dispositivo físico conectado:
   ```powershell
   flutter devices
   ```
6. Ejecuta la aplicación móvil:
   ```powershell
   flutter run
   ```
7. La aplicación se compilará y se desplegará en el emulador o dispositivo seleccionado.

---

## 💡 Consejos de Desarrollo y Troubleshooting

* **Errores de Conexión de Base de Datos**: Si la consola del Backend muestra errores de conexión, asegúrate de que el servicio de SQL Server esté corriendo (puedes verificarlo en la herramienta `services.msc` de Windows) y que la instancia `SQLDIGITALEXPRES` o la que estés usando esté habilitada para conexiones locales TCP/IP.
* **Problema con Certificados de Seguridad SSL**: Dado que localmente se suele usar HTTP o certificados autofirmados, si la app móvil o el sitio web reportan problemas de comunicación segura, asegúrate de usar las rutas `http` (no `https`) o de confiar en los certificados locales de desarrollo de .NET ejecutando:
  ```powershell
  dotnet dev-certs https --trust
  ```
* **Limpieza de Caché en Flutter**: Si la aplicación móvil presenta problemas al importar paquetes o errores inesperados después de cambios de dependencias, ejecuta:
  ```powershell
  flutter clean
  flutter pub get
  ```
