SELECT
       CASE
         WHEN cie10_codigo LIKE 'K35%' THEN 'Apendicectomia'
         WHEN cie10_codigo LIKE 'K80%' OR cie10_codigo LIKE 'K81%' THEN 'Colecistectomia'
         WHEN cie10_codigo LIKE 'O82%' THEN 'Parto por Cesarea'
       END AS procedimiento,
    
       sector_normalizado,
      dias_estancia,
      con_egrpa -- La condición de egreso para el Chi-Cuadrado
   
    FROM
      `tu-proyecto.warehouse.egresosnor`
    WHERE
      (
        cie10_codigo LIKE 'K35%'
        OR cie10_codigo LIKE 'K80%'
        OR cie10_codigo LIKE 'K81%'
        OR cie10_codigo LIKE 'O82%'
      )
      AND dias_estancia < 90; -- Filtro de outliers
