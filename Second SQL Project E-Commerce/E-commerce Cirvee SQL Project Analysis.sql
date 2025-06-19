-- This data has been cleaned in power query before being imported into sql for this analysis, majorly cleaning involved repleace blank and null values. The method used to clean involves replacing these records with median where obvious an using fill up. 

					--TASK 1
-- Devices used by customers 
select distinct Device_Type
from Ecommerce

-- customer base 
select Customer_Login_type, count (Customer_Login_type) as [Customer Base]
from Ecommerce
group by Customer_Login_type

--Product catergory being sold 
select distinct Product_Category, sum (Quantity) as Qunatity, sum(Sales) as total_sales
From Ecommerce
group by Product_Category
order by sum (Quantity) desc, sum (Sales) desc

--Gender Distribution by Product Category

Select Product_Category,
   sum (case when Gender = 'Male' then Quantity else 0 end) as [Items Sold for Male],
   sum (case when Gender = 'Female' then Quantity else 0 end)  [Items Sold for Male]
from Ecommerce
group by Product_Category

--  Login typs Preferred by Customers 
select Customer_Login_type, count (Customer_Login_type) as Count_of_Login_Type
from Ecommerce
group by Customer_Login_type 
order by count (Customer_Login_type) desc

-- Influence of Day of the Week and Time On sales? (Total sales by month, the days of week or time arrival)

select
DATENAME(MONTH, CAST(Order_Date AS DATE)) AS Month_Name,
DATENAME(WEEKDAY, CAST(Order_Date AS DATE)) AS Day_of_Week,
DATEPART(HOUR, CAST(Time AS TIME)) AS Hour_of_Day,
SUM(Sales) AS Total_Sales
From Ecommerce
Group by
DATENAME(MONTH, CAST(Order_Date AS DATE)),
DATENAME(WEEKDAY, CAST(Order_Date AS DATE)),
DATEPART(HOUR, CAST(Time AS TIME))
Order by Month_Name, Day_of_Week, Hour_of_Day;

-- Product that gives the highest profit per unit 
select top 1 product, SUM(Profit) / SUM(Quantity) AS Profit_Per_Unit 
from Ecommerce
group by Product
order by Profit_Per_Unit DESC

--How is my delivery speed and order priority? (Delivery Time distribution of order priority by months)
--Here we compare the Types of Orders (Order Priority) Against the average time
-- for more insight we can also compare it against the cost
select Order_Priority, Avg (Order_Processing_Time) as [Averae Procesing Time], AVG(Shipping_Cost) as [Averae shipping Cost]
from Ecommerce
group by Order_Priority


					-- TASK 2 (Sales Performance by Month)

--here we first extract the name of the months, then we calculate the calculate the sales made in the individual months. 
select DATENAME(MONTH, CAST(Order_Date AS DATE)) AS Month_Name, SUM (Sales) as [Sales over Month]
from Ecommerce
Group by DATENAME(MONTH, CAST(Order_Date AS DATE))
order by SUM (Sales) desc

--Months With the Sales
Select TOP 1 DATENAME(MONTH, CAST(Order_Date AS DATE)) AS Month_Name, SUM (Sales) as [Sales over Month]
from Ecommerce
Group by DATENAME(MONTH, CAST(Order_Date AS DATE))
order by [Sales over Month] desc

--Factors that Contributes to the Peak Sales Perfromance in Novemeber

					--TASK 3 (TOP 5 Best-Selling Products)

--Top 5 best-selling products based on total quantity sold.
select Top 5 Product, sum (Quantity) as [Total Quantity] 
from Ecommerce
group by product
order by sum (Quantity) desc

--Top 5 best-selling products based on total sales.

select Top 5 Product, sum (Sales) as [Total sales] 
from Ecommerce
group by product
order by sum (Sales) desc

-- Top 5 best-selling Product Characteristics (Price Per Unit, and Product Category)  

