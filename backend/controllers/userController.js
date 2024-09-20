const { StatusCodes } = require('http-status-codes');

const User = require('../models/user');

const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

// Creazione nuovo utente
const userRegister = async (req, res) => {
    const { nome, cognome, data_nascita, email, password } = req.body;

    try {
        if (!nome || !cognome || !data_nascita || !email || !password) {
            return res.status(StatusCodes.BAD_REQUEST).json({
                error: "Per favore inserisci tutte le informazioni richieste!",
            });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const user = await User.create({
            nome,
            cognome,
            data_nascita,
            email,
            password: hashedPassword
        });
        res.status(StatusCodes.CREATED).json(user);
    } catch (error) {
        return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Login dell'utente
const userLogin = async (req, res) => {
    const { email, password } = req.body;
    try {
        if (!email) {
            return res.status(StatusCodes.BAD_REQUEST).json({
                error: "Per favore inserisci l'email!"
            });
        }

        // Trova l'utente tramite l'email
        const user = await User.findOne({ where: { email } });

        // Se l'utente non esiste
        if (!user) {
            return res.status(StatusCodes.NOT_FOUND).json({
                error: "L'utente non esiste, controlla la tua email!"
            });
        }

        // Se l'utente è stato registrato tramite social network e non ha una password
        if (!user.password) {
            return res.status(StatusCodes.UNAUTHORIZED).json({
                error: "Hai effettuato la registrazione con un social network. Per favore, imposta una password per accedere."
            });
        }

        // Se l'utente ha una password, verifica che la password inserita sia corretta
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(StatusCodes.UNAUTHORIZED).json({
                error: "Password non corretta!"
            });
        }

        // Genera il token JWT
        const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });
        return res.status(StatusCodes.OK).json({
            token,
            user,
        });

    } catch (error) {
        return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};


// Recupero dell'utente
const getUser = async (req, res) => {
    try {
        const user = await User.findByPk(req.params.id);
        if (!user) {
            return res.status(StatusCodes.NOT_FOUND).json({ error: 'User not found' });
        }
        res.json(user);
    } catch (error) {
        res.status(StatusCodes.BAD_REQUEST).json({ error: error.message });
    }
};

// Modifica dell'utente
const updateUser = async (req, res) => {
    const { nome, cognome, email, password, data_nascita, short_bio, indirizzo, sito_web, social_links, posizione_geografica } = req.body;

    try {
        // Usa l'ID dell'utente dal token JWT, non dall'URL o dal body
        const user = await User.findByPk(req.user.id);

        if (!user) {
            return res.status(StatusCodes.NOT_FOUND).json({ error: 'Utente non trovato' });
        }

        // Permetti solo la modifica del profilo dell'utente autenticato
        user.nome = nome || user.nome;
        user.cognome = cognome || user.cognome;
        user.email = email || user.email;
        user.password = password || user.password;
        user.data_nascita = data_nascita || user.data_nascita;
        user.short_bio = short_bio || user.short_bio;
        user.indirizzo = indirizzo || user.indirizzo;
        user.sito_web = sito_web || user.sito_web;
        user.social_links = social_links || user.social_links;
        user.posizione_geografica = posizione_geografica || user.posizione_geografica

        // Se viene passata una nuova password, la cripta prima di salvarla
        if (password) {
            const hashedPassword = await bcrypt.hash(password, 10);
            user.password = hashedPassword;
        }

        await user.save();
        res.status(StatusCodes.OK).json(user);
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};


// Cancellazione dell'utente
const deleteUser = async (req, res) => {
    try {
        // Usa l'ID dell'utente dal token JWT
        const user = await User.findByPk(req.user.id);

        if (!user) {
            return res.status(StatusCodes.NOT_FOUND).json({ error: 'Utente non trovato' });
        }

        await user.destroy();
        res.status(StatusCodes.OK).json({ message: 'Utente eliminato con successo' });
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

module.exports = {
    userRegister,
    userLogin,
    getUser,
    updateUser,
    deleteUser
};
