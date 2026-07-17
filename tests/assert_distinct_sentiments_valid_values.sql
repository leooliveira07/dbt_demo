-- Verifica se todo elemento dentro do array distinct_sentiments
-- pertence à lista de valores aceitos. Retorna linhas apenas
-- quando há violação (dbt falha o teste se a query retornar algo).

with exploded as (

    select
        order_id_sk,
        explode(distinct_sentiments) as sentiment_value

    from {{ ref('fct_orders') }}
    where distinct_sentiments is not null

)

select *
from exploded
where sentiment_value not in ('positive', 'neutral', 'negative')
