const mysql = require('mysql');
const db = mysql.createConnection({
    host:'localhost',
    user:'root',
    password:'',
    database:'testing'
})

db.connect((err)=>{
    if(err){
        console.log(`database gagal terkoneksi, error : ${err}`);
    }
    return console.log("database berhasil terkoneksi");
})

module.exports = db;
