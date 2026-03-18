with base as (

    select *
    from {{ ref('int_impact_dashboard_enriched') }}
    where impact_header = 'A. PHILANTHROPIC IMPACT'

),

fx_rates as (

    select *
    from {{ ref('stg_fx_rates') }}

),

final as (

    select
        base.record_sl_no          as sr_no,
        base.record_date           as date,
        base.fy,
        base.quarter,
        base.program_name,
        base.impact_header,
        base.impact_type_header,
        base.funder_name           as funder_org_name,
        base.funder_region         as region,
        base.women_funder,
        base.funding_given,
        base.funding_amount,
        base.currency_iso_code     as currency,
        case
            when base.currency_iso_code = 'USD'
                then base.funding_amount
            when base.currency_iso_code = 'INR'
                then base.funding_amount / nullif(fx_rates.usd_inr, 0)
            when base.currency_iso_code = 'GBP'
                then base.funding_amount * fx_rates.gbp_inr / nullif(fx_rates.usd_inr, 0)
            else null
        end                        as amt_in_usd,
        case
            when base.currency_iso_code = 'INR'
                then base.funding_amount
            when base.currency_iso_code = 'USD'
                then base.funding_amount * fx_rates.usd_inr
            when base.currency_iso_code = 'GBP'
                then base.funding_amount * fx_rates.gbp_inr
            else null
        end                        as amt_in_inr,
        base.funding_route,
        base.description

    from base
    left join fx_rates
        on left(base.fy, 4) = fx_rates.year

)

select *
from final
