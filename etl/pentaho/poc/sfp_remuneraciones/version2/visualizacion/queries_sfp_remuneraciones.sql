truncate table dpl.rp_remuneraciones;
select count(*) from dpl.rp_remuneraciones;

select * from dpl.rp_remuneraciones;

--
select periodo_anho, periodo_mes, periodo_mes_nombre, count(*) 
from dpl.rp_remuneraciones
group by periodo_anho, periodo_mes, periodo_mes_nombre;

---Total presupuestado y total devengado por entidad y nivel. 
select periodo_anho, periodo_mes, periodo_mes_nombre,
institucion_nivel_descripcion, institucion_entidad_descripcion, 
sum(rubro_monto_presupuestado) as total_presupuestado, sum(rubro_monto_devengado) as  total_devengado
from dpl.rp_remuneraciones
where periodo_anho = '2024' and periodo_mes = '3'
group by periodo_anho, periodo_mes, periodo_mes_nombre, institucion_nivel_descripcion, institucion_entidad_descripcion;