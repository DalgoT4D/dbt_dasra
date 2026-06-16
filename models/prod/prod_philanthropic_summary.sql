with base as (

    select *
    from {{ ref('prod_philanthropic') }}

),

by_impact_type as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        impact_type_header      as particulars,
        sum(amt_in_usd)         as value,
        'Amount (USD)'  as value_label
    from base
    group by
        fy,
        quarter,
        program_name,
        impact_header,
        impact_type_header

),

by_region as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        region                  as particulars,
        sum(amt_in_usd)         as value,
        'Amount (USD)'  as value_label
    from base
    group by
        fy,
        quarter,
        program_name,
        impact_header,
        region

),

by_women_funder as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        'Women Funder'          as particulars,
        sum(amt_in_usd)         as value,
        'Amount (USD)'  as value_label
    from base
    where women_funder = 'Yes'
    group by
        fy,
        quarter,
        program_name,
        impact_header

),

total_phil_cap as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        'Philanthropic capital influenced'          as particulars,
        sum(value)         as value,
        'Amount (USD)'  as value_label
    from by_impact_type
    group by
        fy,
        quarter,
        program_name,
        impact_header

),

funding_amount as (

    select * from by_impact_type
    union all
    select * from by_region
    union all
    select * from by_women_funder
    union all
    select * from total_phil_cap

),

funder_count_by_impact_type as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        impact_type_header              as particulars,
        count(distinct funder_org_name) as value,
        'People'                as value_label
    from base
    where funding_given = 'Yes'     
    group by
        fy,
        quarter,
        program_name,
        impact_header,
        impact_type_header

),

funder_count_by_region as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        region                          as particulars,
        count(distinct funder_org_name) as value,
        'People'                as value_label
    from base
    where funding_given = 'Yes'  
    group by
        fy,
        quarter,
        program_name,
        impact_header,
        region

),

funder_count_by_women_funder as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        'Women Funder'                  as particulars,
        count(distinct funder_org_name) as value,
        'People'                as value_label
    from base
    where women_funder = 'Yes'
    and funding_given = 'Yes'  
    group by
        fy,
        quarter,
        program_name,
        impact_header

),

total_funders_engaged as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        'Total Funders Engaged'             as particulars,
        count(distinct funder_org_name) as value,
        'People'                as value_label
    from base
    group by
        fy,
        quarter,
        program_name,
        impact_header

),

network_of_givers as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        'Network of givers'             as particulars,
        sum(value)         as value,
        'People'                as value_label
    from funder_count_by_impact_type
    group by
        fy,
        quarter,
        program_name,
        impact_header

),

funder_count as (

    select * from funder_count_by_impact_type
    union all
    select * from funder_count_by_region
    union all
    select * from funder_count_by_women_funder
    union all
    select * from total_funders_engaged
    union all
    select * from network_of_givers

),

combined as (

    select * from funding_amount
    union all
    select * from funder_count

),

yearly_aggregate as (

    select 
        fy,
        'Yearly' as yearly,
        program_name,
        impact_header,
        particulars,
        sum(value)         as value,
        value_label
    from combined
    where quarter in ('Q1', 'Q2', 'Q3', 'Q4')
    group by 
        fy,
        program_name,
        impact_header,
        particulars,
        value_label

),

final as (

    select 
        fy,
        quarter as timeframe,
        program_name,
        impact_header,
        particulars,
        value,
        value_label 
    from combined

    union all

    select 
        fy,
        yearly as timeframe,
        program_name,
        impact_header,
        particulars,
        value,
        value_label 
    from yearly_aggregate

)

select *
from final
order by fy desc, program_name, impact_header, value_label, particulars, timeframe asc
