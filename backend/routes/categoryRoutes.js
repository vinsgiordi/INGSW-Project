const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');

// Gestione delle Categorie
router.get('/', categoryController.getAllCategories); // Recupera tutte le categorie

module.exports = router;
