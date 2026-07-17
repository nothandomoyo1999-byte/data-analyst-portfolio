# Project 02 — Customer Satisfaction & Loyalty Survey

**TL;DR for recruiters:** Designed a structured survey instrument, built validation rules for response data, and modeled a loyalty index in Excel/Power BI to test whether bundle buyers show higher satisfaction, repurchase intent, and recommendation likelihood than non-bundle buyers.

## 1. Business problem
Project 01 proved the bundle grew *revenue*. This project asks the follow-up question management actually cares about: **does it grow loyal customers, or just one-off spend?**

## 2. Data & instrument
- `questions_for_survey.docx` — survey instrument (Sections A–C: demographics, purchasing behavior, satisfaction/loyalty), using 5-point Likert scales for satisfaction, repurchase likelihood, and recommendation likelihood.
- `QUESTIONNAIRE.xlsx` — structured question bank / coding sheet.
- `respondents.xlsx`, `Copy_of_Untitled_form_Responses.xlsx` — raw response exports.

## 3. Methodology
1. **Validate** — coded categorical responses (e.g. "18–25" → `1`), checked for incomplete responses and duplicate submissions, and cross-checked frequency-of-visit answers against known purchase records for consistency.
2. **Segment** — split respondents into *bundle purchasers* vs. *non-purchasers* (Q6) to compare satisfaction and loyalty scores between groups.
3. **Score** — built a composite **Loyalty Index** from Q11–Q13 (value-for-money, repurchase intent, recommendation likelihood), averaged and normalized to 0–100.
4. **Visualize** — Power BI/Excel dashboard segmenting the loyalty index by age, income, and visit frequency, so marketing can target the highest-value segments.

## 4. Planned KPIs
| KPI | Definition |
|---|---|
| Loyalty Index | Mean of Q11–Q13 (1–5 scale), rescaled to 0–100 |
| Repurchase Intent % | Share of respondents answering "Likely"/"Very Likely" on Q12 |
| Recommendation Rate (proxy NPS) | Share answering "Likely"/"Very Likely" on Q13 |
| Bundle Penetration | Share of respondents who answered "Yes" to Q6 |

## 5. Status
Survey instrument and response data collected; dashboard build in progress. Next step: link the Loyalty Index back to the `fact_sales` model from Project 01 via a shared customer/period key so repurchase intent can eventually be validated against actual repeat-purchase data rather than self-reported intent alone.
