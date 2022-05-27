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