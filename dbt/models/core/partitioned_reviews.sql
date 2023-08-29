
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
        id,
        date,
        reviewer_id,
        reviewer_name,
        comments

        from {{ ref('base_reviews')}}