const express = require('express');
const app = express();
const dotenv = require('dotenv');
const db = require('./src/db')
const userController = require('./src/user/user.controller');

dotenv.config();
const PORT = process.env.PORT;
app.use(express.json());

app.use('/user', userController);

app.listen(PORT, ()=>{
    console.log(`api service running at port ${PORT}`);

});
