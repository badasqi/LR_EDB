## Лабораторная работа №1 

#### Типовые запросы к БД
##### Получение списков данных:
```sql
-- Список всех клиентов
SELECT * FROM customer;

-- Список всех продуктов
SELECT * FROM product;

-- Список всех заказов клиента
select o.order_online_id, c.name, o.order_date, o.status
FROM online_order o 
JOIN customer c ON o.customer_id = c.customer_id;
```

##### Агрегация:
```sql
-- Количество заказов по каждому клиенту
SELECT count(o.order_online_id) AS count_order, c.name 
FROM online_order o 
JOIN customer c ON o.customer_id = c.customer_id GROUP by c.name;

-- Количество продаж по конкретному продукту по всем магазинам
SELECT p.name, sum(pi.amount) AS amount_sold 
FROM purchase_item pi 
JOIN product_in_shop pis ON pi.product_in_shop_id = pis.product_in_shop_id 
JOIN product p ON pis.product_id = p.product_id 
GROUP BY p.name;


-- Рассчёт стоимости суммарной стоимости заказа
SELECT o.order_online_id, SUM(pis.price) AS order_price
FROM online_order o
JOIN purchase p ON o.purchase_id = p.purchase_id
JOIN purchase_item pi ON pi.purchase_id = p.purchase_id
JOIN product_in_shop pis ON pis.product_in_shop_id = pi.product_in_shop_id
GROUP BY o.order_online_id ORDER BY order_price DESC;
```


### БД можно восстановить из бэкап файла и вызвать хранимые процедуры следующим скриптом:
```sql
DO $$
BEGIN
	CALL generate_customers(1000000);
	CALL generate_manufacturers(1000000);
    CALL generate_products(1000000);
	CALL generate_online_stores(1000000);
	CALL generate_products_in_shop(1000000);
	CALL generate_purchases(1000000);
    CALL generate_purchase_items(1000000);
	CALL generate_online_orders(1000000);
END $$;
```
#### Тестирование запросов
