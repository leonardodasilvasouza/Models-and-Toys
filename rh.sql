######### Resources Humaines #########


  #### Chiffre d'affaires des deux meilleurs vendeurs du mois ####
  
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



  #### Chiffre d'affaires des 2 moins bon vendeurs du mois ####
  
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


  #### Employés par département ####
  
SELECT jobTitle, COUNT(jobTitle) 
FROM employees
GROUP BY jobTitle
ORDER BY COUNT(jobTitle) DESC;  


  #### Top 2 vendeurs par années ####
  
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


  #### Employés par pays ####
  
  SELECT off.country, COUNT(off.country) AS nb_of_employees_per_country 
FROM offices AS off
LEFT JOIN employees AS e ON off.officeCode = e.officeCode
GROUP BY off.country
ORDER BY nb_of_employees_per_country DESC;


	#### Top 2 vendeurs (du dernier mois) ####
	
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


	#### Flop 2 vendeurs (du dernier mois) ####
	
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