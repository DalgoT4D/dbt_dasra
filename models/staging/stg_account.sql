with source as (

    select *
    from {{ source('salesforce_raw_data', 'Account') }}

),

cleaned as (

    select
        -- identifiers
        cast("Id" as varchar)                    as id,
        nullif(trim("Name"), '')                 as account_name,
        nullif(trim("Type"), '')                 as account_type,
        nullif(trim("Area__c"), '')              as area,
        nullif(trim("City__c"), '')              as city,
        nullif(trim("OwnerId"), '')              as owner_id,
        nullif(trim("Industry"), '')             as industry,

        -- flags
        cast("IsDeleted" as boolean)             as is_deleted,
        cast("COP_Alliance__c" as boolean)       as cop_alliance,
        cast("CRA_Alliance__c" as boolean)       as cra_alliance,
        cast("Dalgo_verified__c" as boolean)     as dalgo_verified,
        cast("NFSSM_Alliance__c" as boolean)     as nfssm_alliance,

        -- record type
        nullif(trim("RecordTypeId"), '')         as record_type_id,

        -- user + audit fields
        nullif(trim("CreatedById"), '')          as created_by_id,
        cast("CreatedDate" as timestamptz)       as created_at,
        nullif(trim("LastModifiedById"), '')     as last_modified_by_id,
        cast("LastModifiedDate" as timestamptz)  as last_modified_at,
        cast("LastActivityDate" as date)         as last_activity_date,
        cast("SystemModstamp" as timestamptz)    as system_modstamp,
        cast("LastViewedDate" as timestamptz)    as last_viewed_at,
        cast("LastReferencedDate" as timestamptz) as last_referenced_at,

        -- descriptive attributes
        nullif(trim("CurrencyIsoCode"), '')      as currency_iso_code

    from source

),

-- deduplication logic to ensure we only have one record per Account
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
    account_name,
    account_type,
    area,
    city,
    owner_id,
    industry,
    is_deleted,
    cop_alliance,
    cra_alliance,
    dalgo_verified,
    nfssm_alliance,
    record_type_id,
    created_by_id,
    created_at,
    last_modified_by_id,
    last_modified_at,
    last_activity_date,
    system_modstamp,
    last_viewed_at,
    last_referenced_at,
    currency_iso_code
from deduplicated
where is_deleted = false
