# Maritime-Vessel-Data-Analysis_Project
End to End  Maritime Vessel Data Quality/Integration &amp; Analytics Dashboard
Developed a comprehensive data pipeline and analytical solution for a global shipping dataset containing vessel specifications, ownership details, and builder information. Processed multiple CSV files (Vessels, Owners, and Decodes) to build a clean relational database and performed advanced time-series and aggregation analysis.

Key Tasks & Achievements:
1. Data Ingestion & Cleaning

Imported multiple raw CSV files into a SQLite relational database.
Handled erroneous/inconsistent data values (nulls, invalid dates, duplicates, data type mismatches) using Python (Pandas) for preprocessing.
Performed data validation, cleaning, and standardization before loading the full dataset.
Created normalized tables with proper primary/foreign keys using VesselId as the unique identifier.

2. Time-Series Analysis – Vessel Construction Trends

Built a yearly time-series query to count the number of vessels built per year based on the BuiltDate column.
Used VesselId for accurate unique counting.
Analyzed fleet growth patterns over time.

3. Ownership Analysis by Country

Aggregated total Deadweight Tonnage (DWT) by OwnerCountry.
Delivered insights on the dominant ship-owning nations by total carrying capacity.

4. Pivot Analysis – Builder Country Trends

Created a dynamic pivot table with:
Rows: Year (extracted from BuiltDate, sorted ascending)
Columns: BuilderCountry
Values: Count of unique vessels (VesselId)

Implemented both static pivot (using conditional aggregation) and dynamic pivot technique (without hardcoding column names) using SQL string concatenation and prepared statements / Python post-processing.

Technologies Used:

SQL-T-SQL – Data cleaning & ingestion
SQL  – Advanced querying, aggregation, time-series, and pivoting
Data cleaning for erroneous values
Relational database design
SSIS - Integration Task

-- 2. Vessels built per year (Time-series)
SELECT 
    strftime('%Y', BuiltDate) AS Year_Built,
    COUNT(DISTINCT VesselId) AS Vessel_Count
FROM Vessels
GROUP BY Year_Built
ORDER BY Year_Built ASC;

-- 3. Total DWT by Owner Country
SELECT 
    OwnerCountry,
    SUM(DWT) AS Total_DWT,
    COUNT(DISTINCT VesselId) AS Vessel_Count
FROM Vessels v
JOIN Owners o ON v.VesselId = o.VesselId
GROUP BY OwnerCountry
ORDER BY Total_DWT DESC;

-- 4. Pivot: Vessels by Build Year & Builder Country (Dynamic approach)
-- Static version example:
SELECT 
    strftime('%Y', BuiltDate) AS Year_Built,
    COUNT(CASE WHEN BuilderCountry = 'China' THEN VesselId END) AS China,
    COUNT(CASE WHEN BuilderCountry = 'South Korea' THEN VesselId END) AS South_Korea,
    ... 
FROM Vessels
GROUP BY Year_Built;
