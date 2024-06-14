--
-- PostgreSQL database dump
--

-- Dumped from database version 13.14
-- Dumped by pg_dump version 13.14

-- Started on 2024-06-15 00:08:30

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 682 (class 1247 OID 54135)
-- Name: gender; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.gender AS ENUM (
    'male',
    'female'
);


ALTER TYPE public.gender OWNER TO postgres;

--
-- TOC entry 647 (class 1247 OID 45938)
-- Name: order_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.order_status AS ENUM (
    'New',
    'Accepted',
    'Confirmed',
    'Sent',
    'Delivered to recipient',
    'Delivered to pickup-point',
    'Complete',
    'Awating payment',
    'Paid'
);


ALTER TYPE public.order_status OWNER TO postgres;

--
-- TOC entry 650 (class 1247 OID 45958)
-- Name: store_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.store_type AS ENUM (
    'Appliances',
    'Components for computers and laptops',
    'Grocery',
    'Agricultural'
);


ALTER TYPE public.store_type OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 45967)
-- Name: generate_customers(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.generate_customers(num integer)
    LANGUAGE plpgsql
    AS $$DECLARE
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
END$$;


ALTER PROCEDURE public.generate_customers(num integer) OWNER TO postgres;

--
-- TOC entry 216 (class 1255 OID 45968)
-- Name: generate_manufacturers(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.generate_manufacturers(num integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..num LOOP
        INSERT INTO manufacturer (name, email)
        VALUES (
            'manufacturer-' || i,
            'email' || i || '@domain.ru'
        );
    END LOOP;
END;
$$;


ALTER PROCEDURE public.generate_manufacturers(num integer) OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 45969)
-- Name: generate_online_orders(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.generate_online_orders(num integer)
    LANGUAGE plpgsql
    AS $$DECLARE
    i INT;
    purchase_ids INT[];
    customer_ids INT[];
    order_statuses order_status[]; -- Переменная для хранения возможных статусов заказа
BEGIN
    -- Заполнение массива purchase_ids существующими purchase_id
    SELECT array_agg(purchase_id) INTO purchase_ids FROM purchase;

    -- Заполнение массива customer_ids существующими customer_id
    SELECT array_agg(customer_id) INTO customer_ids FROM customer;
	
	order_statuses := ARRAY['New', 'Accepted', 'Confirmed', 'Sent', 'Delivered to recipient', 'Delivered to pickup-point', 'Complete', 'Awating payment', 'Paid'];

    FOR i IN 1..num LOOP
        -- Вставка записи в таблицу online_order с указанием случайных значений
        INSERT INTO online_order (customer_id, purchase_id, status)
        VALUES (
            customer_ids[ceil(array_length(customer_ids, 1) * random())::INT],  -- Генерация случайного customer_id
            purchase_ids[ceil(array_length(purchase_ids, 1) * random())::INT],  -- Генерация случайного purchase_id
            order_statuses[ceil(array_length(order_statuses, 1) * random())::INT] -- Генерация случайного статуса заказа
        );
    END LOOP;
END$$;


ALTER PROCEDURE public.generate_online_orders(num integer) OWNER TO postgres;

--
-- TOC entry 218 (class 1255 OID 45970)
-- Name: generate_online_stores(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.generate_online_stores(num integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    i INT;
    store_types store_type[] := ARRAY['Appliances', 'Grocery', 'Components for computers and laptops', 'Agricultural'];
BEGIN
    FOR i IN 1..num LOOP
        INSERT INTO online_store (name, store_type)
        VALUES (
            'Store-' || i,
            store_types[1 + (RANDOM() * array_length(store_types, 1))::INT - 1]
        );
    END LOOP;
END;
$$;


ALTER PROCEDURE public.generate_online_stores(num integer) OWNER TO postgres;

--
-- TOC entry 232 (class 1255 OID 45971)
-- Name: generate_products(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.generate_products(num integer)
    LANGUAGE plpgsql
    AS $$DECLARE
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
$$;


ALTER PROCEDURE public.generate_products(num integer) OWNER TO postgres;

--
-- TOC entry 219 (class 1255 OID 45972)
-- Name: generate_products_in_shop(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.generate_products_in_shop(num integer)
    LANGUAGE plpgsql
    AS $$DECLARE
    i INT;
    store_ids INT[];
    product_ids INT[];
BEGIN
    -- Собираем все существующие store_id в массив
    SELECT array_agg(online_store_id) INTO store_ids FROM online_store;

    -- Собираем все существующие product_id в массив
    SELECT array_agg(product_id) INTO product_ids FROM product;

    FOR i IN 1..num LOOP
        INSERT INTO product_in_shop (store_id, product_id, price)
        VALUES (
            store_ids[ceil(array_length(store_ids, 1) * random())::INT],  -- Генерация случайного store_id
            product_ids[ceil(array_length(product_ids, 1) * random())::INT],  -- Генерация случайного product_id
            ROUND((RANDOM() * 10000)::numeric, 2)  -- Генерация случайной цены до 10000
        );
    END LOOP;
END$$;


ALTER PROCEDURE public.generate_products_in_shop(num integer) OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 45973)
-- Name: generate_purchase_items(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.generate_purchase_items(num integer)
    LANGUAGE plpgsql
    AS $$DECLARE
    i INT;
    purchase_ids INT[];
    product_in_shop_ids INT[];
BEGIN
    -- Собираем все существующие purchase_id в массив
    SELECT array_agg(purchase_id) INTO purchase_ids FROM purchase;

    -- Собираем все существующие product_in_shop_id в массив
    SELECT array_agg(product_in_shop_id) INTO product_in_shop_ids FROM product_in_shop;

    FOR i IN 1..num LOOP
        INSERT INTO purchase_item (product_in_shop_id, amount, purchase_id)
        VALUES (
            product_in_shop_ids[ceil(array_length(product_in_shop_ids, 1) * random())::INT],  -- Генерация случайного product_in_shop_id
            1 + (RANDOM() * 10)::INT,  -- Генерация случайного количества (amount)
            purchase_ids[ceil(array_length(purchase_ids, 1) * random())::INT]  -- Генерация случайного purchase_id
        );
    END LOOP;
END$$;


ALTER PROCEDURE public.generate_purchase_items(num integer) OWNER TO postgres;

--
-- TOC entry 217 (class 1255 OID 45974)
-- Name: generate_purchases(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.generate_purchases(num integer)
    LANGUAGE plpgsql
    AS $$DECLARE
    i INT;
    store_ids INT[];
BEGIN
    -- Собираем все существующие store_id в массив
    SELECT array_agg(online_store_id) INTO store_ids FROM online_store;
    FOR i IN 1..num LOOP
        INSERT INTO purchase (store_id)
        VALUES (
            store_ids[ceil(array_length(store_ids, 1) * random())::INT]  -- Генерация случайного store_id
        );
    END LOOP;
END$$;


ALTER PROCEDURE public.generate_purchases(num integer) OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 54181)
-- Name: sales_by_gender(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sales_by_gender()
    LANGUAGE sql
    AS $$COPY (
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
    -- Получение информации о поле для каждого заказа
    OrderGender AS (
        SELECT
            o.order_online_id,
            c.gender
        FROM
            online_order o
            JOIN purchase p ON o.purchase_id = p.purchase_id
            JOIN customer c ON c.customer_id = o.customer_id
    )
    -- Выборка суммарного количества проданных единиц и суммарной стоимости товара для каждого пола
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
$$;


ALTER PROCEDURE public.sales_by_gender() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 213 (class 1259 OID 54122)
-- Name: customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer (
    customer_id bigint NOT NULL,
    name character varying NOT NULL,
    full_name character varying NOT NULL,
    email character varying NOT NULL,
    gender public.gender NOT NULL
);


ALTER TABLE public.customer OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 54120)
-- Name: customer_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customer_customer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.customer_customer_id_seq OWNER TO postgres;

--
-- TOC entry 3086 (class 0 OID 0)
-- Dependencies: 212
-- Name: customer_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customer_customer_id_seq OWNED BY public.customer.customer_id;


--
-- TOC entry 215 (class 1259 OID 54150)
-- Name: manufacturer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.manufacturer (
    manufacturer_id integer NOT NULL,
    name character varying NOT NULL,
    email character varying NOT NULL
);


ALTER TABLE public.manufacturer OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 54148)
-- Name: manufacturer_manufacturer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.manufacturer_manufacturer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.manufacturer_manufacturer_id_seq OWNER TO postgres;

--
-- TOC entry 3087 (class 0 OID 0)
-- Dependencies: 214
-- Name: manufacturer_manufacturer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.manufacturer_manufacturer_id_seq OWNED BY public.manufacturer.manufacturer_id;


--
-- TOC entry 200 (class 1259 OID 45988)
-- Name: online_order; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.online_order (
    order_online_id integer NOT NULL,
    purchase_id bigint NOT NULL,
    customer_id bigint NOT NULL,
    order_date date,
    status public.order_status
);


ALTER TABLE public.online_order OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 45991)
-- Name: online_order_order_online_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.online_order_order_online_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.online_order_order_online_id_seq OWNER TO postgres;

--
-- TOC entry 3088 (class 0 OID 0)
-- Dependencies: 201
-- Name: online_order_order_online_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.online_order_order_online_id_seq OWNED BY public.online_order.order_online_id;


--
-- TOC entry 202 (class 1259 OID 45993)
-- Name: online_store; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.online_store (
    online_store_id integer NOT NULL,
    name character varying(255),
    store_type public.store_type
);


ALTER TABLE public.online_store OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 45996)
-- Name: online_store_online_store_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.online_store_online_store_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.online_store_online_store_id_seq OWNER TO postgres;

--
-- TOC entry 3089 (class 0 OID 0)
-- Dependencies: 203
-- Name: online_store_online_store_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.online_store_online_store_id_seq OWNED BY public.online_store.online_store_id;


--
-- TOC entry 204 (class 1259 OID 45998)
-- Name: product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product (
    product_id integer NOT NULL,
    manufacturer_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    price numeric(40,0) NOT NULL,
    category character varying(50) NOT NULL
);


ALTER TABLE public.product OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 46001)
-- Name: product_in_shop; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_in_shop (
    product_in_shop_id integer NOT NULL,
    product_id bigint NOT NULL,
    store_id bigint NOT NULL,
    price numeric(40,0) NOT NULL
);


ALTER TABLE public.product_in_shop OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 46004)
-- Name: product_in_shop_product_in_shop_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_in_shop_product_in_shop_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.product_in_shop_product_in_shop_id_seq OWNER TO postgres;

--
-- TOC entry 3090 (class 0 OID 0)
-- Dependencies: 206
-- Name: product_in_shop_product_in_shop_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_in_shop_product_in_shop_id_seq OWNED BY public.product_in_shop.product_in_shop_id;


--
-- TOC entry 207 (class 1259 OID 46006)
-- Name: product_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.product_product_id_seq OWNER TO postgres;

--
-- TOC entry 3091 (class 0 OID 0)
-- Dependencies: 207
-- Name: product_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_product_id_seq OWNED BY public.product.product_id;


--
-- TOC entry 208 (class 1259 OID 46008)
-- Name: purchase; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.purchase (
    purchase_id bigint NOT NULL,
    store_id bigint NOT NULL
);


ALTER TABLE public.purchase OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 46011)
-- Name: purchase_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.purchase_item (
    purchase_item_id integer NOT NULL,
    product_in_shop_id bigint NOT NULL,
    amount numeric(10,0) NOT NULL,
    purchase_id bigint NOT NULL
);


ALTER TABLE public.purchase_item OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 46014)
-- Name: purchase_item_purchase_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.purchase_item_purchase_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.purchase_item_purchase_item_id_seq OWNER TO postgres;

--
-- TOC entry 3092 (class 0 OID 0)
-- Dependencies: 210
-- Name: purchase_item_purchase_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.purchase_item_purchase_item_id_seq OWNED BY public.purchase_item.purchase_item_id;


--
-- TOC entry 211 (class 1259 OID 46016)
-- Name: purchase_purchase_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.purchase_purchase_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.purchase_purchase_id_seq OWNER TO postgres;

--
-- TOC entry 3093 (class 0 OID 0)
-- Dependencies: 211
-- Name: purchase_purchase_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.purchase_purchase_id_seq OWNED BY public.purchase.purchase_id;


--
-- TOC entry 2918 (class 2604 OID 54125)
-- Name: customer customer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer ALTER COLUMN customer_id SET DEFAULT nextval('public.customer_customer_id_seq'::regclass);


--
-- TOC entry 2919 (class 2604 OID 54153)
-- Name: manufacturer manufacturer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manufacturer ALTER COLUMN manufacturer_id SET DEFAULT nextval('public.manufacturer_manufacturer_id_seq'::regclass);


--
-- TOC entry 2912 (class 2604 OID 46020)
-- Name: online_order order_online_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.online_order ALTER COLUMN order_online_id SET DEFAULT nextval('public.online_order_order_online_id_seq'::regclass);


--
-- TOC entry 2913 (class 2604 OID 46021)
-- Name: online_store online_store_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.online_store ALTER COLUMN online_store_id SET DEFAULT nextval('public.online_store_online_store_id_seq'::regclass);


--
-- TOC entry 2914 (class 2604 OID 46022)
-- Name: product product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product ALTER COLUMN product_id SET DEFAULT nextval('public.product_product_id_seq'::regclass);


--
-- TOC entry 2915 (class 2604 OID 46023)
-- Name: product_in_shop product_in_shop_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_in_shop ALTER COLUMN product_in_shop_id SET DEFAULT nextval('public.product_in_shop_product_in_shop_id_seq'::regclass);


--
-- TOC entry 2916 (class 2604 OID 46024)
-- Name: purchase purchase_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase ALTER COLUMN purchase_id SET DEFAULT nextval('public.purchase_purchase_id_seq'::regclass);


--
-- TOC entry 2917 (class 2604 OID 46025)
-- Name: purchase_item purchase_item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_item ALTER COLUMN purchase_item_id SET DEFAULT nextval('public.purchase_item_purchase_item_id_seq'::regclass);


--
-- TOC entry 2940 (class 2606 OID 54130)
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);


