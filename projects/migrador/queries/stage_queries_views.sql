/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * Descripción: Consultas de vistas y controles de STAGE AREA.
 *
 * @autor: Prof. Richar D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 10, 2024
 * @ultima_modificacion: Setiembre 10, 2024
 * @version: 1.0.0
 */


select * from stage.vw_nivel;

select * from stage.vw_entidad;

select * from stage.vw_oee;

select * from stage.vw_aux_persona;

select * from stage.vw_persona;

select * from stage.vw_funcionario;


-- Controles
select documento from stage.vw_persona group by documento having count(*) > 1;


-- drop view stage.vw_aux_tipo_discapacidad_persona;

create or replace view stage.vw_aux_tipo_discapacidad_persona as
select distinct
	documento,
	max(tipo_discapacidad) tipo_discapacidad
from
	ods.ods_nomina
where
	tipo_discapacidad is not null
group by documento
order by documento;

select * from stage.vw_aux_tipo_discapacidad_persona;

-- rastrear 
select documento from stage.vw_aux_tipo_discapacidad_persona group by documento having count(*) > 1;

select * from stage.vw_aux_tipo_discapacidad_persona
where documento in('1236720')
;