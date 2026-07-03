with source as (

    select * from {{ source('olist_raw', 'geolocation') }}

),

renamed as (

    select
        geolocation_zip_code_prefix,
        cast(geolocation_lat as decimal(10,6)) as geolocation_lat,
        cast(geolocation_lng as decimal(10,6)) as geolocation_lng,
        geolocation_city,
        geolocation_state

    from source

)

select * from renamed
