-- Player summary
DROP VIEW IF EXISTS player_summary;
CREATE VIEW player_summary AS
SELECT
    player_id,
    COUNT(*) AS total_matches,
    AVG(win) AS win_rate
FROM matches
GROUP BY player_id;

-- Early behaviour
DROP VIEW IF EXISTS early_behaviour;
CREATE VIEW early_behaviour AS
SELECT
    m.player_id,
    COUNT(*) AS early_matches,
    AVG(m.win) AS early_win_rate
FROM matches m
JOIN players p ON m.player_id = p.player_id
WHERE m.match_date <= datetime(p.signup_date, '+3 days')
GROUP BY m.player_id;

-- Churn
DROP VIEW IF EXISTS churn_labels;
CREATE VIEW churn_labels AS
SELECT
    player_id,
    CASE 
        WHEN MAX(match_date) < datetime((SELECT MAX(match_date) FROM matches), '-7 days')
        THEN 1 ELSE 0
    END AS churn
FROM matches
GROUP BY player_id;

-- Final dataset
DROP VIEW IF EXISTS player_features;
SELECT
    ps.player_id,
    ps.total_matches,
    ps.win_rate,
    COALESCE(eb.early_matches, 0) AS early_matches,
    COALESCE(eb.early_win_rate, 0) AS early_win_rate,
    c.churn
FROM player_summary ps
LEFT JOIN early_behaviour eb ON ps.player_id = eb.player_id
LEFT JOIN churn_labels c ON ps.player_id = c.player_id;