--
-- TOC entry 2942 (class 2606 OID 54158)
-- Name: manufacturer manufacturer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manufacturer
    ADD CONSTRAINT manufacturer_pkey PRIMARY KEY (manufacturer_id);


--
-- TOC entry 2922 (class 2606 OID 46031)
-- Name: online_order online_order_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.online_order
    ADD CONSTRAINT online_order_pkey PRIMARY KEY (order_online_id);


--
-- TOC entry 2925 (class 2606 OID 46033)
-- Name: online_store online_store_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.online_store
    ADD CONSTRAINT online_store_pkey PRIMARY KEY (online_store_id);


--
-- TOC entry 2932 (class 2606 OID 46035)
-- Name: product_in_shop product_in_shop_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_in_shop
    ADD CONSTRAINT product_in_shop_pkey PRIMARY KEY (product_in_shop_id);


--
-- TOC entry 2928 (class 2606 OID 46037)
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (product_id);


--
-- TOC entry 2938 (class 2606 OID 46039)
-- Name: purchase_item purchase_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_item
    ADD CONSTRAINT purchase_item_pkey PRIMARY KEY (purchase_item_id);


--
-- TOC entry 2934 (class 2606 OID 46041)
-- Name: purchase purchase_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase
    ADD CONSTRAINT purchase_pkey PRIMARY KEY (purchase_id);


