const express = require('express');
const router = express.Router();
const fs = require('fs');
const csvParser = require('csv-parser');
const db = require('../config/database');
const moment = require('moment');
const {query1,query2,query3,query4,query5,query6,query7,query8,query9,query10,eliminar_tablas,tablas_modelo,eliminar_informacion} = require('../queries/queries');

router.get('/cargarmodelo',async(req,res)=>{
    const csvPaises = 'D:/USAC2024/SEMESTRE1/SBD1/Laboratorio/ProyectosBD1_201900822/Proyecto1/backend/data/paises.csv';
    const csvCategorias = 'D:/USAC2024/SEMESTRE1/SBD1/Laboratorio/ProyectosBD1_201900822/Proyecto1/backend/data/Categorias.csv';
    const csvClientes = 'D:/USAC2024/SEMESTRE1/SBD1/Laboratorio/ProyectosBD1_201900822/Proyecto1/backend/data/clientes.csv';
    const csvProductos = 'D:/USAC2024/SEMESTRE1/SBD1/Laboratorio/ProyectosBD1_201900822/Proyecto1/backend/data/productos.csv';
    const csvOrdenes = 'D:/USAC2024/SEMESTRE1/SBD1/Laboratorio/ProyectosBD1_201900822/Proyecto1/backend/data/ordenes.csv';
    const csvVendedores = 'D:/USAC2024/SEMESTRE1/SBD1/Laboratorio/ProyectosBD1_201900822/Proyecto1/backend/data/vendedores.csv';
    const valuesPaises = [];
    const valuesCategorias = [];
    const valuesClientes = [];
    const valuesProductos = [];
    //const valuesOrdenes = [];
    const valuesVendedores = [];

    //Se cargan los paises
    fs.createReadStream(csvPaises)
    .pipe(csvParser({separator: ';'}))
    .on('data', (row) => {
        //console.log(row);
        valuesPaises.push([row.id_pais, row.nombre]);
    })
    .on('end', () => {
        //console.log(values);
        const placeholders = valuesPaises.map(() => '(?)').join(',');
        console.log('cargando paises...');
        db.query(`INSERT INTO paises (id_pais, nombre) VALUES ${placeholders}`, valuesPaises, (err, result) => {
            if(err){
                console.log(err);
            }
        })
        //res.send('Paises cargados');
    })
    .on('error', (err) => {
        res.send(err);
    });


    //Se cargan las categorias
    fs.createReadStream(csvCategorias)
    .pipe(csvParser({separator: ';'}))
    .on('data', (row) => {
        valuesCategorias.push([row.id_categoria, row.nombre]);
    })
    .on('end', () => {
        //console.log(values);
        const placeholders = valuesCategorias.map(() => '(?)').join(',');
        console.log('cargando categorias...');
        db.query(`INSERT INTO categorias (id_categoria, nombre) VALUES ${placeholders}`, valuesCategorias, (err, result) => {
            if(err){
                console.log(err);
            }
        })
        //res.send('Categorias cargadas');
    })
    .on('error', (err) => {
        res.send(err);
    });

    //Se cargan los clientes
    fs.createReadStream(csvClientes)
    .pipe(csvParser({separator: ';'}))
    .on('data', (row) => {
        valuesClientes.push([row.id_cliente,row.Nombre,row.Apellido,row.Direccion,row.Telefono,row.Tarjeta,row.Edad,row.Salario,row.Genero,row.id_pais]);
    })
    .on('end', () => {
        //console.log(values);
        const placeholders = valuesClientes.map(() => '(?)').join(',');
        console.log('cargando clientes...');
        db.query(`INSERT INTO clientes (id_cliente,Nombre,Apellido,Direccion,Telefono,Tarjeta,Edad,Salario,Genero,id_pais) VALUES ${placeholders}`, valuesClientes, (err, result) => {
            if(err){
                console.log(err);
            }
        })
        //res.send('Categorias cargadas');
    })
    .on('error', (err) => {
        res.send(err);
    });

    //Se cargan los productos
    fs.createReadStream(csvProductos)
    .pipe(csvParser({separator: ';'}))
    .on('data', (row) => {
        valuesProductos.push([row.id_producto,row.Nombre,row.Precio,row.id_categoria]);
    })
    .on('end', () => {
        //console.log(values);
        const placeholders = valuesProductos.map(() => '(?)').join(',');
        console.log('cargando productos...');
        db.query(`INSERT INTO productos (id_producto,Nombre,Precio,id_categoria) VALUES ${placeholders}`, valuesProductos, (err, result) => {
            if(err){
                console.log(err);
            }
        })
        //res.send('Productos cargados');
    })
    .on('error', (err) => {
        res.send(err);
    });

    //Se cargan los vendedores
    fs.createReadStream(csvVendedores)
    .pipe(csvParser({separator: ';'}))
    .on('data', (row) => {
        valuesVendedores.push([row.id_vendedor,row.nombre,row.id_pais]);
    })
    .on('end', () => {
        //console.log(values);
        const placeholders = valuesVendedores.map(() => '(?)').join(',');
        console.log('cargando vendedores...');
        db.query(`INSERT INTO vendedores (id_vendedor,nombre,id_pais) VALUES ${placeholders}`, valuesVendedores, (err, result) => {
            if(err){
                console.log(err);
            }
        })
        //res.send('Vendedores cargados');
    })
    .on('error', (err) => {
        res.send(err);
    });

    //Se cargan las ordenes
    let valoresOrdenes = new Set(); // Utilizamos un Set para almacenar las filas únicas
    fs.createReadStream(csvOrdenes)
    .pipe(csvParser({
        separator: ';',
        mapHeaders: ({ header }) => header.trim(), // Eliminar espacios en los encabezados
        mapValues: ({ header, index, value }) => {
            if (header === 'id_orden') return parseInt(value); // Convertir 'id_orden' en un número
            return value; // Mantener otros valores igual
        }
    }))
    .on('data', (row) => {
        // Dividir el string de fecha en día, mes y año
        const partesFecha = row.fecha_orden.split('/');

        // Crear un objeto Date con los componentes de la fecha
        const fecha = new Date(partesFecha[2], partesFecha[1] - 1, partesFecha[0]);

        // Formatear la fecha en el formato "YYYY-MM-DD"
        const fechaFormateada = fecha.getFullYear() + '-' + (fecha.getMonth() + 1).toString().padStart(2, '0') + '-' + fecha.getDate().toString().padStart(2, '0');

        const clave = `${row.id_orden}_${fechaFormateada}_${row.id_cliente}`;
        valoresOrdenes.add(clave);
        
    })
    .on('end', () => {
        const clavesUnicas = Array.from(valoresOrdenes);

        // Aquí puedes continuar con tu lógica para insertar los datos en la base de datos
        console.log('cargando ordenes...');

        // Ejemplo de cómo iterar sobre las claves únicas e insertar en la base de datos
        for (const clave of clavesUnicas) {
            const [id_orden, fecha_orden, id_cliente] = clave.split('_');
            // Ejemplo de inserción en la base de datos (reemplaza esto con tu lógica real)
            db.query(`INSERT INTO ordenes (id_orden, fecha, id_cliente) VALUES (?, ?, ?)`, [id_orden, fecha_orden, id_cliente], (err, result) => {
                if (err) {
                    console.log('Error al insertar datos en la base de datos:', err);
                }
            });
        }
        
    });
    //Se cargan los detalles de ordenes
    const detailOrders = [];
    let id_dorden = 1;
    fs.createReadStream(csvOrdenes)
    .pipe(csvParser({
        separator: ';',
        mapHeaders: ({ header }) => header.trim(), // Eliminar espacios en los encabezados
        mapValues: ({ header, index, value }) => {
            if (header === 'id_orden') return parseInt(value); // Convertir 'id_orden' en un número
            return value; // Mantener otros valores igual
        }
    }))
    .on('data', (row) => {
        detailOrders.push([id_dorden,row.id_orden,row.linea_orden,row.id_vendedor,row.id_producto,row.cantidad]);
        id_dorden++;
    })
    .on('end', () => {
        //console.log(values);
        const placeholders = detailOrders.map(() => '(?)').join(',');
        console.log('cargando detalles de ordenes...');
        db.query(`INSERT INTO detalle_orden (id_dorden,id_orden,linea_orden,id_vendedor,id_producto,cantidad) VALUES ${placeholders}`, detailOrders, (err, result) => {
            if(err){
                console.log(err);
            }
        })
       // res.send('Detalles de ordenes cargados');
    })
    .on('error', (err) => {
        res.send(err);
    });
    console.log('Datos cargados correctamente');
    res.send('Datos cargados correctamente');
    

    
});


