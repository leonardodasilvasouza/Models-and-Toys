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