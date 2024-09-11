const { StatusCodes } = require('http-status-codes');
const Order = require('../models/order');
const Product = require('../models/product');

// Crea un nuovo ordine
const createOrder = async (req, res) => {
    const { prodotto_id, indirizzo_spedizione, metodo_pagamento, importo_totale } = req.body;

    try {
        // Qui useremo l'id dell'acquirente dal token JWT e lo assoceremo all'ordine
        const acquirente_id = req.user.id;

        // Supponiamo che il venditore sia collegato al prodotto (aggiungi la logica necessaria se non esiste già)
        const venditore_id = await getVenditoreId(prodotto_id); // Funzione ipotetica che ottiene il venditore del prodotto

        const order = await Order.create({
            prodotto_id,
            acquirente_id,
            venditore_id,
            indirizzo_spedizione,
            metodo_pagamento,
            importo_totale,
            stato: 'in elaborazione' // Stato iniziale dell'ordine
        });
        res.status(StatusCodes.CREATED).json(order);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Recupera tutti gli ordini per l'utente autenticato
const getOrdersByUser = async (req, res) => {
    try {
        const orders = await Order.findAll({
            where: {
                acquirente_id: req.user.id
            }
        });
        res.status(StatusCodes.OK).json(orders);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Recupera un ordine specifico per ID
const getOrderById = async (req, res) => {
    try {
        const order = await Order.findByPk(req.params.id);

        // Controlla se l'ordine esiste e se l'utente autenticato è l'acquirente o il venditore
        if (!order || (order.acquirente_id !== req.user.id && order.venditore_id !== req.user.id)) {
            return res.status(StatusCodes.NOT_FOUND).json({ error: 'Ordine non trovato o non autorizzato' });
        }

        res.status(StatusCodes.OK).json(order);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Aggiorna lo stato di un ordine
const updateOrderStatus = async (req, res) => {
    const { stato } = req.body;
    try {
        const order = await Order.findByPk(req.params.id);
        if (!order || order.acquirente_id !== req.user.id) {
            return res.status(StatusCodes.NOT_FOUND).json({ error: 'Ordine non trovato o non autorizzato' });
        }

        order.stato = stato || order.stato;
        await order.save();
        res.status(StatusCodes.OK).json(order);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Cancella un ordine
const deleteOrder = async (req, res) => {
    try {
        const order = await Order.findByPk(req.params.id);
        if (!order) {
            return res.status(StatusCodes.NOT_FOUND).json({ error: 'Ordine non trovato' });
        }

        // Controlliamo che solo l'acquirente o il venditore possano cancellare l'ordine
        if (order.acquirente_id !== req.user.id && order.venditore_id !== req.user.id) {
            return res.status(StatusCodes.FORBIDDEN).json({ error: 'Non autorizzato a cancellare questo ordine' });
        }

        await order.destroy();
        res.status(StatusCodes.OK).json({ message: 'Ordine cancellato con successo' });
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Funzione per ottenere il venditore associato a un prodotto
async function getVenditoreId(prodotto_id) {
    try {
        // Recupera il prodotto per ottenere il venditore
        const product = await Product.findByPk(prodotto_id);

        if (!product) {
            throw new Error('Prodotto non trovato');
        }

        return product.venditore_id; // Restituisci il venditore_id associato al prodotto
    } catch (error) {
        throw new Error(error.message);
    }
}

module.exports = {
    createOrder,
    getOrdersByUser,
    getOrderById,
    updateOrderStatus,
    deleteOrder
};