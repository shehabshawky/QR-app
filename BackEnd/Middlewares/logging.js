const Log = require('../Models/Log');

const logAdminAction = async (req, action) => {
    if (req.user && req.user.role === 'admin') {
        await Log.create({
            admin: req.user._id,
            adminName: req.user.name,
            action: action
        });
    }
};

module.exports = { logAdminAction }; 