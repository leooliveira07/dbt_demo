{% snapshot snap_sellers %}

{{
   config(
       target_schema='snapshots',
       unique_key='seller_id',

       strategy='check',
       check_cols='all'
   )
}}

select * from {{ source('olist_raw', 'sellers') }}


{% endsnapshot %}