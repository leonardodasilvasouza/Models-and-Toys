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
