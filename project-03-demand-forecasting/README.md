# Project 03 — Quarterly Demand Forecasting (SARIMA)

**TL;DR for recruiters:** Built a SARIMA time-series model in Python (`statsmodels`) to forecast quarterly demand/investment 8 quarters ahead with confidence intervals, to support inventory and promo-planning decisions.

## 1. Business problem
Management needs a forward-looking view of demand — not just historical before/after comparisons (Project 01) — to plan stock and staffing for future promotional periods.

## 2. Data
Quarterly time series, 2021–2024 (`sarima_with_2021.ipynb`), 16 data points showing a strong upward trend with seasonal fluctuation.

## 3. Methodology
1. **Stationarity check** — Augmented Dickey-Fuller test on the raw series before modelling.
2. **Model** — `SARIMAX(order=(1,1,1), seasonal_order=(1,1,1,4))` fit with `statsmodels`, using a 4-period seasonal cycle (quarterly).
3. **Forecast** — 8-quarter-ahead forecast with 95% confidence interval, plotted against history.

## 4. Data quality note (lessons learned)
The original notebook parsed quarter labels (`'2021-Q1'`) using a `%q` strptime directive, which isn't a valid Python date directive and raised a `ValueError`. **Fix:** map quarter numbers to a representative month before parsing, e.g.:

```python
quarter_to_month = {1: '01', 2: '04', 3: '07', 4: '10'}
df['Year'] = df['Year'].apply(
    lambda x: f"{x.split('-')[0]}-{quarter_to_month[int(x.split('-Q')[1])]}-01"
)
df['Year'] = pd.to_datetime(df['Year'])
```
This kind of parsing bug is exactly why the SQL/Power BI layer in Project 01 enforces `TRY_CAST` validation on load rather than trusting raw date strings — a small but real example of validate-before-you-model discipline.

## 5. Status
Model runs end-to-end after the date-parsing fix; next step is backtesting (train/test split) to quantify forecast accuracy (MAPE) before presenting the forecast as a planning input.
