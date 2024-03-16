/*Mostrar el cliente que más ha comprado. Se debe de mostrar el id del cliente, 
nombre, apellido, país y monto total.*/

const query1 = 
`SELECT c.id_cliente,c.nombre,c.apellido,p.nombre,
ROUND(SUM(prd.precio * dor.cantidad),2) AS Monto,
COUNT(c.id_cliente) AS numveces
FROM clientes c
INNER JOIN paises p
ON c.id_pais = p.id_pais
INNER JOIN ordenes o 
ON c.id_cliente = o.id_cliente
INNER JOIN detalle_orden dor
ON o.id_orden = dor.id_orden
INNER JOIN productos prd
ON dor.id_producto = prd.id_producto
GROUP BY c.id_cliente
ORDER BY numveces DESC
LIMIT 1`;

/*Mostrar el producto más y menos comprado. 
Se debe mostrar el id del producto, nombre del producto, categoría, 
cantidad de unidades y monto vendido.*/

const query2 =
`SELECT id_producto, nombre_producto, categoria, cantidad_unidades, monto_vendido
FROM (
    SELECT prd.id_producto, prd.nombre AS nombre_producto, c.nombre AS categoria,
           SUM(dto.cantidad) AS cantidad_unidades,
           ROUND(SUM(prd.precio * dto.cantidad),2) AS monto_vendido
    FROM productos prd
    INNER JOIN categorias c ON prd.id_categoria = c.id_categoria
    INNER JOIN detalle_orden dto ON prd.id_producto = dto.id_producto
    GROUP BY prd.id_producto, prd.nombre, c.nombre
    ORDER BY cantidad_unidades DESC
    LIMIT 1
) AS subquery1

UNION

SELECT id_producto, nombre_producto, categoria, cantidad_unidades, monto_vendido
FROM (
    SELECT prd.id_producto, prd.nombre AS nombre_producto, c.nombre AS categoria,
           SUM(dto.cantidad) AS cantidad_unidades,
           ROUND(SUM(prd.precio * dto.cantidad),2) AS monto_vendido
    FROM productos prd
    INNER JOIN categorias c ON prd.id_categoria = c.id_categoria
    INNER JOIN detalle_orden dto ON prd.id_producto = dto.id_producto
    GROUP BY prd.id_producto, prd.nombre, c.nombre
    ORDER BY cantidad_unidades ASC
    LIMIT 1
) AS subquery2;`;



const query3 =
`SELECT v.id_vendedor,v.nombre,
ROUND(SUM(prd.precio * dto.cantidad),2) AS monto_total
FROM vendedores v
INNER JOIN detalle_orden dto
ON v.id_vendedor = dto.id_vendedor
INNER JOIN productos prd
ON dto.id_producto = prd.id_producto
GROUP BY v.id_vendedor
ORDER BY SUM(dto.cantidad) DESC
LIMIT 1;
`;

const query4 =
`SELECT nombre_pais, monto_total
FROM (
	SELECT p.nombre AS nombre_pais,
    ROUND(SUM(prd.precio * dto.cantidad),2) AS monto_total
    FROM paises p
    INNER JOIN vendedores v
    ON p.id_pais = v.id_pais
    INNER JOIN detalle_orden dto
    ON v.id_vendedor = dto.id_vendedor
    INNER JOIN productos prd
    ON dto.id_producto = prd.id_producto
    GROUP BY p.nombre
    ORDER BY SUM(dto.cantidad) DESC
    LIMIT 1) as subquery1
    
    UNION
    
SELECT nombre_pais, monto_total
FROM (
	SELECT p.nombre AS nombre_pais,
    ROUND(SUM(prd.precio * dto.cantidad),2) AS monto_total
    FROM paises p
    INNER JOIN vendedores v
    ON p.id_pais = v.id_pais
    INNER JOIN detalle_orden dto
    ON v.id_vendedor = dto.id_vendedor
    INNER JOIN productos prd
    ON dto.id_producto = prd.id_producto
    GROUP BY p.nombre
    ORDER BY SUM(dto.cantidad) ASC
    LIMIT 1) as subquery2;`;


const query5 = 
`SELECT p.id_pais, p.nombre,
ROUND(SUM(prd.precio * dto.cantidad),2) AS monto
FROM paises p
JOIN clientes c
ON p.id_pais = c.id_pais
JOIN ordenes ord
ON c.id_cliente = ord.id_cliente
JOIN detalle_orden dto
ON ord.id_orden = dto.id_orden
JOIN productos prd
ON dto.id_producto = prd.id_producto
GROUP BY p.id_pais, p.nombre
ORDER BY monto ASC
LIMIT 5;`;

