-- the concerpt is to unoin first and second player and scores because the match was between 2 players of the same group
-- for each group, there can only be 1 winner, so easier approach to convery everything to records
-- t- union all plaers and scores
-- cte- get group of each player, find sum of scores for each player, and assign rank for each group(partition) according to highest score and lower player_id in case of tie(order by)
-- final query- pull the players with rank = 1 from cte

with cte as
(select group_id, first_player, sum(first_score) as total_score,
    dense_rank() over(partition by group_id order by sum(first_score) desc, player_id asc) as rnk
from
    (
    select m.first_player, m.first_score
    from Matches m
    union all 
    select m.second_player, m.second_score
    from Matches m
    ) t
join Players p
on p.player_id = t.first_player
group by 2)

select group_id, first_player as player_id
from cte
where rnk = 1

-- wayfair- 1


#####################################################################################


WITH
    s AS (
        SELECT first_player AS player_id, first_score AS score, group_id
        FROM
            Matches AS m
            JOIN Players AS p ON m.first_player = p.player_id
        UNION ALL
        SELECT second_player AS player_id, second_score AS score, group_id
        FROM
            Matches AS m
            JOIN Players AS p ON m.second_player = p.player_id
    ),
    t AS (
        SELECT group_id, player_id, SUM(score) AS scores
        FROM s
        GROUP BY player_id
    ),
    p AS (
        SELECT
            group_id,
            player_id,
            RANK() OVER (
                PARTITION BY group_id
                ORDER BY scores DESC, player_id
            ) AS rk
        FROM t
    )
SELECT group_id, player_id
FROM p
WHERE rk = 1;
