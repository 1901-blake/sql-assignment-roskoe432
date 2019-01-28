--| 2.1 Select |---------------------------------------------------------



-- Task 1: Select all employees from Employee table.
select * from employee;

-- Task 2 – Select all records from the Employee table where last name is King.
select * from employee where lastname = 'King';

-- Task 3 – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
select * from employee where firstname = 'Andrew' and reportsto is null;



--| 2.2 ORDER BY |---------------------------------------------------------



-- Task 1 – Select all albums in Album table and sort result set in descending order by title.
select * from album order by title desc;

-- Task 2 – Select first name from Customer and sort result set in ascending order by city
select firstname from customer order by city asc;



--| 2.3 INSERT INTO |---------------------------------------------------------



-- Task 1 – Insert two new records into Genre table
insert into genre (genreid, name) values (26, 'Nu Metal');
insert into genre (genreid, name) values (27, 'Alternative Rock');

-- Task 2 – Insert two new records into Employee table
insert into employee (employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, postalcode, phone, fax, email) 
	values (9, 'Snow', 'Ben', 'Associate', 6, '1988/11/16', '2019/01/14', '2222 Drive', 'Tampa', 'FL', 'United States', '77777', '+1 (888) 888-8888', '+1 (777) 777-7777', 'ben@email.com');
insert into employee (employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, postalcode, phone, fax, email) 
	values (10, 'Doe', 'John', 'Custodian', 6, '1970/01/01', '2019/01/10', '323 Ave', 'Tampa', 'FL', 'United States', '77777', '+1 (333) 333-3333', '+1 (222) 222-2222', 'jdoe@email.com');

-- Task 3 – Insert two new records into Customer table
insert into customer (customerid, firstname, lastname, address, city, country, postalcode, phone, email, supportrepid) 
	values (60, 'Billy', 'Bob', 'Trailer By River', 'Montana', 'United States', '98989', '+1 (666) 655-8787', 'redneck@yahoo', 9);
insert into customer (customerid, firstname, lastname, company, address, city, country, postalcode, phone, email, supportrepid) 
	values (61, 'Tony', 'Montana', 'Imports/Exports Inc.', 'Miami', 'Florida', 'United States', '11111', '+1 (777) 877-9898', 'scarface@gmail', 10);



--| 2.4 UPDATE |---------------------------------------------------------



-- Task 1 – Update Aaron Mitchell in Customer table to Robert Walter
update customer set firstname = 'Robert', lastname = 'Walter' where firstname = 'Aaron' and lastname = 'Mitchell';

-- Task 2 – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
update artist set name = 'CCR' where name = 'Creedence Clearwater Revival';



--| 2.5 LIKE |---------------------------------------------------------



-- Task 1 – Select all invoices with a billing address like “T%”
select * from invoice where billingaddress like 'T%';




--| 2.6 BETWEEN |---------------------------------------------------------



-- Task 1 – Select all invoices that have a total between 15 and 50
select * from invoice where total between 15 and 50;


-- Task 2 – Select all employees hired between 1st of June 2003 and 1st of March 2004
select * from employee where hiredate between '2003-06-01' and '2004-03-01';



--| 2.7 DELETE |---------------------------------------------------------



-- Task 1 – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).
-- DELETE FROM table_name WHERE [condition];
alter table invoiceline
drop constraint fk_invoicelineinvoiceid;

alter table invoiceline
add constraint k_invoicelineinvoiceid foreign key (invoiceid) references invoice(invoiceid) on delete cascade;

alter table invoice
drop constraint fk_invoicecustomerid;

alter table invoice
add constraint fk_invoicecustomerid foreign key (customerid) references customer(customerid) on delete cascade;

delete from customer where firstname = 'Robert' and lastname = 'Walter';



--| 3.1 System Defined Functions |---------------------------------------------------------



-- Task 1 – Create a function that returns the current time.
create or replace function getTime() 
returns timestamptz as $$ 
begin
	return now();
end; 
$$ language plpgsql;

select getTime();



-- Task 2 – create a function that returns the length of a mediatype from the mediatype table
create or replace function getLength(id int) 
returns int as $$
begin
	return length(name) from mediatype where mediatypeid = id;
end;
$$ language plpgsql;

select getLength(2);



--| 3.2 System Defined Aggregate Functions |---------------------------------------------------------



