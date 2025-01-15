CREATE SCHEMA dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INT
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INT,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
SELECT * FROM sales;
  
  
  -- What is the total amount each customer spent at the restaurant?
  
SELECT s.customer_id, SUM(m.price) AS total_amount
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- With the help of JOIN clause we find out that how much each customer has spends on restaurent

-- How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(order_date) AS No_of_days_visited_restaurant
FROM sales
GROUP BY customer_id;

-- We analyzed that two customer has visited the restaurant 6six days. However, Customer'C' visited only 3days.

-- What was the first item from the menu purchased by each customer?

SELECT f.customer_id, m.product_name, f.first_purchase
FROM
    (SELECT s.customer_id,s.product_id, MIN(s.product_id) AS first_purchase
    FROM sales s
    GROUP BY s.customer_id,s.product_id) f 
    
JOIN menu m ON f.product_id = m.product_id;

-- What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT f.customer_id, m.product_name, f.most_purchased
FROM
     (SELECT s.customer_id, s.product_id,MAX(product_id) AS most_purchased
     FROM sales s
     GROUP BY s.customer_id, s.product_id) f
     
JOIN menu m ON f.product_id = m.product_id;  

-- Analyzed minimun and most purchased order of the restaurant   

-- Which item was the most popular for each customer?

SELECT c.customer_id, c.product_id, m.product_name, c.purchase_count
FROM (
      SELECT s.customer_id, s.product_id, COUNT(*) AS purchase_count
      FROM sales s
      GROUP BY s.customer_id, s.product_id) c
   
JOIN menu m ON c.product_id = m.product_id

WHERE c.purchase_count = (
		SELECT MAX(sub.purchase_count)
        FROM (
              SELECT s2.customer_id, s2.product_id, COUNT(*) AS purchase_count
              FROM sales s2
              GROUP BY s2.customer_id, s2.product_id) sub 
              WHERE sub.customer_id = c.customer_id
            
 );           


-- Which item was purchased first by the customer after they became a member?

SELECT 
    s.customer_id,
    s.product_id,
    m1.product_name,
    s.order_date AS purchase_date
FROM 
    Sales s
JOIN 
    Menu m1
ON 
    s.product_id = m1.product_id
JOIN 
    members m2
ON 
    s.customer_id = m2.customer_id
WHERE 
    s.order_date >= m2.join_date
AND 
    s.order_date = (
        SELECT 
            MIN(s2.order_date)
        FROM 
            Sales s2
        WHERE 
            s2.customer_id = s.customer_id
            AND s2.order_date >= m2.join_date
    );

         
-- Which item was purchased just before the customer became a member?

SELECT 
    s.customer_id,
    s.product_id,
    m1.product_name,
    s.order_date AS purchase_date
FROM 
    Sales s
JOIN 
    Menu m1
ON 
    s.product_id = m1.product_id
JOIN 
    members m2
ON 
    s.customer_id = m2.customer_id
WHERE 
    s.order_date <= m2.join_date
AND 
    s.order_date = (
        SELECT 
            MIN(s2.order_date)
        FROM 
            Sales s2
        WHERE 
            s2.customer_id = s.customer_id
            AND s2.order_date <= m2.join_date
    );


-- What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, COUNT(s.product_id), SUM(m1.price)
FROM sales s
JOIN menu m1 ON s.product_id = m1.product_id
JOIN members m2 ON s.customer_id = m2.customer_id
WHERE s.order_date < m2.join_date
GROUP BY s.customer_id;

-- -- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT s.customer_id, SUM(
		CASE
            WHEN m.product_id = 'sushi' THEN m.price * 10 * 2
            ELSE m.price * 10
	   END
 ) AS total_points
 FROM sales s 
 JOIN menu m ON s.product_id = m.product_id
 GROUP BY s.customer_id;
 
 -- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
 
   SELECT 
    s.customer_id,
    SUM(
        CASE 
            WHEN s.order_date BETWEEN m2_join_date AND DATE_ADD(m.join_date, INTERVAL 6 DAY) THEN 
                m1.price * 10 * 2
            WHEN m1.product_name = 'sushi' THEN 
                m1.price * 10 * 2
            ELSE 
                m1.price * 10
        END
    ) AS total_points
FROM 
    Sales s
JOIN 
    Menu m1 
ON 
    s.product_id = m.product_id
JOIN 
    members m2 
ON 
    s.customer_id = m2.customer_id
WHERE 
    s.customer_id IN ('A', 'B') 
    AND s.order_date <= '2021-01-31'
GROUP BY 
    s.customer_id;
    



SELECT s.customer_id, s.product_id, s.order_date, m.product_id, m.product_name, m.price, m2.join_date
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members m2 ON s.customer_id = m2.customer_id
ORDER BY s.customer_id, s.product_id, s.order_date, m.product_id, m.product_name, m.price, m2.join_date DESC;



-- Joining all the tables for staff, so that they can find every recoed in one place


SELECT s.customer_id, s.product_id, s.order_date, m.product_id, m.product_name, m.price, m2.join_date,
   CASE 
       WHEN m2.customer_id IS NOT NULL THEN 'Y'
         ELSE 'N'
  END AS Members

FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members m2 ON s.customer_id = m2.customer_id;
