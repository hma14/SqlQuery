/****** Script for SelectTopNRows command from SSMS  ******/
select * from employee

GO
select max(salary) from employee
where salary < (select max(salary) from employee)


-- select second highest salary
select top 1 salary from
(select distinct top 2 salary
from employee
order by salary desc) as result
order by salary


select top 2 salary  from employee order by salary desc
GO

-- select second highest salary (2)
select  Max(Salary) 
from employee
where Salary not in (select max(salary) from employee)


select distinct salary, DENSERANK from 
(select salary, DENSE_RANK() over (order by salary desc) as DENSERANK
from employee) result
where DENSERANK = 2

GO
-- CTE: Common Table Expression
with result as
(
select salary, DENSE_RANK() over (order by salary desc) as DENSERANK
from employee
)
select top 1 salary
from result
where result.DENSERANK = 3

-- get employee name and his/her manager name
use [Interview]
select * from emp

select e.EmployeeName as 'Employee Name', isnull(m.EmployeeName, 'No Boss') as 'Boss Name'
from emp e
LEFT OUTER JOIN emp m on e.ManagerID = m.EmployeeID

GO
-- given an employee ID to find out his/her managers - this won't work well
Declare @ID int;
Set @ID = 4;
select e.EmployeeName as 'Employee Name', isnull(m.EmployeeName, 'No Boss') as 'Boss Name'
from emp e
LEFT OUTER JOIN emp m on e.ManagerID = m.EmployeeID
where e.EmployeeID = @ID

GO


-- given an employee ID to find out his/her managers - this will work

use [Interview]

-- CTE example

Declare @ID int;
Set @ID = 4;
with empCTE as 
(
	select EmployeeID, EmployeeName, ManagerId 
	from emp
	where EmployeeID=4

	union all

	select  e.EmployeeID, e.EmployeeName, e.ManagerId 
	from emp as e
	join empCTE cte on e.EmployeeID = cte.ManagerID	
)

--select * from empCTE
select e.EmployeeName as 'Employee Name', isnull(m.EmployeeName, 'No Boss') as 'Manager Name'
from empCTE as e
left outer join empCTE as m
on m.EmployeeID = e.ManagerID

GO


--Delete duplicate rows in sql

With employeeDupCTE AS
(
	select *, ROW_NUMBER() OVER(Partition BY  ID order BY ID) as RowNumber
	from employeeDup
)
select * from employeeDupCTE
insert into employeeDup values(2, 'Henry', 'Ma', 'Male', 89900)
insert into employeeDup values(2, 'Stella', 'Fang', 'Female', 70000)

delete from employeeDupCTE where RowNumber > 1


-- There is a table which contains two column Student and Marks, you need to find all the students, 
-- whose marks are greater than average marks i.e. list of above average students.

select ftudent, marks from tbl 
where marks > (select avg(marks) from tbl)




-- Transform Rows into Columns using Pivot

select Country, City1, City2, City3
from
(
	select Country, City,
	'City' + cast(row_number() over(partition by Country order by Country) as varchar (10) ) ColumnSequence
	from Countries
) Temp
pivot
(
	max(City)
	for ColumnSequence in (City1, City2, City3)
) Piv



GO

-- Query to find rows that contain only numerical data - using ISNUMERIC()

select Value from TestTable
where ISNUMERIC(Value) = 1


GO

-- Find department with highest number of employee

select top 1 d.Name
from employees e
join departments d on e.DepartmentID = d.ID
group by d.Name 
order by Count(*) desc

select * from departments
select * from employees

GO

-- Inner Join, outer join
insert into employees values(6, 'Pam', null)

-- inner join
select e.Name as EmployeeName, d.Name as DepartmentName
from employees e
join Departments d on e.DepartmentID = d.ID

-- left join

select e.Name as EmployeeName, d.Name as DepartmentName
from employees e
left join Departments d on e.DepartmentID = d.ID

-- right join 

select e.Name as EmployeeName, d.Name as DepartmentName
from employees e
right join Departments d on e.DepartmentID = d.ID

-- full join
insert into Departments values(4, 'Admin')

select e.Name as EmployeeName, d.Name as DepartmentName
from employees e
full join Departments d on e.DepartmentID = d.ID


-- join 3 tables in sql, select total employees in each Department and for each gender

Select DepartmentName, Gender, Count(*) as TotalEmployees
from Employees 
Join Departments on Employees.DepartmentID = Department.DepartmentID
Join Genders on Genders.GenderID = Employees.GenderID
GROUP BY DepartmentName, Gender
ORDER BY DepartmentName, Gender


-- 

select isdate('12/15/15') as 'MM/DD/YY'

-- Write an SQL Query find number of employees according to Gender whose BirthDate is between 01/01/1960 to 31/12/1975.
use AdventureWorks2014

select Gender, count(*) as TotalEmployee from [HumanResources].[Employee]
where BirthDate between '1960-01-01' and '1975-12-31'
group by Gender


-- Write an SQL Query to find name of employee whose firstname Start with ‘M’

select * 
from [Person].[Person]
where FirstName like 'M%'

--find all Employee records containing the word "Joe", regardless of whether it was stored as JOE, Joe, or joe.

select * 
from Person.Person
where Upper(FirstName) like '%JOE%' 

select year(getdate()) - 1 as Year
select month(getdate()) - 1 as 'Last Month'

select datediff(Month, '2015-11-01', GETDATE()) 


select * 
from [Person].[Person]
where  = (select max(rowid)