use WideWorldImporters;

go

/*
1. Напишите запрос с временной таблицей и перепишите его с табличной переменной. Сравните планы. 
В качестве запроса с временной таблицей и табличной переменной можно взять свой запрос. 
Или запрос из ДЗ по Оконным функциям 
Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года (в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки)
Выведите id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом
Пример 
Дата продажи Нарастающий итог по месяцу
2015-01-29	4801725.31
2015-01-30	4801725.31
2015-01-31	4801725.31
2015-02-01	9626342.98
2015-02-02	9626342.98
2015-02-03	9626342.98
Нарастающий итог должен быть без оконной функции. 
*/

--с временой таблицей
create table #Total
(	InvoiceID int not null,
	InvoiceDate date not null,
	CustomerName nvarchar(100) not null,
	SaleAmount decimal not null,
	Summ decimal not null
);

set statistics time on;

insert into #Total
select 
	IL.InvoiceID,
	I.InvoiceDate,
	C.CustomerName,
	IL.Quantity*IL.UnitPrice as [Sale Amount],
	(select sum(ILInner.Quantity*ILInner.UnitPrice)
		from [Sales].[InvoiceLines] as ILInner
		join [Sales].[Invoices] as IInner
		on IInner.InvoiceID = ILInner.InvoiceID
		where IInner.InvoiceDate  >= '2015-01-01' 
		and IInner.InvoiceDate <= eomonth(I.InvoiceDate)
		) as [Sale Amount by Month]
from [Sales].[InvoiceLines] as IL
join [Sales].[Invoices] as I on I.InvoiceID = IL.InvoiceID
join [Sales].[Customers] as C on C.CustomerID = I.CustomerID
where I.InvoiceDate  >= '2015-01-01'
order by I.InvoiceDate, [Sale Amount], IL.InvoiceID, C.CustomerName


set statistics time off;

select *
from #Total
order by InvoiceID, InvoiceDate

/*

 SQL Server Execution Times:
   CPU time = 41781 ms,  elapsed time = 48287 ms.

*/

--с табличной переменной

declare @Total table
(	InvoiceID int not null,
	InvoiceDate date not null,
	CustomerName nvarchar(100) not null,
	SaleAmount decimal not null,
	Summ decimal not null
);

set statistics time on;

insert into @Total
select 
	IL.InvoiceID,
	I.InvoiceDate,
	C.CustomerName,
	IL.Quantity*IL.UnitPrice as [Sale Amount],
	(select sum(ILInner.Quantity*ILInner.UnitPrice)
		from [Sales].[InvoiceLines] as ILInner
		join [Sales].[Invoices] as IInner
		on IInner.InvoiceID = ILInner.InvoiceID
		where IInner.InvoiceDate  >= '2015-01-01' 
		and IInner.InvoiceDate <= eomonth(I.InvoiceDate)
		) as [Sale Amount by Month]
from [Sales].[InvoiceLines] as IL
join [Sales].[Invoices] as I on I.InvoiceID = IL.InvoiceID
join [Sales].[Customers] as C on C.CustomerID = I.CustomerID
where I.InvoiceDate  >= '2015-01-01'
order by I.InvoiceDate, [Sale Amount], IL.InvoiceID, C.CustomerName

set statistics time off;

select *
from @Total
order by InvoiceID, InvoiceDate

/*

SQL Server Execution Times:
   CPU time = 42609 ms,  elapsed time = 52427 ms.


   Запрос с временой таблицей отработал быстрее.
*/

/*
2. Написать рекурсивный CTE sql запрос и заполнить им временную таблицу и табличную переменную
Дано :
CREATE TABLE dbo.MyEmployees 
( 
EmployeeID smallint NOT NULL, 
FirstName nvarchar(30) NOT NULL, 
LastName nvarchar(40) NOT NULL, 
Title nvarchar(50) NOT NULL, 
DeptID smallint NOT NULL, 
ManagerID int NULL, 
CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC) 
); 
INSERT INTO dbo.MyEmployees VALUES 
(1, N'Ken', N'Sánchez', N'Chief Executive Officer',16,NULL) 
,(273, N'Brian', N'Welcker', N'Vice President of Sales',3,1) 
,(274, N'Stephen', N'Jiang', N'North American Sales Manager',3,273) 
,(275, N'Michael', N'Blythe', N'Sales Representative',3,274) 
,(276, N'Linda', N'Mitchell', N'Sales Representative',3,274) 
,(285, N'Syed', N'Abbas', N'Pacific Sales Manager',3,273) 
,(286, N'Lynn', N'Tsoflias', N'Sales Representative',3,285) 
,(16, N'David',N'Bradley', N'Marketing Manager', 4, 273) 
,(23, N'Mary', N'Gibson', N'Marketing Specialist', 4, 16); 

Результат вывода рекурсивного CTE:
EmployeeID Name Title EmployeeLevel
1	Ken Sánchez	Chief Executive Officer	1
273	| Brian Welcker	Vice President of Sales	2
16	| | David Bradley	Marketing Manager	3
23	| | | Mary Gibson	Marketing Specialist	4
274	| | Stephen Jiang	North American Sales Manager	3
276	| | | Linda Mitchell	Sales Representative	4
275	| | | Michael Blythe	Sales Representative	4
285	| | Syed Abbas	Pacific Sales Manager	3
286	| | | Lynn Tsoflias	Sales Representative	4
*/

