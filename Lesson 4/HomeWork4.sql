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
