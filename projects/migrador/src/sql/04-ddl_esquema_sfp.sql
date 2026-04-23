/* UNIVERSIDAD NACIONAL DE ASUNCION
 * Facultad Politécnica - Proyecto Centro de Innovación TIC - Curso Básico de Introducción a Big Data
 * 
 * SCRIPTS: DDL PARA CREAR LAS TABLAS EN EL ESQUEMA SFP.
 * 
 * Descripcion: Implementación del modelo de datos físico de la base de datos de laboratorio.
 *
 * @autor: Prof. Richar D. Jiménez-R. <rjimenez@pol.una.py>
 * @creacion: Setiembre 10, 2024
 * @ultima_modificacion: Abril 22, 2025
 * @version: 1.0.0
 */

SET search_path TO sfp;

CREATE SEQUENCE sfp.periodo_periodo_id_seq;

CREATE TABLE sfp.periodo (
                periodo_id SMALLINT NOT NULL DEFAULT nextval('sfp.periodo_periodo_id_seq'),
                anho SMALLINT NOT NULL,
                mes SMALLINT NOT NULL,
                mes_nombre VARCHAR(16) NOT NULL,
                trimestre CHAR(1) NOT NULL,
                cuatrimestre CHAR(1) NOT NULL,
                semestre CHAR(1) NOT NULL,
                activo BOOLEAN DEFAULT true NOT NULL,
                usuario_creacion VARCHAR(16) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
                usuario_modificacion VARCHAR(16),
                fecha_modificacion TIMESTAMP,
                CONSTRAINT periodo_pk PRIMARY KEY (periodo_id)
);
COMMENT ON TABLE sfp.periodo IS 'Tabla paramétrica.';
COMMENT ON COLUMN sfp.periodo.periodo_id IS 'Clave primaria';
COMMENT ON COLUMN sfp.periodo.activo IS 'Estado del registro';
COMMENT ON COLUMN sfp.periodo.usuario_creacion IS 'Nombre de usuario de creación del registro';
COMMENT ON COLUMN sfp.periodo.fecha_creacion IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN sfp.periodo.usuario_modificacion IS 'Nombre de usuario que realizó la última modificación del registro';
COMMENT ON COLUMN sfp.periodo.fecha_modificacion IS 'Fecha y hora de la última modificación del registro';


ALTER SEQUENCE sfp.periodo_periodo_id_seq OWNED BY sfp.periodo.periodo_id;

CREATE UNIQUE INDEX periodo_anho_mes_idx
 ON sfp.periodo USING BTREE
 ( anho ASC, mes ASC );

CREATE SEQUENCE sfp.profesion_profesion_id_seq;

CREATE TABLE sfp.profesion (
                profesion_id SMALLINT NOT NULL DEFAULT nextval('sfp.profesion_profesion_id_seq'),
                codigo VARCHAR(32) NOT NULL,
                descripcion VARCHAR(255) NOT NULL,
                activo BOOLEAN DEFAULT true NOT NULL,
                usuario_creacion VARCHAR(16) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
                usuario_modificacion VARCHAR(16),
                fecha_modificacion TIMESTAMP,
                CONSTRAINT profesion_pk PRIMARY KEY (profesion_id)
);
COMMENT ON TABLE sfp.profesion IS 'Tabla que almacena el listado de profesiones.';
COMMENT ON COLUMN sfp.profesion.profesion_id IS 'Clave primeria';
COMMENT ON COLUMN sfp.profesion.codigo IS 'Código único';
COMMENT ON COLUMN sfp.profesion.descripcion IS 'Texto descriptivo';
COMMENT ON COLUMN sfp.profesion.activo IS 'Estado del registro';
COMMENT ON COLUMN sfp.profesion.usuario_creacion IS 'Nombre de usuario de creacion del registro';
COMMENT ON COLUMN sfp.profesion.fecha_creacion IS 'Fecha y hora de creacion del registro';
COMMENT ON COLUMN sfp.profesion.usuario_modificacion IS 'Nombre de usuario que realizo la ultima modificacion del registro';
COMMENT ON COLUMN sfp.profesion.fecha_modificacion IS 'Fecha y hora de la última modificación del registro';


ALTER SEQUENCE sfp.profesion_profesion_id_seq OWNED BY sfp.profesion.profesion_id;

CREATE UNIQUE INDEX profesion_codigo_idx
 ON sfp.profesion USING BTREE
 ( codigo ASC );

CREATE SEQUENCE sfp.fuente_financiamiento_fuente_financiamiento_id_seq;

CREATE TABLE sfp.fuente_financiamiento (
                fuente_financiamiento_id SMALLINT NOT NULL DEFAULT nextval('sfp.fuente_financiamiento_fuente_financiamiento_id_seq'),
                codigo VARCHAR(2) NOT NULL,
                descripcion VARCHAR(64) NOT NULL,
                activo BOOLEAN DEFAULT true NOT NULL,
                usuario_creacion VARCHAR(16) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
                usuario_modificacion VARCHAR(16),
                fecha_modificacion TIMESTAMP,
                CONSTRAINT fuente_financiamiento_pk PRIMARY KEY (fuente_financiamiento_id)
);
COMMENT ON TABLE sfp.fuente_financiamiento IS 'Tabala paramétrica para fuente de financiamiento del Presupuesto General de la Nación';
COMMENT ON COLUMN sfp.fuente_financiamiento.fuente_financiamiento_id IS 'Clave primaria';
COMMENT ON COLUMN sfp.fuente_financiamiento.codigo IS 'Código único';
COMMENT ON COLUMN sfp.fuente_financiamiento.descripcion IS 'Texto descriptivo';
COMMENT ON COLUMN sfp.fuente_financiamiento.activo IS 'Estado del registro';
COMMENT ON COLUMN sfp.fuente_financiamiento.usuario_creacion IS 'Nombre de usuario de creación del registro';
COMMENT ON COLUMN sfp.fuente_financiamiento.fecha_creacion IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN sfp.fuente_financiamiento.usuario_modificacion IS 'Nombre de usuario que realizó la última modificación del registro';
COMMENT ON COLUMN sfp.fuente_financiamiento.fecha_modificacion IS 'Fecha y hora de la última modificación del registro';


