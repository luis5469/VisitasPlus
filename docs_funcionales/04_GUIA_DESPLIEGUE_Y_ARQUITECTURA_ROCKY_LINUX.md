# 🐧 Guía de Arquitectura y Despliegue en Servidor de Aplicaciones con Rocky Linux 9
**Proyecto:** VisitaPDV  
**Sistema Operativo:** Rocky Linux 9 (x86_64 / aarch64 - Enterprise Linux)  
**Propósito:** Guía de referencia técnica para desplegar la nueva versión del Backend, el Sitio Web y el almacenamiento multimedia en servidores empresariales basados en RHEL / Rocky Linux.

---

## 1. Topología de Infraestructura Recomendada

```
                        [ Dispositivos Móviles ]      [ Navegadores Web (Admin) ]
                                   │                               │
                                   ▼                               ▼
                      ┌────────────────────────────────────────────────────────┐
                      │             Rocky Linux 9 Application Server           │
                      │                                                        │
                      │  ┌──────────────────────────────────────────────────┐  │
                      │  │   NGINX Reverse Proxy (Puertos 80 / 443 HTTPS)   │  │
                      │  │   - Terminación SSL / Let's Encrypt              │  │
                      │  │   - Compresión Gzip / Brotli                     │  │
                      │  │   - Rate Limiting & Seguridad HTTP               │  │
                      │  └──────────┬───────────────────┬───────────────────┘  │
                      │             │                   │                      │
                      │    /api/*   │                   │   /*                 │
                      │             ▼                   ▼                      │
                      │  ┌────────────────────┐   ┌─────────────────────────┐  │
                      │  │    Backend API     │   │   Admin Web Frontend    │  │
                      │  │  (Systemd Service  │   │  (Static Assets Nginx   │  │
                      │  │   o Container)     │   │   o SSR Node / .NET)    │  │
                      │  │    Puerto 5000     │   │      Puerto 3000        │  │
                      │  └──────────┬─────────┘   └─────────────────────────┘  │
                      │             │                                          │
                      │             ├─────────────────┐                        │
                      │             ▼                 ▼                        │
                      │  ┌────────────────────┐ ┌───────────────────────────┐  │
                      │  │  Base de Datos     │ │  Almacenamiento Multimedia│  │
                      │  │  PostgreSQL +      │ │  MinIO (S3 Compatible) o  │  │
                      │  │  PostGIS / MSSQL   │ │  Volumen Local Protegido  │  │
                      │  └────────────────────┘ └───────────────────────────┘  │
                      └────────────────────────────────────────────────────────┘
```

---

## 2. Preparación Base del Servidor Rocky Linux 9

### 2.1 Actualización de Paquetes y Repositorios
```bash
# Actualizar el sistema base
sudo dnf update -y

# Instalar repositorios EPEL (Extra Packages for Enterprise Linux)
sudo dnf install -y epel-release

# Herramientas esenciales de sistema y diagnóstico
sudo dnf install -y curl wget git htop unzip tar policycoreutils-python-utils
```

### 2.2 Configuración del Firewall (`firewalld`)
Rocky Linux tiene activo `firewalld` por defecto. Se deben abrir los puertos para tráfico web seguro:
```bash
# Permitir tráfico HTTP y HTTPS
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https

# Si la base de datos o MinIO se acceden internamente desde otra máquina de la red:
# sudo firewall-cmd --permanent --add-port=5432/tcp

# Aplicar los cambios
sudo firewall-cmd --reload
```

---

## 3. Configuración de Base de Datos en Rocky Linux

### Opción A: PostgreSQL 16 con PostGIS (Altamente Recomendada para reescritura)
PostgreSQL es la base de datos de código abierto de mayor robustez en Rocky Linux y cuenta con **PostGIS** para operaciones geográficas ultra-rápidas (cálculo de geocercas nativo indexado).

```bash
# Deshabilitar módulo postgresql por defecto de Rocky
sudo dnf -qy module disable postgresql

# Agregar repositorio oficial de PostgreSQL
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# Instalar PostgreSQL 16 y extensión PostGIS
sudo dnf install -y postgresql16-server postgis34_16

# Inicializar y habilitar el servicio
sudo /usr/pgsql-16/bin/postgresql-16-setup initdb
sudo systemctl enable postgresql-16
sudo systemctl start postgresql-16

# Crear base de datos y usuario de la aplicación
sudo -u postgres psql -c "CREATE DATABASE visitapdv;"
sudo -u postgres psql -c "CREATE USER visitapdv_user WITH ENCRYPTED PASSWORD 'TuPasswordSeguro123!';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE visitapdv TO visitapdv_user;"
sudo -u postgres psql -d visitapdv -c "CREATE EXTENSION IF NOT EXISTS postgis;"
```

### Opción B: Microsoft SQL Server 2022 on Rocky Linux 9
Si se prefiere mantener compatibilidad con los scripts SQL actuales de VisitaPDV:
```bash
# Configurar repositorio de Microsoft SQL Server
sudo curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/rhel/9/mssql-server-2022.repo

# Instalar SQL Server
sudo dnf install -y mssql-server

# Ejecutar el asistente de configuración inicial (elegir edición y contraseña de SA)
sudo /opt/mssql/bin/mssql-conf setup

# Habilitar e iniciar servicio
sudo systemctl enable mssql-server
sudo systemctl start mssql-server
```

---

## 4. Gestión del Servicio Backend con `systemd`

