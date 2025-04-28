const express = require('express');
const app = express();
const dotenv = require('dotenv');
const cors = require('cors');
const userRouter = require('./src/routes/useRoutes')

dotenv.config();
const port = process.env.PORT;
app.use(express.json());
app.use(cors({
    origin: '*',
    methods: 'GET, POST, PUT, DELETE',
    credentials: true
}));

app.use('/api', userRouter)

app.listen(port, () => {
    console.log(`server berjalan di port ${port}`);
});