ALTER SEQUENCE sfp.fuente_financiamiento_fuente_financiamiento_id_seq OWNED BY sfp.fuente_financiamiento.fuente_financiamiento_id;

CREATE INDEX fuente_financiamiento_codigo_idx
 ON sfp.fuente_financiamiento USING BTREE
 ( codigo ASC );

CREATE SEQUENCE sfp.cargo_cargo_id_seq;

CREATE TABLE sfp.cargo (
                cargo_id SMALLINT NOT NULL DEFAULT nextval('sfp.cargo_cargo_id_seq'),
                codigo VARCHAR(32) NOT NULL,
                descripcion VARCHAR(255) NOT NULL,
                activo BOOLEAN DEFAULT true NOT NULL,
                usuario_creacion VARCHAR(16) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
                usuario_modificacion VARCHAR(16),
                fecha_modificacion TIMESTAMP,
                CONSTRAINT cargo_pk PRIMARY KEY (cargo_id)
);
COMMENT ON TABLE sfp.cargo IS 'Tabla que almacena el listado de cargos.';
COMMENT ON COLUMN sfp.cargo.cargo_id IS 'Clave primeria';
COMMENT ON COLUMN sfp.cargo.codigo IS 'Código único';
COMMENT ON COLUMN sfp.cargo.descripcion IS 'Texto descriptivo';
COMMENT ON COLUMN sfp.cargo.activo IS 'Estado del registro';
COMMENT ON COLUMN sfp.cargo.usuario_creacion IS 'Nombre de usuario de creacion del registro';
COMMENT ON COLUMN sfp.cargo.fecha_creacion IS 'Fecha y hora de creacion del registro';
COMMENT ON COLUMN sfp.cargo.usuario_modificacion IS 'Nombre de usuario que realizo la ultima modificacion del registro';
COMMENT ON COLUMN sfp.cargo.fecha_modificacion IS 'Fecha y hora de la última modificación del registro';


ALTER SEQUENCE sfp.cargo_cargo_id_seq OWNED BY sfp.cargo.cargo_id;

CREATE UNIQUE INDEX cargo_codigo_idx
 ON sfp.cargo USING BTREE
 ( codigo ASC );

CREATE SEQUENCE sfp.control_financiero_control_financiero_id_seq;

CREATE TABLE sfp.control_financiero (
                control_financiero_id SMALLINT NOT NULL DEFAULT nextval('sfp.control_financiero_control_financiero_id_seq'),
                codigo SMALLINT NOT NULL,
                descripcion VARCHAR(64) NOT NULL,
                activo BOOLEAN DEFAULT true NOT NULL,
                usuario_creacion VARCHAR(16) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
                usuario_modificacion VARCHAR(16),
                fecha_modificacion TIMESTAMP,
                CONSTRAINT control_financiero_pk PRIMARY KEY (control_financiero_id)
);
COMMENT ON TABLE sfp.control_financiero IS 'Tabla paramétrica.';
COMMENT ON COLUMN sfp.control_financiero.control_financiero_id IS 'Clave primaria';
COMMENT ON COLUMN sfp.control_financiero.codigo IS 'Código único';
COMMENT ON COLUMN sfp.control_financiero.descripcion IS 'Texto descriptivo';
COMMENT ON COLUMN sfp.control_financiero.activo IS 'Estado del registro';
COMMENT ON COLUMN sfp.control_financiero.usuario_creacion IS 'Nombre de usuario de creación del registro';
COMMENT ON COLUMN sfp.control_financiero.fecha_creacion IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN sfp.control_financiero.usuario_modificacion IS 'Nombre de usuario que realizó la última modificación del registro';
COMMENT ON COLUMN sfp.control_financiero.fecha_modificacion IS 'Fecha y hora de la última modificación del registro';


ALTER SEQUENCE sfp.control_financiero_control_financiero_id_seq OWNED BY sfp.control_financiero.control_financiero_id;

CREATE UNIQUE INDEX control_financiero_codigo_idx
 ON sfp.control_financiero USING BTREE
 ( codigo );

CREATE SEQUENCE sfp.grupo_gasto_grupo_gasto_id_seq;

CREATE TABLE sfp.grupo_gasto (
                grupo_gasto_id SMALLINT NOT NULL DEFAULT nextval('sfp.grupo_gasto_grupo_gasto_id_seq'),
                codigo SMALLINT NOT NULL,
                descripcion VARCHAR(70) NOT NULL,
                activo BOOLEAN DEFAULT true NOT NULL,
                usuario_creacion VARCHAR(16) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
                usuario_modificacion VARCHAR(16),
                fecha_modificacion TIMESTAMP,
                CONSTRAINT grupo_gasto_pk PRIMARY KEY (grupo_gasto_id)
);
COMMENT ON TABLE sfp.grupo_gasto IS 'Tabla paramétrica del clasificador de gastos del Presupuesto General de la Nación.';
COMMENT ON COLUMN sfp.grupo_gasto.grupo_gasto_id IS 'Clave primaria';
COMMENT ON COLUMN sfp.grupo_gasto.codigo IS 'Código único';
COMMENT ON COLUMN sfp.grupo_gasto.descripcion IS 'Texto descriptivo';
COMMENT ON COLUMN sfp.grupo_gasto.activo IS 'Estado del registro';
COMMENT ON COLUMN sfp.grupo_gasto.usuario_creacion IS 'Nombre de usuario de creación del registro';
COMMENT ON COLUMN sfp.grupo_gasto.fecha_creacion IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN sfp.grupo_gasto.usuario_modificacion IS 'Nombre de usuario que realizó la última modificación del registro';
COMMENT ON COLUMN sfp.grupo_gasto.fecha_modificacion IS 'Fecha y hora de la última modificación del registro';


ALTER SEQUENCE sfp.grupo_gasto_grupo_gasto_id_seq OWNED BY sfp.grupo_gasto.grupo_gasto_id;

