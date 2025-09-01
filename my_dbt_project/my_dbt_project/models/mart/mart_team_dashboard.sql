-- models/mart/mart_team_dashboard.sql
{{ config(
    materialized='table'
) }}


with team_stats as (
    select
        p.club_team_id,
        count(p.player_id) as total_players,
        round(avg(p.overall), 2) as avg_overall,
        round(avg(p.value_eur), 0) as avg_value_eur
    from int_male_players p
    group by p.club_team_id
),
key_players as (
    select
        p.club_team_id,
        p.player_id,
        p.long_name,
        p.overall,
        p.value_eur,
        case 
            when p.overall > t.avg_overall then true
            else false
        end as exceeds_expectation
    from int_male_players p
    join team_stats t
        on p.club_team_id = t.club_team_id
)
select
    t.club_team_id,
    t.total_players,
    t.avg_overall,
    t.avg_value_eur,
    k.player_id,
    k.long_name,
    k.overall,
    k.value_eur,
    k.exceeds_expectation
from team_stats t
left join key_players k
    on t.club_team_id = k.club_team_id
order by t.club_team_id, k.overall desc
