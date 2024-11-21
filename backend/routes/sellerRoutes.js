const express = require('express');
const router = express.Router();
const sellerController = require('../controllers/sellerController');
const authMiddleware = require('../middleware/auth');

// Rotta per ottenere i dettagli del venditore
router.get('/:id', authMiddleware, sellerController.getSellerDetails);

module.exports = router;
