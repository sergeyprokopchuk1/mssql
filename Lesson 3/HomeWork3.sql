use WideWorldImporters;

go

/*
1. Довставлять в базу 5 записей используя insert в таблицу Customers или Suppliers
2. удалите 1 запись из Customers, которая была вами добавлена
3. изменить одну запись, из добавленных через UPDATE
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

insert into [Sales].[Customers](
	[CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryPostalCode]
      ,[PostalAddressLine1]
      ,[PostalPostalCode]
      ,[LastEditedBy]
)
values
('CustomerName10', 1, 3, 1, 1011, 1012, 3, 20672, 20672, '2013-01-01', 0.000, 0, 0, 7, '(239) 555-0199', '(239) 555-0199', 'https://example.com/CustomerName1', 'DeliveryAddressLine1', 'Code1', 'PostalAddressLine1', 'Code1', 1),
('CustomerName20', 1, 3, 1, 1011, 1012, 3, 20672, 20672, '2013-01-01', 0.000, 0, 0, 7, '(239) 555-0199', '(239) 555-0199', 'https://example.com/CustomerName1', 'DeliveryAddressLine1', 'Code1', 'PostalAddressLine1', 'Code1', 1),
('CustomerName30', 1, 3, 1, 1011, 1012, 3, 20672, 20672, '2013-01-01', 0.000, 0, 0, 7, '(239) 555-0199', '(239) 555-0199', 'https://example.com/CustomerName1', 'DeliveryAddressLine1', 'Code1', 'PostalAddressLine1', 'Code1', 1),
('CustomerName40', 1, 3, 1, 1011, 1012, 3, 20672, 20672, '2013-01-01', 0.000, 0, 0, 7, '(239) 555-0199', '(239) 555-0199', 'https://example.com/CustomerName1', 'DeliveryAddressLine1', 'Code1', 'PostalAddressLine1', 'Code1', 1),
('CustomerName50', 1, 3, 1, 1011, 1012, 3, 20672, 20672, '2013-01-01', 0.000, 0, 0, 7, '(239) 555-0199', '(239) 555-0199', 'https://example.com/CustomerName1', 'DeliveryAddressLine1', 'Code1', 'PostalAddressLine1', 'Code1', 1);

go 

delete from [Sales].[Customers]
where [CustomerName] = 'CustomerName50'