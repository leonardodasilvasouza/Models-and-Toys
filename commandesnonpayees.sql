WITH total_order_customer AS
(
SELECT SUM(orderdetails.priceeach * orderdetails.quantityOrdered) AS totalorder,
customers.CustomerNumber AS customerNumberOrder
FROM orderdetails
INNER JOIN orders
ON orders.orderNumber = orderdetails.orderNumber
INNER JOIN customers
ON customers.customerNumber = orders.CustomerNumber
GROUP BY customers.CustomerNumber
)
, total_payments_customer AS
(
SELECT SUM(payments.amount) AS totalpayment,
customers.CustomerNumber AS customerNumberPayment
FROM payments
INNER JOIN customers
ON customers.customerNumber = payments.CustomerNumber
GROUP BY customers.CustomerNumber
)

SELECT c.customerNumber, c.customerName, ROUND(ot.totalorder - tp.totalpayment) as to_be_paid
FROM customers AS c
INNER JOIN total_order_customer AS ot
ON ot.customerNumberOrder=c.customerNumber
INNER JOIN total_payments_customer AS tp
ON tp.customerNumberPayment=c.customerNumber
WHERE ROUND(ot.totalorder - tp.totalpayment)> 0
GROUP BY c.customerNumber
ORDER BY to_be_paid DESC;