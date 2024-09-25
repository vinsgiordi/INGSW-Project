const { StatusCodes } = require('http-status-codes');
const Payment = require('../models/payment');
const Order = require('../models/order');
const { client } = require('../config/paypalConfig'); // Importiamo la configurazione PayPal

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

// Funzione per creare un ordine PayPal e salvarlo nel DB
const createPayPalOrder = async (req, res) => {
    const { importo_totale, id_ordine_db } = req.body;
    try {
      const order = await client.post('/v2/checkout/orders', {
        intent: 'CAPTURE',
        purchase_units: [{ amount: { currency_code: 'USD', value: importo_totale } }]
      });
      const orderID = order.data.id; // Ottieni l'ID dell'ordine PayPal
      // Aggiorna l'ordine nel DB con l'orderID di PayPal
      await Order.update({ orderID }, { where: { id: id_ordine_db } });
      res.status(200).json({ orderID });
    } catch (error) {
      res.status(500).json({ error: 'Errore nella creazione dell\'ordine PayPal' });
    }
  };

  // Funzione per catturare il pagamento PayPal
  const capturePayPalOrder = async (req, res) => {
    const { orderID, id_ordine_db } = req.body;
    try {
      const capture = await client.post(`/v2/checkout/orders/${orderID}/capture`);
      // Aggiorna lo stato dell'ordine a "completato" nel DB
      await Order.update({ stato: 'completato' }, { where: { id: id_ordine_db } });
      res.status(200).json({ success: true, capture: capture.data });
    } catch (error) {
      // Aggiorna lo stato dell'ordine a "fallito" nel DB
      await Order.update({ stato: 'fallito' }, { where: { id: id_ordine_db } });
      res.status(500).json({ error: 'Errore nella cattura del pagamento PayPal' });
    }
  };


module.exports = {
    createPayment,
    getPaymentsByUser,
    deletePayment,
    createPayPalOrder,
    capturePayPalOrder
};
