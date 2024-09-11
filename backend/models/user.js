const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const User = sequelize.define('User', {
    nome: {
        type: DataTypes.STRING,
        allowNull: false
    },
    cognome: {
        type: DataTypes.STRING,
        allowNull: false
    },
    data_nascita: {
        type: DataTypes.DATE,
        allowNull: false
    },
    email: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true
    },
    password: {
        type: DataTypes.STRING,
        allowNull: false
    },
    short_bio: {
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
    avatar: {
        type: DataTypes.STRING,
        allowNull: true
    }
}, {
    timestamps: false,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    tableName: 'users'
});

module.exports = User;
