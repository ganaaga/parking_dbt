-- Entries vs exits per park per hour (occupancy pattern)
with events as (
    select park_code, park_name, date_trunc('hour', entered_at) as event_hour, 1 as entries, 0 as exits
    from {{ ref('slv_ticket') }} where entered_at is not null
    union all
    select park_code, park_name, date_trunc('hour', exited_at), 0, 1
    from {{ ref('slv_ticket') }} where exited_at is not null
)
select
    cast(event_hour as date)  as event_date,
    hour(event_hour)          as event_hour,
    park_code,
    park_name,
    sum(entries)              as entries,
    sum(exits)                as exits,
    sum(entries) - sum(exits) as net_flow
from events
group by 1, 2, 3, 4
