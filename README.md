Pharma Analysis — SQL & Data Cleaning Portfolio Project
A SQL and Python data analysis project on a synthetic pharmaceutical company dataset, covering data modeling, budget vs actual analysis, and inventory risk analysis.
Built as a first portfolio project to demonstrate SQL skills (CTEs, CASE, aggregations, multi-table joins), data cleaning in Python (pandas, wide-to-long transformations), and analytical reasoning applied to a realistic business scenario.
Note on the dataset: the data was downloaded from Kaggle and does not represent a real company — it is used purely for educational/portfolio purposes.
Project structure
Folder	Contents
data_cleaning/	Python/Colab notebooks that transform the raw Kaggle CSVs into the clean, modeled dataset. Documents the star-schema design decisions and issues found and fixed during cleaning.
data/clean/	Final cleaned CSV files, ready to load into a database.
sql_analysis/budget_vs_actual/	Comparison between planned budget and actual sales, by product, year, and price tier — investigates why the PLN gap changes even when the unit gap stays similar.
sql_analysis/inventory_risk/	Stockout risk, lead time vs. safety stock configuration issues, shelf life / expiration risk, and related storage costs.
charts/	Supporting charts referenced in the analysis READMEs.
Highlights
Data modeling: raw wide-format CSVs (with duplicated attributes across tables) redesigned into a star schema — one dimension table (products_parameters) and three fact tables (financial_plan, sales, inventory), with an explicit normalization rationale documented in data_cleaning/README.md.
Budget vs Actual: a similar unit gap between 2023 and 2024 hides an 11% difference in PLN — traced to a mix-shift between high- and low-price products, confirmed at the price-tier level, then re-tested against 2025 data.
Inventory Risk: 100% of "latent risk" product-months (adequate safety stock, but insufficient lead time coverage) share one deterministic cause — lead_time_months > safety_stock_months — pointing to a systematic parameter configuration issue rather than demand variability.
See each linked README for full methodology, SQL queries, and detailed findings.
