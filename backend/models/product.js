const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Product = sequelize.define('Product', {
    nome: {
        type: DataTypes.STRING,
        allowNull: false
    },
    descrizione: {
        type: DataTypes.TEXT,
        allowNull: true
    },
    categoria_id: {
        type: DataTypes.INTEGER,
        references: {
            model: 'categories',
            key: 'id'
        },
        allowNull: true
    },
    prezzo_iniziale: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: false
    },
    immagine_principale: {
        type: DataTypes.STRING,
        allowNull: true
    },
    venditore_id: {
        type: DataTypes.INTEGER,
        references: {
            model: 'users', // Assicurati che sia il nome del modello corretto
            key: 'id'
        },
        allowNull: false
    }
}, {
    timestamps: false,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    tableName: 'products'
});

// Associazione con il venditore
Product.associate = (models) => {
    Product.belongsTo(models.User, { foreignKey: 'venditore_id', as: 'venditore' });
};

module.exports = Product;
