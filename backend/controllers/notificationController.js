const { StatusCodes } = require('http-status-codes');
const Notification = require('../models/notification');

// Crea una nuova notifica
const createNotification = async (req, res) => {
    const { messaggio } = req.body;

    try {

        const utente_id = req.user.id;

        const notification = await Notification.create({
            utente_id,
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
            order: [['created_at', 'DESC']]
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
            return res.status(StatusCodes.NOT_FOUND).json({ error: 'Notifica non trovata' });
        }

        notification.letto = true;
        await notification.save();
        res.status(StatusCodes.OK).json(notification);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Elimina una notifica
const deleteNotification = async (req, res) => {
    try {
        const notification = await Notification.findByPk(req.params.id);
        if (!notification || notification.utente_id !== req.user.id) {
            return res.status(StatusCodes.NOT_FOUND).json({ error: 'Notifica non trovata' });
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
    deleteNotification
};
