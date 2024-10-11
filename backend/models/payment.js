const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Payment = sequelize.define('Payment', {
    utente_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    numero_carta: {
        type: DataTypes.STRING,
        allowNull: false
    },
    nome_intestatario: {
        type: DataTypes.STRING,
        allowNull: false
    },
    data_scadenza: {
        type: DataTypes.DATE,
        allowNull: false
    },
}, {
    timestamps: false,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    tableName: 'payments'
});

module.exports = Payment;
