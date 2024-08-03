use salemanagement;

-- 1. SQL statement returns the cities (only distinct values) from both the "Clients" and the "salesman" table.
select client_name, city from clients
union
select salesman_name, city from salesman;

-- 2. SQL statement returns the cities (duplicate values also) both the "Clients" and the "salesman" table.
select client_name, city from clients
union all
select salesman_name, city from salesman;

-- 3. SQL statement returns the Ho Chi Minh cities (only distinct values) from the "Clients" and the "salesman" table
select client_name, city from clients where city = 'Ho Chi Minh'
union
select salesman_name, city from salesman where city = 'Ho Chi Minh';

-- 4. SQL statement returns the Ho Chi Minh cities (duplicate values also) from the "Clients" and the "salesman" table
select client_name, city from clients where city = 'Ho Chi Minh'
union all
select salesman_name, city from salesman where city = 'Ho Chi Minh';

-- 5. SQL statement lists all Clients and salesman.
select client_name from clients
union all
select salesman_name from salesman;

-- 6. Write a SQL query to find all salesman and clients located in the city of Ha Noi on a table with
-- information: ID, Name, City and Type.
select client_number, client_name, city, 'client' from clients where city = 'Hanoi'
union
select salesman_number, salesman_name, city, 'salesman'  from salesman where city = 'Hanoi';

-- 7. Write a SQL query to find those salesman and clients who have placed more than one order. Return
-- ID, name and order by ID.
select * from (select c.client_number id, c.client_name from clients c
join salesorder o on o.client_number = c.client_number
group by c.client_number
having count(o.order_number) > 1
union
select s.salesman_number id, s.salesman_name from salesman s
join salesorder o on o.salesman_number = s.salesman_number
group by s.salesman_number
having count(o.order_number) > 1) as T
order by id;

-- 8. Retrieve Name, Order Number (order by order number) and Type of client or salesman with the client
-- names who placed orders and the salesman names who processed those orders.
select * from (select client_name, order_number od, 'client' from clients c
join salesorder o on o.client_number = c.client_number
union all
select salesman_name, order_number od, 'salesman' from salesman s
join salesorder o on o.salesman_number = s.salesman_number) as T
order by od;

-- 9. Write a SQL query to create a union of two queries that shows the salesman, cities, and
-- target_Achieved of all salesmen. Those with a target of 60 or greater will have the words 'High
-- Achieved', while the others will have the words 'Low Achieved'.
select salesman_name, city, target_achieved, 'High Achieved' from salesman where target_achieved >= 60
union
select salesman_name, city, target_achieved, 'Low Achieved' from salesman where target_achieved < 60;

-- 10. Write query to creates lists all products (Product_Number AS ID, Product_Name AS Name,
-- Quantity_On_Hand AS Quantity) and their stock status. Products with a positive quantity in stock are
-- labeled as 'More 5 pieces in Stock'. Products with zero quantity are labeled as ‘Less 5 pieces in Stock'.
select product_number id, product_name `name`, quantity_on_hand quantity, 'More 5 pieces in Stock' from product where quantity_on_hand > 0
union
select product_number id, product_name `name`, quantity_on_hand quantity, 'Less 5 pieces in Stock' from product where quantity_on_hand = 0;

-- 11. Create a procedure stores get_clients _by_city () saves the all Clients in table. Then Call procedure stores.
delimiter $$
create procedure get_clients_by_city()
begin
	select * from clients;
end; 
$$
call get_clients_by_city();

-- 12. Drop get_clients _by_city () procedure stores
drop procedure get_clients_by_city;

-- 13. Create a stored procedure to update the delivery status for a given order number. Change value
-- delivery status of order number “O20006” and “O20008” to “On Way”.
delimiter $$
create procedure delivery_update()
begin
	update salesorder
    set delivery_status = 'On Way'
    where order_number in ('O20006', 'O20008');
    
end; 
$$
call delivery_update();

-- 14. Create a stored procedure to retrieve the total quantity for each product
delimiter $$
create procedure total_quantity()
begin
	select product_number, product_name, quantity_on_hand+quantity_sell totalquantity from product;
end; 
$$
call total_quantity();

-- 15. Create a stored procedure to update the remarks for a specific salesman.
delimiter $$
create procedure update_remarks(id varchar(15), mark varchar(25))
begin
	update salesman
    set remark = mark
    where salesman_number = id;
