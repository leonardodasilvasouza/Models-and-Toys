SELECT orders.orderDate, orders.requiredDate, orders.shippedDate, customers.customerName, orders.orderNumber
FROM orders
INNER JOIN customers
ON orders.customerNumber = customers.customerNumber
WHERE orders.requiredDate < orders.shippedDate AND YEAR(orders.orderDate) = YEAR(NOW())