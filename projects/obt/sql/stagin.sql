--Step 1: RUBROS ACTIVOS

drop table if exists stg.sfp_nomina_temporal;

create unlogged table stg.sfp_nomina_temporal as
select
	anho::smallint,
	mes::smallint,
	nivel::smallint,
	entidad::smallint,
	oee::smallint,
	documento,
	nombres,
	apellidos,
	estado,
	anho_ingreso::smallint,
	sexo,
	discapacidad,
	tipo_discapacidad,
	fuente_financiamiento::smallint,
	objeto_gasto::smallint,
	linea,
	categoria,
	cargo,
	presupuestado::int,
	devengado::int,
	movimiento,
	fecha_nacimiento::date,
	fecha_acto::date,
	profesion,
	left(documento, 1)::char(1) as ctrl
from raw.sfp_nomina
where presupuestado::int <> 0 and left(documento, 1) <> 'V';

alter table stg.sfp_nomina_temporal set (autovacuum_enabled = false);


-- Step 2: RUBROS VACANTES
drop table if exists stg.sfp_nomina_vacante;

create unlogged table stg.sfp_nomina_vacante as
select
	anho::smallint,
	mes::smallint,
	nivel::smallint,
	entidad::smallint,
	oee::smallint,
	documento,
	nombres,
	apellidos,
	estado,
	anho_ingreso::smallint,
	sexo,
	discapacidad,
	tipo_discapacidad,
	fuente_financiamiento::smallint,
	objeto_gasto::smallint,
	linea,
	categoria,
	cargo,
	presupuestado::int,
	devengado::int,
	movimiento,
	fecha_nacimiento::date,
	fecha_acto::date,
	profesion
from raw.sfp_nomina
where left(documento, 1) = 'V' -- VACANTE
and presupuestado::int <> 0;


-- Step 3: RUBROS INCONSISTENTES

drop table if exists stg.sfp_nomina_pendiente;

create unlogged table stg.sfp_nomina_pendiente as
select
	anho,
	mes,
	nivel,
	entidad,
	oee,
	documento,
	nombres,
	apellidos,
	estado,
	anho_ingreso,
	sexo,
	discapacidad,
	tipo_discapacidad,
	fuente_financiamiento
	objeto_gasto,
	linea,
	categoria,
	cargo,
	presupuestado,
	devengado,
	movimiento,
	fecha_nacimiento,
	fecha_acto,
	profesion
from raw.sfp_nomina
where presupuestado::int = 0;


-- Step 4: Conetos de registros
with tmp_conteos as (
select
	count(*) as total,
	(select count(*) from stg.sfp_nomina_temporal) as temporal,
	(select count(*) from stg.sfp_nomina_vacante) as vacante,
	(select count(*) from stg.sfp_nomina_pendiente) as pendiente
from raw.sfp_nomina
)
select *, (temporal + vacante + pendiente - total) as delta from tmp_conteos;


-- Step 5: Cargar a core
drop table if exists core.remuneracion_funcionario_publico;

create unlogged table core.remuneracion_funcionario_publico as
select
	anho,
	mes,
	nivel as codigo_nivel,
	entidad as codigo_entidad,
	oee as codigo_oee,
	left(trim(documento), 1)::char(1) as documento_control,
	trim(documento) as documento_identidad,
	upper(trim(nombres)) as nombres,
	upper(trim(apellidos)) as apellidos,
	upper(trim(sexo)) as sexo,
	case
	    when fecha_nacimiento between date '1900-01-01' and now()::date then fecha_nacimiento
	    else null
	end as fecha_nacimiento,
	upper(trim(discapacidad)) as discapacidad,
	upper(trim(tipo_discapacidad)) as tipo_discapacidad,
	upper(trim(profesion)) as profesion,
	upper(trim(movimiento)) as movimiento,
	anho_ingreso,
	case
	    when fecha_acto between date '1900-01-01' and now()::date
	    then extract(year from fecha_acto)::smallint
	    else null
	end as anho_acto,
	upper(trim(estado)) as estado,
	fuente_financiamiento as codigo_fuente_financiamiento,
	upper(trim(linea)) as codigo_linea,
	case
	    when replace(upper(trim(categoria)), ' ', '') similar to '[a-za-z]%[0-9]%' then replace(upper(trim(categoria)), ' ', '')
	    else null
	end as codigo_categoria,
	upper(trim(cargo)) as cargo,
	objeto_gasto as codigo_gasto,
	presupuestado::int,
	devengado::int
from stg.sfp_nomina_temporal;

-- Step 6: Crear Tabla de hechos financieros (montos)
-- Grano: periodo–OEE–(fuente, categoría, concepto/tipo_remuneración…)
-- Medidas: montos PYG/USD, ratio de ejecución, etc.

drop table if exists datamart.remu_univ_financiera;