CREATE UNIQUE INDEX grupo_gasto_codigo_idx
 ON sfp.grupo_gasto USING BTREE
 ( codigo ASC );

CREATE SEQUENCE sfp.subgrupo_gasto_subgrupo_gasto_id_seq;

CREATE TABLE sfp.subgrupo_gasto (
                subgrupo_gasto_id SMALLINT NOT NULL DEFAULT nextval('sfp.subgrupo_gasto_subgrupo_gasto_id_seq'),
                grupo_gasto_id SMALLINT NOT NULL,
                codigo SMALLINT NOT NULL,
                descripcion VARCHAR(84) NOT NULL,
                activo BOOLEAN DEFAULT true NOT NULL,
                usuario_creacion VARCHAR(16) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
                usuario_modificacion VARCHAR(16),
                fecha_modificacion TIMESTAMP,
                CONSTRAINT subgrupo_gasto_pk PRIMARY KEY (subgrupo_gasto_id)
);
COMMENT ON TABLE sfp.subgrupo_gasto IS 'Tabla paramétrica del clasificador de gastos del Presupuesto General de la Nación.';
COMMENT ON COLUMN sfp.subgrupo_gasto.subgrupo_gasto_id IS 'Clave primaria';
COMMENT ON COLUMN sfp.subgrupo_gasto.grupo_gasto_id IS 'Clave foránea para relacionar con la tabla grupo de gasto';
COMMENT ON COLUMN sfp.subgrupo_gasto.codigo IS 'Código único';
COMMENT ON COLUMN sfp.subgrupo_gasto.descripcion IS 'Texto descriptivo';
COMMENT ON COLUMN sfp.subgrupo_gasto.activo IS 'Estado del registro';
COMMENT ON COLUMN sfp.subgrupo_gasto.usuario_creacion IS 'Nombre de usuario de creación del registro';
COMMENT ON COLUMN sfp.subgrupo_gasto.fecha_creacion IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN sfp.subgrupo_gasto.usuario_modificacion IS 'Nombre de usuario que realizó la última modificación del registro';
COMMENT ON COLUMN sfp.subgrupo_gasto.fecha_modificacion IS 'Fecha y hora de la última modificación del registro';


ALTER SEQUENCE sfp.subgrupo_gasto_subgrupo_gasto_id_seq OWNED BY sfp.subgrupo_gasto.subgrupo_gasto_id;

CREATE INDEX subgrupo_gasto_codigo_idx
 ON sfp.subgrupo_gasto USING BTREE
 ( grupo_gasto_id ASC, codigo ASC );

CREATE SEQUENCE sfp.objeto_gasto_objeto_gasto_id_seq;

CREATE TABLE sfp.objeto_gasto (
                objeto_gasto_id SMALLINT NOT NULL DEFAULT nextval('sfp.objeto_gasto_objeto_gasto_id_seq'),
                subgrupo_gasto_id SMALLINT NOT NULL,
                objeto_gasto SMALLINT NOT NULL,
                concepto_gasto VARCHAR(132) NOT NULL,
                control_financiero_id SMALLINT NOT NULL,
                activo BOOLEAN DEFAULT true NOT NULL,
                usuario_creacion VARCHAR(16) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
                usuario_modificacion VARCHAR(16),
                fecha_modificacion TIMESTAMP,
                CONSTRAINT objeto_gasto_pk PRIMARY KEY (objeto_gasto_id)
);
COMMENT ON TABLE sfp.objeto_gasto IS 'Tabla paramétrica del clasificador de gastos del Presupuesto General de la Nación.';
COMMENT ON COLUMN sfp.objeto_gasto.objeto_gasto_id IS 'Clave primaria';
COMMENT ON COLUMN sfp.objeto_gasto.subgrupo_gasto_id IS 'Clave foránea para relacionar con la tabla subgrupo de gasto';
COMMENT ON COLUMN sfp.objeto_gasto.objeto_gasto IS 'Código único';
COMMENT ON COLUMN sfp.objeto_gasto.concepto_gasto IS 'Texto descriptivo';
COMMENT ON COLUMN sfp.objeto_gasto.control_financiero_id IS 'Clave foránea para relacionar con la tabla control financiero';
COMMENT ON COLUMN sfp.objeto_gasto.activo IS 'Estado del registro';
COMMENT ON COLUMN sfp.objeto_gasto.usuario_creacion IS 'Nombre de usuario de creación del registro';
COMMENT ON COLUMN sfp.objeto_gasto.fecha_creacion IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN sfp.objeto_gasto.usuario_modificacion IS 'Nombre de usuario que realizó la última modificación del registro';
COMMENT ON COLUMN sfp.objeto_gasto.fecha_modificacion IS 'Fecha y hora de la última modificación del registro';


ALTER SEQUENCE sfp.objeto_gasto_objeto_gasto_id_seq OWNED BY sfp.objeto_gasto.objeto_gasto_id;

CREATE INDEX objeto_gasto_codigo_idx
 ON sfp.objeto_gasto USING BTREE
 ( objeto_gasto ASC, objeto_gasto_id ASC );

CREATE SEQUENCE sfp.nacionalidad_naciondalidad_id_seq;

CREATE TABLE sfp.nacionalidad (
                naciondalidad_id SMALLINT NOT NULL DEFAULT nextval('sfp.nacionalidad_naciondalidad_id_seq'),
                codigo CHAR(2) NOT NULL,
                descripcion VARCHAR(16) NOT NULL,
                activo BOOLEAN DEFAULT true NOT NULL,
                usuario_creacion VARCHAR(16) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
                usuario_modificacion VARCHAR(16),
                fecha_modificacion TIMESTAMP,
                CONSTRAINT nacionalidad_pk PRIMARY KEY (naciondalidad_id)
);
COMMENT ON TABLE sfp.nacionalidad IS 'Tabla paramétrica.';
COMMENT ON COLUMN sfp.nacionalidad.naciondalidad_id IS 'Clave primaria';
COMMENT ON COLUMN sfp.nacionalidad.codigo IS 'Código único';
COMMENT ON COLUMN sfp.nacionalidad.descripcion IS 'Texto descriptivo';
COMMENT ON COLUMN sfp.nacionalidad.activo IS 'Estado del registro';
COMMENT ON COLUMN sfp.nacionalidad.usuario_creacion IS 'Nombre de usuario de creación del registro';
COMMENT ON COLUMN sfp.nacionalidad.fecha_creacion IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN sfp.nacionalidad.usuario_modificacion IS 'Nombre de usuario que realizó la última modificación del registro';
COMMENT ON COLUMN sfp.nacionalidad.fecha_modificacion IS 'Fecha y hora de la última modificación del registro';


