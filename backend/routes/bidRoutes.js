const express = require('express');
const router = express.Router();
const bidController = require('../controllers/bidController');
const authMiddleware = require('../middleware/auth');

// Gestione delle offerte
router.post('/create', authMiddleware, bidController.createBid); // Creare un'offerta
router.get('/prodotto/:prodotto_id', authMiddleware, bidController.getBidsByProduct); // Recuperare tutte le offerte per un prodotto specifico
router.get('/user/', authMiddleware, bidController.getBidsByUser); //Recuperare tutte le offerte di un utente specifico
router.delete('/:id', authMiddleware, bidController.deleteBid); // Eliminare un'offerta

module.exports = router;