# E-Commerce SQL Analysis using PostgreSQL

An E-Commerce data analysis project built with PostgreSQL. It answers business questions on customers, orders, products, revenue, payments, delivery and reviews, moving from basic queries to advanced SQL (joins, `CASE`, `HAVING`, `FILTER`, CTEs and window functions such as `RANK()` and `LAG()`).

**Tools:** PostgreSQL, SQL, pgAdmin, CSV, Git and GitHub

---

## Project objectives

- Analyse customer purchasing behaviour and segment customers by spending
- Find popular and high-revenue products and categories
- Track monthly and yearly revenue and growth
- Measure payment failures, cancelled and returned orders
- Compare delivery partners
- Find poorly rated products and high-revenue cities
- Summarise business KPIs in one management query

---

## Database tables

| Table | Purpose |
| --- | --- |
| `customers` | Customer name, city and state |
| `orders` | Orders with date, status and total amount |
| `order_items` | Products, quantity, unit price and discount for each order |
| `products` | Product name, category, price and cost price |
| `payments` | Payment method, date and status |
| `payments_methods` | Payment method reference data |
| `delivery` | Delivery partner, dispatch date and delivery date |
| `reviews` | Product ratings and reviews |

**Relationships**

```text
customers --(customer_id)--> orders --(order_id)--> order_items --(product_id)--> products --(product_id)--> reviews
                               |
                               +--> payments
                               +--> delivery
```

**ERD:** [add your schema image, for example `![ERD](screenshots/database_schema.png)`]

---

## Revenue calculation

All item-level revenue (products, categories, customers, cities) uses:

```text
Revenue = quantity x unit_price x (1 - discount)
```

where `discount` is stored as a fraction (for example 0.10 for 10%). [If your `discount` column holds an amount instead, use `quantity x unit_price - discount`, and change the queries below to match.]

---

## SQL analysis

### Basic

**1. Customers from Delhi**
```sql
SELECT * FROM customers WHERE city = 'Delhi';
```

**2. All Electronics products**
```sql
SELECT * FROM products WHERE category = 'Electronics';
```

**3. Orders above 50,000**
```sql
SELECT * FROM orders WHERE total_amount > 50000;
```

**4. The 10 most expensive products**
```sql
SELECT product_name, price
FROM products
ORDER BY price DESC
LIMIT 10;
```

**5. Customers by state**
```sql
SELECT state, COUNT(customer_id) AS total_customers
FROM customers
GROUP BY state;
```

### Intermediate

**6. Top 10 completed orders by amount**
```sql
SELECT *
FROM orders
WHERE order_status = 'Completed'
ORDER BY total_amount DESC
LIMIT 10;
```

**7. Monthly revenue for 2024 and 2025**
```sql
SELECT EXTRACT(YEAR FROM order_date)  AS year,
       EXTRACT(MONTH FROM order_date) AS month,
       SUM(total_amount)              AS total_revenue
FROM orders
WHERE order_date BETWEEN '2024-01-01' AND '2025-12-31'
GROUP BY 1, 2
ORDER BY 1, 2;
```

**8. Average order value (AOV) per customer (completed orders)**
```sql
SELECT customer_id,
       COUNT(order_id)               AS total_orders,
       SUM(total_amount)             AS total_revenue,
       ROUND(AVG(total_amount), 2)   AS aov
FROM orders
WHERE order_status = 'Completed'
GROUP BY customer_id
ORDER BY total_revenue DESC;
```

**9. Customers with total spending above 50,000**
```sql
SELECT c.customer_id, c.customer_name, SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.total_amount) > 50000
ORDER BY total_spent DESC;
```

**10. Top 10 products by revenue**
```sql
SELECT p.product_name,
       SUM(oi.quantity * oi.unit_price * (1 - COALESCE(oi.discount, 0))) AS revenue
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 10;
```

**11. Units sold and revenue by category**
```sql
SELECT p.category,
       SUM(oi.quantity) AS total_units_sold,
       SUM(oi.quantity * oi.unit_price * (1 - COALESCE(oi.discount, 0))) AS total_revenue
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;
```

**12. Categories with an average profit margin above 15%**
```sql
SELECT category,
       ROUND(AVG((price - cost_price) / price * 100), 2) AS avg_margin_percent
FROM products
GROUP BY category
HAVING AVG((price - cost_price) / price * 100) > 15;
```

**13. Payments by payment method**
```sql
SELECT payment_method, COUNT(*) AS total_payments
FROM payments
GROUP BY payment_method
ORDER BY total_payments DESC;
```

