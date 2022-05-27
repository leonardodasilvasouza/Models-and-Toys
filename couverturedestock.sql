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