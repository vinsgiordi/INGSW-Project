const Notification  = require('../models/notification');
const Bid = require('../models/bid');
const Auction = require('../models/auction');
const dayjs = require('../utils/dayjs');

// Logica per la gestione della scadenza delle aste a tempo fisso
const handleAuctionExpiration = async (auction) => {
    try {
        console.log('Gestione dell\'asta scaduta:', auction.id);  // Debug
        console.log('Controllo se Bid è definito:', Bid);  // Debug

        // Assicurati che il prodotto esista
        if (!auction.Product) {
            console.error('Prodotto non trovato per l\'asta:', auction.id);
            return;
        }

        // Trova l'offerta più alta
        const highestBid = await Bid.findOne({
            where: { auction_id: auction.id },
            order: [['importo', 'DESC']],
        });

        if (highestBid) {
            console.log('Offerta più alta trovata:', highestBid);  // Debug
        } else {
            console.log('Nessuna offerta trovata per l\'asta:', auction.id);  // Debug
        }

        if (highestBid && highestBid.importo >= auction.prezzo_minimo) {
            // Notifica il vincitore
            await Notification.create({
                utente_id: highestBid.utente_id,
                messaggio: `Hai vinto l'asta per ${auction.Product.nome} con un'offerta di € ${highestBid.importo}.`,
            });

            // Notifica il venditore
            await Notification.create({
                utente_id: auction.venditore_id,
                messaggio: `L'asta per il tuo prodotto ${auction.Product.nome} è terminata. L'offerta vincente è di €${highestBid.importo}.`,
            });
        } else {
            // L'asta è fallita
            const bids = await Bid.findAll({ where: { auction_id: auction.id } });

            for (const bid of bids) {
                // Notifica ciascun acquirente del fallimento dell'asta
                await Notification.create({
                    utente_id: bid.utente_id,
                    messaggio: `L'asta per ${auction.Product.nome} è fallita poiché non è stata raggiunta la soglia minima.`,
                });
            }

            // Notifica il venditore che l'asta è fallita
            await Notification.create({
                utente_id: auction.venditore_id,
                messaggio: `L'asta per il tuo prodotto ${auction.Product.nome} è fallita. La soglia minima non è stata raggiunta.`,
            });
        }
    } catch (error) {
        console.error('Errore nella gestione dell\'asta a tempo fisso:', error);
    }
};

// Logica per la gestione della scadenza delle aste all'inglese
const handleEnglishAuctionExpiration = async (auction) => {
    try {
        const highestBid = await Bid.findOne({
            where: { auction_id: auction.id },
            order: [['importo', 'DESC']],
        });

        if (highestBid) {
            // Notifica il vincitore
            await Notification.create({
                utente_id: highestBid.utente_id,
                messaggio: `Hai vinto l'asta all'inglese per ${auction.Product.nome} con un'offerta di €${highestBid.importo}.`,
            });

            // Notifica il venditore
            await Notification.create({
                utente_id: auction.venditore_id,
                messaggio: `L'asta all'inglese per il tuo prodotto ${auction.Product.nome} è terminata. L'offerta vincente è di €${highestBid.importo}.`,
            });
        }
    } catch (error) {
        console.error('Errore nella gestione dell\'asta all\'inglese:', error);
    }
};

// Logica per gestire il reset del timer quando viene fatta una nuova offerta per l'asta all'inglese
const handleNewBidForEnglishAuction = async (auction, newBid) => {
    try {
        // Aggiungi 1 ora alla data corrente per resettare il timer
        const newEndTime = dayjs().add(1, 'hour').format('YYYY-MM-DD HH:mm:ss');

        // Aggiorna la data di scadenza dell'asta
        auction.data_scadenza = newEndTime;
        await auction.save();

        console.log(`Data di scadenza aggiornata a: ${newEndTime} per l'asta ${auction.id}`);

        // Gestisci la creazione della nuova offerta e notifica gli utenti coinvolti
        await Notification.create({
            utente_id: newBid.utente_id,
            messaggio: `La tua offerta di €${newBid.importo} per l'asta all'inglese è stata registrata.`,
        });

        await Notification.create({
            utente_id: auction.venditore_id,
            messaggio: `Una nuova offerta di €${newBid.importo} è stata fatta per il tuo prodotto ${auction.Product.nome}.`,
        });

    } catch (error) {
        console.error('Errore durante il reset del timer per l\'asta all\'inglese:', error);
    }
};

// Logica per la gestione della scadenza delle aste al ribasso
const handleReverseAuction = async (auction) => {
    try {
        const now = new Date();
        const lastUpdateTime = auction.updatedAt || auction.createdAt;
        const hoursSinceLastUpdate = (now - new Date(lastUpdateTime)) / (1000 * 60 * 60); // Differenza in ore

        // Calcola quanti decrementi devono essere applicati
        const decrementSteps = Math.floor(hoursSinceLastUpdate / auction.timer_decremento);
        if (decrementSteps > 0) {
            const newPrice = auction.prezzo_iniziale - (decrementSteps * auction.decremento_prezzo);

            if (newPrice <= auction.prezzo_minimo) {
                // Notifica che l'asta è fallita
                auction.stato = 'fallita';
                await auction.save();
                await Notification.create({
                    utente_id: auction.venditore_id,
                    messaggio: `L'asta al ribasso per ${auction.Product.nome} è fallita. Il prezzo ha raggiunto il minimo senza offerte.`,
                });
            } else {
                // Aggiorna il prezzo corrente
                auction.prezzo_corrente = newPrice;
                await auction.save();
                console.log(`Prezzo aggiornato a €${newPrice} per l'asta ${auction.id}`);
            }
        }
    } catch (error) {
        console.error('Errore nella gestione dell\'asta al ribasso:', error);
    }
};

// Logica per accettare un'offerta per le aste silenziose
const acceptSilentAuctionBid = async (auction, acceptedBidId) => {
    try {
        const acceptedBid = await Bid.findByPk(acceptedBidId);

        if (acceptedBid) {
            // Notifica il vincitore
            await Notification.create({
                utente_id: acceptedBid.utente_id,
                messaggio: `La tua offerta per l'asta silenziosa del prodotto ${auction.Product.nome} è stata accettata.`,
            });

            // Notifica il venditore
            await Notification.create({
                utente_id: auction.venditore_id,
                messaggio: `Hai accettato l'offerta per il prodotto ${auction.Product.nome}.`,
            });
        }
    } catch (error) {
        console.error('Errore nell\'accettazione dell\'offerta per l\'asta silenziosa:', error);
    }
};

module.exports = {
    handleAuctionExpiration,
    handleEnglishAuctionExpiration,
    handleNewBidForEnglishAuction,
    handleReverseAuction,
    acceptSilentAuctionBid
};
