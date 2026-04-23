
select * from sfp_nominas limit 10;

select count(*) from sfp_nominas; --891.867



select distinct nivel, descripcion_nivel from sfp_nominas order by nivel;

select distinct entidad, descripcion_entidad from sfp_nominas order by entidad;

select distinct oee, descripcion_oee from sfp_nominas order by oee;



----------------

select nivel, descripcion_nivel, 
	entidad, descripcion_entidad,
	oee, descripcion_oee,
	count(distinct documento) as cantidad_funcionario
from sfp_nominas
where nivel = '28'
	and LEFT(documento, 1) not in ('V', 'A')
group by nivel, descripcion_nivel, 
	entidad, descripcion_entidad,
	oee, descripcion_oee
order by nivel, entidad;


----------------------
select documento, count(*)
from sfp_nominas
group by documento
having count(*) > 1
limit 10;

select * from sfp_nominas where documento = '1129164A';

--------------------
select distinct documento from sfp_nominas limit 1000;


select distinct LEFT(documento, 1) from sfp_nominas;

select count(*) from sfp_nominas where LEFT(documento, 1) = 'E'; --91
select count(*)  from sfp_nominas where LEFT(documento, 1) = 'A'; --110.996
select count(*)  from sfp_nominas where LEFT(documento, 1) = 'V'; --11.422
select count(*)  from sfp_nominas where LEFT(documento, 1) between '1' and '9'; --769.358

select (91 + 110996 + 11422 + 769358) - (select count(*) from sfp_nominas);

select * from sfp_nominas where LEFT(documento, 1) = 'V' and devengado > 0;

---

select distinct RIGHT(documento, 1) from sfp_nominas where RIGHT(documento, 1) not between '0' and '9';

select * from sfp_nominas where RIGHT(documento, 1) = 'B' limit 100;

select count(*) from sfp_nominas where presupuestado = 0; --2.679
select count(*) from sfp_nominas where devengado = 0; --15.479


--registros basuras
select count(*) from sfp_nominas where presupuestado = 0 and devengado = 0; --2679

