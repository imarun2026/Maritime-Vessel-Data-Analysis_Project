/* =============================================================================
   CLARKSONS RESEARCH – DATA ENGINEER SQL Task
   Database: ClarksonsDB
   Author  : Arun Kumar
   =============================================================================*/
   /*=======================Error Details============================*/
   --In some table to insert the data got an error 
   ----like type mismatch or invalid character for the specified codepage
   ----in data like 
   ----Some Date format in data i.e. dd-mm-yyyy but in sql yyyy-mm-dd
   ----Country name "Korea, South" it was treating as a seperate column
   ----BOM character — UTF-8 issues - its indicate header in the fist line of the heading 
/* ============================================================
   STEP 1 – CREATE THE DATABASE & TABLES
   ============================================================*/

   /* ============================================================
 Steps taken to solve the data quality issues
=================================================================*/
--In bulk insert task used FORMAT and CODEPAGE 
--to handle the double quotes which commented
--To handle the  date format  and country issues 
--performed cleaning process in staging table to store the data
--Then migrated into final table
 /*============================================================*/

-- USE ClarksonsDB;
--GO

--IF DATABASE NOT EXIST THEN DROP
IF DB_ID('ClarksonsDB') IS NOT NULL
    DROP DATABASE ClarksonsDB;
GO

CREATE DATABASE ClarksonsDB;
GO

--DDL Command syntax - Flags 

CREATE TABLE dbo.Flags (
    FlagCode   VARCHAR(10)  NOT NULL,
    Flag       VARCHAR(100) NOT NULL,
    FlagType   VARCHAR(50)  NOT NULL,
    CONSTRAINT PK_Flags PRIMARY KEY (FlagCode) ----PK to the parant table
);

--DDL Command syntax - Owners

CREATE TABLE dbo.Owners (
    OwnerId      INT          NOT NULL,
    Owner        VARCHAR(200) NOT NULL,
    OwnerCountry VARCHAR(100) NOT NULL,
    CONSTRAINT PK_Owners PRIMARY KEY (OwnerId) --Priamry key defined for the parent table
);

-- 1c. VesselTypes 
CREATE TABLE dbo.VesselTypes (
    VesselTypeCode      INT          NOT NULL,
    VesselType          VARCHAR(200) NOT NULL,
    VesselTypeClassCode INT          NOT NULL,
    VesselTypeClass     VARCHAR(100) NOT NULL,
    CONSTRAINT PK_VesselTypes PRIMARY KEY (VesselTypeCode) --PK to the parant table
);

CREATE TABLE dbo.Vessels (
    VesselId            INT             NOT NULL,
    VesselTypeCode      INT             NOT NULL,
    Dwt                 DECIMAL(18,2)   NULL,
    GT                  DECIMAL(18,2)   NULL,
    LOA_m               DECIMAL(10,3)   NULL,
    Draft_m             DECIMAL(10,3)   NULL,
    TEU                 INT             NULL,
    FlagCode            VARCHAR(10)     NULL,
    BuiltDate           DATE            NULL,
    Status              VARCHAR(50)     NULL,
    OwnerId             INT             NULL,
    BuilderId           INT             NULL,
    Builder             VARCHAR(200)    NULL,
    BuilderCountry      VARCHAR(100)    NULL,
    ContractDate        DATE            NULL,
    DemolitionDate      DATE            NULL,
    CONSTRAINT PK_Vessels
        PRIMARY KEY (VesselId) --PK to the parant table

    --CONSTRAINT FK_Vessels_VesselTypes --Taking Reference from the VessalType Table
    --    FOREIGN KEY (VesselTypeCode)          
    --    REFERENCES dbo.VesselTypes (VesselTypeCode) --Created seperately primary and FK with req. columns
);

--Adding  FK Keys to the child Tables for the reference

--ALTER TABLE Vessels
--ADD CONSTRAINT FK_Vessels_VesselTypes
--FOREIGN KEY (VesselTypeCode)          
--REFERENCES dbo.VesselTypes (VesselTypeCode)

ALTER TABLE Vessels
ADD CONSTRAINT FK_Vessels_Owners
FOREIGN KEY (OwnerId)
REFERENCES Owners(OwnerId);

ALTER TABLE Vessels
ADD CONSTRAINT FK_Vessels_Flags
FOREIGN KEY (FlagCode)
REFERENCES Flags(FlagCode);

