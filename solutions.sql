DROP TABLE IF EXISTS reviews, delivery, payments, order_items, orders, products, customers CASCADE;
CREATE TABLE customers
       (customer_id INT PRIMARY KEY,customer_name VARCHAR(100),email VARCHAR(150)
	   UNIQUE,phone VARCHAR(15),gender VARCHAR(20),city VARCHAR(80),state VARCHAR(80),
	   signup_date DATE);

CREATE TABLE products(product_id INT PRIMARY KEY,product_name VARCHAR(150),category VARCHAR(80)
          ,sub_category VARCHAR(80),price NUMERIC(12,2),cost_price NUMERIC(12,2));
		  
CREATE TABLE orders(order_id INT PRIMARY KEY,customer_id INT REFERENCES customers
             (customer_id),order_date DATE,order_status VARCHAR(30),payment_method 
			 VARCHAR(40),total_amount NUMERIC(12,2));
			 
CREATE TABLE order_items(order_item_id INT PRIMARY KEY,order_id INT REFERENCES orders(order_id),
             product_id INT REFERENCES products(product_id),quantity INT,unit_price NUMERIC(12,2),
			 discount NUMERIC(5,2));
			 
CREATE TABLE payments(payment_id INT PRIMARY KEY,order_id INT REFERENCES orders(order_id),payment_date 
             DATE,payment_method VARCHAR(40),amount NUMERIC(12,2),payment_status VARCHAR(30));
			 
CREATE TABLE delivery(delivery_id INT PRIMARY KEY,order_id INT REFERENCES orders(order_id),delivery_partner
             VARCHAR(80),dispatch_date DATE,delivery_date DATE,delivery_status VARCHAR(30));
			 
CREATE TABLE reviews(review_id INT PRIMARY KEY,customer_id INT REFERENCES customers(customer_id),product_id
             INT REFERENCES products(product_id),review_date DATE,rating INT CHECK(rating BETWEEN 1 AND 5),review_text TEXT);
			 
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_items_product ON order_items(product_id);
CREATE INDEX idx_delivery_order ON delivery(order_id);

-- Import CSV File 

COPY customers
FROM 'D:\Study\Project\SQL\Ecommerce_SQL_Project_Complete\data\customers.csv'
WITH (FORMAT csv, HEADER true);

select * from customers;

COPY delivery
FROM 'D:\Study\Project\SQL\Ecommerce_SQL_Project_Complete\data\delivery.csv'
WITH (FORMAT csv, HEADER true);

select * from delivery;

COPY order_items
FROM 'D:\Study\Project\SQL\Ecommerce_SQL_Project_Complete\data\order_items.csv'
WITH (FORMAT csv, HEADER true);

select * from order_items;

COPY orders
FROM 'D:\Study\Project\SQL\Ecommerce_SQL_Project_Complete\data\orders.csv'
WITH (FORMAT csv, HEADER true);

select * from orders;

COPY payments
FROM 'D:\Study\Project\SQL\Ecommerce_SQL_Project_Complete\data\payments.csv'
WITH (FORMAT csv, HEADER true);

select * from payments;


COPY reviews
FROM 'D:\Study\Project\SQL\Ecommerce_SQL_Project_Complete\data\reviews.csv'
WITH (FORMAT csv, HEADER true);

select * from reviews;
