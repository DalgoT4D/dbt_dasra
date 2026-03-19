with base as (

    select *
    from {{ ref('prod_sectoral') }}

),

by_impact_type as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        impact_type_header          as particulars,
        case
            when impact_type_header = 'Lives impacted'
                then sum(value)
            when impact_type_header = 'Government capital catalyzed'
                then sum(amt_in_usd)
            when impact_type_header in (
                'Policy and/or scheme advised/influenced',
                'Platform/partnership/network nurtured'
            )
                then count(distinct entity)
            else null
        end                         as value,
        case
            when impact_type_header = 'Lives impacted'
                then 'Reach'
            when impact_type_header = 'Government capital catalyzed'
                then 'Funding Amount (USD)'
            when impact_type_header in (
                'Policy and/or scheme advised/influenced',
                'Platform/partnership/network nurtured'
            )
                then 'Count'
            else null
        end                         as value_label
    from base
    group by
        fy,
        quarter,
        program_name,
        impact_header,
        impact_type_header

),

by_sub_type as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        coalesce(
            impact_sub_type_header,
            impact_type_header
        )                           as particulars,
        case
            when impact_type_header = 'Lives impacted'
                then sum(value)
            when impact_type_header = 'Government capital catalyzed'
                then sum(amt_in_usd)
            when impact_type_header in (
                'Policy and/or scheme advised/influenced',
                'Platform/partnership/network nurtured'
            )
                then count(distinct entity)
            else null
        end                         as value,
        case
            when impact_type_header = 'Lives impacted'
                then 'Reach'
            when impact_type_header = 'Government capital catalyzed'
                then 'Funding Amount (USD)'
            when impact_type_header in (
                'Policy and/or scheme advised/influenced',
                'Platform/partnership/network nurtured'
            )
                then 'Count'
            else null
        end                         as value_label
    from base
    group by
        fy,
        quarter,
        program_name,
        impact_header,
        impact_sub_type_header,
        impact_type_header

),

final as (

    select * from by_impact_type
    union all
    select * from by_sub_type

)

select *
from final
order by fy desc, quarter desc, program_name, impact_header, value_label, particulars
