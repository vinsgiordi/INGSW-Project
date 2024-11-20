const Bid = require('../models/bid');
const { StatusCodes } = require('http-status-codes');
const Auction = require('../models/auction');
const User = require('../models/user');
const Product = require('../models/product');
const Notification = require('../models/notification');
const dayjs = require('../utils/dayjs');

// Crea una nuova offerta
const createBid = async (req, res) => {
    const { prodotto_id, auction_id, importo } = req.body;

    try {
        if (!prodotto_id || !auction_id || !importo) {
            return res.status(StatusCodes.BAD_REQUEST).json({
                error: "Per favore inserisci tutte le informazioni richieste!"
            });
        }

        // Trova l'asta e verifica che esista
        const auction = await Auction.findByPk(auction_id, {
            include: {
                model: Product,
                attributes: ['nome']
            }
        });

        if (!auction || !auction.Product) {
            return res.status(StatusCodes.NOT_FOUND).json({
                error: "Asta o prodotto non trovati"
            });
        }

        // Verifica se il venditore sta tentando di fare un'offerta sulla propria asta
        if (auction.venditore_id === req.user.id) {
            return res.status(StatusCodes.FORBIDDEN).json({
                error: "Non puoi fare offerte sulla tua asta."
            });
        }

        // Verifica che l'asta non sia scaduta o completata
        if (new Date() > new Date(auction.data_scadenza) || auction.stato === 'completata') {
            return res.status(StatusCodes.BAD_REQUEST).json({
                error: "L'asta è scaduta o completata. Non puoi fare un'offerta."
            });
        }

        // Controllo della soglia di rialzo per l'asta all'inglese
        if (auction.tipo === 'inglese') {
            const minIncrease = parseFloat(auction.incremento_rialzo) || 10;
            console.log(`Valore della soglia di rialzo (incremento_rialzo) per l'asta ID ${auction.id}:`, minIncrease);

            const highestBid = await Bid.findOne({
                where: { auction_id: auction_id },
                order: [['importo', 'DESC']],
            });

            // Calcola l'importo minimo richiesto per l'offerta
            const currentBid = highestBid ? parseFloat(highestBid.importo) : parseFloat(auction.prezzo_iniziale);
            const minRequiredBid = currentBid + minIncrease;

            console.log(`Importo offerto: ${importo}, Offerta più alta attuale: ${currentBid}, Soglia richiesta: ${minRequiredBid}`);

            // Se l'offerta non raggiunge la soglia richiesta, restituisci un errore
            if (importo < minRequiredBid) {
                return res.status(StatusCodes.BAD_REQUEST).json({
                    error: `La tua offerta deve essere almeno di €${minRequiredBid.toFixed(2)} per rispettare la soglia di rialzo di €${minIncrease.toFixed(2)}.`
                });
            }

            // Aggiorna la data di scadenza dell'asta se l'offerta è valida
            auction.data_scadenza = dayjs().add(1, 'hour').format('YYYY-MM-DD HH:mm:ss');
            await auction.save();
        }

        // Crea l'offerta se valida
        const bid = await Bid.create({
            prodotto_id,
            auction_id,
            utente_id: req.user.id,
            importo
        });

        // Notifica il venditore per l'offerta ricevuta
        await Notification.create({
            utente_id: auction.venditore_id,
            messaggio: `Hai ricevuto un'offerta per il tuo prodotto ${auction.Product.nome}.`,
        });

        res.status(StatusCodes.CREATED).json(bid);
    } catch (error) {
        console.error('Errore nella creazione dell\'offerta:', error);
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Recupera tutte le offerte per un determinato prodotto
const getBidsByProduct = async (req, res) => {
    try {
        const bids = await Bid.findAll({
            where: { prodotto_id: req.params.prodotto_id },
            include: [
                {
                    model: User,
                    attributes: ['id', 'nome', 'email']
                },
                {
                    model: Auction,
                    attributes: ['id', 'tipo', 'data_scadenza', 'stato']
                }
            ]
        });
        res.status(StatusCodes.OK).json(bids);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Recupera tutte le offerte dell'utente autenticato
const getBidsByUser = async (req, res) => {
    try {
        const bids = await Bid.findAll({
            where: { utente_id: req.user.id },
            include: [
                {
                    model: Auction,
                    include: {
                        model: Product,
                        attributes: ['nome', 'descrizione', 'immagine_principale']
                    },
                    attributes: ['id', 'tipo', 'data_scadenza', 'stato']
                }
            ]
        });
        res.status(StatusCodes.OK).json(bids);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Elimina un'offerta
const deleteBid = async (req, res) => {
    try {
        const bid = await Bid.findOne({
            where: { id: req.params.id, utente_id: req.user.id }
        });

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
