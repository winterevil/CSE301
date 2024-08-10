use salemanagement;

-- 1. Create a trigger before_total_quantity_update to update total quantity of product when
-- Quantity_On_Hand and Quantity_sell change values. Then Update total quantity when Product P1004
-- have Quantity_On_Hand = 30, quantity_sell =35
delimiter $$
create trigger before_total_quantity_update
before update on product
for each row
begin
	set new.total_quantity = new.quantity_on_hand + new.quantity_sell;
end;
$$
update product set quantity_on_hand = 30, quantity_sell = 35 where product_number = 'P1004';

-- 2. Create a trigger before_remark_salesman_update to update Percentage of per_remarks in a salesman
-- table (will be stored in PER_MARKS column) : per_remarks = target_achieved*100/sales_target.
alter table salesman add column per_remarks decimal(15,2);
delimiter $$
create trigger before_remark_salesman_update
before update on salesman
for each row
begin
	set new.per_remarks = new.target_achieved*100/new.sales_target;
end;
$$

update salesman set sales_target = 50 where salesman_number = 'S001';
-- 3. Create a trigger before_product_insert to insert a product in product table.
delimiter $$
create trigger before_product_insert
before insert on product
for each row
begin
	if new.product_number is null then
		set new.product_name = now();
	end if;
end;
$$

insert into product
value ('P1010', 'Corn', 0, 0, 100, 90, null, null, null);

-- 4. Create a trigger to before update the delivery status to "Delivered" when an order is marked as
-- "Successful".
delimiter $$
create trigger before_update_delivery
before update on salesorder
for each row
begin
	if new.order_status = 'Successful' then
    set new.delivery_status = 'Delivered';
    end if;
end;
$$

update salesorder set order_status = 'Successful' where order_number = 'O20013';

-- 5. Create a trigger to update the remarks "Good" when a new salesman is inserted
delimiter $$
create trigger before_insert_remark
before insert on salesman
for each row
begin
    set new.remark = 'Good';
end;
$$

insert into salesman (salesman_number, salesman_name, pincode, salary, sales_target, target_achieved,phone)
value ('S010', 'Tuan', 700055, 12000,10,0,'0979654213');

-- 6. Create a trigger to enforce that the first digit of the pin code in the "Clients" table must be 7
delimiter $$
create trigger before_insert_clients
before insert on clients
for each row
begin
    if new.pincode not like '7%' then
    signal sqlstate '45000' set message_text = 'The first digit of the pincode must be 7.';
    end if;
end;
$$

insert into clients (client_number, client_name, pincode, amount_paid, amount_due)
value ('C112', 'Pham Yen', 600095, 9000, 9000);

-- 7. Create a trigger to update the city for a specific client to "Unknown" when the client is deleted
create table newClients(
client_number varchar(10),
city varchar(30)
);
delimiter $$
create trigger before_delete_client
after delete on clients
for each row
begin
	insert into newClients (client_number, city)
    value (old.client_number, 'Unknown');
end;
$$

delete from clients where client_number = 'C111';
select * from newClients;

-- 8. Create a trigger after_product_insert to insert a product and update profit and total_quantity in product table.
create table newProduct(
product_number varchar(15),
product_name varchar(25),
quantity_on_hand int,
quantity_sell int,
sell_price decimal(15,4),
cost_price decimal(15,4),
profit float,
total_quantity int
);

DELIMITER //
CREATE TRIGGER after_product_insert
AFTER INSERT ON product
FOR EACH ROW
BEGIN
    SET @profit = ((new.sell_price / new.cost_price) - 1) * 100,
        @total_quantity = new.quantity_on_hand + new.quantity_sell;
	insert into newProduct(product_number, product_name, quantity_on_hand, quantity_sell, sell_price, cost_price, profit, total_quantity)
	value (new.product_number, new.product_name, new.quantity_on_hand, new.quantity_sell, new.sell_price, new.cost_price, @profit, @total_quantity);        
END//
DELIMITER ;

drop trigger after_product_insert;

insert into product (Product_Number,Product_Name,Quantity_On_Hand,Quantity_Sell,Sell_Price,Cost_Price)
value ('P1011', 'crocodile', 10, 20, 2000.0000, 800.0000);
select * from newProduct;

-- 9. Create a trigger to update the delivery status to "On Way" for a specific order when an order is inserted.
delimiter $$
create trigger before_delivery_update
before insert on salesorder
for each row
begin
    set new.delivery_status = 'On Way';
