use WideWorldImporters;

go

/*
Pivot и Cross Apply
1. Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
Название клиента Месяц Год Количество покупок

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys
имя клиента нужно поменять так чтобы осталось только уточнение 
например исходное Tailspin Toys (Gasport, NY) - вы выводите в имени только Gasport,NY
дата должна иметь формат dd.mm.yyyy например 25.12.2019

Например, как должны выглядеть результаты:
InvoiceMonth	Peeples Valley, AZ	Medicine Lodge, KS	Gasport, NY	Sylvanite, MT	Jessie, ND
01.01.2013	3	1	4	2	2
01.02.2013	7	3	4	2	1

2. Для всех клиентов с именем, в котором есть Tailspin Toys
вывести все адреса, которые есть в таблице, в одной колонке

Пример результатов
CustomerName	AddressLine
Tailspin Toys (Head Office)	Shop 38
Tailspin Toys (Head Office)	1877 Mittal Road
Tailspin Toys (Head Office)	PO Box 8975
Tailspin Toys (Head Office)	Ribeiroville
.....

3. В таблице стран есть поля с кодом страны цифровым и буквенным
сделайте выборку ИД страны, название, код - чтобы в поле был либо цифровой либо буквенный код
Пример выдачи

CountryId	CountryName	Code
1	Afghanistan	AFG
1	Afghanistan	4
3	Albania	ALB
3	Albania	8

4. Перепишите ДЗ из оконных функций через CROSS APPLY 
Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
*/

go

/*
1. 1. Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
Название клиента 
Месяц Год Количество покупок

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys
имя клиента нужно поменять так чтобы осталось только уточнение 
например исходное Tailspin Toys (Gasport, NY) - вы выводите в имени только Gasport,NY
дата должна иметь формат dd.mm.yyyy например 25.12.2019

Например, как должны выглядеть результаты:
InvoiceMonth	Peeples Valley, AZ	Medicine Lodge, KS	Gasport, NY	Sylvanite, MT	Jessie, ND
01.01.2013			3		1	4		2		2
01.02.2013			7		3	4		2		1
*/

select PVT.FormatedDate2,
	PVT.[Peeples Valley, AZ],
	PVT.[Medicine Lodge, KS],
	PVT.[Gasport, NY],
	PVT.[Sylvanite, MT],
	PVT.[Jessie, ND]
from
(
	select	CName.fragment as CustomerNameFragment,
		cast(dateadd(mm, datediff(mm, 0, I.InvoiceDate), 0) as date) as FormatedDate,
		convert(char(10), cast(dateadd(mm, datediff(mm, 0, I.InvoiceDate), 0) as date), 104) as FormatedDate2,
		IL.Quantity as CustomerQuantity
	from [Sales].[Customers] as C
	join [Sales].[Invoices] as I on I.CustomerID = C.CustomerID
	join [Sales].[InvoiceLines] as IL on IL.InvoiceID = I.InvoiceID
	cross apply (select ci1 = charindex('(', C.CustomerName)) as FI
	cross apply (select ci2 = charindex(')', C.CustomerName, ci1+1)) as SI
	cross apply (select fragment = substring(C.CustomerName, ci1+1, ci2-ci1-1)) as CName
	where C.CustomerID between 2 and 6
) as Customers
pivot (sum(Customers.CustomerQuantity)
for Customers.CustomerNameFragment in ([Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Sylvanite, MT], [Jessie, ND])) as PVT
order by FormatedDate;

/*
2. Для всех клиентов с именем, в котором есть Tailspin Toys
вывести все адреса, которые есть в таблице, в одной колонке

Пример результатов
CustomerName	AddressLine
Tailspin Toys (Head Office)	Shop 38
Tailspin Toys (Head Office)	1877 Mittal Road
Tailspin Toys (Head Office)	PO Box 8975
Tailspin Toys (Head Office)	Ribeiroville
.....
*/

select CustomerName, AddressLine
from 
(
	select 
		C.CustomerName as CustomerName
		,C.DeliveryAddressLine1 as A1
		,C.DeliveryAddressLine2 as A2
		,C.PostalAddressLine1 as A3
		,C.PostalAddressLine2 as A4
	from [Sales].[Customers] as C
	where C.CustomerName like 'Tailspin Toys%'
)  Customers
unpivot (AddressLine for ll2 in([A1], [A2], [A3], [A4])) as unpvt

/*
3. В таблице стран есть поля с кодом страны цифровым и буквенным
сделайте выборку ИД страны, название, код - чтобы в поле был либо цифровой либо буквенный код
Пример выдачи

CountryId	CountryName	Code
1	Afghanistan	AFG
1	Afghanistan	4
3	Albania	ALB
3	Albania	8
*/

select CountryId, CountryName, Code
from
(
	select C.CountryID as CountryId, 
		C.CountryName as CountryName, 
		C.IsoAlpha3Code as Alpha3Code, 
		cast(C.IsoNumericCode as [nvarchar](3)) as NumericCode
	from [Application].[Countries] as C
) as Countries
unpivot (Code for Code1 in([Alpha3Code], [NumericCode])) as unpvt

/*
4. Перепишите ДЗ из оконных функций через CROSS APPLY 
Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки

*/

--решение через оконные функции
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
	join [Sales].[CustomerTransactions] as CT on CT.CustomerID = C.CustomerID
	join [Sales].[InvoiceLines] as IL on IL.InvoiceID = CT.InvoiceID
	join [Warehouse].[StockItems] as SI	on SI.StockItemID = IL.StockItemID
	join [Sales].[Invoices] as I on I.InvoiceID = IL.InvoiceID
)
select *
from CustomersItemsCTE as Cust
where Cust.Number <= 2
order by  Cust.CustomerID, Cust.UnitPrice desc

--решение через cross apply
select OuterC.CustomerID,
		OuterC.CustomerName,
		InnerC.StockItemID,
		InnerC.UnitPrice,
		InnerC.InvoiceDate
from [Sales].[Customers] as OuterC
cross apply (
	select top 2
		IL.StockItemID,
		SI.UnitPrice,
		I.InvoiceDate
	from [Sales].[Customers] as C
	join [Sales].[CustomerTransactions] as CT on CT.CustomerID = C.CustomerID
	join [Sales].[InvoiceLines] as IL on IL.InvoiceID = CT.InvoiceID
	join [Warehouse].[StockItems] as SI	on SI.StockItemID = IL.StockItemID
	join [Sales].[Invoices] as I on I.InvoiceID = IL.InvoiceID
	where C.CustomerID = OuterC.CustomerID
	order by SI.UnitPrice desc
	) as InnerC
order by  OuterC.CustomerID