WITH profitRate2020 AS (
		SELECT pl.productLine AS productLine,((ROUND(SUM(od.quantityOrdered * od.priceEach), 0) - ROUND(SUM(p.buyPrice * od.quantityOrdered), 0)) 
			/ ROUND(SUM(p.buyPrice * od.quantityOrdered), 0)) * 100 AS profitRate2020
		FROM productlines AS pl
		INNER JOIN products AS p
			ON p.productLine=pl.productLine
		INNER JOIN orderdetails AS od
			ON od.productCode=p.productCode
		INNER JOIN orders AS o
			ON o.orderNumber=od.orderNumber
		WHERE YEAR(o.orderDate) = YEAR(DATE_SUB(NOW(), INTERVAL 2 YEAR))
		GROUP BY pl.productLine
		ORDER BY profitRate2020 DESC
), profitRate2021 AS (
		SELECT pl.productLine AS productLine,((ROUND(SUM(od.quantityOrdered * od.priceEach), 0) - ROUND(SUM(p.buyPrice * od.quantityOrdered), 0)) 
			/ ROUND(SUM(p.buyPrice * od.quantityOrdered), 0)) * 100 AS profitRate2021
		FROM productlines AS pl
		INNER JOIN products AS p
			ON p.productLine=pl.productLine
		INNER JOIN orderdetails AS od
			ON od.productCode=p.productCode
		INNER JOIN orders AS o
			ON o.orderNumber=od.orderNumber
		WHERE YEAR(o.orderDate) = YEAR(DATE_SUB(NOW(), INTERVAL 1 YEAR))
		GROUP BY pl.productLine
		ORDER BY profitRate2021 DESC
), profitRate2022 AS (
		SELECT pl.productLine AS productLine,((ROUND(SUM(od.quantityOrdered * od.priceEach), 0) - ROUND(SUM(p.buyPrice * od.quantityOrdered), 0)) 
			/ ROUND(SUM(p.buyPrice * od.quantityOrdered), 0)) * 100 AS profitRate2022
		FROM productlines AS pl
		INNER JOIN products AS p
			ON p.productLine=pl.productLine
		INNER JOIN orderdetails AS od
			ON od.productCode=p.productCode
		INNER JOIN orders AS o
			ON o.orderNumber=od.orderNumber
		WHERE YEAR(o.orderDate) = YEAR(NOW())
		GROUP BY pl.productLine
		ORDER BY profitRate2022 DESC
)
SELECT a.productLine, profitRate2020, profitRate2021, profitRate2022
FROM profitRate2020 AS a
INNER JOIN profitRate2021 AS b
	ON b.productLine=a.productLine
INNER JOIN profitRate2022 AS c
	ON c.productLine=a.productLine;