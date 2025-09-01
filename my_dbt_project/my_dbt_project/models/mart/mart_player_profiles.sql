-- models/mart/mart_player_profiles.sql
{{ config(
    materialized='table'
) }}

with players as (
    select * from {{ ref('int_male_players') }}
    union all
    select * from {{ ref('int_female_players') }}
),
players_classified as (
    select
        player_id,
        long_name,
        gender,
        overall,
        potential,
        age,
        player_positions,
        case
            when age <= 21 then 'U21'
            when age between 22 and 28 then 'Prime'
            else 'Veteran'
        end as age_group,
        case
            when player_positions ilike '%GK%' then 'Goalkeeper'
            when player_positions ilike any (array['%CB%','%LB%','%RB%','%LWB%','%RWB%']) then 'Defender'
            when player_positions ilike any (array['%CDM%','%CM%','%CAM%','%RM%','%LM%']) then 'Midfielder'
            when player_positions ilike any (array['%RW%','%LW%']) then 'Winger'
            when player_positions ilike any (array['%ST%','%CF%']) then 'Forward'
            else 'Other'
        end as player_role
    from players
)
select * from players_classified
