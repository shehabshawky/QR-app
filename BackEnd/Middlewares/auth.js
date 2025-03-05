const jwt = require('jsonwebtoken');
const User = require('../Models/User');
require('dotenv').config({ path: './../config.env' });

async function auth(req, res, next) {
    try {
        const authHeader = req.header('Authorization');
        if (!authHeader) {
            return res.status(400).send('Authorization header missing');
        }
        const token = req.header('Authorization').replace('Bearer ', '');
        if (!token) {
            return res.status(401).send('Access denied. No token provided.');
        }
        const decodedToken = jwt.verify(token, process.env.token);
        req.user = await User.findById(decodedToken.id).select('-password');
        next();
    } catch (ex) {
        return res.status(400).send('Invalid token.');
    }
}

const role = (role)=> {
    return (req, res, next) => {
        if (req.user.role !== role){
            return res.status(403).send('No permission to do this action!');
        }
        next();
    }
};

module.exports = { auth, role };