const express = require('express');
const passport = require('./config/passportConfig');
const bodyParser = require('body-parser');

const db = require('./models/associations');

// Import delle rotte
const usersRoutes = require('./routes/userRoutes');
const auctionsRoutes = require('./routes/auctionRoutes');
const bidsRoutes = require('./routes/bidRoutes');
const paymentsRoutes = require('./routes/paymentRoutes');
const ordersRoutes = require('./routes/orderRoutes');
const notificationsRoutes = require('./routes/notificationRoutes');
const categoriesRoutes = require('./routes/categoryRoutes');
const authRoutes = require('./routes/authRoutes');
const sellerRoutes = require('./routes/sellerRoutes');
const searchRoutes = require('./routes/searchRoutes');

const app = express();

// Job cron
const auctionScheduler = require('./jobs/auctionScheduler');

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
app.use('/api/categories', categoriesRoutes); // Gestione delle categorie
app.use('/auth', authRoutes); // Gestione dell'autenticazione
app.use('/api/sellers', sellerRoutes); // Gestione dei venditore
app.use('/api', searchRoutes); // Gestione della ricerca

app.post('/auth/refresh-token', (req, res) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
      return res.status(StatusCodes.UNAUTHORIZED).json({ error: 'Token di refresh mancante' });
  }

  // Verifica il token di refresh
  jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET, (err, user) => {
      if (err) return res.status(StatusCodes.FORBIDDEN).json({ error: 'Token di refresh non valido' });

      // Se il refresh token è valido, genera un nuovo access token
      const accessToken = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });

      res.status(StatusCodes.OK).json({ accessToken });
  });
});

const cors = require('cors');
app.use(cors({
  origin: '*', // Per sviluppo locale, puoi specificare il dominio del frontend in produzione
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  credentials: true
}));

// Avvio del server
db.sequelize.sync({ alter: true })
/* Utilizziamo `alter: true` per la sincronizzazione del database
   altrimenti `force: false` per evitare la sincronizzazione
   non utilizziamo `force: true` per evitare di cancellare i dati
*/
  .then(() => {
    console.log('Database sincronizzato correttamente');
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
      console.log(`Server in ascolto sulla porta ${PORT}`);
    });
  })
  .catch((err) => {
    console.error('Errore nella sincronizzazione del database:', err);
  });