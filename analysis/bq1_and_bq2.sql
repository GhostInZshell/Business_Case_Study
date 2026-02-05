WITH property_metrics AS (
    SELECT
        mpd.property_id,
        ROUND(SUM(sites_occupied) / SUM(prop.sites_total) * 100, 1) as phys_occup_pct,
        ROUND(SUM(bad_debt) / SUM(rent_billed) * 100, 1) as bad_debt_rate_pct,
        ROUND(AVG(turn_days_avg), 1) as avg_turn_days,
        ROUND(SUM(operating_expense) / NULLIF(SUM(rent_collected), 0) * 100, 1) as opex_ratio_pct,
        ROUND((SUM(rent_collected - operating_expense - bad_debt)/SUM(rent_collected)) * 100, 1) as noi_margin_pct
    FROM monthly_portfolio_data mpd
    JOIN properties prop ON prop.property_id = mpd.property_id
    GROUP BY mpd.property_id
),
portfolio_averages AS (
    SELECT
        ROUND(AVG(phys_occup_pct), 1) as avg_phys_occup,
        ROUND(AVG(bad_debt_rate_pct), 1) as avg_bad_debt,
        ROUND(AVG(avg_turn_days), 1) as avg_turn_days,
        ROUND(AVG(opex_ratio_pct), 1) as avg_opex,
        ROUND(AVG(noi_margin_pct), 1) as avg_noi_margin
    FROM property_metrics
)
-- Individual properties with advantages
SELECT
    pm.property_id,
    pm.phys_occup_pct,
    ROUND(pm.phys_occup_pct - pa.avg_phys_occup, 1) as phys_occup_advantage,
    pm.bad_debt_rate_pct,
    ROUND(pm.bad_debt_rate_pct - pa.avg_bad_debt, 1) as bad_debt_advantage,
    pm.avg_turn_days,
    ROUND(pm.avg_turn_days - pa.avg_turn_days, 1) as turn_days_advantage,
    pm.opex_ratio_pct,
    ROUND(pm.opex_ratio_pct - pa.avg_opex, 1) as opex_advantage,
    pm.noi_margin_pct,
    ROUND(pm.noi_margin_pct - pa.avg_noi_margin, 1) as noi_margin_advantage
FROM property_metrics pm
CROSS JOIN portfolio_averages pa

UNION ALL

-- Portfolio average row (no advantages)
SELECT
    'Portfolio Avg' as property_id,
    avg_phys_occup as phys_occup_pct,
    NULL as phys_occup_advantage,
    avg_bad_debt as bad_debt_rate_pct,
    NULL as bad_debt_advantage,
    avg_turn_days,
    NULL as turn_days_advantage,
    avg_opex as opex_ratio_pct,
    NULL as opex_advantage,
    avg_noi_margin as noi_margin_pct,
    NULL as noi_margin_advantage
FROM portfolio_averages

ORDER BY property_id;