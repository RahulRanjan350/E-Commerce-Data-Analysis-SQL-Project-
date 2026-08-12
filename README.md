# E-Commerce-Data-Analysis-SQL-Project-
-- ============================================================
-- E-COMMERCE SQL PROJECT — CORRECTED & COMPLETED

--
-- Adjust column names below if your actual schema differs.
-- Items marked [FIXED] had a logic bug in the original; [NEW] were unanswered.
-- ============================================================

-- ================= BASIC =================

-- 1. Display all customers from Delhi.
SELECT * FROM customers WHERE city = 'Delhi';

-- 2. Find all Electronics products.
SELECT * FROM products WHERE category = 'Electronics';

-- 3. Find completed orders above ₹50,000.  [FIXED: was missing the status filter]
SELECT *
FROM orders
WHERE order_status = 'Completed'
  AND total_amount > 50000;

-- 4. Find the 10 most expensive products.
SELECT product_name, price
FROM products
ORDER BY price DESC
LIMIT 10;

-- 5. Count customers by state.
SELECT state, COUNT(customer_id) AS total_customers
FROM customers
GROUP BY state;

-- ================= INTERMEDIATE =================

-- 6. Top 10 customers by completed-order spending.
-- [FIXED: original ranked individual orders, not customers' total spend]
SELECT c.customer_id, c.customer_name, SUM(o.total_amount) AS total_spending
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spending DESC
LIMIT 10;

-- 7. Monthly revenue and order count for 2024–2025.
-- [FIXED: original grouped by month only, merging Jan-2024 with Jan-2025; also added order count]
SELECT
    EXTRACT(YEAR FROM order_date)  AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(total_amount)  AS total_revenue,
    COUNT(order_id)    AS total_orders
FROM orders
WHERE order_date BETWEEN '2024-01-01' AND '2025-12-31'
GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
ORDER BY year, month;

-- 8. AOV for customers with more than 3 completed orders.
-- [FIXED: original didn't filter to 'Completed' orders or require > 3 of them]
SELECT
    customer_id,
    COUNT(order_id) AS completed_orders,
    ROUND(AVG(total_amount), 2) AS AOV
FROM orders
WHERE order_status = 'Completed'
GROUP BY customer_id
HAVING COUNT(order_id) > 3
ORDER BY customer_id;

-- 9. Customers spending more than ₹50,000 (total spend, not per order).
-- [FIXED: original filtered individual order rows > 50000 instead of summing per customer]
SELECT c.customer_id, c.customer_name, SUM(o.total_amount) AS total_spending
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.total_amount) > 50000
ORDER BY total_spending DESC;

-- 10. Top 10 products by quantity sold.
-- [FIXED: original summed `price` from products table, never touched order_items.quantity]
SELECT p.product_name, SUM(oi.quantity) AS total_qty_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_qty_sold DESC
LIMIT 10;

-- 11. Category-wise quantity sold and revenue.
-- [FIXED: original never joined order_items, so it just summed catalog price, not actual sales]
SELECT
    p.category,
    SUM(oi.quantity) AS total_qty_sold,
    SUM(oi.quantity * oi.unit_price * (1 - COALESCE(oi.discount, 0))) AS total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- 12. Categories with average discount above 15%.
-- [FIXED: original computed (price-cost_price)/price, which is margin, not discount.
--  Uses order_items.discount instead. If discount is stored as a whole percent (e.g. 15,
--  not 0.15), drop the "*100".]
SELECT p.category, ROUND(AVG(oi.discount) * 100, 2) AS avg_discount_pct
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
HAVING ROUND(AVG(oi.discount) * 100, 2) > 15;

-- 13. Successful/failed payments by payment method.
-- [FIXED: original grouped by method only, collapsing all statuses into one count]
SELECT payment_method, payment_status, COUNT(*) AS total_payments
FROM payments
GROUP BY payment_method, payment_status
ORDER BY payment_method, payment_status;

-- 14. Monthly cancellation rate.
-- [FIXED: original used payment failures as a proxy for "cancellation" — cancellation
--  should come from orders.order_status = 'Cancelled', not payment status]
SELECT
    TO_CHAR(order_date, 'Month')   AS month_name,
    EXTRACT(MONTH FROM order_date) AS month_num,
    ROUND(
        COUNT(*) FILTER (WHERE order_status = 'Cancelled') * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate
FROM orders
GROUP BY EXTRACT(MONTH FROM order_date), TO_CHAR(order_date, 'Month')
ORDER BY month_num;

-- 15. Orders delivered in more than 5 days.
-- [FIXED: original was incomplete ("select from orders;")]
SELECT
    o.*,
    d.dispatch_date,
    d.delivery_date,
    (d.delivery_date - d.dispatch_date) AS delivery_days
FROM orders o
JOIN delivery d ON o.order_id = d.order_id
WHERE (d.delivery_date - d.dispatch_date) > 5;

-- 16. Average delivery time by delivery partner.  (Correct as originally written)
SELECT
    delivery_partner,
    ROUND(AVG(delivery_date - dispatch_date), 2) || ' days' AS average_delivery_days
FROM delivery
GROUP BY delivery_partner;

-- 17. Most popular product in each city by quantity.
-- [FIXED: original listed every city/product pair instead of just the top one per city]
WITH city_product_qty AS (
    SELECT
        c.city,
        p.product_name,
        SUM(oi.quantity) AS total_qty,
        RANK() OVER (PARTITION BY c.city ORDER BY SUM(oi.quantity) DESC) AS rnk
    FROM order_items oi
    JOIN products p  ON p.product_id = oi.product_id
    JOIN orders o    ON o.order_id = oi.order_id
    JOIN customers c ON c.customer_id = o.customer_id
    GROUP BY c.city, p.product_name
)
SELECT city, product_name, total_qty
FROM city_product_qty
WHERE rnk = 1
ORDER BY city;

-- 18. Customers who ordered in 2024 but not 2025.
-- [FIXED: original only filtered year = 2024, so it didn't actually exclude 2025 orderers]
SELECT DISTINCT c.customer_id, c.customer_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE EXTRACT(YEAR FROM o.order_date) = 2024
  AND c.customer_id NOT IN (
      SELECT customer_id FROM orders WHERE EXTRACT(YEAR FROM order_date) = 2025
  );

-- 19. Customers who ordered in both 2024 and 2025.
-- [FIXED: original used OR, which returns customers in *either* year, not both]
SELECT c.customer_id, c.customer_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE EXTRACT(YEAR FROM o.order_date) IN (2024, 2025)
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT EXTRACT(YEAR FROM o.order_date)) = 2;

-- 20. One-time customers and their spending.
-- [FIXED: original didn't restrict to customers with exactly one order]
SELECT c.customer_id, c.customer_name, SUM(oi.quantity * oi.unit_price) AS total_spending
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE c.customer_id IN (
    SELECT customer_id FROM orders GROUP BY customer_id HAVING COUNT(DISTINCT order_id) = 1
)
GROUP BY c.customer_id, c.customer_name;

-- ================= ADVANCED =================

-- 21. Rank products within each category by revenue.
-- [FIXED: original grouped only by category, losing per-product detail —
--  question asks to rank products *within* each category]
SELECT
    p.category,
    p.product_name,
    ABS(SUM(oi.quantity * oi.unit_price - oi.discount * oi.unit_price)) AS total_revenue,
    RANK() OVER (
        PARTITION BY p.category
        ORDER BY ABS(SUM(oi.quantity * oi.unit_price - oi.discount * oi.unit_price)) DESC
    ) AS rnk
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.category, p.product_name;

-- 22. [NEW] Top 3 products in every category using a window function.
WITH ranked AS (
    SELECT
        p.category,
        p.product_name,
        SUM(oi.quantity * oi.unit_price * (1 - COALESCE(oi.discount, 0))) AS revenue,
        RANK() OVER (
            PARTITION BY p.category
            ORDER BY SUM(oi.quantity * oi.unit_price * (1 - COALESCE(oi.discount, 0))) DESC
        ) AS rnk
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    GROUP BY p.category, p.product_name
)
SELECT category, product_name, revenue, rnk
FROM ranked
WHERE rnk <= 3
ORDER BY category, rnk;

-- 23. [NEW] Month-over-month revenue growth using LAG().
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date) AS month, SUM(total_amount) AS revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0),
        2
    ) AS mom_growth_pct
