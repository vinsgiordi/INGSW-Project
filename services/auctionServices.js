const Notification = require('../models/notification');
const Bid = require('../models/bid');
const Auction = require('../models/auction');
const Order = require('../models/order');
const User = require('../models/user');
const Payment = require('../models/payment');
const orderController = require('../controllers/orderController');

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
            await handleReverseAuction(auction, highestBid);
        } else if (auction.tipo === 'silenziosa') {
            await handleSilentAuctionExpiration(auction);
        }
    } catch (error) {
        console.error(`Errore nella gestione dell'asta ID ${auction.id}:`, error);
    }
};

// Gestione della scadenza per le aste a tempo fisso
const handleFixedTimeAuction = async (auction, highestBid) => {
    try {
        // Verifica se esiste un'offerta valida e se ha raggiunto il prezzo minimo
        if (highestBid && highestBid.importo >= auction.prezzo_minimo) {
            auction.stato = 'completata';
            await auction.save();
            console.log(`Asta ID ${auction.id} completata con successo. Offerta vincente: €${highestBid.importo}`);

            // Creazione automatica dell'ordine
            await createOrder(auction, highestBid);

            // Notifica all'acquirente vincitore
            await Notification.create({
                utente_id: highestBid.utente_id,
                messaggio: `Hai vinto l'asta per ${auction.Product.nome} con un'offerta di €${highestBid.importo}.`,
            });

            // Notifica al venditore
            await Notification.create({
                utente_id: auction.venditore_id,
                messaggio: `L'asta per il tuo prodotto ${auction.Product.nome} è terminata con un'offerta vincente di €${highestBid.importo}.`,
            });
        } else {
            // Se l'offerta non ha raggiunto il prezzo minimo, segna l'asta come fallita
            auction.stato = 'fallita';
            await auction.save();
            console.log(`Asta ID ${auction.id} fallita. Prezzo minimo non raggiunto.`);

            // Notifica il venditore dell'asta fallita
            await Notification.create({
                utente_id: auction.venditore_id,
                messaggio: `L'asta per il tuo prodotto ${auction.Product.nome} è fallita. Nessuna offerta valida è stata ricevuta.`,
            });

            // Notifica gli offerenti che l'asta è fallita
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
    } catch (error) {
        console.error(`Errore nella gestione dell'asta a tempo fisso ID ${auction.id}:`, error);
    }
};

// Gestione della scadenza per le aste all'inglese
const handleEnglishAuctionExpiration = async (auction, highestBid) => {
    try {
        if (highestBid) {
            auction.stato = 'completata';
            await auction.save();

            // Creazione dell'ordine in automatico
            await createOrder(auction, highestBid);

            // Notifica all'acquirente vincitore
            await Notification.create({
                utente_id: highestBid.utente_id,
                messaggio: `Hai vinto l'asta all'inglese per ${auction.Product.nome} con un'offerta di €${highestBid.importo}.`,
            });

            // Notifica al venditore
            await Notification.create({
                utente_id: auction.venditore_id,
                messaggio: `L'asta all'inglese per il tuo prodotto ${auction.Product.nome} è terminata. L'offerta vincente è di €${highestBid.importo}.`,
            });
        } else {
            auction.stato = 'fallita';
            await auction.save();
            console.log(`Nessuna offerta valida per l'asta inglese ID ${auction.id}`);

            // Notifica il venditore dell'asta fallita
            await Notification.create({
                utente_id: auction.venditore_id,
                messaggio: `L'asta all'inglese per il tuo prodotto ${auction.Product.nome} è fallita. Nessuna offerta valida è stata ricevuta.`,
            });
        }
    } catch (error) {
        console.error(`Errore nella gestione dell'asta all'inglese ID ${auction.id}:`, error);
    }
};

// Logica per la gestione della scadenza per le aste al ribasso
const handleReverseAuction = async (auction, highestBid) => {
    console.log(`Esecuzione di handleReverseAuction a ${new Date()} per l'asta con ID ${auction.id}`);

    try {
        const now = new Date();
        const timerDecrementoMs = (auction.timer_decremento || 60) * 60 * 1000; // Imposta il timer a 1 ora se non specificato
        console.log(`Asta ID ${auction.id} - timerDecremento in ms: ${timerDecrementoMs}`);

        if (now >= new Date(auction.data_scadenza)) {
            const newPrice = auction.prezzo_iniziale - auction.decremento_prezzo;
            console.log(`Asta ID ${auction.id} - Nuovo prezzo calcolato: €${newPrice}`);

            if (newPrice <= auction.prezzo_minimo) {
                console.log(`Asta ID ${auction.id} - Prezzo minimo raggiunto senza offerte, impostazione su fallita`);
                auction.stato = 'fallita';
                await auction.save();

                await Notification.create({
                    utente_id: auction.venditore_id,
                    messaggio: `L'asta al ribasso per ${auction.Product.nome} è fallita. Il prezzo ha raggiunto il minimo senza offerte.`,
                });
            } else {
                auction.prezzo_iniziale = newPrice;
                auction.data_scadenza = new Date(now.getTime() + timerDecrementoMs);
                await auction.save();
                console.log(`Asta ID ${auction.id} - Prezzo decrementato a €${newPrice}, nuova scadenza aggiornata a ${auction.data_scadenza}`);
            }
        } else {
            console.log(`Asta ID ${auction.id} - Nessun decremento necessario al momento.`);
        }

        if (highestBid && auction.stato === 'attiva') {
            console.log(`Asta ID ${auction.id} - Offerta ricevuta, completamento asta.`);
            auction.stato = 'completata';
            await auction.save();

            const ordine = await createOrder(auction, highestBid);
            console.log("Ordine creato con successo:", ordine);

            await Notification.create({
                utente_id: highestBid.utente_id,
                messaggio: `Hai vinto l'asta per ${auction.Product.nome} con un'offerta di €${highestBid.importo}.`,
            });
            await Notification.create({
                utente_id: auction.venditore_id,
                messaggio: `L'asta per il tuo prodotto ${auction.Product.nome} è terminata con un'offerta vincente di €${highestBid.importo}.`,
            });
        }

    } catch (error) {
        console.error("Errore nella gestione dell'asta al ribasso:", error);
    }
};

// Logica per la gestione della scadenza delle aste silenziose
const handleSilentAuctionExpiration = async (auction) => {
    try {
        const bids = await Bid.findAll({
            where: { auction_id: auction.id },
            order: [['importo', 'DESC']],
        });

        if (bids.length === 0) {
            auction.stato = 'fallita';
            await auction.save();

            // Notifica il venditore che l'asta è scaduta senza offerte
            await Notification.create({
                utente_id: auction.venditore_id,
                messaggio: `L'asta silenziosa per il tuo prodotto ${auction.Product.nome} è terminata senza offerte.`,
                auction_id: auction.id,
                bid_id: null,
            });
            console.log(`Notifica inviata al venditore per asta senza offerte, auction_id=${auction.id}`);
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

        console.log('Dati Auction:', auction); // Controllo
        console.log('Dati Bid:', bid); // Controllo

        if (!auction.venditore_id || !bid.utente_id) {
            throw new Error('Venditore o Acquirente non trovato');
        }

        // Recupera l'utente (acquirente) per ottenere l'indirizzo di spedizione
        const acquirente = await User.findByPk(bid.utente_id);
        if (!acquirente) {
            throw new Error('Acquirente non trovato.');
        }

        const metodoPagamento = await Payment.findOne({
            where: { utente_id: bid.utente_id }
        });

        // Aggiorna lo stato dell'asta a "completata"
        auction.stato = 'completata';
        await auction.save();

        const ordine = await createOrder(auction, bid);
        console.log("Ordine creato con successo:", ordine);

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

        return { success: true, message: 'Offerta accettata con successo e ordine creato.' };
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
            messaggio: `Hai rifiutato l'offerta per il prodotto ${auction.Product.nome}. L'asta è stata annullata.`,
        });

        return { success: true, message: 'Offerta rifiutata e asta annullata.' };
    } catch (error) {
        console.error(`Errore nel rifiuto dell'offerta per l'asta silenziosa: ${error}`);
        throw error;
    }
};

// Funzione per la creazione dell'ordine
const createOrder = async (auction, bid) => {
    try {
        const acquirente = await User.findByPk(bid.utente_id);
        if (!acquirente) {
            throw new Error('Acquirente non trovato.');
        }

        const metodoPagamento = await Payment.findOne({
            where: { utente_id: bid.utente_id }
        });

        const orderData = {
            prodotto_id: auction.prodotto_id,
            auction_id: auction.id,
            acquirente_id: bid.utente_id,
            venditore_id: auction.venditore_id,
            indirizzo_spedizione: acquirente.indirizzo_spedizione || "",
            metodo_pagamento: metodoPagamento ? metodoPagamento.numero_carta : "",
            importo_totale: bid.importo
        };

        return await Order.create(orderData);
    } catch (error) {
        console.error('Errore nella creazione dell\'ordine:', error);
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
