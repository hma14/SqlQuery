select count(distinct [SalesOrderID]) as UniqueOrders,
avg(UnitPrice) as Avg_UnitPrice,
Min(OrderQty) as Min_OrderQty,
Max(LineTotal) as Max_LineTotal

from [Sales].[SalesOrderDetail]

select SalesPersonID, Year(OrderDate) as OrderYear,
Count(CustomerID) as All_Custs,
count(distinct CustomerID) as Unique_Custs
from [Sales].[SalesOrderHeader]
group by SalesPersonID, YEAR(OrderDate)
order by SalesPersonID

select CustomerID, SalesOrderID, TerritoryID
from [Sales].[SalesOrderHeader]
where CustomerID  in
(
select CustomerID
from [Sales].[Customer]
where TerritoryID=10
);


select CustomerID, PersonID
from [Sales].[Customer] as Cust
where exists (
select * 
from [Sales].[SalesOrderHeader] as Ord
where Cust.CustomerID = Ord.CustomerID
);

-- Equivalent to above sub query 
select distinct Cust.CustomerID, Cust.PersonID, ROW_NUMBER() over (partition by Cust.CustomerID order by Cust.CustomerID) as rownumberr
from [Sales].[Customer] as Cust
join Sales.SalesOrderHeader as soh on soh.CustomerID = Cust.CustomerID
group by Cust.CustomerID, Cust.PersonID  
--having count(1) > 10
order by Cust.CustomerID

select Cust.CustomerID, Cust.PersonID, count(*) as Total_Entries
from [Sales].[Customer] as Cust
join Sales.SalesOrderHeader as soh on soh.CustomerID = Cust.CustomerID
group by Cust.CustomerID, Cust.PersonID  
--having count(1) > 10
order by Cust.CustomerID




select * from (
	select 
		rank() over (partition by CustomerID Order by OrderDate DESC) as RN
		, *
	from [Sales].[SalesOrderHeader]
	) as a
	where RN = 1;

with a as (
	select rank() over (partition by CustomerID Order By OrderDate DESC) as RN
	, *
	from [Sales].[SalesOrderHeader]
) 
select * from a
where RN = 3;


--dense_rank()


GO
SELECT i.ProductID, p.Name, i.LocationID, i.Quantity
    ,DENSE_RANK() OVER 
    (PARTITION BY i.LocationID ORDER BY i.Quantity DESC) AS Rank
FROM Production.ProductInventory AS i 
INNER JOIN Production.Product AS p 
    ON i.ProductID = p.ProductID
WHERE i.LocationID BETWEEN 3 AND 4
ORDER BY i.LocationID;
GO



-- create function
GO
create function Sales.fnCustomerSales(@StartDate DATE, @EndDate DATE)
returns table
as
return (
	select 
		c.CustomerId
		,c.AccountNumber
		,isnull (Sum(sod.UnitPrice), 0) as TotalSales
	from Sales.Customer as c
	left outer join Sales.SalesOrderHeader as soh on soh.CustomerID = c.CustomerID
	left outer join Sales.SalesOrderDetail as sod on sod.SalesOrderID = soh.SalesOrderID
	where soh.OrderDate >= @StartDate and soh.OrderDate < @EndDate
	group by c.CustomerID, c.AccountNumber

);

GO
--using where clause and having clause together
create function Sales.fnCustomerSalesGreaterThan(@StartDate DATE, @EndDate DATE, @totalSales int)
returns table
as
return (
	select c.CustomerId
	,c.AccountNumber
	,isnull (Sum(sod.UnitPrice), 0) as TotalSales
	from Sales.Customer as c
	left outer join Sales.SalesOrderHeader as soh on soh.CustomerID = c.CustomerID
	left outer join Sales.SalesOrderDetail as sod on sod.SalesOrderID = soh.SalesOrderID
	where soh.OrderDate >= @StartDate and soh.OrderDate < @EndDate
	group by c.CustomerID, c.AccountNumber 
	having Sum(sod.UnitPrice) >= @totalSales
);

GO

-- call function Sales.fnCustomerSalesGreaterThan()

select * from Sales.fnCustomerSalesGreaterThan('20110101', '20130101', 130000);

GO


select c.CustomerId
		,c.AccountNumber
		,isnull (Sum(sod.UnitPrice), 0) as TotalSales
	from Sales.Customer as c
	left outer join Sales.SalesOrderHeader as soh on soh.CustomerID = c.CustomerID
	left outer join Sales.SalesOrderDetail as sod on sod.SalesOrderID = soh.SalesOrderID
	where soh.OrderDate >= '20110101' and soh.OrderDate < '20130101'
	group by c.CustomerID, c.AccountNumber
	having Sum(sod.UnitPrice) >= 100000


--using function above
select * from sales.fnCustomerSales('20110101', '20130101') as a


-- Apply
-- Apply operator allows you to join two table expressions
select 
	c.CustomerID
	,c.AccountNumber
	,o.*
from Sales.Customer AS c
 outer APPLY (
	select top(5) soh.OrderDate, soh.SalesOrderID 
	from Sales.SalesOrderHeader as soh
	where soh.CustomerID = c.CustomerID
	order by soh.OrderDate DESC
) as o
where c.TerritoryID = 3

GO

select 
	c.CustomerID
	,c.AccountNumber
	,o.*
from Sales.Customer AS c
 outer APPLY (
	select soh.OrderDate, soh.SalesOrderID 
	from Sales.SalesOrderHeader as soh
	where soh.CustomerID = c.CustomerID
	
) as o
where c.TerritoryID = 3
order by o.OrderDate ASC

GO

