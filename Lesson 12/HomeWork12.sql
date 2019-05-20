use WideWorldImporters;

go

/*
1. Загрузить данные из файла StockItems.xml в таблицу StockItems.
Существующие записи в таблице обновить, отсутствующие добавить (искать по StockItemName).
Файл StockItems.xml в личном кабинете.
*/

declare @items xml

set @items = (
	select * 
	from openrowset 
		(bulk 'D:\12_Dynamic_SQL\StockItems.xml',
		single_blob)
	as s)

insert into [Warehouse].[StockItems](
[StockItemName], 
[SupplierID], 
[UnitPackageID],
[OuterPackageID],
[LeadTimeDays],
[QuantityPerOuter],
[IsChillerStock],
[TypicalWeightPerUnit],
[TaxRate],
[UnitPrice],
[LastEditedBy]
)
select t.c.value('@Name', 'nvarchar(100)') + ' xml',
	t.c.value('SupplierID[1]', 'int'),
	t.c.value('Package[1]/UnitPackageID[1]', 'int'),
	t.c.value('Package[1]/OuterPackageID[1]', 'int'),
	t.c.value('LeadTimeDays[1]', 'int'),
	t.c.value('Package[1]/QuantityPerOuter[1]', 'int'),
	t.c.value('IsChillerStock[1]', 'bit'),
	t.c.value('Package[1]/TypicalWeightPerUnit[1]', 'decimal(18, 3)'),
	t.c.value('TaxRate[1]', 'decimal(18, 3)'),
	t.c.value('UnitPrice[1]', 'decimal(18, 2)'),
	1
from @items.nodes('//StockItems/Item') as t(c)

--2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
go

select
[StockItemName] as '@Name', 
[SupplierID], 
[UnitPackageID]  as 'Package/UnitPackageID',
[OuterPackageID]  as 'Package/OuterPackageID',
[QuantityPerOuter]  as 'Package/QuantityPerOuter',
[TypicalWeightPerUnit]  as 'Package/TypicalWeightPerUnit',
[LeadTimeDays],
[IsChillerStock],
[TaxRate],
[UnitPrice]
from [Warehouse].[StockItems]
for xml path('Item'), root('StockItems'), elements

/*
3. В таблице StockItems в колонке CustomFields есть данные в json.
Написать select для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- Range (из CustomFields)
*/
go

select 
StockItemID,
StockItemName,
JSON_VALUE(CustomFields, '$.CountryOfManufacture') as CountryOfManufacture,
JSON_VALUE(CustomFields, '$.Range') as Range
from [Warehouse].[StockItems]

/*
4. Найти в StockItems строки, где есть тэг "Vintage"
Запрос написать через функции работы с JSON.
Тэги искать в поле CustomFields, а не в Tags.
*/
go

select 
	SI.StockItemID,
	SI.StockItemName,
	SI.CustomFields
from 
    [Warehouse].[StockItems] as SI
    cross apply openjson(SI.CustomFields,'$.Tags')
where value = 'Vintage'

/*

5. Пишем динамический PIVOT. 
По заданию из 8го занятия про CROSS APPLY и PIVOT 
Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
Название клиента
МесяцГод Количество покупок

Нужно написать запрос, который будет генерировать результаты для всех клиентов 
имя клиента указывать полностью из CustomerName
дата должна иметь формат dd.mm.yyyy например 25.12.2019
*/