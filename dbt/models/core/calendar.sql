
{{ config(
    materialized='table',
    partition_by={
      "field": "date",
      "data_type": "date",
      "granularity": "month"
    }
)}}


select
        listing_id,
        date,
        available,
        price,
        adjusted_price,
        minimum_nights,
        maximum_nights

        from {{ ref('base_bookings')}}