router.get('/consulta1', (req, res) => {
    db.query(query1, (err, result) => {
        if(err){
            console.log(err);
            res.status(500).json({ error: 'Error en la consulta' });
            return;
        }
        res.json(result);
    });
});

router.get('/consulta2', (req, res) => {
    db.query(query2, (err, result) => {
        if(err){
            console.log(err);
            res.status(500).json({ error: 'Error en la consulta' });
            return;
        }
        res.json(result);
    });
}
);

router.get('/consulta3', (req, res) => {
    db.query(query3, (err, result) => {
        if(err){
            console.log(err);
            res.status(500).json({ error: 'Error en la consulta' });
            return;
        }
        res.json(result);
    });
}
);

router.get('/consulta4', (req, res) => {
    db.query(query4, (err, result) => {
        if(err){
            console.log(err);
            res.status(500).json({ error: 'Error en la consulta' });
            return;
        }
        res.json(result);
    });
}
);

router.get('/consulta5', (req, res) => {
    db.query(query5, (err, result) => {
        if(err){
            console.log(err);
            res.status(500).json({ error: 'Error en la consulta' });
            return;
        }
        res.json(result);
    });
}
);

router.get('/consulta6', (req, res) => {
    db.query(query6, (err, result) => {
        if(err){
            console.log(err);
            res.status(500).json({ error: 'Error en la consulta' });
            return;
        }
        res.json(result);
    });
}
);

