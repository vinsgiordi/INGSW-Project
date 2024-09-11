const { StatusCodes } = require('http-status-codes');
const Payment = require('../models/payment');

// Crea un nuovo metodo di pagamento
const createPayment = async (req, res) => {
    const { numero_carta, nome_intestatario, data_scadenza, cvc, indirizzo_fatturazione } = req.body;

    try {
        const utente_id = req.user.id; // L'ID dell'utente è estratto dal token JWT
        const payment = await Payment.create({
            utente_id,
            numero_carta,
            nome_intestatario,
            data_scadenza,
            cvc,
            indirizzo_fatturazione
        });

        res.status(StatusCodes.CREATED).json(payment);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Recupera tutti i metodi di pagamento dell'utente
const getPaymentsByUser = async (req, res) => {
    try {
        const payments = await Payment.findAll({ where: { utente_id: req.user.id } });
        res.status(StatusCodes.OK).json(payments);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Elimina un metodo di pagamento
const deletePayment = async (req, res) => {
    try {
        const payment = await Payment.findOne({ where: { id: req.params.id, utente_id: req.user.id } });
        if (!payment) {
            return res.status(StatusCodes.NOT_FOUND).json({ error: 'Metodo di pagamento non trovato' });
        }

        await payment.destroy();
        res.status(StatusCodes.OK).json({ message: 'Metodo di pagamento eliminato con successo' });
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

module.exports = {
    createPayment,
    getPaymentsByUser,
    deletePayment
};
