const express = require('express');
const passport = require('passport');
const router = express.Router();

// Autenticazione con Facebook
router.get('/facebook', passport.authenticate('facebook', { scope: ['email'] }));
router.get('/facebook/callback', passport.authenticate('facebook', {
    session: false,
    failureRedirect: '/login'
}), (req, res) => {
    if (req.user && req.user.token) {
        const redirectUrl = `bidhub://auth/callback?token=${req.user.token}`;
        res.redirect(redirectUrl);
    } else {
        res.status(401).json({ error: 'Autenticazione con Facebook fallita.' });
    }
});

// Autenticazione con Google
router.get('/google', passport.authenticate('google', { scope: ['profile', 'email'] }));
router.get('/google/callback', passport.authenticate('google', {
    session: false,
    failureRedirect: '/login'
}), (req, res) => {
    if (req.user && req.user.token) {
        const redirectUrl = `bidhub://auth/callback?token=${req.user.token}`;
        res.redirect(redirectUrl);
    } else {
        res.status(401).json({ error: 'Autenticazione con Google fallita.' });
    }
});

// Autenticazione con GitHub
router.get('/github', passport.authenticate('github', { scope: ['user:email'] }));
router.get('/github/callback', passport.authenticate('github', {
    session: false,
    failureRedirect: '/login'
}), (req, res) => {
    if (req.user && req.user.token) {
        const redirectUrl = `bidhub://auth/callback?token=${req.user.token}`;
        res.redirect(redirectUrl);
    } else {
        res.status(401).json({ error: 'Autenticazione con GitHub fallita.' });
    }
});


// Autenticazione con LinkedIn
router.get('/linkedin', passport.authenticate('linkedin', { scope: ['openid', 'profile', 'email'] }));
router.get('/linkedin/callback', passport.authenticate('linkedin', {
    session: false,
    failureRedirect: '/login'
}), (req, res) => {
    if (req.user && req.user.token) {
        const redirectUrl = `bidhub://auth/callback?token=${req.user.token}`;
        res.redirect(redirectUrl);
    } else {
        res.status(401).json({ error: 'Autenticazione con LinkedIn fallita.' });
    }
});

module.exports = router;