Crear un usuario de sistema dedicado para ejecutar la aplicación sin privilegios de root:
```bash
sudo useradd -r -s /sbin/nologin visitapdv
sudo mkdir -p /opt/visitapdv/backend
sudo mkdir -p /opt/visitapdv/storage
sudo chown -R visitapdv:visitapdv /opt/visitapdv
```

Crear el archivo de servicio systemd en `/etc/systemd/system/visitapdv-backend.service`:
```ini
[Unit]
Description=VisitaPDV Backend API Service
After=network.target postgresql-16.service

[Service]
Type=simple
User=visitapdv
Group=visitapdv
WorkingDirectory=/opt/visitapdv/backend
# Ejemplo según el stack elegido:
# Para .NET: ExecStart=/usr/bin/dotnet /opt/visitapdv/backend/VisitaPDV.API.dll
# Para Node.js: ExecStart=/usr/bin/node /opt/visitapdv/backend/dist/main.js
# Para Python: ExecStart=/opt/visitapdv/backend/venv/bin/gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app --bind 127.0.0.1:5000
# Para Go: ExecStart=/opt/visitapdv/backend/visitapdv-api
ExecStart=/opt/visitapdv/backend/visitapdv-api
Restart=always
RestartSec=10
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=PORT=5000
Environment=DATABASE_URL=Host=localhost;Database=visitapdv;Username=visitapdv_user;Password=TuPasswordSeguro123!
Environment=GEMINI_API_KEY=AIzaSy...TuApiKeyDeGemini
Environment=STORAGE_PATH=/opt/visitapdv/storage

[Install]
WantedBy=multi-user.target
```

Habilitar y arrancar el backend:
```bash
sudo systemctl daemon-reload
sudo systemctl enable visitapdv-backend
sudo systemctl start visitapdv-backend
sudo systemctl status visitapdv-backend
```

---

## 5. Configuración de NGINX y Certificados SSL

### 5.1 Instalación de NGINX
```bash
sudo dnf install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
```

### 5.2 Configuración del Virtual Host
Crear el archivo de configuración en `/etc/nginx/conf.d/visitapdv.conf`:
```nginx
# Límite de subida de archivos (100MB para videos cortos de evidencias)
client_max_body_size 100M;

# Servidor HTTP: Redirige todo el tráfico a HTTPS
server {
    listen 80;
    server_name visitapdv.farmaenlace.com; # O la IP del servidor
    return 301 https://$host$request_uri;
}

# Servidor HTTPS
server {
    listen 443 ssl http2;
    server_name visitapdv.farmaenlace.com;

    # Certificados SSL
    ssl_certificate /etc/letsencrypt/live/visitapdv.farmaenlace.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/visitapdv.farmaenlace.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Compresión
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;

    # 1. Frontend Web de Administración (Single Page Application / Assets)
    location / {
        root /opt/visitapdv/admin/dist;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    # 2. Reverse Proxy a la API Backend
    location /api/ {
        proxy_pass http://127.0.0.1:5000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;

        # Timeouts para subidas pesadas de videos y análisis de IA
        proxy_read_timeout 120s;
        proxy_connect_timeout 60s;
    }

    # 3. Servidor de Archivos Multimedia Protegidos
    location /storage/ {
        alias /opt/visitapdv/storage/;
        # Se puede restringir por token o delegar a endpoints del backend
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }
}
```

---

## 6. Ajustes de Seguridad y SELinux en Rocky Linux

Rocky Linux utiliza **SELinux en modo Enforcing** por defecto. Para que NGINX pueda actuar como proxy inverso hacia el puerto del backend (puerto 5000) y leer los archivos web:

```bash
# Permitir que Nginx se conecte a servicios de red locales (Proxy inverso)
sudo setsebool -P httpd_can_network_connect 1

# Permitir que Nginx lea el directorio estático del frontend
sudo semanage fcontext -a -t httpd_sys_content_t "/opt/visitapdv/admin/dist(/.*)?"
sudo restorecon -Rv /opt/visitapdv/admin/dist

# Permitir lectura de la carpeta de almacenamiento multimedia
sudo semanage fcontext -a -t httpd_sys_content_t "/opt/visitapdv/storage(/.*)?"
sudo restorecon -Rv /opt/visitapdv/storage
```

---

## 7. Automatización de Backups y Mantenimiento

Crear un script de respaldo diario en `/opt/visitapdv/scripts/backup.sh`:
```bash
#!/bin/bash
BACKUP_DIR="/var/backups/visitapdv"
FECHA=$(date +"%Y%m%d_%H%M%S")
mkdir -p $BACKUP_DIR

# Respaldo de Base de Datos PostgreSQL
PGPASSWORD="TuPasswordSeguro123!" pg_dump -U visitapdv_user -h localhost visitapdv | gzip > "$BACKUP_DIR/db_$FECHA.sql.gz"

# Respaldo de Archivos Multimedia (Fotos con Watermark y Videos)
tar -czf "$BACKUP_DIR/media_$FECHA.tar.gz" -C /opt/visitapdv/storage .

# Eliminar respaldos con más de 30 días de antigüedad
find $BACKUP_DIR -type f -name "*.gz" -mtime +30 -exec rm {} \;
```
Programarlo en `crontab -e`:
```cron
0 2 * * * /bin/bash /opt/visitapdv/scripts/backup.sh > /dev/null 2>&1
```

