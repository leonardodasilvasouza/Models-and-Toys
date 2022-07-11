# Models-and-Toys

Following a Data Analyst Training at Wild Code School, this is the first projet that my colleagues and I have built with the aim to develop our MySQL and Tableau skills. We took 3 weeks to build this dashboard. 

Link Tableau Public -> https://public.tableau.com/app/profile/da.silva.souza/viz/Projet1_16575362634360/Overview

<b>1 - Introduction</b> 

With a group of five members, we were commissioned by a fictious company selling models and scale models. This company sent the database with all the information that we could have to develope the project, such as : <i>the list of employees, products, orders and so on</i>. Thus, we were in charge to develop a dashboard which the director of the company can refresh each morning to have the latest information in order to take decision and to manage the company. 

<b>2 - Objective</b> 

Our dashboard must have four (4) main topics: <i>sales, finance, logistics and human resources.</i>
  - <b>Sales:</b> The number of products sold by category and by month, with comparison and rate of change compared to the same month of the previous year.
  - <b>Finances:</b> The turnover of the orders of the last two months by country and the orders that have not yet been paid.
  - <b>Logistics:</b> The stock of the 5 most ordered products.
  - <b>Human Resources:</b> Each month, the 2 sellers with the highest turnover 

<b>3 - Tools</b> 

For this project we have used Tableau Software and MySQL Workbench 

##

<h1>Sales</h1>

- <b>Sales volume per month per line and n-1 variation</b>

~~~~sql
WITH monthly_sales_year AS
(
SELECT pl.productLine AS productline, DATE_FORMAT(o.orderDate, "%M") as mois,
SUM(od.quantityOrdered) AS total_ordered
FROM productlines AS pl
  INNER JOIN products AS p
    ON p.productLine=pl.productLine
  INNER JOIN orderdetails AS od
    ON od.productCode=p.productCode
  INNER JOIN orders AS o
    ON o.orderNumber=od.orderNumber
WHERE YEAR(o.orderDate) = YEAR(NOW()) AND MONTH(o.orderDate) <= MONTH(DATE_SUB(NOW(), INTERVAL 1 MONTH))
GROUP BY productline, MONTH(o.orderDate)
),

monthly_sales_previous_year AS
(
SELECT pl.productLine AS productline, DATE_FORMAT(o.orderDate, "%M") as mois,
SUM(od.quantityOrdered) AS total_ordered
FROM productlines AS pl
  INNER JOIN products AS p
    ON p.productLine=pl.productLine
  INNER JOIN orderdetails AS od
    ON od.productCode=p.productCode
  INNER JOIN orders AS o
    ON o.orderNumber=od.orderNumber
WHERE YEAR(o.orderDate) = YEAR(DATE_SUB(NOW(), INTERVAL 1 YEAR)) AND MONTH(o.orderDate) <= MONTH(DATE_SUB(NOW(), INTERVAL 1 MONTH))
GROUP BY productline, MONTH(o.orderDate)
)

SELECT py.productline, py.mois, py.total_ordered AS total_ordered_previous_year, y.total_ordered AS total_ordered_this_year, 
    y.total_ordered - py.total_ordered AS variation,
    ((y.total_ordered - py.total_ordered) / py.total_ordered) * 100 AS rate_of_change
FROM monthly_sales_previous_year AS py
LEFT JOIN monthly_sales_year AS y
    ON y.productline=py.productline AND y.mois=py.mois
~~~~

<div style="display: inline_block"><br>
	<img align="center" alt="SA-1" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/volumeventemoislignevariationbis.png?raw=true">
	<img align="center" alt="SA-2" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/volumeventemoislignevariation.png?raw=true">
</div>

#

- <b>Top products by country</b>

