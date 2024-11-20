const Sequelize = require('sequelize');
const sequelize = require('../config/db');

// Importa i modelli
const Auction = require('./auction');
const Bid = require('./bid');
const Product = require('./product');
const User = require('./user');
const Category = require('./category');
const Notification = require('./notification');
const Order = require('./order');

// Definizione delle associazioni

// Un'asta (Auction) è associata a un prodotto (Product)
// Un prodotto può avere molte aste associate
Auction.belongsTo(Product, { foreignKey: 'prodotto_id', onDelete: 'CASCADE' });
Product.hasMany(Auction, { foreignKey: 'prodotto_id', onDelete: 'CASCADE' });

// Un'asta (Auction) è associata a un venditore (User)
// Un venditore (utente) può avere molte aste associate
Auction.belongsTo(User, { foreignKey: 'venditore_id', as: 'venditore' });
User.hasMany(Auction, { foreignKey: 'venditore_id', onDelete: 'CASCADE' });

// Un'asta (Auction) può avere molte offerte (Bid) associate
// Ogni offerta appartiene a una singola asta
Auction.hasMany(Bid, { foreignKey: 'auction_id', onDelete: 'CASCADE' });
Bid.belongsTo(Auction, { foreignKey: 'auction_id', onDelete: 'CASCADE' });

// Un'offerta (Bid) è fatta da un utente (User)
// Un utente può fare molte offerte
Bid.belongsTo(User, { foreignKey: 'utente_id', onDelete: 'CASCADE' });
User.hasMany(Bid, { foreignKey: 'utente_id', onDelete: 'CASCADE' });

// Un'offerta (Bid) è associata a un prodotto (Product)
// Un prodotto può avere molte offerte
Bid.belongsTo(Product, { foreignKey: 'prodotto_id', onDelete: 'CASCADE' });
Product.hasMany(Bid, { foreignKey: 'prodotto_id', onDelete: 'CASCADE' });

// Un prodotto (Product) appartiene a una categoria (Category)
// Una categoria può includere molti prodotti
Product.belongsTo(Category, { foreignKey: 'categoria_id' });
Category.hasMany(Product, { foreignKey: 'categoria_id' });

// Un prodotto (Product) è associato a un venditore (User) che lo ha messo in vendita
// Un venditore (utente) può avere molti prodotti in vendita
Product.belongsTo(User, { foreignKey: 'venditore_id', as: 'venditore' });
User.hasMany(Product, { foreignKey: 'venditore_id', onDelete: 'CASCADE' });

// Un utente (User) può ricevere molte notifiche (Notification)
// Ogni notifica appartiene a un singolo utente
User.hasMany(Notification, { foreignKey: 'utente_id', onDelete: 'CASCADE' });
Notification.belongsTo(User, { foreignKey: 'utente_id' });

// Un ordine (Order) è associato a un'asta (Auction)
// Un'asta può avere molti ordini associati, ma ogni ordine è collegato a una sola asta
Order.belongsTo(Auction, { foreignKey: 'auction_id', onDelete: 'CASCADE' });
Auction.hasMany(Order, { foreignKey: 'auction_id', onDelete: 'CASCADE' });

// Un ordine (Order) è associato a un prodotto (Product)
// Un prodotto può essere presente in molti ordini, ma ogni ordine si riferisce a un singolo prodotto
Order.belongsTo(Product, { foreignKey: 'prodotto_id', onDelete: 'CASCADE' });
Product.hasMany(Order, { foreignKey: 'prodotto_id', onDelete: 'CASCADE' });

// Un ordine (Order) è associato a un acquirente (User)
// Un utente può avere molti ordini in qualità di acquirente
Order.belongsTo(User, { foreignKey: 'acquirente_id', as: 'acquirente' });
User.hasMany(Order, { foreignKey: 'acquirente_id' });

// Un ordine (Order) è associato a un venditore (User)
// Un venditore (utente) può avere molti ordini per i prodotti che vende
Order.belongsTo(User, { foreignKey: 'venditore_id', as: 'venditore' });
User.hasMany(Order, { foreignKey: 'venditore_id', onDelete: 'CASCADE' });

// Un'asta (Auction) può generare molte notifiche (Notification)
// Ogni notifica è collegata a una singola asta
Auction.hasMany(Notification, { foreignKey: 'auction_id', onDelete: 'CASCADE' });
Notification.belongsTo(Auction, { foreignKey: 'auction_id', onDelete: 'CASCADE' });

module.exports = {
  sequelize,
  Auction,
  Bid,
  Product,
  User,
  Category,
  Notification,
  Order
};
