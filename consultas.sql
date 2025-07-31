--NUMERO DE CASOS DE APENDICECTOMIA, COLECISTECTOMIA Y CESAREAS POR SECTOR
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
