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
		where
			documento is not null
			and nombres is not null
			and apellidos is not null
			and sexo is not null
			and substring(documento, 1, 1) not in('A', 'V') -- no persona
		order by documento
	) pd
	--where discapacidad = 'SI' and array_length(tipo_discapacidad) > 1
	group by documento
)
select * from mydata where cardinality(tipo_discapacidad) > 2;


SELECT array_length(ARRAY[1, 2, 3, 4], 1); -- Resultado: 4}



with my_table as (
	select
		documento,
		array_agg(distinct tipo_discapacidad) as tipo_discapacidad,
		array_agg(distinct discapacidad) as discapacidad 
	from stage.sfp_nomina_temporal
	group by documento
)
select *,
	case
		when cardinality(tipo_discapacidad) = 1 then coalesce(tipo_discapacidad[1], 'NINGUNO')
		when cardinality(tipo_discapacidad) = 2 then tipo_discapacidad[1]
		when cardinality(tipo_discapacidad) > 2 then 'MULTIPLE'
		else 'DESCONOCIDO'
	end funcionario_tipo_discapacidad,
	case
		when cardinality(discapacidad) = 1 then coalesce(discapacidad[1], 'NO')
		when cardinality(discapacidad) > 1 then 'SI'
		else 'NO'
	end funcionario_tipo_discapacidad	
from my_table
where cardinality(tipo_discapacidad) > 2;





