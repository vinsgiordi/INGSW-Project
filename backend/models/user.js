const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const User = sequelize.define('User', {
    nome: {
        type: DataTypes.STRING,
        allowNull: true
    },
    cognome: {
        type: DataTypes.STRING,
        allowNull: true
    },
    email: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true
    },
    password: {
        type: DataTypes.STRING,
        allowNull: true
    },
    data_nascita: {
        type: DataTypes.DATE,
        allowNull: true
    },
    short_bio: {
        type: DataTypes.TEXT,
        allowNull: true
    },
    indirizzo: {
        type: DataTypes.TEXT,
        allowNull: true
    },
    sito_web: {
        type: DataTypes.STRING,
        allowNull: true
    },
    social_links: {
        type: DataTypes.JSONB,
        allowNull: true
    },
    posizione_geografica: {
        type: DataTypes.TEXT,
        allowNull: true
    },
    social_id: {
        type: DataTypes.STRING,
        allowNull: true
    },
    social_provider: {
        type: DataTypes.STRING,
        allowNull: true
    }
}, {
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    tableName: 'users'
});

module.exports = User;
