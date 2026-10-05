{{ config(
    unique_key = 'ticket_id',
    incremental_strategy = 'delete+insert'
) }}

with src as (
    select
        *,
        coalesce(changedDate, paidDate, exitedDate, enteredDate) as _updated_at
    from {{ source('bronze', 'ticket') }}
    where id is not null
    {% if is_incremental() %}
      and coalesce(changedDate, paidDate, exitedDate, enteredDate)
          > (select max(updated_at) - interval 1 day from {{ this }})
    {% endif %}
),

dedup as (
    select *,
           row_number() over (partition by id order by _updated_at desc) as rn
    from src
)

select
    -- keys / dimensions
    id                                              as ticket_id,
    trim(parkCode)                                  as park_code,
    trim(parkName)                                  as park_name,
    trim(areaCode)                                  as area_code,
    trim(areaName)                                  as area_name,
    upper(replace(numberPlate, ' ', ''))            as number_plate,
    upper(replace(coalesce(changedPlate, numberPlate), ' ', '')) as final_plate,
    changedPlate is not null                        as is_plate_changed,
    coalesce(vehicleTypeCode, 'UNKNOWN')            as vehicle_type_code,
    coalesce(vehicleTypeName, 'Тодорхойгүй')        as vehicle_type_name,
    category,
    cashier,
    discountName                                    as discount_name,
    customerNames                                   as customer_names,
    contractNumbers is not null                     as has_contract,

    -- timestamps
    arrivedDate                                     as arrived_at,
    enteredDate                                     as entered_at,
    exitedDate                                      as exited_at,
    paidDate                                        as paid_at,
    cast(enteredDate as date)                       as entered_date,
    hour(enteredDate)                               as entered_hour,

    -- measures
    coalesce(parkedMinute, date_diff('minute', enteredDate, exitedDate)) as parked_minutes,
    coalesce(estimatedAmount, 0)                    as estimated_amount,
    coalesce(discountAmount, 0)                     as discount_amount,
    coalesce(paidAmount, 0)                         as paid_amount,
    coalesce(overPaid, 0)                           as over_paid,
    coalesce(parkingFee, 0)                         as parking_fee,
    coalesce(kioskFee, 0)                           as kiosk_fee,

    -- flags / status
    lower(coalesce(freeExited, 'false')) in ('true', '1', 'yes') as is_free_exit,
    case
        when exitedDate is null                         then 'IN_PARKING'
        when coalesce(paidAmount, 0) > 0                then 'PAID'
        when lower(coalesce(freeExited, 'false')) in ('true', '1', 'yes') then 'FREE_EXIT'
        else 'UNPAID_EXIT'
    end                                             as ticket_status,

    _updated_at                                     as updated_at,
    current_timestamp                               as dbt_loaded_at
from dedup
where rn = 1
