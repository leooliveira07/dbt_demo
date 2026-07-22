{{ 
    config(
        materialized='incremental',
        unique_key='order_id_sk',
        incremental_strategy='merge',
        on_schema_change='sync_all_columns',
        table_properties={'delta.columnMapping.mode': 'name'}
    ) 
}}

with order_items as (
    select * from {{ ref('stg_order_items') }}
),

orders_enriched as (
    select * from {{ ref('int_orders_enriched') }}
),

payments_summary as (
    select * from {{ ref("int_order_payments_summary")}}
),

reviews_enriched as (
    select * from {{ ref('int_reviews_enriched') }}
),

reviews_agg as (

    select
        order_id,
        count(*) as review_count,
        avg(review_score) as avg_review_score,
        collect_set(sentiment) as distinct_sentiments

    from reviews_enriched
    group by order_id

),
final as (
    select
        {{ dbt_utils.generate_surrogate_key(['order_items.order_id', 'order_items.order_item_id']) }} as order_id_sk,
        order_items.order_id,
        order_items.order_item_id,
        order_items.product_id,
        order_items.seller_id,
        orders_enriched.customer_id,
        order_items.price as item_price,
        order_items.freight_value as item_freight_value,
        orders_enriched.order_status,
        orders_enriched.order_purchase_at,
        orders_enriched.order_delivered_customer_at,
        orders_enriched.delivery_days,
        orders_enriched.delivery_days_vs_estimate,
        payments_summary.total_paid,
        payments_summary.predominant_payment_type,
        payments_summary.max_installments,
        reviews_agg.review_count,
        reviews_agg.avg_review_score,
        reviews_agg.distinct_sentiments
    from order_items
    left join orders_enriched
        on order_items.order_id = orders_enriched.order_id
    left join payments_summary
        on order_items.order_id = payments_summary.order_id
    left join reviews_agg
        on order_items.order_id = reviews_agg.order_id

)

select * from final

{% if is_incremental() %}
    where order_purchase_at > (select max(order_purchase_at) from {{ this }})
{% endif %}