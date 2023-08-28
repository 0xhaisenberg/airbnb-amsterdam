
with 

source as (

    select * from {{ source('staging', 'calendar') }}

),

calendar_entry as (

    select
        listing_id,
        cast(date as DATE) as date,
        available,
        price,
        adjusted_price,
        cast(minimum_nights as INT64) as minimum_nights,
        cast(maximum_nights as INT64) as maximum_nights

    from source

)

select * from calendar_entry
