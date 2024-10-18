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
      // Verifica che tutti i campi richiesti siano presenti
      if (!prodotto_id || !auction_id || !importo) {
        return res.status(StatusCodes.BAD_REQUEST).json({
          error: "Per favore inserisci tutte le informazioni richieste!"
        });
      }

      // Crea l'offerta
      const bid = await Bid.create({
        prodotto_id,
        auction_id,
        utente_id: req.user.id, // Usa l'ID utente dal token JWT
        importo
      });

      // Trova l'asta e il venditore associato
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

      // Se l'asta è di tipo inglese, resetta il timer
      if (auction.tipo === 'inglese') {
        const newEndTime = dayjs().add(1, 'hour').format('YYYY-MM-DD HH:mm:ss');
        auction.data_scadenza = newEndTime;
        await auction.save();

        console.log(`Data di scadenza aggiornata a: ${newEndTime} per l'asta ${auction.id}`);
      }

      // Invia una notifica al venditore
      const venditoreId = auction.venditore_id;
      await Notification.create({
        utente_id: venditoreId,
        messaggio: `Hai ricevuto una nuova offerta di €${importo} per il tuo prodotto ${auction.Product.nome}.`
      });

      // Risposta con l'offerta creata
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
                    model: User, // Include il modello User per visualizzare le informazioni sull'utente che ha fatto l'offerta
                    attributes: ['id', 'nome', 'email']
                },
                {
                    model: Auction, // Include il modello Auction per visualizzare le informazioni sull'asta
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
                        model: Product, // Collega il modello Product per ottenere i dettagli del prodotto
                        attributes: ['nome', 'descrizione', 'immagine_principale'] // I campi che vuoi includere
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
