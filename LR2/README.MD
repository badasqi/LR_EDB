# Лабораторная работа №2
## Доработка ER-модели БД для машинного обучения

## 1. Задача машинного обучения
#### Прогнозирование продаж товаров для женщин и мужчин
Задача для машинного обучения заключается в прогнозировании количества товаров, которое может быть продано случайной женщине или мужчине по всем онлайн-магазинам портала. Эта информация может быть полезна при закупках у производителя товаров определённой категории и стоимости.

### 1.1. Доработка процедуры Product
#### Генерация продуктов с случайной категорией
Для генерации продуктов с случайной категорией были переписаны процедуры Product. Каждый продукт теперь имеет случайную категорию из 100 заданных категорий.
```sql
DECLARE
    i INT;
    manufacturer_ids INT[];
    product_categories TEXT[] := ARRAY[
        'Electronics', 'Clothing', 'Books', 'Home & Kitchen', 'Beauty & Personal Care', 'Sports & Outdoors', 
        'Toys & Games', 'Automotive', 'Jewelry', 'Health & Household', 'Grocery & Gourmet Food', 'Pet Supplies', 
        'Office Products', 'Tools & Home Improvement', 'Garden & Outdoor', 'Musical Instruments', 
        'Baby', 'Video Games', 'Movies & TV', 'Software', 'Arts, Crafts & Sewing', 'Industrial & Scientific', 
        'Collectibles & Fine Art', 'Cell Phones & Accessories', 'Shoes', 'Handmade Products', 'Appliances', 
        'Camera & Photo', 'Luggage & Travel Gear', 'Furniture', 'Watches', 'Gift Cards', 'Computers', 
        'Smart Home', 'Building Supplies', 'Party Supplies', 'Bedding', 'Lighting', 'Cleaning Supplies', 
        'Safety & Security', 'Storage & Organization', 'Seasonal Decor', 'Bathroom Accessories', 'Kitchen & Dining', 
        'Stationery & Gift Wrapping', 'Craft Beer & Wine', 'Fresh Produce', 'Fitness & Nutrition', 'Camping & Hiking', 
        'Cycling', 'Water Sports', 'Winter Sports', 'Fishing', 'Hunting & Shooting', 'Climbing', 'Yoga', 
        'Dance & Gymnastics', 'Martial Arts', 'Board Games', 'Puzzles', 'Model Building', 'Science Kits', 
        'Educational Toys', 'Plush Toys', 'Dolls', 'Action Figures', 'Remote Control Toys', 'Video Game Accessories', 
        'Streaming Media Players', 'Wearable Technology', 'Smartphone Accessories', 'Tablet Accessories', 
        'Laptop Accessories', 'Network & Connectivity', 'Printers & Scanners', 'Computer Components', 
        'Software & Cloud Services', 'TV & Home Theater', 'Headphones', 'Speakers', 'Musical Accessories', 
        'DJ & Karaoke', 'Recording Equipment', 'Live Sound & Stage', 'Synthesizers', 'Brass Instruments', 
        'String Instruments', 'Woodwind Instruments', 'Percussion Instruments', 'Band & Orchestra', 'Sheet Music', 
        'Instrument Accessories', 'Concert Merchandise', 'Digital Music', 'Vinyl Records', 'CDs & DVDs', 
        'Blu-ray Discs', 'Streaming Subscriptions', 'E-Books', 'Audiobooks'
    ];
    category_manufacturers TEXT[] := ARRAY[
        'Sony', 'Nike', 'Penguin Random House', 'KitchenAid', 'Oréal', 'Adidas', 
        'LEGO', 'Bosch', 'Tiffany & Co.', 'Johnson & Johnson', 'Nestlé', 'Purina', 
        '3M', 'DeWalt', 'Scotts Miracle-Gro', 'Fender', 'Pampers', 'Nintendo', 
        'Warner Bros.', 'Microsoft', 'Crayola', 'Honeywell', 'Funko', 'Apple', 
        'Adidas', 'Etsy', 'Whirlpool', 'Canon', 'Samsonite', 'IKEA', 
        'Rolex', 'Amazon', 'Dell', 'Nest', 'Home Depot', 'Party City', 
        'Tempur-Pedic', 'Philips', 'Clorox', 'ADT', 'Rubbermaid', 'Hallmark', 
        'Moen', 'Pyrex', 'Anheuser-Busch', 'Dole', 'GNC', 
        'Coleman', 'Trek', 'Speedo', 'Burton', 'Shimano', 'Remington', 
        'Black Diamond', 'Lululemon', 'Capezio', 'Century', 'Hasbro', 
        'Ravensburger', 'Revell', 'National Geographic', 'LeapFrog', 'Gund', 
        'Mattel', 'Traxxas', 'Razer', 'Roku', 'Fitbit', 
        'OtterBox', 'Logitech', 'Belkin', 'Netgear', 'HP', 'Intel', 
        'Adobe', 'Samsung', 'Bose', 'Sonos', 'Dunlop', 'Pioneer DJ', 
        'Shure', 'Behringer', 'Moog', 'Yamaha', 'Gibson', 'Selmer', 
        'Pearl', 'Conn-Selmer', 'Hal Leonard', 'D’Addario', 'Bravado', 
        'Spotify', 'Sony Music', 'Universal Music', '20th Century Fox', 
        'Netflix', 'Kindle', 'Audible', 'Google', 'Facebook', 'Twitter', 'Tesla'
    ];
    random_category TEXT;
    random_price NUMERIC;
    manufacturer_name TEXT;
    manufacturer_uuid INT;
BEGIN

    SELECT array_agg(manufacturer_id) INTO manufacturer_ids FROM manufacturer;

    FOR i IN 1..num LOOP
        random_category := product_categories[CEIL(array_length(product_categories, 1) * random())::INT];
        
        -- Получаем соответствующего производителя для случайной категории
        manufacturer_name := category_manufacturers[array_position(product_categories, random_category)];
        SELECT manufacturer_id INTO manufacturer_uuid FROM manufacturer WHERE name = manufacturer_name;

        random_price := ROUND((RANDOM() * 1000)::numeric, 2);

        INSERT INTO product (name, price, manufacturer_id, category)
        VALUES (
            'Product ' || i,
            random_price,
            manufacturer_uuid,
            random_category
        );
    END LOOP;
END;

```
### 1.2. Доработка процедуры Customer
Процедура для генерации Customer со случайным gender : 
```sql
DECLARE
    i INT;
    random_gender gender;
BEGIN
    FOR i IN 1..num LOOP
        random_gender := (ARRAY['male'::gender, 'female'::gender])[FLOOR(RANDOM() * 2 + 1)];
        
        INSERT INTO customer (name, full_name, email, gender)
        VALUES (
            'customer-' || i,
            'full-name-' || ROUND((RANDOM() * i)::numeric, 2), 
            'email' || i || '@domain.ru',
            random_gender
        );
    END LOOP;
END
```
### Обновлённая схема БД.
![](https://github.com/badasqi/LR_EDB/blob/main/LR2/img/LR2_EDB_ER.png)

## Схему БД можно восстановить из бэкап [файла](https://github.com/badasqi/LR_EDB/blob/main/LR2/img/edb_backup_lr2.sql)

#### Был написан скрипт для выполнения запроса с извлечением из БД данных для каждого проданного продукта (категория, количество проданных товаров, суммарная стоимость, пол покупателя) и записи его в csv файл
```sql
COPY (
    WITH OrderSummary AS (
        -- Подсчёт суммарной стоимости и количества продаж по каждому заказу
        SELECT
            o.order_online_id,
            prod.name AS product_name,
            prod.category AS product_category,
            SUM(pis.price) AS order_price,
            SUM(pi.amount) AS total_amount_sold
        FROM
            online_order o
            JOIN purchase p ON o.purchase_id = p.purchase_id
            JOIN purchase_item pi ON pi.purchase_id = p.purchase_id
            JOIN product_in_shop pis ON pis.product_in_shop_id = pi.product_in_shop_id
            JOIN product prod ON pis.product_id = prod.product_id
        GROUP BY
            o.order_online_id,
            prod.name,
            prod.category
    ),
    OrderGender AS (
        SELECT
            o.order_online_id,
            c.gender
        FROM
            online_order o
            JOIN purchase p ON o.purchase_id = p.purchase_id
            JOIN customer c ON c.customer_id = o.customer_id
    )
    -- Выборка суммарного кол-ва проданных товаров и суммарной стоимости товара для каждого каждого пола
    SELECT
        os.product_name,
        os.product_category,
        'Female' AS gender,
        SUM(CASE WHEN og.gender = 'female' THEN os.total_amount_sold ELSE 0 END) AS amount_sold,
        SUM(CASE WHEN og.gender = 'female' THEN os.order_price ELSE 0 END) AS total_price
    FROM
        OrderSummary os
        JOIN OrderGender og ON os.order_online_id = og.order_online_id
    GROUP BY
        os.product_name,
        os.product_category

    UNION ALL

    SELECT
        os.product_name,
        os.product_category,
        'Male' AS gender,
        SUM(CASE WHEN og.gender = 'male' THEN os.total_amount_sold ELSE 0 END) AS amount_sold,
        SUM(CASE WHEN og.gender = 'male' THEN os.order_price ELSE 0 END) AS total_price
    FROM
        OrderSummary os
        JOIN OrderGender og ON os.order_online_id = og.order_online_id
    GROUP BY
        os.product_name,
        os.product_category
) TO 'C:/sales_by_gender.csv' WITH CSV HEADER;
```
#### Пример данных
![](https://github.com/badasqi/LR_EDB/blob/main/LR2/img/dataset.png)
#### [csv файл с датасетом](https://drive.google.com/file/d/1sAohe3Cr0kD-05ClAgMkIShu9OBDZE9I/view?usp=sharing)
### (2-6) Была спроектирована и обучена НС. Результаты по ссылке: [Обработка данных, подбор гиперпараметров, обучение лучшей модели и оценка метрик MAE, R^2 на тестовой выборке](https://github.com/badasqi/LR_EDB/blob/main/LR2_EDB.ipynb).
### Результаты
Блокнот с результатами: [https://github.com/badasqi/LR_EDB/blob/main/LR2_EDB.ipynb][1].

[1]: https://github.com/badasqi/LR_EDB/blob/main/LR2_EDB.ipynb

