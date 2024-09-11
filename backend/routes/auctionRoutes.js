const express = require('express');
const router = express.Router();
const auctionController = require('../controllers/auctionController');
const authMiddleware = require('../middleware/auth');

// Gestione delle Aste
router.post('/create', authMiddleware, auctionController.createAuction); // Crea una nuova asta
router.get('/', authMiddleware, auctionController.getAllAuctions); // Recupera tutte le aste
router.get('/:id', authMiddleware, auctionController.getAuctionById); // Recupera una singola asta per ID
router.put('/:id', authMiddleware, auctionController.updateAuction); // Aggiorna un'asta per ID
router.delete('/:id', authMiddleware, auctionController.deleteAuction); // Cancella un'asta per ID

module.exports = router;