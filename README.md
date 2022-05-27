# Models-and-Toys

Folowing a Data Analyst Training at Wild Code School, this is the first projet that my colleagues and I have built avec the aim to develop our MySQL and Tableau skills. We took 3 weeks to build this dashboard. 

<b>1 - Introduction</b> 

With a group of five members, we were commissioned by a fictious company selling models and scale models. This company sent the database with all the information that we could have to develope the project, such as : <i>the list of employees, products, orders and so on</i>. Thus, we were in charge to develop a dashboard which the director of the company can refresh each morning to have the latest information oin order to take decision and manage the company. 

<b>2 - Objective</b> 

Our dashboard must have four (4) main topics: <i>sales, finance, logistics and human resources.</i>
  - <b>Sales:</b> The number of products sold by category and by month, with comparison and rate of change compared to the same month of the previous year.
  - <b>Finances:</b> The turnover of the orders of the last two months by country and the orders that have not yet been paid.
  - <b>Logistics:</b> The stock of the 5 most ordered products.
  - <b>Human Resources:</b> Each month, the 2 sellers with the higest turnorver 

<b>3 - Tools</b> 

For this project we have used Tableau Software and MySQL Workbench 

##

<h1>Our Dashboard Human Resource</h1>

- <b>The best sales each month</b>

~~~~sql
WITH rank_turnover AS
(
SELECT ROUND(SUM(orderdetails.priceeach * orderdetails.quantityOrdered), 0) as turnover, 
CONCAT(employees.firstname," ", employees.lastname) AS fullname, 
DATE_FORMAT(orders.orderdate, "%M, %Y") as monthyear, 
DATE_FORMAT(orders.orderdate, "%M") as month1, 
DATE_FORMAT(orders.orderdate, "%Y") as year1
FROM employees
INNER JOIN customers
	ON employees.employeeNumber = customers.SalesRepEmployeeNumber
INNER JOIN orders
	ON customers.customerNumber = orders.customerNumber
INNER JOIN orderdetails
	ON orders.orderNumber = orderdetails.orderNumber
GROUP BY YEAR(orders.orderdate), MONTH(orders.orderdate), fullname
ORDER BY YEAR(orders.orderdate), MONTH(orders.orderdate), turnover
)
, rank_month AS
(
SELECT RANK() OVER (PARTITION BY monthyear ORDER BY turnover DESC) AS turnover_rank, 
monthyear, turnover, year1, month1, fullname
FROM rank_turnover
ORDER BY turnover_rank DESC
)

SELECT turnover_rank, fullname, turnover, month1, year1 
FROM rank_month
WHERE turnover_rank <= '2'
ORDER BY year1, month1, turnover_rank;
~~~~

<div style="display: inline_block"><br>
  <img align="center" alt="RH-1" src="https://github.com/leonardodasilvasouza/Models-and-Toys/blob/main/deuxmeilleursvendeursmois.png?raw=true">
</div>

