with source as (

    select * from {{ source('olist_raw', 'payments') }}

),

renamed as (

    select
        order_id,
        cast(payment_sequential as int) as payment_sequential,
        payment_type,
        cast(payment_installments as int) as payment_installments,
        cast(payment_value as decimal(10,2)) as payment_value

    from source

)

select * from renamed
