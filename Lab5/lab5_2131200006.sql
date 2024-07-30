use salemanagement;

insert into salesman
values ('S007','Quang','Chanh My','Da Lat',700032,'Lam Dong',25000,90,95,'0900853487'),
('S008','Hoa','Hoa Phu','Thu Dau Mot',700051,'Binh Duong',13500,50,75,'0998213659');

insert into salesorder
values ('O20015','2022-05-12','C108','S007','On Way', '2022-05-15','Successful'),
('O20016','2022-05-16','C109','S008','Ready to Ship',null,'In Process');

insert into salesorderdetails
values ('O20015','P1008',15),
('O20015','P1007',10),
('O20016','P1007',20),
('O20016','P1003',5);

-- 1. Display the clients (name) who lives in same city.
select c1.client_name, c2.client_name, c2.city
from clients c1 join clients c2
on c1.city = c2.city and c1.client_number != c2.client_number;

-- 2. Display city, the client names and salesman names who are lives in “Thu Dau Mot” city.
select c.city, c.client_name, s.salesman_name
from clients c join salesman s
on c.city = s.city
where c.city = 'Thu Dau Mot';

-- 3. Display client name, client number, order number, salesman number, and product number for each order
select c.client_name, c.client_number, s.order_number, s.salesman_number, d.product_number
from clients c join salesorder s
on c.client_number = s.client_number
join salesorderdetails d
on s.order_number = d.order_number;

-- 4. Find each order (client_number, client_name, order_number) placed by each client. 
select c.client_number, c.client_name, s.order_number
from clients c join salesorder s
on c.client_number = s.client_number;

-- 5. Display the details of clients (client_number, client_name) and the number of orders which is paid by them
select c.client_number, c.client_name, count(s.order_number)
from clients c join salesorder s
on c.client_number = s.client_number
group by s.client_number;

-- 6. Display the details of clients (client_number, client_name) who have paid for more than 2 orders. 
select c.client_number, c.client_name
from clients c join salesorder s
on c.client_number = s.client_number
group by s.client_number
having count(s.order_number) > 2;

-- 7. Display details of clients who have paid for more than 1 order in descending order of client_number
select c.*
from clients c join salesorder s
on c.client_number = s.client_number
group by s.client_number
having count(s.order_number) > 1
order by c.client_number desc;

-- 8. Find the salesman names who sells more than 20 products.
select s.salesman_name
from salesman s join salesorder o
on s.salesman_number = o.salesman_number
join salesorderdetails d
on o.order_number = d.order_number
group by o.salesman_number
having sum(d.order_quantity) > 20;

-- 9. Display the client information (client_number, client_name) and order number of those clients who have order status is cancelled
select c.client_number, c.client_name, s.order_number
from clients c join salesorder s
on c.client_number = s.client_number
where s.order_status = 'Cancelled';

-- 10. Display client name, client number of clients C101 and count the number of orders which were received “successful”.
select c.client_name, c.client_number, count(s.order_number)
from clients c join salesorder s
on c.client_number = s.client_number
where c.client_number = 'C101' and s.order_status = 'Successful';

-- 11. Count the number of clients orders placed for each product.
select d.product_number, count(c.client_number)
from clients c join salesorder s
on c.client_number = s.client_number
join salesorderdetails d
on s.order_number = d.order_number
group by d.product_number;

-- 12. Find product numbers that were ordered by more than two clients then order in descending by product number.
select d.product_number, count(c.client_name)
from clients c join salesorder s
on c.client_number = s.client_number
join salesorderdetails d
on s.order_number = d.order_number
group by d.product_number
having count(c.client_number) > 2
order by d.product_number desc;

-- 13. Find the salesman’s names who is getting the second highest salary.
select salesman_name
from salesman
where salary = (select max(salary)
from salesman
where salary < (select max(salary)
from salesman));

-- 14. Find the salesman’s names who is getting second lowest salary.
select salesman_name
from salesman
where salary = (select min(salary)
from salesman
where salary > (select min(salary)
from salesman));

-- 15. Write a query to find the name and the salary of the salesman who have a higher salary than the salesman whose salesman number is S001.
select salesman_name, salary
from salesman
where salary > (select salary
from salesman
where salesman_number = 'S001');

-- 16. Write a query to find the name of all salesman who sold the product has number: P1002
select salesman_name
from salesman
where salesman_number in (select salesman_number 
from salesorder 
where order_number in (select order_number 
from salesorderdetails
where product_number = 'P1002'));

-- 17. Find the name of the salesman who sold the product to client C108 with delivery status is “delivered”.
select salesman_name
from salesman
where salesman_number in (select salesman_number 
from salesorder 
where client_number = 'C108' and delivery_status = 'Delivered');

-- 18. Display lists the ProductName in ANY records in the sale Order Details table has Order Quantity equal to 5.
select product_name
from product
where product_number = any (select product_number
from salesorderdetails
where order_quantity = 5);

-- 19. Write a query to find the name and number of the salesman who sold pen or TV or laptop.
select salesman_name, salesman_number, count(*)
from salesman
where salesman_number in (select salesman_number
from salesorder
where order_number in (select order_number
from salesorderdetails
where product_number in (select product_number
from product
where product_name in ('pen','TV','laptop'))))
group by salesman_number;

