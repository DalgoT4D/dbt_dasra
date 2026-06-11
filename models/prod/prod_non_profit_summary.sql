with base as (

    select *
    from {{ ref('prod_non_profit') }}

),

by_impact_type as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        impact_type_header      as particulars,
        sum(amt_in_usd)         as value,
        'Funding Amount (USD)'  as value_label
    from base
    group by
        fy,
        quarter,
        program_name,
        impact_header,
        impact_type_header

),

by_dba_led as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        'DBA Led'               as particulars,
        sum(amt_in_usd)         as value,
        'Funding Amount (USD)'  as value_label
    from base
    where dba_led = 'Yes'
    group by
        fy,
        quarter,
        program_name,
        impact_header

),

by_women_led as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        'Women Led'             as particulars,
        sum(amt_in_usd)         as value,
        'Funding Amount (USD)'  as value_label
    from base
    where women_led = 'Yes'
    group by
        fy,
        quarter,
        program_name,
        impact_header

),

funding_amount as (

    select * from by_impact_type
    union all
    select * from by_dba_led
    union all
    select * from by_women_led

),

ngo_count_by_impact_type as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        impact_type_header      as particulars,
        count(distinct ngo_name) as value,
        'No. of NGOs'           as value_label
    from base
    group by
        fy,
        quarter,
        program_name,
        impact_header,
        impact_type_header

),

ngo_count_by_dba_led as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        'DBA Led'               as particulars,
        count(distinct ngo_name) as value,
        'No. of NGOs'           as value_label
    from base
    where dba_led = 'Yes'
    group by
        fy,
        quarter,
        program_name,
        impact_header

),

ngo_count_by_women_led as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        'Women Led'             as particulars,
        count(distinct ngo_name) as value,
        'No. of NGOs'           as value_label
    from base
    where women_led = 'Yes'
    group by
        fy,
        quarter,
        program_name,
        impact_header

),

ngo_count as (

    select * from ngo_count_by_impact_type
    union all
    select * from ngo_count_by_dba_led
    union all
    select * from ngo_count_by_women_led

),

final as (

    select * from funding_amount
    union all
    select * from ngo_count

)

select *
from final
order by fy desc, quarter desc, program_name, impact_header, value_label, particulars
