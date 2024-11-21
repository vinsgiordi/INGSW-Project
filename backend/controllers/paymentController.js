const { StatusCodes } = require('http-status-codes');
const Payment = require('../models/payment');
const dayjs = require('../utils/dayjs');

// Crea un nuovo metodo di pagamento
const createPayment = async (req, res) => {
    const { numero_carta, nome_intestatario, data_scadenza } = req.body;

    try {
        // Valida che il numero della carta sia di almeno 16 cifre
        if (!numero_carta || numero_carta.length < 16) {
            return res.status(StatusCodes.BAD_REQUEST).json({ error: 'Numero della carta non valido' });
        }

        const utente_id = req.user.id;
        const ultime_4_cifre = numero_carta.slice(-4);

        const parsedDataScadenza = dayjs(data_scadenza, ['MM/YYYY', 'YYYY-MM']).toDate();

        // Salva il numero della carta criptato nel formato desiderato
        const payment = await Payment.create({
            utente_id,
            numero_carta: `**** **** **** ${ultime_4_cifre}`, // Salva solo le ultime 4 cifre
            nome_intestatario,
            data_scadenza: parsedDataScadenza,
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
