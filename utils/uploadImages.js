const fs = require('fs');
const path = require('path');
const sequelize = require('../config/db');
const Product = require('../models/product');

const uploadImages = async () => {
  try {
    await sequelize.authenticate();
    console.log('Connessione al database riuscita.');

    const imagesPath = path.join(__dirname, '../files/images/product');
    const files = fs.readdirSync(imagesPath);

    for (const file of files) {
      const filePath = path.join(imagesPath, file);

      // Controlla solo i file con estensioni valide
      const validExtensions = ['.jpg', '.jpeg'];
      if (!validExtensions.includes(path.extname(file).toLowerCase())) {
        console.log(`Estensione non valida per il file: ${file}`);
        continue;
      }

      const productId = parseInt(file.split('.')[0], 10);
      if (isNaN(productId)) {
        console.log(`Nome file non valido per determinare l'ID prodotto: ${file}`);
        continue;
      }

      const product = await Product.findByPk(productId);

      if (product) {
        const fileData = fs.readFileSync(filePath);
        const base64Image = fileData.toString('base64');
        product.immagine_principale = base64Image;
        await product.save();
        console.log(`Immagine aggiornata per il prodotto con ID: ${productId}`);
      } else {
        console.log(`Prodotto con ID: ${productId} non trovato nel database`);
      }
    }

    console.log('Caricamento completato.');
  } catch (error) {
    console.error('Errore durante il caricamento delle immagini:', error);
  } finally {
    await sequelize.close();
    console.log('Connessione al database chiusa.');
  }
};

uploadImages();
