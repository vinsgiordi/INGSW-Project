const express = require('express');
const passport = require('./config/passportConfig');
const bodyParser = require('body-parser');

// Import delle rotte
const usersRoutes = require('./routes/userRoutes');
const auctionsRoutes = require('./routes/auctionRoutes');
const bidsRoutes = require('./routes/bidRoutes');
const paymentsRoutes = require('./routes/paymentRoutes');
const ordersRoutes = require('./routes/orderRoutes');
const notificationsRoutes = require('./routes/notificationRoutes');
const authRoutes = require('./routes/authRoutes');

const app = express();

// Middleware per il parsing del JSON
app.use(bodyParser.json());

// Inizializzazione di Passport
app.use(passport.initialize());

// Rotte
app.use('/api/users', usersRoutes); // Gestione degli utenti
app.use('/api/auctions', auctionsRoutes); // Gestione delle aste
app.use('/api/bids', bidsRoutes); // Gestione delle offerte
app.use('/api/payments', paymentsRoutes); // Gestione dei pagamenti
app.use('/api/orders', ordersRoutes); // Gestione degli ordini
app.use('/api/notifications', notificationsRoutes); // Gestione delle notifiche
app.use('/auth', authRoutes); // Gestione dell'autenticazione

// Avvio del server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server in ascolto sulla porta ${PORT}`);
});