ALTER SEQUENCE sfp.nacionalidad_naciondalidad_id_seq OWNED BY sfp.nacionalidad.naciondalidad_id;

CREATE UNIQUE INDEX nacionalidad_codigo_idx
 ON sfp.nacionalidad USING BTREE
 ( codigo ASC );

CREATE SEQUENCE sfp.sexo_sexo_id_seq;

CREATE TABLE sfp.sexo (
                sexo_id SMALLINT NOT NULL DEFAULT nextval('sfp.sexo_sexo_id_seq'),
                codigo CHAR(1) NOT NULL,
                descripcion VARCHAR(12) NOT NULL,
                activo BOOLEAN DEFAULT true NOT NULL,
                usuario_creacion VARCHAR(16) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
                usuario_modificacion VARCHAR(16),
                fecha_modificacion TIMESTAMP,
                CONSTRAINT sexo_pk PRIMARY KEY (sexo_id)
);
COMMENT ON TABLE sfp.sexo IS 'Tabla paramétrica.';
COMMENT ON COLUMN sfp.sexo.sexo_id IS 'Clave primaria';
COMMENT ON COLUMN sfp.sexo.codigo IS 'Código único';
COMMENT ON COLUMN sfp.sexo.descripcion IS 'Texto descriptivo';
COMMENT ON COLUMN sfp.sexo.activo IS 'Estado del registro';
COMMENT ON COLUMN sfp.sexo.usuario_creacion IS 'Nombre de usuario de creación del registro';
COMMENT ON COLUMN sfp.sexo.fecha_creacion IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN sfp.sexo.usuario_modificacion IS 'Nombre de usuario que realizó la última modificación del registro';
COMMENT ON COLUMN sfp.sexo.fecha_modificacion IS 'Fecha y hora de la última modificación del registro';


ALTER SEQUENCE sfp.sexo_sexo_id_seq OWNED BY sfp.sexo.sexo_id;

CREATE UNIQUE INDEX sexo_codigo_idx
 ON sfp.sexo USING BTREE
 ( codigo ASC );

CREATE SEQUENCE sfp.estado_estado_id_seq;

CREATE TABLE sfp.estado (
                estado_id SMALLINT NOT NULL DEFAULT nextval('sfp.estado_estado_id_seq'),
                codigo VARCHAR(12) NOT NULL,
                descripcion VARCHAR(96) NOT NULL,
                activo BOOLEAN DEFAULT true NOT NULL,
                usuario_creacion VARCHAR(16) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
                usuario_modificacion VARCHAR(16),
                fecha_modificacion TIMESTAMP,
                CONSTRAINT estado_pk PRIMARY KEY (estado_id)
);
COMMENT ON TABLE sfp.estado IS 'Tabla paramétrica.';
COMMENT ON COLUMN sfp.estado.estado_id IS 'Clave primaria';
COMMENT ON COLUMN sfp.estado.codigo IS 'Código único';
COMMENT ON COLUMN sfp.estado.descripcion IS 'Texto descriptivo';
COMMENT ON COLUMN sfp.estado.activo IS 'Estado del registro';
COMMENT ON COLUMN sfp.estado.usuario_creacion IS 'Nombre de usuario de creación del registro';
COMMENT ON COLUMN sfp.estado.fecha_creacion IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN sfp.estado.usuario_modificacion IS 'Nombre de usuario que realizó la última modificación del registro';
COMMENT ON COLUMN sfp.estado.fecha_modificacion IS 'Fecha y hora de la última modificación del registro';


ALTER SEQUENCE sfp.estado_estado_id_seq OWNED BY sfp.estado.estado_id;

CREATE UNIQUE INDEX estado_codigo_idx
 ON sfp.estado USING BTREE
 ( codigo ASC );

CREATE SEQUENCE sfp.tipo_discapacidad_tipo_discapacidad_id_seq;

CREATE TABLE sfp.tipo_discapacidad (
                tipo_discapacidad_id SMALLINT NOT NULL DEFAULT nextval('sfp.tipo_discapacidad_tipo_discapacidad_id_seq'),
                codigo CHAR(2) NOT NULL,
                descripcion VARCHAR(24) NOT NULL,
                discapacidad BOOLEAN NOT NULL,
                activo BOOLEAN DEFAULT true NOT NULL,
                usuario_creacion VARCHAR(16) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
                usuario_modificacion VARCHAR(16),
                fecha_modificacion TIMESTAMP,
                CONSTRAINT tipo_discapacidad_pk PRIMARY KEY (tipo_discapacidad_id)
);
COMMENT ON TABLE sfp.tipo_discapacidad IS 'Tabla paramétrica.';
COMMENT ON COLUMN sfp.tipo_discapacidad.tipo_discapacidad_id IS 'Clave primaria';
COMMENT ON COLUMN sfp.tipo_discapacidad.codigo IS 'Código único';
COMMENT ON COLUMN sfp.tipo_discapacidad.descripcion IS 'Texto descriptivo';
COMMENT ON COLUMN sfp.tipo_discapacidad.discapacidad IS 'Indica si el funcionario posee o no discapacidad, ya sea permanente o temporal';
COMMENT ON COLUMN sfp.tipo_discapacidad.activo IS 'Estado del registro';
COMMENT ON COLUMN sfp.tipo_discapacidad.usuario_creacion IS 'Nombre de usuario de creación del registro';
COMMENT ON COLUMN sfp.tipo_discapacidad.fecha_creacion IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN sfp.tipo_discapacidad.usuario_modificacion IS 'Nombre de usuario que realizó la última modificación del registro';
COMMENT ON COLUMN sfp.tipo_discapacidad.fecha_modificacion IS 'Fecha y hora de la última modificación del registro';


