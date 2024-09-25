const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const authMiddleware = require('../middleware/auth');

// Gestione dei Pagamenti
router.post('/create', authMiddleware, paymentController.createPayment); // Rotta per creare un metodo di pagamento
router.get('/', authMiddleware, paymentController.getPaymentsByUser); // Rotta per ottenere tutti i metodi di pagamento di un utente
router.delete('/:id', authMiddleware, paymentController.deletePayment); // Rotta per cancellare un metodo di pagamento

// Gestione dei Pagamenti con PayPal
router.post('/paypal/create-order', authMiddleware, paymentController.createPayPalOrder); // Creazione di un ordine PayPal
router.post('/paypal/capture-order', authMiddleware, paymentController.capturePayPalOrder); // Cattura del pagamento PayPal

module.exports = router;