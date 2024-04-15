CREATE TABLE cliente (
    id_cliente   INTEGER NOT NULL,
    nombre       VARCHAR(40) NOT NULL,
    apellidos    VARCHAR(40),
    telefono     VARCHAR(12) NOT NULL,
    correo       VARCHAR(40) NOT NULL,
    usuario      VARCHAR(40) NOT NULL,
    contraseña   VARCHAR(200) NOT NULL,
    tipo_cliente INTEGER NOT NULL
);

ALTER TABLE cliente ADD CONSTRAINT cliente_pk PRIMARY KEY ( id_cliente );

CREATE TABLE compra (
    id_compra        INTEGER NOT NULL,
    fecha            DATE NOT NULL,
    importe_compra   DECIMAL(12, 2),
    otros_detalles   VARCHAR(40),
    codigo_prod_serv INTEGER NOT NULL,
    id_cliente       INTEGER NOT NULL
);

ALTER TABLE compra ADD CONSTRAINT compra_pk PRIMARY KEY ( id_compra );

CREATE TABLE cuenta (
    id_cuenta      INTEGER NOT NULL,
    monto_apertura DECIMAL(12, 2) NOT NULL,
    saldo_cuenta   DECIMAL(12, 2) NOT NULL,
    descripcion    VARCHAR(50) NOT NULL,
    fecha_apertura DATE NOT NULL,
    otros_detalles VARCHAR(100),
    tipo_cuenta    INTEGER NOT NULL,
    id_cliente     INTEGER NOT NULL
);

ALTER TABLE cuenta ADD CONSTRAINT cuenta_pk PRIMARY KEY ( id_cuenta );

CREATE TABLE debito (
    id_debito      INTEGER NOT NULL,
    fecha          DATE NOT NULL,
    monto          DECIMAL(12, 2) NOT NULL,
    otros_detalles VARCHAR(40),
    id_cliente     INTEGER NOT NULL
);

ALTER TABLE debito ADD CONSTRAINT debito_pk PRIMARY KEY ( id_debito );

CREATE TABLE deposito (
    id_deposito    INTEGER NOT NULL,
    fecha          DATE NOT NULL,
    monto          DECIMAL(12, 2) NOT NULL,
    otros_detalles VARCHAR(40),
    id_cliente     INTEGER NOT NULL
);

ALTER TABLE deposito ADD CONSTRAINT deposito_pk PRIMARY KEY ( id_deposito );

CREATE TABLE producto_servicio (
    codigo_prod_serv      INTEGER NOT NULL,
    tipo                  INTEGER NOT NULL,
    costo                 DECIMAL(12, 2),
    descripcion_prod_serv VARCHAR(100)
);

ALTER TABLE producto_servicio ADD CONSTRAINT producto_servicio_pk PRIMARY KEY ( codigo_prod_serv );

CREATE TABLE tipo_cliente (
    id_tipo     INTEGER AUTO_INCREMENT PRIMARY KEY NOT NULL ,
    nombre      VARCHAR(20) NOT NULL,
    descripcion VARCHAR(40) NOT NULL
);

#ALTER TABLE tipo_cliente ADD CONSTRAINT tipo_cliente_pk PRIMARY KEY ( id_tipo );

CREATE TABLE tipo_cuenta (
    codigo      INTEGER AUTO_INCREMENT PRIMARY KEY NOT NULL,
    nombre      VARCHAR(20) NOT NULL,
    descripcion VARCHAR(100) NOT NULL
);

#ALTER TABLE tipo_cuenta ADD CONSTRAINT tipo_cuenta_pk PRIMARY KEY ( codigo );

CREATE TABLE tipo_transaccion (
    codigo_transaccion INTEGER AUTO_INCREMENT PRIMARY KEY NOT NULL,
    nombre             VARCHAR(20) NOT NULL,
    descripcion        VARCHAR(40) NOT NULL
);

#ALTER TABLE tipo_transaccion ADD CONSTRAINT tipo_transaccion_pk PRIMARY KEY ( codigo_transaccion );

CREATE TABLE transaccion (
    id_transaccion      INTEGER AUTO_INCREMENT PRIMARY KEY NOT NULL,
    fecha               DATE NOT NULL,
    otros_detalles      VARCHAR(40),
    id_tipo_transaccion INTEGER NOT NULL,
    id_compra           INTEGER NOT NULL,
    id_deposito         INTEGER NOT NULL,
    id_debito           INTEGER NOT NULL,
    no_cuenta           INTEGER NOT NULL
);

#ALTER TABLE transaccion ADD CONSTRAINT transaccion_pk PRIMARY KEY ( id_transaccion );

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

ALTER TABLE transaccion
    ADD CONSTRAINT transaccion_tipo_transaccion_fk FOREIGN KEY ( id_tipo_transaccion )
        REFERENCES tipo_transaccion ( codigo_transaccion );