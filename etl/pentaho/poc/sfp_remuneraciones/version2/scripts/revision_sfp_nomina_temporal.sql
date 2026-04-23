create temporary table mydata as
-- revision de totales de registros
select count(*) from stage.sfp_nomina_temporal; --1.883.346

-- revision: ANHO y MES
select anho, mes, count(*) from stage.sfp_nomina_temporal group by anho, mes;


-- revision de montos: PRESUPUESTADO y DEVENGADO
select count(*) from stage.sfp_nomina_temporal where presupuestado = 0; --0
select count(*) from stage.sfp_nomina_temporal where devengado = 0; --27.169

select count(*) from stage.sfp_nomina_temporal where presupuestado < devengado; --0
select count(*) from stage.sfp_nomina_temporal where presupuestado > devengado; --666.095
select count(*) from stage.sfp_nomina_temporal where presupuestado = devengado; --1.217.251

select 666095 + 1217251; --1.883.346


--- revision: NIVEL, ENTIDAD y OEE
select distinct nivel_codigo from stage.sfp_nomina_temporal where not nivel_codigo is null;
select distinct entidad_codigo from stage.sfp_nomina_temporal where not entidad_codigo is null;
select distinct oee_codigo from stage.sfp_nomina_temporal where not oee_codigo is null;

select nivel_codigo, entidad_codigo, oee_codigo, count(*)
from stage.sfp_nomina_temporal
where nivel_codigo is null or entidad_codigo is null or oee_codigo is null
group by nivel_codigo, entidad_codigo, oee_codigo;


-- revision: ESTADO
select estado, count(*) from stage.sfp_nomina_temporal group by estado; -- COMISIONADO | CONTRATADO | PERMANENTE

-- revision: DOCUMENTO
select left(documento, 1), count(*) --A: 219.919 V: 21.644 E: 182
from stage.sfp_nomina_temporal
group by left(documento, 1);

-- revision: NOMBRES, APELLIDOS, SEXO, FECHA_NACIMIENTO

select distinct sexo from stage.sfp_nomina_temporal; -- FEMENINO y MASCULINO

drop table temp_mydata;
create temporary table temp_mydata as
select documento, nombres, apellidos, sexo, fecha_nacimiento, presupuestado, devengado, objeto_gasto_codigo, estado
from stage.sfp_nomina_temporal
where left(documento, 1) = 'A';

select * from temp_mydata;

select distinct nombres from temp_mydata; --NOMBRES DEL FUNCIONARIO
select distinct apellidos from temp_mydata; --APELLIDOS DEL FUNCIONARIO
select distinct sexo from temp_mydata; -- MASCULINO y FEMENINO

select count(*) from temp_mydata where devengado = 0; --13
select * from temp_mydata where devengado = 0;

-- regla para eliminar registros ANONIMOS
select count(*) from stage.sfp_nomina_temporal where left(documento, 1) = 'A' and devengado = 0; --13

select count(*) from stage.sfp_nomina_temporal where not (left(documento, 1) = 'A' and devengado = 0); --1.883.333

--regla para eliminar registros VACANTES
select count(*) from stage.sfp_nomina_temporal where left(documento, 1) = 'V' and devengado > 0;


-- revision: FECHA_NACIMIENTO
select min(fecha_nacimiento::date), max(fecha_nacimiento::date)
from stage.sfp_nomina_temporal
where not (left(documento, 1) = 'A' and devengado = 0)
and not left(documento, 1) = 'V'
and not fecha_nacimiento::date = '1777-07-07'::date
;

select * from stage.sfp_nomina_temporal where fecha_nacimiento::date = '1777-07-07'::date;
select * from stage.sfp_nomina_temporal where fecha_nacimiento::date = '2011-08-23'::date;

select * from stage.sfp_nomina_temporal where fecha_nacimiento::date < '1930-01-01'::date;

select distinct extract(year from fecha_nacimiento::date) as anho, 2025 - extract(year from fecha_nacimiento::date) edad  
from stage.sfp_nomina_temporal
order by anho desc;


select count(*) from stage.sfp_nomina_temporal where extract(year from fecha_nacimiento::date) is null;
select count(*) from stage.sfp_nomina_temporal where fecha_nacimiento::date is null; --21.822
select * from stage.sfp_nomina_temporal where fecha_nacimiento::date is null;


-- revision: ANHO_INGRESO
select min(anho_ingreso), max(anho_ingreso) from stage.sfp_nomina_temporal; --0 y 9999

select distinct anho_ingreso from stage.sfp_nomina_temporal order by anho_ingreso asc;

select * from stage.sfp_nomina_temporal where anho_ingreso = '204';
select * from stage.sfp_nomina_temporal where anho_ingreso is null;
select * from stage.sfp_nomina_temporal where anho_ingreso = '';



-- revision: DISCAPACIDAD y TIPO_DISCAPACIDAD

with mydata as (
	select
		documento,
		array_agg(tipo_discapacidad) as tipo_discapacidad,
		array_agg(discapacidad) as discapacidad 
	from (
		select distinct
			documento,
			trim(tipo_discapacidad) as tipo_discapacidad,
			trim(discapacidad) as discapacidad
		from
			stage.sfp_nomina_temporal
		--where
			--documento is not null
			--and nombres is not null
			--and apellidos is not null
			--and sexo is not null
			--and substring(documento, 1, 1) not in('A', 'V') -- no persona
		order by documento
	) pd
	--where discapacidad = 'SI' and array_length(tipo_discapacidad) > 1
	group by documento
)
select * from mydata where cardinality(tipo_discapacidad) > 1;


SELECT array_length(ARRAY[1, 2, 3, 4], 1); -- Resultado: 4


select
	documento, count(*) cantidad
from (
	select distinct
		documento,
		trim(tipo_discapacidad) as tipo_discapacidad,
		trim(discapacidad) as discapacidad
	from
		stage.sfp_nomina_temporal
) t
group by documento
having count(*) > 2
;


--dejar el mas actual si aplica
--tomar el añor de ingreso
select * from stage.sfp_nomina_temporal where documento = '3801917';


-- revision: ESTADO
select distinct estado from stage.sfp_nomina_temporal;


-- revision: OBJETO_GASTO_CODIGO
select distinct objeto_gasto_codigo from stage.sfp_nomina_temporal;
select distinct objeto_gasto_codigo from stage.sfp_nomina_temporal where objeto_gasto_codigo is null;
select distinct objeto_gasto_codigo from stage.sfp_nomina_temporal where objeto_gasto_codigo = '';

-- revision: LINEA y CATEGORIA
select distinct linea from stage.sfp_nomina_temporal;
select linea from stage.sfp_nomina_temporal where linea is null;
select linea from stage.sfp_nomina_temporal where linea = '';


select distinct categoria from stage.sfp_nomina_temporal;
select distinct categoria from stage.sfp_nomina_temporal where categoria like 'Z%';
select categoria from stage.sfp_nomina_temporal where categoria is null;
select categoria from stage.sfp_nomina_temporal where categoria = '';







