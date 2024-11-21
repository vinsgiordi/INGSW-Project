const { StatusCodes } = require('http-status-codes');
const User = require('../models/user');
const Product = require('../models/product');
const Category = require('../models/category');

// Funzione per recuperare i dati di un venditore
const getSellerDetails = async (req, res) => {
    try {
        const sellerId = req.params.id;

        // Recupera il venditore e includi i prodotti associati e la categoria
        const seller = await User.findByPk(sellerId, {
            attributes: ['id', 'nome', 'cognome', 'avatar', 'short_bio'],
            include: [{
                model: Product,
                attributes: ['id', 'nome', 'descrizione', 'prezzo_iniziale', 'immagine_principale', 'categoria_id'],
                include: [{
                    model: Category, // Include anche la tabella Category
                    attributes: ['nome'], // Ottieni il nome della categoria
                }]
            }]
        });

        if (!seller) {
            return res.status(StatusCodes.NOT_FOUND).json({ message: 'Venditore non trovato' });
        }

        // Restituisci i dati con i prodotti e le categorie associate
        return res.status(StatusCodes.OK).json({
            venditore: seller, // I prodotti e le categorie saranno inclusi qui sotto `venditore.Products`
        });
    } catch (error) {
        console.error('Errore nel recupero dei dettagli del venditore:', error);
        return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

module.exports = {
    getSellerDetails
};
