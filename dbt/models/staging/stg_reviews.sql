with 

source as (

    select * from {{ source('staging', 'reviews') }}

),

entry_reviews as (

    select
        listing_id,
        id,
        date,
        reviewer_id,
        reviewer_name,
        comments

    from source

)

select * from entry_reviews

