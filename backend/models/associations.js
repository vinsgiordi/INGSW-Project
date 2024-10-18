const Sequelize = require('sequelize');
const sequelize = require('../config/db');

// Importa i modelli
const Auction = require('./auction');
const Bid = require('./bid');
const Product = require('./product');
const User = require('./user');
const Category = require('./category');
const Notification = require('./notification');

// Definizione delle associazioni

// Un'asta (Auction) è associata a un prodotto (Product)
Auction.belongsTo(Product, { foreignKey: 'prodotto_id' });
Product.hasMany(Auction, { foreignKey: 'prodotto_id' });

// Un'asta (Auction) è associata a un venditore (User)
Auction.belongsTo(User, { foreignKey: 'venditore_id', as: 'venditore' });
User.hasMany(Auction, { foreignKey: 'venditore_id', onDelete: 'CASCADE' });

// Un'asta (Auction) può avere molte offerte (Bids)
Auction.hasMany(Bid, { foreignKey: 'auction_id', onDelete: 'CASCADE' });
Bid.belongsTo(Auction, { foreignKey: 'auction_id' });

// Un'offerta (Bid) è fatta da un utente (User)
Bid.belongsTo(User, { foreignKey: 'utente_id' });
User.hasMany(Bid, { foreignKey: 'utente_id', onDelete: 'CASCADE' });

// Un'offerta (Bid) è associata a un prodotto (Product)
Bid.belongsTo(Product, { foreignKey: 'prodotto_id' });
Product.hasMany(Bid, { foreignKey: 'prodotto_id' });

// Un prodotto (Product) appartiene a una categoria (Category)
Product.belongsTo(Category, { foreignKey: 'categoria_id' });
Category.hasMany(Product, { foreignKey: 'categoria_id' });

// Un prodotto (Product) ha un venditore (User) che lo ha messo in vendita
Product.belongsTo(User, { foreignKey: 'venditore_id', as: 'venditore' });
User.hasMany(Product, { foreignKey: 'venditore_id', onDelete: 'CASCADE' });

// Un utente (User) può avere molte notifiche (Notifications)
User.hasMany(Notification, { foreignKey: 'utente_id', onDelete: 'CASCADE' });
Notification.belongsTo(User, { foreignKey: 'utente_id' });

module.exports = {
  sequelize,
  Auction,
  Bid,
  Product,
  User,
  Category,
  Notification
};
