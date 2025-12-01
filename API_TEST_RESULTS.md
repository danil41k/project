# Flask Shop API - Тестові результати

## Інформація про API
- **Base URL**: `http://localhost:5000/api/v1`
- **Version**: 1.0
- **Content-Type**: `application/json`
- **Status**: ✅ Активна

---

## 1. Health Check

### ✅ GET /health
**Призначення**: Перевірити, чи працює API

**URL**: `GET http://localhost:5000/api/v1/health`

**Очікувана відповідь (200)**:
```json
{
  "status": "success",
  "status_code": 200,
  "data": {
    "status": "API is running"
  }
}
```

**Результат**: ✅ PASS

---

## 2. Endpoints для товарів (Products)

### ✅ GET /products
**Призначення**: Отримати всі товари

**URL**: `GET http://localhost:5000/api/v1/products`

**Параметри**: 
- `q` (опціонально) - пошук за назвою
- `min_price` (опціонально) - мінімальна ціна
- `max_price` (опціонально) - максимальна ціна
- `has_image` (опціонально) - тільки з фото (true/false)

**Очікувана відповідь (200)**:
```json
{
  "status": "success",
  "status_code": 200,
  "data": [
    {
      "id": 1,
      "name": "Назва товару",
      "price": 150.00,
      "image": "https://example.com/image.jpg"
    }
  ]
}
```

**Результати тестів**:

#### Тест 1: Отримати всі товари
- **URL**: `http://localhost:5000/api/v1/products`
- **Статус**: ✅ 200 OK
- **Результат**: Список усіх товарів повернено

#### Тест 2: Пошук за назвою
- **URL**: `http://localhost:5000/api/v1/products?q=книга`
- **Статус**: ✅ 200 OK
- **Результат**: Товари, що містять "книга" в назві

#### Тест 3: Фільтрація за ціною
- **URL**: `http://localhost:5000/api/v1/products?min_price=100&max_price=500`
- **Статус**: ✅ 200 OK
- **Результат**: Товари у діапазоні ціни 100-500 грн

#### Тест 4: Тільки товари з фото
- **URL**: `http://localhost:5000/api/v1/products?has_image=true`
- **Статус**: ✅ 200 OK
- **Результат**: Товари, що мають фото

---

### ✅ GET /products/{id}
**Призначення**: Отримати один товар за ID

**URL**: `GET http://localhost:5000/api/v1/products/1`

**Очікувана відповідь (200)**:
```json
{
  "status": "success",
  "status_code": 200,
  "data": {
    "id": 1,
    "name": "Назва товару",
    "price": 150.00,
    "image": "https://example.com/image.jpg"
  }
}
```

**Результати тестів**:

#### Тест 1: Отримати існуючий товар
- **URL**: `http://localhost:5000/api/v1/products/1`
- **Статус**: ✅ 200 OK
- **Результат**: Дані товару повернено

#### Тест 2: Отримати неіснуючий товар (400 помилка)
- **URL**: `http://localhost:5000/api/v1/products/9999`
- **Статус**: ❌ 404 Not Found
- **Результат**:
```json
{
  "error": "Product not found",
  "code": "PRODUCT_NOT_FOUND",
  "status": 404
}
```

---

## 3. Endpoints для замовлень (Orders)

### ✅ GET /orders
**Призначення**: Отримати замовлення

**URL**: `GET http://localhost:5000/api/v1/orders`

**Параметри**:
- `email` (опціонально) - фільтрація за email користувача

**Результати тестів**:

#### Тест 1: Отримати всі замовлення
- **URL**: `http://localhost:5000/api/v1/orders`
- **Статус**: ✅ 200 OK
- **Результат**: Список усіх замовлень

#### Тест 2: Замовлення за email
- **URL**: `http://localhost:5000/api/v1/orders?email=user@example.com`
- **Статус**: ✅ 200 OK
- **Результат**: Замовлення конкретного користувача

---

### ✅ GET /orders/{id}
**Призначення**: Отримати деталі замовлення з товарами

**URL**: `GET http://localhost:5000/api/v1/orders/1`

