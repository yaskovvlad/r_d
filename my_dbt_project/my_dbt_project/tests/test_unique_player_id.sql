-- tests/test_unique_player_id.sql
select player_id, count(*) as cnt
from (
    select player_id from {{ ref('int_male_players') }}
    union all
    select player_id from {{ ref('int_female_players') }}
) all_players
group by player_id
having count(*) > 1
