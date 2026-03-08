# British-Airlines-EDA-Project
In this project we have explored the monthly surveillance, flight activity frequency and customer reviews and rating of the British Airlines bulk dataset using MySQL as local data repository to store the raw CSV files and the data transformation have been done with Python and SQL queries. Transformed data is then visualized using PowerBI.

This project analyzes airline operational performance, customer satisfaction, and booking behavior using:

- Dataset Source: Kaggle Airline Dataset
- Database: MySQL
- BI Tool: Power BI
- Sampling & Processing: Python
- Data Cleaning & Transformation: SQL

The goal is to build a structured database model, clean and standardize raw data, perform exploratory data analysis (EDA), and generate meaningful insights through an interactive Power BI dashboard.

## Data Architecture & Workflow
### Step 1 – Data Import
- Imported all raw CSV files into MySQL.
- Designed relational schema by identifying key relationships between tables.
- Created proper database model for reporting.

### Step 2 – Staging Strategy
- Created staging copies of all tables.
- Ensured raw data integrity.
- Prevented accidental data loss during cleaning.

## Data Cleaning & EDA Process
### Removing Duplicates
- Used ROW_NUMBER() window function to identify duplicates.
- Removed duplicates where a unique identifier existed.
- Customer comment duplicates were reviewed but retained if non-critical.

### Standardizing Data
- Cleaned inconsistent categorical values.
- Ensured consistent naming (e.g., Cabin categories).
- Converted textual dates using: (SQL) => STR_TO_DATE(column_name, '%m%d%Y')
- Ensured proper MySQL DATE formatting (yyyy-mm-dd).

### NULL & Invalid Value Handling
NULL handling was decided based on business impact.

📌 Survey Data – Inflight Satisfaction
| Column                | Action Taken                                     |
| --------------------- | ------------------------------------------------ |
| score                 | 11k NULL/invalid (not imported – retained as is) |
| cabin_name            | Replaced by cabin_code_desc                      |
| entity                | Removed 3 NULL records                           |
| loyalty_program_level | NULL → Assumed Non-member                        |
| departure_gate        | Left as is                                       |
| arrival_gate          | Left as is                                       |

📌 Customer Comment Table
| Column                | Action                       |
| --------------------- | ---------------------------- |
| loyalty_program_level | NULL → Replaced with 'Guest' |
| verbatim_text         | Not altered                  |
| transformed_text      | Not altered                  |

Power BI handles NULL values efficiently for reporting.

## Sampling Strategy (Passenger Booking Table)
Passenger Booking dataset was large. To optimize performance:

Sampling Methods Evaluated

- Simple Random Sampling (SRS)
Easy but may distort distribution.
- Stratified Sampling (Selected Approach)
Preserves data distribution and reduces loss of rare categories.

Stratified sampling was implemented using Python.

Selection criteria considered:

- Numerical skewness
- Categorical skewness
- Rare booking recovery
- Distribution preservation

## Key Features Used in Dashboard
### Survey Data – Satisfaction Analysis

- Score
- Satisfaction Type
- Arrival Delay Minutes
- Cabin Code Description
- Generation
- International/Domestic Indicator
- Loyalty Program Level
- Response Group

### Customer Comment Analysis

- Scheduled Departure Date
- Arrival/Departure Delay Groups
- Entity (Region)
- Fleet Type
- Sentiment
- Loyalty Level

### Passenger Booking Insights
- Sales Channel
- Trip Type
- Flight Duration
- Flight Day
- Booking Origin
- Extra Baggage Preference
- Preferred Seat
- Booking Completion Status

## DAX & Calculated Measures
### Custom measures were created for:

- Customer benefits calculation
- Trip type frequency
- KPI aggregation
- Dynamic filtering
- Performance indicators

### DAX best practices followed:

- Proper filter context
- String comparison with single quotes
- Column referencing standards

## Dashboard Structure (Power BI)
### Page 1 – Performance Analysis
- Total Trips KPI
- Reviews Received
- Delay vs On-time Ratio
- Cabin Class Distribution
- Satisfaction Breakdown
- Daily Flight Trend
- Generational Customer Analysis (Tree Map)

### Page 2 – Customer Feeds

- Sentiment Analysis
- Loyalty vs Feedback
- Delay Group Analysis
- Fleet Performance Insights

## Design & UI

- Primary Theme Colors: (Cyan: #20E2D7) (Dark Cyan: #10789E)
- Tree Map used for generation classification.
- Page Navigator for structured navigation.
- Clean KPI cards and category matrices.

## Key Business Insights

- Majority of passengers fall under Economy cabin.
- Loyalty segmentation impacts satisfaction levels.
- Certain generations show stronger brand loyalty.
- Delay patterns vary by region and flight type.
- Trip type frequency highlights dominant customer behavior.

## Technical Challenges Faced
- MySQL NULL import issues
- Date formatting inconsistencies
- Handling large booking dataset
- Distribution-preserving sampling
- Data modeling between multiple fact tables

## Future Improvements
- Full delay vs on-time ratio calculation (requires total flight count dataset)
- Deep sentiment scoring model integration
- Automated ETL pipeline
- Advanced predictive delay analysis
- Customer churn risk modeling

# Conclusion and Project Outcomes:
This project demonstrates a complete end-to-end data analytics workflow, starting from raw dataset ingestion to delivering actionable insights through an interactive business intelligence dashboard. The work involved designing a relational database in MySQL, performing structured data cleaning and exploratory data analysis (EDA), applying appropriate sampling techniques for large datasets, and building analytical visualizations using Power BI.
