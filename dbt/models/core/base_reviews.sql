with rev_source as (

    select 
        listing_id,
        id,
        date,
        reviewer_id,
        reviewer_name,
        comments

        from {{ ref('stg_reviews')}}
),

list_reviews as (

    select
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
        reviews_per_month


        from {{ ref('stg_listings')}}
)

select 
        rv.listing_id,
        rv.id,
        rv.date,
        rv.reviewer_id,
        rv.reviewer_name,
        rv.comments,
        lr.number_of_reviews,
        lr.number_of_reviews_ltm,
        lr.number_of_reviews_l30d,
        lr.first_review,
        lr.last_review,
        lr.review_scores_rating,
        lr.review_scores_accuracy,
        lr.review_scores_cleanliness,
        lr.review_scores_checkin,
        lr.review_scores_communication,
        lr.review_scores_location,
        lr.review_scores_value,
        lr.reviews_per_month

        from list_reviews lr 
        join rev_source rv
        on lr.listing_id=rv.listing_id