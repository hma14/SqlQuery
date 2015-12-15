SET NOCOUNT ON
EXEC sys.sp_addextendedproperty 
@name=N'MS_Description', 
@value=N'Street address information for customers, employees, and vendors.' ,
@level0type=N'SCHEMA', 
@level0name=N'Person', --Schema Name
@level1type=N'TABLE', 
@level1name=N'Address' --Table Name
GO


EXEC sys.sp_addextendedproperty 
@name=N'MS_Description', 
@value=N'Second street address line.' ,
@level0type=N'SCHEMA', 
@level0name=N'Person', --Schema Name
@level1type=N'TABLE', 
@level1name=N'Address',--Table Name 
@level2type=N'COLUMN', 
@level2name=N'AddressLine2'--Column Name
GO

-- Explicit Cross Join

USE AdventureWorks2014;

GO
SELECT p.BusinessEntityID, t.Name AS Territory
FROM Sales.SalesPerson p
CROSS JOIN Sales.SalesTerritory t
ORDER BY p.BusinessEntityID;

-- Implicit Cross Join

GO
SELECT p.BusinessEntityID, t.Name AS Territory
FROM Sales.SalesPerson p, Sales.SalesTerritory t
ORDER BY p.BusinessEntityID;

-- Cross Join with Where clause like inner join
GO
SELECT p.BusinessEntityID, t.Name AS Territory
FROM Sales.SalesPerson p
CROSS JOIN Sales.SalesTerritory t
WHERE p.TerritoryID = t.TerritoryID
ORDER BY p.BusinessEntityID;



-- tricky problem: result will be 'Nope'

select case when null = null then 'Yup' else 'Nope' end as Result;


-- correct one: using 'is' instead of '=' to compare null

select case when null is null then 'Yup' else 'Nope' end as Result;


--If the set being evaluated by the SQL NOT IN condition contains any values that are null, 
--then the outer query here will return an empty set, 

select * from [Sales].[Customer] as c
where c.CustomerID not in (select distinct soh.CustomerID from [Sales].[SalesOrderHeader] as soh)

-- to solve the problem

select * from [Sales].[Customer] as c
where c.CustomerID not in (select distinct soh.CustomerID from [Sales].[SalesOrderHeader] as soh 
							where soh.CustomerID is not null)


-- The expression OrderYear in the WHERE clause is invalid. Even though 
-- it is defined as an alias in the SELECT phrase, which appears before 
-- the WHERE phrase, the logical processing order of the phrases of the 
-- statement is different from the written order. 
-- Most programmers are accustomed to code statements being processed 
-- generally top-to-bottom or left-to-right, but T-SQL processes phrases 
-- in a different order.

-- Wrong
select [SalesOrderID], year([OrderDate]) as OrderYear
from [Sales].[SalesOrderHeader]
where OrderYear >= 2010

-- Correct
GO
select [SalesOrderID], year([OrderDate]) as OrderYear
from [Sales].[SalesOrderHeader]
where year([OrderDate]) >= 2010
GO

-- 

create table Invoices(
	Id int not null,
	BillingDate Date not null,
	CustomerId int not null

);

create table Customers
(
	Id int not null,
	Name nvarchar(50) not null,
	ReferredBy int 
);

-- Write a SQL query to return a list of all the invoices. 
-- For each invoice, show the Invoice ID, the billing date, 
-- the customer’s name, and the name of the customer who 
-- referred that customer (if any). -
-- The list should be ordered by billing date

select i.Id, i.BillingDate, c.Name as Customer, r.Name as ReferredByName
from Invoices as i
left join Customers as c on i.CustomerId = c.Id -- using LEFT JOIN: in order to guarantee that all Invoices are returned no matter what
left join Customers as r on c.ReferredBy = r.Id
order by i.BillingDate


-- Assume a schema of Emp ( Id, Name, DeptId ) , Dept ( Id, Name).
-- If there are 10 records in the Emp table and 5 records in the Dept table, 
-- how many rows will be displayed in the result of the following SQL query:

