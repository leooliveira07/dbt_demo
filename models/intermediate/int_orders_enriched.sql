with orders as (
    select * from {{ ref('stg_orders') }}
),

orders_items as (
    select * from {{ ref('stg_order_items') }}
),

items_agg as (
    select
        order_id,
        count(*) as item_count,
        sum(price) as items_total_value,
        sum(freight_value) as freight_total_value
    from orders_items
    group by order_id
),

final as (
    select
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_purchase_at,
        o.order_approved_at,
        o.order_delivered_carrier_at,
        o.order_delivered_customer_at,
        o.order_estimated_delivery_at,
        coalesce(i.item_count, 0) as item_count,
        coalesce(i.items_total_value, 0) as items_total_value,
        coalesce(i.freight_total_value, 0) as freight_total_value,
        coalesce(i.items_total_value, 0) + coalesce(i.freight_total_value, 0) as order_total_value,
        datediff(day, o.order_purchase_at, o.order_delivered_customer_at) as delivery_days,
        datediff(day, o.order_delivered_customer_at, o.order_estimated_delivery_at) as delivery_days_vs_estimate
    from orders o
    left join items_agg i on o.order_id = i.order_id
)

select * from final