ALTER SEQUENCE sfp.tipo_discapacidad_tipo_discapacidad_id_seq OWNED BY sfp.tipo_discapacidad.tipo_discapacidad_id;

CREATE UNIQUE INDEX tipo_discapacidad_codigo_idx
 ON sfp.tipo_discapacidad USING BTREE
 ( codigo ASC );

CREATE SEQUENCE sfp.persona_persona_id_seq;

CREATE TABLE sfp.persona (
                persona_id INTEGER NOT NULL DEFAULT nextval('sfp.persona_persona_id_seq'),
                documento VARCHAR(20) NOT NULL,
                nombre VARCHAR(52) NOT NULL,
                apellido VARCHAR(52) NOT NULL,
                fecha_nacimiento DATE,
                sexo_id SMALLINT NOT NULL,
                naciondalidad_id SMALLINT NOT NULL,
                tipo_discapacidad_id SMALLINT NOT NULL,
                activo BOOLEAN DEFAULT true NOT NULL,
                usuario_creacion VARCHAR(16) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
                usuario_modificacion VARCHAR(16),
                fecha_modificacion TIMESTAMP,
                CONSTRAINT persona_pk PRIMARY KEY (persona_id)
);
COMMENT ON TABLE sfp.persona IS 'Tabla para almacenar datos básicos de una persona';
COMMENT ON COLUMN sfp.persona.persona_id IS 'Clave primaria';
COMMENT ON COLUMN sfp.persona.documento IS 'Número de cédula de idéntidad';
COMMENT ON COLUMN sfp.persona.nombre IS 'Nombres del individuo';
COMMENT ON COLUMN sfp.persona.apellido IS 'Apellidos del individuo';
COMMENT ON COLUMN sfp.persona.fecha_nacimiento IS 'Natalicio';
COMMENT ON COLUMN sfp.persona.sexo_id IS 'Clave foránea para relacionar con la tabla sexo';
COMMENT ON COLUMN sfp.persona.naciondalidad_id IS 'Clave foránea para relacionar con la tabla nacionalidad';
COMMENT ON COLUMN sfp.persona.tipo_discapacidad_id IS 'Clave foránea para relacionar con la tipo de discapacidad';
COMMENT ON COLUMN sfp.persona.activo IS 'Estado del registro';
COMMENT ON COLUMN sfp.persona.usuario_creacion IS 'Nombre de usuario de creación del registro';
COMMENT ON COLUMN sfp.persona.fecha_creacion IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN sfp.persona.usuario_modificacion IS 'Nombre de usuario que realizó la última modificación del registro';
COMMENT ON COLUMN sfp.persona.fecha_modificacion IS 'Fecha y hora de la última modificación del registro';


ALTER SEQUENCE sfp.persona_persona_id_seq OWNED BY sfp.persona.persona_id;

CREATE UNIQUE INDEX persona_documento_idx
 ON sfp.persona USING BTREE
 ( documento ASC );

CREATE SEQUENCE sfp.nivel_nivel_id_seq;

CREATE TABLE sfp.nivel (
                nivel_id SMALLINT NOT NULL DEFAULT nextval('sfp.nivel_nivel_id_seq'),
                codigo SMALLINT NOT NULL,
                descripcion VARCHAR(70) NOT NULL,
                activo BOOLEAN DEFAULT true NOT NULL,
                usuario_creacion VARCHAR(16) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
                usuario_modificacion VARCHAR(16),
                fecha_modificacion TIMESTAMP,
                CONSTRAINT nivel_pk PRIMARY KEY (nivel_id)
);
COMMENT ON TABLE sfp.nivel IS 'Tabla que almacena el listado de niveles de la organización del estado Paraguayo.';
COMMENT ON COLUMN sfp.nivel.nivel_id IS 'Clave primeria';
COMMENT ON COLUMN sfp.nivel.codigo IS 'Código único';
COMMENT ON COLUMN sfp.nivel.descripcion IS 'Texto descriptivo';
COMMENT ON COLUMN sfp.nivel.activo IS 'Estado del registro';
COMMENT ON COLUMN sfp.nivel.usuario_creacion IS 'Nombre de usuario de creación del registro';
COMMENT ON COLUMN sfp.nivel.fecha_creacion IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN sfp.nivel.usuario_modificacion IS 'Nombre de usuario que realizó la última modificación del registro';
COMMENT ON COLUMN sfp.nivel.fecha_modificacion IS 'Fecha y hora de la última modificación del registro';


ALTER SEQUENCE sfp.nivel_nivel_id_seq OWNED BY sfp.nivel.nivel_id;

CREATE UNIQUE INDEX nivel_codigo_idx
 ON sfp.nivel USING BTREE
 ( codigo ASC );

CREATE SEQUENCE sfp.entidad_entidad_id_seq;

CREATE TABLE sfp.entidad (
                entidad_id SMALLINT NOT NULL DEFAULT nextval('sfp.entidad_entidad_id_seq'),
                nivel_id SMALLINT NOT NULL,
                codigo SMALLINT NOT NULL,
                descripcion VARCHAR(84) NOT NULL,
                activo BOOLEAN DEFAULT true NOT NULL,
                usuario_creacion VARCHAR(16) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
                usuario_modificacion VARCHAR(16),
                fecha_modificacion TIMESTAMP,
                CONSTRAINT entidad_pk PRIMARY KEY (entidad_id)
);
COMMENT ON TABLE sfp.entidad IS 'Tabla que almacena el listado de entidades. Relacionado con la tabla nivel.';
COMMENT ON COLUMN sfp.entidad.entidad_id IS 'Clave primaria';
COMMENT ON COLUMN sfp.entidad.nivel_id IS 'Clave foránea para relacionar con la tabla nivel';
COMMENT ON COLUMN sfp.entidad.codigo IS 'Código único';
COMMENT ON COLUMN sfp.entidad.descripcion IS 'Texto descriptivo';
COMMENT ON COLUMN sfp.entidad.activo IS 'Estado del registro';
COMMENT ON COLUMN sfp.entidad.usuario_creacion IS 'Nombre de usuario de creación del registro';
COMMENT ON COLUMN sfp.entidad.fecha_creacion IS 'Nombre de usuario de creación del registro';
COMMENT ON COLUMN sfp.entidad.usuario_modificacion IS 'Nombre de usuario que realizó la última modificación del registro';
COMMENT ON COLUMN sfp.entidad.fecha_modificacion IS 'Fecha y hora de la última modificación del registro';


