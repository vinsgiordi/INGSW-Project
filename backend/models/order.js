const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Order = sequelize.define('Order', {
    prodotto_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    acquirente_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    venditore_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    stato: {
        type: DataTypes.ENUM('in elaborazione', 'pagato', 'spedito', 'completato'),
        allowNull: false,
        defaultValue: 'in elaborazione'
    },
    indirizzo_spedizione: {
        type: DataTypes.TEXT,
        allowNull: false
    },
    metodo_pagamento: {
        type: DataTypes.STRING,
        allowNull: false
    },
    importo_totale: {
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
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    tableName: 'orders'
});

module.exports = Order;