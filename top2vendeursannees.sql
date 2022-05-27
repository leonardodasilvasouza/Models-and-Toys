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