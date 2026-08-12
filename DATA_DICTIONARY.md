# Data Dictionary
## customers
customer_id, customer_name, email, phone, gender, city, state, signup_date
## products
product_id, product_name, category, sub_category, price, cost_price
## orders
order_id, customer_id, order_date, order_status, payment_method, total_amount
## order_items
order_item_id, order_id, product_id, quantity, unit_price, discount
## payments
payment_id, order_id, payment_date, payment_method, amount, payment_status
## delivery
delivery_id, order_id, delivery_partner, dispatch_date, delivery_date, delivery_status
## reviews
review_id, customer_id, product_id, review_date, rating, review_text
