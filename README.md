# E-Commerce Business Analytics

**SQL | PostgreSQL | Excel | Power Query | Power Pivot | Business Intelligence**

![Executive Summary Dashboard](screenshots/01_executive_summary.png)

## 📊 Project Overview

This project analyzes 100,000 e-commerce order-level records to evaluate sales performance, profitability, discount exposure, regional and category performance, and customer/order behavior.

The analysis combines PostgreSQL/pgAdmin and Excel-based analytics to transform transactional data into an executive dashboard and actionable business recommendations.

## 🎯 Business Problem

The objective is to understand:

- How the business is performing in terms of sales and profit
- How discounting is associated with profit margin
- Which regions and categories contribute most to sales
- Which sub-categories require profitability or discount review
- Where management should focus to improve profitability

The final analysis is designed to support **data-driven pricing, discount governance, and product-level business decisions**.

## 🗂️ Dataset

The project is based on **100,000 e-commerce order-level records** containing information related to orders, products, customers, locations, dates, sales, discounts, and profit.

### Data Model

The analytical model uses a star-style structure:

- **Fact Orders** — transactional measures such as Sales, Profit, Quantity, Discount, Order Date, Product ID, and Location ID
- **Dim Products** — product category and sub-category information
- **Dim Dates** — date, month, year, quarter, and day-of-week attributes
- **Dim Locations** — region, city type, outlet type, and location attributes
- **Customer Orders** — order-to-customer information used for customer and segment analysis

The Excel Data Model connects the fact table to the relevant dimension tables to support consistent reporting and dashboard analysis.

### Data Source

The original dataset is included in the repository under:

`data/raw/store_sales_data.csv`

The processed analytical tables are stored under:

`data/processed/`

## 🛠️ Tools & Technologies

- **PostgreSQL / pgAdmin** — data storage, SQL analysis, joins, aggregations, window functions, and analytical views
- **Excel** — dashboard development and business reporting
- **Power Query** — data preparation and transformation
- **Power Pivot / Data Model** — relational data modeling and analytical calculations
- **Git / GitHub** — project version control and portfolio documentation

## 🔄 Analytical Approach

The project follows a structured analytics workflow:

1. **Data Preparation**  
   Prepared the transactional and dimensional datasets for analysis.

2. **SQL Analysis**  
   Used PostgreSQL/pgAdmin to calculate baseline KPIs and investigate regional, category, sub-category, discount, customer, and segment performance.

3. **Data Modeling**  
   Built a relational Excel Data Model connecting the fact table with product, date, and location dimensions.

4. **Business Analysis**  
   Evaluated sales, profit, profit margin, discount exposure, AOV, and performance patterns across key business dimensions.

5. **Dashboard Development**  
   Built a four-page Excel dashboard focused on executive performance, regional/category analysis, discount profitability, and business opportunities.

6. **Business Recommendations**  
   Converted the analytical findings into practical recommendations around discount governance, low-margin products, and protecting stronger-margin areas.

   ## 📈 Key Business Findings

### 1. Strong Overall Business Performance

The business generated **₹250.84 Cr in sales** and **₹37.55 Cr in profit**, resulting in an overall **14.97% profit margin** across 100,000 orders.

### 2. Significant Discount Exposure

Total discount exposure amounts to **₹63.04 Cr**, with an average discount of **25.13%** across orders. This makes discount governance an important area for profitability management.

### 3. Profit Margin Declines at Higher Discount Levels

Profit margin decreases from **19.83% at 0% discount** to **10.08% at 50% discount**, representing a **9.75 percentage-point decline**.

This indicates an observed association between higher discount levels and lower profit margins; the analysis does not establish a causal relationship.

### 4. Performance Is Relatively Balanced Across Regions and Categories

Regional and category performance shows limited variation. Regional profit margins range from approximately **14.91% to 15.03%**, indicating that broad regional reallocation is less significant than targeted profitability and discount management.
## 💡 Business Recommendations

### 1. Tighten Discount Governance

Review discount thresholds and promotional controls, particularly where higher discount levels coincide with weaker profit margins. Use margin impact as a key consideration when evaluating promotions.

### 2. Review Lower-Margin Sub-Categories

Prioritize a deeper review of **Tables (14.82% margin)** and **Washing Machines (25.37% average discount)**. Management should evaluate pricing, sourcing, and promotional strategy before making changes.

### 3. Review High-Discount Products

**Tomatoes (25.70% average discount)** should be reviewed to understand whether the level of discounting is justified by its commercial performance and profitability.

### 4. Protect Stronger-Margin Performance

Use stronger-margin areas such as **Microwaves (15.22% margin)** as internal profitability benchmarks and avoid unnecessary discounting where margins are already relatively strong.
## 📊 Dashboard

