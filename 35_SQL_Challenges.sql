## Basic
1. Display all customers from Delhi.
select * from customers where city='Delhi';
select * from customers;
select * from orders;
select * from products;
select * from orders;
select * from order_items;

COPY order_items
FROM 'D:\Study\Project\SQL\Ecommerce_SQL_Project_Complete\data\order_items.csv'
WITH (FORMAT csv, HEADER true);

select * from payments;
select * from delivery;
select * from payments_methods;

2. Find all Electronics products.
select * from products where category='Electronics';

3. Find completed orders above ₹50,000.
select * from orders where total_amount > 50000;

4. Find the 10 most expensive products.
select product_name, price from products order by price DESC limit 10; 

5. Count customers by state.

select count (customer_id) as total_customer, state  from customers group by state; 

## Intermediate
6. Top 10 customers by completed-order spending.
select * from orders where order_status='Completed' order by  total_amount DESC limit 10;

7. Monthly revenue and order count for 2024–2025.
select extract (Month from order_date) as month, sum(total_amount) as total_Revenue from orders where order_date 
                                between '2024-01-01' and '2025-12-31'
								group by EXTRACT(MONTH FROM order_date)
								order by Month;

8. AOV for customers with more than 3 completed orders.

select customer_id, order_status, sum(total_amount) as Total_revenue,round(avg(total_amount ),2) as AOV
                         from orders  group by customer_id,order_status order by customer_id ;


9. Customers spending more than ₹50,000.
select  customers.customer_id,customers.customer_name,orders.total_amount from customers
                left join orders on customers.customer_id=orders.customer_id where total_amount > 50000 order by customers.customer_id;

10. Top 10 products by quantity sold.
select product_name,sum(price) as total_amount  from products group by product_name  order by total_amount desc limit 10;

11. Category-wise quantity sold and revenue.
select category,count(product_id) as total_item_sold, sum(price) as total_revenue  from products group by category  order by total_revenue desc ;

12. Categories with average discount above 15%.
select category,round((avg((price-cost_price)/price * 100)),2) as discount_percentage
         from products group by category  having round((avg((price-cost_price)/price * 100)),2) > 15  ;

13. Successful/failed payments by payment method.
select payment_method,count(payment_status) as total_payments from payments group by payment_method;

14. Monthly cancellation rate.
SELECT
    TO_CHAR(payment_date, 'Month') AS month,
    ROUND(
        COUNT(*) FILTER (WHERE payment_status = 'Failed') * 100.0
        / COUNT(*),
        2
    ) AS cancellation_rate
FROM payments
GROUP BY
    EXTRACT(MONTH FROM payment_date),
    TO_CHAR(payment_date, 'Month')
ORDER BY EXTRACT(MONTH FROM payment_date);
						
15. Orders delivered in more than 5 days.

select  from orders;

16. Average delivery time by delivery partner.
select * from delivery
SELECT
    delivery_partner,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (delivery_date - dispatch_date)) / 86400)::numeric,
        2
    ) || ' days' AS average_delivery_days
FROM delivery
GROUP BY delivery_partner;

17. Most popular product in each city by quantity.
select * from customers;
select * from orders;
select * from products;
select * from orders;
select * from order_items;

select customers.city,products.product_name,sum(order_items.quantity) as total_qty
     from order_items 
	 join products on products.product_id=order_items.product_id
	 join orders on orders.order_id= order_items.order_id
	 join customers on customers.customer_id= orders.customer_id
	 group by customers.city, products.product_name;

	 
18. Customers who ordered in 2024 but not 2025.
select customers.customer_name,orders.order_date from customers join orders on customers.customer_id= orders.customer_id
     where extract(Year from orders.order_date) ='2024';
	 
19. Customers who ordered in both 2024 and 2025.
select customers.customer_name,orders.order_date from customers join orders on customers.customer_id= orders.customer_id
     where extract(Year from orders.order_date) ='2024' or  
	  extract(Year from orders.order_date)= '2025';
 
20. One-time customers and their spending.
select customers.customer_id,customers.customer_name, orders.order_id,order_items.product_id, 
                order_items.quantity,(order_items.unit_price * order_items.quantity) as total_spending
          from customers join orders on customers.customer_id=orders.customer_id
		  join order_items on order_items.order_id=orders.order_id;

## Advanced
21. Rank products within each category by revenue.

22. Top 3 products in every category using a window function.
23. Month-over-month revenue growth using LAG().
24. 2024 vs 2025 revenue and YoY growth.
25. Category percentage contribution to total revenue.
26. Gold/Silver/Bronze segmentation: Gold >= ₹50,000; Silver ₹20,000–₹49,999; Bronze < ₹20,000.
27. Customer Lifetime Value (CLV).
28. RFM metrics as of 2025-12-31.
29. RFM classification: Champions, Loyal Customers, Potential Loyalists, At Risk, Lost.
30. Best on-time delivery partner for completed orders.
31. Cancellation rate by payment method.
32. Products with high sales but average rating below 3.5.
33. Customers whose latest order was Cancelled or Returned.
34. Highest-revenue city for each state.
35. Management summary: customers, orders, completed orders, cancellations, revenue, AOV and average rating.


CREATE TABLE employees (
    employee_id INT,
    employee_name VARCHAR(50),
    salary NUMERIC
);

INSERT INTO employees (employee_id, employee_name, salary)
VALUES
    (1, 'Rahul Kumar', 45000),
    (2, 'Aman Sharma', 52000),
    (3, 'Priya Singh', 48000),
    (4, 'Neha Verma', 60000),
    (5, 'Arjun Mehta', 55000),
    (6, 'Simran Kaur', 47000),
    (7, 'Rohit Sharma', 65000),
    (8, 'Anjali Gupta', 58000),
    (9, 'Karan Singh', 50000),
    (10, 'Pooja Verma', 62000);

select * from employees;

drop TABLE employees;