with base as (

    select *
    from {{ ref('int_impact_dashboard_enriched') }}
    where impact_header = 'B. SECTORAL IMPACT'

),

fx_rates as (

    select *
    from {{ ref('stg_fx_rates') }}

),

final as (

    select
        base.record_sl_no              as sr_no,
        base.record_date               as date,
        base.fy,
        base.quarter,
        base.program_name,
        base.impact_header,
        base.impact_type_header,
        base.impact_sub_type_header,
        case
            when base.impact_type_header = 'Policy and/or scheme advised/influenced'
                then base.policy_name
            when base.impact_type_header = 'Platform/partnership/network nurtured' and base.impact_sub_type_header = 'Platforms'
                then base.platform_name
            else base.entity_name
        end                            as entity,
        case
            when base.impact_type_header = 'Lives impacted'
                then base.reach
            when base.impact_type_header = 'Government capital catalyzed'
                then base.budgetary_allocation
            when base.impact_type_header in (
                'Policy and/or scheme advised/influenced',
                'Platform/partnership/network nurtured'
            )
                then 1
            else null
        end                            as value,
        case
            when base.impact_type_header = 'Lives impacted'
                then 'Reach'
            when base.impact_type_header = 'Government capital catalyzed'
                then base.currency_iso_code
            when base.impact_type_header in (
                'Policy and/or scheme advised/influenced',
                'Platform/partnership/network nurtured'
            )
                then 'Count'
            else null
        end                            as value_label,
        case
            when base.impact_type_header = 'Government capital catalyzed' then
                case
                    when base.currency_iso_code = 'USD'
                        then base.budgetary_allocation
                    when base.currency_iso_code = 'INR'
                        then base.budgetary_allocation / nullif(fx_rates.usd_inr, 0)
                    when base.currency_iso_code = 'GBP'
                        then base.budgetary_allocation * fx_rates.gbp_inr / nullif(fx_rates.usd_inr, 0)
                    else null
                end
            else null
        end                            as amt_in_usd,
        case
            when base.impact_type_header = 'Government capital catalyzed' then
                case
                    when base.currency_iso_code = 'INR'
                        then base.budgetary_allocation
                    when base.currency_iso_code = 'USD'
                        then base.budgetary_allocation * fx_rates.usd_inr
                    when base.currency_iso_code = 'GBP'
                        then base.budgetary_allocation * fx_rates.gbp_inr
                    else null
                end
            else null
        end                            as amt_in_inr,
        base.description

    from base
    left join fx_rates
        on left(base.fy, 4) = fx_rates.year

)

select *
from final
