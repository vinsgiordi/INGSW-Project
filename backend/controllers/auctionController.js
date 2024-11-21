const { StatusCodes } = require('http-status-codes');
const Auction = require('../models/auction');
const Product = require('../models/product');
const Bid = require('../models/bid');
const Category = require('../models/category');
const { User, Order } = require('../models/associations');
const { Op } = require('sequelize');
const auctionService = require('../services/auctionServices');

// Crea una nuova asta
const createAuction = async (req, res) => {
    console.log("Token ricevuto nel controller:", req.user);  // Verifica che l'utente sia stato correttamente autenticato

    const {
        tipo, data_scadenza, prezzo_minimo, incremento_rialzo, decremento_prezzo,
        prezzo_iniziale, stato, titolo, descrizione, categoria_id, immagine_principale, timer_decremento
    } = req.body;

    try {
        console.log('Dati ricevuti dall\'API:', req.body);

        // Validazione di base per i campi richiesti
        if (!tipo || !data_scadenza || !prezzo_iniziale || !stato || !titolo || !descrizione || !categoria_id) {
            console.error('Errore: uno o più campi obbligatori mancanti');
            return res.status(400).json({
                error: "Per favore inserisci tutte le informazioni richieste per il prodotto e l'asta."
            });
        }

        // Verifica se la categoria esiste
        const category = await Category.findByPk(categoria_id);
        if (!category) {
            console.error('Errore: categoria non trovata');
            return res.status(404).json({ error: "Categoria non trovata" });
        }

        // Crea il prodotto nel database
        console.log('Creazione prodotto con i dati:', { titolo, descrizione, prezzo_iniziale, immagine_principale, categoria_id });
        const product = await Product.create({
            nome: titolo,
            descrizione,
            prezzo_iniziale,
            immagine_principale: immagine_principale || null,
            categoria_id,
            venditore_id: req.user.id // L'utente autenticato è il venditore
        });

        // Configura l'asta in base al tipo di asta
        let auctionData = {
            prodotto_id: product.id,
            tipo,
            data_scadenza,  // Usa la data convertita in UTC
            prezzo_iniziale,
            stato,
            venditore_id: req.user.id
        };

        // Aggiungi campi opzionali solo se necessari
        if (tipo === 'inglese' && incremento_rialzo) {
            auctionData.incremento_rialzo = incremento_rialzo;
        }

        if (tipo === 'ribasso') {
            if (decremento_prezzo) auctionData.decremento_prezzo = decremento_prezzo;
            if (timer_decremento) auctionData.timer_decremento = timer_decremento;
        }

        if (prezzo_minimo) {
            auctionData.prezzo_minimo = prezzo_minimo;
        }

        console.log('Dati finali per l\'asta:', auctionData);

        // Crea l'asta nel database
        const auction = await Auction.create(auctionData);

        return res.status(201).json({ product, auction });
    } catch (error) {
        console.log('Errore nella creazione dell\'asta:', error);
        return res.status(500).json({ error: 'Errore interno al server' });
    }
};

