# GoExplore Analytics Dashboard

## Project Overview
GoExplore is a Camping and Hiking supplier operating across
21 markets with 289 retailers and 149,257 transactions.

This project builds a complete self-service analytics
dashboard for GoExplore's CEO (Sabah) and department heads
to make data-driven business decisions — starting from
raw CSV files all the way to an interactive live dashboard.

---

## Full Data Pipeline


---

## Stage 1 — Google Sheets (Data Exploration)

### What I did in Google Sheets:
- Uploaded all 4 raw CSV files into Google Sheets
- Explored column headers and data structure
- Identified key business questions from the data
- Spotted data relationships between tables
- Connected Google Sheets directly to BigQuery

### Files uploaded to Google Sheets:
| File | Rows | Description |
|------|------|-------------|
| GoExplore_daily_sales.csv | 149,257 | All sales transactions |
| GoExplore_products.csv | 244 | Product catalogue |
| GoExplore_retailers.csv | 289 | Retailer information |
| GoExplore_methods.csv | 7 | Order method types |

### Key observations from Google Sheets exploration:
- daily_sales connects to Products via Product_number
- daily_sales connects to Retailers via Retailer_code
- daily_sales connects to Methods via Order_method_code
- Date range spans 2015 to 2018 — 4 years of data
- 21 countries across 5 global regions
- 5 product lines from camping to golf equipment
- Revenue calculated as Quantity × Unit_sale_price
- Profit calculated as Revenue minus Unit_cost

### Why Google Sheets first?
Google Sheets is a low-barrier tool perfect for:
- Quick data exploration without any coding
- Understanding data structure and column names
- Spotting missing values or data quality issues
- Sharing raw data with non-technical teammates
- Connecting directly to BigQuery as a data source

---

## Stage 2 — BigQuery (Data Warehouse + SQL)

### What I did in BigQuery:
- Connected Google Sheets directly to BigQuery
- Created dataset: goexplore in project goexplore-505409
- Loaded all 4 tables into BigQuery
- Wrote 14 analytical SQL queries (BigQuery Analysis Playbook)
- Built one master dashboard query using CTEs
- Saved master query as GoExplore_Master_Dashboard

### Tables in BigQuery:
| Table | Rows | Key columns |
|-------|------|-------------|
| daily_sales | 149,257 | Date, Quantity, Unit_sale_price |
| Products | 244 | Product_line, Unit_cost |
| Retailers | 289 | Country, Type |
| methods | 7 | Order_method_type |

### SQL Approach — CTEs (Common Table Expressions):
Used BigQuery CTEs to build a clean master query in 3 steps:

**Step 1 — base CTE:**
Joins all 4 tables together and calculates row-level numbers

**Step 2 — aggregated CTE:**
Groups data and calculates all KPIs by dimensions

**Step 3 — Final SELECT:**
Adds tier classifications on top of aggregated data

```sql
WITH base AS (
  -- Join all 4 tables
  -- Calculate row level revenue, cost, profit
),
aggregated AS (
  -- Group by all dimensions
  -- Calculate SUM, AVG, COUNT KPIs
)
SELECT *,
  -- Add discount_tier
  -- Add margin_tier  
  -- Add order_size_tier
FROM aggregated
```

### Why CTEs instead of simple queries?
| Simple Query | CTE Approach |
|-------------|-------------|
| One long messy query | Clean organized steps |
| Hard to read | Easy to understand |
| Hard to debug | Easy to find errors |
| Cannot reuse parts | Reuse each step |
| Junior approach | Professional approach |

### 14 Analytical Queries built:
1. Revenue and Profit Trends by Year and Month
2. Product Line Performance
3. Top 10 Best Selling Products
4. Discount and Price Erosion Analysis
5. Country and Regional Performance
6. Retailer Type and Channel Analysis
7. Top 10 Retailers by Revenue
8. Order Method Breakdown
9. Digital vs Traditional Channel Trend
10. Seasonality Analysis by Month
11. Product Line vs Country Cross Analysis
12. Slow Moving and Low Revenue Products
13. Retailer Cohort New vs Returning
14. Day of Week Sales Pattern

### KPIs calculated in master query:
| KPI | Field | Description |
|-----|-------|-------------|
| Total Revenue | total_revenue | SUM of Quantity × sale price |
| Total Cost | total_cost | SUM of Quantity × unit cost |
| Gross Profit | gross_profit | Revenue minus Cost |
| Profit Margin % | profit_margin_pct | Profit / Revenue × 100 |
| Avg Order Value | avg_order_value | AVG revenue per transaction |
| Avg Sale Price | avg_sale_price | AVG unit sale price |
| Avg Discount % | avg_discount_pct | AVG discount percentage |
| Avg Profit Per Unit | avg_profit_per_unit | AVG profit per unit sold |
| Total Units | total_units | SUM of all quantities |
| Total Transactions | total_transactions | COUNT of all orders |
| Active Retailers | num_retailers | COUNT DISTINCT retailers |

