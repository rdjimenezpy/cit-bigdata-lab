-- Eliminar la tabla
DROP TABLE IF EXISTS dpl.bcp_cotizacion_referencial_mensual;

-- Crear la tabla
CREATE TABLE dpl.bcp_cotizacion_referencial_mensual (
	anho TEXT,
	mes TEXT,
	moneda TEXT,
	descripcion TEXT,
	cotizacion TEXT
);

--Crear indices
CREATE INDEX idx_bcp_cotizacion_referencial_mensual_lookup ON dpl.bcp_cotizacion_referencial_mensual(anho, mes, moneda);

-- Consultar la tabla
select * from dpl.bcp_cotizacion_referencial_mensual;


select count(*) from dpl.bcp_cotizacion_referencial_mensual; 104

select anho, mes, count(*) 
from dpl.bcp_cotizacion_referencial_mensual
group by anho, mes; 
