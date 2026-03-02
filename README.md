# 🎮 vgsales-data-project (Docker + PostgreSQL + SQL + Python + Power BI)

> **Portfolio project** using the Kaggle dataset **“Video Game Sales (vgsales)”**.  
> Goal: build a realistic local analytics pipeline (**staging → clean → star schema → views → Power BI dashboard**) with reproducible setup across **2 PCs**.

---

## 📌 Project Goals (What this repo is for)

- ✅ Practice an end-to-end data workflow (similar to real BI/Analytics work)
- ✅ Use **Docker + PostgreSQL** as the local “warehouse”
- ✅ Load raw CSV into **staging** via **Python (pandas + SQLAlchemy + psycopg2 + dotenv)**
- ✅ Run **data quality checks** (NULLs, duplicates, outliers, consistency checks)
- ✅ Create a **clean staging layer** (SQL views for standardization + dedup)
- 🔜 Build **dimensional model (star schema)**: `dim_*` + `fact_sales`
- 🔜 Create **SQL views** optimized for Power BI consumption
- 🔜 Build a **Power BI dashboard** (KPIs, trends, regional split, rankings)

---

## 🧱 Tech Stack

- 🐳 **Docker / Docker Compose** (local infrastructure)
- 🐘 **PostgreSQL** (database)
- 🧠 **SQL** (checks, transformations, views, dimensional model)
- 🐍 **Python** (ingestion + automation)
  - `pandas`
  - `SQLAlchemy`
  - `psycopg2-binary`
  - `python-dotenv`
- 📊 **Power BI** (dashboard / reporting)
- 🧰 **DBeaver** (DB client for validation)

---

## 🧬 Data Architecture (Layers)

This project follows a simple warehouse-style flow:

1) **Raw Staging**: `stg_vgsales_raw`  
   - Raw load of the CSV (audit-friendly)

2) **Normalized Staging (View)**: `stg_vgsales_norm`  
   - Standardization only: `TRIM()` + empty strings → `NULL`

3) **Clean Staging (View)**: `stg_vgsales_clean`  
   - Deduplication using a defined grain: **(name, platform, year)**  
   - Dedup rule (current): keep the row with:
     1. highest `global_sales`
     2. highest regional sum (`na+eu+jp+other`)
     3. lowest `rank` as final tie-breaker  
   - Includes `dup_count` for auditing (optional column)

4) **Data Mart (Star Schema)** *(next)*  
   - Dimensions + Fact (Kimball-style star schema)

5) **Power BI Semantic Views** *(next)*  
   - Views to simplify Power BI connection and keep logic in SQL

---

## 📂 Repository Structure (current)

```text
vgsales-data-project/
├─ data/
│  └─ raw/
│     └─ vgsales.csv                      # (local only) do NOT commit
├─ sql/
│  ├─ 01_staging.sql                      # staging table DDL (placeholder name)
│  ├─ staging_quality_checks.sql          # QA checks on raw staging
│  └─ 03_create_stg_clean_view.sql        # creates stg_vgsales_norm + stg_vgsales_clean
├─ src/
│  ├─ 01_load_stating.py                  # Python ingestion (consider renaming to *_staging.py)
│  └─ Notebook.ipynb                      # optional exploration
├─ .env                                   # local only (ignored by git)
├─ .gitignore
├─ docker-compose.yml
├─ requirements.txt
└─ README.md
