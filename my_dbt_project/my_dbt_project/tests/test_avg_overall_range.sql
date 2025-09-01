-- tests/test_avg_overall_range.sql
select *
from {{ ref('mart_team_dashboard') }}
where avg_overall < 40 or avg_overall > 100