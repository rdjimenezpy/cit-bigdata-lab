/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: QUERIES PARA REPORTES DE MONITOREOS Y CONTROL DEL PROCESO DE ETL.
 * 
 * Descripción: Reportes Ad Hoc.
 *
 * @autor: Prof. Richar D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 10, 2024
 * @ultima_modificacion: Setiembre 10, 2024
 * @version: 1.0.0
 */



--REPROCESAMIENTO TABLA REMUNERACION_DETALLE
do $$
declare
	periodo_anho int;
	periodo_mes int;
	id_min int;
begin

	--Obtener anho y mes de procesamiento
	select anho, mes into periodo_anho, periodo_mes
	from raw.raw_nomina_sfp limit 1;

	raise notice 'periodo anho % y mes %', periodo_anho, periodo_mes;

	--Obtener el identificador minimo para el periodo de procesamiento
	select min(rd.remuneracion_detalle_id) into id_min
	from sfp.remuneracion_detalle rd
	inner join sfp.remuneracion_cabecera rc on rc.remuneracion_cabecera_id = rd.remuneracion_cabecera_id
	inner join sfp.periodo p on p.periodo_id = rc.periodo_id
	where p.anho = periodo_anho and p.mes = periodo_mes;

	raise notice 'valor id_min %', id_min;

	--Eliminar conjunto de registros del periodo de procesamiento
	delete from sfp.remuneracion_detalle rd where rd.remuneracion_detalle_id in(
		select rd.remuneracion_detalle_id from sfp.remuneracion_detalle rd
		inner join sfp.remuneracion_cabecera rc on rc.remuneracion_cabecera_id = rd.remuneracion_cabecera_id
		inner join sfp.periodo p on p.periodo_id = rc.periodo_id
		where p.anho = periodo_anho and p.mes = periodo_mes
	);

	--Setear valor de secuencia con el valor calculado
	if id_min is not null then
		perform setval('sfp.remuneracion_detalle_remuneracion_detalle_id_seq', id_min);
	else
		raise notice 'valor id_min es NULL';
	end if;

end $$;
language plpgsql;
