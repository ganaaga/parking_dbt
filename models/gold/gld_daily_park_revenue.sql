-- Daily KPIs per park
select
    entered_date,
    park_code,
    park_name,
    count(*)                                              as total_tickets,
    count(distinct final_plate)                           as unique_vehicles,
    count_if(ticket_status = 'IN_PARKING')                as still_parked,
    count_if(ticket_status = 'PAID')                      as paid_tickets,
    count_if(ticket_status = 'FREE_EXIT')                 as free_exits,
    count_if(ticket_status = 'UNPAID_EXIT')               as unpaid_exits,
    sum(estimated_amount)                                 as estimated_amount,
    sum(discount_amount)                                  as discount_amount,
    sum(paid_amount)                                      as paid_amount,
    sum(estimated_amount - discount_amount - paid_amount) filter (where ticket_status = 'UNPAID_EXIT')
                                                          as unpaid_amount,
    round(avg(parked_minutes), 1)                         as avg_parked_minutes
from {{ ref('slv_ticket') }}
where entered_date is not null
group by 1, 2, 3
