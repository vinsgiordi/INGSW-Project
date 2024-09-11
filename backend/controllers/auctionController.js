const { StatusCodes } = require('http-status-codes');
const Auction = require('../models/auction');

// Crea una nuova asta
const createAuction = async (req, res) => {
    const { prodotto_id, tipo, data_scadenza, prezzo_minimo, incremento_rialzo, decremento_prezzo, prezzo_iniziale, stato } = req.body;

    try {
        if (!prodotto_id || !tipo || !data_scadenza || !prezzo_iniziale || !stato) {
            return res.status(StatusCodes.BAD_REQUEST).json({
                error: "Per favore inserisci tutte le informazioni richieste!"
            });
        }

        // Associa l'asta all'utente autenticato
        const auction = await Auction.create({
            prodotto_id,
            tipo,
            data_scadenza,
            prezzo_minimo,
            incremento_rialzo,
            decremento_prezzo,
            prezzo_iniziale,
            stato,
            venditore_id: req.user.id // Ottieni l'utente autenticato dal token JWT
        });

        res.status(StatusCodes.CREATED).json(auction);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Recupera tutte le aste
const getAllAuctions = async (req, res) => {
    try {
        const auctions = await Auction.findAll();
        res.status(StatusCodes.OK).json(auctions);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Recupera un'asta per ID
const getAuctionById = async (req, res) => {
    try {
        const auction = await Auction.findByPk(req.params.id);
        if (!auction) {
            return res.status(StatusCodes.NOT_FOUND).json({ error: 'Asta non trovata' });
        }
        res.status(StatusCodes.OK).json(auction);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Aggiorna un'asta per ID
const updateAuction = async (req, res) => {
    const { prodotto_id, tipo, data_scadenza, prezzo_minimo, incremento_rialzo, decremento_prezzo, prezzo_iniziale, stato } = req.body;
    try {
        const auction = await Auction.findByPk(req.params.id);
        if (!auction) {
            return res.status(StatusCodes.NOT_FOUND).json({ error: 'Asta non trovata' });
        }

        // Verifica che l'utente autenticato sia il venditore dell'asta
        if (auction.venditore_id !== req.user.id) {
            return res.status(StatusCodes.UNAUTHORIZED).json({ error: 'Non autorizzato' });
        }

        auction.prodotto_id = prodotto_id || auction.prodotto_id;
        auction.tipo = tipo || auction.tipo;
        auction.data_scadenza = data_scadenza || auction.data_scadenza;
        auction.prezzo_minimo = prezzo_minimo || auction.prezzo_minimo;
        auction.incremento_rialzo = incremento_rialzo || auction.incremento_rialzo;
        auction.decremento_prezzo = decremento_prezzo || auction.decremento_prezzo;
        auction.prezzo_iniziale = prezzo_iniziale || auction.prezzo_iniziale;
        auction.stato = stato || auction.stato;

        await auction.save();
        res.status(StatusCodes.OK).json(auction);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Cancella un'asta per ID
const deleteAuction = async (req, res) => {
    try {
        const auction = await Auction.findByPk(req.params.id);
        if (!auction) {
            return res.status(StatusCodes.NOT_FOUND).json({ error: 'Asta non trovata' });
        }

        // Verifica che l'utente autenticato sia il venditore dell'asta
        if (auction.venditore_id !== req.user.id) {
            return res.status(StatusCodes.UNAUTHORIZED).json({ error: 'Non autorizzato' });
        }

        await auction.destroy();
        res.status(StatusCodes.OK).json({ message: 'Asta cancellata con successo' });
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

module.exports = {
    createAuction,
    getAllAuctions,
    getAuctionById,
    updateAuction,
    deleteAuction
};