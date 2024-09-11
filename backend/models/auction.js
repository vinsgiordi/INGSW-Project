const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Auction = sequelize.define('Auction', {
    prodotto_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    tipo: {
        type: DataTypes.STRING,
        allowNull: false
    },
    data_scadenza: {
        type: DataTypes.DATE,
        allowNull: false
    },
    prezzo_minimo: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: true
    },
    incremento_rialzo: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: true
    },
    decremento_prezzo: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: true
    },
    prezzo_iniziale: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: false
    },
    stato: {
        type: DataTypes.STRING,
        allowNull: false
    },
    venditore_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    }
}, {
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    tableName: 'auctions'
});

module.exports = Auction;