Select * From Emp, Dept

-- Answer: The query will result in 50 rows as a “cartesian product” or “cross join”, 
-- which is the default whenever the ‘where’ clause is omitted.

-- Given a table SALARIES, such as the one below, that has m = male 
-- and f = female values. Swap all f and m values (i.e., change all 
-- f values to m and vice versa) with a single update query and no intermediate temp table.

--Id  Name  Sex  Salary
--1   A     m    2500
--2   B     f    1500
--3   C     m    5500
--4   D     f    500

use tempdb
GO
create table Salaries
(
	Name varchar(2),
	Sex  varchar(1),
	Salary int
)

insert into Salaries values('A', 'm', 2500)
insert into Salaries values('B', 'f', 1500)
insert into Salaries values('C', 'm', 5500)
insert into Salaries values('D', 'f', 500)

select * from Salaries
update SALARIES set Sex = case Sex when 'm' then 'f' else 'm' end 
select * from Salaries
-- or
update SALARIES set Sex = case when Sex='m' then 'f' else 'm' end 
select * from Salaries

GO

-- Given two tables created as follows

use [tempdb]
create table test_a(id numeric);

create table test_b(id numeric);

insert into test_a(id) values
  (10),
  (20),
  (30),
  (40),
  (50);

insert into test_b(id) values
  (10),
  (30),
  (50);

  -- Write a query to fetch values in table test_a that are and not in test_b without using the NOT keyword.

select a.id from test_a a
where a.id not in (select b.id from test_b b)

select a.id from test_a a
where not exists (select b.id from test_b b where a.id = b.id)

-- Correct answwer - using keyword: except
select a.id from test_a a
except 
select b.id from test_b b

-- opposite: instersect
select a.id from test_a a
intersect 
select b.id from test_b b


--Given a table TBL with a field Nmbr that has rows with the following values:

--1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1

--Write a query to add 2 where Nmbr is 0 and add 3 where Nmbr is 1.

update TBL set Nmbr = case Nmbr when 0 then 2 else 1 + 3 end

-- or 

update TBL set Nmbr = case when Nmbr > 0 then Nmbr+3 else Nmbr+2 end;

GO
use tempdb
GO
drop table TBL;
GO
create table TBL
(
	Nmbr int
)

GO

insert into TBL Values(1)
insert into TBL Values(0)
insert into TBL Values(1)
insert into TBL Values(1)
insert into TBL Values(1)
insert into TBL Values(1)
insert into TBL Values(0)
insert into TBL Values(0)
insert into TBL Values(1)
insert into TBL Values(0)
insert into TBL Values(1)
insert into TBL Values(0)
insert into TBL Values(1)


select * from TBL

--update TBL set Nmbr = case when Nmbr > 0 then Nmbr + 3 else Nmbr + 2 end

--or

update TBL set Nmbr = case Nmbr when 0 then Nmbr + 2 else Nmbr + 3 end

select * from TBL

GO

--Write a SQL query to find the 10th highest employee salary from an Employee table. Explain your answer.

--(Note: You may assume that there are at least 10 records in the Employee table.)

--RANK gives you the ranking within your ordered partition. Ties are assigned the same rank, 
--with the next ranking(s) skipped. So, if you have 3 items at rank 2, the next rank listed 
--would be ranked 5.
--DENSE_RANK again gives you the ranking within your ordered partition, but the ranks are 
--consecutive. No ranks are skipped if there are ranks with multiple items.
--As for nulls, it depends on the ORDER BY clause.

use Interview

declare @rank int;
set @rank = 2;
SELECT TOP (1) Salary FROM
(
    SELECT DISTINCT TOP (@rank) Salary FROM employee ORDER BY Salary DESC
) AS Emp ORDER BY Salary

GO
-- example for Dense_Rank()
use Interview
declare @rank int;
set @rank = 4;