FROM monthly
ORDER BY month;

-- 24. [NEW] 2024 vs 2025 revenue and YoY growth.
WITH yearly AS (
    SELECT EXTRACT(YEAR FROM order_date) AS year, SUM(total_amount) AS revenue
    FROM orders
    WHERE EXTRACT(YEAR FROM order_date) IN (2024, 2025)
    GROUP BY EXTRACT(YEAR FROM order_date)
)
SELECT
    year,
    revenue,
    LAG(revenue) OVER (ORDER BY year) AS prev_year_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY year)) * 100.0
        / NULLIF(LAG(revenue) OVER (ORDER BY year), 0),
        2
    ) AS yoy_growth_pct
FROM yearly
ORDER BY year;

-- 25. Category percentage contribution to total revenue.  (Logic was fine as originally written)
SELECT
    p.category,
    ABS(SUM(oi.quantity * oi.unit_price - oi.discount * oi.unit_price)) AS total_revenue,
    ROUND(
        ABS(SUM(oi.quantity * oi.unit_price - oi.discount * oi.unit_price))
        / SUM(ABS(SUM(oi.quantity * oi.unit_price - oi.discount * oi.unit_price))) OVER () * 100,
        2
    ) AS category_pct_contribution
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.category;

-- 26. [NEW] Total spending by each customer.
SELECT c.customer_id, c.customer_name, SUM(o.total_amount) AS total_spending
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spending DESC;

