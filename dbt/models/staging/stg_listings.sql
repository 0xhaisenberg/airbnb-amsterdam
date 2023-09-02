with

    source as (select * from {{ source("staging", "listings") }}),

    entry_lists as (

        select
            id,
            listing_url,
            scrape_id,
            last_scraped,
            name,
            description,
            neighborhood_overview,
            picture_url,
            host_id,
            host_url,
            host_name,
            host_since,
            host_location,
            host_about,
            host_response_time,
            host_response_rate,
            host_acceptance_rate,
            host_is_superhost,
            host_thumbnail_url,
            host_picture_url,
            host_neighbourhood,
            host_listings_count,
            host_total_listings_count,
            host_verifications,
            host_has_profile_pic,
            host_identity_verified,
            neighbourhood,
            neighbourhood_cleansed,
            neighbourhood_group_cleansed,
            latitude,
            longitude,
            property_type,
            room_type,
            accommodates,
            cast(bathrooms as int64) as bathrooms,
            bathrooms_text,
            cast(bedrooms as int64) as bedrooms,
            cast(beds as int64) as beds,
            amenities,
            cast(price as float64) as price,
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
            cast(calendar_last_scraped as date) as calendar_last_scraped,
            number_of_reviews,
            number_of_reviews_ltm,
            number_of_reviews_l30d,
            first_review,
            last_review,
            review_scores_rating,
            review_scores_accuracy,
            review_scores_cleanliness,
            review_scores_checkin,
            review_scores_communication,
            review_scores_location,
            review_scores_value,
            license,
            instant_bookable,
            calculated_host_listings_count,
            calculated_host_listings_count_entire_homes,
            calculated_host_listings_count_private_rooms,
            calculated_host_listings_count_shared_rooms,
            reviews_per_month

        from source

    )

select *
from entry_lists
