const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Notification = sequelize.define('Notification', {
    utente_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'users',
            key: 'id'
        }
    },
    messaggio: {
        type: DataTypes.TEXT,
        allowNull: false
    },
    letto: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    },
    auction_id: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: 'auctions',
            key: 'id'
        }
    },
    bid_id: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: 'bids',
            key: 'id'
        }
    }
}, {
    timestamps: true,
    createdAt: 'created_at',
    tableName: 'notifications'
});

module.exports = Notification;
