const cron = require('node-cron');
const { Op } = require('sequelize');
const Auction = require('../models/auction');
const Product = require('../models/product');
const auctionService = require('../services/auctionServices');

// Pianifica il controllo ogni 5 minuti
cron.schedule('*/5 * * * *', async () => {
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

    for (const auction of auctions) {
        console.log(`Gestione dell'asta scaduta con ID ${auction.id}: tipo - ${auction.tipo}`);
        await auctionService.handleAuctionExpiration(auction);
    }
});

console.log('Scheduler delle aste avviato.');
