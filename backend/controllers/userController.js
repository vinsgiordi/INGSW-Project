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

        // Verifica se l'email esiste già
        const existingUser = await User.findOne({ where: { email } });
        if (existingUser) {
            return res.status(StatusCodes.CONFLICT).json({ error: 'Email già registrata' });
        }

        // Cripta la password
        const hashedPassword = await bcrypt.hash(password, 10);

        const user = await User.create({
            nome,
            cognome,
            data_nascita,
            email,
            password: hashedPassword
        });

        // Genera il token JWT
        const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });

        res.status(StatusCodes.CREATED).json({
            token,
            user: {
                id: user.id,
                nome: user.nome,
                cognome: user.cognome,
                email: user.email,
            },
        });
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
                error: "Per favore inserisci sia l'email che la password!"
            });
        }

        // Trova l'utente tramite l'email
        const user = await User.findOne({ where: { email } });

        if (!user) {
            return res.status(StatusCodes.NOT_FOUND).json({
                error: "L'utente non esiste, controlla la tua email!"
            });
        }

        if (!user.password) {
            return res.status(StatusCodes.UNAUTHORIZED).json({
                error: "Hai effettuato la registrazione con un social network. Per favore, imposta una password per accedere."
            });
        }

        // Verifica la password
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(StatusCodes.UNAUTHORIZED).json({
                error: "Password non corretta!"
            });
        }

        // Genera il token JWT con l'ID dell'utente
        const accessToken = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });
        const refreshToken = jwt.sign({ id: user.id }, process.env.REFRESH_TOKEN_SECRET, { expiresIn: '7d' });
        return res.status(StatusCodes.OK).json({
            accessToken,
            refreshToken,
            user: {
                id: user.id,
                nome: user.nome,
                cognome: user.cognome,
                email: user.email,
            },
        });

    } catch (error) {
        return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Recupero dell'utente autenticato
const getUser = async (req, res) => {
    try {
        const user = await User.findByPk(req.user.id);
        if (!user) {
            return res.status(StatusCodes.NOT_FOUND).json({ error: 'Utente non trovato' });
        }
        res.json({
            id: user.id,
            nome: user.nome,
            cognome: user.cognome,
            email: user.email,
            data_nascita: user.data_nascita,
            short_bio: user.short_bio,
            sito_web: user.sito_web,
            social_links: user.social_links,
            posizione_geografica: user.posizione_geografica,
            indirizzo_di_spedizione: user.indirizzo_di_spedizione,
            indirizzo_di_fatturazione: user.indirizzo_di_fatturazione
        });
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Modifica dell'utente
const updateUser = async (req, res) => {
    const { nome, cognome, email, password, data_nascita, short_bio, indirizzo_di_spedizione, indirizzo_di_fatturazione, sito_web, social_links, posizione_geografica } = req.body;

    try {
        const user = await User.findByPk(req.user.id);

        if (!user) {
            return res.status(StatusCodes.NOT_FOUND).json({ error: 'Utente non trovato' });
        }

        user.nome = nome || user.nome;
        user.cognome = cognome || user.cognome;
        user.email = email || user.email;
        user.data_nascita = data_nascita || user.data_nascita;
        user.short_bio = short_bio || user.short_bio;
        user.indirizzo_di_spedizione = indirizzo_di_spedizione || user.indirizzo_di_spedizione;
        user.indirizzo_di_fatturazione = indirizzo_di_fatturazione || user.indirizzo_di_fatturazione;
        user.sito_web = sito_web || user.sito_web;
        user.social_links = social_links || user.social_links;
        user.posizione_geografica = posizione_geografica || user.posizione_geografica;

        // Se viene passata una nuova password, cripta la password prima di salvarla
        if (password) {
            const hashedPassword = await bcrypt.hash(password, 10);
            user.password = hashedPassword;
        }

        await user.save();
        res.status(StatusCodes.OK).json({
            message: "Profilo aggiornato con successo",
            user
        });
    } catch (error) {
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
};

// Funzione per resettare la password tramite email
const resetPassword = async (req, res) => {
    const { email, newPassword } = req.body;

    try {
        // Controlla se l'utente con l'email esiste
        const user = await User.findOne({ where: { email } });

        if (!user) {
            return res.status(StatusCodes.NOT_FOUND).json({
                error: "L'email fornita non corrisponde a nessun account!"
            });
        }

        // Cripta la nuova password
        const hashedPassword = await bcrypt.hash(newPassword, 10);

        // Aggiorna la password dell'utente
        user.password = hashedPassword;
        await user.save();

        return res.status(StatusCodes.OK).json({
            message: 'Password aggiornata con successo!'
        });
    } catch (error) {
        return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({ error: error.message });
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
    resetPassword,
    deleteUser
};