~~~~sql
WITH CTE AS
(
SELECT C.country AS Country, SUM(OD.quantityOrdered) AS Sales, P.productName AS Product 
FROM customers C
	INNER JOIN orders O
		ON O.customerNumber = C.customerNumber
	INNER JOIN orderdetails OD
		ON O.orderNumber = OD.orderNumber
	INNER JOIN products P
		ON OD.productCode = P.productCode 

WHERE YEAR(O.orderDate) = YEAR(NOW())
GROUP BY C.country , P.productName
)

SELECT * 
	FROM (
		SELECT *, RANK() OVER (PARTITION BY Country ORDER BY Sales DESC) AS Rang
		FROM CTE
		) AS Classement
WHERE Classement.Rang =1
~~~~

<div style="display: inline_block"><br>
	<img align="center" alt="SA-3" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/topproduitpays.png?raw=true">
</div>

#

- <b>Customers by country</b>

~~~~sql
SELECT c.country, COUNT(c.customerNumber) AS total_customers
FROM customers AS c
INNER JOIN orders AS o
	ON o.customerNumber=c.customerNumber
WHERE YEAR(o.orderDate) = YEAR(NOW())
GROUP BY country
ORDER BY total_customers DESC
~~~~

<div style="display: inline_block"><br>
	<img align="center" alt="SA-4" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/nombreclientpays.png?raw=true">
</div>

#

<h1>Finance</h1>

- <b>Sales revenue for the last two months by country</b>

~~~~sql
SELECT c.country, ROUND(SUM(od.quantityOrdered * od.priceEach) ,0) AS turnover
FROM orderdetails AS od
INNER JOIN orders AS o
	ON o.orderNumber=od.orderNumber
INNER JOIN customers AS c
	ON c.customerNumber=o.customerNumber
WHERE o.orderDate > DATE_ADD(NOW(), INTERVAL -2 MONTH)
GROUP BY country
ORDER BY turnover DESC;
~~~~

<div style="display: inline_block"><br>
  <img align="center" alt="FI-1" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/cadeuxderniersmois.png?raw=true">
</div>

#

- <b>Unpaid orders</b>

~~~~sql
WITH total_order_customer AS
(
SELECT SUM(orderdetails.priceeach * orderdetails.quantityOrdered) AS totalorder,
customers.CustomerNumber AS customerNumberOrder
FROM orderdetails
INNER JOIN orders
ON orders.orderNumber = orderdetails.orderNumber
INNER JOIN customers
ON customers.customerNumber = orders.CustomerNumber
GROUP BY customers.CustomerNumber
)
, total_payments_customer AS
(
SELECT SUM(payments.amount) AS totalpayment,
customers.CustomerNumber AS customerNumberPayment
FROM payments
INNER JOIN customers
ON customers.customerNumber = payments.CustomerNumber
GROUP BY customers.CustomerNumber
)

SELECT c.customerNumber, c.customerName, ROUND(ot.totalorder - tp.totalpayment) as to_be_paid
FROM customers AS c
INNER JOIN total_order_customer AS ot
ON ot.customerNumberOrder=c.customerNumber
INNER JOIN total_payments_customer AS tp
ON tp.customerNumberPayment=c.customerNumber
WHERE ROUND(ot.totalorder - tp.totalpayment)> 0
GROUP BY c.customerNumber
ORDER BY to_be_paid DESC;
~~~~

<div style="display: inline_block"><br>
  <img align="center" alt="FI-2" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/commandesnonpayees.png?raw=true">
</div>

#

- <b>Sales Revenue by product line of the current year</b>

