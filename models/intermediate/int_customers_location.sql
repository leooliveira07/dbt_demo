with customers as (

    select * from {{ ref('stg_customers') }}

),

geolocation as (

    select * from {{ ref('stg_geolocation') }}

),

geo_dedup as (

    select
        geolocation_zip_code_prefix,
        avg(geolocation_lat) as avg_lat,
        avg(geolocation_lng) as avg_lng

    from geolocation
    group by geolocation_zip_code_prefix

),

final as (

    select
        customers.customer_id,
        customers.customer_unique_id,
        customers.customer_zip_code_prefix,
        customers.customer_city,
        customers.customer_state,
        geo_dedup.avg_lat as customer_lat,
        geo_dedup.avg_lng as customer_lng

    from customers
    left join geo_dedup
        on customers.customer_zip_code_prefix = geo_dedup.geolocation_zip_code_prefix

)

select * from final
