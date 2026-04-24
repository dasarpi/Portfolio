SELECT * FROM zepto_inventory.zepto_v2;
-- Checing Null Values

SELECT * FROM zepto_v2
WHERE name IS null
OR Category IS null
OR mrp IS null
OR discountPercent IS null
OR availableQuantity IS null
OR discountedSellingPrice IS null
OR weightInGms IS null
OR outOfStock IS null
OR quantity IS null;

-- Different Product Category
SELECT DISTINCT Category
FROM zepto_v2
ORDER BY Category;

-- Products that are in Stock
SELECT outOfStock, COUNT(Sku_id)
FROM zepto_v2
GROUP BY outOfStock;


-- Multiple Product Names
SELECT name, COUNT(SKu_id) AS "Numbers_of_SKUs"
FROM zepto_v2
GROUP BY name
HAVING COUNT(Sku_id) >1
ORDER BY COUNT(Sku_id) DESC;


-- Data Cleaning Process
-- Products with Zero prices;

SELECT * FROM zepto_v2
WHERE mrp = 0 OR discountedSellingPrice = 0;

DELETE FROM zepto_v2
WHERE mrp = 0;

SELECT * FROM zepto_v2;

-- Convert paise into Rupess
UPDATE zepto_v2
SET mrp = mrp/100.0,
discountedSellingPrice = discountedSellingPrice/100.0;

SELECT mrp, discountedSellingPrice
FROM zepto_v2;

-- Find the top 10 best value products based on the discount percentage?

SELECT DISTINCT name, mrp, discountPercent
FROM zepto_v2
ORDER BY discountPercent DESC
LIMIT 10;

-- What are the Products with High MRP but Out of stock?
SELECT DISTINCT name, mrp
FROM zepto_v2
WHERE outOfStock = TRUE and mrp >300
ORDER BY mrp DESC;

-- Calculate Estimated Revenue of each Category

SELECT Category,
SUM(discountedSellingPrice * availableQuantity) AS "Total_Revenue"
FROM zepto_v2
GROUP BY Category
ORDER BY Total_Revenue;

-- Find all Products where MRP is greater than Rs.500 and discount is less than 10%?
SELECT DISTINCT name, mrp, discountPercent
FROM zepto_v2
WHERE mrp > 500 and discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- Identify the top 5 category offering the highest average discount percentage?
SELECT Category,
ROUND(AVG(discountPercent),2)  AS Avg_Discount
FROM zepto_v2
GROUP BY Category
ORDER BY Avg_Discount DESC
LIMIT 5;

-- Find the price per gram for products above 100g and sort by best values?
 SELECT DISTINCT name, weightInGms, discountedSellingPrice,
 ROUND(discountedSellingPrice/weightInGms,2) AS Price_per_Gram
 FROm zepto_v2
 WHERE weightInGms >= 100
 ORDER BY Price_Per_Gram;

-- Group the products into category like Low, Medium and large
SELECT DISTINCT name, weightInGms,
CASE WHEN weightInGms <1000 THEN 'Low'
     WHEN weightInGms <5000 THEN 'Medium'
	 ELSE 'large'
     END AS Weight_Category
FROM zepto_v2;     
          
-- What is the total Inventory Weight PEr Category?
SELECT Category,
SUM(weightInGms * availableQuantity) AS "Total_Weight"
FROM zepto_v2
GROUP BY Category
ORDER BY Total_Weight;