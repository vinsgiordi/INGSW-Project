const { Op } = require('sequelize');
const Auction = require('../models/auction');
const Product = require('../models/product');
const User = require('../models/user');
const Bid = require('../models/bid');
const { Sequelize } = require('sequelize');

const searchAuctions = async (req, res) => {
  try {
    const { query, categoryId } = req.query;

    // Creiamo le condizioni di ricerca basate sulla categoria e query
    const productConditions = {};

    // Se viene specificata una categoria, aggiungiamo il filtro
    if (categoryId) {
      productConditions.categoria_id = parseInt(categoryId, 10);
    }

    // Se viene specificata una query, applichiamo il filtro sul nome del prodotto
    if (query) {
      const normalizedQuery = query.toLowerCase(); // Convertiamo tutto in lowercase per la corrispondenza case-insensitive
      productConditions[Op.or] = [
        Sequelize.where(Sequelize.fn('LOWER', Sequelize.col('Product.nome')), {
          [Op.like]: `%${normalizedQuery}%`
        })
      ];
    }


    // Creiamo la condizione finale di ricerca per Auction
    const searchConditions = {
      include: [
        {
          model: Product,
          attributes: ['id', 'nome', 'descrizione', 'immagine_principale', 'prezzo_iniziale', 'categoria_id', 'venditore_id'],
          where: productConditions
        },
        {
          model: User,
          as: 'venditore',
          attributes: ['id', 'nome', 'cognome']
        },
        {
          model: Bid,
          attributes: ['id', 'importo', 'utente_id']
        }
      ]
    };

    // Eseguiamo la ricerca
    const auctions = await Auction.findAll(searchConditions);

    if (!auctions || auctions.length === 0) {
      return res.status(404).json({ message: 'Nessuna asta trovata' });
    }

    res.status(200).json(auctions);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: error.message });
  }
};

module.exports = {
  searchAuctions
};
