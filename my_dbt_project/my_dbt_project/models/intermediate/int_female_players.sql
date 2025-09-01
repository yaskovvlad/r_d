-- models/staging/int_female_players.sql
{{ config(
    materialized='table'
) }}


with base as (
    select
        player_id,
        player_url,
        fifa_version,
        fifa_update,
        fifa_update_date,
        short_name,
        long_name,
        player_positions,
        overall,
        potential,
        NULL::numeric as value_eur,
        NULL::numeric as wage_eur,
        age,
        dob,
        height_cm,
        weight_kg,
        NULL::int as league_id,
        NULL::text as league_name,
        NULL::int as league_level,
        NULL::int as club_team_id,
        NULL::text as club_name,
        NULL::text as club_position,
        NULL::int as club_jersey_number,
        NULL::text as club_loaned_from,
        NULL::date as club_joined_date,
        NULL::int as club_contract_valid_until_year,
        nationality_id,
        nationality_name,
        NULL::int as nation_team_id,
        nation_position,
        nation_jersey_number,
        preferred_foot,
        weak_foot,
        skill_moves,
        international_reputation,
        work_rate,
        body_type,
        real_face,
        NULL::numeric as release_clause_eur,
        player_tags,
        player_traits,
        pace,
        shooting,
        passing,
        dribbling,
        defending,
        physic,
        attacking_crossing,
        attacking_finishing,
        attacking_heading_accuracy,
        attacking_short_passing,
        attacking_volleys,
        skill_dribbling,
        skill_curve,
        skill_fk_accuracy,
        skill_long_passing,
        skill_ball_control,
        movement_acceleration,
        movement_sprint_speed,
        movement_agility,
        movement_reactions,
        movement_balance,
        power_shot_power,
        power_jumping,
        power_stamina,
        power_strength,
        power_long_shots,
        mentality_aggression,
        mentality_interceptions,
        mentality_positioning,
        mentality_vision,
        mentality_penalties,
        mentality_composure,
        defending_marking_awareness,
        defending_standing_tackle,
        defending_sliding_tackle,
        goalkeeping_diving,
        goalkeeping_handling,
        goalkeeping_kicking,
        goalkeeping_positioning,
        goalkeeping_reflexes,
        goalkeeping_speed,
        ls, st, rs, lw, lf, cf, rf, rw,
        lam, cam, ram, lm, lcm, cm, rcm, rm,
        lwb, ldm, cdm, rdm, rwb, lb, lcb, cb, rcb, rb, gk,
        player_face_url,
        'female'::text as gender
    from {{ ref('stg_female_players') }}
),
deduped as (
    select *
    from (
        select 
            *,
            row_number() over (partition by player_id order by fifa_update desc) as rn
        from base
    ) t
    where rn = 1
)

select * from deduped