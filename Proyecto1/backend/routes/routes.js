const express = require('express');
const router = express.Router();
const fs = require('fs');
const csvParser = require('csv-parser');
const db = require('../config/database');

router.post('/data-upload',(req,res)=>{
    const csvPaises = 'D:/USAC2024/SEMESTRE1/SBD1/Laboratorio/ProyectosBD1_201900822/Proyecto1/backend/data/paises.csv';
    const values = [];
    fs.createReadStream(csvPaises)
    .pipe(csvParser({separator: ';'}))
    .on('data', (row) => {
        values.push([row.id_pais, row.nombre]);
    })
    .on('end', () => {
        //console.log(values);
        const placeholders = values.map(() => '(?)').join(',');
        console.log('cargando paises...');
        db.query(`INSERT INTO paises (id_pais, nombre) VALUES ${placeholders}`, values, (err, result) => {
            if(err){
                console.log(err);
            }
        })
        res.send('Paises cargados');
    })
    .on('error', (err) => {
        res.send(err);
    });
    
});

module.exports = router;