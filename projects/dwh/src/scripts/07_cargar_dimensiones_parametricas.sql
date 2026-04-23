/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: PARAMETRICAS PARA EL TRAMIENTO DE VALORES NULOS.
 * 
 * Descripción: Creamos valores paramétricos para las dimensiones. Se carga una sola vez antes de correr el ETL.
 *
 * @autor: Prof. Richard D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 11, 2024
 * @ultima_modificacion: Setiembre 11, 2024
 * @version: 1.0.0
 */


-- ###########################################################################
-- Tabla objetivo: DIM_FUNCIONARIO
-- ###########################################################################

INSERT INTO datamart.dim_funcionario
(documento, nombres, apellidos, sexo, nacionalidad, fecha_nacimiento, discapacidad, tipo_discapacidad, fecha_ultima_modificacion)
VALUES('-1', 'DESCONOCIDO', 'DESCONOCIDO', 'DESCONOCIDO', 'DESCONOCIDO', null, false, 'DESCONOCIDO', now());

INSERT INTO datamart.dim_funcionario
(documento, nombres, apellidos, sexo, nacionalidad, fecha_nacimiento, discapacidad, tipo_discapacidad, fecha_ultima_modificacion)
VALUES('-2', 'NO APLICA', 'NO APLICA', 'NO APLICA', 'NO APLICA', null, false, 'NO APLICA', now());

INSERT INTO datamart.dim_funcionario
(documento, nombres, apellidos, sexo, nacionalidad, fecha_nacimiento, discapacidad, tipo_discapacidad, fecha_ultima_modificacion)
VALUES('-3', 'EXTRANJERO', 'EXTRANJERO', 'EXTRANJERO', 'EXTRANJERO', null, false, 'NO', now());