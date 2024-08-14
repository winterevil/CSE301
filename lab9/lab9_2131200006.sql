use hrmanagement;

-- 1. Check constraint to value of gender in “Nam” or “Nu”
alter table employees add constraint chk_gender
check (gender in ('Nam', 'Nu'));

-- 2. Check constraint to value of salary > 0.
alter table employees add constraint chk_salary
check (salary > 0);

-- 3. Check constraint to value of relationship in Relative table in “Vo chong”, “Con trai”, “Con 
-- gai”, “Me ruot”, “Cha ruot”. 
alter table relative add constraint chk_relationship
check(relationship in ('Vo chong', 'Con trai', 'Con gai', 'Me ruot', 'Cha ruot'));

-- 1. Look for employees with salaries above 25,000 in room 4 or employees with salaries above
-- 30,000 in room 5.
select * from employees
where salary > 25000 and departmentID = 4
or salary > 30000 and departmentID = 5;

-- 2. Provide full names of employees in HCM city.
select concat(lastName,' ',middleName,' ',firstName) as fullname from employees
where address like '%HCM';

-- 3. Indicate the date of birth of Dinh Ba Tien staff
select dateOfBirth from employees
where lastName = 'Dinh' and middleName = 'Ba' and firstName = 'Tien';

-- 4. The names of the employees of Room 5 are involved in the "San pham X" project and this
-- employee is directly managed by "Nguyen Thanh Tung".
select concat(e.lastName,' ',e.middleName,' ',e.firstName) as fullname from employees e
join assignment a on a.employeeID = e.employeeID
join projects p on p.projectID = a.projectID
join employees em on em.employeeID = e.managerID
where e.departmentID = 5 and p.projectName = 'San pham X'
and em.lastName = 'Nguyen' and em.middleName = 'Thanh' and em.firstName = 'Tung';

-- 5. Find the names of department heads of each department
select concat(em.lastName,' ',em.middleName,' ',em.firstName) as fullname from department d
join employees em on d.managerID = em.employeeID;

-- 6. Find projectID, projectName, projectAddress, departmentID, departmentName,
-- managerID, date0fEmployment.
select p.*, d.departmentName, d.managerID, d.dateOfEmployment from projects p
join department d on d.departmentID = p.departmentID;

-- 7. Find the names of female employees and their relatives
select concat(e.lastName,' ',e.middleName,' ',e.firstName) as fullname, r.* from employees e
join relative r on e.employeeID = r.employeeID
where e.gender = 'Nu';

-- 8. For all projects in "Hanoi", list the project code (projectID), the code of the project lead
-- department (departmentID), the full name of the manager (lastName, middleName,
-- firstName) as well as the address (Address) and date of birth (date0fBirth) of the Employees.
select p.projectID, d.departmentID, concat(e.lastName,' ',e.middleName,' ',e.firstName) as fullname, e.address, e.dateOfBirth
from projects p join department d on p.departmentID = d.departmentID
join employees e on d.managerID = e.employeeID
where p.projectAddress = 'Ha noi';

-- 9. For each employee, include the employee's full name and the employee's line manager
select concat(e.lastName,' ',e.middleName,' ',e.firstName) as employeeName, 
concat(em.lastName,' ',em.middleName,' ',em.firstName) as managerName
from employees e join employees em on e.managerID = em.employeeID;

-- 10. For each employee, indicate the employee's full name and the full name of the head of the
-- department in which the employee works
select concat(e.lastName,' ',e.middleName,' ',e.firstName) as employeeName, 
concat(em.lastName,' ',em.middleName,' ',em.firstName) as headName
from employees e join department d on d.departmentID = e.departmentID
join employees em on d.managerID = em.employeeID
where e.employeeID <> em.employeeID;

-- 11. Provide the employee's full name (lastName, middleName, firstName) and the names of
-- the projects in which the employee participated, if any.
select concat(e.lastName,' ',e.middleName,' ',e.firstName) as fullname, p.projectName
from employees e join assignment a on e.employeeID = a.employeeID
join projects p on p.projectID = a.projectID;

-- 12. For each scheme, list the scheme name (projectName) and the total number of hours
-- worked per week of all employees attending that scheme
select p.projectName, sum(a.workingHour) from projects p
join assignment a on a.projectID = p.projectID
group by p.projectID;

-- 13. For each department, list the name of the department (departmentName) and the average
-- salary of the employees who work for that department.
select d.departmentName, avg(e.salary) from department d
join employees e on e.departmentID = d.departmentID
group by e.departmentID;

