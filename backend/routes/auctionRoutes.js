const express = require('express');
const router = express.Router();
const auctionController = require('../controllers/auctionController');
const authMiddleware = require('../middleware/auth');

// Gestione delle Aste
router.post('/create', authMiddleware, auctionController.createAuction); // Crea una nuova asta
router.get('/ending-soon', authMiddleware, auctionController.getAuctionsByEndingSoon); // Recupera tutte le aste che terminano entro una certa data
router.get('/active', authMiddleware, auctionController.getAllActiveAuctions); // Recupera tutte le aste con stato attivo
router.get('/completed', authMiddleware, auctionController.getAuctionCompleted); // Recupera tutte le aste con stato completato
router.get('/unsold', authMiddleware, auctionController.getUnsoldAuctions); // Recupera tutte le aste che non sono state vendute
router.post('/silent-auction/:auctionId/accept-bid/:bidId', authMiddleware, auctionController.acceptBidForSilentAuction); // Per accettare le offerte per le aste silenziose
router.post('/silent-auction/:auctionId/reject-all-bids', authMiddleware, auctionController.rejectAllBidsForSilentAuction); // Per rifiutare le offerte per le aste silenziose
router.get('/by-type', authMiddleware, auctionController.getAuctionsByType); // Recupera tutte le aste per il singolo tipo
router.get('/category/:categoryId', authMiddleware, auctionController.getAuctionsByCategory); // Recupera le aste per una determinata categoria
router.get('/:id', authMiddleware, auctionController.getAuctionById); // Recupera una singola asta per ID
router.get('/', authMiddleware, auctionController.getAllAuctions); // Recupera tutte le aste
router.put('/:id', authMiddleware, auctionController.updateAuction); // Aggiorna un'asta per ID
router.delete('/:id', authMiddleware, auctionController.deleteAuction); // Cancella un'asta per ID
router.get('/:auctionId/isUserSeller', authMiddleware, auctionController.isUserSeller); // Per verificare se l'utente è il venditore

module.exports = router;
