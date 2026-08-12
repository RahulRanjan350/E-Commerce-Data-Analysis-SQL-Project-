# E-Commerce SQL Analysis using PostgreSQL

## Project Overview

This project is an **E-Commerce Data Analysis project built using PostgreSQL and SQL**.

The objective of this project is to analyze customer behavior, orders, products, sales, revenue, payments, reviews, and delivery performance using real-world business questions.

The project starts with basic SQL queries and gradually moves toward **intermediate and advanced SQL concepts**, including joins, aggregations, filtering, `CASE`, `HAVING`, window functions, ranking, `LAG()`, and conditional aggregation using `FILTER`.

The main focus is not only on writing SQL queries but also on using SQL to answer practical **business and analytical questions**.

---

# Project Objectives

The project aims to:

* Analyze customer purchasing behavior
* Identify popular and high-value products
* Analyze sales and revenue
* Compare product categories
* Analyze customer spending
* Segment customers based on spending
* Analyze payment performance
* Study cancelled and returned orders
* Evaluate delivery partner performance
* Analyze product ratings
* Identify high-revenue cities
* Practice advanced SQL and PostgreSQL features

---

# 🛠️ Technologies Used

* **PostgreSQL**
* **SQL**
* **pgAdmin**
* **CSV**
* **Git & GitHub**

---

#  Database Tables

The project contains the following tables:

| Table              | Purpose                                                   |
| ------------------ | --------------------------------------------------------- |
| `customers`        | Customer information such as name, city and state         |
| `orders`           | Customer orders, dates, status and order amount           |
| `order_items`      | Products, quantities, prices and discounts for each order |
| `products`         | Product names, categories, prices and cost prices         |
| `payments`         | Payment methods, payment dates and payment status         |
| `payments_methods` | Payment method reference data                             |
| `delivery`         | Delivery partner, dispatch date and delivery date         |
| `reviews`          | Product ratings and customer reviews                      |

---

#  Database Relationship

The major relationships between the tables are:

```text
Customers
    │
    │ customer_id
    ▼
Orders
    │
    ├──────────────► Payments
    │
    ├──────────────► Delivery
    │
    │ order_id
    ▼
Order_Items
    │
    │ product_id
    ▼
Products
    │
    │ product_id
    ▼
Reviews
```

---

# 📊 SQL Analysis

The project is divided into three levels:

* **Basic SQL**
* **Intermediate SQL**
* **Advanced SQL**

---

#  Basic SQL Analysis

### 1. Display all customers from Delhi

```sql
SELECT *
FROM customers
WHERE city = 'Delhi';
```

### 2. Find all Electronics products

```sql
SELECT *
FROM products
WHERE category = 'Electronics';
```

### 3. Find orders above ₹50,000

```sql
SELECT *
FROM orders
WHERE total_amount > 50000;
```

### 4. Find the 10 most expensive products

```sql
SELECT
    product_name,
    price
FROM products
ORDER BY price DESC
LIMIT 10;
```

### 5. Count customers by state

```sql
SELECT
    state,
    COUNT(customer_id) AS total_customer
FROM customers
GROUP BY state;
```

---

#  Intermediate SQL Analysis

## 6. Analyze completed orders by spending

```sql
SELECT *
FROM orders
WHERE order_status = 'Completed'
ORDER BY total_amount DESC
LIMIT 10;
```

## 7. Monthly revenue for 2024–2025

```sql
SELECT
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(total_amount) AS total_revenue
FROM orders
WHERE order_date BETWEEN '2024-01-01' AND '2025-12-31'
GROUP BY EXTRACT(MONTH FROM order_date)
ORDER BY month;
```

## 8. Average Order Value

The project uses `AVG(total_amount)` to analyze the average order value of customers.

```sql
SELECT
    customer_id,
    order_status,
    SUM(total_amount) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS AOV
FROM orders
GROUP BY customer_id, order_status
ORDER BY customer_id;
```

## 9. Customers with spending above ₹50,000

```sql
SELECT
    customers.customer_id,
    customers.customer_name,
    orders.total_amount
FROM customers
LEFT JOIN orders
    ON customers.customer_id = orders.customer_id
WHERE total_amount > 50000
ORDER BY customers.customer_id;
```

## 10. Top 10 products based on value

