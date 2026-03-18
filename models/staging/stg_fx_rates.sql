with source as (

    select *
    from {{ source('GSheet_Raw_Data', 'FX_Rates') }}

),

cleaned as (

    select
        -- year
        nullif(trim("year_mar_31_"), '')                                            as year,

        -- fx rates (source values are strings; strip commas before casting)
        cast(nullif(regexp_replace(trim("usd_inr"), ',', '', 'g'), '') as float)   as usd_inr,
        cast(nullif(regexp_replace(trim("gbp_inr"), ',', '', 'g'), '') as float)   as gbp_inr

    from source

)

select
    year,
    usd_inr,
    gbp_inr
from cleaned
