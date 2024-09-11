const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');
const authMiddleware = require('../middleware/auth');

// Gestione degli Ordini
router.post('/create', authMiddleware, orderController.createOrder); // Crea un nuovo ordine
router.get('/user', authMiddleware, orderController.getOrdersByUser); // Recupera tutti gli ordini di un utente
router.get('/:id', authMiddleware, orderController.getOrderById); // Recupera ordini specifici
router.put('/:id', authMiddleware, orderController.updateOrderStatus); // Aggiorna lo stato di un ordine
router.delete('/:id', authMiddleware, orderController.deleteOrder); // Cancella un ordine

module.exports = router;