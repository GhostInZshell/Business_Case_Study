SELECT *
FROM (
SELECT
	mpd.property_id,
	ROUND((SUM(rent_collected - operating_expense - bad_debt)/SUM(rent_collected)) * 100, 1) as noi_margin_pct,
	ROUND(SUM(sites_occupied) / SUM(sites_total) * 100, 1) as phys_occup_pct,
	ROUND(SUM(bad_debt) / SUM(rent_billed) * 100, 1) as bad_debt_rate_pct
FROM monthly_portfolio_data mpd
JOIN properties prop ON prop.property_id = mpd.property_id
GROUP BY mpd.property_id
)
ORDER BY noi_margin_pct DESC
;

-- Get tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';

-- Get schema for monthly_portfolio_data
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'monthly_portfolio_data'
ORDER BY ordinal_position;

-- Get schema for properties
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'properties'
ORDER BY ordinal_position;

-- Segment/Region breakdown
SELECT 
    mpd.property_id,
    prop.property_name,
    prop.portfolio_segment,
    prop.region,
    prop.market,
    prop.acq_year,
    ROUND((SUM(rent_collected - operating_expense - bad_debt) / SUM(rent_collected)) * 100, 1) as noi_margin_pct,
    ROUND(SUM(sites_occupied) / SUM(prop.sites_total) * 100, 1) as phys_occup_pct
FROM monthly_portfolio_data mpd
JOIN properties prop ON prop.property_id = mpd.property_id
WHERE mpd.property_id IN ('P03', 'P06', 'P01', 'P04')
GROUP BY mpd.property_id, prop.property_name, prop.portfolio_segment, prop.region, prop.market, prop.acq_year
ORDER BY noi_margin_pct DESC;

-- Ops effeciency
SELECT 
    mpd.property_id,
    prop.property_name,
    ROUND(SUM(operating_expense) / NULLIF(SUM(rent_collected), 0) * 100, 1) as opex_ratio_pct,
    ROUND(SUM(capex) / SUM(prop.sites_total), 0) as capex_per_site,
    ROUND(AVG(turn_days_avg), 1) as avg_turn_days
FROM monthly_portfolio_data mpd
JOIN properties prop ON prop.property_id = mpd.property_id
WHERE mpd.property_id IN ('P03', 'P06', 'P01', 'P04')
GROUP BY mpd.property_id, prop.property_name
ORDER BY opex_ratio_pct ASC;

--  Collections strength
SELECT 
    mpd.property_id,
    prop.property_name,
    ROUND(SUM(rent_collected) / NULLIF(SUM(rent_billed), 0) * 100, 1) as economic_occupancy_pct,
    ROUND(SUM(bad_debt) / NULLIF(SUM(rent_billed), 0) * 100, 1) as bad_debt_rate_pct,
    ROUND(AVG(evictions / NULLIF(sites_occupied, 0)) * 100, 2) as avg_eviction_rate_pct
FROM monthly_portfolio_data mpd
JOIN properties prop ON prop.property_id = mpd.property_id
WHERE mpd.property_id IN ('P03', 'P06', 'P01', 'P04')
GROUP BY mpd.property_id, prop.property_name
ORDER BY economic_occupancy_pct DESC;


-- resident exp.
SELECT 
    mpd.property_id,
    prop.property_name,
    AVG(resident_satisfaction_score) as avg_satisfaction,
    AVG(work_order_days_avg) as avg_wo_close_days,
    ROUND(SUM(work_orders_closed) / NULLIF(SUM(work_orders_opened), 0) * 100, 1) as wo_closure_rate_pct,
    ROUND(SUM(complaints) / SUM(sites_occupied) * 100, 1) as complaint_rate_pct
FROM monthly_portfolio_data mpd
JOIN properties prop ON prop.property_id = mpd.property_id
WHERE mpd.property_id IN ('P03', 'P06', 'P01', 'P04')
GROUP BY mpd.property_id, prop.property_name
ORDER BY avg_satisfaction DESC;

-- marketing effeciency
SELECT 
    mpd.property_id,
    prop.property_name,
    SUM(leads) as total_leads,
    SUM(applications) as total_applications,
    SUM(move_ins) as total_move_ins,
    ROUND(SUM(applications) / NULLIF(SUM(leads), 0) * 100, 1) as lead_to_app_pct,
    ROUND(SUM(move_ins) / NULLIF(SUM(applications), 0) * 100, 1) as app_to_move_in_pct,
    ROUND(SUM(marketing_spend) / NULLIF(SUM(leads), 0), 0) as cost_per_lead
FROM monthly_portfolio_data mpd
JOIN properties prop ON prop.property_id = mpd.property_id
WHERE mpd.property_id IN ('P03', 'P06', 'P01', 'P04')
GROUP BY mpd.property_id, prop.property_name
ORDER BY lead_to_app_pct DESC;