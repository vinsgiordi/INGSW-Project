const Bid = require('../models/bid');
const { StatusCodes } = require('http-status-codes');

// Crea una nuova offerta
const createBid = async (req, res) => {
    const { prodotto_id, importo } = req.body;

    try {
        const bid = await Bid.create({
            prodotto_id,
            utente_id: req.user.id, // Usa l'ID utente dal token JWT
            importo
        });
        res.status(StatusCodes.CREATED).json(bid);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Recupera tutte le offerte per un determinato prodotto
const getBidsByProduct = async (req, res) => {
    try {
        const bids = await Bid.findAll({ where: { prodotto_id: req.params.prodotto_id } });
        res.status(StatusCodes.OK).json(bids);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Recupera tutte le offerte dell'utente autenticato
const getBidsByUser = async (req, res) => {
    try {
        const bids = await Bid.findAll({ where: { utente_id: req.user.id } });
        res.status(StatusCodes.OK).json(bids);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Elimina un'offerta
const deleteBid = async (req, res) => {
    try {
        const bid = await Bid.findOne({ where: { id: req.params.id, utente_id: req.user.id } });

        if (!bid) {
            return res.status(StatusCodes.NOT_FOUND).json({ error: 'Offerta non trovata o non autorizzato' });
        }

        await bid.destroy();
        res.status(StatusCodes.OK).json({ message: 'Offerta eliminata con successo' });
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

module.exports = {
    createBid,
    getBidsByProduct,
    getBidsByUser,
    deleteBid
};