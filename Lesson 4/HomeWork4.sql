use WideWorldImporters

go

/*
Сделайте 2 варианта запросов:
1) через вложенный запрос
2) через WITH (для производных таблиц) 
Написать запросы:
1. Выберите сотрудников, которые являются продажниками, и еще не сделали ни одной продажи.
2. Выберите товары с минимальной ценой (подзапросом), 2 варианта подзапроса. 
3. Выберите всех клиентов у которых было 5 максимальных оплат из [Sales].[CustomerTransactions] представьте 3 способа (в том числе с CTE)
4. Выберите города (ид и название), в которые были доставлены товары входящие в тройку самых дорогих товаров, а также Имя сотрудника, 
который осуществлял упаковку заказов
*/

-- 1. Выберите сотрудников, которые являются продажниками, и еще не сделали ни одной продажи.

--
select P.PersonID, P.FullName
from [Application].[People] as P
where not exists (select I.SalespersonPersonID
	from [Sales].[Invoices] as I
	where I.SalespersonPersonID = P.PersonID)
and P.IsSalesperson = 1

go 

; with SalespersonsCTE(SalespersonPersonID) as 
(
	select O.SalespersonPersonID
	from [Sales].[Invoices] as O
)
select P.PersonID, P.FullName
from [Application].[People] as P
where 
not exists (select * from SalespersonsCTE where SalespersonPersonID = P.PersonID)
and P.IsSalesperson = 1


; with PersonCTE 
as
(
	select P.PersonID, P.FullName
	from [Application].[People] as P
	where P.[IsSalesperson] = 1
)
select P.PersonID, P.FullName
from PersonCTE as P
where not exists (select  I.SalespersonPersonID from [Sales].[Invoices] as I
where I.SalespersonPersonID = P.PersonID)


--2. Выберите товары с минимальной ценой (подзапросом), 2 варианта подзапроса. 

select I.StockItemID, 
	I.StockItemName,
	I.UnitPrice
from [Warehouse].[StockItems] as I
where I.UnitPrice = (select Min([Warehouse].[StockItems].UnitPrice)  from [Warehouse].[StockItems])

--with CTE
; with MinPriceCTE(MinPrice) as
(
	select Min([Warehouse].[StockItems].UnitPrice)  
	from [Warehouse].[StockItems]
)
select I.StockItemID, 
	I.StockItemName,
	I.UnitPrice
from [Warehouse].[StockItems] as I
where I.UnitPrice = (select MinPriceCTE.MinPrice from MinPriceCTE)

--3. Выберите всех клиентов у которых было 5 максимальных оплат из [Sales].[CustomerTransactions] представьте 3 способа (в том числе с CTE)

select top(5)  C.CustomerID, C.CustomerName, Max(CT.TransactionAmount) as MaxAmount
from [Sales].[Customers] as C
inner join [Sales].[CustomerTransactions] as CT
on CT.CustomerID = C.CustomerID
group by C.CustomerID, C.CustomerName
order by MaxAmount desc

go

select C.CustomerID, 
	C.CustomerName, 
	CT.MaxAmount
from [Sales].[Customers] as C
join (select top(5) [Sales].[CustomerTransactions].[CustomerID], Max(TransactionAmount) as MaxAmount
	from [Sales].[CustomerTransactions]
	group by [Sales].[CustomerTransactions].[CustomerID]
	order by MaxAmount desc) as CT
	on C.CustomerID = CT.CustomerID

go

; with CustomerTransactionCTE(CustomerID, MaxAmount) as 
(
	select top(5) [Sales].[CustomerTransactions].[CustomerID], Max(TransactionAmount) as MaxAmount
	from [Sales].[CustomerTransactions]
	group by [Sales].[CustomerTransactions].[CustomerID]
	order by MaxAmount desc
)
select C.CustomerID, 
	C.CustomerName, 
	CTCTE.MaxAmount
from [Sales].[Customers] as C
join CustomerTransactionCTE as CTCTE
on C.CustomerID = CTCTE.CustomerID
	

--4. Выберите города (ид и название), в которые были доставлены товары входящие в тройку самых дорогих товаров, а также Имя сотрудника, 
--который осуществлял упаковку заказов

select ItemTrans.StockItemTransactionID, Item.UnitPrice, City.CityID, City.CityName, Person.FullName
from [Warehouse].[StockItemTransactions] as ItemTrans
join (select top(3) Items.UnitPrice, Items.StockItemID
	from [Warehouse].[StockItems] as Items
	order by Items.UnitPrice desc) as Item
on Item.StockItemID = ItemTrans.StockItemID

join [Sales].[Customers] as Cust
on Cust.CustomerID = ItemTrans.CustomerID

join [Application].[Cities] as City
on Cust.DeliveryCityID = City.CityID

join [Sales].[Invoices] as Inv
on Inv.InvoiceID = ItemTrans.InvoiceID

join [Application].[People] as Person
on Inv.PackedByPersonID = Person.PersonID

--with CTE

; with StockItemCTE (MaxPrice, StockItemID) as
(
	select top(3) Items.UnitPrice as MaxPrice, Items.StockItemID
	from [Warehouse].[StockItems] as Items
	order by Items.UnitPrice desc
)
select ItemTrans.StockItemTransactionID, Item.MaxPrice, City.CityID, City.CityName, Person.FullName
from [Warehouse].[StockItemTransactions] as ItemTrans

join StockItemCTE as Item
on Item.StockItemID = ItemTrans.StockItemID

join [Sales].[Customers] as Cust
on Cust.CustomerID = ItemTrans.CustomerID

join [Application].[Cities] as City
on Cust.DeliveryCityID = City.CityID

join [Sales].[Invoices] as Inv
on Inv.InvoiceID = ItemTrans.InvoiceID

join [Application].[People] as Person
on Inv.PackedByPersonID = Person.PersonID

--5 Объясните, что делает и оптимизируйте запрос:
--Приложите план запроса и его анализ, а также ход ваших рассуждений по поводу оптимизации. 
--Можно двигаться как в сторону улучшения читабельности запроса (что уже было в материале лекций), так и в сторону упрощения плана\ускорения.

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
	FROM Application.People
	WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
	FROM Sales.OrderLines
	WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
		FROM Sales.Orders
		WHERE Orders.PickingCompletedWhen IS NOT NULL	
		AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
JOIN
(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
FROM Sales.InvoiceLines
GROUP BY InvoiceId
HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

--Выборка показывает счета с именами продажников, показывается общая сумма всех уже зкомплектованих товаров, в которых сумма счета больше 27000.
--Выборка отсортирована по общей сумме счета от большего к меньшему.

; with InvoiceCTE (InvoiceID, TotalSumm, InvoiceDate, SalespersonPersonID, OrderID) as
(
	select I.InvoiceID, SalesTotals.TotalSumm, I.InvoiceDate, I.SalespersonPersonID, I.OrderID
	FROM Sales.Invoices as I
	JOIN
		(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
		FROM Sales.InvoiceLines
		GROUP BY InvoiceId
		HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
	ON I.InvoiceID = SalesTotals.InvoiceID
)
SELECT 
	InvoiceCTE.InvoiceID, 
	InvoiceCTE.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = InvoiceCTE.SalespersonPersonID
		) AS SalesPersonName,
	InvoiceCTE.TotalSumm AS TotalSummByInvoice, 
		(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
			AND Orders.OrderId = InvoiceCTE.OrderId)	
		) AS TotalSummForPickedItems
from InvoiceCTE
ORDER BY InvoiceCTE.TotalSumm DESC