end; 
$$

-- 16. Create a procedure stores find_clients() saves all of clients and can call each client by client_number.
delimiter $$
create procedure find_clients(id varchar(10))
begin
	select * from clients where client_number = id;
end; 
$$

-- 17. Create a procedure stores salary_salesman() saves all of clients (salesman_number, salesman_name,
-- salary) having salary >15000. Then execute the first 2 rows and the first 4 rows from the salesman table.
delimiter $$
create procedure salary_salesman(a int)
begin
	select salesman_number, salesman_name, salary from salesman where salary > 15000 limit a;
end; 
$$
call salary_salesman(2);
call salary_salesman(4);

-- 18. Procedure MySQL MAX() function retrieves maximum salary from MAX_SALARY of salary table.
delimiter $$
create procedure max_salary()
begin
	select max(salary) from salesman;
end;
$$

-- 19. Create a procedure stores execute finding amount of order_status by values order status of salesorder table.
delimiter $$
create procedure finding_amount_of_order_status(os varchar(15))
begin
	select count(order_status) from salesorder where order_status = os;
end; 
$$

call finding_amount_of_order_status('In Process');

-- 21. Count the number of salesman with following conditions : SALARY < 20000; SALARY > 20000; SALARY = 20000.
delimiter $$
create procedure number_salesman()
begin
	select sum(case when salary < 20000 then 1 else 0 end) as high,
			sum(case when salary > 20000 then 1 else 0 end) as low,
			sum(case when salary = 20000 then 1 else 0 end) as mid from salesman;
end; 
$$

-- 22. Create a stored procedure to retrieve the total sales for a specific salesman.
delimiter $$
create procedure total_sales(id varchar(15))
begin
	select id, s.salesman_name, sum(d.order_quantity) as totalsales from salesman s
    join salesorder o on s.salesman_number = o.salesman_number
    join salesorderdetails d on o.order_number = d.order_number
    join product p on d.product_number = p.product_number
    where s.salesman_number = id
    group by salesman_name;
end;
$$

call total_sales('S003');
-- 23. Create a stored procedure to add a new product:
-- Input variables: Product_Number, Product_Name, Quantity_On_Hand, Quantity_Sell, Sell_Price, Cost_Price.
delimiter $$
create procedure add_product(id varchar(15), `name` varchar(25), on_hand int,
							sell_quantity int, sprice decimal(15,4), cprice decimal(15,4),
                            pfit float, totalquantity int, exp date)
begin
	insert into product
    value (id, `name`, on_hand, sell_quantity, sprice, cprice, pfit, totalquantity, exp);
end; 
$$

call add_product('P1009', 'Rabbit', 30, 20, 120, 100, null, null, null);

-- 24. Create a stored procedure for calculating the total order value and classification:
-- - This stored procedure receives the order code (p_Order_Number) và return the total value 
-- (p_TotalValue) and order classification (p_OrderStatus).
-- Using the cursor (CURSOR) to browse all the products in the order (SalesOrderDetails ).
-- LOOP/While: Browse each product and calculate the total order value.
-- CASE WHEN: Classify orders based on total value:
-- Greater than or equal to 10000: "Large"
-- Greater than or equal to 5000: "Midium"
-- Less than 5000: "Small"
delimiter //
create procedure CalculateOrderValueAndClassification (
    IN p_Order_Number varchar(15),
    OUT p_TotalValue DECIMAL(10,2),
    OUT p_OrderStatus VARCHAR(10)
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE productValue DECIMAL(10,2);
    DECLARE totalValue DECIMAL(10,2) DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT p.sell_price * sod.order_quantity
        FROM SalesOrderDetails sod
        JOIN Product p ON sod.Product_number = p.Product_number
        WHERE sod.Order_Number = p_Order_Number;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO productValue;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET totalValue = totalValue + productValue;
    END LOOP;

    CLOSE cur;

    SET p_TotalValue = totalValue;

    CASE
        WHEN totalValue >= 10000 THEN
            SET p_OrderStatus = 'Large';
        WHEN totalValue >= 5000 THEN
            SET p_OrderStatus = 'Medium';
        ELSE
            SET p_OrderStatus = 'Small';
    END CASE;
END //
DELIMITER ;

CALL CalculateOrderValueAndClassification('O20001', @totalValue, @orderStatus);
SELECT @totalValue AS TotalValue, @orderStatus AS OrderStatus;