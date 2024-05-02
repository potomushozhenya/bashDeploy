# Spatial-Data-ETL
Автоматизация сбора и обработки пространственных данных <br />

SELECT
    tablename,
    indexname,
    indexdef
FROM
    pg_indexes
WHERE
    schemaname = 'public'
ORDER BY
    tablename,
    indexname;