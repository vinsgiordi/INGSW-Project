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
        if (!email || !password) {
            return res.status(StatusCodes.BAD_REQUEST).json({
                error: "Per favore inserisci email e password!",
            });
        }

        const user = await User.findOne({ where: { email } });

        if (user) {
            const isMatch = await bcrypt.compare(password, user.password);
            if (isMatch) {
                const token = jwt.sign({ id: user.id }, 'your_jwt_secret', { expiresIn: '1h' });
                return res.status(StatusCodes.OK).json({
                    token,
                    user,
                });
            } else {
                return res.status(StatusCodes.UNAUTHORIZED).json({
                    error: "Password non corretta!",
                });
            }
        } else {
            return res.status(StatusCodes.BAD_REQUEST).json({
                error: "L'utente non esiste, controlla la tua email!",
            });
        }
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
    const { nome, cognome, email, short_bio, sito_web, social_links } = req.body;

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
        user.short_bio = short_bio || user.short_bio;
        user.sito_web = sito_web || user.sito_web;
        user.social_links = social_links || user.social_links;

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
