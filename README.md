# Retail Customer Analytics & RFM Segmentation

An end-to-end data analytics project that cleans, models, and segments over 390,000 online retail transaction records using **Python**, **SQL**, and **Power BI**. This project transforms raw e-commerce data into a behavior-based **Recency, Frequency, Monetary (RFM)** model to drive targeted customer retention strategies and optimize marketing spend.

---

## 📌 Project Overview

In e-commerce and retail, treating all customers identically leads to inefficient marketing spend and increased customer churn. This project addresses that business challenge by engineering an automated analytics pipeline that:
1. Cleans and validates raw e-commerce transactional data.
2. Calculates customer-level RFM metrics using database-level window functions.
3. Classifies customers into actionable behavioral segments (e.g., Champions, At-Risk, Loyalists).
4. Delivers an interactive Power BI dashboard for executive reporting and campaign triggers.

---

## 🛠️ Architecture & Tech Stack
Raw CSV (390k+ Rows) ]
│
▼
[ Python (Google Colab / Pandas， Numpy) ] ──► Data Cleaning, Deduplication & Datetime Standardisation
│
▼
[ SQL (ipython-sql) ]         ──► Aggregations, CTEs & NTILE(5) Quantile Scoring
│
▼
[ Power BI Dashboard ]            ──► Measure-Driven Dynamic Visual Analytics
* **Data Wrangling & Validation:** Python (Pandas, NumPy, Google Colab)
* **Database Modeling & Analytics:** SQL (Common Table Expressions, `NTILE(5)` Window Functions)
* **Business Intelligence & Reporting:** Power BI Desktop (DAX, Interactive Dashboards)
* **Documentation & Web Portfolio:** Markdown, GitHub, Custom Web Portfolio

---

## 🚀 Data Processing Pipeline

### 1. Data Cleaning & Preparation (Python)
* Ingested 390k+ rows of raw transactional data.
* Handled missing customer IDs, stripped whitespace, and removed negative/invalid quantities and prices (returns/cancellations).
* Standardised timestamp object formats into standard SQL-compatible date structures.

### 2. RFM Calculation & Quantile Scoring (SQL)
Using Common Table Expressions (CTEs) and window functions, raw customer transactions were aggregated to calculate core RFM values relative to a fixed snapshot date:

$$\text{Recency} = \text{Snapshot Date} - \max(\text{Invoice Date})$$
$$\text{Frequency} = \text{Count of Unique Invoices}$$
$$\text{Monetary} = \sum (\text{Quantity} \times \text{Unit Price})$$

Quantile scoring ($1$ to $5$) was assigned using `NTILE(5)`:
* **Recency Score ($R$):** $5$ = Most Recent, $1$ = Longest Inactive.
* **Frequency Score ($F$):** $5$ = Top 20% Order Volume, $1$ = Single Order.
* **Monetary Score ($M$):** $5$ = Top 20% Spenders, $1$ = Lowest Spend.

```sql
WITH Raw_Metrics AS (
    SELECT 
        CustomerID,
        CAST(JULIANDAY((SELECT MAX(InvoiceDate) FROM orders)) - JULIANDAY(MAX(InvoiceDate)) AS INT) AS Recency,
        COUNT(DISTINCT InvoiceNo) AS Frequency,
        ROUND(SUM(Quantity * UnitPrice), 2) AS Monetary
    FROM orders
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
),
RFM_Scores AS (
    SELECT 
        CustomerID,
        Recency,
        Frequency,
        Monetary,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score
    FROM Raw_Metrics
)
SELECT 
    CustomerID,
    Recency,
    Frequency,
    Monetary,
    R_Score,
    F_Score,
    M_Score,
    (CAST(R_Score AS TEXT) || CAST(F_Score AS TEXT) || CAST(M_Score AS TEXT)) AS RFM_Cell
FROM RFM_Scores;

📊 Key Insights & Business Impact
The 80/20 Rule in Action: Champions and Loyal Customers make up under 20% of the total customer base but generate over 60% of total revenue.

Churn Warning: Identified a high-value cluster of historically big spenders transitioning into the At-Risk segment due to decaying Recency scores.

Targeted Marketing Triggers:

Champions (555, 554): Exclusive VIP perks, early product access, and referral incentives.

At-Risk (255, 155): Automated re-engagement campaigns and win-back discount codes.

Potential Loyalists (432, 523): Upsell recommendations and loyalty program enrollment.

🌐 Live Portfolio & Contact
Explore the interactive Power BI dashboard and complete case study on my web portfolio:

Live Demo & Portfolio: sites.google.com/view/yancong-tian-portfolio/home)

GitHub Repository: github.com/xyzplanet/

LinkedIn: linkedin.com/in/yancong-tian-79326858/)

