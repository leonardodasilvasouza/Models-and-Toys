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