# SQL_Call_Center

## IVR Data Analysis for Call Centers

## Summary

This repository contains SQL scripts and data sets for analyzing Interactive Voice Response (IVR) systems in a call center environment. The goal is to understand customer interactions and optimize IVR flow.

## Table of Contents
1. [Data model](#data-model)
   - [ivr_calls](#ivr_calls)
   - [ivr_modules](#ivr_modules)
   - [ivr_steps](#ivr_steps)
2. [Characteristics](#characteristics)
3. [ivr_detail table](#ivr_detail-table)
   - [Data source](#data-source)
   - Relationships](#relationships)
   - [Fields in ivr_detail](#fields-in-ivr_detail)
   - [Calculated fields in ivr_detail](#calculated-fields-in-ivr_detail)
4. [Table ivr_summary](#table-ivr_summary)
   - Purpose](#purpose)
   - Characteristics](#characteristics)
   - [Relationship to ivr_detail](#relationship-with-ivr_detail)
   - [Fields in ivr_summary](#fields-in-ivr_summary)
5. [Function clean_integer](#function-clean_integer)
   - Description](#description)
   - Usage](#usage)
   - BigQuery implementation](#implementation-in-bigquery)

## Data Model

The data model consists of the following tables:

### ivr_calls

| Field | Description |
|---------------------|--------------------------------------------------|
| ivr_id | Call Identifier |
| phone_number | Customer's telephone number |
| ivr_result | Result of the call |
| | vdn_label | VDN label |
| start_date | Start date of the call |
| end_date | end date of the call |
| total_duration | Total duration of the call |
| customer_segment | | customer segment |
| ivr_language | Language of the IVR |
| steps_module | Number of modules the call goes through | | module_aggregation | Number of modules the call goes through | module_aggregation | Number of modules the call goes through |
| | module_aggregation | List of modules through which the call goes |

| ivr_modules

| Field | Description |
|-----------------|----------------------------------------------|
| ivr_id | Call Identifier | |
| module_sequence | | Module sequence |
| module_name | Module Name |
| module_duration | Module duration | Module_result | Module result | Result
| module_result | Module Result | Module Result | Module Result

| ivr_steps

| Field | Description |
|-------------------------|---------------------------------------------------|
| | ivr_id | Call Identifier | |
| module_sequence | | module sequence |
| step_sequence | | step sequence |
| step_name | Step Name |
| step_result | Result of the step |
| step_description_error | Description of the step error |
| document_type | Type of client document |
| document_identification | Customer document identification | Customer_phone number | Customer_phone number | Customer_phone number | Customer_phone number | Customer_phone number | Customer_phone
| customer_phone | Customer's phone number | |
| billing_account_id | customer_account_id | billing_account_id | customer_account_id | billing_account_id | billing_account_id

| | billing_account_id | billing_account_id | customer_account_id

- Detailed analysis of IVR routing for each call
- Summary table with key performance indicators for each call
- Data cleansing functions for handling missing or erroneous data.

---

## ivr_detail table

The `ivr_detail` table is a derived table that is created from the `ivr_calls`, `ivr_modules` and `ivr_steps` tables of the `keepcoding` dataset. This table provides a unified view of IVR interactions, facilitating more complex analysis and reporting. The relationship between these tables is detailed below:

### Data Source

- **ivr_calls**: Contains data relating to calls made in the IVR system.
- **ivr_modules**: Contains data on the different modules a call goes through. This table is related to `ivr_calls` through the `ivr_id` field.
- ivr_steps**: Contains data on the specific steps that a user performs within a module. This table is related to `ivr_modules` through the `ivr_id` and `module_sequence` fields.

### Relationships

- `ivr_calls.ivr_id` relates to `ivr_modules.ivr_id`.
- `ivr_modules.ivr_id` and `ivr_modules.module_sequence` relate to `ivr_steps.ivr_id` and `ivr_steps.module_sequence`, respectively.

### Fields in ivr_detail

The fields in the `ivr_detail` table include all relevant fields from `ivr_calls`, `ivr_modules` and `ivr_steps`, allowing a detailed analysis of the user experience in the IVR system.

### Fields in ivr_detail

The `ivr_detail` table will consolidate data from the `ivr_calls`, `ivr_modules` and `ivr_steps` tables. Each field in the table is detailed below:

| Field | Source | Description |
|--------------------------|--------------|-------------------------------------------------------------|
| calls_ivr_ivr_id | ivr_calls | Unique call identifier |
| calls_phone_number | ivr_calls | ivr_calls | Customer's phone number |
| calls_ivr_result | ivr_calls | ivr_calls | Overall call result |
| calls_vdn_label | ivr_calls | VDN Label associated with the call |
| calls_start_date | ivr_calls | Date and time of call start |
| calls_start_date_id | ivr_calls | Start date identifier (yyyymmdd format) |
| calls_end_date | ivr_calls | Call end date and time |
| calls_end_date_id | ivr_calls | End Date Identifier (yyyymmdd format) |
| calls_total_duration | ivr_calls | Total duration of the call in seconds |
| calls_customer_segment | ivr_calls | Segment to which the customer belongs |
| calls_ivr_language | ivr_calls | Selected language in the IVR |
| calls_steps_module | ivr_calls | Number of modules through which the call passes |
| calls_module_aggregation | ivr_calls | List of modules through which the call is routed |
| module_sequence | ivr_modules | Order of occurrence of the module in the call |
| module_name | ivr_modules | Module name |
| module_duration | ivr_modules | Module Duration in seconds |
| module_result | ivr_modules | Module Result | module_result | module_result | module_result | module_result | module_result | module result
| step_sequence | ivr_steps | Order of appearance of the step in the module | step_name | ivr_name | step_sequence | ivr_steps | step_sequence | ivr_steps
| step_name | ivr_steps | Step name |
| step_result | ivr_steps | Result of the step |
| step_description_error | ivr_steps | Description of the error in the step, if applicable |
| document_type | ivr_steps | Type of client document |
| document_identification | ivr_steps | customer_identification | customer_phone | ivr_steps | document_identification | ivr_steps | customer document identification |
| customer_phone | ivr_steps | customer phone number |
| billing_account_id | ivr_steps | customer_account_id | ivr_steps | customer billing_account_id | ivr_steps | ivr_steps | customer billing account ID |

### Calculated fields in ivr_detail

#### calls_start_date_id and calls_end_date_id

These are calculated fields representing the start and end dates of calls, respectively, in a specific format (yyyymmdd).

| Field | Source | Description |
|--------------------|--------------|-----------------------------------------------------------------------------|
| calls_start_date_id| ivr_calls | Calculated identifier for the call start date. Format yyyymmdd. Example: `20230101` for 1 January 2023. |
| calls_end_date_id | ivr_calls | Calculated identifier for the end date of the call. Format yyyymmdd. Example: `20230101` for 1 January 2023. |

These fields are useful for performing time series analysis or for joining the `ivr_detail` table with other tables using a similar date format.

## Table ivr_summary

The `ivr_summary` table is a summarised version of the `ivr_detail` table and is created to facilitate quick analysis and reporting. This table focuses on the most important indicators for each call and therefore contains only one record per call.

### Purpose

The purpose of the `ivr_summary` table is to streamline the analysis of KPIs (Key Performance Indicators) and to provide a simplified view of call data. This is especially useful for stakeholders and analysts who need to quickly access key metrics without having to navigate through the large amount of detail in `ivr_detail`.

### Features

- One Record per Call**: Unlike `ivr_detail`, which can have multiple records for a single call based on different modules and steps, `ivr_summary` has a single record for each call.
  
- Key Indicators**: Includes fields such as `ivr_id`, `phone_number`, `ivr_result`, `total_duration`, `customer_segment`, and others that are critical for IVR system performance analysis.

### Relationship to ivr_detail

The `ivr_summary` table is derived from the `ivr_detail` table and can be created by aggregation queries that summarise the relevant fields of `ivr_detail` into a single record by `ivr_id`.

### Fields in ivr_summary

The table `ivr_summary` contains the following fields:

| Field | Source | Description |
|--------------------------|--------------|-----------------------------------------------------------------------------------------------------------------------|
| ivr_id | ivr_detail | Unique caller id |
| phone_number | ivr_detail | Customer's phone number |
| ivr_result | ivr_detail | ivr_result | ivr_result | ivr_detail | overall call result |
| ivr_detail | vdn_aggregation | ivr_detail | Generalisation of the `vdn_label` field (FRONT for ATC, TECH for TECH, ABSORPTION for ABSORPTION, RESTO for others) |
| start_date | ivr_detail | Date and time of start of call |
| end_date | ivr_detail | Date and time of end of call |
| total_duration | ivr_detail | Total duration of the call in seconds |
| customer_segment | ivr_detail | customer segment |
| ivr_language | ivr_detail | Selected language in the IVR |
| steps_module | ivr_detail | Number of modules through which the call passes |
| module_aggregation | ivr_detail | List of modules through which the call is routed |
| document_type | ivr_detail | Client's document type, if available |
| document_identification | ivr_detail | customer document identification, if available |
| customer_phone | ivr_detail | Customer's phone number, if available |
| billing_account_id | ivr_detail | Customer's billing account ID, if available |
| massive_lg | ivr_detail | Flag indicating if the call went through the 'MASSIVE_HURT' module (1 for yes, 0 for no) | |
| info_by_phone_lg | ivr_detail | Flag indicating if the customer was identified by his phone number (1 for yes, 0 for no) | info_by_phone_lg | ivr_detail | Flag indicating if the customer was identified by his phone number (1 for yes, 0 for no) |
| info_by_dni_lg | ivr_detail | Flag indicating if the customer was identified by his DNI (1 for yes, 0 for no) | info_by_dni_lg | ivr_detail | Flag indicating if the customer was identified by his DNI (1 for yes, 0 for no) |

Each of these fields is extracted or calculated from the data in the `ivr_detail` table, allowing for easier and more focused analysis of key IVR system performance metrics.

### Additional fields in ivr_summary

| Field | Source | Description |
|-----------------------|--------------|----------------------------------------------------------------------------------------------------------------|
| ivr_phone_24H | ivr_detail | A flag (0 or 1) indicating whether the same number has made a call in the previous 24 hours.          |
| cause_recall_phone_24H| ivr_detail | A flag (0 or 1) indicating whether the same number has made a call within 24 hours.         |


## clean_integer function

### Description

The `clean_integer` function is a data cleaning utility designed to handle `null` integer values in our database tables. If the function receives a `null` value, it returns -999999 as the default value. This convention is especially useful for maintaining data integrity and facilitating further analysis.

### Usage

The function can be used in SQL queries to replace `null` values in integer columns, as follows:

````sql
SELECT clean_integer(integer_column) FROM table_name;
```

### Implementation in BigQuery
The implementation of this function in BigQuery could be something similar to:

````sql
CREATE OR REPLACE FUNCTION dataset_name.clean_integer(input INT64) AS (
  IFNULL(input, -999999)
);
```

To use this function in your queries within the same dataset, you simply call it as ``clean_integer(your_integer_column)`.

By using this function in your queries, you can be sure that any null value will be replaced with the value `-99999999`, thus facilitating analysis and avoiding potential errors related to the lack of handling `null` values.











