use WideWorldImporters;

go

/*
Запросы SELECT
Напишите выборки для того, чтобы получить:
1. Все товары, в которых в название есть пометка urgent или название начинается с Animal
2. Поставщиков, у которых не было сделано ни одного заказа (потом покажем как это делать через подзапрос, сейчас сделайте через JOIN)
3. Продажи с названием месяца, в котором была продажа, номером квартала, к которому относится продажа, 
включите также к какой трети года относится дата - каждая треть по 4 месяца, дата забора заказа должна быть задана, 
с ценой товара более 100$ либо количество единиц товара более 20. 
Добавьте вариант этого запроса с постраничной выборкой пропустив первую 1000 и отобразив следующие 100 записей. 
Соритровка должна быть по номеру квартала, трети года, дате продажи. 
4. Заказы поставщикам, которые были исполнены за 2014й год с доставкой Road Freight или Post, 
добавьте название поставщика, имя контактного лица принимавшего заказ
5. 10 последних по дате продаж с именем клиента и именем сотрудника, который оформил заказ.
6. Все ид и имена клиентов и их контактные телефоны, которые покупали товар Chocolate frogs 250g
*/

--1. Все товары, в которых в название есть пометка urgent или название начинается с Animal

select SI.[StockItemID],
      SI.[StockItemName]
from [Warehouse].[StockItems] as SI
where SI.StockItemName like '%urgent%' 
or SI.StockItemName like 'Animal%'

--2. Поставщиков, у которых не было сделано ни одного заказа (потом покажем как это делать через подзапрос, сейчас сделайте через JOIN)

select S.[SupplierID]
      ,S.[SupplierName]
from [Purchasing].[Suppliers] as S
left join [Purchasing].[SupplierTransactions] as ST on S.SupplierID = ST.SupplierID
where ST.SupplierID is null

/*
3. Продажи с названием месяца, в котором была продажа, номером квартала, к которому относится продажа, 
включите также к какой трети года относится дата - каждая треть по 4 месяца, дата забора заказа должна быть задана, 
с ценой товара более 100$ либо количество единиц товара более 20. 
Добавьте вариант этого запроса с постраничной выборкой пропустив первую 1000 и отобразив следующие 100 записей. 
Соритровка должна быть по номеру квартала, трети года, дате продажи. 
*/

select O.OrderDate
	,OL.PickingCompletedWhen
	,datename(month, convert(char(8), O.OrderDate, 112)) as [Month Name]
	,datepart(QUARTER, O.OrderDate) as [Quarter Number]
	,(datepart(month, O.OrderDate)-1)/4 + 1 as [Third Number]
from [Sales].[Orders] as O
join [Sales].[OrderLines] as OL on OL.OrderID = O.OrderID
where OL.PickingCompletedWhen is not null
and (OL.UnitPrice > 100 or OL.Quantity > 20)
order by [Quarter Number], [Third Number], O.OrderDate
offset 1000 rows fetch next 100 rows only

--4. Заказы поставщикам, которые были исполнены за 2014й год с доставкой Road Freight или Post, 
--добавьте название поставщика, имя контактного лица принимавшего заказ

select O.PurchaseOrderID
	,S.SupplierID
	,S.SupplierName
	,P.FullName
	,O.OrderDate
from [Purchasing].[Suppliers] as S
join [Purchasing].[PurchaseOrders] as O on O.SupplierID = S.SupplierID
join [Application].[People] as P on O.ContactPersonID = P.PersonID
where year(O.OrderDate) = 2014
and (O.DeliveryMethodID = 1 or O.DeliveryMethodID = 7)
order by O.PurchaseOrderID

--5. 10 последних по дате продаж с именем клиента и именем сотрудника, который оформил заказ.

select top(10) O.OrderDate
	,O.OrderID
	,SP.FullName
	,C.CustomerName
from [Sales].[Orders] as O
join [Application].[People] as SP on SP.PersonID = O.SalespersonPersonID
join [Sales].[Customers] as C on C.CustomerID = O.CustomerID
where SP.IsSalesperson = 1
order by O.OrderDate desc

--6. Все ид и имена клиентов и их контактные телефоны, которые покупали товар Chocolate frogs 250g

select
	C.CustomerID
	,C.CustomerName
	,C.PhoneNumber
from [Sales].[Customers] as C
join [Sales].Orders as O on O.CustomerID = C.CustomerID
join [Sales].[OrderLines] as OL on OL.OrderID = O.OrderID
join [Warehouse].[StockItems] as I on I.StockItemID = OL.StockItemID
where I.StockItemName = 'Chocolate frogs 250g'