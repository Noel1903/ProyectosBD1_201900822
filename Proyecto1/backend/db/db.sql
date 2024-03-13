-- Generado por Oracle SQL Developer Data Modeler 23.1.0.087.0806
--   en:        2024-03-11 17:57:19 CST
--   sitio:      SQL Server 2012
--   tipo:      SQL Server 2012

CREATE TABLE categorias 
    (
     id_categoria INTEGER NOT NULL , 
     nombre CHAR (30) 
    );

ALTER TABLE categorias ADD CONSTRAINT categorias_PK PRIMARY KEY CLUSTERED (id_categoria);

CREATE TABLE clientes 
    (
     id_cliente INTEGER NOT NULL , 
     Nombre CHAR (30) , 
     Apellido CHAR (30) , 
     Direccion CHAR (100) , 
     Telefono CHAR (10) , 
     Tarjeta CHAR (21) , 
     Edad INTEGER , 
     Salario INTEGER , 
     Genero CHAR (1) , 
     id_pais INTEGER NOT NULL 
    );

ALTER TABLE clientes ADD CONSTRAINT clientes_PK PRIMARY KEY CLUSTERED (id_cliente);

CREATE TABLE ordenes 
    (
     id_orden INTEGER NOT NULL , 
     linea_orden INTEGER , 
     fecha_orden DATE , 
     id_cliente INTEGER NOT NULL , 
     id_vendedor INTEGER NOT NULL , 
     id_producto INTEGER NOT NULL , 
     cantidad INTEGER 
    );

ALTER TABLE ordenes ADD CONSTRAINT ordenes_PK PRIMARY KEY CLUSTERED (id_orden);

CREATE TABLE paises 
    (
     id_pais INTEGER NOT NULL , 
     nombre CHAR (30) 
    );

ALTER TABLE paises ADD CONSTRAINT paises_PK PRIMARY KEY CLUSTERED (id_pais);

CREATE TABLE productos 
    (
     id_producto INTEGER NOT NULL , 
     Nombre CHAR (100) , 
     Precio FLOAT (2) , 
     id_categoria INTEGER NOT NULL 
    );

ALTER TABLE productos ADD CONSTRAINT productos_PK PRIMARY KEY CLUSTERED (id_producto);

CREATE TABLE vendedores 
    (
     id_vendedor INTEGER NOT NULL , 
     nombre CHAR (100) , 
     id_pais INTEGER NOT NULL 
    );

ALTER TABLE vendedores ADD CONSTRAINT vendedores_PK PRIMARY KEY CLUSTERED (id_vendedor);


ALTER TABLE ordenes 
    ADD CONSTRAINT ordenes_productos_FK FOREIGN KEY 
    ( 
     id_producto
    ) 
    REFERENCES productos 
    ( 
     id_producto 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION ;

ALTER TABLE ordenes 
    ADD CONSTRAINT ordenes_vendedores_FK FOREIGN KEY 
    ( 
     id_vendedor
    ) 
    REFERENCES vendedores 
    ( 
     id_vendedor 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION ;

ALTER TABLE productos 
    ADD CONSTRAINT TABLE_4_categorias_FK FOREIGN KEY 
    ( 
     id_categoria
    ) 
    REFERENCES categorias 
    ( 
     id_categoria 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION ;
ALTER TABLE vendedores 
    ADD CONSTRAINT TABLE_6_paises_FK FOREIGN KEY 
    ( 
     id_pais
    ) 
    REFERENCES paises 
    ( 
     id_pais 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION ;
ALTER TABLE clientes 
    ADD CONSTRAINT TABLE_7_paises_FK FOREIGN KEY 
    ( 
     id_pais
    ) 
    REFERENCES paises 
    ( 
     id_pais 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION;

ALTER TABLE ordenes 
    ADD CONSTRAINT TABLE_8_clientes_FK FOREIGN KEY 
    ( 
     id_cliente
    ) 
    REFERENCES clientes 
    ( 
     id_cliente 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION ;






-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                             6
-- CREATE INDEX                             0
-- ALTER TABLE                             12
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE DATABASE                          0
-- CREATE DEFAULT                           0
-- CREATE INDEX ON VIEW                     0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE ROLE                              0
-- CREATE RULE                              0
-- CREATE SCHEMA                            0
-- CREATE SEQUENCE                          0
-- CREATE PARTITION FUNCTION                0
-- CREATE PARTITION SCHEME                  0
-- 
-- DROP DATABASE                            0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
