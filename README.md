This is a simple Todo List API built in Ruby on Rails 7. This project is currently being used for Ruby full-stack candidates.

## Build

To build the application:

`bin/setup`

## Run seeds

`rails db:seed`

## Run

To run the TodoApi in your local environment:

`bin/puma`

## Test

To run tests:

`bin/rspec`

## Web Implementation

### Authentication & User Management

The application uses [Devise](https://github.com/heartcombo/devise) for user authentication and management, providing:
- User registration and login
- Password recovery
- Session management
- Account confirmation via email
- Secure password handling

### Frontend Technologies

#### CSS Framework
- **Bootstrap 5**
  ```html
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
  ```

#### Icons
- **Font Awesome 6**
  ```html
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" integrity="sha512-Evv84Mr4kqVGRNSgIGL/F/aIDqQb7xQ2vcrdIwxfjThSH8CSR7PBEakCr51Ck+w+/U6swU2Im1vVX0SVk9ABhg==" crossorigin="anonymous" referrerpolicy="no-referrer" />
  ```

### Real-time Updates

The application uses Turbo Streams for real-time updates, enabling:
- Live updates for todo lists and items
- Instant UI updates without page refreshes
- Enhanced user experience with dynamic content

## API Documentation

This API allows you to manage todo lists and their items. All responses are in JSON format.

All index endpoints use Kaminari for pagination with the following query parameters:
- `page` (optional): Page number (default: 1)
- `per_page` (optional): Items per page (default: 10)

Example: `?page=1&per_page=5`

## Todo Lists

### List Todo Lists

Retrieves a paginated list of todo lists.

```http
GET /api/todolists?page=1&per_page=1
```

#### Response

```json
{
  "todo_lists": [
    {
      "id": 1,
      "name": "Shopping List",
      "created_at": "2024-03-21T10:00:00.000Z",
      "updated_at": "2024-03-21T10:00:00.000Z"
    }
  ],
  "total_pages": 1,
  "current_page": 1,
  "total_count": 1
}
```

### Get Single Todo List

Retrieves a specific todo list by ID.

```http
GET /api/todolists/:id
```

#### Response

```json
{
  "id": 1,
  "name": "Shopping List",
  "created_at": "2024-03-21T10:00:00.000Z",
  "updated_at": "2024-03-21T10:00:00.000Z"
}
```

### Create Todo List

Creates a new todo list.

```http
POST /api/todolists
```

#### Request Body

```json
{
  "todo_list": {
    "name": "New Todo List"
  }
}
```

#### Response

```json
{
  "msg": "Todo list created successfully",
  "todo_list": {
    "id": 1,
    "name": "New Todo List",
    "created_at": "2024-03-21T10:00:00.000Z",
    "updated_at": "2024-03-21T10:00:00.000Z"
  }
}
```

### Update Todo List

Updates an existing todo list.

```http
PATCH/PUT /api/todolists/:id
```

#### Request Body

```json
{
  "todo_list": {
    "name": "Updated List Name"
  }
}
```

#### Response

```json
{
  "msg": "Todo list updated successfully",
  "todo_list": {
    "id": 1,
    "name": "Updated List Name",
    "created_at": "2024-03-21T10:00:00.000Z",
    "updated_at": "2024-03-21T10:00:00.000Z"
  }
}
```

### Delete Todo List

Deletes a todo list.

```http
DELETE /api/todolists/:id
```

#### Response

```json
{
  "msg": "Todo list deleted successfully"
}
```

## Todo Items

### List Items

Retrieves a paginated list of items in a todo list.

```http
GET /api/todolists/:todo_list_id/todos
```

#### Response

```json
{
  "items": [
    {
      "id": 1,
      "title": "Buy groceries",
      "description": "Get milk and eggs",
      "todo_list_id": 1,
      "created_at": "2024-03-21T10:00:00.000Z",
      "updated_at": "2024-03-21T10:00:00.000Z"
    }
  ],
  "total_pages": 5,
  "current_page": 1,
  "total_count": 47
}
```

### Get Single Item

Retrieves a specific item from a todo list.

```http
GET /api/todolists/:todo_list_id/todos/:id
```

#### Response

```json
{
  "item": {
    "id": 1,
    "title": "Buy groceries",
    "description": "Get milk and eggs",
    "todo_list_id": 1,
    "created_at": "2024-03-21T10:00:00.000Z",
    "updated_at": "2024-03-21T10:00:00.000Z"
  }
}
```

### Create Item

Creates a new item in a todo list.

```http
POST /api/todolists/:todo_list_id/todos
```

#### Request Body

```json
{
  "item": {
    "title": "New Task",
    "description": "Task description"
  }
}
```

#### Response

```json
{
  "msg": "Item created successfully",
  "item": {
    "id": 1,
    "title": "New Task",
    "description": "Task description",
    "todo_list_id": 1,
    "created_at": "2024-03-21T10:00:00.000Z",
    "updated_at": "2024-03-21T10:00:00.000Z"
  }
}
```

### Update Item

Updates an existing item in a todo list.

```http
PATCH/PUT /api/todolists/:todo_list_id/todos/:id
```

#### Request Body

```json
{
  "item": {
    "title": "Updated Task",
    "description": "Updated description"
  }
}
```

#### Response

```json
{
  "msg": "Item updated successfully",
  "item": {
    "id": 1,
    "title": "Updated Task",
    "description": "Updated description",
    "todo_list_id": 1,
    "created_at": "2024-03-21T10:00:00.000Z",
    "updated_at": "2024-03-21T10:00:00.000Z"
  }
}
```

### Delete Item

Deletes an item from a todo list.

```http
DELETE /api/todolists/:todo_list_id/todos/:id
```

#### Response

```json
{
  "msg": "Item deleted successfully"
}
```

## Error Responses

The API uses conventional HTTP response codes to indicate the success or failure of requests.

### Not Found (404)

Returned when the requested resource doesn't exist.

```json
{
  "error": "Todo list not found"
}
```

or

```json
{
  "error": "Item not found"
}
```

### Validation Error (422)

Returned when the request data fails validation.

```json
{
  "errors": [
    "Name can't be blank"
  ]
}
```
