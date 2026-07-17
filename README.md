# Nothando Moyo — Data Analyst Portfolio

Business-focused analytics portfolio covering **Excel, SQL, Power BI, and Python**, built around a real retail case study: measuring and predicting the impact of product bundling on sales, profitability, and customer loyalty for a QSR (chicken) outlet.

Every project follows the same pipeline: **compile → validate → model (SQL) → visualize (Power BI) → recommend**, so each README is written the way a stakeholder deck would be, not just a notebook dump.

## 🧰 Skills demonstrated

| Area | Tools | Where |
|---|---|---|
| Data compiling & cleaning | Excel (Power Query, formulas) | all projects |
| Data validation & integrity checks | SQL constraints, Excel data validation, Python asserts | Project 01 |
| Centralized database design | SQL (star schema: fact/dim tables, views) | Project 01 |
| Statistical / causal analysis | Python (pandas, statsmodels) — Difference-in-Differences, growth & margin analysis | Project 01 |
| Forecasting | Python (SARIMA) | Project 03 |
| Survey design & analytics | Excel, Power BI | Project 02 |
| Dashboarding & KPI design | Power BI (DAX measures), Excel PivotTables | all projects |
| Business performance monitoring | Power BI KPI cards, trend visuals | Project 01, 02 |

## 📂 Projects

| # | Project | Business question | Tools | Headline result |
|---|---|---|---|---|
| 01 | [Bundling Strategy — Impact & Causal Analysis](./project-01-bundling-impact) | Did the 8pc-chicken + 2L-Fizzi bundle actually grow revenue and profit, or just cannibalize existing sales? | Excel, SQL, Python, Power BI | Revenue up **306%** combined across two test windows; bundle still delivered a **55.5%** gross margin |
| 02 | [Customer Satisfaction & Loyalty Survey](./project-02-customer-loyalty-survey) | Are customers who buy the bundle more likely to repurchase and recommend? | Excel, Power BI | Survey-driven loyalty index & segmentation (see project README) |
| 03 | [Demand Forecasting (SARIMA)](./project-03-demand-forecasting) | What should we expect demand/investment to look like next 2 years? | Python (statsmodels) | Quarterly forecast with confidence intervals |

## 📁 Repository structure

```
data-analyst-portfolio/
├── README.md                          <- you are here
├── project-01-bundling-impact/
│   ├── README.md                      <- full case study write-up
│   ├── data/                          <- raw & cleaned Excel extracts
│   ├── sql/01_schema_and_etl.sql      <- centralized DB schema + validation
│   ├── notebooks/                     <- Python analysis (cost/margin, DID)
│   └── powerbi/dax_measures.md        <- KPI / DAX reference for the dashboard
├── project-02-customer-loyalty-survey/
│   └── README.md
└── project-03-demand-forecasting/
    └── README.md
```

## 🚀 How to use this repo
1. Start with **Project 01** — it's the most complete, end-to-end example (raw Excel → SQL → Python analysis → Power BI dashboard → business recommendation).
2. Each project README has a **"Business impact"** section at the top for recruiters skimming quickly, and a **"Methodology"** section below for technical reviewers.

## 📫 Contact
Nothando Moyo · [LinkedIn] · [email]

---
*This portfolio is adapted from an academic research project on promotional bundling; data has been anonymized/aggregated where required.*
