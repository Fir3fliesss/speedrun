const db = require('../db');

const getUsers = (callback) =>{
    const sql = 'SELECT * FROM users';
    db.query(sql, (err, result) => {
        callback(err, result);
    })
};

const getUser = (id, callback) => {
    const sql = `SELECT * FROM users WHERE id = ?`;
    db.query(sql, [id], (err, result) => {
        callback(err, result);
    })
}

const signup = (values, callback) => {
    const [username, email] = values;
    const checkUserExists = 'SELECT * FROM users WHERE username = ? OR email = ?';
    db.query(checkUserExists, [username, email], (err, result) => {
        if (err) {
            return callback(err);
        }
        if (result && result.length > 0) {
            return callback(null, { exists: true });
        }
        const sql = `INSERT INTO users (username, password, email, full_name) VALUES (?, ?, ?, ?)`;
        db.query(sql, values, (err, result) => {
            callback(err, { exists: false, result });
        });
    });
};

const deleteUser = (id, callback) => {
     const checkId = 'SELECT * FROM users WHERE id = ?';
     db.query(checkId, [id], (err, result) => {
        if (err) {
            callback(err);
        }
        if (result.length === 0) {
            return callback(null, {exists: false});
        }
        const sql = 'DELETE FROM users WHERE id = ?';
        const values = [id];
        db.query(sql, values, (err, result) => {
            callback(err, { exists: true, result});
        });
     });
};

module.exports = { getUsers, getUser, signup, deleteUser };
