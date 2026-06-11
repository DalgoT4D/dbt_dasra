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
        'Funding Amount (USD)'  as value_label
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
        'Funding Amount (USD)'  as value_label
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
        'Funding Amount (USD)'  as value_label
    from base
    where women_funder = 'Yes'
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

),

funder_count_by_impact_type as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        impact_type_header              as particulars,
        count(distinct funder_org_name) as value,
        'No. of Funders'                as value_label
    from base
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
        'No. of Funders'                as value_label
    from base
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
        'No. of Funders'                as value_label
    from base
    where women_funder = 'Yes'
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

),

final as (

    select * from funding_amount
    union all
    select * from funder_count

)

select *
from final
order by fy desc, quarter desc, program_name, impact_header, value_label, particulars
