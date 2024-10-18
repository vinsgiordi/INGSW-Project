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
    }
}, {
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: false,
    tableName: 'notifications'
});

module.exports = Notification;
