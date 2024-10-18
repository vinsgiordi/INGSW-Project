const { StatusCodes } = require('http-status-codes');
const Auction = require('../models/auction');
const Product = require('../models/product');
const Bid = require('../models/bid');
const Category = require('../models/category');
const { User } = require('../models/associations');
const { Op } = require('sequelize');
const auctionService = require('../services/auctionServices');
const dayjs = require('../utils/dayjs');

// Funzione per formattare le date in UTC
const formatDateUTC = (date) => {
  return dayjs(date).tz('Europe/Rome').utc().format();
};

// Crea una nuova asta
const createAuction = async (req, res) => {
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

        // Converti la data di scadenza in UTC (fuso orario Europe/Rome)
        const dataScadenzaUTC = formatDateUTC(data_scadenza);
        console.log('Data di scadenza UTC:', dataScadenzaUTC);

        // Configura l'asta in base al tipo di asta
        let auctionData = {
            prodotto_id: product.id,
            tipo,
            data_scadenza: dataScadenzaUTC,  // Usa la data convertita in UTC
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

const handleAuctionCompletion = async (req, res) => {
    const auctionId = req.params.id;
    const auction = await Auction.findByPk(auctionId);

    if (!auction) {
        return res.status(404).json({ error: 'Asta non trovata' });
    }

    if (auction.tipo === 'tempo fisso') {
        await auctionService.handleAuctionExpiration(auction);
    } else if (auction.tipo === 'inglese') {
        await auctionService.handleEnglishAuctionExpiration(auction);
    } else if (auction.tipo === 'ribasso') {
        await auctionService.handleReverseAuction(auction);
    } else if (auction.tipo === 'silenziosa') {
        const { acceptedBidId } = req.body;
        await auctionService.acceptSilentAuctionBid(auction, acceptedBidId);
    }

    res.status(200).json({ message: 'Asta gestita correttamente' });
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

        await Bid.destroy({ where: { auction_id: auction.id } });

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
    getAuctionsByCategory,
    getAllActiveAuctions,
    getAuctionsByEndingSoon,
    getAuctionsByType,
    updateAuction,
    handleAuctionCompletion,
    deleteAuction
};