ALTER SEQUENCE sfp.entidad_entidad_id_seq OWNED BY sfp.entidad.entidad_id;

CREATE INDEX entidad_codigo_idx
 ON sfp.entidad USING BTREE
 ( entidad_id ASC, codigo ASC );

CREATE SEQUENCE sfp.oee_oee_id_seq;

CREATE TABLE sfp.oee (
                oee_id SMALLINT NOT NULL DEFAULT nextval('sfp.oee_oee_id_seq'),
                entidad_id SMALLINT NOT NULL,
                codigo SMALLINT NOT NULL,
                descripcion VARCHAR(132) NOT NULL,
                activo BOOLEAN DEFAULT true NOT NULL,
                usuario_creacion VARCHAR(16) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
                usuario_modificacion VARCHAR(16),
                fecha_modificacion TIMESTAMP,
                CONSTRAINT oee_pk PRIMARY KEY (oee_id)
);
COMMENT ON TABLE sfp.oee IS 'Tabla que almacena el listado de los Organismos y Entidades del Estado (OEE).';
COMMENT ON COLUMN sfp.oee.oee_id IS 'Clave primaria';
COMMENT ON COLUMN sfp.oee.entidad_id IS 'Clave foránea para relacionar con la tabla entidad';
COMMENT ON COLUMN sfp.oee.codigo IS 'Código único';
COMMENT ON COLUMN sfp.oee.descripcion IS 'Texto descriptivo';
COMMENT ON COLUMN sfp.oee.activo IS 'Estado del registro';
COMMENT ON COLUMN sfp.oee.usuario_creacion IS 'Nombre de usuario de creación del registro';
COMMENT ON COLUMN sfp.oee.fecha_creacion IS 'Nombre de usuario de creación del registro';
COMMENT ON COLUMN sfp.oee.usuario_modificacion IS 'Nombre de usuario que realizó la última modificación del registro';
COMMENT ON COLUMN sfp.oee.fecha_modificacion IS 'Fecha y hora de la última modificación del registro';


ALTER SEQUENCE sfp.oee_oee_id_seq OWNED BY sfp.oee.oee_id;

CREATE INDEX oee_codigo_idx
 ON sfp.oee USING BTREE
 ( entidad_id ASC, codigo ASC );

CREATE SEQUENCE sfp.funcionario_funcionario_id_seq;

CREATE TABLE sfp.funcionario (
                funcionario_id INTEGER NOT NULL DEFAULT nextval('sfp.funcionario_funcionario_id_seq'),
                persona_id INTEGER NOT NULL,
                oee_id SMALLINT NOT NULL,
                activo BOOLEAN DEFAULT true NOT NULL,
                usuario_creacion VARCHAR(16) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
                usuario_modificacion VARCHAR(16),
                fecha_modificacion TIMESTAMP,
                CONSTRAINT funcionario_pk PRIMARY KEY (funcionario_id)
);
COMMENT ON TABLE sfp.funcionario IS 'Tabla para regitrar los funcionarios públicos de las organizaciones del estado.';
COMMENT ON COLUMN sfp.funcionario.funcionario_id IS 'Clave primaria de la tabla.';
COMMENT ON COLUMN sfp.funcionario.persona_id IS 'Clave foránea para relacionar con la tabla persona';
COMMENT ON COLUMN sfp.funcionario.oee_id IS 'Clave foránea para relacionar con la tabla oee';
COMMENT ON COLUMN sfp.funcionario.activo IS 'Estado del registro';
COMMENT ON COLUMN sfp.funcionario.usuario_creacion IS 'Nombre de usuario de creación del registro';
COMMENT ON COLUMN sfp.funcionario.fecha_creacion IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN sfp.funcionario.usuario_modificacion IS 'Nombre de usuario que realizó la última modificación del registro';
COMMENT ON COLUMN sfp.funcionario.fecha_modificacion IS 'Fecha y hora de la última modificación del registro';


ALTER SEQUENCE sfp.funcionario_funcionario_id_seq OWNED BY sfp.funcionario.funcionario_id;

CREATE INDEX funcionario_fk_idx
 ON sfp.funcionario USING BTREE
 ( persona_id ASC, oee_id ASC );

CREATE SEQUENCE sfp.funcionario_puesto_funcionario_puesto_id_seq;