router.get('/consulta7', (req, res) => {
    db.query(query7, (err, result) => {
        if(err){
            console.log(err);
            res.status(500).json({ error: 'Error en la consulta' });
            return;
        }
        res.json(result);
    });
}
);

router.get('/consulta8', (req, res) => {
    db.query(query8, (err, result) => {
        if(err){
            console.log(err);
            res.status(500).json({ error: 'Error en la consulta' });
            return;
        }
        res.json(result);
    });
}
);

router.get('/consulta9', (req, res) => {
    db.query(query9, (err, result) => {
        if(err){
            console.log(err);
            res.status(500).json({ error: 'Error en la consulta' });
            return;
        }
        res.json(result);
    });
}
);

router.get('/consulta10', (req, res) => {
    db.query(query10, (err, result) => {
        if (err) {
            console.log(err);
            res.status(500).json({ error: 'Error en la consulta' });
            return;
        }

        // Verificar si hay resultados
        if (result.length === 0) {
            res.json({ numCampos: 0, datos: [] }); // No hay datos, respondemos con un JSON vacío
            return;
        }

        // Obtener el número de campos (claves del primer objeto)
        const numregistros = result.length;

        // Adjuntar el número de campos al JSON de respuesta
        res.json({ numRegistros: numregistros, datos: result });
    });
}
);

router.get('/eliminarmodelo', (req, res) => {
    db.query(eliminar_tablas, (err, result) => {
        if(err){
            console.log(err);
        }
        res.json(result);
    });
}
);

router.get('/crearmodelo', (req, res) => {
    db.query(tablas_modelo, (err, result) => {
        if(err){
            console.log(err);
        }
        res.json(result);
    });
}
);

router.get('/borrarinfodb', (req, res) => {
    db.query(eliminar_informacion, (err, result,fields) => {
        if(err){
            console.log(err);
        }
        res.json(result);
    });
}
);

module.exports = router;