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
where P.PersonID not in (select O.SalespersonPersonID
	from [Sales].[Orders] as O
	)

go 


; with SalespersonsCTE(SalespersonPersonID) as 
(
	select O.SalespersonPersonID
	from [Sales].[Orders] as O
)
select P.PersonID, P.FullName
from [Application].[People] as P
where P.PersonID not in (select * from SalespersonsCTE)


--2. Выберите товары с минимальной ценой (подзапросом), 2 варианта подзапроса. 

-- 1 subquery with CTE
select I.StockItemID, 
	I.StockItemName,
	I.UnitPrice
	, (select Min([Warehouse].[StockItems].UnitPrice)  from [Warehouse].[StockItems]) as MinPrice
from [Warehouse].[StockItems] as I
where I.UnitPrice = (select Min([Warehouse].[StockItems].UnitPrice)  from [Warehouse].[StockItems])

-- looks weird but performance are the same
; with MinPriceCTE(MinPrice) as
(
	select Min([Warehouse].[StockItems].UnitPrice)  
	from [Warehouse].[StockItems]
)
select I.StockItemID, 
	I.StockItemName,
	I.UnitPrice
	,(select MinPriceCTE.MinPrice from MinPriceCTE) as MinPrice
from [Warehouse].[StockItems] as I
where I.UnitPrice = (select MinPriceCTE.MinPrice from MinPriceCTE)

--2 subquery with CTE
select I.StockItemID, 
	I.StockItemName,
	I.UnitPrice
	, (select Min([Warehouse].[StockItems].UnitPrice)  from [Warehouse].[StockItems]) as MinPrice
from [Warehouse].[StockItems] as I
where I.UnitPrice <= All (select Min([Warehouse].[StockItems].UnitPrice)  from [Warehouse].[StockItems])

-- looks weird but performance is the same
; with MinPriceCTE(MinPrice) as
(
	select Min([Warehouse].[StockItems].UnitPrice)  
	from [Warehouse].[StockItems]
)
select I.StockItemID, 
	I.StockItemName,
	I.UnitPrice
	, (select MinPriceCTE.MinPrice from MinPriceCTE) as MinPrice
from [Warehouse].[StockItems] as I
where I.UnitPrice <= All (select MinPriceCTE.MinPrice from MinPriceCTE)

--3. Выберите всех клиентов у которых было 5 максимальных оплат из [Sales].[CustomerTransactions] представьте 3 способа (в том числе с CTE)

select top(5)  C.CustomerID, C.CustomerName, Max(CT.TransactionAmount) as MaxAmount -- C.CustomerName, CT.TransactionAmount
from [Sales].[Customers] as C
inner join [Sales].[CustomerTransactions] as CT
on CT.CustomerID = C.CustomerID
group by C.CustomerID, C.CustomerName
order by MaxAmount desc

go

select top(5) C.CustomerID, 
	C.CustomerName, 
	CT.MaxAmount
from [Sales].[Customers] as C
join (select [Sales].[CustomerTransactions].[CustomerID], Max(TransactionAmount) as MaxAmount
	from [Sales].[CustomerTransactions]
	group by [Sales].[CustomerTransactions].[CustomerID]) as CT
	on C.CustomerID = CT.CustomerID
	order by CT.MaxAmount desc

go

; with CustomerTransactionCTE(CustomerID, MaxAmount) as 
(
	select [Sales].[CustomerTransactions].[CustomerID], Max(TransactionAmount) as MaxAmount
	from [Sales].[CustomerTransactions]
	group by [Sales].[CustomerTransactions].[CustomerID]
)
select top(5) C.CustomerID, 
	C.CustomerName, 
	CTCTE.MaxAmount
from [Sales].[Customers] as C
join CustomerTransactionCTE as CTCTE
	on C.CustomerID = CTCTE.CustomerID
	order by CTCTE.MaxAmount desc

--4. Выберите города (ид и название), в которые были доставлены товары входящие в тройку самых дорогих товаров, а также Имя сотрудника, 
--который осуществлял упаковку заказов

select ItemTrans.StockItemTransactionID, Item.UnitPrice, City.CityID, City.CityName, Person.FullName
from [Warehouse].[StockItemTransactions] as ItemTrans

join (select top(3) Items.UnitPrice, Items.StockItemID
from [Warehouse].[StockItems] as Items
group by Items.UnitPrice, Items.StockItemID
order by Items.UnitPrice desc) as Item
on Item.StockItemID = ItemTrans.StockItemID

join (select City.CityID, City.CityName, C.CustomerID
from [Application].Cities as City
inner join [Sales].Customers as C
on C.DeliveryCityID = City.CityID) as City
on City.CustomerID = ItemTrans.CustomerID

join (select P.PersonID, P.FullName, I.InvoiceID
from [Application].[People] as P
inner join [Sales].Invoices as I
on I.PackedByPersonID = P.PersonID
group by P.PersonID, P.FullName, I.InvoiceID) as Person
on Person.InvoiceID = ItemTrans.InvoiceID

--with CTE

; with StockItemCTE (MaxPrice, StockItemID) as
(
	select top(3) Items.UnitPrice as MaxPrice, Items.StockItemID
	from [Warehouse].[StockItems] as Items
	group by Items.UnitPrice, Items.StockItemID
	order by Items.UnitPrice desc
),
CityCTE (CityID, CityName, CustomerID) as 
(
	select City.CityID, City.CityName, C.CustomerID
	from [Application].Cities as City
	inner join [Sales].Customers as C
	on C.DeliveryCityID = City.CityID
), 
PackedPersonCTE (FullName, InvoiceID) as
(
	select P.FullName, I.InvoiceID
	from [Application].[People] as P
	inner join [Sales].Invoices as I
	on I.PackedByPersonID = P.PersonID
	group by P.FullName, I.InvoiceID
)
select ItemTrans.StockItemTransactionID, Item.MaxPrice, City.CityID, City.CityName, Person.FullName
from [Warehouse].[StockItemTransactions] as ItemTrans
join StockItemCTE as Item
on Item.StockItemID = ItemTrans.StockItemID
join CityCTE as City
on City.CustomerID = ItemTrans.CustomerID
join PackedPersonCTE as Person
on Person.InvoiceID = ItemTrans.InvoiceID

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