Select TOP 5 Product,Product_Category,
    SUM(Quantity) AS Total_Quantity_Sold, 
    SUM(Sales) / SUM(Quantity) AS Price_Per_Unit 
From Ecommerce
Group by Product, Product_Category
Order by Total_Quantity_Sold DESC

/*
The Best Selling Product further Analysis Shows that, the top five best selling product are from the same category (Fashion), the price per unit varies from 32-86 price range with runnings shoes being the most expensive at 86, and sports wear being the cheapest at 32. 
*/


						--TASK 4 (SALES BY PRODUCT CATEGORY)
--Total Sales per Product Category
select Product_Category, SUM (Sales) as [Revenue Per Category]
from Ecommerce
group by Product_Category
order by SUM (Sales) desc


-- percentage contribution 
--[where we providing the percentage distribution of every product category in the overall sales]
SELECT
    Product_Category,
    SUM(Sales) AS [CategorySales],
    ROUND(100.0 * SUM(Sales) / (SELECT SUM(Sales) 
FROM Ecommerce), 2) AS Percentage_Contribution
FROM
    Ecommerce
GROUP BY
    Product_Category
ORDER BY
    Percentage_Contribution DESC;


				--	TASK 5: Revenue Generation Order 
-- Calculate the average sales per order.

select count(Customer_Id)
from Ecommerce

select distinct count(Customer_Id)
from Ecommerce

--since there is no orderID or Invoice ID in the table, we check for what can be used to represent each unique order in every row, the query below shows that what is captured as customer Id is unique for every row, seeing that the output of count and distinct count is the same. There we will use it to customer_Id to represent each other. 

--//Attention to Clarify
select ROUND(AVG(Order_Total), 2) as Average_Sales_Per_Order
FROM (
    SELECT
        Customer_Id,
        SUM(Sales) AS Order_Total
    FROM
        Ecommerce
    GROUP BY
        Customer_Id
) AS Order_Sales;

-- Identify the top 5 orders by total sales amount 

select top 5 customer_Id,
    SUM(Sales) AS Order_Total
FROM Ecommerce
GROUP BY Customer_Id
ORDER BY Order_Total DESC;

--analyze which products contributed the most to these orders

-- Step 1: Identify the Top 5 Orders by Total Sales
WITH Top5Orders AS (
    SELECT TOP 5
        Customer_Id,
        SUM(Sales) AS Order_Total
    FROM
        Ecommerce
    GROUP BY
        Customer_Id
    ORDER BY
        Order_Total DESC
)

-- Step 2: For Those Orders, Show Product Contributions
SELECT
    e.Customer_Id,
    e.Product,
    SUM(e.Sales) AS Product_Contribution
FROM
    Ecommerce e
JOIN
    Top5Orders t ON e.Customer_Id = t.Customer_Id
GROUP BY
    e.Customer_Id, e.Product
ORDER BY
    e.Customer_Id, Product_Contribution DESC;


-- TASK 6 (Discount Impact Analysis)
-- Analyze the impact of discounts on sales performance. Determine if products with discounts are sold more frequently or generate higher revenue than non-discounted products

SELECT
    CASE 
        WHEN Discount > 0 THEN 'Discounted'
        ELSE 'Non-Discounted'
    END AS Discount_Type,
    COUNT(*) AS Transactions,
    SUM(Quantity) AS Total_Units_Sold,
    SUM(Sales) AS Total_Revenue,
    ROUND(AVG(Sales), 2) AS Average_Revenue_Per_Transaction
FROM
    Ecommerce
GROUP BY
    CASE 
        WHEN Discount > 0 THEN 'Discounted'
        ELSE 'Non-Discounted'
    END;


-- Recommendation: 
-- with an average revenue per tracsaction of $152 and a total revenue of 7813528. This shows that the company is generating revenue from the product discount. 

-- the analysis shows that all product are discounted. NB: Data was cleaned and null values were cleaned to fill up with the assumption that null discount is not the same as zero (0) discount. 