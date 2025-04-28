const express = require('express');
const router = express.Router();
const userController = require('../user/userController');

router.post('/users', userController.createUser);
router.get('/users', userController.getUsers);
router.put('/users/:id', userController.updateUser);
router.delete('/users/:id', userController.deleteUser);

module.exports = router;