end;
$$
insert into salesorder (order_number, order_date, client_number, salesman_number, delivery_date)
value ('O20017', '2022-05-15', 'C108', 'S008', '2022-05-16');
select * from salesorder;

-- 10. Create a trigger before_remark_salesman_update to update Percentage of per_remarks in a salesman
-- table (will be stored in PER_MARKS column) If per_remarks >= 75%, his remarks should be ‘Good’.
-- If 50% <= per_remarks < 75%, he is labeled as 'Average'. If per_remarks <50%, he is considered 'Poor'.
delimiter $$
create trigger before_update_remark_salesman
before update on salesman
for each row
begin
	if new.per_remarks >= 75 then
    set new.remark = 'Good';
    elseif new.per_remarks between 50 and 75 then
    set new.remark = 'Average';
    else set new.remark = 'Poor';
    end if;
end;
$$
update salesman set sales_target = 70, target_achieved = 65 where salesman_number = 'S010';
select * from salesman;

-- 11. Create a trigger to check if the delivery date is greater than the order date, if not, do not insert it.
delimiter $$
create trigger check_delivery_date
before update on salesorder
for each row
begin
	if new.delivery_date <= new.order_date then
    signal sqlstate '45000'
    set message_text = 'Delivery date must be greater than order date';
    end if;
end;
$$
update salesorder set order_date = '2022-05-16', delivery_date = '2022-05-15' where order_number = 'O20017';
select * from salesorder;

-- 12. Create a trigger to update Quantity_On_Hand when ordering a product (Order_Quantity).
delimiter $$
create trigger before_update_quantity
before insert on salesorderdetails
for each row
begin
	update product
	set quantity_on_hand = quantity_on_hand - new.order_quantity
    where product_number = new.product_number;
end;
$$
insert into salesorderdetails
value ('O20017', 'P1011', 5);
select * from salesorderdetails;
select * from product;

-- 1. Find the average salesman’s salary
delimiter $$
create function find_avg()
returns decimal(15,4)
deterministic
begin
	declare avgsal decimal(15,4);
	select avg(salary) into avgsal from salesman;
	return avgsal;
end;
$$

select find_avg();

-- 2. Find the name of the highest paid salesman
delimiter $$
create function find_highest_salary()
returns varchar(25)
deterministic
begin
	declare highest varchar(25);
    select salesman.salesman_name into highest from salesman
    where salary = (select max(salary) from salesman) limit 1;
    return highest;
end;
$$
select find_highest_salary();

-- 3. Find the name of the salesman who is paid the lowest salary
delimiter $$
create function find_lowest_salary()
returns varchar(25)
deterministic
begin
	declare lowest varchar(25);
    select salesman.salesman_name into lowest from salesman
    where salary = (select min(salary) from salesman) limit 1;
    return lowest;
end;
$$
select find_lowest_salary();

-- 4. Determine the total number of salespeople employed by the company.
delimiter $$
create function count_salesman()
returns int
deterministic
begin
	declare numOfSalesman int;
    select count(salesman_number) into numOfSalesman from salesman;
    return numOfSalesman;
end;
$$
select count_salesman();

-- 5. Compute the total salary paid to the company's salesman
delimiter $$
create function sum_salary_salesman()
returns decimal(15,4)
deterministic
begin
	declare sumSalary decimal(15,4);
    select sum(salary) into sumSalary from salesman;
    return sumSalary;
end;
$$
select sum_salary_salesman();

-- 6. Find Clients in a Province
delimiter $$
create function find_clients_province(input_province char(25))
returns text
deterministic
begin
	declare client_list text;
    select group_concat(client_name) into client_list from clients
    where province = input_province;
    return client_list;
end;
$$
select find_clients_province('Binh Duong');

-- 7. Calculate Total Sales
delimiter $$
create function calculate_total_sales()
returns decimal(15,4)
deterministic
begin
	declare sales decimal(15,4);
    select sum(quantity_sell*sell_price) into sales from product;
    return sales;
end;
$$
select calculate_total_sales();

-- 8. Calculate Total Order Amount
delimiter $$
create function calculate_total_order_amount()
returns int
deterministic
begin
	declare totalOrder int;
    select sum(order_quantity) into totalOrder from salesorderdetails;
    return totalOrder;
end;
$$
select calculate_total_order_amount();