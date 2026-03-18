with base as (

    select *
    from {{ ref('int_impact_dashboard_enriched') }}
    where impact_header = 'C. NON-PROFIT IMPACT'

),

fx_rates as (

    select *
    from {{ ref('stg_fx_rates') }}

),

final as (

    select
        base.record_sl_no                  as sr_no,
        base.record_date                   as date,
        base.fy,
        base.quarter,
        base.program_name,
        base.impact_header,
        base.impact_type_header,
        base.non_profit_supported_name     as ngo_name,
        base.dba_leader                    as dba_led,
        base.women_leader                  as women_led,
        base.funding_received,
        base.funds_received_by_non_profits as funding_amount,
        base.currency_iso_code             as currency,
        case
            when base.currency_iso_code = 'USD'
                then base.funds_received_by_non_profits
            when base.currency_iso_code = 'INR'
                then base.funds_received_by_non_profits / nullif(fx_rates.usd_inr, 0)
            when base.currency_iso_code = 'GBP'
                then base.funds_received_by_non_profits * fx_rates.gbp_inr / nullif(fx_rates.usd_inr, 0)
            else null
        end                                as amt_in_usd,
        case
            when base.currency_iso_code = 'INR'
                then base.funds_received_by_non_profits
            when base.currency_iso_code = 'USD'
                then base.funds_received_by_non_profits * fx_rates.usd_inr
            when base.currency_iso_code = 'GBP'
                then base.funds_received_by_non_profits * fx_rates.gbp_inr
            else null
        end                                as amt_in_inr,
        base.funding_route,
        base.description

    from base
    left join fx_rates
        on left(base.fy, 4) = fx_rates.year

)

select *
from final
