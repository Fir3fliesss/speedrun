const express = require('express');
const router = express.Router();
const { authenticateJWT, authorizeRoles } = require('../../auth/auth');
const { getAllUsers, getUserById, signup, signin, updateUser, deleteUser, logout } = require('./user.service');

router.post('/signup', (req,res)=>{
    const values = [req.body.username, req.body.password, req.body.email, req.body.full_name];
    signup(values, res);
});

router.post('/signin', (req, res)=>{
    const values = [req.body.email, req.body.password];
    console.log(values);
    signin(values, res);
});

router.post('/logout', authenticateJWT, (req, res) => {
    logout(req, res);
});

    router.get('/', authenticateJWT, (req, res)=>{
    getAllUsers(res);
    });

    router.get('/:id', authenticateJWT, authorizeRoles('admin'), (req, res)=>{
        const id = req.params.id;
        getUserById(id, res);
    });


    router.put('/:id', authenticateJWT, (req, res)=>{
        const id = req.params.id;
        values = [req.body.username, req.body.password, req.body.email, req.body.full_name, id];
        updateUser(values, res);
    })

    router.delete('/:id', authenticateJWT,authorizeRoles('admin'), (req, res)=>{
        const id = req.params.id;
        deleteUser(id, res);
    })

module.exports = router;
