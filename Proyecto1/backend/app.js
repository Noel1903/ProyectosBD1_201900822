const express = require('express');
const app = express();
const mysql = require('./config/database')

app.use(express.json());

mysql.connect((err)=>{
    if(err) throw err;
    console.log('Connected to MySQL Server!');
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, ()=>{
    console.log(`Server is running on port ${PORT}`);
});