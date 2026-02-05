SELECT
    mpd.property_id,
    ROUND(SUM(sites_occupied) / SUM(prop.sites_total) * 100, 1) as phys_occup_pct,
    ROUND(SUM(rent_collected) / SUM(rent_billed) * 100, 1) as economic_occup_pct,
    ROUND(SUM(sites_occupied) / SUM(prop.sites_total) * 100, 1) - ROUND(SUM(rent_collected) / SUM(rent_billed) * 100, 1) as occupancy_gap
FROM monthly_portfolio_data mpd
JOIN properties prop ON prop.property_id = mpd.property_id
GROUP BY mpd.property_id

UNION ALL

SELECT
    'Portfolio Avg' as property_id,
    ROUND(SUM(sites_occupied) / SUM(prop.sites_total) * 100, 1),
    ROUND(SUM(rent_collected) / SUM(rent_billed) * 100, 1),
    ROUND(SUM(sites_occupied) / SUM(prop.sites_total) * 100, 1) - ROUND(SUM(rent_collected) / SUM(rent_billed) * 100, 1)
FROM monthly_portfolio_data mpd
JOIN properties prop ON prop.property_id = mpd.property_id
ORDER BY 1
;