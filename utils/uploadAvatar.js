const fs = require('fs');
const path = require('path');
const sequelize = require('../config/db'); // Assumi che `db.js` sia il file di configurazione Sequelize
const User = require('../models/user'); // Modello Sequelize per la tabella `users`

const uploadAvatar = async () => {
  try {
    await sequelize.authenticate();
    console.log('Connessione al database riuscita.');

    const avatarPath = path.join(__dirname, '../files/images/user');
    const files = fs.readdirSync(avatarPath);

    for (const file of files) {
      const filePath = path.join(avatarPath, file);

      // Controlla solo i file con estensioni valide
      const validExtensions = ['.png', '.jpeg', '.jpg'];
      if (!validExtensions.includes(path.extname(file).toLowerCase())) {
        console.log(`Estensione non valida per il file: ${file}`);
        continue;
      }

      // Ottieni l'ID utente dal nome del file (ad esempio, "1.png" → 1)
      const userId = parseInt(file.split('.')[0], 10);
      if (isNaN(userId)) {
        console.log(`Nome file non valido per determinare l'ID dell'utente: ${file}`);
        continue;
      }

      // Trova l'utente corrispondente nel database
      const user = await User.findByPk(userId);
      if (user) {
        // Leggi il file immagine e codificalo in Base64
        const fileData = fs.readFileSync(filePath);
        const base64Image = fileData.toString('base64');

        // Aggiorna l'avatar dell'utente nel database
        user.avatar = base64Image;
        await user.save();

        console.log(`Avatar aggiornato per l'utente con ID: ${userId}`);
      } else {
        console.log(`Utente con ID: ${userId} non trovato nel database`);
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

uploadAvatar();
