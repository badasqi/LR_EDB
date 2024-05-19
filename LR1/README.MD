## Лабораторная работа №1 
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
