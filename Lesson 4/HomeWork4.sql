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