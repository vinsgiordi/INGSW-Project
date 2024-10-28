const Notification = require('../models/notification');
const Bid = require('../models/bid');
const Auction = require('../models/auction');
const dayjs = require('../utils/dayjs');

// Logica per la gestione della scadenza delle aste a tempo fisso e all'inglese
const handleAuctionExpiration = async (auction) => {
    try {
        console.log(`Gestione dell'asta scaduta: ID ${auction.id}`);

        if (!auction.Product) {
            console.error(`Prodotto non trovato per l'asta ID: ${auction.id}`);
            return;
        }

        const highestBid = await Bid.findOne({
            where: { auction_id: auction.id },
            order: [['importo', 'DESC']],
        });

        if (auction.tipo === 'tempo fisso') {
            await handleFixedTimeAuction(auction, highestBid);
        } else if (auction.tipo === 'inglese') {
            await handleEnglishAuctionExpiration(auction, highestBid);
        } else if (auction.tipo === 'ribasso') {
            await handleReverseAuction(auction);
        } else if (auction.tipo === 'silenziosa') {
            await handleSilentAuctionExpiration(auction);
        }
    } catch (error) {
        console.error(`Errore nella gestione dell'asta ID ${auction.id}:`, error);
    }
};

// Gestione della scadenza per le aste a tempo fisso
const handleFixedTimeAuction = async (auction, highestBid) => {
    if (highestBid && highestBid.importo >= auction.prezzo_minimo) {
        auction.stato = 'completata';
        await auction.save();
        console.log(`Asta ID ${auction.id} completata con successo.`);

        await Notification.create({
            utente_id: highestBid.utente_id,
            messaggio: `Hai vinto l'asta per ${auction.Product.nome} con un'offerta di €${highestBid.importo}.`,
        });

        await Notification.create({
            utente_id: auction.venditore_id,
            messaggio: `L'asta per il tuo prodotto ${auction.Product.nome} è terminata con un'offerta vincente di €${highestBid.importo}.`,
        });
    } else {
        auction.stato = 'fallita';
        await auction.save();
        console.log(`Asta ID ${auction.id} fallita.`);

        await Notification.create({
            utente_id: auction.venditore_id,
            messaggio: `L'asta per il tuo prodotto ${auction.Product.nome} è fallita. Nessuna offerta valida è stata ricevuta.`,
        });

        if (highestBid) {
            const bids = await Bid.findAll({ where: { auction_id: auction.id } });
            for (const bid of bids) {
                await Notification.create({
                    utente_id: bid.utente_id,
                    messaggio: `L'asta per ${auction.Product.nome} è fallita poiché non è stato raggiunto il prezzo minimo.`,
                });
            }
        }
    }
};

// Gestione della scadenza per le aste all'inglese
const handleEnglishAuctionExpiration = async (auction, highestBid) => {
    if (highestBid) {
        await Notification.create({
            utente_id: highestBid.utente_id,
            messaggio: `Hai vinto l'asta all'inglese per ${auction.Product.nome} con un'offerta di €${highestBid.importo}.`,
        });

        await Notification.create({
            utente_id: auction.venditore_id,
            messaggio: `L'asta all'inglese per il tuo prodotto ${auction.Product.nome} è terminata. L'offerta vincente è di €${highestBid.importo}.`,
        });
    } else {
        console.log(`Nessuna offerta valida per l'asta inglese ID ${auction.id}`);
    }
};

// Logica per la gestione della scadenza delle aste al ribasso
const handleReverseAuction = async (auction) => {
    try {
        const now = new Date();
        const lastUpdateTime = auction.updatedAt || auction.createdAt;
        const hoursSinceLastUpdate = (now - new Date(lastUpdateTime)) / (1000 * 60 * 60);
        const decrementSteps = Math.floor(hoursSinceLastUpdate / auction.timer_decremento);

        if (decrementSteps > 0) {
            const newPrice = auction.prezzo_iniziale - (decrementSteps * auction.decremento_prezzo);

            if (newPrice <= auction.prezzo_minimo) {
                const highestBid = await Bid.findOne({
                    where: { auction_id: auction.id },
                    order: [['importo', 'DESC']],
                });

                if (!highestBid) {
                    auction.stato = 'fallita';
                    await auction.save();
                    await Notification.create({
                        utente_id: auction.venditore_id,
                        messaggio: `L'asta al ribasso per ${auction.Product.nome} è fallita. Il prezzo ha raggiunto il minimo senza offerte.`,
                    });
                } else {
                    auction.stato = 'completata';
                    await auction.save();
                    await Notification.create({
                        utente_id: auction.venditore_id,
                        messaggio: `L'asta al ribasso per ${auction.Product.nome} è terminata. L'offerta vincente è di €${highestBid.importo}.`,
                    });
                }
            } else {
                auction.prezzo_iniziale = newPrice;
                await auction.save();
                console.log(`Prezzo aggiornato a €${newPrice} per l'asta ${auction.id}`);
            }
        }
    } catch (error) {
        console.error('Errore nella gestione dell\'asta al ribasso:', error);
    }
};