-- Since OUTER APPLY almost equivalent to OUTER JOIN CROSS APPLY equivalent to INNER JOIN 
select 
	c.CustomerID
	,c.AccountNumber
	,soh.OrderDate
	,soh.SalesOrderID
from Sales.Customer as c
left outer join Sales.SalesOrderHeader as soh on soh.CustomerId = c.CustomerID
where c.TerritoryID = 3
order by soh.OrderDate ASC

GO

-- create table valued function for above scenerio
create function Sales.fnGetAllSalesOrderHeader(@customerId int)
returns table
as 
return (
	select soh.OrderDate
		   ,soh.SalesOrderID
	from Sales.SalesOrderHeader as soh
	where soh.CustomerID = @customerId
);

GO

-- replace above OUTER APPLY example with this Sales.fnGetAllSalesOrderHeader
-- So OUTER APPLY can pass c.CustomerID to Sales.fnGetAllSalesOrderHeader, but LEFT OUTER JOIN cannot do this 

select c.CustomerID
	,c.AccountNumber
	,OrderDate
	,SalesOrderID	
from Sales.Customer as c
OUTER APPLY Sales.fnGetAllSalesOrderHeader(c.CustomerID)

GO

select c.CustomerID
	,c.AccountNumber
	,OrderDate
	,SalesOrderID	
from Sales.Customer as c
CROSS APPLY Sales.fnGetAllSalesOrderHeader(c.CustomerID)

GO

--OVER(PARTITION BY )
select CustomerID, OrderDate, TotalDue,
	SUM(TotalDue) OVER(PARTITION BY CustomerID) as TotalDueByCust
from Sales.SalesOrderHeader
 --select * from Sales.SalesOrderHeader

-- PIVOT
select VendorID, [250] as Emp1, [251] as Emp2, [256] as Emp3, [257] as Emp4, [260] as Emp5
from 
(select PurchaseOrderID, EmployeeID, VendorID
from Purchasing.PurchaseOrderHeader) p
PIVOT
(
	count(PurchaseOrderID)
	for EmployeeID IN ([250], [251], [256], [257], [260])
) as pvt
order by pvt.VendorID;




-- For XML

select 
	ProductID
	,Name 
into Products
from Production.Product;

select 
	ProductID as "@id"   -- @ becomes attribute rather than element in xml
	,Name as "@name" 
from Products
where Name like 'A%'
FOR XML PATH('product'), ROOT('products');




select * from Production.Product as p
where p.Name like 'A%'
--FOR XML PATH('product'), ROOT('products');  -- columns are mapped to elements
FOR XML AUTO, ROOT('products'); -- columns become attributes rather than elements


-- xml result

GO


declare @Xml XML = N'
<products>
  <product id="1" name="Adjustable Race!" />
  <product id="879" name="All-Purpose Bike Stand!" />
  <product id="712" name="AWC Logo Cap!" />
  <product id="1001" delete="true" name="Henry" />
</products>';

-- CTE: Common Table Expression
WITH src AS 
(
select 
	xt.xc.value('@id', 'INT') as ProductID
	,xt.xc.value('@name', 'NVARCHAR(1000)') AS Name
	,ISNULL(xt.xc.value('@delete', 'BIT'), 0) AS DoDelete
	from @Xml.nodes('/products/product') as xt(xc)

)
MERGE INTO Products AS dest
	using src on src.ProductID = dest.ProductID
WHEN NOT MATCHED THEN
	INSERT (Name) VALUES(src.Name)
WHEN MATCHED AND src.DoDelete = 0 THEN
	UPDATE SET Name = src.Name
WHEN MATCHED AND src.DoDelete = 1 THEN
	DELETE;

GO

select 
	ProductID as "@id"   -- @ becomes attribute rather than element in xml
	,Name as "@name" 
from Products
where Name like 'A%' OR Name LIKE 'hen%'
FOR XML PATH('product'), ROOT('products');



--Execution Plan
GO
Select * 
into Sales.IndexTest
from Sales.SalesOrderDetail

GO
exec sp_helpindex 'Sales.IndexTest'
drop index CluIdx on Sales.IndexTest
drop index NCIdx on Sales.IndexTest

SET STATISTICS IO ON;
--When STATISTICS IO is ON, 
--statistical information is displayed. When OFF, the information is not displayed.
--After this option is set ON, all subsequent Transact-SQL statements return the 
--statistical information until the option is set to OFF.

--select SpecialOfferID, count(SpecialOfferID) from Sales.IndexTest
--select SpecialOfferID, count(*) from Sales.IndexTest
select SpecialOfferID, count(1) from Sales.IndexTest
group by SpecialOfferID 

-- no index: logical reads 1499,

select 
	SalesOrderID
	,Sum(UnitPrice * OrderQty) as Total
from Sales.IndexTest WITH(INDEX(NCIdx))
where SpecialOfferID = 1
Group by SalesOrderID
Order By Total

GO
-- Create index: logical reads 1525,

drop index CluIdx on Sales.IndexTest;
create clustered index CluIdx ON Sales.IndexTest (SpecialOfferID)
GO
-- Create
drop index CluIdx on Sales.IndexTest;
create clustered index CluIdx ON Sales.IndexTest (SalesOrderID)

drop index NCIdx ON Sales.IndexTest;
create nonclustered index NCIdx on Sales.IndexTest (SpecialOfferID)

drop index NCIdx ON Sales.IndexTest;
create nonclustered index NCIdx on Sales.IndexTest (SpecialOfferID) INCLUDE (SalesOrderID, UnitPrice, OrderQty);



drop index NCIdx ON Sales.IndexTest;
create nonclustered index NCIdx on Sales.IndexTest (SpecialOfferID, SalesOrderID) INCLUDE (UnitPrice, OrderQty);



