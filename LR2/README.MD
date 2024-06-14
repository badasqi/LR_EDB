# Лабораторная работа №2 
## ER модель БД была доработана для возможности формулировки задачи для машинного обучения. Был добавлен столбец gender для Customer и столбец category для Product:

## 1) Задача для машинного обучения заключается в прогнозировании количества товаров которое может быть продано случайной женщине или мужчине по всем онлайн магазинами портала. 
### Были переписаны процедуры Product для [генерации продуктов]() со случайной категорией (одной из 100 заданных)
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

    -- Собираем все существующие manufacturer_id в массив
    SELECT array_agg(manufacturer_id) INTO manufacturer_ids FROM manufacturer;

    FOR i IN 1..num LOOP
        -- Выбор случайной категории
        random_category := product_categories[CEIL(array_length(product_categories, 1) * random())::INT];
        
        -- Получаем соответствующего производителя для выбранной категории
        manufacturer_name := category_manufacturers[array_position(product_categories, random_category)];
        SELECT manufacturer_id INTO manufacturer_uuid FROM manufacturer WHERE name = manufacturer_name;

        -- Если manufacturer_uuid не найден, пропускаем итерацию
        IF manufacturer_uuid IS NULL THEN
            RAISE NOTICE 'Производитель для категории "%" не найден. Пропуск.', random_category;
            CONTINUE;
        END IF;

        -- Генерация случайной цены
        random_price := ROUND((RANDOM() * 1000)::numeric, 2);

        INSERT INTO product (name, price, manufacturer_id, category)
        VALUES (
            'Product ' || i,
            random_price,  -- Используем случайную цену для категории
            manufacturer_uuid,
            random_category  -- Используем случайную категорию
        );
    END LOOP;
END;

```
### Процедура для [генерации Customer]() со случайным gender.
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

## Схему БД можно восстановить из бэкап [файла]()

##

