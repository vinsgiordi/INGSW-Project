const cron = require('node-cron');
const { Op } = require('sequelize');
const Auction = require('../models/auction');
const Product = require('../models/product');
const auctionService = require('../services/auctionServices');

// Pianifica il controllo ogni minuto
cron.schedule('* * * * *', async () => {
    const now = new Date();
    console.log(`[${now.toISOString()}] Avvio del cron per le aste.`);

    // Controlla e trova tutte le aste scadute e attive
    const auctions = await Auction.findAll({
        where: {
            data_scadenza: {
                [Op.lte]: now, // Scadute
            },
            stato: 'attiva', // Attive
        },
        include: [Product],
    });

    console.log(`Aste scadute e attive trovate: ${auctions.length}`);

    // Log per ogni asta rilevata
    auctions.forEach((auction) => {
        console.log(`Asta trovata con ID ${auction.id}: stato - ${auction.stato}, tipo - ${auction.tipo}`);
    });

    // Esegui l'aggiornamento dello stato delle aste scadute
    for (const auction of auctions) {
        await auctionService.handleAuctionExpiration(auction);
    }
});

console.log('Scheduler delle aste avviato.');
