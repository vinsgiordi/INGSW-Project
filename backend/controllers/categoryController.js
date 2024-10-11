const { StatusCodes } = require('http-status-codes');
const Category = require('../models/category');

// Recupera tutte le categorie
const getAllCategories = async (req, res) => {
    try {
        const categories = await Category.findAll();
        res.status(StatusCodes.OK).json(categories);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

module.exports = {
    getAllCategories
};
