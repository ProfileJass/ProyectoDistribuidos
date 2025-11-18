# Arquitectura de Microservicios con Docker

Proyecto de microservicios con balanceo de carga y base de datos centralizada.

## 📋 Arquitectura

```
┌─────────────────────────────────────────────────┐
│              Nginx Load Balancer                │
│                   (Puerto 80)                    │
└────────────┬────────────┬────────────┬──────────┘
             │            │            │
    ┌────────▼──────┐ ┌──▼─────────┐ ┌▼──────────────┐
    │  Users MS     │ │ Payroll MS │ │Incapacities MS│
    │ Instance 1&2  │ │Instance 1&2│ │ Instance 1&2  │
    └────────┬──────┘ └──┬─────────┘ └┬──────────────┘
             │            │            │
             └────────────┴────────────┘
                         │
                    ┌────▼─────┐
                    │PostgreSQL│
                    │   DB     │
                    └──────────┘
```

## 🚀 Servicios

### 1. Base de Datos Centralizada
- **PostgreSQL 15** en puerto `5432`
- Base de datos única: `microservices_db`
- Todas las tablas de los 3 microservicios
- Script de inicialización: `init-db.sql`

### 2. Microservicio de Usuarios
- **2 instancias** con balanceo de carga
- Puerto interno: `8001`
- Rutas: `/api/users/*`

### 3. Microservicio de Nóminas
- **2 instancias** con balanceo de carga
- Puerto interno: `3002`
- Rutas: `/api/payroll/*`

### 4. Microservicio de Incapacidades
- **2 instancias** con balanceo de carga
- Puerto interno: `3000`
- Rutas: `/api/incapacities/*`

### 5. Nginx Load Balancer
- Puerto: `80`
- Algoritmo: `least_conn` (menor número de conexiones)
- Health checks configurados

## 📦 Requisitos Previos

- Docker Desktop instalado
- Docker Compose v3.8+
- 4GB RAM mínimo
- Puertos disponibles: 80, 5432

## 🔧 Instalación

### 1. Clonar el repositorio
```bash
cd ProyectoDistribuidos
```

### 2. Configurar variables de entorno
```bash
cp .env.example .env
# Editar .env con tus valores
```

### 3. Construir y levantar todos los servicios
```bash
docker-compose up --build -d
```

### 4. Verificar que los servicios estén corriendo
```bash
docker-compose ps
```

### 5. Ver logs
```bash
# Todos los servicios
docker-compose logs -f

# Servicio específico
docker-compose logs -f users-service-1
docker-compose logs -f payroll-service-1
docker-compose logs -f incapacities-service-1
docker-compose logs -f nginx
```

## 🧪 Probar la API

### Health Check
```bash
curl http://localhost/health
```

### Microservicio de Usuarios
```bash
# Registrar usuario
curl -X POST http://localhost/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"firstName":"John","lastName":"Doe","email":"john@example.com","password":"pass123","role":"employee"}'

# Login
curl -X POST http://localhost/api/users/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@example.com","password":"pass123"}'
```

### Microservicio de Nóminas
```bash
# Obtener nóminas (requiere token)
curl -X GET http://localhost/api/payroll \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Microservicio de Incapacidades
```bash
# Crear incapacidad (requiere token)
curl -X POST http://localhost/api/incapacities \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "id_user": 1,
    "id_payroll": 1,
    "start_date": "2024-01-01",
    "end_date": "2024-01-10",
    "type": "enfermedad",
    "observacion": "Gripe"
  }'

# Obtener todas las incapacidades
curl -X GET http://localhost/api/incapacities \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 🔍 Monitoreo

### Ver estado de contenedores
```bash
docker-compose ps
```

### Verificar health checks
```bash
docker inspect users-service-1 | grep Health
docker inspect payroll-service-1 | grep Health
docker inspect incapacities-service-1 | grep Health
```

### Estadísticas de recursos
```bash
docker stats
```

## 🛠️ Comandos Útiles

### Detener todos los servicios
```bash
docker-compose down
```

### Detener y eliminar volúmenes (¡CUIDADO! Borra la BD)
```bash
docker-compose down -v
```

### Reiniciar un servicio específico
```bash
docker-compose restart users-service-1
```

### Escalar servicios (agregar más instancias)
```bash
docker-compose up -d --scale users-service-1=3
```

### Reconstruir un servicio específico
```bash
docker-compose up -d --build users-service-1
```

### Acceder a la base de datos
```bash
docker exec -it shared-postgres-db psql -U postgres -d microservices_db
```

## 📊 Base de Datos

### Tablas creadas automáticamente:
- `users` - Usuarios del sistema
- `companies` - Empresas
- `payrolls` - Nóminas
- `incapacities` - Incapacidades

### Datos iniciales (seed):
- 5 compañías pre-cargadas
