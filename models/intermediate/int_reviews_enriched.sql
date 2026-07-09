with reviews as (

    select * from {{ ref('stg_reviews') }}

),

final as (

    select
        review_id,
        order_id,
        review_score,
        review_comment_title,
        review_comment_message,
        review_created_at,
        review_answered_at,
        datediff(hour, review_created_at, review_answered_at) as response_time_hours,
        case
            when review_score >= 4 then 'positive'
            when review_score = 3 then 'neutral'
            when review_score <= 2 then 'negative'
        end as sentiment

    from reviews

)

select * from final