-- 14. For departments with an average salary above 30,000, list the name of the department and
-- the number of employees of that department
select d.departmentName, count(e.employeeID) from department d
join employees e on e.departmentID = d.departmentID
group by e.departmentID
having avg(e.salary) > 30000;

-- 15. Indicate the list of schemes (projectID) that has: workers with them (lastName) as 'Dinh'
-- or, whose head of department presides over the scheme with them (lastName) as 'Dinh'.
select a.projectID from assignment a
join employees e on e.employeeID = a.employeeID
join employees em on e.managerID = em.employeeID
where e.lastName = 'Dinh' or em.lastName = 'Dinh';

-- 16. List of employees (lastName, middleName, firstName) with more than 2 relatives.
select concat(e.lastName,' ',e.middleName,' ',e.firstName) as fullname from employees e
join relative r on e.employeeID = r.employeeID
group by e.employeeID
having count(r.relationship) > 2;

-- 17. List of employees (lastName, middleName, firstName) without any relatives
select concat(e.lastName,' ',e.middleName,' ',e.firstName) as fullname from employees e
where e.employeeID not in (select r.employeeID from relative r);

-- 18. List of department heads (lastName, middleName, firstName) with at least one relative.
select concat(e.lastName,' ',e.middleName,' ',e.firstName) as fullname from employees e
join relative r on e.employeeID = r.employeeID
join department d on d.managerID = e.employeeID
group by e.employeeID
having count(r.relationship) > 1;

-- 19. Find the surname (lastName) of unmarried department heads.
select e.lastName from employees e
join department d on d.managerID = e.employeeID
where d.managerID not in (select r.employeeID from relative r);

-- 20. Indicate the full name of the employee (lastName, middleName, firstName) whose salary
-- is above the average salary of the "Research" department
select concat(e.lastName,' ',e.middleName,' ',e.firstName) as fullname from employees e
where e.salary > (select avg(em.salary) from employees em
join department d on em.departmentID = d.departmentID
where d.departmentName = 'Nghien cuu');

-- 21. Indicate the name of the department and the full name of the head of the department with
-- the largest number of employees.
select d.departmentName, concat(em.lastName,' ',em.middleName,' ',em.firstName) as fullname from department d
join employees e on e.departmentID = d.departmentID
join employees em on d.managerID = em.employeeID
group by e.departmentID
order by count(e.employeeID) desc
limit 1;

-- 22. Find the full names (lastName, middleName, firstName) and addresses (Address) of
-- employees who work on a project in 'HCMC' but the department they belong to is not
-- located in 'HCMC'.
select concat(e.lastName,' ',e.middleName,' ',e.firstName) as fullname, e.address from employees e
join departmentaddress d on d.departmentID = e.departmentID
join assignment a on a.employeeID = e.employeeID
join projects p on p.projectID = a.projectID
where d.address not like '%HCM' and p.projectAddress like '%HCM';

-- 23. Find the names and addresses of employees who work on a scheme in a city but the
-- department to which they belong is not located in that city
select concat(e.lastName,' ',e.middleName,' ',e.firstName) as fullname, e.address from employees e
join departmentaddress d on d.departmentID = e.departmentID
join assignment a on a.employeeID = e.employeeID
join projects p on p.projectID = a.projectID
where d.address not like 'TP%' and p.projectAddress like 'TP%';

-- 24. Create procedure List employee information by department with input data departmentName.
delimiter $$
create procedure list_employee(departmentName varchar(10))
begin
	select e.* from employees e
	join department d on e.departmentID = d.departmentID
	where d.departmentName = departmentName;
end;
$$

-- 25. Create a procedure to Search for projects that an employee participates in based on the
-- employee's last name (lastName).
delimiter $$
create procedure search_project(lastName varchar(20))
begin
	select p.* from projects p
    join assignment a on p.projectID = a.projectID
    join employees e on e.employeeID = a.employeeID
    where e.lastName = lastName;
end;
$$

-- 26. Create a function to calculate the average salary of a department with input data departmentID
delimiter $$
create function calc_avg_salary(departmentID int)
returns decimal(15,4)
deterministic
begin
	declare avgSalary decimal(15,4);
    select avg(e.salary) into avgSalary from employees e
    where e.departmentID = departmentID;
    return avgSalary;
end;
$$

-- 27. Create a function to Check if an employee is involved in a particular project input data is
-- employeeID, projectID.
delimiter $$
create function check_involved(employeeID varchar(3), projectID int)
returns boolean
deterministic
begin
	declare chk boolean;
    set chk = if (employeeID in (select a.employeeID from assignment a where a.projectID = projectID), 1, 0);
    return chk;
end;
$$