### Tier Classifications added:
| Tier | Values |
|------|--------|
| discount_tier | No discount / Low 1-10% / Medium 11-25% / High 25%+ |
| margin_tier | High margin / Medium margin / Low margin |
| order_size_tier | Bulk / Large / Medium / Small |
| channel_type | Digital / Traditional / Field Sales |
| region | Europe / North America / East Asia / South Pacific / South America |

---

## Stage 3 — Data Studio Dashboard

### What I did in Data Studio:
- Connected BigQuery master query directly to Data Studio
- Built 5 stakeholder dashboard pages
- Added cross filtering — click any chart to filter all others
- Added YTD scorecards with Year on Year comparison
- Shared with team using Owner credentials

### Dashboard Pages:
| Page | Audience | Key charts |
|------|----------|-----------|
| CEO Overview | Sabah CEO | YTD Revenue, Profit, Top Products, Channels |
| European Expansion | Leadership | Country revenue, GDP analysis, new markets |
| Retailer Connections | Head of Retail | Top retailers, retailer types, order sizes |
| Marketing | Marketing Manager | Seasonality, brands, channels, discounts |
| CFO Finance | CFO | Cost, margin, discount, profit analysis |

### Filter Controls on every page:
- Date range control
- Year dropdown
- Month dropdown
- Product line dropdown
- Country dropdown
- Channel type dropdown
- Region dropdown

---

## Business Goals
- Track revenue, profit and growth KPIs
- Identify top performing products and markets
- Analyze European expansion opportunities
- Compare digital vs traditional sales channels
- Enable non-technical users to explore data independently

---

## Tech Stack
| Tool | Purpose |
|------|---------|
| Google Sheets | Data exploration and BigQuery connection |
| Google BigQuery | Data warehouse and SQL queries |
| SQL CTEs | Data transformation and KPI calculation |
| Google Data Studio | Interactive self-service dashboard |

---

## Data Sources
- daily_sales — 149,257 transaction records
- Products — 244 products across 5 product lines
- Retailers — 289 retailers across 21 countries
- Methods — 7 order methods (Web, Phone, Email etc)

---

## Key KPIs Built
- Total Revenue — €1.25bn
- Gross Profit — €527.73m
- Profit Margin % — 43.84%
- Units Sold — 19.8m
- YTD Revenue with YoY comparison
- Digital vs Traditional channel split
- Top 10 products and countries

---

## Dashboard Link
[View Live Dashboard - 1](https://datastudio.google.com/u/1/reporting/44010cef-2ff6-479b-995a-5d755367fe29/page/tEnnC/edit)
[View Live Dashboard - 2](https://datastudio.google.com/u/0/reporting/348b25c2-b761-46ae-80b2-4a8a883c745d/page/QGq6F)

---

## Key Insights
- Web channel dominates at 72.7% of all orders
- USA is top market at €197M revenue
- Personal Accessories is highest selling product line
- Europe contributes 45% of total revenue
- Golf Equipment has highest profit margin at 47.6%
- Tuesday and Monday are highest revenue days
- February is peak revenue month

---

## What I Learned
- How to connect Google Sheets to BigQuery
- How to write complex SQL using CTEs
- How to join multiple tables in one master query
- How to calculate business KPIs using SQL
- How to build interactive dashboards in Data Studio
- How to share dashboards with owner credentials
- How to think like a data analyst — asking business questions first

---

## Author
Shyam Sunder Chiliveri
WBS Coding School — IT Specialist for Data Science & Artificial Intelligence
August 2026

---

## Screenshots

### Page 1 — CEO Overview
![CEO Overview]<img width="637" height="1152" alt="Overview" src="https://github.com/user-attachments/assets/7dea0ea3-5795-4650-8d40-1200e3e52f6f" />


### Page 2 — European Expansion
![European Expansion]<img width="1211" height="897" alt="European Expansion" src="https://github.com/user-attachments/assets/fcc0f128-b47d-4c09-a3a3-ca337c2826f1" />


### Page 3 — Retailer Connections
![Retailer Connections]<img width="1184" height="1161" alt="Retailer Connections" src="https://github.com/user-attachments/assets/0d3fe10e-ac07-4929-ac36-258abb22f6a4" />


### Page 4 — Marketing
![Marketing]<img width="1284" height="1167" alt="Marketing" src="https://github.com/user-attachments/assets/e9c021f6-e94c-4a23-aac2-072bd180c2d2" />

### Page 5 — CFO Finance
![CFO Finance]<img width="1249" height="1161" alt="Finance" src="https://github.com/user-attachments/assets/59a6c954-039e-4fde-91fd-f11711df9f47" />

