{{
    config(
        materialized='table'
    )
}}

with payments as (

    select * from {{ ref('stg_payments') }}

),

{% set payment_types = dbt_utils.get_column_values(table=ref('stg_payments'), column='payment_type') %}

final as (

    select
        order_id,

        {% for payment_type in payment_types %}
        sum(case when payment_type = '{{ payment_type }}' then payment_value else 0 end) as {{ payment_type }}_total
        {%- if not loop.last %},{% endif %}
        {% endfor %}

    from payments
    group by order_id

)

select * from final
