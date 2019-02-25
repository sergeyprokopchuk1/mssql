use WideWorldImporters;

/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года (в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки)
Вывести Ид продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом. Сделать 2 варианта запроса - через windows function и без них. Написать какой быстрее выполняется, сравнить по set statistics time on;
2. Вывести список 2х самых популярного продуктов (по кол-ву проданных) в каждом месяце за 2016й год (по 2 самых популярных продукта в каждом месяце)
3. Функции одним запросом
Посчитайте по таблице товаров, в вывод также должен попасть ид товара, название, брэнд и цена
пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
посчитайте общее количество товаров и выведете полем в этом же запросе
посчитайте общее количество товаров в зависимости от буквы начала называния товара
следующий ид товара на следующей строки (по имени) и включите в выборку 
предыдущий ид товара (по имени)
названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
сформируйте 30 групп товаров по полю вес товара на 1 шт
Для этой задачи НЕ нужно писать аналог без аналитических функций
4. По каждому сотруднику выведете последнего клиента, которому сотрудник что-то продал
В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки
5. Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки

Опционально можно сделать вариант запросов для заданий 2,4,5 без использования windows function и сравнить скорость как в задании 1. 
*/

go

-- 1.

select 
	IL.InvoiceID,
	I.InvoiceDate,
	C.CustomerName,
	IL.Quantity*IL.UnitPrice as [Sale Amount],
	SUM(IL.Quantity*IL.UnitPrice) over(partition by year(I.InvoiceDate) order by month(I.InvoiceDate)) as [Sale Amount by Month]
from [Sales].[InvoiceLines] as IL
join [Sales].[Invoices] as I
on I.InvoiceID = IL.InvoiceID
join [Sales].[Customers] as C
on C.CustomerID = I.CustomerID
where I.InvoiceDate  >= '2015-01-01'
order by I.InvoiceDate, IL.Quantity*IL.UnitPrice, IL.InvoiceID, C.CustomerName

go

-- есть проблемы с подзапросом. помесячно выводит, но без нарастающего итога

select 
	IL.InvoiceID,
	I.InvoiceDate,
	C.CustomerName,
	IL.Quantity*IL.UnitPrice as [Sale Amount],
	(select sum(ILInner.Quantity*ILInner.UnitPrice)
		from [Sales].[InvoiceLines] as ILInner
		join [Sales].[Invoices] as IInner
		on IInner.InvoiceID = ILInner.InvoiceID
		where year(IInner.InvoiceDate) = year(I.InvoiceDate)
		and month(IInner.InvoiceDate) = month(I.InvoiceDate)
		and I.InvoiceDate  >= '2015-01-01'
		) as [Sale Amount by Month]
from [Sales].[InvoiceLines] as IL
join [Sales].[Invoices] as I
on I.InvoiceID = IL.InvoiceID
join [Sales].[Customers] as C
on C.CustomerID = I.CustomerID
where I.InvoiceDate  >= '2015-01-01'
order by I.InvoiceDate, IL.Quantity*IL.UnitPrice, IL.InvoiceID, C.CustomerName

-- 2. 2. Вывести список 2х самых популярных продуктов (по кол-ву проданных) в каждом месяце за 2016й год 
--(по 2 самых популярных продукта в каждом месяце)

; with MonthQuantityCTE as
(
	select 
		Item.StockItemID, 
		Item.StockItemName,
		Inv.InvoiceDate,
		InvLine.Quantity as [Item Quantity],
		row_number() over(partition by month(Inv.InvoiceDate) order by InvLine.Quantity desc) as Quantity
	from [Sales].[InvoiceLines] as InvLine
	join [Warehouse].[StockItems] as Item
	on Item.StockItemID = InvLine.StockItemID
	join [Sales].[Invoices] as Inv
	on Inv.InvoiceID = InvLine.InvoiceID
	where year(Inv.InvoiceDate) = '2016'
)
select *
from MonthQuantityCTE
where MonthQuantityCTE.Quantity <= 2
order by MonthQuantityCTE.InvoiceDate, MonthQuantityCTE.Quantity desc

/*
3. Функции одним запросом
Посчитайте по таблице товаров, в вывод также должен попасть ид товара, название, брэнд и цена
пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
посчитайте общее количество товаров и выведете полем в этом же запросе
посчитайте общее количество товаров в зависимости от первой буквы названия товара
отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
предыдущий ид товара с тем же порядком отображения (по имени)
названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
сформируйте 30 групп товаров по полю вес товара на 1 шт
Для этой задачи НЕ нужно писать аналог без аналитических функций
*/

select
	It.StockItemID,
	It.StockItemName,
	It.Brand,
	It.UnitPrice,
	ROW_NUMBER() over(partition by left(It.StockItemName, 1) order by It.StockItemName) as [Item Name Alphabetically],
	count(*) over() as [Item Count],
	count(*) over(partition by left(It.StockItemName, 1)) as [Item Count Alphabetically]
	,LEAD(It.StockItemID) over(order by It.StockItemName) as [Next ID]
	,LAG(It.StockItemID) over(order by It.StockItemName) as [Prev ID]
	,LAG(It.StockItemName, 2, 'No items') over(order by It.StockItemName)  as [Prev 2 Name]
	,NTILE(30) over(partition by It.TypicalWeightPerUnit order by It.StockItemName) as [Grouped Weight Per Unit]
from [Warehouse].[StockItems] as It


--4. По каждому сотруднику выведете последнего клиента, которому сотрудник что-то продал
--В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки

select
	distinct(P.PersonID),
	P.FullName,
	LAST_VALUE(C.CustomerID) over(partition by P.PersonID 
		order by I.InvoiceDate rows between unbounded preceding and unbounded following) as LastCustomerID,
	LAST_VALUE(C.CustomerName) over(partition by P.PersonID 
		order by I.InvoiceDate rows between unbounded preceding and unbounded following) as LastCustomerName,
	LAST_VALUE(I.InvoiceDate) over(partition by P.PersonID 
		order by I.InvoiceDate rows between unbounded preceding and unbounded following) as LastInvoiceDate,
	LAST_VALUE(CT.TransactionAmount) over(partition by P.PersonID 
		order by I.InvoiceDate rows between unbounded preceding and unbounded following) as LastTransactionAmount
from [Application].[People] as P
join [Sales].[Invoices] as I
on I.SalespersonPersonID = P.PersonID
join [Sales].[CustomerTransactions] as CT
on CT.InvoiceID = I.InvoiceID
join [Sales].[Customers] as C
on C.CustomerID = CT.CustomerID
where P.IsSalesperson = 1
order by P.PersonID


--5. Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
--В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки

; with CustomersItemsCTE as
(
	select 
		C.CustomerID,
		C.CustomerName,
		IL.StockItemID,
		SI.UnitPrice,
		I.InvoiceDate,
		row_number() over(partition by C.CustomerID order by SI.UnitPrice desc) as Number
	from [Sales].[Customers] as C
	join [Sales].[CustomerTransactions] as CT
	on CT.CustomerID = C.CustomerID
	join [Sales].[InvoiceLines] as IL
	on IL.InvoiceID = CT.InvoiceID
	join [Warehouse].[StockItems] as SI
	on SI.StockItemID = IL.StockItemID
	join [Sales].[Invoices] as I
	on I.InvoiceID = IL.InvoiceID
)
select *
from CustomersItemsCTE as Cust
where Cust.Number <= 2
order by  Cust.CustomerID, Cust.UnitPrice desc