--
-- TOC entry 2920 (class 1259 OID 46046)
-- Name: ix_online_order_purchase_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_online_order_purchase_id ON public.online_order USING btree (purchase_id);


--
-- TOC entry 2923 (class 1259 OID 46047)
-- Name: ix_online_store_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_online_store_name ON public.online_store USING btree (name);


--
-- TOC entry 2929 (class 1259 OID 46048)
-- Name: ix_product_in_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_product_in_product_id ON public.product_in_shop USING btree (product_id);


--
-- TOC entry 2930 (class 1259 OID 46049)
-- Name: ix_product_in_shop_store_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_product_in_shop_store_id ON public.product_in_shop USING btree (store_id);


--
-- TOC entry 2926 (class 1259 OID 46050)
-- Name: ix_product_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_product_name ON public.product USING btree (name);


--
-- TOC entry 2935 (class 1259 OID 46051)
-- Name: ix_purchase_item_product_in_shop_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_purchase_item_product_in_shop_id ON public.purchase_item USING btree (product_in_shop_id);


--
-- TOC entry 2936 (class 1259 OID 46052)
-- Name: ix_purchase_item_purchase_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_purchase_item_purchase_id ON public.purchase_item USING btree (purchase_id);


--
-- TOC entry 2944 (class 2606 OID 54176)
-- Name: online_order customer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.online_order
    ADD CONSTRAINT customer_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id) NOT VALID;


