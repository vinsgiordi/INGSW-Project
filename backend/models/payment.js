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
    tableName: 'payments'
});

module.exports = Payment;
