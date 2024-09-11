require('dotenv').config();
const { Sequelize } = require('sequelize');

const sequelize = new Sequelize(process.env.PG_DATABASE, process.env.PG_USER, process.env.PG_PASSWORD, {
  host: process.env.PG_HOST,
  dialect: 'postgres',
  port: process.env.PG_PORT,
});

sequelize.authenticate()
  .then(() => console.log('Connessione al database avvenuta con successo!'))
  .catch(err => console.error('Errore di connessione al database:', err));

module.exports = sequelize;
