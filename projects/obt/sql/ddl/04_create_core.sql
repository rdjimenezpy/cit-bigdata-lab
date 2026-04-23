/*
 * Tablas CORE: Tablas maestras optimizadas y particionadas.
 */
 
CREATE SCHEMA IF NOT EXISTS core;

COMMENT ON SCHEMA core IS 'Esquema que contiene tablas maestras con datos transformados y limpios.';

DROP TABLE IF EXISTS stg.sfp_remuneracion;

-- =====================================================
-- Tabla maestra sin partición
-- =====================================================

CREATE UNLOGGED TABLE core.sfp_remuneracion (
	anho                            SMALLINT,
	mes                             SMALLINT,
	codigo_nivel                    SMALLINT,
	codigo_entidad                  SMALLINT,
	codigo_oee                      SMALLINT,
	documento_control               CHAR(1),
	documento_identidad             TEXT,
	nombres                         TEXT,
	apellidos                       TEXT,
	sexo                            TEXT,
	fecha_nacimiento                DATE,
	discapacidad                    TEXT,
	tipo_discapacidad               TEXT,
	profesion                       TEXT,
	movimiento                      TEXT,
	anho_ingreso                    SMALLINT,
	anho_acto                       SMALLINT,
	estado                          TEXT,
	codigo_fuente_financiamiento    SMALLINT,
	codigo_linea                    TEXT,
	codigo_categoria                TEXT,
	cargo                           TEXT,
	codigo_gasto                    SMALLINT,
	presupuestado                   INT,
	devengado                       INT 
);
-- Evita vacuums innecesarios y reduce aún más el consumo de CPU y disco.

ALTER TABLE stg.sfp_remuneracion SET (autovacuum_enabled = false);

-- =====================================================
-- Tabla Principal Particionada por Año y Mes
-- =====================================================

CREATE TABLE IF NOT EXISTS core.sfp_remuneracion (
    -- Columnas de particionamiento (optimización)
    anho                            SMALLINT NOT NULL,
    mes                             SMALLINT NOT NULL CHECK (mes BETWEEN 1 AND 12),
    -- Identificación y jerarquía organizacional (Unidades Ejecutoras)
    codigo_nivel                    SMALLINT NOT NULL,
    codigo_entidad                  SMALLINT NOT NULL,
    codigo_oee                      SMALLINT NOT NULL,
    -- Identificación personal (Datos Personales del Funcionario)
    documento_control               CHAR(1) NOT NULL,
    documento_identidad             VARCHAR(20) NOT NULL,
    nombres                         VARCHAR(100),
    apellidos                       VARCHAR(100),
    sexo                            CHAR(1),
    fecha_nacimiento                DATE,
    -- Información de discapacidad
    discapacidad                    BOOLEAN DEFAULT FALSE,
    tipo_discapacidad               VARCHAR(50),
    -- Información laboral
    profesion                       VARCHAR(100),
    movimiento                      VARCHAR(50),
    anho_ingreso                    SMALLINT,
    anho_acto                       SMALLINT,
    estado                          VARCHAR(20) CHECK (estado IN ('ACTIVO', 'INACTIVO', 'SUSPENDIDO', 'RETIRADO', 'LICENCIA')),
    -- Clasificación presupuestaria
    codigo_fuente_financiamiento    SMALLINT,
    codigo_linea                    VARCHAR(10),
    codigo_categoria                VARCHAR(10),
    cargo                           VARCHAR(150),
    codigo_gasto                    SMALLINT NOT NULL,
    -- Montos financieros
    presupuestado                   INT DEFAULT 0,
    devengado                       INT DEFAULT 0,
    -- Auditoría y control
    fecha_carga                     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion             TIMESTAMP DEFAULT NULL,
    -- Constraint de unicidad por periodo
    CONSTRAINT pk_sfp_remuneracion PRIMARY KEY (anho, mes, codigo_nivel, codigo_entidad, codigo_oee, documento_identidad, codigo_gasto)
) PARTITION BY RANGE (anho, mes);

-- =====================================================
-- Creación de Particiones (2024-01 a 2025-07)
-- =====================================================

-- Año 2024
CREATE TABLE core.sfp_remuneracion_2024_01 PARTITION OF core.sfp_remuneracion
    FOR VALUES FROM (2024, 1) TO (2024, 2);

CREATE TABLE core.sfp_remuneracion_2024_02 PARTITION OF core.sfp_remuneracion
    FOR VALUES FROM (2024, 2) TO (2024, 3);

CREATE TABLE core.sfp_remuneracion_2024_03 PARTITION OF core.sfp_remuneracion
    FOR VALUES FROM (2024, 3) TO (2024, 4);

CREATE TABLE core.sfp_remuneracion_2024_04 PARTITION OF core.sfp_remuneracion
    FOR VALUES FROM (2024, 4) TO (2024, 5);

CREATE TABLE core.sfp_remuneracion_2024_05 PARTITION OF core.sfp_remuneracion
    FOR VALUES FROM (2024, 5) TO (2024, 6);

CREATE TABLE core.sfp_remuneracion_2024_06 PARTITION OF core.sfp_remuneracion
    FOR VALUES FROM (2024, 6) TO (2024, 7);

