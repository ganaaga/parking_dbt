# parking_dbt — bronze → silver → gold demo (dbt-duckdb)

    bronze.ticket ──► silver.slv_ticket (incremental delete+insert, dedup, clean)
                         ├─► gold.gld_daily_park_revenue
                         ├─► gold.gld_hourly_traffic
                         └─► gold.gld_vehicle_type_monthly

## Run
    pip install -r requirements.txt   # dbt-core 1.11 + dbt-duckdb
    cp profiles.yml.example profiles.yml          # set path to your .duckdb file
    dbt debug --profiles-dir .
    dbt build --profiles-dir .                      # run + test
    dbt build --profiles-dir . --full-refresh       # rebuild silver from scratch
    dbt docs generate --profiles-dir . && dbt docs serve   # lineage graph for the demo
