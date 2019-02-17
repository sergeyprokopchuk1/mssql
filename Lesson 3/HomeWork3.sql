use WideWorldImporters;

/*
1. Довставлять в базу 5 записей используя insert в таблицу Customers или Suppliers
2. удалите 1 запись из Customers, которая была вами добавлена
3. изменить одну запись, из добавленных через UPDATE
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

go

--preparation

--delete from [Sales].[Customer_Temp]

--truncate table [Sales].[Customer_Temp]

--drop table [Sales].[Customer_Temp]

--delete FROM [WideWorldImporters].[Sales].[Customers]
--where Sales.Customers.CustomerID > 1061

create table [Sales].[Customer_Temp](
	  [CustomerID] [int] identity NOT NULL,
	[CustomerName] [nvarchar](100) NOT NULL,
	[BillToCustomerID] [int] NOT NULL,
	[CustomerCategoryID] [int] NOT NULL,
	[BuyingGroupID] [int] NULL,
	[PrimaryContactPersonID] [int] NOT NULL,
	[AlternateContactPersonID] [int] NULL,
	[DeliveryMethodID] [int] NOT NULL,
	[DeliveryCityID] [int] NOT NULL,
	[PostalCityID] [int] NOT NULL,
	[AccountOpenedDate] [date] NOT NULL,
	[StandardDiscountPercentage] [decimal](18, 3) NOT NULL,
	[IsStatementSent] [bit] NOT NULL,
	[IsOnCreditHold] [bit] NOT NULL,
	[PaymentDays] [int] NOT NULL,
	[PhoneNumber] [nvarchar](20) NOT NULL,
	[FaxNumber] [nvarchar](20) NOT NULL,
	[WebsiteURL] [nvarchar](256) NOT NULL,
	[DeliveryAddressLine1] [nvarchar](60) NOT NULL,
	[DeliveryPostalCode] [nvarchar](10) NOT NULL,
	[PostalAddressLine1] [nvarchar](60) NOT NULL,
	[PostalPostalCode] [nvarchar](10) NOT NULL,
	[LastEditedBy] [int] NOT NULL,
)

go

insert into [Sales].[Customer_Temp](
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


--INSERT
go

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
select 
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
from [Sales].[Customer_Temp]
where CustomerID <= 5

go

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
output inserted.[CustomerName]
      ,inserted.[BillToCustomerID]
      ,inserted.[CustomerCategoryID]
      ,inserted.[BuyingGroupID]
      ,inserted.[PrimaryContactPersonID]
      ,inserted.[AlternateContactPersonID]
      ,inserted.[DeliveryMethodID]
      ,inserted.[DeliveryCityID]
      ,inserted.[PostalCityID]
      ,inserted.[AccountOpenedDate]
      ,inserted.[StandardDiscountPercentage]
      ,inserted.[IsStatementSent]
      ,inserted.[IsOnCreditHold]
      ,inserted.[PaymentDays]
      ,inserted.[PhoneNumber]
      ,inserted.[FaxNumber]
      ,inserted.[WebsiteURL]
      ,inserted.[DeliveryAddressLine1]
      ,inserted.[DeliveryPostalCode]
      ,inserted.[PostalAddressLine1]
      ,inserted.[PostalPostalCode]
      ,inserted.[LastEditedBy]
into Sales.Customer_Temp(
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
output inserted.CustomerName
values
('CustomerName11', 1, 3, 1, 1011, 1012, 3, 20672, 20672, '2013-01-01', 0.000, 0, 0, 7, '(239) 555-0199', '(239) 555-0199', 'https://example.com/CustomerName1', 'DeliveryAddressLine1', 'Code1', 'PostalAddressLine1', 'Code1', 1),
('CustomerName21', 1, 3, 1, 1011, 1012, 3, 20672, 20672, '2013-01-01', 0.000, 0, 0, 7, '(239) 555-0199', '(239) 555-0199', 'https://example.com/CustomerName1', 'DeliveryAddressLine1', 'Code1', 'PostalAddressLine1', 'Code1', 1),
('CustomerName31', 1, 3, 1, 1011, 1012, 3, 20672, 20672, '2013-01-01', 0.000, 0, 0, 7, '(239) 555-0199', '(239) 555-0199', 'https://example.com/CustomerName1', 'DeliveryAddressLine1', 'Code1', 'PostalAddressLine1', 'Code1', 1),
('CustomerName41', 1, 3, 1, 1011, 1012, 3, 20672, 20672, '2013-01-01', 0.000, 0, 0, 7, '(239) 555-0199', '(239) 555-0199', 'https://example.com/CustomerName1', 'DeliveryAddressLine1', 'Code1', 'PostalAddressLine1', 'Code1', 1),
('CustomerName51', 1, 3, 1, 1011, 1012, 3, 20672, 20672, '2013-01-01', 0.000, 0, 0, 7, '(239) 555-0199', '(239) 555-0199', 'https://example.com/CustomerName1', 'DeliveryAddressLine1', 'Code1', 'PostalAddressLine1', 'Code1', 1);

go


----UPDATE

update [Sales].[Customers]
set [DeliveryMethodID] = 1,
	[CustomerName] = 'CustomerName22'
	output inserted.*, deleted.*
where [CustomerName] = 'CustomerName20'

go

--DELETE

delete from [Sales].[Customers]
where [CustomerName] = 'CustomerName50'

go

delete from C
from [Sales].[Customers] as C
	join [Sales].[Customer_Temp] as CT
	on C.CustomerName = CT.CustomerName
	where CT.[CustomerName] = 'CustomerName51'


go

delete from [Sales].[Customers]
where exists (select *
	from [Sales].[Customer_Temp]
	where [Sales].[Customers].[CustomerName] = [Sales].[Customer_Temp].[CustomerName])

--MERGE