~~~~sql
WITH turnover2020 AS (
		SELECT pl.productLine, p.productName, 
			ROUND(SUM(od.quantityOrdered * od.priceEach), 0) AS turnover2020
		FROM productlines AS pl
		INNER JOIN products AS p
			ON p.productLine=pl.productLine
		INNER JOIN orderdetails AS od
			ON od.productCode=p.productCode
		INNER JOIN orders AS o
			ON o.orderNumber=od.orderNumber
		WHERE YEAR(o.orderDate) = YEAR(DATE_SUB(NOW(), INTERVAL 2 YEAR))
			AND MONTH(o.orderDate) <= MONTH(NOW())
		GROUP BY pl.productLine
		ORDER BY turnover2020 DESC
), turnover2021 AS (
		SELECT pl.productLine, p.productName, 
	ROUND(SUM(od.quantityOrdered * od.priceEach), 0) AS turnover2021
		FROM productlines AS pl
		INNER JOIN products AS p
			ON p.productLine=pl.productLine
		INNER JOIN orderdetails AS od
			ON od.productCode=p.productCode
		INNER JOIN orders AS o
			ON o.orderNumber=od.orderNumber
		WHERE YEAR(o.orderDate) = YEAR(DATE_SUB(NOW(), INTERVAL 1 YEAR))
			AND MONTH(o.orderDate) <= MONTH(NOW())
		GROUP BY pl.productLine
		ORDER BY turnover2021 DESC
), turnover2022 AS (
		SELECT pl.productLine, p.productName, 
	ROUND(SUM(od.quantityOrdered * od.priceEach), 0) AS turnover2022
		FROM productlines AS pl
		INNER JOIN products AS p
			ON p.productLine=pl.productLine
		INNER JOIN orderdetails AS od
			ON od.productCode=p.productCode
		INNER JOIN orders AS o
			ON o.orderNumber=od.orderNumber
		WHERE YEAR(o.orderDate) = YEAR(NOW())
		GROUP BY pl.productLine
		ORDER BY turnover2022 DESC
)
SELECT a.productLine, turnover2020, turnover2021, turnover2022
FROM turnover2020 AS a
INNER JOIN turnover2021 AS b
	ON b.productLine=a.productLine
INNER JOIN turnover2022 AS c
	ON c.productLine=a.productLine;
~~~~

<div style="display: inline_block"><br>
  <img align="center" alt="FI-3" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/caligneproduitanneeencours.png?raw=true">
</div>

#

- <b>Margin rate by product line over the current year</b>

~~~~sql
WITH profitRate2020 AS (
		SELECT pl.productLine AS productLine,((ROUND(SUM(od.quantityOrdered * od.priceEach), 0) - ROUND(SUM(p.buyPrice * od.quantityOrdered), 0)) 
			/ ROUND(SUM(p.buyPrice * od.quantityOrdered), 0)) * 100 AS profitRate2020
		FROM productlines AS pl
		INNER JOIN products AS p
			ON p.productLine=pl.productLine
		INNER JOIN orderdetails AS od
			ON od.productCode=p.productCode
		INNER JOIN orders AS o
			ON o.orderNumber=od.orderNumber
		WHERE YEAR(o.orderDate) = YEAR(DATE_SUB(NOW(), INTERVAL 2 YEAR))
		GROUP BY pl.productLine
		ORDER BY profitRate2020 DESC
), profitRate2021 AS (
		SELECT pl.productLine AS productLine,((ROUND(SUM(od.quantityOrdered * od.priceEach), 0) - ROUND(SUM(p.buyPrice * od.quantityOrdered), 0)) 
			/ ROUND(SUM(p.buyPrice * od.quantityOrdered), 0)) * 100 AS profitRate2021
		FROM productlines AS pl
		INNER JOIN products AS p
			ON p.productLine=pl.productLine
		INNER JOIN orderdetails AS od
			ON od.productCode=p.productCode
		INNER JOIN orders AS o
			ON o.orderNumber=od.orderNumber
		WHERE YEAR(o.orderDate) = YEAR(DATE_SUB(NOW(), INTERVAL 1 YEAR))
		GROUP BY pl.productLine
		ORDER BY profitRate2021 DESC
), profitRate2022 AS (
		SELECT pl.productLine AS productLine,((ROUND(SUM(od.quantityOrdered * od.priceEach), 0) - ROUND(SUM(p.buyPrice * od.quantityOrdered), 0)) 
			/ ROUND(SUM(p.buyPrice * od.quantityOrdered), 0)) * 100 AS profitRate2022
		FROM productlines AS pl
		INNER JOIN products AS p
			ON p.productLine=pl.productLine
		INNER JOIN orderdetails AS od
			ON od.productCode=p.productCode
		INNER JOIN orders AS o
			ON o.orderNumber=od.orderNumber
		WHERE YEAR(o.orderDate) = YEAR(NOW())
		GROUP BY pl.productLine
		ORDER BY profitRate2022 DESC
)
SELECT a.productLine, profitRate2020, profitRate2021, profitRate2022
FROM profitRate2020 AS a
INNER JOIN profitRate2021 AS b
	ON b.productLine=a.productLine
