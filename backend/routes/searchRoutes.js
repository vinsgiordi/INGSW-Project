const express = require('express');
const router = express.Router();
const searchController = require('../controllers/searchController');
const authMiddleware = require('../middleware/auth');

// Gestione della ricerca
router.get('/search', authMiddleware, searchController.searchAuctions);

module.exports = router;
