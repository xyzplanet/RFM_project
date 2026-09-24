%%sql rfm_result <<
WITH Base_Data AS (
    SELECT 
        CustomerID,
        InvoiceNo,
        TotalAmount,
        -- Convert ISO date string to UNIX timestamp (seconds)
        strftime('%s', InvoiceDate) AS InvoiceTimestamp
    FROM stg_fact_sales
),
Max_Date AS (
    -- Retrieve the latest transaction timestamp across the entire dataset as the anchor date
    SELECT MAX(InvoiceTimestamp) AS MaxTimestamp FROM Base_Data
),
Customer_RFM AS (
    SELECT 
        b.CustomerID,
        -- Recency: Days since last purchase relative to the dataset snapshot date
        CAST((m.MaxTimestamp - MAX(b.InvoiceTimestamp)) / 86400.0 AS INTEGER) AS Recency,
        -- Frequency: Count of unique order IDs (InvoiceNo)
        COUNT(DISTINCT b.InvoiceNo) AS Frequency,
        -- Monetary: Total monetary spend per customer
        ROUND(SUM(b.TotalAmount), 2) AS Monetary
    FROM Base_Data b
    CROSS JOIN Max_Date m
    GROUP BY b.CustomerID
),
RFM_Scores AS (
    SELECT 
        CustomerID,
        Recency,
        Frequency,
        Monetary,
        -- NTILE(5) Scoring (1 to 5)
        -- Recency: Lower is better (more recent), so order DESC (smaller days get higher score)
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        -- Frequency & Monetary: Higher is better, so order ASC
        NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score
    FROM Customer_RFM
)
SELECT 
    CustomerID,
    Recency,
    Frequency,
    Monetary,
    R_Score,
    F_Score,
    M_Score,
    -- Concatenate scores into a 3-digit RFM segment string (e.g., '555', '111')
    (CAST(R_Score AS TEXT) || CAST(F_Score AS TEXT) || CAST(M_Score AS TEXT)) AS RFM_Segment
FROM RFM_Scores
ORDER BY Monetary DESC;