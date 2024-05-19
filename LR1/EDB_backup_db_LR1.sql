--
-- PostgreSQL database dump
--

-- Dumped from database version 13.14
-- Dumped by pg_dump version 13.14

-- Started on 2024-05-19 21:34:37

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
-- TOC entry 684 (class 1247 OID 45454)
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
-- TOC entry 660 (class 1247 OID 45362)
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
-- TOC entry 216 (class 1255 OID 45480)
-- Name: generate_customers(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.generate_customers(num integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..num LOOP
        INSERT INTO customer (name, full_name, email)
        VALUES (
            'customer-' || i,
			'full-name-' || ROUND((RANDOM() * i)::numeric, 2), 
            'email' || i || '@domain.ru'
        );
    END LOOP;
END;
$$;


ALTER FUNCTION public.generate_customers(num integer) OWNER TO postgres;

--
-- TOC entry 218 (class 1255 OID 45510)
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
-- TOC entry 217 (class 1255 OID 45511)
-- Name: generate_online_orders(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.generate_online_orders(num integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    i INT;
    purchase_count INT;
BEGIN
    SELECT COUNT(*) INTO purchase_count FROM purchase;
    
    -- Цикл для вставки записей в таблицу online_order
    FOR i IN 1..num LOOP
        INSERT INTO online_order (customer_id, purchase_id)
        VALUES (
            1 + (RANDOM() * 1000)::INT,  -- Генерация случайного customer_id
            1 + (RANDOM() * (purchase_count - 1))::INT  -- Генерация случайного purchase_id
        );
    END LOOP;
END;
$$;


ALTER PROCEDURE public.generate_online_orders(num integer) OWNER TO postgres;

--
-- TOC entry 219 (class 1255 OID 45512)
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
-- TOC entry 220 (class 1255 OID 45513)
-- Name: generate_products(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.generate_products(num integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    i INT;
    manufacturer_count INT;
BEGIN
    SELECT COUNT(*) INTO manufacturer_count FROM manufacturer;
    
    FOR i IN 1..num LOOP
        INSERT INTO product (name, price, manufacturer_id)
        VALUES (
            'Product ' || i,
            ROUND((RANDOM() * 100)::numeric, 2),  -- Генерация случайной цены
            1 + (RANDOM() * (manufacturer_count - 1))::INT  -- Генерация случайного manufacturer_id
        );
    END LOOP;
END;
$$;


ALTER PROCEDURE public.generate_products(num integer) OWNER TO postgres;

--
-- TOC entry 232 (class 1255 OID 45514)
-- Name: generate_products_in_shop(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.generate_products_in_shop(num integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    i INT;
    store_count INT;
    product_count INT;
BEGIN
    SELECT COUNT(*) INTO store_count FROM online_store;
    
    SELECT COUNT(*) INTO product_count FROM product;
    
    FOR i IN 1..num LOOP
        INSERT INTO product_in_shop (store_id, product_id, price)
        VALUES (
            1 + (RANDOM() * (store_count - 1))::INT,  -- Генерация случайного store_id
            1 + (RANDOM() * (product_count - 1))::INT,  -- Генерация случайного product_id
            ROUND((RANDOM() * 10000)::numeric, 2)  -- Генерация случайной цены до 10000
        );
    END LOOP;
END;
$$;


ALTER PROCEDURE public.generate_products_in_shop(num integer) OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 45515)
-- Name: generate_purchase_items(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.generate_purchase_items(num integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    i INT;
    purchase_count INT;
    product_in_shop_count INT;
BEGIN
    SELECT COUNT(*) INTO purchase_count FROM purchase;
    SELECT COUNT(*) INTO product_in_shop_count FROM product_in_shop;
	
    FOR i IN 1..num LOOP
        INSERT INTO purchase_item (product_in_shop_id, amount, purchase_id)
        VALUES (
            1 + (RANDOM() * (product_in_shop_count - 1))::INT,  -- Генерация случайного product_in_shop_id
            1 + (RANDOM() * 10)::INT,  -- Генерация случайного количества (amount)
            1 + (RANDOM() * (purchase_count - 1))::INT  -- Генерация случайного purchase_id
        );
    END LOOP;
END;
$$;


ALTER PROCEDURE public.generate_purchase_items(num integer) OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 45516)
-- Name: generate_purchases(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.generate_purchases(num integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    i INT;
    store_count INT;
BEGIN
    SELECT COUNT(*) INTO store_count FROM online_store;
    FOR i IN 1..num LOOP
        INSERT INTO purchase (store_id)
        VALUES (
            1 + (RANDOM() * (store_count - 1))::INT
        );
    END LOOP;
END;
$$;


ALTER PROCEDURE public.generate_purchases(num integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 213 (class 1259 OID 45418)
-- Name: customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer (
    customer_id integer NOT NULL,
    name character varying(100) NOT NULL,
    full_name character varying(100),
    email character varying(255) NOT NULL
);


ALTER TABLE public.customer OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 45416)
-- Name: customer_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customer_customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.customer_customer_id_seq OWNER TO postgres;

--
-- TOC entry 3085 (class 0 OID 0)
-- Dependencies: 212
-- Name: customer_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customer_customer_id_seq OWNED BY public.customer.customer_id;


--
-- TOC entry 203 (class 1259 OID 45336)
-- Name: manufacturer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.manufacturer (
    manufacturer_id integer NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255)
);


ALTER TABLE public.manufacturer OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 45334)
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
-- TOC entry 3086 (class 0 OID 0)
-- Dependencies: 202
-- Name: manufacturer_manufacturer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.manufacturer_manufacturer_id_seq OWNED BY public.manufacturer.manufacturer_id;


--
-- TOC entry 215 (class 1259 OID 45426)
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
-- TOC entry 214 (class 1259 OID 45424)
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
-- TOC entry 3087 (class 0 OID 0)
-- Dependencies: 214
-- Name: online_order_order_online_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.online_order_order_online_id_seq OWNED BY public.online_order.order_online_id;


--
-- TOC entry 205 (class 1259 OID 45352)
-- Name: online_store; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.online_store (
    online_store_id integer NOT NULL,
    name character varying(255),
    store_type public.store_type
);


ALTER TABLE public.online_store OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 45350)
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
-- TOC entry 3088 (class 0 OID 0)
-- Dependencies: 204
-- Name: online_store_online_store_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.online_store_online_store_id_seq OWNED BY public.online_store.online_store_id;


--
-- TOC entry 201 (class 1259 OID 45328)
-- Name: product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product (
    product_id integer NOT NULL,
    manufacturer_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    price numeric(40,0) NOT NULL
);


ALTER TABLE public.product OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 45371)
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
-- TOC entry 206 (class 1259 OID 45369)
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
-- TOC entry 3089 (class 0 OID 0)
-- Dependencies: 206
-- Name: product_in_shop_product_in_shop_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_in_shop_product_in_shop_id_seq OWNED BY public.product_in_shop.product_in_shop_id;


--
-- TOC entry 200 (class 1259 OID 45326)
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
-- TOC entry 3090 (class 0 OID 0)
-- Dependencies: 200
-- Name: product_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_product_id_seq OWNED BY public.product.product_id;


--
-- TOC entry 209 (class 1259 OID 45389)
-- Name: purchase; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.purchase (
    purchase_id bigint NOT NULL,
    store_id bigint NOT NULL
);


ALTER TABLE public.purchase OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 45402)
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
-- TOC entry 210 (class 1259 OID 45400)
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
-- TOC entry 3091 (class 0 OID 0)
-- Dependencies: 210
-- Name: purchase_item_purchase_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.purchase_item_purchase_item_id_seq OWNED BY public.purchase_item.purchase_item_id;


--
-- TOC entry 208 (class 1259 OID 45387)
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
-- TOC entry 3092 (class 0 OID 0)
-- Dependencies: 208
-- Name: purchase_purchase_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.purchase_purchase_id_seq OWNED BY public.purchase.purchase_id;


--
-- TOC entry 2915 (class 2604 OID 45421)
-- Name: customer customer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer ALTER COLUMN customer_id SET DEFAULT nextval('public.customer_customer_id_seq'::regclass);


--
-- TOC entry 2910 (class 2604 OID 45339)
-- Name: manufacturer manufacturer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manufacturer ALTER COLUMN manufacturer_id SET DEFAULT nextval('public.manufacturer_manufacturer_id_seq'::regclass);


--
-- TOC entry 2916 (class 2604 OID 45429)
-- Name: online_order order_online_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.online_order ALTER COLUMN order_online_id SET DEFAULT nextval('public.online_order_order_online_id_seq'::regclass);


--
-- TOC entry 2911 (class 2604 OID 45355)
-- Name: online_store online_store_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.online_store ALTER COLUMN online_store_id SET DEFAULT nextval('public.online_store_online_store_id_seq'::regclass);


--
-- TOC entry 2909 (class 2604 OID 45331)
-- Name: product product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product ALTER COLUMN product_id SET DEFAULT nextval('public.product_product_id_seq'::regclass);


--
-- TOC entry 2912 (class 2604 OID 45374)
-- Name: product_in_shop product_in_shop_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_in_shop ALTER COLUMN product_in_shop_id SET DEFAULT nextval('public.product_in_shop_product_in_shop_id_seq'::regclass);


--
-- TOC entry 2913 (class 2604 OID 45392)
-- Name: purchase purchase_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase ALTER COLUMN purchase_id SET DEFAULT nextval('public.purchase_purchase_id_seq'::regclass);


--
-- TOC entry 2914 (class 2604 OID 45405)
-- Name: purchase_item purchase_item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_item ALTER COLUMN purchase_item_id SET DEFAULT nextval('public.purchase_item_purchase_item_id_seq'::regclass);


--
-- TOC entry 2936 (class 2606 OID 45423)
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);


--
-- TOC entry 2923 (class 2606 OID 45344)
-- Name: manufacturer manufacturer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manufacturer
    ADD CONSTRAINT manufacturer_pkey PRIMARY KEY (manufacturer_id);


--
-- TOC entry 2941 (class 2606 OID 45431)
-- Name: online_order online_order_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.online_order
    ADD CONSTRAINT online_order_pkey PRIMARY KEY (order_online_id);


--
-- TOC entry 2926 (class 2606 OID 45360)
-- Name: online_store online_store_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.online_store
    ADD CONSTRAINT online_store_pkey PRIMARY KEY (online_store_id);


--
-- TOC entry 2928 (class 2606 OID 45376)
-- Name: product_in_shop product_in_shop_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_in_shop
    ADD CONSTRAINT product_in_shop_pkey PRIMARY KEY (product_in_shop_id);


--
-- TOC entry 2919 (class 2606 OID 45333)
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (product_id);


--
-- TOC entry 2934 (class 2606 OID 45407)
-- Name: purchase_item purchase_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_item
    ADD CONSTRAINT purchase_item_pkey PRIMARY KEY (purchase_item_id);


--
-- TOC entry 2930 (class 2606 OID 45394)
-- Name: purchase purchase_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase
    ADD CONSTRAINT purchase_pkey PRIMARY KEY (purchase_id);


--
-- TOC entry 2937 (class 1259 OID 45448)
-- Name: ix_customer_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_customer_email ON public.customer USING btree (email);


--
-- TOC entry 2938 (class 1259 OID 45447)
-- Name: ix_customer_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_customer_name ON public.customer USING btree (name);


--
-- TOC entry 2920 (class 1259 OID 45450)
-- Name: ix_manufacturer_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_manufacturer_email ON public.manufacturer USING btree (email);


--
-- TOC entry 2921 (class 1259 OID 45449)
-- Name: ix_manufacturer_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_manufacturer_name ON public.manufacturer USING btree (name);


--
-- TOC entry 2939 (class 1259 OID 45507)
-- Name: ix_online_order_purchase_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_online_order_purchase_id ON public.online_order USING btree (purchase_id);


--
-- TOC entry 2924 (class 1259 OID 45451)
-- Name: ix_online_store_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_online_store_name ON public.online_store USING btree (name);


--
-- TOC entry 2917 (class 1259 OID 45452)
-- Name: ix_product_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_product_name ON public.product USING btree (name);


--
-- TOC entry 2931 (class 1259 OID 45509)
-- Name: ix_purchase_item_product_in_shop_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_purchase_item_product_in_shop_id ON public.purchase_item USING btree (product_in_shop_id);


--
-- TOC entry 2932 (class 1259 OID 45508)
-- Name: ix_purchase_item_purchase_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_purchase_item_purchase_id ON public.purchase_item USING btree (purchase_id);


--
-- TOC entry 2949 (class 2606 OID 45437)
-- Name: online_order customer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.online_order
    ADD CONSTRAINT customer_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id);


--
-- TOC entry 2942 (class 2606 OID 45345)
-- Name: product manufacturer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT manufacturer_fkey FOREIGN KEY (manufacturer_id) REFERENCES public.manufacturer(manufacturer_id) NOT VALID;


--
-- TOC entry 2944 (class 2606 OID 45382)
-- Name: product_in_shop product_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_in_shop
    ADD CONSTRAINT product_fkey FOREIGN KEY (product_id) REFERENCES public.product(product_id);


--
-- TOC entry 2946 (class 2606 OID 45408)
-- Name: purchase_item product_in_shop_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_item
    ADD CONSTRAINT product_in_shop_fkey FOREIGN KEY (product_in_shop_id) REFERENCES public.product_in_shop(product_in_shop_id);


--
-- TOC entry 2948 (class 2606 OID 45432)
-- Name: online_order purchase_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.online_order
    ADD CONSTRAINT purchase_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchase(purchase_id);


--
-- TOC entry 2947 (class 2606 OID 45442)
-- Name: purchase_item purchase_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_item
    ADD CONSTRAINT purchase_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchase(purchase_id) NOT VALID;


--
-- TOC entry 2943 (class 2606 OID 45377)
-- Name: product_in_shop store_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_in_shop
    ADD CONSTRAINT store_fkey FOREIGN KEY (store_id) REFERENCES public.online_store(online_store_id);


--
-- TOC entry 2945 (class 2606 OID 45395)
-- Name: purchase store_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase
    ADD CONSTRAINT store_fkey FOREIGN KEY (store_id) REFERENCES public.online_store(online_store_id);


-- Completed on 2024-05-19 21:34:37

--
-- PostgreSQL database dump complete
--

