-- models/intermediate/int_team_profiles_male.sql
{{ config(
    materialized='table'
) }}

with league_players as (
    select
        league_id,
        league_name,
        overall,
        age,
        potential
    from {{ ref('int_male_players') }}
),
league_aggregates as (
    select
        league_id,
        max(league_name) as league_name,
        avg(overall)::numeric(5,2) as league_avg_overall,
        bool_or(age <= 23 and potential > 85) as has_young_talent
    from league_players
    group by league_id
)
select
    league_id,
    league_name,
    league_avg_overall,
    has_young_talent
from league_aggregates
order by league_avg_overall desc