create table dbo.MyEmployees 
( 
EmployeeID smallint NOT NULL, 
FirstName nvarchar(30) NOT NULL, 
LastName nvarchar(40) NOT NULL, 
Title nvarchar(50) NOT NULL, 
DeptID smallint NOT NULL, 
ManagerID int NULL, 
constraint PK_EmployeeID primary key clustered (EmployeeID asc) 
); 

insert into dbo.MyEmployees
values 
(1, N'Ken', N'Sánchez', N'Chief Executive Officer',16,NULL) 
,(273, N'Brian', N'Welcker', N'Vice President of Sales',3,1) 
,(274, N'Stephen', N'Jiang', N'North American Sales Manager',3,273) 
,(275, N'Michael', N'Blythe', N'Sales Representative',3,274) 
,(276, N'Linda', N'Mitchell', N'Sales Representative',3,274) 
,(285, N'Syed', N'Abbas', N'Pacific Sales Manager',3,273) 
,(286, N'Lynn', N'Tsoflias', N'Sales Representative',3,285) 
,(16, N'David',N'Bradley', N'Marketing Manager', 4, 273) 
,(23, N'Mary', N'Gibson', N'Marketing Specialist', 4, 16);

--вставка у временную таблицу
create table #Employees(
	EmployeeID smallint NOT NULL, 
	Name nvarchar(1000) not null, 
	Title nvarchar(50) NOT NULL,	
	EmployeeLevel smallint NOT NULL);

; with EmployeesCTE(EmployeeID, Name, Title, EmployeeLevel, Offset) as
(
	select EmployeeID,
		cast(FirstName + N' ' + LastName as nvarchar(1000)) collate database_default as Name,
		Title,
		1 as EmployeeLevel,
		0 as Offset
	from dbo.MyEmployees 
	where ManagerID is null
	union all
	select E2.EmployeeID,
		cast((N'| ' + left(CTE.Name, CTE.Offset) + E2.FirstName + N' ' + E2.LastName) as nvarchar(1000)) collate database_default,
		E2.Title,
		CTE.EmployeeLevel + 1,
		CTE.Offset + 2
	from dbo.MyEmployees  as E2
	inner join EmployeesCTE as CTE on E2.ManagerID = CTE.EmployeeID
)
insert into #Employees
select EmployeeID, Name, Title,	EmployeeLevel
from EmployeesCTE
order by EmployeeID

select *
from #Employees

go 

--вставка в табличную переменную

declare @Employees Table (
	EmployeeID smallint NOT NULL, 
	Name nvarchar(1000) not null, 
	Title nvarchar(50) NOT NULL,	
	EmployeeLevel smallint NOT NULL);

; with EmployeesCTE(EmployeeID, Name, Title, EmployeeLevel, Offset) as
(
	select EmployeeID,
		cast(FirstName + N' ' + LastName as nvarchar(1000)) collate database_default as Name,
		Title,
		1 as EmployeeLevel,
		0 as Offset
	from dbo.MyEmployees 
	where ManagerID is null
	union all
	select E2.EmployeeID,
		cast((N'| ' + left(CTE.Name, CTE.Offset) + E2.FirstName + N' ' + E2.LastName) as nvarchar(1000)) collate database_default,
		E2.Title,
		CTE.EmployeeLevel + 1,
		CTE.Offset + 2
	from dbo.MyEmployees  as E2
	inner join EmployeesCTE as CTE on E2.ManagerID = CTE.EmployeeID
)
insert into @Employees
select EmployeeID, Name, Title,	EmployeeLevel
from EmployeesCTE
order by EmployeeID

select *
from @Employees
