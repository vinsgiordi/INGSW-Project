const jwt = require('jsonwebtoken');
const { StatusCodes } = require('http-status-codes');

const authMiddleware = (req, res, next) => {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
        return res.status(StatusCodes.UNAUTHORIZED).json({ error: 'Accesso non autorizzato, token mancante' });
    }

    try {
        // Verifica il token e decodifica l'ID dell'utente
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded; // Salva il payload del token nella richiesta
        next(); // Passa al prossimo middleware o controller
    } catch (error) {
        return res.status(StatusCodes.UNAUTHORIZED).json({ error: 'Token non valido' });
    }
};

module.exports = authMiddleware;