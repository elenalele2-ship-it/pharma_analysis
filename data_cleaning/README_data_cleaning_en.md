# Project: Pharma Supply Chain / Sales Analysis (SQL)

## Initial dataset assessment

### Note on the dataset
The data used in this project was downloaded from Kaggle. The original link could not be recovered at the time of writing this README; the dataset does not represent a real company — any reference to pharmaceutical products, sales, or budgets is purely scenario-based, for educational purposes.

**Technical note:** the original files distinguished 2023-2024 sales (`train`) from 2025 (`test`), naming typical of a dataset designed for forecasting/predictive modeling exercises. In this project, all three years are treated as continuous historical data for a budget vs actual analysis, which does not involve forecasting.

Project built to demonstrate SQL skills (CTEs, CASE, aggregations, multi-table dataset handling) applied to a realistic business case, as a first portfolio project.

Dataset made of 4 raw CSVs (`financial_plan`, `products_parameters`, `sales_train_2023_2024`, `sales_test_2025`), linked via the natural key `ProductID` (250 products). The data is realistic — wide format (months/years as columns), overlapping/duplicate columns across tables — making it a good candidate for a publishable SQL/GitHub project, since it requires genuine modeling decisions (normalization, star schema), not just simple joins on already-clean data.

---

## Modeling decisions

**Decision 1 — Star Schema**
- Dimension table: `products_parameters` → static/master attributes of each product
- Fact tables: `financial_plan`, `sales`, `inventory` → time-varying measures, linked to the dimension only via `ProductID`

Guiding criterion: static (doesn't change over time) vs. dynamic (varies by year/month).

**Decision 2 — Product_name removed from fact tables**
Descriptive, non-temporal attribute → kept only in `products_parameters`, retrievable via JOIN. Removed from `sales`, `inventory`, `financial_plan`.

**Decision 3 — Price_PLN_per_unit centralized in products_parameters**
Duplicated between `financial_plan` and `products_parameters` with identical values. Normalization test: price doesn't change across Plan_2023/2024/2025, so it's a product attribute (dimension), not a plan attribute (fact). Removed from `financial_plan`.

**Decision 4 — Wide → long format**
Source tables (wide, months as columns) were converted to long format (`ProductID, date, quantity`) for sales and inventory, to enable easier joins, aggregation, and UNION across periods (2023-24 and test 2025). `financial_plan` initially stayed wide (annual granularity, no immediate benefit to unpivoting) — see the section below on its later evolution to long format.

**Decision 5 — Quantity column naming**
Verified that `sales_2324_long` / `sales_train_2025_long` use `quantity_sales`, while `inventory_2324_long` / `inventory_test_2025_long` use `inventory_level` — distinct, correct names, no remaining ambiguity (previously an open point, now closed).

**Decision 6 — financial_plan finalized (wide phase)**
`Product_name` and `Price_PLN_per_unit` permanently removed. Intermediate structure: `ProductID, Plan_2023_units, Plan_2024_units, Plan_2025_units, Plan_2023_PLN, Plan_2024_PLN, Plan_2025_PLN`.

---

## Data quality check — products_parameters

Verified: 250 unique `ProductID`s (no duplicates), zero null values across all columns, no anomalous values (zero/negative) in `Price_PLN_per_unit` (min 8.00, max 220.81). Table confirmed ready as the central dimension table. No transformation required — verification only.

---

## Final schema

| Table | Role | Columns | File |
|---|---|---|---|
| products_parameters | Dimension | ProductID, Product_name, Storage_cost, Shelf_life, Lead_time, Safety_stock, Price | `products_parameters.csv` |
| financial_plan | Fact | ProductID, Year, PLN, units | `financial_plan_2324_final.csv`, `financial_plan_2025_final.csv` |
| sales | Fact | ProductID, date, quantity_sales | `sales_2324_long.csv`, `sales_train_2025_long.csv` |
| inventory | Fact | ProductID, date, inventory_level | `inventory_2324_long.csv`, `inventory_test_2025_long.csv` |

---

## Schema evolution: financial_plan from wide to long format

### The problem
The stakeholder requested a comparison between actual sales and the financial plan, per product, for 2023 and 2024. Sales data (`sales_2324_long`) is already in long format, with one row per product/month — the natural granularity for annual aggregation with `SUM()` and `GROUP BY`.

`financial_plan`, on the other hand, was in wide format: one row per product, with separate columns for each year and metric (`Plan_2023_units`, `Plan_2024_units`, `Plan_2025_units`, `Plan_2023_PLN`, `Plan_2024_PLN`, `Plan_2025_PLN`).

### Why the wide format was a limitation
Joining aggregated sales (long, key `ProductID + year`) with the plan (wide, key `ProductID` only) couldn't happen on both dimensions at once: without an explicit `year` column in `financial_plan`, it wasn't possible to match "2023 sales for P001" to "2023 plan for P001" without additional conditional logic (e.g. `CASE WHEN`) for every year — a poorly scalable solution, inconsistent with the schema of the other fact tables in the project.

### The decision
`financial_plan` was transformed from wide to long and split into two files, following the same pattern already adopted for sales/inventory (2023-2024 historical data kept separate from 2025 data):
- `financial_plan_2324_final.csv`: columns `ProductID, Year, PLN, units`
- `financial_plan_2025_final.csv`: same structure, 2025 data only

The transformation was performed in Python (Google Colab) using `melt` (wide → long) followed by `pivot` (to split the `units` and `PLN` measures into distinct columns on the same product-year row), keeping `units` and `PLN` in the same table since they share the same granularity and the same data source — unlike sales/inventory, which are conceptually distinct facts (flow vs. stock).

### Lessons learned
During the transformation, the `year` column — obtained as a string from the original column name (e.g. "2023" extracted from "Plan_2023_units") — was initially converted to datetime format by mistake, out of habit from working with the monthly date columns in `sales_2324_long`. This would have introduced a type inconsistency with `EXTRACT(YEAR FROM date)`, already used elsewhere in the project to obtain the year as an integer, unnecessarily complicating future joins. The column was later corrected and kept as `INTEGER`, ensuring type consistency with the rest of the schema.

---

## Known issues — found and fixed

During the review of the cleaning notebooks, three implementation issues (not modeling issues) were found:

1. **Spurious `index` column in `financial_plan_2025_final`.** Caused by a double call to `reset_index()` on the same DataFrame: the first call correctly turned the `ProductID, Year` index (created by the pivot) into columns; the second, applied to a DataFrame that already had a standard numeric index, generated an extra column named `index`. Fixed by removing the duplicate call.

2. **Column rename performed after saving, in `sales_train_2025`.** The `quantity_sales_2025` column was renamed to `quantity_sales` only after a first save/download of the CSV, which therefore still contained the old column name. Fixed by moving the rename before the final save.

3. **Malformed second save, in the same notebook.** A save following point 2 was missing both the `.csv` extension in the file name and the `index=False` parameter, introducing an unwanted index column. Resolved by consolidating into a single correct save, performed after the rename.

None of these issues affected the final data structure reported in the schema above — they were caught and fixed before publishing the final CSVs.

---

## Quality checks performed on all notebooks

- Duplicate check (`duplicated().sum()`)
- Missing values check (`isnull().sum()`)
- Data type check (`dtypes` / `info()`)
- Value range check on key numeric columns (e.g. `Price_PLN_per_unit`, `describe()`)
