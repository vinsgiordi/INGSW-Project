const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Auction = sequelize.define('Auction', {
    prodotto_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    tipo: {
        type: DataTypes.STRING,
        validate: {
            isIn: [['tempo fisso', 'inglese', 'ribasso', 'silenziosa']]
        },
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
        type: DataTypes.ENUM('attiva', 'completata', 'fallita'),
        allowNull: false,
        defaultValue: 'attiva'
    },
    venditore_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    timer_decremento: {
        type: DataTypes.DECIMAL(5, 3),
        allowNull: true // Solo per aste al ribasso, può essere null
    },
}, {
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    tableName: 'auctions'
});

module.exports = Auction;
