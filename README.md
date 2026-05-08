# Ecomart API 🛒

A robust, high-performance E-Commerce REST API backend built with Ruby on Rails. Designed with a clean relational schema, it features token-based stateless authentication (JWT), secure password hashing (BCrypt), and an incredibly efficient multi-core database seeding architecture.

## 🛠 Tech Stack

- **Ruby version:** >= 3.2.0
- **Framework:** Ruby on Rails (~> 8.1.2)
- **Database:** PostgreSQL
- **Security:** `bcrypt` (~> 3.1.7) & `jwt` (~> 2.9.0)

## 📦 Setting Up the Application

### 1. Installation

Ensure you have Ruby and PostgreSQL installed. Then, configure your dependencies:

```bash
# Install the necessary gems into the project environment
bundle install
```

### 2. Database Initialization

Drop any legacy configurations and create your database entirely from scratch:

```bash
# Create the database and apply migrations
rails db:create db:migrate
```

### 3. Ultra-Fast Parallel Seeding

The provided `seeds.rb` file is designed to brutally stress-test the schema. It spawns independent background processes across your CPU's available cores to slam data into PostgreSQL concurrently.

```bash
# Will generate 10k Users, 100k Products, 1M Orders, and 2.5M Order Items.
rails db:seed
```

## 🛣 Core API Endpoints

### Authentication

- `POST /auth/register` - Creates a new user and returns a token.
- `POST /auth/login` - Authenticates user credentials and returns a token.

_(Pass the returned token in the `Authorization: Bearer <token>` header for protected routes)._

### Users

- `GET /users` - Retrieve a list of users
- `GET /users/:id` - Retrieve a specific user
- `PUT /users/:id` - Update user information
- `DELETE /users/:id` - Delete a user

### Products

- `GET /products` - Retrieve all products
- `GET /products/:id` - Retrieve a specific product
- `POST /products` - Create a new product
- `PUT /products/:id` - Update a product
- `DELETE /products/:id` - Delete a product

### Orders

_(Protected endpoints: Require `Authorization: Bearer <token>`)_

- `GET /orders` - Retrieve list of orders for the authenticated user
- `GET /orders/:id` - Retrieve a specific order
- `POST /orders` - Create a new order
- `PUT /orders/:id` - Update an order's status
- `DELETE /orders/:id` - Delete a specified order

### Order Items

- `GET /order_items` - Retrieve all order items
- `GET /order_items/:id` - Retrieve a specific order item
- `POST /order_items` - Add an item to an order
- `PUT /order_items/:id` - Update item quantity or details
- `DELETE /order_items/:id` - Remove an item from an order

### Payments

- `GET /payments` - Retrieve payment records
- `GET /payments/:id` - Retrieve a specific payment
- `POST /payments` - Process a new payment for an order
- `PUT /payments/:id` - Update payment status
- `DELETE /payments/:id` - Remove a payment record
