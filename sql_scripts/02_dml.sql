-- 1. Заполнение dim_customer (пропуск дубликатов)
INSERT INTO dim_customer (customer_id, first_name, last_name, age, email, country, postal_code)
SELECT DISTINCT
    sale_customer_id,
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    customer_country,
    customer_postal_code
FROM raw_mock_data
WHERE sale_customer_id IS NOT NULL
ON CONFLICT (customer_id) DO NOTHING;

-- 2. Заполнение dim_pet (пропуск дубликатов)
INSERT INTO dim_pet (customer_id, pet_type, pet_name, pet_breed)
SELECT DISTINCT
    sale_customer_id,
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed
FROM raw_mock_data
WHERE customer_pet_type IS NOT NULL
ON CONFLICT (pet_id) DO NOTHING;

-- 3. Заполнение dim_seller (пропуск дубликатов)
INSERT INTO dim_seller (seller_id, first_name, last_name, email, country, postal_code)
SELECT DISTINCT
    sale_seller_id,
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code
FROM raw_mock_data
WHERE sale_seller_id IS NOT NULL
ON CONFLICT (seller_id) DO NOTHING;

-- 4. Заполнение dim_supplier (пропуск дубликатов)
INSERT INTO dim_supplier (name, contact, email, phone, address, city, country)
SELECT DISTINCT
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM raw_mock_data
WHERE supplier_name IS NOT NULL
ON CONFLICT (supplier_id) DO NOTHING;

-- 5. Заполнение dim_store (пропуск дубликатов)
INSERT INTO dim_store (name, location, city, state, country, phone, email)
SELECT DISTINCT
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
FROM raw_mock_data
WHERE store_name IS NOT NULL
ON CONFLICT (store_id) DO NOTHING;

-- 6. Заполнение dim_product (пропуск дубликатов)
INSERT INTO dim_product (
    product_id, name, category, price, weight, color, size, brand, material,
    description, rating, reviews, release_date, expiry_date, supplier_id
)
SELECT DISTINCT
    sale_product_id,
    product_name,
    product_category,
    product_price,
    product_weight,
    product_color,
    product_size,
    product_brand,
    product_material,
    product_description,
    product_rating,
    product_reviews,
    product_release_date,
    product_expiry_date,
    (SELECT supplier_id FROM dim_supplier WHERE name = supplier_name LIMIT 1)
FROM raw_mock_data
WHERE sale_product_id IS NOT NULL
ON CONFLICT (product_id) DO NOTHING;

-- 7. Заполнение dim_date (пропуск дубликатов)
INSERT INTO dim_date (date_id, day, month, year, quarter)
SELECT DISTINCT
    sale_date,
    EXTRACT(DAY FROM sale_date),
    EXTRACT(MONTH FROM sale_date),
    EXTRACT(YEAR FROM sale_date),
    EXTRACT(QUARTER FROM sale_date)
FROM raw_mock_data
WHERE sale_date IS NOT NULL
ON CONFLICT (date_id) DO NOTHING;

-- 8. Заполнение fact_sales (без конфликтов, так как sale_id SERIAL)
INSERT INTO fact_sales (
    date_id, customer_id, seller_id, product_id, store_id, quantity, total_price
)
SELECT
    sale_date,
    sale_customer_id,
    sale_seller_id,
    sale_product_id,
    (SELECT store_id FROM dim_store WHERE name = store_name LIMIT 1),
    sale_quantity,
    sale_total_price
FROM raw_mock_data
WHERE
    sale_date IS NOT NULL AND
    sale_customer_id IS NOT NULL AND
    sale_seller_id IS NOT NULL AND
    sale_product_id IS NOT NULL;

-- Проверка количества записей
SELECT
    (SELECT COUNT(*) FROM dim_customer) AS customers,
    (SELECT COUNT(*) FROM dim_pet) AS pets,
    (SELECT COUNT(*) FROM dim_seller) AS sellers,
    (SELECT COUNT(*) FROM dim_supplier) AS suppliers,
    (SELECT COUNT(*) FROM dim_store) AS stores,
    (SELECT COUNT(*) FROM dim_product) AS products,
    (SELECT COUNT(*) FROM dim_date) AS dates,
    (SELECT COUNT(*) FROM fact_sales) AS sales;