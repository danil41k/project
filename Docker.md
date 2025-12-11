# Документація контейнеризації Flask проєкту

## Огляд

Цей проєкт контейнеризований за допомогою Docker та Docker Compose для спрощення розгортання та управління середовищем.

### Технічні характеристики

- **Базовий образ**: `python:3.11-alpine` (легкий і безпечний)
- **Метод збірки**: Багатоетапна збірка (multi-stage build)
- **База даних**: SQLite з volume-персистентністю
- **Орхестрація**: Docker Compose v3.8
- **Health Check**: Включено для моніторингу стану

## Структура проєкту

# 🐳 Docker Контейнеризація - Високий рівень

## 📋 Зміст

1. [Архітектура](#архітектура)
2. [Оптимізація](#оптимізація)
3. [Production](#production)
4. [Monitoring](#monitoring)
5. [Troubleshooting](#troubleshooting)

## Архітектура

### Компоненти системи

**Flask Web Application**
- Python 3.11 Alpine
- WSGI сервер для production
- Health checks
- Структурована організація логів
- Обробка помилок

**Nginx Reverse Proxy**
- Load balancing
- SSL/TLS termination
- Compression (gzip)
- Caching статичних файлів
- Security headers

**Backup Service**
- Автоматичний backup SQLite
- Rotation старих файлів
- Логування процесу

### Docker Compose Services

```yaml
web:      Flask додаток (port 5000)
backup:   Backup job (scheduled)
nginx:    Reverse proxy (port 80/443)
```

## Оптимізація

### Розміри образів

```bash
# Production образ
FROM python:3.11-alpine  # ~50MB

# Багатоетапна збірка
# - Builder етап встановлює залежності
# - Production етап копіює лише потрібні файли
# - Результат: ~250-300MB final image
```

### Кешування шарів

- `requirements.txt` копіюється окремо (кешується)
- Код копіюється останнім (часто змінюється)
- Dependencies переусте лише при зміні requirements.txt

### Безпека контейнера

```dockerfile
# Непривілейований користувач
RUN adduser -S appuser -G appgroup
USER appuser

# Read-only файлова система для частини файлів
```

## Production

### Deployment Чек-лист

```bash
# 1. Перевірка конфігурації
docker-compose config

# 2. Збірка образів
docker-compose build

# 3. Запуск
docker-compose up -d

# 4. Перевірка здоров'я
docker-compose ps

# 5. Логи
docker-compose logs web
```

### Restart Policies

```yaml
# unless-stopped: перезапускає крім manual stop
restart: unless-stopped

# Крім того, є: always, on-failure, no
```

### Resource Limits

```yaml
deploy:
  resources:
    limits:
      cpus: '1'      # Max 1 CPU core
      memory: 512M   # Max 512MB RAM
    reservations:
      cpus: '0.5'    # Reserved 0.5 cores
      memory: 256M   # Reserved 256MB
```

## Monitoring

### Health Checks

```bash
# Статус контейнерів
docker ps --format "table {{.Names}}\t{{.Status}}"

# healthy | unhealthy | starting

# Детальна інформація
docker inspect flask_app_prod | jq '.[] | .State.Health'
```

### Логування

```bash
# JSON логи зберігаються на диску
# logs/docker-compose/containers/

# Real-time
docker-compose logs -f

# Фільтрування
docker-compose logs web | grep ERROR
```

## Troubleshooting

### Container exited

```bash
docker-compose logs web  # Див. помилку
docker-compose down      # Очистити
docker-compose build --no-cache  # Перебудувати
```

### Database locked

```bash
# Встановіть timeout
DATABASE_TIMEOUT=30.0

# Або перезавантажте контейнер
docker-compose restart web
```

### Performance issues

```bash
# Моніторинг ресурсів
watch -n 1 'docker stats --no-stream'

# Перевірка дискового простору
docker system df

# Очищення dangling volumes
docker volume prune -a
```

## Run & verify (швидка перевірка після налаштування)

1. Пререквізити
   - Docker (Desktop або Engine) та docker-compose мають бути встановлені:
     - docker --version
     - docker-compose --version

2. Збірка образів
```
docker-compose build
```

3. Запуск (production)
```
docker-compose up -d
```

4. Перевірка стану контейнерів
```
docker-compose ps
# або
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

5. Health check
```
# Показати health-статус контейнера (замініть flask_app_prod на ім'я вашого контейнера)
docker inspect flask_app_prod --format='{{json .State.Health}}' | jq

# або простий запит
curl -sS http://localhost:5000/api/v1/health | jq
```

6. Перевірка nginx (якщо є)
```
# Відкрити у браузері або curl
http://localhost/   # порт 80 проксить на Flask
```

7. Перевірка API (основні ендпоінти)
```
curl -sS http://localhost:5000/api/v1/products | jq
curl -sS http://localhost:5000/api/v1/orders | jq
curl -sS http://localhost:5000/api/v1/feedback | jq
```

8. Персистентність SQLite (практична перевірка)
- Додайте продукт через API або UI.
- Перезапустіть контейнер:
```
docker-compose down
docker-compose up -d
```
- Переконайтесь, що запис залишився (через API або ./data/database.db на хості для bind mount).

9. Backup перевірка
```
# Ручний запуск backup контейнера (якщо налаштовано)
docker-compose run --rm backup

# або виконати скрипт всередині backup контейнера
docker-compose exec backup /bin/sh -c "/app/backup.sh"

# Перевірити директорію backups
ls -la backups/
```

10. Логи і моніторинг
```
docker-compose logs -f web
# або локальні лог-файли
tail -f logs/app.log
```

11. Запуск тестів у контейнері (опціонально)
```
# Увімкніть тестова залежності в образі або виконайте у контейнері dev
docker-compose exec web sh -c "pip install -r requirements-dev.txt && pytest -q"
```

12. Troubleshooting (швидко)
- Контейнер не стартує: docker-compose logs web
- Проблеми з БД: docker-compose exec web ls -la /app/data && sqlite3 /app/data/database.db ".tables"
- Health нездоровий: подивитись logs та endpoint /api/v1/health