const query6 =
`SELECT nombre_categoria,cantidad_unidades
FROM (
	SELECT cat.nombre AS nombre_categoria, 
    SUM(dto.cantidad) AS cantidad_unidades
    FROM categorias cat
    INNER JOIN productos prd
    ON cat.id_categoria = prd.id_categoria
    INNER JOIN detalle_orden dto
    ON prd.id_producto = dto.id_producto
    GROUP BY cat.nombre
    ORDER BY cantidad_unidades DESC
    LIMIT 1
) AS subquery1
UNION
SELECT nombre_categoria,cantidad_unidades
FROM (
	SELECT cat.nombre AS nombre_categoria, 
    SUM(dto.cantidad) AS cantidad_unidades
    FROM categorias cat
    INNER JOIN productos prd
    ON cat.id_categoria = prd.id_categoria
    INNER JOIN detalle_orden dto
    ON prd.id_producto = dto.id_producto
    GROUP BY cat.nombre
    ORDER BY cantidad_unidades ASC
    LIMIT 1
) AS subquery2;`;


const query7 =
`SELECT p.nombre AS nombre_pais,cat.nombre AS nombre_categoria,
SUM(dto.cantidad) AS cantidad_unidades
FROM paises p
INNER JOIN clientes c
ON p.id_pais = c.id_pais
INNER JOIN ordenes ord
ON c.id_cliente = ord.id_cliente
INNER JOIN detalle_orden dto
ON ord.id_orden = dto.id_orden
INNER JOIN productos prd
ON dto.id_producto = prd.id_producto
INNER JOIN categorias cat
ON prd.id_categoria = cat.id_categoria
GROUP BY p.id_pais,cat.nombre
HAVING
	SUM(dto.cantidad) = (
		SELECT MAX(cantidad_u)
        FROM (
			SELECT p.id_pais,cat.nombre,
			SUM(dto.cantidad) AS cantidad_u
			FROM paises p
			INNER JOIN clientes c
			ON p.id_pais = c.id_pais
			INNER JOIN ordenes ord
			ON c.id_cliente = ord.id_cliente
			INNER JOIN detalle_orden dto
			ON ord.id_orden = dto.id_orden
			INNER JOIN productos prd
			ON dto.id_producto = prd.id_producto
			INNER JOIN categorias cat
			ON prd.id_categoria = cat.id_categoria
			GROUP BY p.id_pais,cat.nombre
        ) AS subquery
        WHERE subquery.id_pais = p.id_pais
    )
ORDER BY cantidad_unidades DESC; `


const query8 = 
`SELECT MONTH(ord.fecha) AS numero_mes,
ROUND(SUM(prd.precio * dto.cantidad),2) AS monto_total
FROM ordenes ord
INNER JOIN detalle_orden dto
ON ord.id_orden = dto.id_orden
INNER JOIN productos prd
ON dto.id_producto = prd.id_producto
INNER JOIN  vendedores v
ON dto.id_vendedor = v.id_vendedor
INNER JOIN paises p 
ON v.id_pais = p.id_pais
WHERE p.nombre = 'Inglaterra'
GROUP BY numero_mes
ORDER BY numero_mes;`

const query9 =
`SELECT mes,monto
FROM (
	SELECT MONTH(ord.fecha) AS mes,
    ROUND(SUM(prd.precio * dto.cantidad),2) AS monto
	FROM ordenes ord 
    INNER JOIN detalle_orden dto
    ON ord.id_orden = dto.id_orden
    INNER JOIN productos prd
    ON dto.id_producto = prd.id_producto
    GROUP BY mes
    ORDER BY mes DESC
    LIMIT 1
    )AS subquery1
    UNION
SELECT mes,monto
FROM (
	SELECT MONTH(ord.fecha) AS mes,
    ROUND(SUM(prd.precio * dto.cantidad),2) AS monto
	FROM ordenes ord 
    INNER JOIN detalle_orden dto
    ON ord.id_orden = dto.id_orden
    INNER JOIN productos prd
    ON dto.id_producto = prd.id_producto
    GROUP BY mes
    ORDER BY mes ASC
    LIMIT 1
    )AS subquery2;`
    
const query10 =
`SELECT prd.id_producto,prd.nombre,
ROUND(SUM(prd.precio * dto.cantidad),2) AS monto
FROM productos prd
INNER JOIN detalle_orden dto
ON prd.id_producto = dto.id_producto
INNER JOIN categorias cat
ON prd.id_categoria = cat.id_categoria
WHERE cat.nombre = 'Deportes'
GROUP BY prd.id_producto,prd.nombre;`

const eliminar_tablas =
`SET SQL_SAFE_UPDATES = 0;
DROP TABLE detalle_orden;
DROP TABLE ordenes;
DROP TABLE vendedores;
DROP TABLE productos;
DROP TABLE clientes;
DROP TABLE categorias;
DROP TABLE paises;
`


const tablas_modelo = 
`CREATE TABLE categorias (
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
    fecha      DATE,
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
        REFERENCES vendedores ( id_vendedor );`

const eliminar_informacion =
`
SET SQL_SAFE_UPDATES = 0;
DELETE FROM detalle_orden;
DELETE FROM ordenes;
DELETE FROM vendedores;
DELETE FROM productos;
DELETE FROM clientes;
DELETE FROM categorias;
DELETE FROM paises;`

module.exports = {
    query1,
    query2,
    query3,
    query4,
    query5,
    query6,
    query7,
    query8,
    query9,
    query10,
    eliminar_tablas,
    tablas_modelo,
    eliminar_informacion
}