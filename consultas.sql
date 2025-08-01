-- JUSTIFICACION Y CONTEO DE CASOS MAS COMUNES DE CIRUGIAS EN ECUADOR 2024
SELECT
       cau_cie10,
       COUNT(*) AS numero_de_casos
     FROM
       warehouse.egresosnor
     WHERE
       cie10_codigo LIKE 'K%' -- Capítulo de Enf. del Sist. Digestivo (Apendicectomía, Colecistectomía)
       OR cie10_codigo LIKE 'O%' -- Capítulo de Embarazo, parto y puerperio (Cesárea)
    GROUP BY
      cau_cie10
    ORDER BY
      numero_de_casos DESC
    LIMIT 20;


--JUSTIFICACION CRITERIOS DE EXCLUSION DE ESTANCIA HOSPITALARIA
SELECT
       COUNTIF(dias_estancia >= 90) AS numero_de_outliers,
       COUNT(*) AS total_de_casos,
       ROUND(COUNTIF(dias_estancia >= 90) * 100.0 / COUNT(*), 4) AS porcentaje_de_outliers
     FROM
       warehouse.egresosnor
     WHERE
       (
        cie10_codigo LIKE 'K35%'
        OR cie10_codigo LIKE 'K80%'
        OR cie10_codigo LIKE 'K81%'
        OR cie10_codigo LIKE 'O82%'
      );


-- JUSTIFICACION CRITERIOS DE EXCLUSION DE ESTACIA HOSPITALARIA QUARTILES
SELECT
       APPROX_QUANTILES(dias_estancia, 100) AS percentiles_estancia
     FROM
       `tu-proyecto.warehouse.egresosnor`
     WHERE
       (
         cie10_codigo LIKE 'K35%'
         OR cie10_codigo LIKE 'K80%'
        OR cie10_codigo LIKE 'K81%'
        OR cie10_codigo LIKE 'O82%'
      )
      AND dias_estancia < 90;

--CONTEO NUMERO DE CASOS DE APENDICECTOMIA, COLECISTECTOMIA Y CESAREAS POR SECTOR
-- TABLA 1
SELECT
sector_normalizado,
CASE 
WHEN cie10_codigo LIKE 'K35%' THEN 'Apendicectomía'
WHEN cie10_codigo LIKE 'K80%' OR cie10_codigo LIKE 'K81%' THEN 'Colecistectomía'
WHEN cie10_codigo LIKE 'O82%' THEN 'Cesárea'
END AS procedimiento,
COUNT(*) AS numero_de_casos
FROM warehouse.egresosnor
WHERE
( cie10_codigo LIKE 'K35%'
OR cie10_codigo LIKE 'K80%'
OR cie10_codigo LIKE 'K81%'
OR cie10_codigo LIKE 'O82%')
GROUP BY sector_normalizado, procedimiento;


-- ANALISIS ESTANCIA HOSPITALARIA
-- Análisis de Estancia Hospitalaria Promedio (Tabla 2)
     SELECT
       sector_normalizado,
       CASE
         WHEN cie10_codigo LIKE 'K35%' THEN 'Apendicectomía'
         WHEN cie10_codigo LIKE 'K80%' OR cie10_codigo LIKE 'K81%' THEN 'Colecistectomía'
         WHEN cie10_codigo LIKE 'O82%' THEN 'Parto por Cesárea'
       END AS procedimiento,
    
      COUNT(*) AS numero_de_casos,
      ROUND(AVG(dias_estancia), 2) AS estancia_promedio_dias,
      ROUND(STDDEV(dias_estancia), 2) AS desviacion_estandar_dias,
      MIN(dias_estancia) AS estancia_minima_dias,
      MAX(dias_estancia) AS estancia_maxima_dias
   
    FROM
      warehouse.egresosnor
    WHERE
      (
        cie10_codigo LIKE 'K35%'
        OR cie10_codigo LIKE 'K80%'
        OR cie10_codigo LIKE 'K81%'
        OR cie10_codigo LIKE 'O82%'
      )
      AND dias_estancia < 90 -- Filtro para excluir outliers extremos (ej. estancias de meses)
    GROUP BY
      sector_normalizado,
      procedimiento
    ORDER BY
      procedimiento,
      sector_normalizado;


--CONSULTA DE MORTALIDAD
SELECT
       sector_normalizado,
       CASE
         WHEN cie10_codigo LIKE 'K35%' THEN 'Apendicectomía'
         WHEN cie10_codigo LIKE 'K80%' OR cie10_codigo LIKE 'K81%' THEN 'Colecistectomía'
         WHEN cie10_codigo LIKE 'O82%' THEN 'Parto por Cesárea'
       END AS procedimiento,
    
      COUNT(*) AS total_casos,
      SUM(CASE WHEN con_egrpa LIKE 'Fallecido%' THEN 1 ELSE 0 END) AS total_fallecidos,
      ROUND(AVG(CASE WHEN con_egrpa LIKE 'Fallecido%' THEN 1.0 ELSE 0.0 END) * 100, 3) AS tasa_mortalidad_porcentaje
   
    FROM
      warehouse.egresosnor
    WHERE
      (
        cie10_codigo LIKE 'K35%'
        OR cie10_codigo LIKE 'K80%'
        OR cie10_codigo LIKE 'K81%'
        OR cie10_codigo LIKE 'O82%'
      )
    GROUP BY
      sector_normalizado,
      procedimiento
    ORDER BY
      procedimiento,
      sector_normalizado;
  