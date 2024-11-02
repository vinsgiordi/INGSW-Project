const { StatusCodes } = require('http-status-codes');
const Order = require('../models/order');
const Product = require('../models/product');
const User = require('../models/user');

// Crea un nuovo ordine
const createOrder = async (req, res) => {
    const { prodotto_id, auction_id, indirizzo_spedizione, metodo_pagamento, importo_totale } = req.body;

    try {
        // Otteniamo l'ID dell'acquirente dal token JWT
        const acquirente_id = req.user.id;

        // Funzione per ottenere il venditore associato al prodotto
        const venditore_id = await getVenditoreId(prodotto_id);

        const order = await Order.create({
            prodotto_id,
            auction_id,
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

// Recupera gli ordini per l'utente autenticato con stato filtrato
const getOrdersByUser = async (req, res) => {
    const { stato } = req.query;

    try {
        const queryOptions = {
            where: { acquirente_id: req.user.id },
            include: [
                {
                    model: Product,
                    attributes: ['id', 'nome', 'descrizione', 'immagine_principale'],
                },
                {
                    model: User,
                    as: 'venditore', // Usa 'venditore' come alias per la relazione con l'utente
                    attributes: ['id', 'nome', 'email']
                },
                {
                    model: User,
                    as: 'acquirente', // Usa 'acquirente' per l'acquirente
                    attributes: ['id', 'nome', 'email']
                }
            ]
        };

        if (stato) {
            queryOptions.where.stato = stato;
        }

        const orders = await Order.findAll(queryOptions);
        res.status(StatusCodes.OK).json(orders);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Recupera un ordine specifico per ID
const getOrderById = async (req, res) => {
    try {
        const order = await Order.findByPk(req.params.id, {
            include: [
                {
                    model: Product, // Include il prodotto associato
                    attributes: ['id', 'nome', 'descrizione', 'immagine_principale']
                },
                {
                    model: User, // Include il venditore
                    as: 'venditore',
                    attributes: ['id', 'nome', 'email']
                }
            ]
        });

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

// Aggiorna lo stato di un ordine a "pagato"
const markAsPaid = async (req, res) => {
    try {
        console.log('ID Utente Autenticato:', req.user.id); // Log per l'utente autenticato
        console.log('ID Ordine Richiesto:', req.params.id); // Log per l'ID dell'ordine

        const order = await Order.findByPk(req.params.id);

        if (!order) {
            console.log('Ordine non trovato'); // Log ordine non trovato
            return res.status(StatusCodes.NOT_FOUND).json({ error: 'Ordine non trovato' });
        }

        if (order.acquirente_id !== req.user.id) {
            console.log('Utente non autorizzato'); // Log utente non autorizzato
            return res.status(StatusCodes.FORBIDDEN).json({ error: 'Non autorizzato a modificare questo ordine' });
        }

        order.stato = 'pagato';
        await order.save();

        console.log('Stato ordine aggiornato a "pagato"'); // Log aggiornamento riuscito
        res.status(StatusCodes.OK).json({ message: 'Ordine aggiornato a "pagato".' });
    } catch (error) {
        console.log('Errore interno:', error.message); // Log errore interno
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};


module.exports = {
    createOrder,
    getOrdersByUser,
    getOrderById,
    updateOrderStatus,
    deleteOrder,
    markAsPaid
};