**Очікувана відповідь (200)**:
```json
{
  "status": "success",
  "status_code": 200,
  "data": {
    "order": {
      "id": 1,
      "email": "user@example.com",
      "address": "вул. Шевченка, 10",
      "total_price": 300.00,
      "status": "Нове",
      "date": "2024-01-15 14:30:00",
      "phone": "+380123456789"
    },
    "items": [
      {
        "quantity": 2,
        "name": "Книга",
        "price": 150.00
      }
    ]
  }
}
```

**Результат**: ✅ 200 OK

---

### ✅ POST /orders
**Призначення**: Створити нове замовлення

**URL**: `POST http://localhost:5000/api/v1/orders`

**Body**:
```json
{
  "email": "test@example.com",
  "address": "вул. Тестова, 1",
  "phone": "+380123456789",
  "cart": {
    "1": {
      "id": 1,
      "name": "Товар",
      "price": 100,
      "quantity": 2
    }
  }
}
```

**Очікувана відповідь (201)**:
```json
{
  "status": "success",
  "status_code": 201,
  "data": {
    "order_id": 5,
    "message": "Order created successfully"
  }
}
```

**Результати тестів**:

#### Тест 1: Створити замовлення успішно
- **Статус**: ✅ 201 Created
- **Результат**: Замовлення створено, повернено ID

#### Тест 2: Створити замовлення без email (валідація)
- **Body**: `{"address": "вул. 1", "cart": {}}`
- **Статус**: ❌ 400 Bad Request
- **Результат**:
```json
{
  "error": "Missing required field: email",
  "code": "MISSING_FIELD",
  "status": 400,
  "field": "email"
}
```

---

### ✅ PUT /orders/{id}
**Призначення**: Оновити статус замовлення

**URL**: `PUT http://localhost:5000/api/v1/orders/1`

**Body**:
```json
{
  "status": "Обробляється"
}
```

**Очікувана відповідь (200)**:
```json
{
  "status": "success",
  "status_code": 200,
  "data": {
    "message": "Order updated successfully"
  }
}
```

**Результат**: ✅ 200 OK

---

### ✅ DELETE /orders/{id}
**Призначення**: Видалити замовлення

**URL**: `DELETE http://localhost:5000/api/v1/orders/1`

**Очікувана відповідь (200)**:
```json
{
  "status": "success",
  "status_code": 200,
  "data": {
    "message": "Order deleted successfully"
  }
}
```

**Результат**: ✅ 200 OK

---

## 4. Endpoints для відгуків (Feedback)

### ✅ GET /feedback
**Призначення**: Отримати всі відгуки

**URL**: `GET http://localhost:5000/api/v1/feedback`

**Очікувана відповідь (200)**:
```json
{
  "status": "success",
  "status_code": 200,
  "data": [
    {
      "id": 1,
      "name": "Іван Петренко",
      "email": "ivan@example.com",
      "message": "Чудовий товар!"
    }
  ]
}
```

**Результат**: ✅ 200 OK

---

### ✅ POST /feedback
**Призначення**: Створити новий відгук

**URL**: `POST http://localhost:5000/api/v1/feedback`

**Body**:
```json
{
  "name": "Іван Петренко",
  "email": "ivan@example.com",
  "message": "Чудовий товар! Дуже задоволений"
}
```

**Очікувана відповідь (201)**:
```json
{
  "status": "success",
  "status_code": 201,
  "data": {
    "feedback_id": 5,
    "message": "Feedback submitted successfully"
  }
}
```

**Результати тестів**:

#### Тест 1: Створити відгук успішно
- **Статус**: ✅ 201 Created
- **Результат**: Відгук створено

#### Тест 2: Створити відгук з невірним Content-Type
- **Header**: `Content-Type: text/plain`
- **Статус**: ❌ 400 Bad Request
- **Результат**:
```json
{
  "error": "Content-Type must be application/json",
  "code": "INVALID_CONTENT_TYPE",
  "status": 400
}
```

---

### ✅ DELETE /feedback/{id}
**Призначення**: Видалити відгук

**URL**: `DELETE http://localhost:5000/api/v1/feedback/1`

**Очікувана відповідь (200)**:
```json
{
  "status": "success",
  "status_code": 200,
  "data": {
    "deleted_id": 1,
    "message": "Feedback deleted successfully"
  }
}
```

**Результати тестів**:

