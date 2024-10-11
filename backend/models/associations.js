const Sequelize = require('sequelize');
const sequelize = require('../config/db');

// Importa i modelli
const Auction = require('./auction');
const Bid = require('./bid');
const Product = require('./product');
const User = require('./user');
const Category = require('./category');

// Definizione delle associazioni

// Un'asta può avere molte offerte (Bids)
Auction.hasMany(Bid, { foreignKey: 'auction_id', onDelete: 'CASCADE' });
Bid.belongsTo(Auction, { foreignKey: 'auction_id' });

// Un'offerta è fatta da un utente su un prodotto
Bid.belongsTo(User, { foreignKey: 'utente_id' });
Bid.belongsTo(Product, { foreignKey: 'prodotto_id' });

// Un'asta è associata a un prodotto
Auction.belongsTo(Product, { foreignKey: 'prodotto_id' });

// Un prodotto ha un venditore (User) che lo ha messo in vendita
Product.belongsTo(User, { foreignKey: 'venditore_id', as: 'venditore' });
User.hasMany(Product, { foreignKey: 'venditore_id', onDelete: 'CASCADE' });

Auction.belongsTo(User, { foreignKey: 'venditore_id', as: 'venditore' });
User.hasMany(Auction, { foreignKey: 'venditore_id', onDelete: 'CASCADE' });

// Associazioni tra modelli
Auction.belongsTo(Product, { foreignKey: 'prodotto_id' });
Product.belongsTo(Category, { foreignKey: 'categoria_id' });

Product.belongsTo(Category, { foreignKey: 'categoria_id' });
Category.hasMany(Product, { foreignKey: 'categoria_id' });



module.exports = {
  sequelize,
  Auction,
  Bid,
  Product,
  User,
  Category
};
