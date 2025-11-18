# Arquitectura de Microservicios con Docker

## Autores
- **Jhonatan Sierra**
- **Karen Ruiz**
- **Wilson Soledad**

---


Proyecto de microservicios con **balanceo de carga**, **autenticación JWT** y **base de datos PostgreSQL centralizada**.

---

## Servicios

### 1. Base de Datos Centralizada
- **PostgreSQL 15** en puerto `5432`
- Base de datos única: `microservices_db`
- Todas las tablas de los 3 microservicios
- Volumen persistente: `postgres-data`

### 2. Microservicio de Usuarios (UsersService)
- **2 instancias** con balanceo de carga
- Puerto interno: `8001`
- Rutas: `/api/v1/users/*`
- **Funcionalidad**: Autenticación JWT, gestión de usuarios

### 3. Microservicio de Nóminas (PayrollService)
- **2 instancias** con balanceo de carga
- Puerto interno: `3002`
- Rutas: `/api/payroll/*`
- **Funcionalidad**: Gestión de nóminas y empresas

### 4. Microservicio de Incapacidades (IncapacitiesService)
- **2 instancias** con balanceo de carga
- Puerto interno: `3000`
- Rutas: `/api/incapacities/*`
- **Funcionalidad**: Radicar y gestionar incapacidades

### 5. Nginx Load Balancer
- Puerto: `80`
- Algoritmo: `least_conn` (menor número de conexiones)
- Health checks configurados

---

## Requisitos Previos

- **Docker Desktop** instalado (versión 20.10+)
- **Docker Compose** v3.8+
- **4GB RAM** mínimo disponibles
- **Puertos libres**: 80, 5432
- Sistema operativo: Windows/Linux/MacOS

---

## 🚀 Inicio Rápido

### 1. Levantar todos los servicios
```bash
docker-compose up -d --build
```

### 2. Cargar datos iniciales (IMPORTANTE)
**Este comando es necesario para el flujo completo de los endpoints:**
```bash
docker exec users-service-1 npm run seed
```

Este comando crea:
- ✅ Usuario administrador: `admin@example.com` / `mypassword123`
- ✅ 5 empresas predefinidas en la base de datos
- ✅ Datos necesarios para probar todos los endpoints

### 3. Verificar que todo esté funcionando
```bash
docker-compose ps
```

Todos los servicios deben mostrar estado `healthy`.

---

## Colección Postman

### Importar en Postman:

1. Descarga el archivo: **`ProyectoDistribuidos.postman_collection.json`** (ubicado en la raíz del proyecto)
2. Abre Postman
3. Click en **Import** (botón superior izquierdo)
4. Arrastra el archivo o selecciónalo
5. La colección aparecerá en el panel izquierdo con **4 carpetas**:
   - **1. UsersService** - 6 endpoints de usuarios
   - **2. PayrollService** - 8 endpoints de nóminas
   - **3. IncapacitiesService** - 5 endpoints de incapacidades
   - **4. Flujo Completo** - 7 pasos automatizados

### Cómo usar la colección:

1. **Ejecuta primero**: `1.1 Login` para obtener el token JWT
2. El token se guarda automáticamente en la variable `{{JWT_TOKEN}}`
3. Todos los demás requests usarán este token automáticamente
4. Si el token expira (1 hora), vuelve a ejecutar el login

### Variables de la colección:
- `{{BASE_URL}}`: `http://localhost`
- `{{JWT_TOKEN}}`: Se llena automáticamente después del login
- `{{USER_ID}}`: Se actualiza al crear usuarios
- `{{PAYROLL_ID}}`: Se actualiza al crear nóminas
- `{{INCAPACITY_ID}}`: Se actualiza al crear incapacidades

### Flujo Completo Automatizado:
La carpeta **"4. Flujo Completo de Prueba"** contiene 7 requests que puedes ejecutar secuencialmente usando el **Collection Runner** de Postman para probar todo el sistema de principio a fin.

---

## 📊 Endpoints Disponibles

### 🔐 USUARIOS (`/api/v1/users`)

| Método | Endpoint | Auth | Descripción |
|--------|----------|------|-------------|
| POST | `/login` | No | Iniciar sesión y obtener token |
| POST | `/` | Sí (Admin) | Crear usuario |
| GET | `/` | No | Obtener todos los usuarios |
| GET | `/:id` | No | Obtener usuario por ID |
| PUT | `/:id` | Sí (Admin) | Actualizar usuario |
| DELETE | `/:id` | Sí (Admin) | Eliminar usuario |

