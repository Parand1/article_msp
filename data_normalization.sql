--NORMALIZACION Y LIMPIEZA DE DATOS:
CREATE OR REPLACE TABLE `airy-runway-450418-q9.warehouse.egresosnor`
     PARTITION BY fecha_egr_dt
     CLUSTER BY sector_normalizado, cie10_codigo
     AS
     SELECT
    --1. ENRIQUECIMIENTO: Estandarización de la Edad a días
       CASE
         WHEN cod_edad LIKE 'Años%' THEN SAFE_CAST(edad AS INT64) * 365
        WHEN cod_edad LIKE 'Meses%' THEN SAFE_CAST(edad AS INT64) * 30
        WHEN cod_edad LIKE 'Días%' THEN SAFE_CAST(edad AS INT64)
        ELSE NULL
      END AS edad_en_dias,
   
      -- 2. ENRIQUECIMIENTO: Extracción del código CIE-10 puro
      SPLIT(cau_cie10, ' ')[OFFSET(0)] AS cie10_codigo,
   
      -- 3. LIMPIEZA: Normalización del Sector (CORREGIDO)
      CASE
        WHEN sector = 'Público' THEN 'Público'
        WHEN sector = 'Privado con fines de lucro' THEN 'Privado'
        WHEN sector = 'Privado sin fines de lucro' THEN 'Privado' -- Corregido para agrupar ambos tipos de privados
        ELSE 'Otro'
      END AS sector_normalizado,
   
      -- 4. CASTING SEGURO: Conversión de tipos de datos
      SAFE_CAST(dia_estad AS INT64) AS dias_estancia,
      SAFE_CAST(fecha_ingr AS DATE) AS fecha_ingr_dt,
      SAFE_CAST(fecha_egr AS DATE) AS fecha_egr_dt,
   
      -- 5. SELECCIÓN DE COLUMNAS RELEVANTES
      sexo,
      etnia,
      prov_res,
      con_egrpa,
      cau_cie10,
      sector -- Mantenemos el sector original para verificación
   
    FROM
      `airy-runway-450418-q9.warehouse.egresos`
    WHERE
      -- Filtro de calidad de datos (CORREGIDO)
      SAFE_CAST(dia_estad AS INT64) >= 0
      AND fecha_egr IS NOT NULL
      AND cau_cie10 IS NOT NULL
      AND con_egrpa IS NOT NULL
      AND sector IN ('Público', 'Privado con fines de lucro', 'Privado sin fines de lucro');