--| Task 1 – Create a function that returns the average total of all invoices
create or replace function totalAvg() 
returns numeric as $$
begin
	return avg(total) from invoice;
end;
$$ language plpgsql;

select totalAvg();



--| Task 2 – Create a function that returns the most expensive track
create or replace function mostExpensiveTrack() 
returns numeric as $$
begin
	return max(track.unitprice) from track;
end;
$$ language plpgsql;

select mostExpensiveTrack();



--| 3.3 User Defined Scalar Functions |---------------------------------------------------------



--| Task 1 – Create a function that returns the average price of invoiceline items in the invoiceline table
create or replace function avgPrice() 
returns numeric as $$
begin
	return avg(unitprice) from invoiceline;
end;
$$ language plpgsql;

select avgPrice();



--| 3.4 User Defined Table Valued Functions |---------------------------------------------------------



--| Task 1 – Create a function that returns all employees who are born after 1968.
create or replace function bornAfter1968() 
returns setof employee as $$
begin
	return Query(select * from employee where extract(year from birthdate) > 1968);
end;
$$ language plpgsql;

select bornAfter1968();



--| 4.1 Basic Stored Procedure |---------------------------------------------------------



-- Task 1 – Create a stored procedure that selects the first and last names of all the employees.
create or replace function employeeNames()
returns refcursor as $$
	declare
		ref refcursor;
	begin
		open ref for select firstname, lastname from employee;
		return ref;
	end;
$$ language plpgsql;

create table e_names (
	employeeid serial primary key,
	firstname text,
	lastname text
);

do $$
declare
    curs refcursor;
  	v_firstname text;
  	v_lastname text;
begin
    select employeeNames() into curs;
   	loop
        fetch curs into v_firstname, v_lastname;
        exit when not found;
        insert into e_names (firstname, lastname) values(v_firstname, v_lastname);
   	end loop;
end;
$$ language plpgsql;

select * from e_names;



--| 4.2 Stored Procedure Input Parameters |---------------------------------------------------------



-- Task 1 – Create a stored procedure that updates the personal information of an employee.
create or replace function update_emp(
	p_id int, 
	p_birthdate timestamp, 
	p_address varchar, 
	p_city varchar, 
	p_state varchar,
	p_country varchar,
    p_postalcode varchar,
    p_phone varchar,
    p_fax varchar,
    p_email varchar
)
returns void as $$
begin
    update employee
    	set birthdate = p_birthdate,
    	address = p_address,
    	city = p_city,
    	state = p_state,
    	country = p_country,
    	postalcode = p_postalcode,
    	phone = p_phone,
    	fax = p_fax,
    	email = p_email
        where employeeid = p_id;
end;
$$ language plpgsql;

select update_emp(10, '1988-10-30', 'Hwy 166 S', 'Pocahontas', 'AR', 'US', '72566', '888-888-9999', 'blahblah', 'bkjr@gmail.com');



-- Task 2 – Create a stored procedure that returns the managers of an employee.
create table e_managers (
	employeeid serial primary key,
	m_name text,
	e_name text
);

create or replace function employeeManagers()
returns refcursor as $$
	declare
		ref refcursor;
	begin
		open ref for select 
			concat(m.firstname, ', ', m.lastname) as "Manager Name",
			concat(e.firstname, ', ', e.lastname) as "Employee Name"
			from employee as m
			inner join employee as e  
			on m.employeeid = e.reportsto
			order by m.employeeid;
		return ref;
	end;
$$ language plpgsql;

do $$
declare
    curs refcursor;
  	v_m_name text;
  	v_e_name text;
begin
    select employeeManagers() into curs;
   	loop
        fetch curs into v_m_name, v_e_name;
        exit when not found;
        insert into e_managers (m_name, e_name) values(v_m_name, v_e_name);
   	end loop;
end;
$$ language plpgsql;

select * from e_managers;


--| 4.3 Stored Procedure Output Parameters |---------------------------------------------------------

-- Task 1 – Create a stored procedure that returns the name and company of a customer.
create table temp_customers (
	id serial primary key,
	name text,
	company text
);

create or replace function getCustomers()
returns refcursor as $$
	declare
		ref refcursor;
	begin
		open ref for select 
			concat(firstname, ' ', lastname),
			company
			from customer
			order by customerid;
		return ref;
	end;
$$ language plpgsql;

do $$
declare
    curs refcursor;
  	v_name text;
  	v_company text;