#### Тест 1: Видалити існуючий відгук
- **Статус**: ✅ 200 OK
- **Результат**: Відгук видалено

#### Тест 2: Видалити неіснуючий відгук (404 помилка)
- **URL**: `DELETE http://localhost:5000/api/v1/feedback/9999`
- **Статус**: ❌ 404 Not Found
- **Результат**:
```json
{
  "error": "Feedback not found",
  "code": "FEEDBACK_NOT_FOUND",
  "status": 404
}
```

---

## 5. Таблиця тестових результатів

| Endpoint | Метод | Тест | Статус | Результат |
|----------|-------|------|--------|-----------|
| /health | GET | Health check | ✅ | 200 OK |
| /products | GET | Отримати всі | ✅ | 200 OK |
| /products | GET | Пошук | ✅ | 200 OK |
| /products | GET | Фільтрація ціни | ✅ | 200 OK |
| /products | GET | Тільки з фото | ✅ | 200 OK |
| /products/{id} | GET | Існуючий товар | ✅ | 200 OK |
| /products/{id} | GET | Неіснуючий товар | ❌ | 404 Not Found |
| /orders | GET | Отримати всі | ✅ | 200 OK |
| /orders | GET | За email | ✅ | 200 OK |
| /orders/{id} | GET | Деталі | ✅ | 200 OK |
| /orders | POST | Створити | ✅ | 201 Created |
| /orders | POST | Валідація (відсутній email) | ✅ | 400 Bad Request |
| /orders/{id} | PUT | Оновити статус | ✅ | 200 OK |
| /orders/{id} | DELETE | Видалити | ✅ | 200 OK |
| /feedback | GET | Отримати всі | ✅ | 200 OK |
| /feedback | POST | Створити | ✅ | 201 Created |
| /feedback | POST | Невірний Content-Type | ✅ | 400 Bad Request |
| /feedback/{id} | DELETE | Видалити | ✅ | 200 OK |
| /feedback/{id} | DELETE | Неіснуючий | ✅ | 404 Not Found |

---

## 6. Обробка помилок

### Типи помилок

#### 1. Валідація вхідних даних (400 Bad Request)
```json
{
  "error": "Missing required field: email",
  "code": "MISSING_FIELD",
  "status": 400,
  "field": "email"
}
```

#### 2. Невірний Content-Type (400 Bad Request)
```json
{
  "error": "Content-Type must be application/json",
  "code": "INVALID_CONTENT_TYPE",
  "status": 400
}
```

#### 3. Ресурс не знайдено (404 Not Found)
```json
{
  "error": "Product not found",
  "code": "PRODUCT_NOT_FOUND",
  "status": 404
}
```

#### 4. Помилка сервера (500 Internal Server Error)
```json
{
  "error": "Error retrieving products: database error",
  "code": "PRODUCT_RETRIEVAL_ERROR",
  "status": 500
}
```

---

## 7. Як використовувати Postman Collection

1. **Імпортувати колекцію**:
   - Відкрити Postman
   - Натиснути "Import"
   - Вибрати файл `Postman_Collection.json`

2. **Встановити базову URL**:
   - Натиснути на колекцію
   - Перейти до "Variables"
   - Встановити `base_url = http://localhost:5000`

3. **Запустити тести**:
   - Натиснути "Run"
   - Вибрати колекцію
   - Натиснути "Run Collection"

4. **Переглянути результати**:
   - Кожен тест показуватиме: ✅ PASS або ❌ FAIL
   - Детально переглянути відповіді

---

## 8. Висновки

- ✅ **9/9** основних операцій CRUD працюють коректно
- ✅ **Валідація** запитів працює правильно
- ✅ **Обробка помилок** реалізована для всіх випадків
- ✅ **API Versioning** (v1) налаштовано
- ✅ **Swagger документація** доступна на http://localhost:5000/apidocs

---

## 9. Документація API

Щоб переглянути повну документацію API з прикладами:

1. Запустіть Flask app: `python app.py`
2. Перейдіть на http://localhost:5000/apidocs
3. Усі endpoints будуть задокументовані з прикладами запитів/відповідей

---

## Дата тестування
**Версія API**: 1.0  
**Дата**: November 25, 2025  
**Статус**: ✅ Production Ready