// Logica per la gestione della scadenza delle aste silenziose
const handleSilentAuctionExpiration = async (auction) => {
    try {
        const bids = await Bid.findAll({ where: { auction_id: auction.id } });

        if (bids.length === 0) {
            // Notifica il venditore che l'asta è scaduta senza offerte
            await Notification.create({
                utente_id: auction.venditore_id,
                messaggio: `L'asta silenziosa per il tuo prodotto ${auction.Product.nome} è terminata senza offerte.`,
                auction_id: auction.id,
                bid_id: null,
            });
            console.log(`Notifica inviata al venditore per asta senza offerte, auction_id=${auction.id}`);
        } else {
            // Notifica il venditore di una nuova offerta con invito alla decisione
            const highestBid = bids[0];
            await Notification.create({
                utente_id: auction.venditore_id,
                messaggio: `Hai ricevuto una nuova offerta di €${highestBid.importo} per il tuo prodotto ${auction.Product.nome}. Controlla per accettare o rifiutare l'offerta.`,
                auction_id: auction.id,
                bid_id: highestBid.id,
            });
            console.log(`Notifica inviata al venditore per offerta ricevuta, auction_id=${auction.id}, bid_id=${highestBid.id}`);
        }
    } catch (error) {
        console.error(`Errore nella gestione dell'asta silenziosa ID ${auction.id}:`, error);
    }
};

// Logica per accettare un'offerta per le aste silenziose
const acceptSilentAuctionBid = async (auction, bidId) => {
    try {
        const bid = await Bid.findByPk(bidId);

        if (!bid || bid.auction_id !== auction.id) {
            throw new Error('Offerta non trovata o non valida per questa asta.');
        }

        // Aggiorna lo stato dell'asta a "completata"
        auction.stato = 'completata';
        await auction.save();

        // Notifica l'offerente che la sua offerta è stata accettata
        await Notification.create({
            utente_id: bid.utente_id,
            messaggio: `La tua offerta per l'asta silenziosa del prodotto ${auction.Product.nome} è stata accettata.`,
        });

        // Notifica il venditore che l'asta è completata
        await Notification.create({
            utente_id: auction.venditore_id,
            messaggio: `Hai accettato l'offerta per il prodotto ${auction.Product.nome}. L'asta è stata completata.`,
        });

        return { success: true, message: 'Offerta accettata con successo.' };
    } catch (error) {
        console.error(`Errore nell'accettazione dell'offerta per l'asta silenziosa: ${error}`);
        throw error;
    }
};

// Logica per rifiutare un'offerta per le aste silenziose
const rejectAllBidsForSilentAuction = async (auction) => {
    try {
        // Aggiorna lo stato dell'asta a "fallita"
        auction.stato = 'fallita';
        await auction.save();

        // Notifica il venditore che l'asta è fallita
        await Notification.create({
            utente_id: auction.venditore_id,
            messaggio: `Hai rifiutato tutte le offerte per il prodotto ${auction.Product.nome}. L'asta è stata annullata.`,
        });

        return { success: true, message: 'Tutte le offerte rifiutate e asta annullata.' };
    } catch (error) {
        console.error(`Errore nel rifiuto delle offerte per l'asta silenziosa: ${error}`);
        throw error;
    }
};

module.exports = {
    handleAuctionExpiration,
    handleFixedTimeAuction,
    handleEnglishAuctionExpiration,
    handleReverseAuction,
    handleSilentAuctionExpiration,
    acceptSilentAuctionBid,
    rejectAllBidsForSilentAuction,
};
