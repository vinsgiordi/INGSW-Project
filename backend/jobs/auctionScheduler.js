const cron = require('node-cron');
const { Op } = require('sequelize');
const Auction = require('../models/auction');
const Product = require('../models/product');
const auctionService = require('../services/auctionServices');

// Pianifica il controllo ogni minuto
cron.schedule('* * * * *', async () => {
    console.log('Controllo delle aste in scadenza e delle aste al ribasso...');

    const now = new Date();

    // Trova tutte le aste attive che sono scadute
    const auctions = await Auction.findAll({
        where: {
            data_scadenza: {
                [Op.lte]: now, // Le aste con scadenza <= ora
            },
            stato: 'attiva' // Solo le aste ancora attive
        },
        include: [Product] // Includi il prodotto collegato all'asta
    });

    // Trova tutte le aste al ribasso scadute
    const reverseAuctions = await Auction.findAll({
        where: {
            tipo: 'ribasso',
            stato: 'attiva',
            data_scadenza: { [Op.gt]: now },
        },
        include: [Product],
    });

    // Gestisci ciascuna asta scaduta
    for (const auction of auctions) {
        try {
            if (auction.tipo === 'tempo fisso') {
                await auctionService.handleAuctionExpiration(auction);
            } else if (auction.tipo === 'inglese') {
                await auctionService.handleEnglishAuctionExpiration(auction);
            } else if (auction.tipo === 'ribasso') {
                await auctionService.handleReverseAuction(auction);
            } else if (auction.tipo === 'silenziosa') {
                const { acceptBidId } = auction;
                await auctionService.acceptSilentAuctionBid(auction, acceptBidId);
            }

            // Dopo aver gestito l'asta, aggiorna lo stato a "completata" o "fallita"
            auction.stato = 'completata'; // O impostalo come "fallita" in base alla logica
            await auction.save();

            console.log(`Gestita l'asta ${auction.id} (${auction.tipo})`);
        } catch (error) {
            console.error(`Errore nella gestione dell'asta ${auction.id}:`, error);
        }
    }

    // Gestisci le aste al ribasso attive
    for (const auction of reverseAuctions) {
        try {
            await auctionService.handleReverseAuction(auction);
        } catch (errore) {
            console.error(`Errore nella gestione dell'asta al ribasso ${auction.id}:`, error);
        }
    }
});

console.log('Scheduler delle aste avviato.');
