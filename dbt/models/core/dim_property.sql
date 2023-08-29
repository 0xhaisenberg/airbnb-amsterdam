with prop as (

    select
        id,
        listing_url,
        property_type,
        room_type,
        accommodates,
        bathrooms,
        bathrooms_text,
        bedrooms,
        beds,
        amenities

        from {{ ref('stg_listings')}}
)

select * from prop