**14. Monthly payment failure rate (using `FILTER`)**
```sql
SELECT TRIM(TO_CHAR(payment_date, 'Month')) AS month,
       ROUND(COUNT(*) FILTER (WHERE payment_status = 'Failed') * 100.0 / COUNT(*), 2) AS failure_rate_percent
FROM payments
GROUP BY EXTRACT(MONTH FROM payment_date), TRIM(TO_CHAR(payment_date, 'Month'))
ORDER BY EXTRACT(MONTH FROM payment_date);
```

**15. Orders delivered in more than 5 days**
```sql
SELECT o.order_id,
       d.delivery_partner,
       d.delivery_date - d.dispatch_date AS delivery_days
FROM delivery d
JOIN orders o ON o.order_id = d.order_id
WHERE d.delivery_date - d.dispatch_date > 5
ORDER BY delivery_days DESC;
```

**16. Average delivery time by delivery partner**
```sql
SELECT delivery_partner,
       ROUND(AVG(delivery_date - dispatch_date), 2) AS avg_delivery_days
FROM delivery
GROUP BY delivery_partner
ORDER BY avg_delivery_days;
```

### Customer and product analysis

**17. Most popular product in each city**
```sql
WITH city_product AS (
    SELECT c.city,
           p.product_name,
           SUM(oi.quantity) AS total_qty,
           RANK() OVER (PARTITION BY c.city ORDER BY SUM(oi.quantity) DESC) AS rnk
    FROM order_items oi
    JOIN products  p ON p.product_id = oi.product_id
    JOIN orders    o ON o.order_id   = oi.order_id
    JOIN customers c ON c.customer_id = o.customer_id
    GROUP BY c.city, p.product_name
)
SELECT city, product_name, total_qty
FROM city_product
WHERE rnk = 1;
```

**18. Customers who ordered in 2024 or 2025**
```sql
SELECT DISTINCT c.customer_id, c.customer_name
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE EXTRACT(YEAR FROM o.order_date) IN (2024, 2025);
```

**19. Customers with only one order, and what they spent**
```sql
SELECT c.customer_id,
       c.customer_name,
       SUM(oi.quantity * oi.unit_price * (1 - COALESCE(oi.discount, 0))) AS total_spending
FROM customers c
JOIN orders o       ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.order_id) = 1
ORDER BY total_spending DESC;
```

### Advanced

**20. Rank categories by revenue**
```sql
SELECT p.category,
       SUM(oi.quantity * oi.unit_price * (1 - COALESCE(oi.discount, 0))) AS total_revenue,
       RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price * (1 - COALESCE(oi.discount, 0))) DESC) AS revenue_rank
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.category;
```

**21. Top 3 products in every category**
```sql
WITH product_revenue AS (
    SELECT p.category,
           p.product_name,
           SUM(oi.quantity * oi.unit_price * (1 - COALESCE(oi.discount, 0))) AS revenue
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    GROUP BY p.category, p.product_name
),
ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM product_revenue
)
SELECT category, product_name, revenue
FROM ranked
WHERE rn <= 3
ORDER BY category, rn;
```

**22. Month-over-month revenue growth (using `LAG()`)**
```sql
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date AS month,
           SUM(total_amount) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY 1
)
SELECT month,
       revenue,
       LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0
             / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 2) AS mom_growth_percent
FROM monthly
ORDER BY month;
```

**23. 2024 vs 2025 revenue and year-over-year growth**
```sql
WITH yearly AS (
    SELECT EXTRACT(YEAR FROM order_date)::int AS year,
           SUM(total_amount) AS revenue
    FROM orders
    WHERE EXTRACT(YEAR FROM order_date) IN (2024, 2025)
    GROUP BY 1
)
SELECT year,
       revenue,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY year)) * 100.0
             / NULLIF(LAG(revenue) OVER (ORDER BY year), 0), 2) AS yoy_growth_percent
FROM yearly
ORDER BY year;
```

**24. Each category's share of total revenue**
```sql
SELECT p.category,
       SUM(oi.quantity * oi.unit_price * (1 - COALESCE(oi.discount, 0))) AS category_revenue,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - COALESCE(oi.discount, 0))) * 100.0
             / SUM(SUM(oi.quantity * oi.unit_price * (1 - COALESCE(oi.discount, 0)))) OVER (), 2) AS contribution_percent
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY contribution_percent DESC;
```

### Customer analytics

**25. Orders per customer**
```sql
SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_orders DESC;
```

**26. Customer segmentation by total spending**

| Segment | Total spending |
| --- | --- |
| Gold | 50,000 and above |
| Silver | 20,000 to 49,999 |
| Bronze | below 20,000 |

```sql
WITH customer_spend AS (
    SELECT c.customer_id,
           c.customer_name,
           SUM(oi.quantity * oi.unit_price * (1 - COALESCE(oi.discount, 0))) AS total_spending
    FROM customers c
    JOIN orders o       ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id   = o.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id,
       customer_name,
       total_spending,
       CASE
           WHEN total_spending >= 50000 THEN 'Gold'
           WHEN total_spending >= 20000 THEN 'Silver'
           ELSE 'Bronze'
       END AS segment
FROM customer_spend
ORDER BY total_spending DESC;
```

