-- models/intermediate/int_team_profiles_male.sql
{{ config(
    materialized='table'
) }}



with base as (
    select
        club_team_id,
        club_name,
        count(*) as total_players,
        avg(overall)::numeric(5,2) as avg_overall,
        sum(coalesce(value_eur,0))::bigint as total_value_eur
    from {{ ref('int_male_players') }}
    where club_team_id is not null
    group by club_team_id, club_name
)
select *
from base