with salaryCTE as
(
	select FirstName + ' ' + LastName as Name, Salary, dense_rank() over (order by Salary DESC) as Rnk
	from employee 
) 

select s.Name, s.Salary, s.Rnk from salaryCTE as s
where s.Rnk = @rank
GO

-- or without using CTE, instead using sub query

use Interview
declare @rank int;
set @rank = 1;


select FirstName + ' ' + LastName as Name, Salary
from (
	select *, dense_rank() over (order by Salary DESC) as Rnk
	from employee
) salary_rnk


where Rnk = @rank

GO

-- example for Rank()
use Interview
declare @rank int;
set @rank = 3;

with salaryCTE2 as 
(
	select FirstName + ' ' + LastName as Name, Salary, rank() over ( order by Salary DESC) rnk
	from employee
)

select s.Name, s.Salary, s.Rnk from salaryCTE2 as s
where s.Rnk = @rank

GO

-- example for Rank()
USE AdventureWorks2014;
GO
SELECT i.ProductID, p.Name, i.LocationID, i.Quantity
    ,RANK() OVER 
    (PARTITION BY i.LocationID ORDER BY i.Quantity DESC) AS Rank
FROM Production.ProductInventory AS i 
INNER JOIN Production.Product AS p 
    ON i.ProductID = p.ProductID
WHERE i.LocationID BETWEEN 3 AND 4
ORDER BY i.LocationID;
GO


--Write a SQL query using UNION ALL (not UNION) that uses the WHERE clause 
--to eliminate duplicates. Why might you want to do this?

use Interview;

-- X = (select ID from employee) 
-- Y = (select ID from employeeDup)

select * from employee e where ID in (select ID from employee) 
UNION ALL 
select * from employeeDup e2 where e2.ID in (select e2.ID from employeeDup) and e2.ID not in (select ID from employee)


-- duplicate 
select * from employee 
union all 
select * from employee 

-- instersect
select * from employee 
intersect
select * from employee 


--SELECT * FROM employee WHERE a=X UNION ALL SELECT * FROM employee WHERE b=Y AND a!=X




select * from employee
union all
select * from employeeDup as ed
GO
select * from employee
union all
select * from employee as ed
where ID <> ed.ID

GO

-- find number of duplicated phones for each entries: best solution
use AdventureWorks2014

select PhoneNumber, (select  count(*) from Person.PersonPhone i where i.PhoneNumber = o.PhoneNumber) as numPhones
from Person.PersonPhone o
where BusinessEntityID < 100


-- find duplicated phone number in Person.PsersonPhone with CTE: this won't compare whole list if just select a range of 
-- rows.It just compare within the given range.
with phoneCTE as
(
	select BusinessEntityID,  PhoneNumber, ROW_NUMBER() over (partition by PhoneNumber order by PhoneNumber) as RowNumber
	from Person.PersonPhone	
)

select BusinessEntityID,  PhoneNumber, RowNumber from phoneCTE
--where BusinessEntityID < 100
order by BusinessEntityID 



-- What is an execution plan? When would you use it? 
-- How would you view the execution plan?

--An execution plan is basically a road map that graphically or textually 
--shows the data retrieval methods chosen by the SQL server’s query 
--optimizer for a stored procedure or ad hoc query. Execution plans 
--are very useful for helping a developer understand and analyze the 
--performance characteristics of a query or stored procedure, since the 
--plan is used to execute the query or stored procedure.

--In many SQL systems, a textual execution plan can be obtained using a 
--keyword such as EXPLAIN, and visual representations can often be obtained 
--as well. In Microsoft SQL Server, the Query Analyzer has an option called 
--“Show Execution Plan” (located on the Query drop down menu). If this option 
--is turned on, it will display query execution plans in a separate window 
--when a query is run.

--What is a key difference between Truncate and Delete?

--Truncate is used to delete table content and the action can not be 
--rolled back, whereas Delete is used to delete one or more rows in 
--the table and can be rolled back.