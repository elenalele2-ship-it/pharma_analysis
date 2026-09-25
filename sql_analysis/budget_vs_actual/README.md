# Pharma Analysis — Budget vs Actual (2023–2025)

SQL analysis on a synthetic dataset (Kaggle, original link no longer available) of a pharmaceutical company: comparison between planned budget and actual sales, by product, year, and price tier.

**Note on the dataset:** does not represent a real company — data for educational/portfolio purposes. The original files distinguished 2023-2024 (`train`) from 2025 (`test`), naming typical of datasets built for forecasting exercises; here all three years are treated as continuous historical data, since the objective is budget vs actual, not forecasting.

---

## 1. Business question

For each product and year, how much does actual revenue differ from the planned budget?

The gap between sales and budget in **units** is similar between 2023 and 2024 (+14,079 vs +14,319), but the gap in **PLN** drops by 11% (620,262 → 549,439 PLN). Hypothesis: the over-budget gap shifts from expensive to cheaper products (mix-shift), not just a change in volume.

**Budget status distribution**

| | 2023 | 2024 |
|---|---:|---:|
| On Budget | 3 | 1 |
| Over Budget | 164 | 173 |
| Under Budget | 83 | 76 |

---

## 2. Methodology

1. `budget_vs_actual` — joins sales, budget, and price per product/year (2023-2024 and 2025 with `union all`), calculates `variance = actual_revenue − budget_PLN`
2. `budget_case` — classifies each row Over/Under/On Budget with `CASE`
3. `units_gap` — assigns the price tier (High/Low, threshold = median price, 31,485 PLN)
4. Final query — sums `variance` by year and price tier

---

## 3. Variance by price tier (mix-shift)

| Year | High Price | Low Price | Total |
|---|---:|---:|---:|
| 2023 | 491,335 | 128,927 | 620,262 |
| 2024 | 391,573 | 157,866 | 549,439 |
| 2025 | 521,305 | 211,590 | 732,895 |

**2023 → 2024:** mix-shift hypothesis confirmed — the High tier drops (-100k), the Low tier rises (+29k). The total decline is explained almost entirely by the collapse of the high tier.

**2025:** breaks the pattern — both tiers grow, no longer a shift between tiers but a generalized increase in over-budget performance.

---

## 4. Why 2025 breaks the pattern: budget vs. actual sales

| Year | Budget (units) | Actual sales (units) | Gap |
|---|---:|---:|---:|
| 2023 | 253,115 | 267,194 | 14,079 |
| 2024 | 257,747 | 272,066 | 14,319 |
| 2025 | 259,737 | 280,919 | 21,182 |

The budget grows steadily (253k → 258k → 260k) — it does not become more conservative in 2025. The jump in the gap is therefore explained by a genuine acceleration in actual sales: growth from 2024 to 2025 (+8,853 units) is nearly double the growth from 2023 to 2024 (+4,872 units).

---

## 5. Products at the extremes (2025)

Top 10 products furthest over and under budget in PLN, obtained by filtering `units_gap` by year, sorted by `variance` (positive and negative).

Almost all products in both lists have a unit price above the median (31,485 PLN). This doesn't by itself indicate anomalous sales behavior: it's the mathematical consequence of `variance = price × gap_units` — an expensive product automatically produces a larger absolute variance, in both directions, even with a normal unit gap.

---

## 6. Price vs. unit gap — separating the price effect from the actual sales gap

To distinguish "product on the list just because it's expensive" from "product with a genuinely anomalous sales gap," `p_unit` (price) and `gap_units` (unit gap, without the price multiplier) are compared directly for the extreme products across the three years.

*[Scatter plot: Price (PLN) vs. Unit gap, extreme products 2023-2025]*

**How to read it:**
- High price + high gap_units → strong case in both directions
- Low price + high gap_units → genuine, significant gap, but "silent" in PLN
- High price + low gap_units → on the list only due to the price effect, not anomalous behavior

**Observation from the chart:** the points show no strong correlation between price and unit gap — the two phenomena are fairly independent. This confirms that the PLN variance rankings (section 5) are partly "inflated" by product price, not solely by unusual sales behavior.

---

## Conclusions

1. The decline in the PLN gap from 2023 to 2024 is explained by a mix-shift toward cheaper products — confirmed at the price-tier level.
2. The 2025 jump is real (higher sales), not a budget artifact.
3. Rankings of "most extreme" products by PLN variance should be read with caution: product price amplifies the metric independently of sales behavior — identifying true behavioral outliers requires looking at the unit gap, not monetary variance alone.
