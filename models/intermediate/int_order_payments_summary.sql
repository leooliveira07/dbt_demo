with payments as (

    select * from {{ ref('stg_payments') }}

),

payment_type_ranked as (

    select
        order_id,
        payment_type,
        row_number() over (
            partition by order_id
            order by payment_value desc
        ) as rn

    from payments

),

final as (

    select
        payments.order_id,
        sum(payments.payment_value) as total_paid,
        count(*) as payment_records_count,
        max(payments.payment_installments) as max_installments,
        max(case when payment_type_ranked.rn = 1 then payment_type_ranked.payment_type end) as predominant_payment_type

    from payments
    left join payment_type_ranked
        on payments.order_id = payment_type_ranked.order_id
        and payment_type_ranked.rn = 1
    group by payments.order_id

)

select * from final
