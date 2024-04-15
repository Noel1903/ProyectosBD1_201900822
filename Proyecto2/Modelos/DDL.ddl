-- Generado por Oracle SQL Developer Data Modeler 23.1.0.087.0806
--   en:        2024-04-12 13:01:20 CST
--   sitio:      Oracle Database 21c
--   tipo:      Oracle Database 21c



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE cliente (
    id_cliente   INTEGER NOT NULL,
    nombre       VARCHAR2(40) NOT NULL,
    apellidos    VARCHAR2(40),
    telefono     VARCHAR2(12) NOT NULL,
    correo       VARCHAR2(40) NOT NULL,
    usuario      VARCHAR2(40) NOT NULL,
    contraseña   VARCHAR2(200) NOT NULL,
    tipo_cliente INTEGER NOT NULL
);

ALTER TABLE cliente ADD CONSTRAINT cliente_pk PRIMARY KEY ( id_cliente );

CREATE TABLE compra (
    id_compra        INTEGER NOT NULL,
    fecha            DATE NOT NULL,
    importe_compra   NUMBER(12, 2),
    otros_detalles   VARCHAR2(40),
    codigo_prod_serv INTEGER NOT NULL,
    id_cliente       INTEGER NOT NULL
);

ALTER TABLE compra ADD CONSTRAINT compra_pk PRIMARY KEY ( id_compra );

CREATE TABLE cuenta (
    id_cuenta      INTEGER NOT NULL,
    monto_apertura NUMBER(12, 2) NOT NULL,
    saldo_cuenta   NUMBER(12, 2) NOT NULL,
    descripcion    VARCHAR2(50) NOT NULL,
    fecha_apertura DATE NOT NULL,
    otros_detalles VARCHAR2(100),
    tipo_cuenta    INTEGER NOT NULL,
    id_cliente     INTEGER NOT NULL
);

ALTER TABLE cuenta ADD CONSTRAINT cuenta_pk PRIMARY KEY ( id_cuenta );

CREATE TABLE debito (
    id_debito      INTEGER NOT NULL,
    fecha          DATE NOT NULL,
    monto          NUMBER(12, 2) NOT NULL,
    otros_detalles VARCHAR2(40),
    id_cliente     INTEGER NOT NULL
);

ALTER TABLE debito ADD CONSTRAINT debito_pk PRIMARY KEY ( id_debito );

CREATE TABLE deposito (
    id_deposito    INTEGER NOT NULL,
    fecha          DATE NOT NULL,
    monto          NUMBER(12, 2) NOT NULL,
    otros_detalles VARCHAR2(40),
    id_cliente     INTEGER NOT NULL
);

ALTER TABLE deposito ADD CONSTRAINT deposito_pk PRIMARY KEY ( id_deposito );

CREATE TABLE producto_servicio (
    codigo_prod_serv      INTEGER NOT NULL,
    tipo                  INTEGER NOT NULL,
    costo                 NUMBER(12, 2),
    descripcion_prod_serv VARCHAR2(100)
);

ALTER TABLE producto_servicio ADD CONSTRAINT producto_servicio_pk PRIMARY KEY ( codigo_prod_serv );

CREATE TABLE tipo_cliente (
    id_tipo     INTEGER NOT NULL,
    nombre      VARCHAR2(20) NOT NULL,
    descripcion VARCHAR2(40) NOT NULL
);

ALTER TABLE tipo_cliente ADD CONSTRAINT tipo_cliente_pk PRIMARY KEY ( id_tipo );

CREATE TABLE tipo_cuenta (
    codigo      INTEGER NOT NULL,
    nombre      VARCHAR2(20) NOT NULL,
    descripcion VARCHAR2(100) NOT NULL
);

ALTER TABLE tipo_cuenta ADD CONSTRAINT tipo_cuenta_pk PRIMARY KEY ( codigo );

CREATE TABLE tipo_transaccion (
    codigo_transaccion INTEGER NOT NULL,
    nombre             VARCHAR2(20) NOT NULL,
    descripcion        VARCHAR2(40) NOT NULL
);

ALTER TABLE tipo_transaccion ADD CONSTRAINT tipo_transaccion_pk PRIMARY KEY ( codigo_transaccion );

