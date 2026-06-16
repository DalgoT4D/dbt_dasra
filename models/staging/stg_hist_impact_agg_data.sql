with source as (

    select *
    from {{ source('GSheet_Raw_Data', 'hist_FinalSheet') }}

),

cleaned as (

    select
        nullif(trim("atp"), '')                                                      as atp,
        nullif(trim("year"), '')                                                     as year,
        nullif(trim("timeframe"), '')                                                as timeframe,
        nullif(trim("impact"), '')                                                   as impact,
        nullif(trim("new_particulars"), '')                                          as new_particulars,
        nullif(trim("title"), '')                                                    as title,   
        nullif(trim("new_team"), '')                                                 as new_team,
        nullif(trim("value_label"), '')                                              as value_label,

        -- value is stored as string; strip commas before casting to float
        cast(nullif(regexp_replace(trim("value"), ',', '', 'g'), '') as float)      as value

    from source

)

select
    year,
    timeframe,
    new_team as team,
    impact as impact_header,
    new_particulars as particular,
    title,
    atp,
    value,
    value_label
from cleaned
WHERE impact not in ('NA','')
and new_particulars not in ('NA','')
and title not in ('NA','')