### Orders, payments and ratings

**27. Cancelled orders by payment method**
```sql
SELECT p.payment_method, COUNT(*) AS cancelled_orders
FROM orders o
JOIN payments p ON p.order_id = o.order_id
WHERE o.order_status = 'Cancelled'
GROUP BY p.payment_method
ORDER BY cancelled_orders DESC;
```

**28. Products with an average rating below 3.5**
```sql
SELECT p.product_name, ROUND(AVG(r.rating), 2) AS average_rating
FROM products p
JOIN reviews r ON r.product_id = p.product_id
GROUP BY p.product_name
HAVING AVG(r.rating) < 3.5
ORDER BY average_rating;
```

**29. Cancelled and returned orders per customer**
```sql
SELECT c.customer_id,
       c.customer_name,
       COUNT(*) FILTER (WHERE o.order_status = 'Cancelled') AS cancelled_orders,
       COUNT(*) FILTER (WHERE o.order_status = 'Returned')  AS returned_orders
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status IN ('Cancelled', 'Returned')
GROUP BY c.customer_id, c.customer_name
ORDER BY cancelled_orders + returned_orders DESC;
```

### City revenue

**30. Revenue by state and city**
```sql
SELECT c.state,
       c.city,
       SUM(oi.quantity * oi.unit_price * (1 - COALESCE(oi.discount, 0))) AS revenue
FROM customers c
JOIN orders o       ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
GROUP BY c.state, c.city
ORDER BY revenue DESC;
```

### Management summary

**31. Business KPIs in one query**
```sql
SELECT
    (SELECT COUNT(*) FROM customers)                                        AS total_customers,
    (SELECT COUNT(*) FROM orders)                                           AS total_orders,
    (SELECT COUNT(*) FROM orders WHERE order_status = 'Completed')          AS completed_orders,
    (SELECT COUNT(*) FROM orders WHERE order_status = 'Cancelled')          AS cancelled_orders,
    (SELECT SUM(total_amount) FROM orders WHERE order_status = 'Completed') AS total_revenue,
    (SELECT ROUND(AVG(total_amount), 2) FROM orders WHERE order_status = 'Completed') AS average_order_value,
    (SELECT ROUND(AVG(rating), 2) FROM reviews)                             AS average_rating,
    (SELECT ROUND(AVG(delivery_date - dispatch_date), 2) FROM delivery)     AS avg_delivery_days;
```

---

## SQL concepts used

- **Basics:** `SELECT`, `WHERE`, `ORDER BY`, `LIMIT`, `DISTINCT`
- **Aggregation and grouping:** `COUNT`, `SUM`, `AVG`, `GROUP BY`, `HAVING`
- **Joins:** `INNER JOIN` across up to four tables
- **Conditional logic:** `CASE`, and `FILTER (WHERE ...)` for conditional aggregation
- **Window functions:** `RANK()`, `ROW_NUMBER()`, `LAG()`, `SUM() OVER ()`
- **CTEs and subqueries**
- **Dates:** `EXTRACT`, `DATE_TRUNC`, `TO_CHAR`, date subtraction

---

## Key insights

[Fill these in from your own results. Examples of what to write: which city and category earn the most revenue, how many customers fall in Gold, Silver and Bronze, which delivery partner is fastest, which month had the highest payment failure rate, and which products are rated below 3.5. Add result screenshots in `screenshots/`.]

---

## Project structure

[Make this match your repo.]

```text
.
├── README.md
├── data/          # CSV files
├── sql/           # table creation, data import and analysis queries
└── screenshots/   # schema and query output images
```

---

## How to run

1. Create a database: `CREATE DATABASE ecommerce_analysis;`
2. Create the eight tables (run your table creation script).
3. Import the CSV files into their tables, for example:
   ```sql
   COPY order_items FROM 'path/to/order_items.csv' WITH (FORMAT csv, HEADER true);
   ```
   Change the path to your machine, or use pgAdmin's Import/Export tool.
4. Run the analysis queries from the `sql` folder in pgAdmin, one at a time.

---

## Future improvements

- A Power BI dashboard on top of these queries
- Python and pandas analysis of the same data
- RFM analysis, cohort analysis and retention analysis
- Sales forecasting

---

## Author

**Rahul Kumar**: Python/Django backend developer with SQL experience
LinkedIn: www.linkedin.com/in/rahulkumar350| GitHub: [RahulRanjan350](https://github.com/RahulRanjan350)

Project repository: https://github.com/RahulRanjan350/E-Commerce-Data-Analysis-SQL-Project-
