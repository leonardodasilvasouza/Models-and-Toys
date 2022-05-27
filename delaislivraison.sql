SELECT country, DATE_FORMAT(orderDate, '%Y') AS annee, round(avg(duration), 2) AS average
from (
	SELECT orderNumber, orders.orderDate, orders.requiredDate, offices.country, 
  TIMESTAMPDIFF(day, orders.orderDate, orders.requiredDate) AS duration
	FROM orders
		inner join customers on orders.customernumber = customers.customernumber
		inner join employees on customers.salesrepemployeenumber = employees.employeenumber
		inner join offices on employees.officecode = offices.officecode) as table1
group by country, annee