-- 20. Lists the salesman’s name sold product with a product price less than 800 and Quantity_On_Hand more than 50
select salesman_name
from salesman
where salesman_number in (select salesman_number
from salesorder
where order_number in (select order_number
from salesorderdetails
where product_number in (select product_number
from product
where cost_price < 800 and quantity_on_hand > 50)));

-- 21. Write a query to find the name and salary of the salesman whose salary is greater than the average salary.
select salesman_name, salary
from salesman
where salary > (select avg(salary) from salesman);

-- 22. Write a query to find the name and Amount Paid of the clients whose amount paid is greater than the average amount paid.
select client_name, amount_paid
from clients 
where amount_paid > (select avg(amount_paid)
from clients);

-- 23. Find the product price that was sold to Le Xuan
select p.sell_price
from product p join salesorderdetails d
on p.product_number = d.product_number
join salesorder s
on s.order_number = d.order_number
join clients c
on c.client_number = s.client_number
where c.client_name = 'Le Xuan';

-- 24. Determine the product name, client name and amount due that was delivered.
select p.product_name, c.client_name, c.amount_due
from product p join salesorderdetails d
on p.product_number = d.product_number
join salesorder s 
on d.order_number = s.order_number
join clients c
on s.client_number = c.client_number
where s.delivery_status = 'Delivered';

-- 25. Find the salesman’s name and their product name which is cancelled.
select s.salesman_name, p.product_name
from salesman s join salesorder o
on s.salesman_number = o.salesman_number
join salesorderdetails d
on o.order_number = d.order_number
join product p
on d.product_number = p.product_number
where o.order_status = 'Cancelled';

-- 26. Find product names, prices and delivery status for those products purchased by Nguyen Thanh.
select p.product_name, p.sell_price, s.delivery_status
from product p join salesorderdetails d
on p.product_number = d.product_number
join salesorder s
on d.order_number = s.order_number
join clients c
on s.client_number = c.client_number
where c.client_name = 'Nguyen Thanh';

-- 27. Display the product name, sell price, salesperson name, delivery status, and order quantity information for each customer.
select p.product_name, p.sell_price, s.salesman_name, o.delivery_status, d.order_quantity
from product p join salesorderdetails d
on p.product_number = d.product_number
join salesorder o
on d.order_number = o.order_number
join salesman s
on o.salesman_number = s.salesman_number
join clients c
on o.client_number = c.client_number;

-- 28. Find the names, product names, and order dates of all sales staff whose product order status has been successful but the items have not yet been delivered to the client.
select s.salesman_name, p.product_name, o.order_date
from salesman s join salesorder o
on s.salesman_number = o.salesman_number
join salesorderdetails d
on o.order_number = d.order_number
join product p
on d.product_number = p.product_number
where o.order_status = 'Successful' and not o.delivery_status = 'Delivered';

-- 29. Find each clients’ product which in on the way.
select c.client_name, p.product_name
from product p join salesorderdetails d
on p.product_number = d.product_number
join salesorder o
on d.order_number = o.order_number
join clients c
on o.client_number = c.client_number
where o.delivery_status = 'On way';

-- 30. Find salary and the salesman’s names who is getting the highest salary.
select salary, salesman_name
from salesman
where salary = (select max(salary) from salesman);

-- 31. Find salary and the salesman’s names who is getting second lowest salary.
select salary, salesman_name
from salesman
where salary = (select min(salary) from salesman where salary > (select min(salary) from salesman));

-- 32. Display lists the ProductName in ANY records in the sale Order Details table has Order Quantity more than 9.
select product_name
from product
where product_number = any (select product_number from salesorderdetails where order_quantity > 9);

-- 33. Find the name of the customer who ordered the same item multiple times.
select c.client_name, d.product_number, count(d.product_number)
from clients c join salesorder o
on c.client_number = o.client_number
join salesorderdetails d
on o.order_number = d.order_number
group by d.product_number, c.client_name
having count(d.product_number) >= 2;

-- 34. Write a query to find the name, number and salary of the salemans who earns less than the average salary and works in any of Thu Dau Mot city.
select s.salesman_name, s.salesman_number, s.salary
from salesman s
where s.city = 'Thu Dau Mot' and s.salary < (select avg(salary) from salesman);

-- 35. Write a query to find the name, number and salary of the salemans who earn a salary that is higher than the salary 
-- of all the salesman have (Order_status = ‘Cancelled’). Sort the results of the salary of the lowest to highest.
select salesman_name, salesman_number, salary
from salesman
where salary > (select max(s.salary) from salesman s
join salesorder o
on s.salesman_number = o.salesman_number
 where o.order_status = 'Cancelled')
 order by salary;

-- 36. Write a query to find the 4th maximum salary on the salesman’s table.
select salary
from salesman 
order by salary desc
limit 3, 1;

-- 37. Write a query to find the 3th minimum salary in the salesman’s table.
select salary
from salesman 
order by salary
limit 2, 1;

SELECT *, CASE WHEN salary<15000 THEN 'low' ELSE
CASE WHEN salary<20000 THEN 'medium' ELSE 'high' END END 'note'
FROM salesman;