with locations as (
    
    select
        name,
        description,
        neighborhood_overview,
        picture_url,
        host_location,
        neighbourhood,
        neighbourhood_cleansed,
        neighbourhood_group_cleansed,
        latitude,
        longitude

        
        from {{ ref('stg_listings')}}
)


select * from locations