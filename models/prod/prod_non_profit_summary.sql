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
        case impact_type_header      
            when 'Urban' then 'Funds Raised For Urban NGOs'
            when 'Rural' then 'Funds Raised For Rural NGOs'
            when 'Both' then 'Funds Raised For Both (Rural & Urban) NGOs'
            else null
        end as particulars,
        sum(amt_in_usd)         as value,
        'Amount (USD)'  as value_label
    from base
    where funding_received = 'Yes'
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
        'Funds Raised For DBA Leader NGOs'  as particulars,
        sum(amt_in_usd)         as value,
        'Amount (USD)'  as value_label
    from base
    where funding_received = 'Yes'
    and dba_led = 'Yes'
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
        'Funds Raised For Women Leader NGOs'  as particulars,
        sum(amt_in_usd)         as value,
        'Amount (USD)'  as value_label
    from base
    where funding_received = 'Yes'
    and women_led = 'Yes'
    group by
        fy,
        quarter,
        program_name,
        impact_header

),

total_funds_raised as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        'Funds raised for non-profits'             as particulars,
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
    select * from by_dba_led
    union all
    select * from by_women_led
    union all
    select * from total_funds_raised

),

supported_ngo_count_by_impact_type as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        case impact_type_header      
            when 'Urban' then 'Supported Urban NGOs'
            when 'Rural' then 'Supported Rural NGOs'
            when 'Both' then 'Supported Both (Rural & Urban) NGOs'
            else null
        end as particulars,
        count(distinct ngo_name) as value,
        'People'           as value_label
    from base
    group by
        fy,
        quarter,
        program_name,
        impact_header,
        impact_type_header

),

supported_ngo_count_by_dba_led as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        'Supported DBA Leader NGOs'  as particulars,
        count(distinct ngo_name) as value,
        'People'           as value_label
    from base
    where dba_led = 'Yes'
    group by
        fy,
        quarter,
        program_name,
        impact_header

),

supported_ngo_count_by_women_led as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        'Supported Women Leader NGOs'  as particulars,
        count(distinct ngo_name) as value,
        'People'           as value_label
    from base
    where women_led = 'Yes'
    group by
        fy,
        quarter,
        program_name,
        impact_header

),

total_supported_non_profits as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        'Non-profits supported'  as particulars,
        sum(value)         as value,
        'People'           as value_label
    from supported_ngo_count_by_impact_type
    group by
        fy,
        quarter,
        program_name,
        impact_header

),

supported_ngo_count as (

    select * from supported_ngo_count_by_impact_type
    union all
    select * from supported_ngo_count_by_dba_led
    union all
    select * from supported_ngo_count_by_women_led
    union all
    select * from total_supported_non_profits

),

funded_ngo_count_by_impact_type as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        case impact_type_header      
            when 'Urban' then 'Fund Receiving Urban NGOs'
            when 'Rural' then 'Fund Receiving Rural NGOs'
            when 'Both' then 'Fund Receiving Both (Rural & Urban) NGOs'
            else null
        end as particulars,
        count(distinct ngo_name) as value,
        'People'           as value_label
    from base
    where funding_received = 'Yes'
    group by
        fy,
        quarter,
        program_name,
        impact_header,
        impact_type_header

),

funded_ngo_count_by_dba_led as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        'Fund Receiving DBA Leader NGOs'  as particulars,
        count(distinct ngo_name) as value,
        'People'           as value_label
    from base
    where dba_led = 'Yes'
    and funding_received = 'Yes'
    group by
        fy,
        quarter,
        program_name,
        impact_header

),

funded_ngo_count_by_women_led as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        'Fund Receiving Women Leader NGOs'  as particulars,
        count(distinct ngo_name) as value,
        'People'           as value_label
    from base
    where women_led = 'Yes'
    and funding_received = 'Yes'
    group by
        fy,
        quarter,
        program_name,
        impact_header

),

total_funded_non_profits as (

    select
        fy,
        quarter,
        program_name,
        impact_header,
        'Non-profits receiving funds'  as particulars,
        sum(value)         as value,
        'People'           as value_label
    from funded_ngo_count_by_impact_type
    group by
        fy,
        quarter,
        program_name,
        impact_header

),

funded_ngo_count as (

    select * from funded_ngo_count_by_impact_type
    union all
    select * from funded_ngo_count_by_dba_led
    union all
    select * from funded_ngo_count_by_women_led
    union all
    select * from total_funded_non_profits

),

combined as (

    select * from funding_amount
    union all
    select * from supported_ngo_count
    union all
    select * from funded_ngo_count

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