create unlogged table datamart.remu_univ_financiera as
with base as (
    select
        mst.anho,
        mst.mes,
        mst.codigo_entidad,
        mst.codigo_oee,
        oee.descripcion_entidad,
        oee.descripcion_oee,
        oee.descripcion_corta,
        mst.estado as funcionario_estado,
        mst.sexo as funcionario_sexo,
        case
            when mst.codigo_gasto in (111, 161) then 'SUELDOS'
            else 'VARIAS'
        end as tipo_remuneracion,
        case
        	when mst.codigo_fuente_financiamiento = 10 then 'TESORO PÚBLICO'
        	when mst.codigo_fuente_financiamiento = 20 then 'ENDEUDAMIENTO PÚBLICO'
        	when mst.codigo_fuente_financiamiento = 30 then 'RECURSOS INSTITUCIONALES'
        	else 'ND'
        end fuente_financiamiento,
        mst.presupuestado,
        mst.devengado,
        usd.cotizacion::int as cotizacion_usd
    from core.remuneracion_funcionario_publico mst
    join fdw.clasificador_oee oee
        on oee.codigo_nivel = '28'  -- universidades nacionales
       and oee.codigo_nivel::smallint = mst.codigo_nivel
       and oee.codigo_entidad::smallint = mst.codigo_entidad
       and oee.codigo_oee::smallint    = mst.codigo_oee
    join fdw.cotizacion_usd_mensual usd
        on usd.anho::smallint = mst.anho
       and usd.mes::smallint  = mst.mes
)
, agg as (
    select
        anho,
        mes,
        codigo_entidad,
        codigo_oee,
        descripcion_entidad,
        descripcion_oee,
        descripcion_corta,
		funcionario_estado,
		funcionario_sexo,
        tipo_remuneracion,
        fuente_financiamiento,
        sum(presupuestado)                  as monto_presupuestado_pyg,
        sum(devengado)                      as monto_devengado_pyg,
        sum(presupuestado) / cotizacion_usd as monto_presupuestado_usd,
        sum(devengado)     / cotizacion_usd as monto_devengado_usd
    from base
    group by
        anho,
        mes,
        codigo_entidad,
        codigo_oee,
        descripcion_entidad,
        descripcion_oee,
        descripcion_corta,
		funcionario_estado,
		funcionario_sexo,
        tipo_remuneracion,
        fuente_financiamiento,
        cotizacion_usd
)
select
    anho,
    mes,
    codigo_entidad,
    codigo_oee,
    descripcion_entidad,
    descripcion_oee,
    descripcion_corta,
	funcionario_estado,
	funcionario_sexo,
    tipo_remuneracion,
    fuente_financiamiento,
    monto_presupuestado_pyg,
    monto_devengado_pyg,
    monto_presupuestado_usd,
    monto_devengado_usd,
    round(monto_devengado_pyg::numeric / monto_presupuestado_pyg::numeric, 3) as ratio_ejecutado
from agg;


-- Step 7: Crear Tabla de “headcount” (funcionarios únicos)

drop table if exists datamart.remu_univ_headcount;

create unlogged table datamart.remu_univ_headcount as
with base_persona as (
    -- 1) Una fila por funcionario / periodo / OEE
    select distinct
        mst.anho,
        mst.mes,
        mst.codigo_entidad,
        mst.codigo_oee,
        oee.descripcion_entidad,
        oee.descripcion_oee,
        oee.descripcion_corta,
        mst.documento_identidad,
        mst.sexo,
        mst.fecha_nacimiento,
        mst.discapacidad,
        coalesce(mst.tipo_discapacidad, 'NO_APLICA') as tipo_discapacidad,
        mst.anho_ingreso
    from core.remuneracion_funcionario_publico mst
    join fdw.clasificador_oee oee
        on oee.codigo_nivel = '28'  -- UNIVERSIDADES NACIONALES
       and oee.codigo_nivel::smallint = mst.codigo_nivel
       and oee.codigo_entidad::smallint = mst.codigo_entidad
       and oee.codigo_oee::smallint    = mst.codigo_oee
)
, base_enriquecida as (
    -- 2) Calcular edad y antigüedad + rangos
    select
        anho,
        mes,
        codigo_entidad,
        codigo_oee,
        descripcion_entidad,
        descripcion_oee,
        descripcion_corta,
        documento_identidad,
        sexo,
        discapacidad,
        tipo_discapacidad,
        -- Edad al primer día del mes del período
        case
            when fecha_nacimiento is null then null
            else extract(
                     year from age(
                         make_date(anho::int, mes::int, 1),
                         fecha_nacimiento
                     )
                 )::int
        end as edad,
        case
            when anho_ingreso is null then null
            else anho::int - anho_ingreso::int
        end as antiguedad
    from base_persona
)
, base_rangos as (
    select
        anho,
        mes,
        codigo_entidad,
        codigo_oee,
        descripcion_entidad,
        descripcion_oee,
        descripcion_corta,
        documento_identidad,
        sexo,
        discapacidad,
        tipo_discapacidad,
        case
            when edad is null        then 'SIN_DATOS'
            when edad < 30           then '<30'
            when edad between 30 and 39 then '30-39'
            when edad between 40 and 49 then '40-49'
            when edad between 50 and 59 then '50-59'
            else '60+'
        end as rango_edad,
        case
            when antiguedad is null         then 'SIN_DATOS'
            when antiguedad < 5             then '<5'
            when antiguedad between 5 and 9 then '5-9'
            when antiguedad between 10 and 19 then '10-19'
            else '20+'
        end as rango_antiguedad
    from base_enriquecida
)
select
    anho,
    mes,
    codigo_entidad,
    codigo_oee,
    descripcion_entidad,
    descripcion_oee,
    descripcion_corta,
    sexo,
    discapacidad,
    tipo_discapacidad,
    rango_edad,
    rango_antiguedad,
    count(distinct documento_identidad)::int as cantidad_funcionarios
from base_rangos
group by
    anho,
    mes,
    codigo_entidad,
    codigo_oee,
    descripcion_entidad,
    descripcion_oee,
    descripcion_corta,
    sexo,
    discapacidad,
    tipo_discapacidad,
    rango_edad,
    rango_antiguedad;
