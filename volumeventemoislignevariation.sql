WITH monthly_sales_year AS
(
SELECT pl.productLine AS productline, DATE_FORMAT(o.orderDate, "%M") as mois,
SUM(od.quantityOrdered) AS total_ordered
FROM productlines AS pl
  INNER JOIN products AS p
    ON p.productLine=pl.productLine
  INNER JOIN orderdetails AS od
    ON od.productCode=p.productCode
  INNER JOIN orders AS o
    ON o.orderNumber=od.orderNumber
WHERE YEAR(o.orderDate) = YEAR(NOW()) AND MONTH(o.orderDate) <= MONTH(DATE_SUB(NOW(), INTERVAL 1 MONTH))
GROUP BY productline, MONTH(o.orderDate)
),

monthly_sales_previous_year AS
(
SELECT pl.productLine AS productline, DATE_FORMAT(o.orderDate, "%M") as mois,
SUM(od.quantityOrdered) AS total_ordered
FROM productlines AS pl
  INNER JOIN products AS p
    ON p.productLine=pl.productLine
  INNER JOIN orderdetails AS od
    ON od.productCode=p.productCode
  INNER JOIN orders AS o
    ON o.orderNumber=od.orderNumber
WHERE YEAR(o.orderDate) = YEAR(DATE_SUB(NOW(), INTERVAL 1 YEAR)) AND MONTH(o.orderDate) <= MONTH(DATE_SUB(NOW(), INTERVAL 1 MONTH))
GROUP BY productline, MONTH(o.orderDate)
)

SELECT py.productline, py.mois, py.total_ordered AS total_ordered_previous_year, y.total_ordered AS total_ordered_this_year, 
    y.total_ordered - py.total_ordered AS variation,
    ((y.total_ordered - py.total_ordered) / py.total_ordered) * 100 AS rate_of_change
FROM monthly_sales_previous_year AS py
LEFT JOIN monthly_sales_year AS y
    ON y.productline=py.productline AND y.mois=py.moiss