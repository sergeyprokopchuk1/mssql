use WideWorldImporters;

/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам
2. Отобразить все месяцы, где общая сумма продаж превысила 10 000 
3. Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц.
*/

go

-- 1. Посчитать среднюю цену товара, общую сумму продажи по месяцам

select InvTr.StockItemID,
	month(Inv.InvoiceDate) as [Month Number],
	AVG(InvTr.UnitPrice) as [Average Price],
	Sum(InvTr.UnitPrice * InvTr.Quantity) as [Total Sale]
from [Sales].[Invoices] as Inv
join [Sales].[InvoiceLines] as InvTr
on Inv.InvoiceID = InvTr.InvoiceID
group by InvTr.StockItemID, month(Inv.InvoiceDate)
order by InvTr.StockItemID, month(Inv.InvoiceDate)

-- 2. Отобразить все месяцы, где общая сумма продаж превысила 10 000 

select InvTr.StockItemID,
	month(Inv.InvoiceDate) as [Month Number],
	Sum(InvTr.UnitPrice * InvTr.Quantity) as [Total Sale]
from [Sales].[Invoices] as Inv
join [Sales].[InvoiceLines] as InvTr
on Inv.InvoiceID = InvTr.InvoiceID
group by InvTr.StockItemID, month(Inv.InvoiceDate)
having Sum(InvTr.UnitPrice * InvTr.Quantity) > 10000
order by InvTr.StockItemID, month(Inv.InvoiceDate)

--3. Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц.

select month(Inv.InvoiceDate) as [Month Number],
	InvTr.StockItemID,
	Sum(InvTr.UnitPrice * InvTr.Quantity) as [Total Sale],
	Min(Inv.InvoiceDate) as [First Sale Date],
	Sum(InvTr.Quantity) as [Quantity It]
from [Sales].[Invoices] as Inv
join [Sales].[InvoiceLines] as InvTr
on Inv.InvoiceID = InvTr.InvoiceID
group by month(Inv.InvoiceDate), InvTr.StockItemID
having Sum(InvTr.Quantity) <= 50
order by month(Inv.InvoiceDate), InvTr.StockItemID, [Quantity It]