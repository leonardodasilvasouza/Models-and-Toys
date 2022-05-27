SELECT c.country, ROUND(SUM(od.quantityOrdered * od.priceEach) ,0) AS turnover
FROM orderdetails AS od
INNER JOIN orders AS o
	ON o.orderNumber=od.orderNumber
INNER JOIN customers AS c
	ON c.customerNumber=o.customerNumber
WHERE o.orderDate > DATE_ADD(NOW(), INTERVAL -2 MONTH)
GROUP BY country
ORDER BY turnover DESC;