```sql
SELECT
    product_name,
    SUM(price) AS total_amount
FROM products
GROUP BY product_name
ORDER BY total_amount DESC
LIMIT 10;
```

## 11. Category-wise quantity and revenue

```sql
SELECT
    category,
    COUNT(product_id) AS total_item_sold,
    SUM(price) AS total_revenue
FROM products
GROUP BY category
ORDER BY total_revenue DESC;
```

## 12. Categories with average discount above 15%

```sql
SELECT
    category,
    ROUND(
        AVG((price - cost_price) / price * 100),
        2
    ) AS discount_percentage
FROM products
GROUP BY category
HAVING AVG((price - cost_price) / price * 100) > 15;
```

## 13. Payment analysis by payment method

```sql
SELECT
    payment_method,
    COUNT(payment_status) AS total_payments
FROM payments
GROUP BY payment_method;
```

## 14. Monthly payment failure/cancellation rate

The project uses PostgreSQL's `FILTER` clause for conditional aggregation.

```sql
SELECT
    TO_CHAR(payment_date, 'Month') AS month,
    ROUND(
        COUNT(*) FILTER (
            WHERE payment_status = 'Failed'
        ) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate
FROM payments
GROUP BY
    EXTRACT(MONTH FROM payment_date),
    TO_CHAR(payment_date, 'Month')
ORDER BY EXTRACT(MONTH FROM payment_date);
```

## 15. Orders delivered in more than 5 days

This analysis is included as part of the delivery-performance section.

## 16. Average delivery time by delivery partner

Since `dispatch_date` and `delivery_date` are stored as PostgreSQL `DATE` values:

```sql
SELECT
    delivery_partner,
    ROUND(
        AVG(delivery_date - dispatch_date),
        2
    ) || ' days' AS average_delivery_days
FROM delivery
GROUP BY delivery_partner;
```

This identifies which delivery partners have faster or slower average delivery times.

---

#  Customer & Product Analysis

## 17. Most popular product in each city

The project joins:

```text
Customers → Orders → Order_Items → Products
```

and calculates total quantity sold.

```sql
SELECT
    customers.city,
    products.product_name,
    SUM(order_items.quantity) AS total_qty
FROM order_items
JOIN products
    ON products.product_id = order_items.product_id
JOIN orders
    ON orders.order_id = order_items.order_id
JOIN customers
    ON customers.customer_id = orders.customer_id
GROUP BY
    customers.city,
    products.product_name;
```

## 18. Customers who ordered in 2024

```sql
SELECT
    customers.customer_name,
    orders.order_date
FROM customers
JOIN orders
    ON customers.customer_id = orders.customer_id
WHERE EXTRACT(YEAR FROM orders.order_date) = 2024;
```

## 19. Customers who ordered in 2024 or 2025

```sql
SELECT
    customers.customer_name,
    orders.order_date
FROM customers
JOIN orders
    ON customers.customer_id = orders.customer_id
WHERE EXTRACT(YEAR FROM orders.order_date) IN (2024, 2025);
```

## 20. One-time customer spending analysis

The project joins customer, order and order-item information to calculate spending.

```sql
SELECT
    customers.customer_id,
    customers.customer_name,
    orders.order_id,
    order_items.product_id,
    order_items.quantity,
    order_items.unit_price * order_items.quantity AS total_spending
FROM customers
JOIN orders
    ON customers.customer_id = orders.customer_id
JOIN order_items
    ON order_items.order_id = orders.order_id;
```

---

# 🔴 Advanced SQL Analysis

## 21. Rank products/categories by revenue

The project uses PostgreSQL window functions such as `RANK()`.

Example:

```sql
SELECT
    products.category,
    ABS(
        SUM(
            order_items.quantity * order_items.unit_price
            - order_items.discount * order_items.unit_price
        )
    ) AS total_revenue,
    RANK() OVER (
        ORDER BY
        ABS(
            SUM(
                order_items.quantity * order_items.unit_price
                - order_items.discount * order_items.unit_price
            )
        ) DESC
    ) AS rank
FROM products
JOIN order_items
    ON order_items.product_id = products.product_id
GROUP BY products.category;
```

---

## 22. Top 3 products in every category

Planned/advanced analysis using window functions such as:

```sql
RANK()
DENSE_RANK()
ROW_NUMBER()
```

