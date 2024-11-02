const { StatusCodes } = require('http-status-codes');
const Notification = require('../models/notification');
const User = require('../models/user');

// Crea una nuova notifica
const createNotification = async (req, res) => {
    const { messaggio, utente_id } = req.body; // Aggiungi l'opzione di inviare notifiche a utenti specifici

    try {
        // Se non è specificato un utente, utilizza l'ID dell'utente autenticato
        const userId = utente_id || req.user.id;

        const notification = await Notification.create({
            utente_id: userId,
            messaggio
        });
        res.status(StatusCodes.CREATED).json(notification);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Recupera tutte le notifiche per l'utente autenticato
const getNotificationsByUser = async (req, res) => {
    try {
        const notifications = await Notification.findAll({
            where: { utente_id: req.user.id },
            order: [['created_at', 'DESC']],
            include: {
                model: User, // Includi informazioni sull'utente
                attributes: ['id', 'nome', 'email'] // Solo i campi necessari
            }
        });
        res.status(StatusCodes.OK).json(notifications);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Segna una notifica come letta
const markAsRead = async (req, res) => {
    try {
        const notification = await Notification.findByPk(req.params.id);
        if (!notification || notification.utente_id !== req.user.id) {
            return res.status(StatusCodes.NOT_FOUND).json({ error: 'Notifica non trovata o non autorizzato' });
        }

        notification.letto = true;
        await notification.save();
        res.status(StatusCodes.OK).json(notification);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Eliminare tutte le notifiche contemporaneamente
const deleteAllNotifications = async (req, res) => {
    try {
        const userId = req.user.id;

        // Cancella tutte le notifiche dell'utente autenticato
        await Notification.destroy({
            where: { utente_id: userId }
        });

        res.status(StatusCodes.OK).json({ message: 'Tutte le notifiche sono state cancellate con successo' });
    } catch (error) {
        console.error('Errore nella cancellazione delle notifiche:', error);
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: 'Errore nel cancellare le notifiche' });
    }
};

// Elimina una notifica
const deleteNotification = async (req, res) => {
    try {
        const notification = await Notification.findByPk(req.params.id);
        if (!notification || notification.utente_id !== req.user.id) {
            return res.status(StatusCodes.NOT_FOUND).json({ error: 'Notifica non trovata o non autorizzato' });
        }

        await notification.destroy();
        res.status(StatusCodes.OK).json({ message: 'Notifica eliminata con successo' });
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};


module.exports = {
    createNotification,
    getNotificationsByUser,
    markAsRead,
    deleteAllNotifications,
    deleteNotification
};