CREATE TABLE transaccion (
    id_transaccion      INTEGER NOT NULL,
    fecha               DATE NOT NULL,
    otros_detalles      VARCHAR2(40),
    id_tipo_transaccion INTEGER NOT NULL,
    id_compra           INTEGER NOT NULL,
    id_deposito         INTEGER NOT NULL,
    id_debito           INTEGER NOT NULL,
    no_cuenta           INTEGER NOT NULL
);

ALTER TABLE transaccion ADD CONSTRAINT transaccion_pk PRIMARY KEY ( id_transaccion );

ALTER TABLE cliente
    ADD CONSTRAINT cliente_tipo_cliente_fk FOREIGN KEY ( tipo_cliente )
        REFERENCES tipo_cliente ( id_tipo );

ALTER TABLE compra
    ADD CONSTRAINT compra_cliente_fk FOREIGN KEY ( id_cliente )
        REFERENCES cliente ( id_cliente );

ALTER TABLE compra
    ADD CONSTRAINT compra_producto_servicio_fk FOREIGN KEY ( codigo_prod_serv )
        REFERENCES producto_servicio ( codigo_prod_serv );

ALTER TABLE cuenta
    ADD CONSTRAINT cuenta_cliente_fk FOREIGN KEY ( id_cliente )
        REFERENCES cliente ( id_cliente );

ALTER TABLE cuenta
    ADD CONSTRAINT cuenta_tipo_cuenta_fk FOREIGN KEY ( tipo_cuenta )
        REFERENCES tipo_cuenta ( codigo );

ALTER TABLE debito
    ADD CONSTRAINT debito_cliente_fk FOREIGN KEY ( id_cliente )
        REFERENCES cliente ( id_cliente );

ALTER TABLE deposito
    ADD CONSTRAINT deposito_cliente_fk FOREIGN KEY ( id_cliente )
        REFERENCES cliente ( id_cliente );

ALTER TABLE transaccion
    ADD CONSTRAINT transaccion_compra_fk FOREIGN KEY ( id_compra )
        REFERENCES compra ( id_compra );

ALTER TABLE transaccion
    ADD CONSTRAINT transaccion_debito_fk FOREIGN KEY ( id_debito )
        REFERENCES debito ( id_debito );

ALTER TABLE transaccion
    ADD CONSTRAINT transaccion_deposito_fk FOREIGN KEY ( id_deposito )
        REFERENCES deposito ( id_deposito );

--  ERROR: FK name length exceeds maximum allowed length(30) 
ALTER TABLE transaccion
    ADD CONSTRAINT transaccion_tipo_transaccion_fk FOREIGN KEY ( id_tipo_transaccion )
        REFERENCES tipo_transaccion ( codigo_transaccion );

CREATE SEQUENCE tipo_cliente_id_tipo_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tipo_cliente_id_tipo_trg BEFORE
    INSERT ON tipo_cliente
    FOR EACH ROW
    WHEN ( new.id_tipo IS NULL )
BEGIN
    :new.id_tipo := tipo_cliente_id_tipo_seq.nextval;
END;
/

CREATE SEQUENCE tipo_cuenta_codigo_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tipo_cuenta_codigo_trg BEFORE
    INSERT ON tipo_cuenta
    FOR EACH ROW
    WHEN ( new.codigo IS NULL )
BEGIN
    :new.codigo := tipo_cuenta_codigo_seq.nextval;
END;
/

CREATE SEQUENCE tipo_transaccion_codigo_transa START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tipo_transaccion_codigo_transa BEFORE
    INSERT ON tipo_transaccion
    FOR EACH ROW
    WHEN ( new.codigo_transaccion IS NULL )
BEGIN
    :new.codigo_transaccion := tipo_transaccion_codigo_transa.nextval;
END;
/

CREATE SEQUENCE transaccion_id_transaccion_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER transaccion_id_transaccion_trg BEFORE
    INSERT ON transaccion
    FOR EACH ROW
    WHEN ( new.id_transaccion IS NULL )
BEGIN
    :new.id_transaccion := transaccion_id_transaccion_seq.nextval;
END;
/



-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            10
-- CREATE INDEX                             0
-- ALTER TABLE                             21
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           4
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          4
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   1
-- WARNINGS                                 0
