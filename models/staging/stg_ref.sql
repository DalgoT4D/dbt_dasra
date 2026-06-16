with source as (

    select *
    from {{ source('GSheet_Raw_Data', 'ref') }}

),

cleaned as (

    select
        nullif(trim("impact"), '')                   as impact,
        nullif(trim("value_label"), '')              as value_label,
        nullif(trim("new_type_subtype_names"), '')   as particular,
        nullif(trim("title"), '')                    as title

    from source

)

select
    impact,
    value_label,
    particular,
    title
from cleaned
