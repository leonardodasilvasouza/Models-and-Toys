# Stock des 5 produits les plus commandés

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