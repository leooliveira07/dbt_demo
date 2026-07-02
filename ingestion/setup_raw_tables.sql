-- Setup das tabelas raw a partir dos CSVs do dataset Olist
-- Fonte: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
-- Executar manualmente no SQL Editor do Databricks (fora do dbt)
-- Pré-requisito: CSVs já carregados no Volume leo.raw.olist_files

CREATE TABLE leo.raw.orders AS
SELECT * FROM read_files(
  '/Volumes/leo/raw/olist_files/olist_orders_dataset.csv',
  format => 'csv',
  header => true
);

CREATE TABLE leo.raw.order_items AS
SELECT * FROM read_files(
  '/Volumes/leo/raw/olist_files/olist_order_items_dataset.csv',
  format => 'csv',
  header => true
);

CREATE TABLE leo.raw.products AS
SELECT * FROM read_files(
  '/Volumes/leo/raw/olist_files/olist_products_dataset.csv',
  format => 'csv',
  header => true
);

CREATE TABLE leo.raw.sellers AS
SELECT * FROM read_files(
  '/Volumes/leo/raw/olist_files/olist_sellers_dataset.csv',
  format => 'csv',
  header => true
);

CREATE TABLE leo.raw.customers AS
SELECT * FROM read_files(
  '/Volumes/leo/raw/olist_files/olist_customers_dataset.csv',
  format => 'csv',
  header => true
);

CREATE TABLE leo.raw.geolocation AS
SELECT * FROM read_files(
  '/Volumes/leo/raw/olist_files/olist_geolocation_dataset.csv',
  format => 'csv',
  header => true
);

CREATE TABLE leo.raw.payments AS
SELECT * FROM read_files(
  '/Volumes/leo/raw/olist_files/olist_order_payments_dataset.csv',
  format => 'csv',
  header => true
);

CREATE TABLE leo.raw.reviews AS
SELECT * FROM read_files(
  '/Volumes/leo/raw/olist_files/olist_order_reviews_dataset.csv',
  format => 'csv',
  header => true
);

CREATE TABLE leo.raw.product_category_name_translation AS
SELECT * FROM read_files(
  '/Volumes/leo/raw/olist_files/product_category_name_translation.csv',
  format => 'csv',
  header => true
);
