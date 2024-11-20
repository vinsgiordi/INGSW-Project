# Usa un'immagine Node.js di base
FROM node:14

# Crea una directory di lavoro
WORKDIR /app

# Copia i file package.json e package-lock.json
COPY package*.json ./

# Installa le dipendenze
RUN npm install

# Copia tutto il contenuto della directory nel container
COPY . .

# Esponi la porta che il server utilizza
EXPOSE 3000

# Avvia l'applicazione
CMD ["npm", "start"]
