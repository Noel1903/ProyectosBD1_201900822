CREATE TABLE categorias (
    id_categoria INTEGER NOT NULL,
    nombre       CHAR(30)
);

ALTER TABLE categorias ADD CONSTRAINT categorias_pk PRIMARY KEY ( id_categoria );

CREATE TABLE clientes (
    id_cliente INTEGER NOT NULL,
    nombre     CHAR(30),
    apellido   CHAR(30),
    direccion  CHAR(100),
    telefono   CHAR(10),
    tarjeta    CHAR(21),
    edad       INTEGER,
    salario    INTEGER,
    genero     CHAR(1),
    id_pais    INTEGER NOT NULL
);

ALTER TABLE clientes ADD CONSTRAINT clientes_pk PRIMARY KEY ( id_cliente );

CREATE TABLE detalle_orden (
    id_dorden   INTEGER NOT NULL,
    id_orden    INTEGER NOT NULL,
    linea_orden INTEGER,
    id_vendedor INTEGER NOT NULL,
    id_producto INTEGER NOT NULL,
    cantidad    INTEGER
);

ALTER TABLE detalle_orden ADD CONSTRAINT detalle_orden_pk PRIMARY KEY ( id_dorden );

CREATE TABLE ordenes (
    id_orden   INTEGER NOT NULL,
    fecha      CHAR(10),
    id_cliente INTEGER NOT NULL
);

ALTER TABLE ordenes ADD CONSTRAINT ordenes_pk PRIMARY KEY ( id_orden );

CREATE TABLE paises (
    id_pais INTEGER NOT NULL,
    nombre  CHAR(30)
);

ALTER TABLE paises ADD CONSTRAINT paises_pk PRIMARY KEY ( id_pais );

CREATE TABLE productos (
    id_producto  INTEGER NOT NULL,
    nombre       CHAR(100),
    precio       FLOAT(2),
    id_categoria INTEGER NOT NULL
);

ALTER TABLE productos ADD CONSTRAINT productos_pk PRIMARY KEY ( id_producto );

CREATE TABLE vendedores (
    id_vendedor INTEGER NOT NULL,
    nombre      CHAR(100),
    id_pais     INTEGER NOT NULL
);

ALTER TABLE vendedores ADD CONSTRAINT vendedores_pk PRIMARY KEY ( id_vendedor );

ALTER TABLE productos
    ADD CONSTRAINT table_4_categorias_fk FOREIGN KEY ( id_categoria )
        REFERENCES categorias ( id_categoria );

ALTER TABLE vendedores
    ADD CONSTRAINT table_6_paises_fk FOREIGN KEY ( id_pais )
        REFERENCES paises ( id_pais );

ALTER TABLE ordenes
    ADD CONSTRAINT table_7_clientes_fk FOREIGN KEY ( id_cliente )
        REFERENCES clientes ( id_cliente );

ALTER TABLE clientes
    ADD CONSTRAINT table_7_paises_fk FOREIGN KEY ( id_pais )
        REFERENCES paises ( id_pais );

ALTER TABLE detalle_orden
    ADD CONSTRAINT table_8_ordenes_fk FOREIGN KEY ( id_orden )
        REFERENCES ordenes ( id_orden );

ALTER TABLE detalle_orden
    ADD CONSTRAINT table_8_productos_fk FOREIGN KEY ( id_producto )
        REFERENCES productos ( id_producto );

ALTER TABLE detalle_orden
    ADD CONSTRAINT table_8_vendedores_fk FOREIGN KEY ( id_vendedor )
        REFERENCES vendedores ( id_vendedor );

SET SQL_SAFE_UPDATES = 0;