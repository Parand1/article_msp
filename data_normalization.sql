CREATE OR REPLACE TABLE `airy-runway-450418-q9.warehouse.egresosnor`
     PARTITION BY fecha_egr_dt
     CLUSTER BY sector_normalizado, cie10_codigo
     AS
     SELECT
       CASE
         WHEN cod_edad LIKE 'Años%' THEN SAFE_CAST(edad AS INT64) * 365
        WHEN cod_edad LIKE 'Meses%' THEN SAFE_CAST(edad AS INT64) * 30
        WHEN cod_edad LIKE 'Días%' THEN SAFE_CAST(edad AS INT64)
        ELSE NULL
      END AS edad_en_dias,
   
      SPLIT(cau_cie10, ' ')[OFFSET(0)] AS cie10_codigo,
   
      CASE
        WHEN sector = 'Público' THEN 'Público'
        WHEN sector LIKE 'Privado%' THEN 'Privado'
        ELSE 'Otro'
      END AS sector_normalizado,
   
      SAFE_CAST(dia_estad AS INT64) AS dias_estancia,
      SAFE_CAST(fecha_ingr AS DATE) AS fecha_ingr_dt,
      SAFE_CAST(fecha_egr AS DATE) AS fecha_egr_dt,
   
      sexo,
      etnia,
      prov_res,
      cant_res,
      parr_res,
      tipo_seg,
      con_egrpa,
      esp_egrpa,
   
      cau_cie10,
      causa3,
      cap221rx,
      cau221rx,
      cau298rx,
   
      prov_ubi,
      cant_ubi,
      parr_ubi,
      clase,
      tipo,
      entidad
   
    FROM
     `airy-runway-450418-q9.warehouse.egresos`
    WHERE
   
      dia_estad IS NOT NULL AND SAFE_CAST(dia_estad AS INT64) >= 0 
      AND fecha_egr IS NOT NULL
      AND cau_cie10 IS NOT NULL
      AND sector IS NOT NULL AND sector IN ('Público', 'Privados con fines de lucro', 'Privados sin fines de lucro');