---

## 23. Month-over-Month Revenue Growth

Advanced analysis using:

```sql
LAG()
```

to compare current-month revenue with previous-month revenue.

---

## 24. 2024 vs 2025 Revenue and YoY Growth

The project includes year-wise revenue comparison as an advanced analytical extension.

---

## 25. Category Percentage Contribution to Total Revenue

The project uses a window function to calculate the percentage contribution of each category to total revenue.

Concept:

```text
Category Contribution =
Category Revenue / Total Revenue × 100
```

---

# 👤 Customer Analytics

## 26. Total Spending by Customer

Customer spending is calculated by combining:

```text
Customers
      ↓
Orders
      ↓
Order_Items
```

Revenue is calculated using quantity, unit price and discount.

---

## 27. Total Number of Orders per Customer

```sql
SELECT
    customers.customer_id,
    customers.customer_name,
    COUNT(orders.order_id) AS total_order_placed
FROM customers
JOIN orders
    ON customers.customer_id = orders.customer_id
GROUP BY
    customers.customer_id,
    customers.customer_name;
```

---

## 28. Customer Segmentation

Customers can be classified according to their total spending.

### Segmentation Rules

| Segment   |          Spending |
| --------- | ----------------: |
| 🥇 Gold   | ₹50,000 and above |
| 🥈 Silver | ₹20,000 – ₹49,999 |
| 🥉 Bronze |     Below ₹20,000 |

The classification can be implemented using:

```sql
CASE
    WHEN total_spending >= 50000 THEN 'Gold'
    WHEN total_spending >= 20000 THEN 'Silver'
    ELSE 'Bronze'
END
```

---

#  Delivery Analysis

## 29. Average Delivery Time

```sql
SELECT
    delivery_partner,
    ROUND(
        AVG(delivery_date - dispatch_date),
        2
    ) || ' days' AS average_delivery_days
FROM delivery
GROUP BY delivery_partner;
```

This helps compare delivery partners based on average delivery duration.

---

# 💳 Order & Payment Analysis

## 30. Cancelled Orders by Payment Method

Payment and order information can be analyzed to identify cancellation patterns by payment method.

---

#  Product Rating Analysis

## 31. Products with Average Rating Below 3.5

```sql
SELECT
    products.product_name,
    AVG(reviews.rating) AS average_rating
FROM products
JOIN reviews
    ON products.product_id = reviews.product_id
GROUP BY products.product_name
HAVING AVG(reviews.rating) < 3.5;
```

This uses:

* `JOIN`
* `AVG()`
* `GROUP BY`
* `HAVING`

to identify products with lower customer ratings.

---

# ❌ Cancelled & Returned Orders

## 32. Customers with Cancelled or Returned Orders

```sql
SELECT
    customers.customer_name,
    orders.order_status
FROM customers
JOIN orders
    ON customers.customer_id = orders.customer_id
WHERE orders.order_status IN ('Cancelled', 'Returned');
```

This helps identify customers affected by cancelled or returned orders.

---

# 🏙️ City Revenue Analysis

## 33. Revenue Generated by City

Revenue is calculated using quantity, unit price and discount.

```sql
SELECT
    customers.state,
    customers.city,
    ABS(
        SUM(
            (order_items.quantity * order_items.unit_price)
            * (1 - COALESCE(order_items.discount, 0))
        )
    ) AS revenue
FROM customers
JOIN orders
    ON customers.customer_id = orders.customer_id
JOIN order_items
    ON orders.order_id = order_items.order_id
GROUP BY
    customers.state,
    customers.city
ORDER BY revenue DESC;
```

This analysis helps identify high-performing cities and states.

---

# 📋 34. Management Summary

The final stage of the project is designed to provide a management-level summary containing important business KPIs such as:

*  Total Customers
*  Total Orders
*  Completed Orders
*  Cancelled Orders
*  Total Revenue
*  Average Order Value (AOV)
*  Average Product Rating
*  Average Delivery Time

These metrics provide a high-level overview of overall business performance.

---

#  Revenue Calculation

For order-item level analysis, revenue is calculated using:

```text
Revenue =
Quantity × Unit Price
−
Discount Amount
```

or, when discount is stored as a percentage:

```text
Revenue =
Quantity × Unit Price × (1 − Discount)
```