INNER JOIN profitRate2022 AS c
	ON c.productLine=a.productLine;
~~~~

<div style="display: inline_block"><br>
  <img align="center" alt="FI-4" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/tauxmargeligneproduitanneeencours.png?raw=true">
</div>

#

<h1>Logistics</h1>

- <b>Stocks of the five (5) most ordered products</b>

~~~~sql
SELECT p.productCode, p.productName, p.quantityInStock
FROM products AS p
INNER JOIN orderdetails AS od
ON p.productCode = od.productCode
INNER JOIN orders AS o
ON o.orderNumber=od.orderNumber
WHERE YEAR(o.orderDate) = YEAR(NOW())
GROUP BY p.productName
ORDER BY SUM(od.quantityOrdered) DESC
LIMIT 5
~~~~

<div style="display: inline_block"><br>
  <img align="center" alt="LG-1" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/cinqproduitsplusdemandes.png?raw=true">
</div>

#

- <b>Order Status</b>

~~~~sql
WITH status_order AS (

SELECT DATE_FORMAT(o.orderDate, '%Y') AS annee, o.status as status_order, COUNT(o.orderNumber) AS total_status_order
FROM orders AS o
GROUP BY annee, status_order
)
, total_order AS (

SELECT annee, status_order, total_status_order, count(orders.orderNumber) as total_order
FROM status_order
INNER JOIN orders
ON DATE_FORMAT(orders.orderDate, '%Y') = annee
GROUP BY status_order, annee
)

SELECT annee, status_order, ROUND((100 * total_status_order) / total_order, 2) as percentage
FROM total_order
GROUP BY status_order, annee
ORDER BY annee
~~~~

<div style="display: inline_block"><br>
  <img align="center" alt="LG-2" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/statutdescommandes.png?raw=true">
</div>

#

- <b>Stock</b>

~~~~sql
SELECT p.productCode, p.productName, 
ROUND((((p.quantityInStock+od.quantityOrdered)+p.quantityInStock)/2)/od.quantityOrdered*(DAYOFYEAR(DATE( NOW() )))) AS couvertureStockNbJours
FROM orderdetails AS od 
INNER JOIN products AS p
	ON p.productCode = od.productCode
INNER JOIN orders AS o
	ON od.orderNumber = o.orderNumber
WHERE YEAR(o.orderDate) = YEAR(NOW())
GROUP BY p.productCode
ORDER BY couvertureStockNbJours;
~~~~

<div style="display: inline_block"><br>
  <img align="center" alt="LG-3" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/couverturedestock.png?raw=true">
</div>

#

- <b>Late orders</b>

~~~~sql
SELECT orders.orderDate, orders.requiredDate, orders.shippedDate, customers.customerName, orders.orderNumber
FROM orders
INNER JOIN customers
ON orders.customerNumber = customers.customerNumber
WHERE orders.requiredDate < orders.shippedDate AND YEAR(orders.orderDate) = YEAR(NOW())
~~~~

<div style="display: inline_block"><br>
  <img align="center" alt="LG-4" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/commandesrenretard.png?raw=true">
</div>

#

- <b>Delivery Time</b>