--Insert the data into all tables with BULK INSERT TASK


BULK INSERT dbo.Vessels
FROM 'C:\Users\user\Downloads\dataassessmentforclarksonsresearch\Vessels.csv'
WITH (
    FORMAT          = 'CSV',        -- handles any double quoted fields
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    CODEPAGE        = '65001',      --To handle the conversion
	TABLOCK
);

--select GETDATE()--yymmdd

BULK INSERT dbo.Flags
FROM 'C:\Users\user\Downloads\dataassessmentforclarksonsresearch\Flags.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    TABLOCK
);

BULK INSERT dbo.Owners
FROM 'C:\Users\user\Downloads\dataassessmentforclarksonsresearch\Owners.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    TABLOCK
);


 --2. VesselTypes 
BULK INSERT dbo.VesselTypes
FROM 'C:\Users\user\Downloads\dataassessmentforclarksonsresearch\VesselTypes.csv'
WITH (
    FORMAT          = 'CSV',        -- Used to handle quotes
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    TABLOCK
);

--Vessel

BULK INSERT dbo.Vessels
FROM 'C:\Users\user\Downloads\dataassessmentforclarksonsresearch\Vessels_clean.csv'
WITH (
    FORMAT          = 'CSV',        -- handles any remaining quoted fields
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    CODEPAGE        = '65001',     --To handle 
    TABLOCK
);

 
   --TASK 1 – Calculate TIMESERIES: Count of Vessels per Built Year
   

SELECT
    YEAR(BuiltDate)      AS BuiltYear,
    COUNT(VesselId)      AS VesselCount
FROM dbo.Vessels
WHERE BuiltDate IS NOT NULL   
GROUP BY YEAR(BuiltDate)
ORDER BY BuiltYear ASC;
GO



   --TASK  – 3.	Create a query to get the aggregated total of DWT 
      --(use the data column "DWT") 
   --            per Owner Country, using the data column "OwnerCountry".
   -- Aggregated Total DWT per Owner Country
   

SELECT
    o.OwnerCountry,
    SUM(v.DWT)           AS TotalDWT --Deadweight Tonnage
FROM dbo.Vessels v
JOIN dbo.Owners  o ON v.OwnerId = o.OwnerId
GROUP BY o.OwnerCountry
ORDER BY TotalDWT DESC;
GO



   --TASK 4a.	Pivot the data from the dataset using the year 
			   --of the data in the column "BuiltDate" as the rows ascending, 
			   --and data column "BuilderCountry" as the columns, 
			   --count the number records (use the unique identifier in the data column "VesselId"). 
  

SELECT *
FROM (
    SELECT
        YEAR(BuiltDate)  AS BuiltYear,
        BuilderCountry,
        VesselId
    FROM dbo.Vessels
    WHERE BuiltDate IS NOT NULL
) AS src
PIVOT (
    COUNT(VesselId)
    FOR BuilderCountry IN (
        [Brazil],
        [China],
        [Croatia],
        [Denmark],
        [Finland],
        [France],
        [Germany],
        [Italy],
        [Japan],
        [Netherlands],
        [North Korea],
        [Norway],
        [Poland],
        [Romania],
        [Russia],
        [South Korea],
        [Spain],
        [Sweden],
        [Taiwan],
        [Turkey],
        [Ukraine],
        [United Kingdom],
        [United States]
    )
) AS pvt
ORDER BY BuiltYear ASC;
GO


--Declaring 2 variable to handle columns and query

DECLARE @countrycols NVARCHAR(MAX);
DECLARE @sqlquery  NVARCHAR(MAX);

--Getting the country name in the variable 
SELECT @countrycols =
    STRING_AGG(QUOTENAME(BuilderCountry), ',')
FROM (
    SELECT DISTINCT BuilderCountry
    FROM dbo.Vessels
    WHERE BuilderCountry IS NOT NULL
	--AND BuilderCountry <> 'Unknown' --Returning unknown country name
) t;

--Set the result set in the variable

SET @sqlquery ='
SELECT *
FROM
(
    SELECT BuilderCountry, VesselID
    FROM dbo.Vessels
) src
PIVOT
(
    COUNT(VesselID)
    FOR BuilderCountry IN ('+ @countrycols + ')
) p';

--Execute Final query
EXEC sp_executesql @sqlquery;


