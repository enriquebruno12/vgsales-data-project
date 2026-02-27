# 🎮 vgsales-data-project (Docker + PostgreSQL + SQL + Python + Power BI)

> **Portfolio project** using the Kaggle dataset **“Video Game Sales (vgsales)”**.  
> Goal: build a realistic local analytics pipeline (**staging → clean → star schema → views → Power BI dashboard**) with reproducible setup across **2 PCs**.

---

## 📌 Project Goals (What this repo is for)

- ✅ Practice an end-to-end data workflow (similar to real BI/Analytics work)
- ✅ Use **Docker + PostgreSQL** as the local “warehouse”
- ✅ Load raw CSV into **staging** via **Python (pandas + SQLAlchemy + psycopg2 + dotenv)**
- ✅ Run **data quality checks** (NULLs, duplicates, outliers, consistency checks)
- 🔜 Build **dimensional model (star schema)**: `dim_*` + `fact_sales`
- 🔜 Create **SQL views** optimized for Power BI consumption
- 🔜 Build a **Power BI dashboard** (KPIs, trends, regional split, rankings)
- 🔜 Add a small ML layer later (e.g., predicting sales / clustering games)

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

## 📂 Repository Structure (current)

```text
vgsales-data-project/
├─ data/
│  └─ raw/
│     └─ vgsales.csv                      # (local only) do NOT commit
├─ sql/
│  ├─ 01_staging.sql                      # staging table DDL (placeholder name)
│  └─ staging_quality_checks.sql          # your QA checks
├─ src/
│  ├─ 01_load_stating.py                  # Python ingestion (consider renaming to *_staging.py)
│  └─ Notebook.ipynb                      # optional exploration
├─ .env                                   # local only (ignored by git)
├─ .gitignore
├─ docker-compose.yml
├─ requirements.txt
└─ README.md