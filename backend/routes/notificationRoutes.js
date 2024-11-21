const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const authMiddleware = require('../middleware/auth');

// Gestione delle notifiche
router.post('/create', authMiddleware, notificationController.createNotification); // Crea una nuova notifica
router.get('/', authMiddleware, notificationController.getNotificationsByUser); // Recupera tutte le notifiche dell'utente
router.put('/:id', authMiddleware, notificationController.markAsRead); // Segna una notifica come letta
router.delete('/delete-all', authMiddleware, notificationController.deleteAllNotifications); // Elimina tutte le notifiche contemporaneamente
router.delete('/:id', authMiddleware, notificationController.deleteNotification); // Elimina una notifica

module.exports = router;
