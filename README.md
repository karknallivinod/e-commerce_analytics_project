# E-Commerce Analytics: SQL, Python (RFM & Cohorts) & Power BI

An end-to-end data analytics workflow examining **222M in gross revenue** across **6,000 orders** and **1,045 unique customers**. 

This project bridges relational database queries, statistical customer modeling in Python, and executive BI reporting to analyze customer retention, profitability margins, and churn risk.

---

## 🏗️ Architecture & Data Pipeline

```text
[ Relational DB (SQL) ] 
       │
       ├── Tasks 1-5: Filtering, Monthly MoM Trends, Category Margins & RFM Extraction
       ▼
[ Python (Pandas / Jupyter) ]
       │
       ├── Task 6: Quantile Scoring (qcut) & Customer Segmentation
       ├── Task 7: Acquisition Indexing & Month-over-Month Cohort Retention
       ▼
[ Processed CSVs ] ──► [ Power BI Dashboard (3 Interactive Views) ]
ecommerce-analytics-project/
├── README.md
├── sql/
│   └── analysis_queries.sql              # Tasks 1 to 5 (Core Aggregations & RFM Base Table)
├── python/
│   └── rfm_and_cohort_analysis.ipynb     # Tasks 6 & 7 (RFM Quantiles & Cohort Matrix)
├── powerbi/
│   └── ecommerce_analytics_dashboard.pbix # Interactive multi-page reporting model
├── data/
│   ├── customers.csv
│   ├── products.csv
│   ├── orders.csv
│   └── order_items.csv
└── screenshots/
    ├── executive_overview.png
    ├── customer_segmentation.png
    └── product_cohort_insights.png
Phase 1: Database Operations & SQL Metrics (sql/analysis_queries.sql)
Task 1 — Order Status Distribution: Calculated absolute counts and relative percentages for order fulfillment (Delivered, Cancelled, Returned) to evaluate operational baseline health.

Task 2 — Monthly Revenue (Delivered Orders): Aggregated gross merchandise value by month, isolating confirmed delivered revenue streams.

Task 3 — Month-over-Month (MoM) Growth %: Implemented LAG() window functions over chronological order dates to compute percentage growth swings across 2024–2025.

Task 4 — Category Profitability & Margins: Joined products, orders, and order items to analyze total revenue versus profit margin per category (identifying high-margin drivers like Beauty & Personal Care).

Task 5 — RFM Base Extraction Table: Designed a consolidated customer-level query isolating customer_id, recency (days since last delivered purchase), frequency (count of distinct delivered orders), and monetary (sum of delivered order spend).

Phase 2: Statistical Modeling & Retention in Python (python/rfm_and_cohort_analysis.ipynb)
Task 6 — RFM Scoring & Customer Segmentation
Why Python?: While SQL can approximate distribution buckets using NTILE(4), Python's pd.qcut() provides flexible handling of duplicate bin edges and enables dynamic mapping into behavioral profiles.

Segments Created:

Champions: Top quartile spend and recency, contributing over 60% (>135M) of revenue.

Potential Loyalists: Recent shoppers with emerging purchase frequency.

Loyal Customers: Consistent repeat spenders across mid-tier buckets (~40M total spend).

Needs Attention: Average spenders showing declining activity windows.

At Risk / Churned: Customers dormant for >400 days requiring win-back strategies.

Task 7 — Cohort Retention Matrix
Why Python?: Measuring month-over-month retention requires calculating a per-customer transaction index relative to their initial acquisition date (CohortIndex=YearDiff×12+MonthDiff). Pandas simplifies this logic into clean, readable vector operations compared to multi-layered self-joins in SQL.

Export: Generated final matrix and segmented datasets as analytical CSVs for visualization.

Phase 3: Business Intelligence in Power BI (powerbi/ecommerce_analytics_dashboard.pbix)
1. Executive Overview
Surfaces high-level business performance: 222M Gross Revenue, 6K Orders, 37.21K AOV, an 18.47% average profit margin, and city-level revenue breakdowns led by Nagpur, Kochi, and Ahmedabad.

2. Customer Segmentation
Interactive distribution of the 1,045 active customers across the 5 RFM segments, pairing total monetary contribution by segment with a Recency vs. Frequency scatter plot.

3. Product & Cohort Insights
A dynamic cohort retention heatmap tracking retention degradation by monthly cohort, paired with cancellation rate breakdowns by payment method (COD leading at ~18.5%) and category profit margins.

💡 Strategic Takeaways
Protect the VIP Segment: 311 Champion customers generate the vast majority of revenue (>135M). Dedicating retention budgets and loyalty perks to this cohort yields the highest ROI.

Address Cash-on-Delivery Risk: COD exhibits the highest cancellation rate (~18.5%). Offering nominal incentives (1–2% discounts) for prepaid UPI/Cards can protect pipeline margins.

Margin-Optimized Cross-Selling: High-volume Electronics should be strategically cross-sold with high-margin categories like Beauty & Personal Care (~21% profit margin).
