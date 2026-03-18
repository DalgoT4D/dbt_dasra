with impact as (

    select *
    from {{ ref('stg_impact_dashboard_data_form__c') }}

),

entity_account as (

    select *
    from {{ ref('stg_account') }}

),

funder_account as (

    select *
    from {{ ref('stg_account') }}

),

non_profit_account as (

    select *
    from {{ ref('stg_account') }}

),

platform as (

    select *
    from {{ ref('stg_platform_name__c') }}

),

policy as (

    select *
    from {{ ref('stg_policy_name__c') }}

),

joined as (

    select
        -- impact record identifiers
        impact.id,
        impact.record_sl_no,
        impact.fy,
        impact.quarter,
        impact.record_date,
        impact.owner_id,

        -- impact classification
        impact.impact_header,
        impact.impact_type_header,
        impact.impact_sub_type_header,
        impact.description,
        impact.program_name,

        -- entity (organization receiving impact)
        impact.entity_name_acc_id,
        entity_account.account_name    as entity_name,
        entity_account.account_type    as entity_type,
        entity_account.area            as entity_area,
        entity_account.city            as entity_city,
        entity_account.industry        as entity_industry,
        entity_account.cop_alliance    as entity_cop_alliance,
        entity_account.cra_alliance    as entity_cra_alliance,
        entity_account.dalgo_verified  as entity_dalgo_verified,
        entity_account.nfssm_alliance  as entity_nfssm_alliance,

        -- funder
        impact.funder_name_acc_id,
        funder_account.account_name    as funder_name,
        funder_account.account_type    as funder_type,
        funder_account.area            as funder_area,
        funder_account.city            as funder_city,

        -- platform
        impact.platform_name_obj_id,
        platform.platform_name,

        -- policy
        impact.policy_name_obj_id,
        policy.policy_name,

        -- funding dimensions
        impact.women_funder,
        impact.women_leader,
        impact.dba_leader,
        impact.funder_region,
        impact.funding_route,
        impact.funding_given,
        impact.funding_received,
        impact.non_profit_supported          as non_profit_supported_acc_id,
        non_profit_account.account_name      as non_profit_supported_name,
        impact.currency_iso_code,

        -- numeric financials
        impact.funding_amount,
        impact.budgetary_allocation,
        impact.funds_received_by_non_profits,
        impact.reach,

        -- audit fields
        impact.created_by_id,
        impact.created_at,
        impact.last_modified_by_id,
        impact.last_modified_at,
        impact.last_activity_date,
        impact.system_modstamp,
        impact.last_viewed_at,
        impact.last_referenced_at

    from impact
    left join entity_account
        on impact.entity_name_acc_id = entity_account.id
    left join funder_account
        on impact.funder_name_acc_id = funder_account.id
    left join platform
        on impact.platform_name_obj_id = platform.id
    left join policy
        on impact.policy_name_obj_id = policy.id
    left join non_profit_account
        on impact.non_profit_supported = non_profit_account.id

)

select *
from joined