~~~~sql
SELECT country, DATE_FORMAT(orderDate, '%Y') AS annee, round(avg(duration), 2) AS average
from (
	SELECT orderNumber, orders.orderDate, orders.requiredDate, offices.country, 
  TIMESTAMPDIFF(day, orders.orderDate, orders.requiredDate) AS duration
	FROM orders
		inner join customers on orders.customernumber = customers.customernumber
		inner join employees on customers.salesrepemployeenumber = employees.employeenumber
		inner join offices on employees.officecode = offices.officecode) as table1
group by country, annee
~~~~

<div style="display: inline_block"><br>
  <img align="center" alt="LG-5" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/delaisdelivraison.png?raw=true">
</div>

##

<h1>Human Resource</h1>

- <b>The best sales each month</b>

~~~~sql
WITH rank_turnover AS
(
SELECT ROUND(SUM(orderdetails.priceeach * orderdetails.quantityOrdered), 0) as turnover, 
CONCAT(employees.firstname," ", employees.lastname) AS fullname, 
DATE_FORMAT(orders.orderdate, "%M, %Y") as monthyear, 
DATE_FORMAT(orders.orderdate, "%M") as month1, 
DATE_FORMAT(orders.orderdate, "%Y") as year1
FROM employees
INNER JOIN customers
	ON employees.employeeNumber = customers.SalesRepEmployeeNumber
INNER JOIN orders
	ON customers.customerNumber = orders.customerNumber
INNER JOIN orderdetails
	ON orders.orderNumber = orderdetails.orderNumber
GROUP BY YEAR(orders.orderdate), MONTH(orders.orderdate), fullname
ORDER BY YEAR(orders.orderdate), MONTH(orders.orderdate), turnover
)
, rank_month AS
(
SELECT RANK() OVER (PARTITION BY monthyear ORDER BY turnover DESC) AS turnover_rank, 
monthyear, turnover, year1, month1, fullname
FROM rank_turnover
ORDER BY turnover_rank DESC
)

SELECT turnover_rank, fullname, turnover, month1, year1 
FROM rank_month
WHERE turnover_rank <= '2'
ORDER BY year1, month1, turnover_rank;
~~~~

<div style="display: inline_block"><br>
  <img align="center" alt="RH-1" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/deuxmeilleursvendeursmois.png?raw=true">
</div>

#

- <b>The worst sales each month</b>

~~~~sql
WITH rank_turnover AS
(
SELECT ROUND(SUM(orderdetails.priceeach * orderdetails.quantityOrdered), 0) as turnover,
CONCAT(employees.firstname , " ", employees.lastname) AS fullname,
DATE_FORMAT(orders.orderdate, "%M, %Y") as monthyear,
DATE_FORMAT(orders.orderdate, "%M") as month1,
DATE_FORMAT(orders.orderdate, "%Y") as year1
FROM employees
INNER JOIN customers
ON employees.employeeNumber = customers.SalesRepEmployeeNumber
INNER JOIN orders
ON customers.customerNumber = orders.customerNumber
INNER JOIN orderdetails
ON orders.orderNumber = orderdetails.orderNumber
GROUP BY YEAR(orders.orderdate), MONTH(orders.orderdate), fullname
ORDER BY YEAR(orders.orderdate), MONTH(orders.orderdate), turnover
)
, rank_month AS
(
SELECT RANK() OVER (PARTITION BY monthyear ORDER BY turnover) AS turnover_rank,
monthyear, turnover, year1, month1, fullname
FROM rank_turnover
ORDER BY turnover_rank
)

SELECT turnover_rank, fullname, turnover, month1, year1
FROM rank_month
WHERE turnover_rank <= '2'
ORDER BY year1, month1, turnover_rank;
~~~~

<div style="display: inline_block"><br>
  <img align="center" alt="RH-2" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/deuxmoinsbonvendeursmois.png?raw=true">
</div>

#

- <b>Employee by department</b>

