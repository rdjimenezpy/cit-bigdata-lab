
select count(*) from stage.sfp_nomina_temporal; --2.785.413

--
SET lc_time = 'es_ES'; -- Configurar el idioma a español

select count(*) from tmp_rp_remuneraciones; --2.785.413

--

select count(*) from tmp_persona_discapacidad; --341.471

--

select documento, count(*) 
from tmp_persona_discapacidad
group by documento
having count(*) > 1;

--
truncate table dpl.rp_sfp_remuneraciones;

--PASO 3 - Tabla final

--TRUNCATE TABLE dpl.rp_remuneraciones;

--version 1
EXPLAIN ANALYZE
insert into dpl.rp_sfp_remuneraciones
select
    rem.periodo_anho,
    rem.periodo_mes,
    rem.periodo_mes_nombre,
    rem.nivel_codigo as institucion_nivel_codigo,
    sfp.nivel_descripcion as institucion_nivel_descripcion,
    rem.entidad_codigo as institucion_entidad_codigo,
    sfp.entidad_descripcion as institucion_entidad_descripcion,
    rem.oee_codigo as institucion_oee_codigo,
    sfp.oee_descripcion as institucion_oee_descripcion,
    rem.funcionario_segmento,
    rem.documento as funcionario_cedula,
    rem.funcionario_nombres,
    rem.funcionario_apellidos,
    rem.funcionario_sexo,
    rem.funcionario_fecha_nacimiento,
    per.funcionario_discapacidad,
	per.funcionario_discapacidad_tipo,
    rem.funcionario_estado,
    rem.funcionario_anho_ingreso,
    rem.rubro_linea,
    rem.rubro_categoria,
    rem.objeto_gasto_codigo as rubro_objeto_gasto_codigo,
    pgn.objeto_gasto_descripcion as rubro_objeto_gasto_concepto,
    rem.rubro_monto_presupuestado,
    rem.rubro_monto_devengado
from tmp_rp_remuneraciones rem  --PASO 1
join tmp_persona_discapacidad per on per.documento = rem.documento  --PASO 2
join ods.pgn_gastos_clasificador pgn on pgn.objeto_gasto_codigo = rem.objeto_gasto_codigo  --ODS
join ods.sfp_oee sfp on sfp.nivel_codigo = rem.nivel_codigo --ODS
	and sfp.entidad_codigo = rem.entidad_codigo and sfp.oee_codigo = rem.oee_codigo
order by rem.documento, rem.nivel_codigo, rem.entidad_codigo, rem.oee_codigo
;


--Consultas de verificacion y conteo de registros

--ETAPA 1 - EXTRACCION DE DATOS
select * from stage.sfp_nomina_temporal;
select count(*) from stage.sfp_nomina_temporal; --2.785.413

truncate table stage.sfp_nomina_temporal;

--ETAPA 2 - TRAMSFORMACION Y LIMPIEZA DE LOS DATOS
select * from stage.rp_sfp_remuneraciones_temporal;
select count(*) from stage.rp_sfp_remuneraciones_temporal; --2.785.413

truncate table stage.rp_sfp_remuneraciones_temporal;

--ETAPA 3 - CARGA DE DATOS
select * from dpl.rp_sfp_remuneraciones;
select count(*) from dpl.rp_sfp_remuneraciones; --2.785.413

truncate table dpl.rp_sfp_remuneraciones;