This revenue calculation is used for product, category, customer and city-level analysis.

---

# 🧠 SQL Concepts Practiced

This project provided practical experience with:

### Basic SQL

* `SELECT`
* `WHERE`
* `ORDER BY`
* `LIMIT`
* `DISTINCT`

### Aggregation

* `COUNT()`
* `SUM()`
* `AVG()`
* `MIN()`
* `MAX()`

### Grouping

* `GROUP BY`
* `HAVING`

### Joins

* `INNER JOIN`
* `LEFT JOIN`

### Conditional Logic

* `CASE`
* `WHEN`
* `THEN`
* `ELSE`

### Conditional Aggregation

```sql
FILTER (WHERE condition)
```

### Window Functions

* `RANK()`
* `DENSE_RANK()`
* `ROW_NUMBER()`
* `LAG()`

### Date Functions

* `EXTRACT()`
* `TO_CHAR()`
* Date subtraction
* Date filtering

### Advanced SQL

* Subqueries
* Common Table Expressions (CTEs)
* Window functions
* Conditional aggregation

---

#  Project Structure

```text
ecommerce-sql-analysis/
│
├── README.md
│
├── data/
│   ├── customers.csv
│   ├── products.csv
│   ├── orders.csv
│   ├── order_items.csv
│   ├── payments.csv
│   ├── delivery.csv
│   ├── reviews.csv
│   └── payments_methods.csv
│
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_import_data.sql
│   ├── 03_basic_analysis.sql
│   ├── 04_intermediate_analysis.sql
│   └── 05_advanced_analysis.sql
│
└── screenshots/
    ├── database_schema.png
    ├── customer_analysis.png
    ├── product_analysis.png
    ├── revenue_analysis.png
    └── delivery_analysis.png
```

---

#  How to Run the Project

## 1. Create the Database

Create a PostgreSQL database:

```sql
CREATE DATABASE ecommerce_analysis;
```

## 2. Create the Tables

Run the table creation SQL script.

## 3. Import the CSV Files

Import the CSV files into their respective tables.

Example:

```sql
COPY order_items
FROM 'path/to/order_items.csv'
WITH (FORMAT csv, HEADER true);
```

> Update the file path according to your local system.

## 4. Run the Analysis

Execute the SQL files from the `sql` folder in PostgreSQL/pgAdmin.

---

# 📸 Project Screenshots

Important query outputs and database screenshots can be stored in the `screenshots` folder.

Recommended screenshots:

1. Database schema
2. Customer segmentation
3. Revenue analysis
4. Product analysis
5. Delivery partner analysis
6. Management summary

---

# 📈 Business Insights

The analysis is designed to help answer questions such as:

* Which customers generate the most revenue?
* Which products sell the most?
* Which product categories perform best?
* Which cities generate the highest revenue?
* Which delivery partner is fastest?
* Which payment methods have higher failure/cancellation rates?
* Which products have poor customer ratings?
* How many customers have cancelled or returned orders?
* Which customers belong to high-value segments?

---

# 🔮 Future Improvements

The project can be extended with:

* 📊 **Power BI Dashboard**
* 🐍 **Python + Pandas Analysis**
* 📈 Sales forecasting
* 👥 Advanced RFM analysis
* 🔄 Customer retention analysis
* 📅 Customer cohort analysis
* 💰 Advanced Customer Lifetime Value prediction
* 🤖 Machine Learning-based customer segmentation

---

# 👨‍💻 Author

## Rahul Kumar

**SQL | PostgreSQL | Data Analytics | Python**

This project is part of my practical portfolio focused on developing strong skills in **SQL, PostgreSQL, Data Analytics and Python Development**.

---

#  Conclusion

This E-Commerce SQL project demonstrates the practical use of PostgreSQL to analyze **customers, orders, products, revenue, payments, reviews and delivery operations**.

The project progresses from basic SQL queries to more advanced analytical techniques such as **window functions, ranking, conditional aggregation, date analysis and revenue calculations**.

The main objective is to demonstrate the ability to convert **business questions into SQL queries and meaningful analytical insights**.

---

## 🔗 Project Repository

**GitHub:**

https://github.com/RahulRanjan350/E-Commerce-Data-Analysis-SQL-Project-/edit/main/README.md

---

