use salemanagement;
set sql_safe_updates = 0;

-- 1. How to check constraint in a table?
SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'salesman';

-- 2. Create a separate table name as “ProductCost” from “Product” table, which contains the information
-- about product name and its buying price.
create table if not exists ProductCost(
productName varchar(255) not null,
buyingPrice decimal(10,2) not null
);

insert into ProductCost(productName, buyingPrice)
select product_Name, cost_price
from product;

-- 3. Compute the profit percentage for all products. Note: profit = (sell-cost)/cost*100
alter table product add column profit float;
update product set profit = (sell_price-cost_price)/cost_price*100 ;

-- 4. If a salesman exceeded his sales target by more than equal to 75%, his remarks should be ‘Good’.
alter table salesman add column remark varchar(25);
update salesman set remark = 'Good' where target_achieved/sales_target >= 0.75;
select * from salesman;

-- 5. If a salesman does not reach more than 75% of his sales objective, he is labeled as 'Average'.
update salesman set remark = 'Average' where target_achieved/sales_target < 0.75;

-- 6. If a salesman does not meet more than half of his sales objective, he is considered 'Poor'.
update salesman set remark = 'Poor' where target_achieved/sales_target <= 0.5;

-- 7. Find the total quantity for each product. (Query)
select product_name, quantity_on_hand+quantity_sell as total_quantity from product;

-- 8. Add a new column and find the total quantity for each product
alter table product add column total_quantity int;
update product set total_quantity = quantity_on_hand+quantity_sell;

-- 9. If the Quantity on hand for each product is more than 10, change the discount rate to 10 otherwise set to 5.
select *, 
case when quantity_on_hand>10 then 10 
else 5 end as discount_rate 
from product;

-- 10. If the Quantity on hand for each product is more than equal to 20, change the discount rate to 10, if it is
-- between 10 and 20 then change to 5, if it is more than 5 then change to 3 otherwise set to 0.
select *,
case when quantity_on_hand>=20 then 10
when quantity_on_hand between 10 and 20 then 5
when quantity_on_hand>5 then 3
else 0 end as discount_rate
from product;

-- 11. The first number of pin code in the client table should be start with 7.
alter table clients
add constraint chk_pin_code
check (pincode like '7%');

-- 12. Creates a view name as clients_view that shows all customers information from Thu Dau Mot
create view clients_view as select * from clients where city = 'Thu Dau Mot';

-- 13. Drop the “client_view”.
drop view if exists clients_view;

-- 14. Creates a view name as clients_order that shows all clients and their order details from Thu Dau Mot.
create view clients_order as select c.client_name, o.* from clients c 
join salesorder o 
on c.client_number = o.client_number 
where c.city = 'Thu Dau Mot'; 

-- 15. Creates a view that selects every product in the "Products" table with a sell price higher than the average
-- sell price.
create view product_price as select * from product where sell_price > (select avg(sell_price) from product);

-- 16. Creates a view name as salesman_view that show all salesman information and products (product names,
-- product price, quantity order) were sold by them.
create view salesman_view as select s.*, p.product_name, p.sell_price, d.order_quantity
from salesman s join salesorder o
on s.salesman_number = o.salesman_number
join salesorderdetails d
on o.order_number = d.order_number
join product p
on d.product_number = p.product_number;

-- 17. Creates a view name as sale_view that show all salesman information and product (product names,
-- product price, quantity order) were sold by them with order_status = 'Successful'
create view sale_view as select s.*, p.product_name, p.sell_price, d.order_quantity
from salesman s join salesorder o
on s.salesman_number = o.salesman_number
join salesorderdetails d
on o.order_number = d.order_number
join product p
on d.product_number = p.product_number
where o.order_status = 'Successful';

-- 18. Creates a view name as sale_amount_view that show all salesman information and sum order quantity
-- of product greater than and equal 20 pieces were sold by them with order_status = 'Successful'.
create view sale_amount_view as select s.*, sum(d.order_quantity)
from salesman s join salesorder o
on s.salesman_number = o.salesman_number
join salesorderdetails d
on o.order_number = d.order_number
join product p
on d.product_number = p.product_number
where o.order_status = 'Successful'
group by s.salesman_number, s.salesman_name
having sum(d.order_quantity) >=20;

-- 19. Amount paid and amounted due should not be negative when you are inserting the data. 
alter table clients
add constraint chk_amounts_non_negative
check (amount_paid >= 0 AND amount_due >= 0);

-- 20. Remove the constraint from pincode;
alter table clients drop constraint chk_pin_code;

-- 21. The sell price and cost price should be unique.
alter table product
add constraint chk_price
unique (sell_price, cost_price); 

-- 22. The sell price and cost price should not be unique.
alter table product drop constraint chk_price;

-- 23. Remove unique constraint from product name.
alter table product drop constraint product_name;

-- 24. Update the delivery status to “Delivered” for the product number P1007.
update salesorder set delivery_status = 'Delivered' 
where order_number in (select order_number from salesorderdetails
where product_number = 'P1007');

-- 25. Change address and city to ‘Phu Hoa’ and ‘Thu Dau Mot’ where client number is C104.
update clients set address = 'Phu Hoa', city = 'Thu Dau Mot' where client_number = 'C104';

-- 26. Add a new column to “Product” table named as “Exp_Date”, data type is Date
alter table product add column exp_date Date;

-- 27. Add a new column to “Clients” table named as “Phone”, data type is varchar and size is 15.
alter table clients add column phone varchar(15);

-- 28. Update remarks as “Good” for all salesman.
update salesman set remark = 'Good';

-- 29. Change remarks to "bad" whose salesman number is "S004".
update salesman set remark = 'Bad' where salesman_number = 'S004';

-- 30. Modify the data type of “Phone” in “Clients” table with varchar from size 15 to size is 10.
alter table clients modify column phone varchar(10);

-- 31. Delete the “Phone” column from “Clients” table.
alter table clients drop column phone;

-- 33. Change the sell price of Mouse to 120.
update product set sell_price = 120 where product_name = 'Mouse';

-- 34. Change the city of client number C104 to “Ben Cat”.
update clients set city = 'Ben Cat' where client_number = 'C104';

-- 35. If On_Hand_Quantity greater than 5, then 10% discount. If On_Hand_Quantity greater than 10, then 15%
-- discount. Othrwise, no discount.
select *,
case when quantity_on_hand > 5 then 10
when quantity_on_hand > 10 then 15
else 0 end as discount
from product;