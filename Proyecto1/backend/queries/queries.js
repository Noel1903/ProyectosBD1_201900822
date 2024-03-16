/*Mostrar el cliente que más ha comprado. Se debe de mostrar el id del cliente, 
nombre, apellido, país y monto total.*/

const query1 = 
`SELECT c.id_cliente,c.nombre,c.apellido,p.nombre,
SUM(prd.precio * dor.cantidad) as Monto,
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
           SUM(prd.precio * dto.cantidad) AS monto_vendido
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
           SUM(prd.precio * dto.cantidad) AS monto_vendido
    FROM productos prd
    INNER JOIN categorias c ON prd.id_categoria = c.id_categoria
    INNER JOIN detalle_orden dto ON prd.id_producto = dto.id_producto
    GROUP BY prd.id_producto, prd.nombre, c.nombre
    ORDER BY cantidad_unidades ASC
    LIMIT 1
) AS subquery2;`;



const query3 =
`SELECT v.id_vendedor,v.nombre,
SUM(dto.cantidad*prd.precio) AS monto_total
FROM vendedores v
INNER JOIN detalle_orden dto
ON v.id_vendedor = dto.id_vendedor
INNER JOIN productos prd
ON dto.id_producto = prd.id_producto
GROUP BY v.id_vendedor
ORDER BY monto_total ASC
LIMIT 1;`;

const query4 =
`SELECT nombre_pais, monto_total
FROM (
	SELECT p.nombre AS nombre_pais,
    SUM(prd.precio * dto.cantidad) AS monto_total
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
    SUM(prd.precio * dto.cantidad) AS monto_total
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
SUM(dto.cantidad * prd.precio) AS monto
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
ORDER BY SUM(dto.cantidad) DESC
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


module.exports = query1;