CREATE TABLE sfp.funcionario_puesto (
                funcionario_puesto_id INTEGER NOT NULL DEFAULT nextval('sfp.funcionario_puesto_funcionario_puesto_id_seq'),
                funcionario_id INTEGER NOT NULL,
                profesion_id SMALLINT NOT NULL,
                cargo_id SMALLINT NOT NULL,
                estado_id SMALLINT NOT NULL,
                anho_ingreso SMALLINT,
                funcion VARCHAR(512),
                activo BOOLEAN DEFAULT true NOT NULL,
                usuario_creacion VARCHAR(16) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
                fecha_modificacion TIMESTAMP,
                usuario_modificacion VARCHAR(16),
                CONSTRAINT funcionario_puesto_pk PRIMARY KEY (funcionario_puesto_id)
);
COMMENT ON TABLE sfp.funcionario_puesto IS 'Tabla que relaciona un funcionario con uno más cargos públicos ocupados en una organización.';
COMMENT ON COLUMN sfp.funcionario_puesto.funcionario_puesto_id IS 'Clave primaria';
COMMENT ON COLUMN sfp.funcionario_puesto.funcionario_id IS 'Clave foránea para relacionar con la tabla funcionario';
COMMENT ON COLUMN sfp.funcionario_puesto.profesion_id IS 'Clave foránea para relacionar con la tabla profesion';
COMMENT ON COLUMN sfp.funcionario_puesto.cargo_id IS 'Clave foránea para relacionar con la tabla cargo';
COMMENT ON COLUMN sfp.funcionario_puesto.anho_ingreso IS 'Año de ingreso del funcionario a ocupar el cargo público';
COMMENT ON COLUMN sfp.funcionario_puesto.funcion IS 'Texto descriptivo';
COMMENT ON COLUMN sfp.funcionario_puesto.activo IS 'Estado del registro';
COMMENT ON COLUMN sfp.funcionario_puesto.usuario_creacion IS 'Nombre de usuario de creación del registro';
COMMENT ON COLUMN sfp.funcionario_puesto.fecha_creacion IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN sfp.funcionario_puesto.fecha_modificacion IS 'Fecha y hora de la última modificación del registro';
COMMENT ON COLUMN sfp.funcionario_puesto.usuario_modificacion IS 'Nombre de usuario que realizó la última modificación del registro';


ALTER SEQUENCE sfp.funcionario_puesto_funcionario_puesto_id_seq OWNED BY sfp.funcionario_puesto.funcionario_puesto_id;

CREATE INDEX funcionario_puesto_fk_idx
 ON sfp.funcionario_puesto USING BTREE
 ( funcionario_id ASC, cargo_id ASC, anho_ingreso ASC );

CREATE SEQUENCE sfp.remuneracion_cabecera_remuneracion_cabecera_id_seq;

CREATE TABLE sfp.remuneracion_cabecera (
                remuneracion_cabecera_id BIGINT NOT NULL DEFAULT nextval('sfp.remuneracion_cabecera_remuneracion_cabecera_id_seq'),
                periodo_id SMALLINT NOT NULL,
                funcionario_puesto_id INTEGER NOT NULL,
                total_haberes BIGINT NOT NULL,
                total_devengado BIGINT NOT NULL,
                total_descuentos BIGINT NOT NULL,
                activo BOOLEAN DEFAULT true NOT NULL,
                usuario_creacion VARCHAR(16) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
                usuario_modificacion VARCHAR(16),
                fecha_modificacion TIMESTAMP,
                CONSTRAINT remuneracion_cabecera_pk PRIMARY KEY (remuneracion_cabecera_id)
);
COMMENT ON TABLE sfp.remuneracion_cabecera IS 'Tabla que registra las cabeceras de las transacciones de pagos de salarios y otros a los funcionarios públicos.';
COMMENT ON COLUMN sfp.remuneracion_cabecera.remuneracion_cabecera_id IS 'Clave primaria';
COMMENT ON COLUMN sfp.remuneracion_cabecera.periodo_id IS 'Clave foránea para relacionar con la tabla periodo';
COMMENT ON COLUMN sfp.remuneracion_cabecera.funcionario_puesto_id IS 'Clave foránea para relacionar con la tabla funcionario_puesto';
COMMENT ON COLUMN sfp.remuneracion_cabecera.total_haberes IS 'Sumatoria montos haberes';
COMMENT ON COLUMN sfp.remuneracion_cabecera.total_devengado IS 'Sumatoria montos devengados';
COMMENT ON COLUMN sfp.remuneracion_cabecera.total_descuentos IS 'Sumatoria descuentos';
COMMENT ON COLUMN sfp.remuneracion_cabecera.activo IS 'Estado del registro';
COMMENT ON COLUMN sfp.remuneracion_cabecera.usuario_creacion IS 'Nombre de usuario de creación del registro';
COMMENT ON COLUMN sfp.remuneracion_cabecera.fecha_creacion IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN sfp.remuneracion_cabecera.usuario_modificacion IS 'Nombre de usuario que realizó la última modificación del registro';
COMMENT ON COLUMN sfp.remuneracion_cabecera.fecha_modificacion IS 'Fecha y hora de la última modificación del registro';


ALTER SEQUENCE sfp.remuneracion_cabecera_remuneracion_cabecera_id_seq OWNED BY sfp.remuneracion_cabecera.remuneracion_cabecera_id;

CREATE INDEX remuneracion_cabecera_fk_idx
 ON sfp.remuneracion_cabecera USING BTREE
 ( periodo_id ASC, funcionario_puesto_id ASC );

CREATE SEQUENCE sfp.remuneracion_detalle_remuneracion_detalle_id_seq;

