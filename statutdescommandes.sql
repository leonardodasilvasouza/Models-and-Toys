WITH status_order AS (

SELECT DATE_FORMAT(o.orderDate, '%Y') AS annee, o.status as status_order, COUNT(o.orderNumber) AS total_status_order
FROM orders AS o
GROUP BY annee, status_order
)
, total_order AS (

SELECT annee, status_order, total_status_order, count(orders.orderNumber) as total_order
FROM status_order
INNER JOIN orders
ON DATE_FORMAT(orders.orderDate, '%Y') = annee
GROUP BY status_order, annee
)

SELECT annee, status_order, ROUND((100 * total_status_order) / total_order, 2) as percentage
FROM total_order
GROUP BY status_order, annee
ORDER BY annee