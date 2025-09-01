-- tests/test_wage_vs_value.sql
select *
from {{ ref('int_male_players') }}
where wage_eur > value_eur