-- 27. Total number of orders placed by each customer.
-- [FIXED: original joined customers.customer_id = orders.order_id — wrong key]
SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS total_orders_placed
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY c.customer_id;

-- 28. [NEW] Classify customers as Gold, Silver, or Bronze based on total spending.
-- (Thresholds are placeholders — adjust to your business rules.)
WITH spending AS (
    SELECT customer_id, SUM(total_amount) AS total_spending
    FROM orders
    GROUP BY customer_id
)
SELECT
    customer_id,
    total_spending,
    CASE
        WHEN total_spending >= 100000 THEN 'Gold'
        WHEN total_spending >= 50000  THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_tier
FROM spending
ORDER BY total_spending DESC;

-- 29. Average delivery time for each delivery partner.  (Same as #16)
SELECT
    delivery_partner,
    ROUND(AVG(delivery_date - dispatch_date), 2) || ' days' AS average_delivery_days
FROM delivery
GROUP BY delivery_partner;

-- 30. Number of cancelled orders for each payment method.
-- [FIXED: original counted ALL orders per payment method, not just cancelled ones]
SELECT payment_method, COUNT(order_id) AS number_of_cancelled_orders
FROM orders
WHERE order_status = 'Cancelled'
GROUP BY payment_method;

-- 31. Products with an average rating below 3.5.
-- [FIXED: simplified — the boolean column in the original was redundant with HAVING]
SELECT p.product_name, ROUND(AVG(r.rating), 2) AS avg_rating
FROM products p
JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_name
HAVING AVG(r.rating) < 3.5
ORDER BY avg_rating;

-- 32. Customers who have placed a Cancelled or Returned order.  (Correct as originally written)
SELECT DISTINCT c.customer_name, o.order_status
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status IN ('Cancelled', 'Returned');

-- 33. Total revenue generated by each city.

SELECT
    c.state,
    c.city,
    ABS(SUM(oi.quantity * oi.unit_price * (1 - COALESCE(oi.discount, 0)))) AS revenue
FROM customers c
JOIN orders o      ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.state, c.city
ORDER BY revenue DESC;
-- (Add "LIMIT 1" back if you specifically want just the single top-earning city.)

-- 34. [NEW] Management summary: customers, orders, completed orders, cancellations,
--       revenue, AOV and average rating.
SELECT
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.order_id) FILTER (WHERE o.order_status = 'Completed') AS completed_orders,
    COUNT(DISTINCT o.order_id) FILTER (WHERE o.order_status = 'Cancelled') AS cancelled_orders,
    SUM(o.total_amount) FILTER (WHERE o.order_status = 'Completed') AS total_revenue,
    ROUND(AVG(o.total_amount) FILTER (WHERE o.order_status = 'Completed'), 2) AS aov,
    (SELECT ROUND(AVG(rating), 2) FROM reviews) AS avg_rating
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;
