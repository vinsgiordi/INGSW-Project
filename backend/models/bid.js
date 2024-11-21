const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Bid = sequelize.define('Bid', {
    prodotto_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    utente_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    importo: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: false
    },
    auction_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'auctions',
            key: 'id'
        }
    }
}, {
    timestamps: false,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    tableName: 'bids'
});

module.exports = Bid;
