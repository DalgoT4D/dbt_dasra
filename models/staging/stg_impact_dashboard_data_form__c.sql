with source as (

    select *
    from {{ source('salesforce_raw_data', 'Impact_Dashboard_Data_Form__c') }}

),

cleaned as (

    select
        -- identifiers
        cast("Id" as varchar)                                      as id,
        nullif(trim("Name"), '')                                   as record_sl_no,
        nullif(trim("FY__c"), '')                                  as fy,
        nullif(trim("OwnerId"), '')                                as owner_id,
        nullif(trim("Impact__c"), '')                              as impact_header,
        nullif(trim("Type__c"), '')                                as impact_type_header,
        nullif(trim("Sub_Type__c"), '')                            as impact_sub_type_header,

        -- flags
        cast("IsDeleted" as boolean)                               as is_deleted,

        -- record date dimensions
        nullif(trim("Quarter__c"), '')                             as quarter,
        cast("Record_Date__c" as date)                             as record_date,
        

        -- user + audit fields
        nullif(trim("CreatedById"), '')                              as created_by_id,
        cast("CreatedDate" as timestamptz)                           as created_at,
        nullif(trim("LastModifiedById"), '')                         as last_modified_by_id,
        cast("LastModifiedDate" as timestamptz)                      as last_modified_at,
        cast("LastActivityDate" as date)                             as last_activity_date,
        cast("SystemModstamp" as timestamptz)                        as system_modstamp,
        cast("LastViewedDate" as timestamptz)                        as last_viewed_at,
        cast("LastReferencedDate" as timestamptz)                    as last_referenced_at,

        -- descriptive attributes
        
        nullif(trim("DBA_Leader__c"), '')                          as dba_leader,
        nullif(trim("Description__c"), '')                         as description,
        nullif(trim("Entity_Name__c"), '')                         as entity_name_acc_id,
        nullif(trim("Funder_Name__c"), '')                         as funder_name_acc_id,
        nullif(trim("Policy_Name__c"), '')                         as policy_name_obj_id,
        nullif(trim("CurrencyIsoCode"), '')                        as currency_iso_code,
        nullif(trim("Program_Name__c"), '')                        as program_name,
        nullif(trim("Women_Funder__c"), '')                        as women_funder,
        nullif(trim("Women_Leader__c"), '')                        as women_leader,
        nullif(trim("Funder_Region__c"), '')                       as funder_region,
        nullif(trim("Funding_Given__c"), '')                       as funding_given,
        nullif(trim("Funding_Route__c"), '')                       as funding_route,
        nullif(trim("Platform_Name__c"), '')                       as platform_name_obj_id,
        nullif(trim("Funding_Received__c"), '')                    as funding_received,
        nullif(trim("Non_Profit_Supported__c"), '')                as non_profit_supported,

        -- numeric financials
        cast("Funding_Amount__c" as numeric(38, 9))                as funding_amount,
        cast("Budgetary_Allocation__c" as numeric(38, 9))          as budgetary_allocation,
        cast("Funds_Received_by_Non_Profits__c" as numeric(38, 9)) as funds_received_by_non_profits,
        cast("Reach__c" as integer)                         as reach

    from source

),

-- deduplication logic to ensure we only have one record per impact dashboard data form submission
deduplicated as (

    select
        *
    from (
        select
            *,
            row_number() over (
                partition by id
                order by system_modstamp desc, last_modified_at desc, created_at desc
            ) as _row_num
        from cleaned
    ) ranked
    where _row_num = 1

)

select
    id,
    record_sl_no,
    fy,
    owner_id,
    impact_header,
    impact_type_header,
    impact_sub_type_header,
    is_deleted,
    quarter,
    record_date,
    created_by_id,
    created_at,
    last_modified_by_id,
    last_modified_at,
    last_activity_date,
    system_modstamp,
    last_viewed_at,
    last_referenced_at,
    dba_leader,
    description,
    entity_name_acc_id,
    funder_name_acc_id,
    policy_name_obj_id,
    currency_iso_code,
    program_name,
    women_funder,
    women_leader,
    funder_region,
    funding_given,
    funding_route,
    platform_name_obj_id,
    funding_received,
    non_profit_supported,
    funding_amount,
    budgetary_allocation,
    funds_received_by_non_profits,
    reach
from deduplicated
where is_deleted = false
