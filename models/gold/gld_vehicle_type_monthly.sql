-- Monthly revenue & usage by vehicle type
select
    date_trunc('month', entered_date)    as month,
    vehicle_type_code,
    vehicle_type_name,
    count(*)                             as total_tickets,
    count(distinct final_plate)          as unique_vehicles,
    sum(paid_amount)                     as paid_amount,
    sum(discount_amount)                 as discount_amount,
    round(avg(parked_minutes), 1)        as avg_parked_minutes,
    quantile_cont(parked_minutes, 0.5) as median_parked_minutes
from {{ ref('slv_ticket') }}
where entered_date is not null
group by 1, 2, 3