// Recupera tutte le aste
const getAllAuctions = async (req, res) => {
    try {
        const auctions = await Auction.findAll({
            include: [
                {
                    model: Product,   // Collega il modello Product
                    attributes: ['id', 'nome', 'descrizione', 'immagine_principale', 'prezzo_iniziale', 'categoria_id', 'venditore_id']
                },
                {
                    model: User,    // Collega il modello User
                    as: 'venditore', // Nome dell'alias
                    attributes: ['id', 'nome', 'cognome']
                },
                {
                    model: Bid, // Include anche le offerte associate all'asta
                    attributes: ['id', 'importo', 'utente_id']
                }
            ]
        });

        res.status(200).json(auctions);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Recupera un'asta per ID
const getAuctionById = async (req, res) => {
    try {
      // Recupera l'asta con l'id fornito, includendo il venditore e il prodotto associato
      const auction = await Auction.findByPk(req.params.id, {
        include: [
          {
            model: Product, // Collega il modello Product
            attributes: ['id', 'nome', 'descrizione', 'immagine_principale', 'prezzo_iniziale'],
            include: [
                {
                    model: Category, // Collega il modello Category
                    attributes: ['nome']
                }
            ]
          },
          {
            model: User, // Collega il venditore (se presente)
            as: 'venditore',
            attributes: ['id', 'nome', 'cognome']
          }
        ]
      });

      // Se l'asta non esiste, restituisci un errore 404
      if (!auction) {
        return res.status(404).json({ error: 'Auction not found' });
      }

      // Restituisci i dettagli dell'asta
      res.status(200).json(auction);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
};

// Recupera un'asta per categoria
const getAuctionsByCategory = async (req, res) => {
    try {
        const { categoryId } = req.params;

        // Recupera tutte le aste con la categoria specificata
        const auctions = await Auction.findAll({
            include: [{
                model: Product,
                where: {
                    categoria_id: categoryId
                }
            }]
        });

        if (!auctions || auctions.length === 0) {
            return res.status(404).json({ message: 'Nessuna asta trovata per questa categoria' });
        }

        return res.status(200).json(auctions);
    } catch (error) {
        return res.status(500).json({ message: 'Errore nel recupero delle aste', error });
    }
};

// Recupera un'asta con lo stato attivo
const getAllActiveAuctions = async (req, res) => {
    try {
        const auctions = await Auction.findAll({
            where: {
                stato: 'attiva' // Filtra solo le aste con stato "attiva"
            },
            include: [
                {
                    model: Product,   // Collega il modello Product
                    include: {
                        model: User,   // Include il venditore tramite il modello User
                        as: 'venditore',
                        attributes: ['id', 'nome', 'cognome']
                    },
                    attributes: ['id', 'nome', 'descrizione', 'immagine_principale', 'prezzo_iniziale', 'categoria_id', 'venditore_id']
                },
                {
                    model: Bid, // Include anche le offerte associate all'asta
                    attributes: ['id', 'importo', 'utente_id']
                }
            ]
        });

        res.status(200).json(auctions);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Recupera una singola asta per ciascun tipo (tempo fisso, inglese, ribasso, silenziosa)
const getAuctionsByType = async (req, res) => {
    try {
        const auctionTypes = ['tempo fisso', 'inglese', 'ribasso', 'silenziosa'];
        let auctions = [];

        for (const type of auctionTypes) {
            const auction = await Auction.findOne({
                where: { tipo: type, stato: 'attiva' }, // Filtra per tipo e stato "attiva"
                include: [
                    {
                        model: Product,  // Collega il modello Product
                        attributes: ['id', 'nome', 'descrizione', 'immagine_principale', 'prezzo_iniziale', 'categoria_id', 'venditore_id'],
                        include: [
                            {
                                model: Category,  // Collega il modello Category tramite Product
                                attributes: ['id', 'nome']  // Recupera anche il nome della categoria
                            }
                        ]
                    }
                ],
            });
            if (auction) {
                auctions.push(auction);
            }
        }

        res.status(200).json(auctions);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Recupera le aste che terminano entro una certa data
const getAuctionsByEndingSoon = async (req, res) => {
    try {
        // Ottieni la data corrente (ora)
        const now = new Date();

        // Imposta la data di fine come 31 dicembre 2024
        const endDate = new Date('2024-12-31T23:59:59');

        // Recupera tutte le aste con data di scadenza compresa tra 'now' e 'endDate'
        const auctions = await Auction.findAll({
            where: {
                data_scadenza: {
                    [Op.between]: [now, endDate]
                },
                stato: 'attiva'  // Filtra solo le aste attive
            },
            include: [
                {
                    model: Product,
                    attributes: ['id', 'nome', 'descrizione', 'immagine_principale', 'prezzo_iniziale', 'categoria_id', 'venditore_id'],
                    include: [
                        {
                            model: User,  // Collega il modello User (venditore)
                            as: 'venditore',  // Assicurati che 'venditore' sia l'alias corretto
                            attributes: ['id', 'nome', 'cognome']  // Recupera il nome e cognome del venditore
                        }
                    ]
                },
                {
                    model: Bid,
                    attributes: ['id', 'importo', 'utente_id']
                }
            ]
        });

        // Verifica se sono state trovate aste
        if (auctions.length > 0) {
            res.status(200).json(auctions);
        } else {
            res.status(200).json({ message: 'Nessuna asta trovata tra oggi e il 31 dicembre 2024' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Recupera l'asta con lo stato completato
const getAuctionCompleted = async (req, res) => {
    try {
        const auctions = await Auction.findAll({
            where: {
                venditore_id: req.user.id, // Venditore corrisponde all'utente autenticato
                stato: 'completata' // Stato completata
            },
            include: [
                {
                    model: Product,   // Collega il modello Product
                    attributes: ['id', 'nome', 'descrizione', 'prezzo_iniziale', 'immagine_principale']
                },
                {
                    model: Bid,   // Include il modello Bid per ottenere l'offerta vincente
                    attributes: ['id', 'importo', 'utente_id'],
                    include: [{
                        model: User,  // Collega l'utente che ha vinto l'asta
                        attributes: ['nome', 'cognome']
                    }]
                }
            ]
        });

        res.status(200).json(auctions);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Recupera l'asta che non è stata venduta
const getUnsoldAuctions = async (req, res) => {
    try {
      const unsoldAuctions = await Auction.findAll({
        where: {
          venditore_id: req.user.id, // Filtra solo le aste dell'utente autenticato
          stato: 'fallita'
        },
        include: [
          {
            model: Product,
            attributes: ['id', 'nome', 'descrizione', 'prezzo_iniziale', 'immagine_principale']
          },
          {
            model: Bid,  // Include le offerte per vedere se ci sono state offerte
            attributes: ['id', 'importo', 'utente_id'],
          }
        ],
      });

      // Aggiungi un campo per specificare il motivo della mancata vendita
      const unsoldWithReasons = unsoldAuctions.map((auction) => {
        let reason;
        if (auction.Bids.length === 0) {
          reason = 'Nessuna offerta ricevuta';
        } else if (auction.prezzo_minimo && auction.Bids[0].importo < auction.prezzo_minimo) {
          reason = 'Prezzo minimo non raggiunto';
        }
        return {
          ...auction.toJSON(),
          reason: reason,
        };
      });

      res.status(200).json(unsoldWithReasons);
    } catch (error) {
      res.status(500).json({ error: 'Errore nel recupero delle aste non vendute.' });
    }
};

// Recupera tutte le aste attive di un utente loggato
const getUserActiveAuctions = async (req, res) => {
    try {
        const userId = req.user.id;  // Ottieni l'ID dell'utente loggato dal token

        const auctions = await Auction.findAll({
            where: {
                stato: 'attiva',         // Filtra solo le aste con stato "attiva"
                venditore_id: userId     // Filtra solo le aste dell'utente loggato
            },
            include: [
                {
                    model: Product,   // Collega il modello Product
                    attributes: ['id', 'nome', 'descrizione', 'immagine_principale', 'prezzo_iniziale', 'categoria_id', 'venditore_id']
                },
                {
                    model: Bid, // Include anche le offerte associate all'asta
                    attributes: ['id', 'importo', 'utente_id']
                }
            ]
        });

        // Controlla se l'utente non ha aste attive
        if (auctions.length === 0) {
            return res.status(200).json({ message: "Al momento non hai aste attive" });
        }

        res.status(200).json(auctions);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Accetta l'offerta per un'asta silenziosa specifica
const acceptBidForSilentAuction = async (req, res) => {
    const { auctionId, bidId } = req.params;

    try {
        const auction = await Auction.findByPk(auctionId, { include: [Product] });

        if (!auction || auction.tipo !== 'silenziosa' || auction.stato !== 'attiva') {
            return res.status(400).json({ error: 'Asta non trovata o già completata/fallita.' });
        }

        // Chiama il servizio per accettare l'offerta
        const result = await auctionService.acceptSilentAuctionBid(auction, bidId);

        // Imposta lo stato a completata
        auction.stato = 'completata';
        await auction.save();

        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: 'Errore nell\'accettazione dell\'offerta per l\'asta silenziosa.' });
    }
};

// Rifiuta tutte le offerte per un'asta silenziosa specifica
const rejectAllBidsForSilentAuction = async (req, res) => {
    const { auctionId } = req.params;

    try {
        const auction = await Auction.findByPk(auctionId, { include: [Product] });

        if (!auction || auction.tipo !== 'silenziosa' || auction.stato !== 'attiva') {
            return res.status(400).json({ error: 'Asta non trovata o già completata/fallita.' });
        }

        // Chiama il servizio per rifiutare tutte le offerte
        const result = await auctionService.rejectAllBidsForSilentAuction(auction);

        // Imposta lo stato a fallita
        auction.stato = 'fallita';
        await auction.save();

        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: 'Errore nel rifiuto delle offerte per l\'asta silenziosa.' });
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

        // Converti la data di scadenza in UTC (fuso orario Europe/Rome)
        const dataScadenzaUTC = data_scadenza ? formatDateUTC(data_scadenza) : auction.data_scadenza;

        auction.prodotto_id = prodotto_id || auction.prodotto_id;
        auction.tipo = tipo || auction.tipo;
        auction.data_scadenza = dataScadenzaUTC;
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

        // Rimuove tutte le offerte associate all'asta (Bids)
        await Bid.destroy({ where: { auction_id: auction.id } });

        // Rimuove tutti gli ordini associati all'asta (Orders)
        await Order.destroy({ where: { auction_id: auction.id } });

        // Rimuove il prodotto associato all'asta
        const product = await Product.findByPk(auction.prodotto_id);
        if (product) {
            await product.destroy();
        }

        // Elimina l'asta stessa
        await auction.destroy();

        res.status(StatusCodes.OK).json({ message: 'Asta e dati associati cancellati con successo' });
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};


// Controllo per verificare se l'utente è il venditore dell'asta
const isUserSeller = async (req, res) => {
    const { auctionId } = req.params;
    const userId = req.user.id; // ID utente dal token

    try {
      const auction = await Auction.findByPk(auctionId);

      if (!auction) {
        return res.status(404).json({ error: "Asta non trovata" });
      }

      // Verifica se l'utente è il venditore
      const isSeller = auction.venditore_id === userId;
      res.status(200).json({ isSeller });
    } catch (error) {
      console.error('Errore nel controllo venditore:', error);
      res.status(500).json({ error: 'Errore del server' });
    }
};

module.exports = {
    createAuction,
    getAllAuctions,
    getAuctionById,
    getAuctionsByCategory,
    getAllActiveAuctions,
    getAuctionsByEndingSoon,
    getAuctionsByType,
    getAuctionCompleted,
    getUnsoldAuctions,
    getUserActiveAuctions,
    acceptBidForSilentAuction,
    rejectAllBidsForSilentAuction,
    updateAuction,
    deleteAuction,
    isUserSeller
};