### 💼 NÓMINAS (`/api/payroll`)

| Método | Endpoint | Auth | Descripción |
|--------|----------|------|-------------|
| POST | `/` | Sí (Admin) | Crear nómina |
| GET | `/` | Sí (Admin) | Obtener todas las nóminas |
| GET | `/:id` | Sí | Obtener nómina por ID |
| GET | `/document/:document` | Sí | Obtener nómina por documento |
| GET | `/document/:document/active` | Sí | Obtener nómina activa |
| PUT | `/:id` | Sí (Admin) | Actualizar nómina |
| DELETE | `/:id` | Sí (Admin) | Eliminar nómina |
| GET | `/companies` | Sí | Listar empresas |

### 🏥 INCAPACIDADES (`/api/incapacities`)

| Método | Endpoint | Auth | Descripción |
|--------|----------|------|-------------|
| POST | `/` | Sí | Crear incapacidad |
| GET | `/` | Sí | Obtener todas las incapacidades |
| GET | `/:id` | Sí | Obtener incapacidad por ID |
| GET | `/user/:userId` | Sí | Obtener incapacidades de un usuario |
| PUT | `/:id/status` | Sí | Actualizar estado de incapacidad |

---

## 📊 Códigos de Estado HTTP

| Código | Significado | Cuándo se usa |
|--------|-------------|---------------|
| 200 | OK | Operación exitosa (GET, PUT) |
| 201 | Created | Recurso creado (POST) |
| 204 | No Content | Eliminación exitosa (DELETE) |
| 400 | Bad Request | Datos inválidos o faltantes |
| 401 | Unauthorized | Token faltante, inválido o expirado |
| 403 | Forbidden | No tienes permisos para esta operación |
| 404 | Not Found | Recurso no encontrado |
| 409 | Conflict | Conflicto (ej: email duplicado) |
| 500 | Internal Server Error | Error interno del servidor |
| 503 | Service Unavailable | Servicio no disponible |

---

## 🛠️ Comandos Útiles Docker

### Gestión de Contenedores
```bash
# Ver todos los contenedores
docker-compose ps

# Ver logs en tiempo real
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f users-service-1

# Reiniciar todos los servicios
docker-compose restart

# Reiniciar un servicio específico
docker-compose restart users-service-1

# Detener todos los servicios
docker-compose stop

# Iniciar servicios detenidos
docker-compose start

# Eliminar contenedores (mantiene volúmenes)
docker-compose down

# Eliminar todo (contenedores + volúmenes + imágenes)
docker-compose down -v --rmi all
```


### Ejecutar Comandos en Contenedores
```bash
# Acceder a la terminal de un contenedor
docker exec -it users-service-1 sh

# Ejecutar un comando específico
docker exec -it users-service-1 npm run build

# Acceder a PostgreSQL
docker exec -it shared-postgres-db psql -U postgres -d microservices_db

# Ver tablas en PostgreSQL
docker exec -it shared-postgres-db psql -U postgres -d microservices_db -c '\dt'
```

---

## 🔒 Seguridad

### JWT (JSON Web Token)
- **Algoritmo**: HS256
- **Expiración**: 1 hora
- **Secret Key**: 128 caracteres hexadecimales
- **Payload**: `{ id: number, role: string, iat: number, exp: number }`

### Roles de Usuario
- **admin**: Acceso completo a todos los endpoints
- **employee**: Acceso limitado, puede ver sus propios datos

### Endpoints Protegidos
Todos los endpoints excepto:
- `POST /api/v1/users/login`
- `GET /api/v1/users`
- `GET /api/v1/users/:id`
- `GET /health` (todos los servicios)

---

## 🌐 Arquitectura de Red

### Red Docker: `microservices-network`
Todos los servicios se comunican en una red bridge aislada.

### Comunicación entre servicios:
- **Externa** (desde navegador/Postman): `http://localhost:80`
- **Interna** (entre contenedores): 
  - `http://users-service-1:8001`
  - `http://payroll-service-1:3002`
  - `http://incapacities-service-1:3000`

### Rutas Nginx:
- `/api/v1/users` → UsersService (puerto 8001)
- `/api/payroll` → PayrollService (puerto 3002)
- `/api/incapacities` → IncapacitiesService (puerto 3000)

---