CREATE TABLE sfp.remuneracion_detalle (
                remuneracion_detalle_id BIGINT NOT NULL DEFAULT nextval('sfp.remuneracion_detalle_remuneracion_detalle_id_seq'),
                remuneracion_cabecera_id BIGINT NOT NULL,
                fuente_financiamiento_id SMALLINT NOT NULL,
                objeto_gasto_id SMALLINT NOT NULL,
                linea INTEGER NOT NULL,
                categoria VARCHAR(16) NOT NULL,
                monto_haberes BIGINT NOT NULL,
                monto_devengado BIGINT NOT NULL,
                monto_descuentos BIGINT NOT NULL,
                activo BOOLEAN DEFAULT true NOT NULL,
                usuario_creacion VARCHAR(16) NOT NULL,
                fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
                usuario_modificacion VARCHAR(16),
                fecha_modificacion TIMESTAMP,
                CONSTRAINT remuneracion_detalle_pk PRIMARY KEY (remuneracion_detalle_id)
);
COMMENT ON TABLE sfp.remuneracion_detalle IS 'Tabla que registra los detalles de las transacciones de pagos de salarios y otros a los funcionarios públicos.';
COMMENT ON COLUMN sfp.remuneracion_detalle.remuneracion_detalle_id IS 'Clave primaria';
COMMENT ON COLUMN sfp.remuneracion_detalle.remuneracion_cabecera_id IS 'Clave foránea para relacionar con la tabla remuneracion_cabecera';
COMMENT ON COLUMN sfp.remuneracion_detalle.fuente_financiamiento_id IS 'Clave foránea para relacionar con la tabla fuente_financiamiento';
COMMENT ON COLUMN sfp.remuneracion_detalle.objeto_gasto_id IS 'Clave foránea para relacionar con la tabla objeto_gasto';
COMMENT ON COLUMN sfp.remuneracion_detalle.linea IS 'Define la ubicación dentro de la estructura organizativa';
COMMENT ON COLUMN sfp.remuneracion_detalle.categoria IS 'Establece el nivel de responsabilidad y competencia para un puesto en una institución pública en Paraguay';
COMMENT ON COLUMN sfp.remuneracion_detalle.monto_haberes IS 'Monto presupuestado';
COMMENT ON COLUMN sfp.remuneracion_detalle.monto_devengado IS 'Monto desembolsado';
COMMENT ON COLUMN sfp.remuneracion_detalle.monto_descuentos IS 'Monto descuentos';
COMMENT ON COLUMN sfp.remuneracion_detalle.activo IS 'Estado del registro';
COMMENT ON COLUMN sfp.remuneracion_detalle.usuario_creacion IS 'Nombre de usuario de creación del registro';
COMMENT ON COLUMN sfp.remuneracion_detalle.fecha_creacion IS 'Fecha y hora de creación del registro';
COMMENT ON COLUMN sfp.remuneracion_detalle.usuario_modificacion IS 'Nombre de usuario que realizó la última modificación del registro';
COMMENT ON COLUMN sfp.remuneracion_detalle.fecha_modificacion IS 'Fecha y hora de la última modificación del registro';


ALTER SEQUENCE sfp.remuneracion_detalle_remuneracion_detalle_id_seq OWNED BY sfp.remuneracion_detalle.remuneracion_detalle_id;

CREATE INDEX remuneracion_detalle_fk_idx
 ON sfp.remuneracion_detalle USING BTREE
 ( remuneracion_cabecera_id ASC, fuente_financiamiento_id ASC, objeto_gasto_id ASC, linea ASC, categoria ASC );

ALTER TABLE sfp.remuneracion_cabecera ADD CONSTRAINT periodo_remuneracion_cabecera_fk
FOREIGN KEY (periodo_id)
REFERENCES sfp.periodo (periodo_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE sfp.funcionario_puesto ADD CONSTRAINT profesion_funcionario_puesto_fk
FOREIGN KEY (profesion_id)
REFERENCES sfp.profesion (profesion_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE sfp.remuneracion_detalle ADD CONSTRAINT fuente_financiamiento_remuneracion_detalle_fk
FOREIGN KEY (fuente_financiamiento_id)
REFERENCES sfp.fuente_financiamiento (fuente_financiamiento_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE sfp.funcionario_puesto ADD CONSTRAINT cargo_funcionario_cargo_fk
FOREIGN KEY (cargo_id)
REFERENCES sfp.cargo (cargo_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE sfp.objeto_gasto ADD CONSTRAINT control_financiero_objeto_gasto_fk
FOREIGN KEY (control_financiero_id)
REFERENCES sfp.control_financiero (control_financiero_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE sfp.subgrupo_gasto ADD CONSTRAINT grupo_gasto_subgrupo_gasto_fk
FOREIGN KEY (grupo_gasto_id)
REFERENCES sfp.grupo_gasto (grupo_gasto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE sfp.objeto_gasto ADD CONSTRAINT subgrupo_gasto_objeto_gasto_fk
FOREIGN KEY (subgrupo_gasto_id)
REFERENCES sfp.subgrupo_gasto (subgrupo_gasto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE sfp.remuneracion_detalle ADD CONSTRAINT objeto_gasto_remuneracion_detalle_fk
FOREIGN KEY (objeto_gasto_id)
REFERENCES sfp.objeto_gasto (objeto_gasto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE sfp.persona ADD CONSTRAINT nacionalidad_persona_fk
FOREIGN KEY (naciondalidad_id)
REFERENCES sfp.nacionalidad (naciondalidad_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE sfp.persona ADD CONSTRAINT sexo_persona_fk
FOREIGN KEY (sexo_id)
REFERENCES sfp.sexo (sexo_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE sfp.funcionario_puesto ADD CONSTRAINT estado_funcionario_puesto_fk
FOREIGN KEY (estado_id)
REFERENCES sfp.estado (estado_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE sfp.persona ADD CONSTRAINT tipo_discapacidad_persona_fk
FOREIGN KEY (tipo_discapacidad_id)
REFERENCES sfp.tipo_discapacidad (tipo_discapacidad_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE sfp.funcionario ADD CONSTRAINT persona_funcionario_fk
FOREIGN KEY (persona_id)
REFERENCES sfp.persona (persona_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE sfp.entidad ADD CONSTRAINT nivel_entidad_fk
FOREIGN KEY (nivel_id)
REFERENCES sfp.nivel (nivel_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE sfp.oee ADD CONSTRAINT entidad_oee_fk
FOREIGN KEY (entidad_id)
REFERENCES sfp.entidad (entidad_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE sfp.funcionario ADD CONSTRAINT oee_funcionario_fk
FOREIGN KEY (oee_id)
REFERENCES sfp.oee (oee_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE sfp.funcionario_puesto ADD CONSTRAINT funcionario_funcionario_cargo_fk
FOREIGN KEY (funcionario_id)
REFERENCES sfp.funcionario (funcionario_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE sfp.remuneracion_cabecera ADD CONSTRAINT funcionario_puesto_remuneracion_cabecera_fk
FOREIGN KEY (funcionario_puesto_id)
REFERENCES sfp.funcionario_puesto (funcionario_puesto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE sfp.remuneracion_detalle ADD CONSTRAINT remuneracion_cabecera_remuneracion_detalle_fk
FOREIGN KEY (remuneracion_cabecera_id)
REFERENCES sfp.remuneracion_cabecera (remuneracion_cabecera_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;