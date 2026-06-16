with live as (

    select *
    from {{ ref('prod_philanthropic_summary') }}
    union all
    select *
    from {{ ref('prod_non_profit_summary') }}
    union all
    select *
    from {{ ref('prod_sectoral_summary') }}

),

live_title_mapped as (

    select
        l.fy,
        l.timeframe,
        l.program_name,
        l.impact_header,
        l.particulars,
        r.title,
        l.value,
        l.value_label,
        '(A)'          as atp,
        'live'         as data_source
    from live l
    left join {{ ref('stg_ref') }} r
    on l.impact_header = r.impact
    and l.value_label = r.value_label
    and l.particulars = r.particular

),

historical as (

    select
        year           as fy,
        timeframe,
        team           as program_name,
        impact_header,
        particular     as particulars,
        title,
        value,
        value_label,
        atp,
        'historical'   as data_source
    from {{ ref('stg_hist_impact_agg_data') }}

),

final as (

    select * from live_title_mapped
    union all
    select * from historical

)

select *
from final
order by fy desc, program_name, impact_header, value_label, particulars, timeframe asc
