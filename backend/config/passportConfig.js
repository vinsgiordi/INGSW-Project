const passport = require('passport');
const FacebookStrategy = require('passport-facebook').Strategy;
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const GitHubStrategy = require('passport-github2').Strategy;
const LinkedInStrategy = require('passport-linkedin-oauth2').Strategy;
const jwt = require('jsonwebtoken');
const User = require('../models/user');

// Strategia per Facebook
passport.use(new FacebookStrategy({
    clientID: process.env.FACEBOOK_CLIENT_ID,
    clientSecret: process.env.FACEBOOK_CLIENT_SECRET,
    callbackURL: process.env.FACEBOOK_CALLBACK_URL,
    profileFields: ['id', 'emails', 'name']
}, async (accessToken, refreshToken, profile, done) => {
    try {
        const { id, emails, name } = profile;
        let email = emails && emails.length ? emails[0].value : null;

        if (!email) {
            return done(new Error('Email non disponibile su Facebook'));
        }

        // Verifica se esiste un utente con la stessa email
        let existingUser = await User.findOne({ where: { email: email } });
        if (existingUser) {
            // Se esiste un utente con questa email, invia un errore
            return done(null, false, { message: 'Email già utilizzata con un altro account social.' });
        }

        let user = await User.create({
            nome: name.givenName,
            cognome: name.familyName,
            email: email,
            social_id: id,
            social_provider: 'facebook'
        });

        const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });
        return done(null, { token });
    } catch (error) {
        if (error.name === 'SequelizeUniqueConstraintError') {
            return done(null, false, { message: 'Email già utilizzata. Per favore, usa un altro metodo di accesso.' });
        } else {
            return done(error, false);
        }
    }
}));

// Strategia per Google
passport.use(new GoogleStrategy({
    clientID: process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    callbackURL: process.env.GOOGLE_CALLBACK_URL
}, async (accessToken, refreshToken, profile, done) => {
    try {
        const { id, emails, name } = profile;
        let email = emails && emails.length ? emails[0].value : null;

        if (!email) {
            return done(new Error('Email non disponibile su Google'));
        }

        // Verifica se esiste un utente con la stessa email
        let existingUser = await User.findOne({ where: { email: email } });
        if (existingUser) {
            // Se esiste un utente con questa email, invia un errore
            return done(null, false, { message: 'Email già utilizzata con un altro account social.' });
        }

        let user = await User.create({
            nome: name.givenName,
            cognome: name.familyName,
            email: email,
            social_id: id,
            social_provider: 'google'
        });

        const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });
        return done(null, { token });
    } catch (error) {
        if (error.name === 'SequelizeUniqueConstraintError') {
            return done(null, false, { message: 'Email già utilizzata. Per favore, usa un altro metodo di accesso.' });
        } else {
            return done(error, false);
        }
    }
}));

// Strategia per GitHub
passport.use(new GitHubStrategy({
    clientID: process.env.GITHUB_CLIENT_ID,
    clientSecret: process.env.GITHUB_CLIENT_SECRET,
    callbackURL: process.env.GITHUB_CALLBACK_URL,
    scope: ['user:email']
}, async (accessToken, refreshToken, profile, done) => {
    try {
        const { id, emails, username } = profile;
        let email = emails && emails.length ? emails[0].value : null;

        if (!email) {
            return done(new Error('Email non disponibile su GitHub'));
        }

        // Verifica se esiste un utente con la stessa email
        let existingUser = await User.findOne({ where: { email: email } });
        if (existingUser) {
            // Se esiste un utente con questa email, invia un errore
            return done(null, false, { message: 'Email già utilizzata con un altro account social.' });
        }

        let user = await User.create({
            nome: username,
            cognome: username,
            email: email,
            social_id: id,
            social_provider: 'github'
        });

        const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });
        return done(null, { token });
    } catch (error) {
        if (error.name === 'SequelizeUniqueConstraintError') {
            return done(null, false, { message: 'Email già utilizzata. Per favore, usa un altro metodo di accesso.' });
        } else {
            return done(error, false);
        }
    }
}));

// Strategia per LinkedIn
passport.use(new LinkedInStrategy({
    clientID: process.env.LINKEDIN_CLIENT_ID,
    clientSecret: process.env.LINKEDIN_CLIENT_SECRET,
    callbackURL: process.env.LINKEDIN_CALLBACK_URL,
    scope: ['openid', 'profile', 'email']
}, async (accessToken, refreshToken, profile, done) => {
    try {
        const { id, emails, displayName } = profile;

        let email = profile._json.email;

        if (!email) {
            return done(new Error('Email non disponibile su LinkedIn'));
        }

        let user = await User.findOne({ where: { social_id: id, social_provider: 'linkedin' } });

        if (!user) {
            user = await User.create({
                nome: displayName.givenName || displayName,
                cognome: displayName.familyName || '',
                email: email,
                social_id: id,
                social_provider: 'linkedin'
            });
        }

        const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });
        return done(null, { token });
    } catch (error) {
        return done(error, false);
    }
}));


module.exports = passport;
