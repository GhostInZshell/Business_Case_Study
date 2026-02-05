WITH p04_current AS (
    SELECT
        SUM(rent_collected) as current_revenue,
        SUM(operating_expense) as current_opex,
        SUM(bad_debt) as current_bad_debt,
        SUM(rent_collected - operating_expense - bad_debt) as current_noi,
        ROUND(SUM(bad_debt) / SUM(rent_billed) * 100, 1) as bad_debt_rate_pct,
        ROUND(SUM(operating_expense) / SUM(rent_collected) * 100, 1) as opex_ratio_pct,
        ROUND((SUM(rent_collected - operating_expense - bad_debt) / SUM(rent_collected)) * 100, 1) as noi_margin_pct
    FROM monthly_portfolio_data mpd
    WHERE mpd.property_id = 'P04'
),
portfolio_benchmarks AS (
    SELECT
        ROUND(AVG(bad_debt_rate), 1) as portfolio_avg_bad_debt,
        ROUND(AVG(opex_ratio), 1) as portfolio_avg_opex,
        ROUND(AVG(noi_margin), 1) as portfolio_avg_noi_margin
    FROM (
        SELECT
            mpd.property_id,
            SUM(bad_debt) / SUM(rent_billed) * 100 as bad_debt_rate,
            SUM(operating_expense) / SUM(rent_collected) * 100 as opex_ratio,
            (SUM(rent_collected - operating_expense - bad_debt) / SUM(rent_collected)) * 100 as noi_margin
        FROM monthly_portfolio_data mpd
        GROUP BY mpd.property_id
    ) prop_metrics
)
SELECT
    -- Current state (3-month actuals)
    current_revenue / 3 as monthly_revenue,
    current_revenue / 3 * 12 as annual_revenue,
    current_noi / 3 as monthly_noi,
    current_noi / 3 * 12 as annual_noi_current,
    bad_debt_rate_pct as p04_bad_debt_rate,
    opex_ratio_pct as p04_opex_ratio,
    noi_margin_pct as p04_noi_margin,
    
    -- Portfolio benchmarks
    portfolio_avg_bad_debt,
    portfolio_avg_opex,
    portfolio_avg_noi_margin,
    
    -- Potential state (if P04 hits portfolio avg performance)
    (current_revenue / 3 * 12) * (portfolio_avg_noi_margin / 100) as annual_noi_potential,
    
    -- Upside
    ((current_revenue / 3 * 12) * (portfolio_avg_noi_margin / 100)) - (current_noi / 3 * 12) as annual_noi_upside,
    
    -- Monthly impact
    (((current_revenue / 3 * 12) * (portfolio_avg_noi_margin / 100)) - (current_noi / 3 * 12)) / 12 as monthly_noi_upside
    
FROM p04_current, portfolio_benchmarks;