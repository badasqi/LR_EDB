## Лабораторная работа №1 

#### Типовые запросы к БД
##### Получение списков данных
```sql
-- Список всех клиентов
SELECT * FROM customer;

-- Список всех продуктов
SELECT * FROM product;

-- Список всех заказов клиента
select o.order_online_id, c.name, o.order_date, o.status
FROM online_order o JOIN customer c ON o.customer_id = c.customer_id;
```

#### БД можно восстановить из бэкап файла и вызвать хранимые процедуры следующим скриптом:
```sql
DO $$
BEGIN
	CALL generate_customers(1000000);
	CALL generate_manufacturers(1000000);
    CALL generate_products(1000000);
	CALL generate_online_stores(1000000);
	CALL generate_products_in_shop(1000000);
    CALL generate_purchase_items(1000000);
	CALL generate_purchases(1000000);
	CALL generate_online_orders(1000000);
END $$;
```
#### Тестирование запросов
