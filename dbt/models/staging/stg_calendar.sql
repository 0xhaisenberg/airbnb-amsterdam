
with 

source as (

    select * from {{ source('staging', 'calendar') }}

),

calendar_entry as (

    select
        listing_id,
        date,
        available,
        price,
        adjusted_price,
        minimum_nights,
        maximum_nights

    from source

)

select * from calendar_entry