--
-- TOC entry 2945 (class 2606 OID 54159)
-- Name: product manufacturer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT manufacturer_fkey FOREIGN KEY (manufacturer_id) REFERENCES public.manufacturer(manufacturer_id) NOT VALID;


--
-- TOC entry 2946 (class 2606 OID 46063)
-- Name: product_in_shop product_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_in_shop
    ADD CONSTRAINT product_fkey FOREIGN KEY (product_id) REFERENCES public.product(product_id);


--
-- TOC entry 2949 (class 2606 OID 46068)
-- Name: purchase_item product_in_shop_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_item
    ADD CONSTRAINT product_in_shop_fkey FOREIGN KEY (product_in_shop_id) REFERENCES public.product_in_shop(product_in_shop_id);


--
-- TOC entry 2943 (class 2606 OID 46073)
-- Name: online_order purchase_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.online_order
    ADD CONSTRAINT purchase_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchase(purchase_id);


--
-- TOC entry 2950 (class 2606 OID 46078)
-- Name: purchase_item purchase_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_item
    ADD CONSTRAINT purchase_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchase(purchase_id) NOT VALID;


--
-- TOC entry 2947 (class 2606 OID 46083)
-- Name: product_in_shop store_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_in_shop
    ADD CONSTRAINT store_fkey FOREIGN KEY (store_id) REFERENCES public.online_store(online_store_id);


--
-- TOC entry 2948 (class 2606 OID 46088)
-- Name: purchase store_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase
    ADD CONSTRAINT store_fkey FOREIGN KEY (store_id) REFERENCES public.online_store(online_store_id);


-- Completed on 2024-06-15 00:08:31

--
-- PostgreSQL database dump complete
--

