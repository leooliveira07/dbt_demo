with customers_location as (
    select * from {{ ref('int_customers_location') }}
),

final as (
    select
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        customer_lat,
        customer_lng
    from customers_location
)

select * from final