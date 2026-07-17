# Project 01 — Bundling Strategy: Impact & Causal Analysis

**TL;DR for recruiters:** Compiled and validated 12+ months of raw POS export data, built a centralized SQL reporting layer, ran a Python cost/margin and Difference-in-Differences analysis, and designed a Power BI KPI dashboard to prove that a promotional bundle (8-piece chicken + 2L Fizzi) drove a **306% combined revenue lift** while holding a **55.5% gross margin** — then translated that into a go/no-go recommendation for management.

## 1. Business problem
Chicken Inn Gwanda wanted to know whether bundling a chicken meal with a 2-litre soft drink was actually growing the business, or just shifting customers from buying the two items separately (cannibalization) at a lower combined margin. Management needed:
- A trustworthy, single source of truth for daily sales (previously scattered across manual Excel logs).
- Quantified before/after impact on **revenue, profit, and margin**.
- A repeatable dashboard so this could be monitored for future promotions, not just analyzed once.

## 2. Data
| Source | Description |
|---|---|
| `BEFORE_AND_AFTER_BUNDLING_NOTHANDO.xlsx` | Daily sales logs — individual item sales (Fizzi, 8pc Chicken) vs. bundled sales, with quantity, unit price, unit cost per day |
| `clean_data.xlsx` / `Data.xlsx` | Cleaned/staged extracts used for modelling |
| `DID.xlsx` | Panel data structured for Difference-in-Differences testing |
| Survey data (`QUESTIONNAIRE.xlsx`, `respondents.xlsx`) | Feeds Project 02 (loyalty) |

Two comparison windows were used to control for seasonality:
- **Jan 2024 (no bundle)** vs. **Dec 2023 (bundle active)**
- **Jun 2024 (no bundle)** vs. **Jul 2024 (bundle active)**

## 3. Methodology (pipeline)
1. **Compile & validate (Excel)** — consolidated multiple daily sheets into one structured table; flagged and corrected missing/blank rows, non-numeric price cells, and mismatched date formats using Excel data validation before anything touched SQL or Python.
2. **Centralize (SQL)** — designed a small star schema (`fact_sales`, `dim_date`, `dim_product`) with `NOT NULL` / `CHECK` constraints so bad data can't silently enter the reporting layer again. See [`sql/01_schema_and_etl.sql`](./sql/01_schema_and_etl.sql).
3. **Analyze (Python / pandas)** — computed daily and monthly revenue, cost, profit and margin per product line; see [`notebooks/Cost_Analysis.ipynb`](./notebooks/Cost_Analysis.ipynb) and [`notebooks/Untitled.ipynb`](./notebooks/Untitled.ipynb).
4. **Test causality (Difference-in-Differences)** — used `DID.xlsx` to separate the *bundle effect* from underlying trend/seasonality rather than assuming raw before/after growth was 100% attributable to the promotion.
5. **Visualize & monitor (Power BI)** — turned the SQL views into a KPI dashboard with revenue growth %, margin %, and units-sold trend cards. See [`powerbi/dax_measures.md`](./powerbi/dax_measures.md).

## 4. Key results

| Metric | Jan 2024 (before) | Dec 2023 (after) | Jun 2024 (before) | Jul 2024 (after) |
|---|---|---|---|---|
| Units sold | 125 | 968 | 408 | 836 |
| Revenue | $987.00 | $13,552.00 | $5,227.00 | $11,704.00 |
| Profit | $575.80 | $7,521.36 | $3,000.63 | $6,495.72 |
| Revenue growth | — | **+1,273.0%** | — | **+123.9%** |
| Profit growth | — | **+1,206.2%** | — | **+116.5%** |

**Combined revenue growth across both test windows: +306.4%**

**Gross margin comparison** — the bundle held a strong margin despite the discounting typical of bundling:

| Line item | Margin |
|---|---|
| Fizzi (sold individually) | 65.5% |
| 8pc Chicken (sold individually) | 57.4% |
| **Bundle (8pc + 2L Fizzi)** | **55.5%** |

Cost-benefit ratio (profit ÷ cost) for the bundle: **1.25** in both test windows — i.e. every $1 of cost returned $1.25 of profit.

## 5. Business recommendation
- **Keep the bundle live** — the margin dip (57–65% → 55.5%) is small relative to the volume and revenue lift, so total profit dollars rose sharply.
- **Monitor via the Power BI dashboard**, not one-off analysis — set an alert if bundle margin drops below ~50% or unit growth stalls, so the promotion can be re-priced before profitability erodes.
- **Replicate the DID test structure** for future promotions so impact is never just eyeballed from raw before/after numbers, which overstate the true causal effect once trend/seasonality is ignored.

## 6. What I'd improve with more time
- Automate the Excel → SQL ETL step (currently manual/pandas) with a scheduled Power Query refresh.
- Add a control store/product line to strengthen the DID design.
- Extend the Power BI model with the loyalty survey (Project 02) to see if bundle buyers have a higher repeat-purchase rate, not just higher one-time spend.

## 7. Repo contents
```
project-01-bundling-impact/
├── README.md
├── data/                       # place raw & cleaned Excel files here
├── notebooks/                  # Cost_Analysis.ipynb, Untitled.ipynb
├── sql/01_schema_and_etl.sql   # centralized DB schema + validation rules
└── powerbi/dax_measures.md     # KPI / DAX definitions for the dashboard
```
