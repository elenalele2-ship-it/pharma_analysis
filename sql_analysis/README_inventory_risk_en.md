# Pharma Analysis — Inventory Risk (2023–2025)

SQL analysis on a synthetic dataset (Kaggle, original link no longer available) of a pharmaceutical company: identification of stockout risk, structural configuration issues (lead time vs. safety stock), expiration risk (shelf life), and related storage costs.

**Note on the dataset:** synthetic data for educational/portfolio purposes, does not represent a real company.

---

## Main insight

100% of the product-months classified as "adequate for safety stock but at risk for lead time" (162 products in 2023-2024, 147 in 2025) share an identical deterministic cause: `lead_time_months > safety_stock_months`. Zero exceptions, in both periods.

**What this means:** this is not a problem of unexpected demand or sales spikes — it's a systematic error in reorder parameter configuration. The safety policy is set on a shorter horizon than the actual time required to reorder. This is the most actionable finding of the entire analysis: correcting these parameters for the affected subset of products would have a direct, measurable impact.

---

## 1. Stockout Risk

**Method:** average monthly inventory per product compared against the minimum safety level; `level_risk` flagged when inventory falls below threshold.

**2025**
- 646 product-month cases at risk, across 239 distinct products (~96% of the catalog)
- Risk distributed throughout the year, two intensity bands: 30-50 cases/month (Jan, Feb, Apr, Aug, Dec) and 50-70 cases/month (Mar, May, Jun, Jul, Sep, Oct, Nov)
- Chronic products: P227 at risk in 7 out of 12 months; P048 and P100 in 6 out of 12 months
- Extreme cases (gap between minimum threshold and average inventory > 1000 units): P047, P163, P174 with average inventory of zero in at least one month — likely stockout caused by an unforeseen demand spike, not verifiable without additional product-level data

**2023-2024**
- 1,254 product-month cases at risk, across 241 products (~96% of the catalog)
- 2023: 586 cases / 231 products (92.4%) — 2024: 668 cases / 239 products (95.6%) — +14% cases from 2023 to 2024
- Chronic products: P154 and P202 at risk 12 out of 24 months (100% of the period); P048, P108, P203, P227 at risk 10-11 months
- P227 and P048 are also chronic in 2025 → confirms a structural, not seasonal or one-off, issue

**Overall risk comparison (Risk Rate)**

| Period | At risk | OK | Total | Risk rate |
|---|---:|---:|---:|---:|
| 2023-2024 | 1,254 | 4,742 | 6,000 | 20.9% |
| 2025 | 646 | 2,352 | 3,000 | 21.5% |

The overall risk rate remains stable between the two periods. Monthly distribution varies year over year with no fixed seasonal pattern (2024 has two distinct peaks, February and July; 2025 has only one, smaller, peak in June) — consistent with the absence of a structural improvement over time.

---

## 2. Latent risk: adequate safety stock but insufficient lead time coverage

**Method:** for each product-month, two thresholds are calculated based on average sales — `min_level_per_month` (safety stock) and `lead_time_sales` (requirement to cover lead time). Each case is then classified on two independent axes: adequacy vs. safety stock, and coverage vs. lead time.

**Key numbers**

| | 2023-2024 | 2025 |
|---|---:|---:|
| Stockout risk + insufficient coverage | 1,123 | 568 |
| Adequate stock + insufficient coverage (latent risk) | 892 | 398 |
| Unique products involved in latent risk | 162 | 147 |
| Of which with `lead_time > safety_stock` | 162 (100%) | 147 (100%) |

*Note: within the total at-risk cases (1,254 in 2023-2024, 646 in 2025), minor coverage categories remain unlabeled in this summary — to be verified against the original query before publishing further breakdown figures.*

**2023-2024 vs. 2025 comparison:** the share of at-risk cases also showing insufficient lead time is similar across both periods (89.6% vs. 87.9%); the share of "borderline" cases (adequate stock but insufficient coverage) is likewise comparable (18.8% vs. 16.9%) — the phenomenon is stable over time, not an isolated anomaly.

### 2b. Detailed list of latent risk cases

Objective: turn the aggregate into an actionable list for whoever manages reordering, with severity (`gap_inventory_lead_time_sales` = actual inventory − lead time requirement).

- **2023-2024**: most critical case P038 (512 units available against 1,362 required, gap −850). Followed by P044, P020, P173 with gaps beyond −370.
- **2025**: most critical case P163 in August (inventory at zero against a requirement of 2,715 units, gap −2,715 — the most severe value in the entire analysis, worse even than the 2023-2024 peak). Followed by P127 (−1,601), P210 (−1,474), P197 (−1,102).
- P163 and P038 appear at the top of both lists (2023-24 and 2025) — a signal worth further investigation, not yet systematically verified.

**Insight:** the gap is not uniform across the products involved — a few cases concentrate very large gaps, while most have modest gaps. This allows prioritization: intervening on the policy starting from the top of the list, rather than treating all products at once.

---

## 3. Storage cost of latent risk cases

**Objective:** quantify the capital tied up in storage for products that are "adequate but exposed" (the 162/147 from point 2).

| Period | Total storage cost (latent risk cases) | Most costly case |
|---|---:|---|
| 2023 | 59,869.95 PLN | P197 (2 months >900 PLN/month) |
| 2024 | 58,367.05 PLN | P197, followed by P173, P082, P060 |
| 2025 | 57,908.19 PLN | P082 in May (1,168.08 PLN in a single month) |

**Insight:** the company pays to hold this stock, but that cost doesn't buy protection from the risk — the products remain uncovered against actual lead time. A double problem: cost incurred + risk not covered. Consistency between 2023-2024 and 2025 reinforces the structural hypothesis: this is not contingent management, it's a systematic parameter error.

---

## 4. Expiration risk (Shelf Life)

**Method:** for each product-month, actual inventory is compared against `shelf_life_qsales` (average sales × shelf life in months). If inventory exceeds this threshold, the product is flagged `high_risk` (too much stock relative to what can be sold before expiration).

| Year | high_risk cases | Unique products | Most exposed product |
|---|---:|---:|---|
| 2023 | 43 | 28 | P138, P247 (6 months) |
| 2024 | 51 | 31 | P013 (5 months) |
| 2025 | 42 | 24 | P038 (4 months) |

Out of 6,000 product-months observed in 2023-2024, only 1.57% is `high_risk` — a much rarer phenomenon than lead time risk.

**Overlap across periods:** only 11 products appear at risk in both 2023 and 2024. Comparing the combined 2023-2024 set (48 products) with 2025 (24 products): 17 products overlap, but only **4 products** are at risk in all three periods individually — these are the only genuinely chronic cases.

**Insight — key difference from lead time risk:** expiration risk is predominantly **transient**, not structural. Most of the products involved change from one period to the next, unlike the 162/147 products in the lead time risk analysis, which remain identical regardless of the period observed. This suggests the phenomenon here depends on monthly stock accumulation dynamics rather than a fixed flaw in product configuration.

---

## Overall conclusions

1. **Structural risk (lead time vs. safety stock):** the same group of products remains exposed consistently, with a deterministic cause identified (100% of cases). Recommended action: revise configuration parameters for products with `lead_time_months > safety_stock_months`.
2. **Transient risk (shelf life):** rarer phenomenon, involved products change over time, requires monthly monitoring rather than a one-time parameter fix.
3. In both cases, without additional information on product type, usage, and demand, it's not possible to determine root causes (seasonality, reordering errors, demand exceeding expectations) — only to confirm the presence, recurrence, and economic impact of the phenomenon.
