require('dotenv').config();
const { Sequelize } = require('sequelize');

// Configura l'URL del database per Docker o le variabili di ambiente individuali per l'ambiente di sviluppo
const databaseUrl = process.env.DATABASE_URL ||
  `postgres://${process.env.PG_USER}:${process.env.PG_PASSWORD}@${process.env.PG_HOST}:${process.env.PG_PORT}/${process.env.PG_DATABASE}`;

const sequelize = new Sequelize(databaseUrl, {
  dialect: 'postgres',
  protocol: 'postgres',
  logging: false,
  dialectOptions: {
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
  }
});

async function connectWithRetry(retries = 5, delay = 3000) {
  while (retries) {
    try {
      await sequelize.authenticate();
      console.log('Connessione al database avvenuta con successo!');
      return;
    } catch (err) {
      retries -= 1;
      console.error(`Errore di connessione al database: ${err.message}. Nuovo tentativo tra ${delay / 1000} secondi...`);
      if (retries === 0) {
        throw new Error('Impossibile connettersi al database dopo vari tentativi');
      }
      await new Promise((res) => setTimeout(res, delay));
    }
  }
}

connectWithRetry().catch(err => console.error(err.message));

module.exports = sequelize;
