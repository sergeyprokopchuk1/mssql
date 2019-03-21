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

5. Code review (опционально). Запрос приложен в материалы Hometask_code_review.sql. 
Что делает запрос? 
Чем можно заменить CROSS APPLY - можно ли использовать другую стратегию выборки\запроса?
*/

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