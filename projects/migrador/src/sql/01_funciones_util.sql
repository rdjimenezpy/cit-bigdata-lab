/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: DDL PARA CREAR LA BASE DE DATOS DE LABORATORIO Y LOS ESQUEMAS DE LA CAPA DE DATOS.
 * 
 * Descripción: Crear la estructura de la base de datos inicial.
 *
 * @autor: Prof. Richar D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 10, 2024
 * @ultima_modificacion: Abril 22, 2025
 * @version: 1.0.0
 */

SET search_path TO stage;

-- DROP FUNCTION stage.isnumeric(text);

-- SELECT stage.isnumeric('123');

-- SELECT stage.isnumeric('12A3');

-- Si la conversión es exitosa, la función devuelve verdadero (TRUE); de lo contrario, 
-- devuelve falso (FALSE). Esta función verifica si una cadena es numérico.
CREATE OR REPLACE FUNCTION stage.isnumeric(text) RETURNS boolean as $$
DECLARE
    x numeric;
BEGIN
    x = $1::numeric;
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN false;
END;
$$ STRICT LANGUAGE plpgsql IMMUTABLE;
