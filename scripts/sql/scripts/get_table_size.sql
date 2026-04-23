/*Aquí tienes un script en SQL que te permitirá consultar el tamaño de las tablas en PostgreSQL 15, 
 *mostrando tanto el tamaño de la tabla como el tamaño total (incluyendo índices y demás):
 *	pg_relation_size(relid): Muestra el tamaño de solo los datos de la tabla.
 *	pg_total_relation_size(relid): Incluye el tamaño de la tabla y cualquier índice asociado.
 *	pg_size_pretty(): Convierte el tamaño en un formato legible (por ejemplo, MB o GB).
 *	pg_statio_user_tables: Contiene estadísticas sobre tablas accesibles por el usuario.
 */

SELECT
    schemaname AS esquema,
    relname AS tabla,
    pg_size_pretty(pg_relation_size(relid)) AS tamaño_tabla,
    pg_size_pretty(pg_total_relation_size(relid)) AS tamaño_total
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;