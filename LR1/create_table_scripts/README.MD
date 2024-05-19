## Скрипты создания таблиц в БД и добавления к ним индексов

### Customer
```sql
CREATE TABLE IF NOT EXISTS public.customer
(
    customer_id integer NOT NULL DEFAULT nextval('customer_customer_id_seq'::regclass),
    name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    full_name character varying(100) COLLATE pg_catalog."default",
    email character varying(255) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT customer_pkey PRIMARY KEY (customer_id)
)
TABLESPACE pg_default;
	
-- Index: ix_customer_email
CREATE INDEX IF NOT EXISTS ix_customer_email
    ON public.customer USING btree
    (email COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
	
-- Index: ix_customer_name
CREATE INDEX IF NOT EXISTS ix_customer_name
    ON public.customer USING btree
    (name COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
```

### Manufacturer
```sql
-- Table: public.manufacturer

CREATE TABLE IF NOT EXISTS public.manufacturer
(
    manufacturer_id integer NOT NULL DEFAULT nextval('manufacturer_manufacturer_id_seq'::regclass),
    name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    email character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT manufacturer_pkey PRIMARY KEY (manufacturer_id)
)

TABLESPACE pg_default;

	
-- Index: ix_manufacturer_email
CREATE INDEX IF NOT EXISTS ix_manufacturer_email
    ON public.manufacturer USING btree
    (email COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
	
	
-- Index: ix_manufacturer_name
CREATE INDEX IF NOT EXISTS ix_manufacturer_name
    ON public.manufacturer USING btree
    (name COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
```

### Product
```sql
-- Table: public.product

-- DROP TABLE IF EXISTS public.product;

CREATE TABLE IF NOT EXISTS public.product
(
    product_id integer NOT NULL DEFAULT nextval('product_product_id_seq'::regclass),
    manufacturer_id bigint NOT NULL,
    name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    price numeric(40,0) NOT NULL,
    CONSTRAINT product_pkey PRIMARY KEY (product_id),
    CONSTRAINT manufacturer_fkey FOREIGN KEY (manufacturer_id)
        REFERENCES public.manufacturer (manufacturer_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.product
    OWNER to postgres;
-- Index: ix_product_name

-- DROP INDEX IF EXISTS public.ix_product_name;

CREATE INDEX IF NOT EXISTS ix_product_name
    ON public.product USING btree
    (name COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
```