The final dashboard is organized into four analytical pages, moving from executive performance monitoring to detailed profitability analysis and business action.

### 01 — Executive Summary

Provides a high-level view of:

- Total Sales
- Total Profit
- Profit Margin
- Discount Amount
- Yearly Sales & Profit trends
- Key business findings
- Management focus areas

### 02 — Regional & Category Performance

Analyzes sales performance across:

- Regions
- Product categories
- Region–category combinations
- Top-performing combinations
- Lower-performing combinations

### 03 — Discount & Profitability Deep Dive

Focuses on the relationship between discount levels and profitability, including:

- Profit margin by discount level
- Profit margin trend over time
- The 9.75 percentage-point margin decline from 0% to 50% discount

### 04 — Business Opportunities & Action Plan

Converts the analysis into management actions through:

- Discount exposure and average discount KPIs
- Priority sub-category review
- Management priorities
- Discount governance recommendations
- Low-margin product review
- Strong-margin protection
### Dashboard Preview

#### Executive Summary

![Executive Summary Dashboard](screenshots/01_executive_summary.png)

#### Regional & Category Performance

![Regional & Category Dashboard](screenshots/02_regional_category.png)

#### Discount & Profitability Deep Dive

![Discount & Profitability Dashboard](screenshots/03_discount_profitability.png)

#### Business Opportunities & Action Plan

![Business Opportunities Dashboard](screenshots/04_business_opportunities.png)

## 📁 Project Structure

```text
ecommerce-business-analytics/
│
├── README.md
│
├── data/
│   ├── raw/
│   │   └── store_sales_data.csv
│   │
│   └── processed/
│       ├── fact_orders.csv
│       ├── dim_products.csv
│       ├── dim_dates.csv
│       └── dim_locations.csv
│
├── sql/
│   └── Master_sql_pgadmin.sql
│
├── excel/
│   └── ecommerce_business_analytics.xlsx
│
├── docs/
│   ├── methodology.md
│   ├── business_insight_report.pdf
│   └── linkedin_post.md
│
├── screenshots/
│   ├── 01_executive_summary.png
│   ├── 02_regional_category.png
│   ├── 03_discount_profitability.png
│   └── 04_business_opportunities.png
│
└── .gitignore
## 🔬 Methodology

The analysis follows a relational and business-focused workflow:

1. Transactional data was organized into a fact table and supporting dimension tables.
2. PostgreSQL/pgAdmin was used for SQL-based data analysis, joins, aggregations, window functions, and analytical views.
3. Excel Power Query was used for data preparation and transformation.
4. An Excel Data Model / Power Pivot structure was used to connect the fact and dimension tables.
5. Business metrics were calculated and used to build the four-page dashboard.
6. Findings were translated into management-focused recommendations.

### Key Metric Definitions

**Profit Margin**

`Total Profit ÷ Total Sales × 100`

**Average Discount**

`Average of the Discount field across order records`

**Discount Amount**

`SUM(Sales × Discount)`

**Average Order Value (AOV)**

`Total Sales ÷ Distinct Orders`

## ⚠️ Analytical Limitations

- The dataset is observational; therefore, the relationship between discounting and profit margin should be interpreted as an **association rather than a causal effect**.
- Regional and category performance is relatively balanced, so differences between these groups should not be overstated.
- The analysis does not estimate how sales volume would change if discount levels were increased or decreased.
- Therefore, the project does not present a projected profit impact from changing discount policies without additional assumptions or experimentation.
## 🚀 How to Reproduce

1. Load the source dataset from `data/raw/`.
2. Review the processed analytical tables in `data/processed/`.
3. Run the SQL analysis in `sql/Master_sql_pgadmin.sql` using PostgreSQL/pgAdmin.
4. Open `excel/ecommerce_business_analytics.xlsx` to review the Excel Data Model and dashboard.
5. Refer to `docs/business_insight_report.pdf` for the one-page executive summary.

## 📦 Project Deliverables

- **Excel Dashboard** — Four-page interactive business analytics dashboard
- **PostgreSQL / SQL Analysis** — Business analysis performed in pgAdmin
- **Business Insight Report** — One-page executive management report
- **Methodology Documentation** — Data model, metrics, analytical approach and limitations
- **Dashboard Screenshots** — Visual previews of all four dashboard pages
- **LinkedIn Post Draft** — Portfolio-ready project announcement

## 👤 About This Project

This project was developed as a portfolio case study to demonstrate practical skills in **SQL, data modeling, Excel, Power Query, Power Pivot, dashboard development, and business analysis**.

The focus was not only on reporting metrics, but on translating analytical findings into **actionable business recommendations**.