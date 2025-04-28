const db = require('../db');
const response = require('../../response');
const { getUsers, getUser, signup: signupRepo, deleteUser: deleteUserRepo } = require('./user.repository');
const jwt = require('jsonwebtoken');

const getAllUsers = (res) => {
    getUsers((err, result)=>{
        if(err){
            return response(500, null, "terjadi error pada server", res);
        }
        response(200, result, "data berhasil di ambil", res);
    })
}

const getUserById = (id, res) => {
    getUser(id,(err, result)=>{
        if (!(id)){
            return response(500, null, "terjadi error pada server", res);
        }
        if (!result || result.length === 0) {
            return response(400, null, "User tidak ditemukan", res);
        }
        response(200, result, "data berhasil di ambil", res);
    })
}

const signup = (values, res) => {
    signupRepo(values, (err, result)=>{
        if(err){
            return response(500, null, "terjadi error pada server", res);
        }
        if (result.exists) {
            return response(400, null, "username atau email sudah terdaftar", res);
        }
        response(200, result, "data berhasil di tambahkan", res);
    });
};

const signin = (values, res) => {
    const [email, password] = values;
    const sql = `SELECT * FROM users WHERE email = ? AND password = ?`;
    db.query(sql, [email, password], (err, result) => {
        if (err)
            return response(500, null, "terjadi error pada server", res);
        if (!result || result.length === 0) {
            return response(400, null, "User tidak ditemukan", res);
        }
        const user = result[0];
        const token = jwt.sign(
            { id: user.id, email: user.email, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: '1h' }  // Token berlaku 1 jam
        );
        response(200, {user, token}, "login berhasil", res);
    })
}

const logout = (req, res) => {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
        return response(400, null, "Token tidak ditemukan", res);
    }

    response(200, null, "Logout berhasil", res);
}

const updateUser = (values, res) => {
    const sql = `UPDATE users SET username = ?, password = ?, email = ?, full_name = ? WHERE id = ?`
    // const values = [req.body.username, req.body.password, req.body.email, req.body.full_name, id]
    db.query(sql, values,(err, result)=>{
        if (err) {
            response(500, null, "terjadi error pada server", res);
            return;
        }
        if (!result || result.length === 0) {
            return response(400, null, "User tidak ditemukan", res);
        }
        return response(200, result, "data berhasil diubah", res);
    })
}

const deleteUser = (id, res) => {
    deleteUserRepo(id, (err, result)=>{
        if (err) {
            response(500, null, "terjadi error pada server", res);
            return;
        }
        if (!result.exists ) {
            return response(400, null, `tidak ada user dengan id ${id}`, res);
        }
        deleteUserRepo(id, (_err, result)=>{
        return response(200, result, "data berhasil dihapus!", res);
        });
    });
}

module.exports = { getAllUsers, getUserById, signup, signin, logout, updateUser, deleteUser };