~~~~sql
SELECT jobTitle, COUNT(jobTitle) 
FROM employees
GROUP BY jobTitle
ORDER BY COUNT(jobTitle) DESC;
~~~~

<div style="display: inline_block"><br>
  <img align="center" alt="RH-3" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/employesdepartement.png?raw=true">
</div>

#

- <b>Top two business developers by year</b>

~~~~sql
WITH rank_turnover AS
(
SELECT ROUND(SUM(orderdetails.priceeach * orderdetails.quantityOrdered), 0) as turnover,
CONCAT(employees.firstname," ", employees.lastname) AS fullname,
DATE_FORMAT(orders.orderdate, "%Y") as year1
FROM employees
INNER JOIN customers
ON employees.employeeNumber = customers.SalesRepEmployeeNumber
INNER JOIN orders
ON customers.customerNumber = orders.customerNumber
INNER JOIN orderdetails
ON orders.orderNumber = orderdetails.orderNumber
GROUP BY YEAR(orders.orderdate), fullname
ORDER BY YEAR(orders.orderdate), turnover
)
, rank_year AS
(
SELECT RANK() OVER (PARTITION BY year1 ORDER BY turnover DESC) AS turnover_rank,
turnover, year1, fullname
FROM rank_turnover
ORDER BY turnover_rank DESC
)

SELECT turnover_rank, fullname, turnover, year1
FROM rank_year
WHERE turnover_rank <= '2'
ORDER BY year1, turnover_rank;
~~~~

<div style="display: inline_block"><br>
  <img align="center" alt="RH-4" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/top2vendeursannees.png?raw=true">
</div>

#

- <b>Number of exployees by country</b>

~~~~sql
  SELECT off.country, COUNT(off.country) AS nb_of_employees_per_country 
FROM offices AS off
LEFT JOIN employees AS e ON off.officeCode = e.officeCode
GROUP BY off.country
ORDER BY nb_of_employees_per_country DESC;
~~~~

<div style="display: inline_block"><br>
  <img align="center" alt="RH-5" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/top2vendeursannees.png?raw=true">
</div>

#

- <b>Top two business developers (last month)</b>

~~~~sql
 SELECT CONCAT(e.firstName, " ", e.lastName) AS fullname, 
	ROUND(SUM(od.quantityOrdered * od.priceEach), 0) AS turnover
FROM employees AS e
INNER JOIN customers AS c
	ON c.salesRepEmployeeNumber = e.employeeNumber
INNER JOIN orders AS o
	ON o.customerNumber = c.customerNumber
INNER JOIN orderdetails AS od
	ON od.orderNumber=o.orderNumber
WHERE YEAR(o.orderDate) = YEAR(NOW()) AND MONTH(o.orderDate) = MONTH(DATE_SUB(NOW(), INTERVAL 1 MONTH))
GROUP BY fullname
ORDER BY turnover DESC
LIMIT 2;
~~~~

<div style="display: inline_block"><br>
  <img align="center" alt="RH-6" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/top2vendeursderniermois.png?raw=true">
</div>

#

- <b>Two worst business developers (last month)</b>

~~~~sql
SELECT CONCAT(e.firstName, " ", e.lastName) AS fullname, 
	ROUND(SUM(od.quantityOrdered * od.priceEach), 0) AS turnover
FROM employees AS e
INNER JOIN customers AS c
	ON c.salesRepEmployeeNumber = e.employeeNumber
INNER JOIN orders AS o
	ON o.customerNumber = c.customerNumber
INNER JOIN orderdetails AS od
	ON od.orderNumber=o.orderNumber
WHERE YEAR(o.orderDate) = YEAR(NOW()) AND MONTH(o.orderDate) = MONTH(DATE_SUB(NOW(), INTERVAL 1 MONTH))
GROUP BY fullname
ORDER BY turnover
LIMIT 2;
~~~~

<div style="display: inline_block"><br>
  <img align="center" alt="RH-7" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/flop2vendeursderniermois.png?raw=true">
</div>
