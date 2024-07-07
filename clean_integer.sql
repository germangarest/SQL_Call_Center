CREATE OR REPLACE FUNCTION keepcoding.clean_integer(input INT64) AS (
  IFNULL(input, -999999)
);

--- SELECT clean_integer(columna_entera) FROM nombre_tabla;