CREATE TABLE core.sfp_remuneracion_2024_07 PARTITION OF core.sfp_remuneracion
    FOR VALUES FROM (2024, 7) TO (2024, 8);

CREATE TABLE core.sfp_remuneracion_2024_08 PARTITION OF core.sfp_remuneracion
    FOR VALUES FROM (2024, 8) TO (2024, 9);

CREATE TABLE core.sfp_remuneracion_2024_09 PARTITION OF core.sfp_remuneracion
    FOR VALUES FROM (2024, 9) TO (2024, 10);

CREATE TABLE core.sfp_remuneracion_2024_10 PARTITION OF core.sfp_remuneracion
    FOR VALUES FROM (2024, 10) TO (2024, 11);

CREATE TABLE core.sfp_remuneracion_2024_11 PARTITION OF core.sfp_remuneracion
    FOR VALUES FROM (2024, 11) TO (2024, 12);

CREATE TABLE core.sfp_remuneracion_2024_12 PARTITION OF core.sfp_remuneracion
    FOR VALUES FROM (2024, 12) TO (2025, 1);

-- Año 2025
CREATE TABLE core.sfp_remuneracion_2025_01 PARTITION OF core.sfp_remuneracion
    FOR VALUES FROM (2025, 1) TO (2025, 2);

CREATE TABLE core.sfp_remuneracion_2025_02 PARTITION OF core.sfp_remuneracion
    FOR VALUES FROM (2025, 2) TO (2025, 3);

CREATE TABLE core.sfp_remuneracion_2025_03 PARTITION OF core.sfp_remuneracion
    FOR VALUES FROM (2025, 3) TO (2025, 4);

CREATE TABLE core.sfp_remuneracion_2025_04 PARTITION OF core.sfp_remuneracion
    FOR VALUES FROM (2025, 4) TO (2025, 5);

CREATE TABLE core.sfp_remuneracion_2025_05 PARTITION OF core.sfp_remuneracion
    FOR VALUES FROM (2025, 5) TO (2025, 6);

CREATE TABLE core.sfp_remuneracion_2025_06 PARTITION OF core.sfp_remuneracion
    FOR VALUES FROM (2025, 6) TO (2025, 7);

CREATE TABLE core.sfp_remuneracion_2025_07 PARTITION OF core.sfp_remuneracion
    FOR VALUES FROM (2025, 7) TO (2025, 8);

-- =====================================================
-- Índices Estratégicos (aplicados a todas las particiones)
-- =====================================================

-- Índice para búsquedas por jerarquía organizacional
CREATE INDEX idx_remuneracion_jerarquia
ON core.sfp_remuneracion (codigo_nivel, codigo_entidad, codigo_oee, anho, mes);

-- Índice para trazabilidad de personas
CREATE INDEX idx_remuneracion_persona
ON core.sfp_remuneracion (documento_identidad, anho, mes);

-- Índice para análisis presupuestario
CREATE INDEX idx_remuneracion_presupuesto
ON core.sfp_remuneracion (codigo_fuente_financiamiento, codigo_gasto, anho, mes);

-- Índice para análisis por clasificación laboral
CREATE INDEX idx_remuneracion_clasificacion
ON core.sfp_remuneracion (codigo_linea, codigo_categoria, estado, anho, mes);

-- Índice parcial para funcionarios PERMANENTES (el más usado en reportes)
CREATE INDEX idx_remuneracion_activos
ON core.sfp_remuneracion (codigo_entidad, codigo_oee, anho, mes)
WHERE estado = 'PERMANENTES';

-- Índice para análisis demográfico
CREATE INDEX idx_remuneracion_demografia
ON core.sfp_remuneracion (sexo, discapacidad, anho, mes);

-- Índice para análisis de movimientos
CREATE INDEX idx_remuneracion_movimiento
ON core.sfp_remuneracion (movimiento, anho_acto, anho, mes)
WHERE movimiento IS NOT NULL;

-- Índice para búsqueda por cargo
CREATE INDEX idx_remuneracion_cargo
ON core.sfp_remuneracion USING gin(cargo gin_trgm_ops);

-- =====================================================
-- Extensión para búsqueda de texto (si se necesita)
-- =====================================================

CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- =====================================================
-- Estadísticas Mejoradas para el Optimizador
-- =====================================================

ALTER TABLE core.sfp_remuneracion ALTER COLUMN codigo_nivel SET STATISTICS 1000;
ALTER TABLE core.sfp_remuneracion ALTER COLUMN codigo_entidad SET STATISTICS 1000;
ALTER TABLE core.sfp_remuneracion ALTER COLUMN codigo_oee SET STATISTICS 1000;
ALTER TABLE core.sfp_remuneracion ALTER COLUMN documento_identidad SET STATISTICS 500;
ALTER TABLE core.sfp_remuneracion ALTER COLUMN codigo_gasto SET STATISTICS 500;
ALTER TABLE core.sfp_remuneracion ALTER COLUMN codigo_categoria SET STATISTICS 500;
ALTER TABLE core.sfp_remuneracion ALTER COLUMN codigo_linea SET STATISTICS 500;
ALTER TABLE core.sfp_remuneracion ALTER COLUMN estado SET STATISTICS 200;