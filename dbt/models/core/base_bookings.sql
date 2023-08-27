with base_bookings as (
    
    select
        listing_id,
        date,
        available,
        price,
        adjusted_price,
        minimum_nights,
        maximum_nights

        from {{ ref('stg_calendar')}}
),

list_bookings as (

    select
        license,
        minimum_nights,
        maximum_nights,
        minimum_minimum_nights,
        maximum_minimum_nights,
        minimum_maximum_nights,
        maximum_maximum_nights,
        minimum_nights_avg_ntm,
        maximum_nights_avg_ntm,
        calendar_updated,
        has_availability,
        availability_30,
        availability_60,
        availability_90,
        availability_365,
        calendar_last_scraped,
        instant_bookable,
        calculated_host_listings_count,
        calculated_host_listings_count_entire_homes,
        calculated_host_listings_count_private_rooms,
        calculated_host_listings_count_shared_rooms


        from {{ ref('stg_listings')}}
)


select 
        bb.listing_id,
        bb.date,
        bb.available,
        bb.price,
        bb.adjusted_price,
        bb.minimum_nights,
        bb.maximum_nights,
        lb.license,
        lb.price,
        lb.minimum_nights,
        lb.maximum_nights,
        lb.minimum_minimum_nights,
        lb.maximum_minimum_nights,
        lb.minimum_maximum_nights,
        lb.maximum_maximum_nights,
        lb.minimum_nights_avg_ntm,
        lb.maximum_nights_avg_ntm,
        lb.calendar_updated,
        lb.has_availability,
        lb.availability_30,
        lb.availability_60,
        lb.availability_90,
        lb.availability_365,
        lb.calendar_last_scraped,
        lb.instant_bookable,
        lb.calculated_host_listings_count,
        lb.calculated_host_listings_count_entire_homes,
        lb.calculated_host_listings_count_private_rooms,
        lb.calculated_host_listings_count_shared_rooms,

from list_bookings lb
join base_bookings bb 
on lb.id=bb.listing_id