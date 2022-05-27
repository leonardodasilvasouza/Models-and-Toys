SELECT c.country, COUNT(c.customerNumber) AS total_customers
FROM customers AS c
INNER JOIN orders AS o
	ON o.customerNumber=c.customerNumber
WHERE YEAR(o.orderDate) = YEAR(NOW())
GROUP BY country
ORDER BY total_customers DESC
