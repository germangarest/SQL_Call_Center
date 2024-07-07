-- Creación de la tabla ivr_summary
CREATE TABLE keepcoding.ivr_summary AS
WITH
  -- CTE para los detalles de ivr_detail
  
  ivr_detail_details AS (
    SELECT
      calls_ivr_id AS ivr_id,
      MAX(calls_phone_number) AS phone_number,
      MAX(calls_ivr_result) AS ivr_result,
      MAX(calls_start_date_id) AS start_date,
      MAX(calls_end_date_id) AS end_date,
      SUM(calls_total_duration) AS total_duration,
      MAX(calls_customer_segment) AS customer_segment,
      MAX(calls_ivr_language) AS ivr_language,
      COUNT(DISTINCT calls_steps_module) AS steps_module,
      STRING_AGG(DISTINCT calls_module_aggregation, ', ') AS module_aggregation,
      MAX(document_type) AS document_type,
      MAX(document_identification) AS document_identification,
      MAX(customer_phone) AS customer_phone,
      MAX(billing_account_id) AS billing_account_id,
     
      -- Campo calculado vdn_aggregation
     
      CASE
        WHEN MAX(calls_vdn_label) LIKE 'ATC%' THEN 'FRONT'
        WHEN MAX(calls_vdn_label) LIKE 'TECH%' THEN 'TECH'
        WHEN MAX(calls_vdn_label) = 'ABSORPTION' THEN 'ABSORPTION'
        ELSE 'RESTO'
      END AS vdn_aggregation
    FROM keepcoding.ivr_detail
    GROUP BY calls_ivr_id
  ),
  
  -- CTE para los flags
  
  ivr_flags AS (
    SELECT
      calls_ivr_id AS ivr_id,
      MAX(CASE WHEN module_name = 'AVERIA_MASIVA' THEN 1 ELSE 0 END) AS masiva_lg,
      MAX(CASE WHEN step_name = 'CUSTOMERINFOBYPHONE.TX' AND step_description_error IS NULL THEN 1 ELSE 0 END) AS info_by_phone_lg,
      MAX(CASE WHEN step_name = 'CUSTOMERINFOBYDNI.TX' AND step_description_error IS NULL THEN 1 ELSE 0 END) AS info_by_dni_lg
    FROM keepcoding.ivr_detail
    GROUP BY calls_ivr_id
  ),
  
  -- CTE para llamadas repetidas
  
  ivr_repeated_calls AS (
    WITH
      parsed_calls AS (
        SELECT
          calls_ivr_id AS ivr_id,
          calls_phone_number,
          TIMESTAMP(PARSE_DATE('%Y%m%d', CAST(calls_start_date_id AS STRING))) AS parsed_start_date
        FROM keepcoding.ivr_detail
      ),
      lag_lead_calls AS (
        SELECT
          ivr_id,
          calls_phone_number,
          parsed_start_date,
          LAG(parsed_start_date) OVER (PARTITION BY calls_phone_number ORDER BY parsed_start_date) AS previous_start_date,
          LEAD(parsed_start_date) OVER (PARTITION BY calls_phone_number ORDER BY parsed_start_date) AS next_start_date
        FROM parsed_calls
      )
    SELECT
      ivr_id,
      
      -- Flags para llamadas repetidas
      
      CASE
        WHEN TIMESTAMP_DIFF(parsed_start_date, previous_start_date, HOUR) <= 24 THEN 1
        ELSE 0
      END AS repeated_phone_24H,
      CASE
        WHEN TIMESTAMP_DIFF(next_start_date, parsed_start_date, HOUR) <= 24 THEN 1
        ELSE 0
      END AS cause_recall_phone_24H
    FROM lag_lead_calls
  )

-- Combinar los resultados de las CTEs en ivr_summary

SELECT
  d.ivr_id,
  d.phone_number,
  d.ivr_result,
  d.start_date,
  d.end_date,
  d.total_duration,
  d.customer_segment,
  d.ivr_language,
  d.steps_module,
  d.module_aggregation,
  d.document_type,
  d.document_identification,
  d.customer_phone,
  d.billing_account_id,
  d.vdn_aggregation,
  f.masiva_lg,
  f.info_by_phone_lg,
  f.info_by_dni_lg,
  r.repeated_phone_24H,
  r.cause_recall_phone_24H
FROM ivr_detail_details d
LEFT JOIN ivr_flags f ON d.ivr_id = f.ivr_id
LEFT JOIN ivr_repeated_calls r ON d.ivr_id = r.ivr_id;