begin
    select getCustomers() into curs;
   	loop
        fetch curs into v_name, v_company;
        exit when not found;
        insert into temp_customers (name, company) values(v_name, v_company);
   	end loop;
end;
$$ language plpgsql;

select * from temp_customers;


--| 5.0 Transactions |---------------------------------------------------------

-- Task 1 – Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, find out how to resolve them).
begin;
	delete from invoice where invoiceid = 405;
commit;

-- Task 2 – Create a transaction nested within a stored procedure that inserts a new record in the Customer table
create or replace function insert_customer(
	p_id integer, 
	p_firstname varchar, 
	p_lastname varchar, 
	p_company varchar, 
	p_address varchar, 
	p_city varchar, 
	p_state varchar, 
	p_country varchar, 
	p_postalcode varchar, 
	p_phone varchar, 
	p_fax varchar, 
	p_email varchar, 
	p_supportrepid int
) 
returns void as $$
	begin
		insert into customer values(p_id, p_firstname, p_lastname, p_company, p_address, p_city, p_state, p_country, p_postalcode, p_phone, p_fax, p_email, p_supportrepid);
	end;
$$ language plpgsql;

select insert_customer(62, 'Ricky', 'Bobby', 'Revature', 'Hwy 166 N', 'Talledaga', 'ZZ', 'US', '77777', '888-888-8888', '999-999-999', 'shakeandbake@yahoo.com', 9);



--| 6.1 AFTER/FOR |---------------------------------------------------------

create or replace function hello_world()
returns trigger as $$
	begin
		raise 'Hello, World';
	end;
$$ language plpgsql;

-- Task 1 - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
create trigger after_employee_insert
	after insert on employee
	for each row
    execute procedure hello_world();
   
drop trigger after__employee_insert on employee;

-- Task 2 – Create an after update trigger on the album table that fires after a row is inserted in the table
create trigger after_album_update
	after update on album
	for each row
    execute procedure hello_world();
   
insert into album values (350, 'Testing', 275);
update album set title = 'Updated Title' where albumid = 350;
select * from album;
delete from album where albumid = 350;

drop trigger after_album_update on album;

-- Task 3 – Create an after delete trigger on the customer table that fires after a row is deleted from the table.
create trigger after_customer_delete
	after delete on customer
	for each row
    execute procedure hello_world();
   
insert into customer (customerid, firstname, lastname, email) values (62, 'John', 'Doe', 'jd@gmail.com');
select * from customer;
delete from customer where customerid = 62;

drop trigger after_customer_delete on customer;


--| 7.1 INNER |---------------------------------------------------------



-- Task 1 – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
-- ***!!! Table Names didn't line up with actual tables in the database. !!!***
-- ***!!! I made the assumption that it meant customer and invoice table. !!!***
select 
	c.firstname as "First Name", 
	c.lastname as "Last Name", 
	i.invoiceid as "Invoice ID"
from customer as c
inner join invoice as i 
on c.customerid = i.customerid
order by c.lastname;


--| 7.2 OUTER |---------------------------------------------------------

-- Task 2 – Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
select 
	c.customerid as "Customer Id", 
	c.firstname as "First Name", 
	c.lastname as "Last Name", 
	i.invoiceid as "Invoice Id", 
	i.total as "Total"
from customer as c
full outer join invoice as i 
on c.customerid = i.customerid;


--| 7.3 RIGHT |---------------------------------------------------------

-- Task 3 – Create a right join that joins album and artist specifying artist name and title.
select 
	ar.name as "Artist Name", 
	al.title as "Album Title"
from artist as ar
right join album as al
on ar.artistid = al.artistid;


--| 7.4 CROSS |---------------------------------------------------------

-- Task 4 – Create a cross join that joins album and artist and sorts by artist name in ascending order.
select * from
album cross join artist  
order by artist.name asc;


--| 7.5 SELF |---------------------------------------------------------

-- Task 5 – Perform a self-join on the employee table, joining on the reportsto column.

select 
	e.title as "Employee Title", 
	concat(e.lastname, ', ', e.firstname) as "Employee Name",
	e.reportsto as "Reports To", 
	m.title as "Manager Title", 
	concat(m.lastname, ', ', m.firstname) as "Manager Name",
	m.employeeid as "Manager ID"
from employee as e
inner join employee as m 
on e.reportsto = m.employeeid
order by m.employeeid asc;