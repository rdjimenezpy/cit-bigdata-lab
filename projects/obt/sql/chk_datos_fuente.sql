/*
    Diagnóstico y revisión inicial de datos crudos

    Scripts que inspeccionan calidad, formatos, duplicados, nulos, outliers, etc.
*/

select * from raw.sfp_nomina limit 100;

-- Count 988.788
select count(*) from raw.sfp_nomina;

-- Anho, Mes: periodo
select distinct(anho, mes) as periodo from raw.sfp_nomina;


-- Nivel y Descripcion
select distinct nivel, descripcion_nivel from raw.sfp_nomina order by nivel;
select count(distinct (nivel, descripcion_nivel)) from raw.sfp_nomina; -- 14
select nivel, descripcion_nivel, count(*) from raw.sfp_nomina group by nivel, descripcion_nivel;


-- Entidad y Descripcion
select distinct entidad, descripcion_entidad  from raw.sfp_nomina order by entidad;
select count(distinct (entidad, descripcion_entidad)) from raw.sfp_nomina; -- 125


-- OEE y Descripcion
select distinct oee, descripcion_oee from raw.sfp_nomina order by oee;
select count(distinct(oee, descripcion_oee)) from raw.sfp_nomina; -- 396

select nivel, descripcion_nivel, entidad, descripcion_entidad, count(distinct oee)
from raw.sfp_nomina group by nivel, descripcion_nivel, entidad, descripcion_entidad;


--Persona
select distinct documento, nombres, apellidos, sexo, fecha_nacimiento from sfp_nomina
where documento is null
or nombres is null
or apellidos is null
or sexo is null
or fecha_nacimiento is null;

select count(distinct documento) from sfp_nomina; -- 32.4109

-- FechaNacimiento NULL para extranjeros y cargos vacantes
select distinct left(documento, 1) from sfp_nomina where fecha_nacimiento is null;


--Persona Nacionalidad Paraguaya (1-9), Extranejros (E), Anónimos (A) y Cargos Vacantes (V)
select distinct left(documento, 1) as ctl from sfp_nomina order by ctl;

select left(documento, 1) as ctl, count(*) from sfp_nomina group by ctl order by ctl;


-- Estado
select distinct estado from sfp_nomina;


-- AnhoIngreso
select distinct anho_ingreso from sfp_nomina order by anho_ingreso;
select distinct anho_ingreso, coalesce(2025 - anho_ingreso::int, 0) antiguedad from sfp_nomina order by anho_ingreso;


-- Sexo
select distinct Sexo from sfp_nomina;


-- Funcion
select distinct funcion from sfp_nomina;
select count(distinct funcion) from sfp_nomina; --36.263


-- CargaHoraria
select distinct carga_horaria from sfp_nomina;
select count(distinct carga_horaria) from sfp_nomina; --35.235


-- Discapaciad y TipoDiscapacidad
select distinct discapacidad from sfp_nomina;
select distinct tipo_discapacidad from sfp_nomina;


-- FuenteDeFinanciamiento
select distinct fuente_financiamiento from sfp_nomina;


-- ObjetoGasto y Descripcion (Concepto)
select distinct objeto_gasto from sfp_nomina;
select count(distinct objeto_gasto) from sfp_nomina; -- 44
select distinct concepto from sfp_nomina;

-- Linea
select distinct linea from sfp_nomina order by linea desc;
select count(distinct linea) from sfp_nomina; -- 8.105

-- Categoria
select distinct categoria from sfp_nomina;
select distinct categoria, linea, cargo from sfp_nomina where categoria like '%L32%';
select count(distinct categoria) from sfp_nomina; -- 2810


-- Cargo
select distinct cargo from sfp_nomina;
select count(distinct cargo) from sfp_nomina; -- 17708


-- Movimiento
select distinct movimiento from sfp_nomina;
select count(distinct movimiento) from sfp_nomina; -- 3

select movimiento, count(*) from sfp_nomina group by movimiento;

-- Lugar
select distinct lugar from sfp_nomina;
select count(distinct lugar) from sfp_nomina; -- 2.232


-- FechaNacimiento
select distinct fecha_nacimiento from sfp_nomina;
select count(distinct fecha_nacimiento) from sfp_nomina; -- 20.718

select min(fecha_nacimiento::date), max(fecha_nacimiento::date) from sfp_nomina;

select distinct fecha_nacimiento from sfp_nomina where fecha_nacimiento is null;
select distinct fecha_nacimiento from sfp_nomina where fecha_nacimiento::date is null;
select distinct fecha_nacimiento from sfp_nomina where fecha_nacimiento like '';
select distinct fecha_nacimiento from sfp_nomina where fecha_nacimiento like ' ';

-- FechaUltimaModificacion
select distinct fecha_nacimiento from sfp_nomina;
select count(distinct fecha_nacimiento) from sfp_nomina; -- 20.718


-- URI
select distinct uri from sfp_nomina;
select count(distinct uri) from sfp_nomina; -- 309.541


-- FechaActo
select distinct fecha_acto from sfp_nomina;
select count(distinct fecha_acto) from sfp_nomina; -- 10.766


-- Correo
select distinct correo from sfp_nomina;
select count(distinct correo) from sfp_nomina; -- 132.156


-- Profesion
select distinct profesion from sfp_nomina;
select count(distinct profesion) from sfp_nomina; -- 7.020


-- MotivoMovimiento
select distinct motivo_movimiento from sfp_nomina;
select count(distinct motivo_movimiento) from sfp_nomina; -- 6.211


-- Presupuestado y Devengado
select presupuestado, devengado
from sfp_nomina
where presupuestado is null
or devengado is null
or presupuestado::int = 0
or (presupuestado::int <> 0
and devengado::int = 0);


select count(*) -- 16.682
from sfp_nomina
where presupuestado is null
or devengado is null
or presupuestado::int = 0
or (presupuestado::int <> 0
and devengado::int = 0);