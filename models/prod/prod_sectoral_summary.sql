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
            when impact_type_header in (
                'Lives impacted',
                'Platform/partnership/network nurtured'
            )
                then 'People'
            when impact_type_header = 'Government capital catalyzed'
                then 'Amount (USD)'
            when impact_type_header = 'Policy and/or scheme advised/influenced'
                then 'Policies'
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
        impact_sub_type_header  as particulars,
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
            when impact_type_header in (
                'Lives impacted',
                'Platform/partnership/network nurtured'
                )
                then 'People'
            when impact_type_header = 'Government capital catalyzed'
                then 'Amount (USD)'
            when impact_type_header = 'Policy and/or scheme advised/influenced'
                then 'Policies'
            else null
        end                         as value_label
    from base
    group by
        fy,
        quarter,
        program_name,
        impact_header,
        impact_type_header,
        impact_sub_type_header

),

combined as (

    select * from by_impact_type
    union all
    select * from by_sub_type

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
