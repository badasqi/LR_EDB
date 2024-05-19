# Лабораторная работа №1 
## Схему БД можно восстановить из бэкап [файла](https://github.com/badasqi/LR_EDB/blob/main/LR1/EDB_backup_db_LR1.sql)

### Типовые запросы к БД
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

##### Поиск:
```sql
SELECT * FROM customer WHERE name LIKE 'customer-12345';
SELECT p.name FROM product_in_shop pis LEFT JOIN product p ON pis.product_id = p.product_id WHERE pis.price BETWEEN 100 AND 5000;
```

### Вызов хранимых процедур (вставка в каждую таблицу по миллиону строк тестовых данных):
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
### Тестирование запросов:
![](https://github.com/badasqi/LR_EDB/blob/main/LR1/img/search.png)
![](https://github.com/badasqi/LR_EDB/blob/main/LR1/img/search1.png)
![](https://github.com/badasqi/LR_EDB/blob/main/LR1/img/aggregation.png)
![](https://github.com/badasqi/LR_EDB/blob/main/LR1/img/aggregation1.png)
![](https://github.com/badasqi/LR_EDB/blob/main/LR1/img/aggregation2.png)

### Оптимизация конфигурации сервера:

### Оптимизация схемы БД (добавил индексы):
```sql
-- Создание новых индексов

CREATE INDEX ix_online_order_purchase_id ON online_order(purchase_id);
CREATE INDEX ix_purchase_store_id ON purchase(store_id);

CREATE INDEX ix_purchase_item_purchase_id ON purchase_item(purchase_id);
CREATE INDEX ix_purchase_item_product_in_shop_id ON purchase_item(product_in_shop_id);

CREATE INDEX ix_product_in_shop_store_id ON product_in_shop(store_id);
CREATE INDEX ix_product_in_product_id ON product_in_shop(product_id);
```
