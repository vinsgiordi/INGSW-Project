const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/auth');

// Autentizazione e Gestione dell'utente
router.post('/register', userController.userRegister); // Per la registazione dell'utente
router.post('/login', userController.userLogin); // Per il login dell'utente
router.put('/', authMiddleware, userController.updateUser); // Per aggiornare il profilo utente
router.delete('/', authMiddleware, userController.deleteUser); // Per cancellare l'utente

module.exports = router;
