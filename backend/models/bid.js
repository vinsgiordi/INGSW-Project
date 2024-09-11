const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');
const User = require('./user');
const Product = require('./product');

const Bid = sequelize.define('Bid', {
    prodotto_id: {
        type: DataTypes.INTEGER,
        references: {
            model: Product,
            key: 'id'
        }
    },
    utente_id: {
        type: DataTypes.INTEGER,
        references: {
            model: User,
            key: 'id'
        }
    },
    importo: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: false
    }
}, {
    timestamps: false,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    tableName: 'bids'
});

// Associazioni
Bid.belongsTo(User, { foreignKey: 'utente_id' });
Bid.belongsTo(Product, { foreignKey: 'prodotto_id' });

module.exports = Bid;
