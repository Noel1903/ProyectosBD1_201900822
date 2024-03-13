const mysql = require('mysql');
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '123XosN',
    database: 'db_project1_sbd'
});

/*connection.connect((err)=>{
    if(err) throw err;
    console.log('Connected to MySQL Server!');
});*/

module.exports = connection;