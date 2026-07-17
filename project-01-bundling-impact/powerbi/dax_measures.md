# Power BI Dashboard — KPI / DAX Reference

**Data source:** `vw_monthly_performance` and `vw_period_growth` (SQL views, see `../sql/01_schema_and_etl.sql`) imported via Power BI's SQL Server connector, refreshed nightly.

## Dashboard pages
1. **Executive Summary** — KPI cards (revenue, profit, margin, growth %) + before/after bar chart.
2. **Trend** — daily revenue/profit line chart with a shaded band marking the promo period, so viewers can see the shift at a glance.
3. **Product Mix** — margin comparison across Fizzi (individual), 8pc Chicken (individual), and the Bundle.
4. **Drill-through: Daily Detail** — table view for auditing any single day back to the source.

## Core DAX measures

```DAX
Total Revenue =
SUM ( fact_sales[revenue] )

Total Profit =
SUM ( fact_sales[profit] )

Gross Margin % =
DIVIDE ( [Total Profit], [Total Revenue], 0 )

Units Sold =
SUM ( fact_sales[quantity_sold] )

-- Revenue for the prior comparison period, driven by a disconnected
-- "Period Pair" table so the same visual can flip between
-- Jan-vs-Dec and Jun-vs-Jul without duplicating measures.
Revenue (Before Period) =
CALCULATE (
    [Total Revenue],
    dim_date[period_label] = SELECTEDVALUE ( period_pairs[before_label] )
)

Revenue (After Period) =
CALCULATE (
    [Total Revenue],
    dim_date[period_label] = SELECTEDVALUE ( period_pairs[after_label] )
)

Revenue Growth % =
DIVIDE (
    [Revenue (After Period)] - [Revenue (Before Period)],
    [Revenue (Before Period)],
    BLANK ()
)

Profit Growth % =
DIVIDE (
    CALCULATE ( [Total Profit], dim_date[period_label] = SELECTEDVALUE ( period_pairs[after_label] ) )
        - CALCULATE ( [Total Profit], dim_date[period_label] = SELECTEDVALUE ( period_pairs[before_label] ) ),
    CALCULATE ( [Total Profit], dim_date[period_label] = SELECTEDVALUE ( period_pairs[before_label] ) ),
    BLANK ()
)

Cost-Benefit Ratio =
DIVIDE ( [Total Profit], SUM ( fact_sales[cost] ), 0 )

-- Alert measure: flags on the KPI card if margin has drifted below target
Margin Status =
VAR MarginTarget = 0.50
RETURN
    IF ( [Gross Margin %] < MarginTarget, "⚠ Below target", "✅ On target" )
```

## KPI targets used on the dashboard
| KPI | Target | Rationale |
|---|---|---|
| Bundle gross margin | ≥ 50% | Keeps a healthy buffer below the observed 55.5% actual |
| Revenue growth vs. control period | > 0% | Any positive lift signals the promo is working |
| Cost-benefit ratio | ≥ 1.0 | Every $1 spent should return at least $1 profit |

## Why this matters for business monitoring
Instead of re-running a one-off Python/Excel analysis every time management wants to know "is the bundle still working?", this dashboard refreshes automatically from the same validated SQL layer used in the original analysis — so the KPI definitions are consistent between the initial research and ongoing monitoring.
