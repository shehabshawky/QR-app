const mongoose = require('mongoose');
const express = require('express');
const jwt = require('jsonwebtoken');
require('dotenv').config({ path: './../config.env' });
const validator = require('validator');
const upload = require('../Middlewares/upload');
const fs = require('fs');
const User = require('../Models/User');
const { auth, role } = require('../Middlewares/auth');

// route -> /api/users
const router = express.Router();

router.get('/profile', auth, async (req, res) => {
    try{
        let user = null;
        if (req.user.role === 'admin'){
            user = await User.findById(req.user._id).select('name email icon -_id');
            if (user.icon){
                user.icon = `${req.protocol}://${req.hostname}:${process.env.port}/${user.icon}`;
            }
        }
        else if (req.user.role === 'client'){
            user = await User.findById(req.user._id).select('name email photo address phone_number -_id');
            if (user.photo){
                user.photo = `${req.protocol}://${req.hostname}:${process.env.port}/${user.photo}`;
            }
        }
        else{
            user = await User.findById(req.user._id).select('name email -_id');
        }
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.status(200).json(user);
    }catch(error){
        res.status(404).json(error.message);
    }
});
router.get('/admins', auth, role('super_admin'), async (req, res) => {
    try {
        var admins = await User.aggregate([
            { $match: { role: 'admin' } },
            {
                $lookup: {
                    from: 'products',
                    localField: '_id',
                    foreignField: 'admin',
                    as: 'products'
                }
            },
            {
                $unwind: {
                    path: '$products',
                    preserveNullAndEmptyArrays: true
                }
            },
            {
                $lookup: {
                    from: 'reports',
                    localField: 'products._id',
                    foreignField: 'product',
                    as: 'products.reports'
                }
            },
            {
                $group: {
                    _id: '$_id', // admin ID
                    name: { $first: '$name' }, // admin name
                    email: { $first: '$email' }, // admin email
                    icon: { $first: '$icon' }, // admin icon
                    productsCount: { $sum: { $cond: [ { $and: [{ $ifNull: ['$products._id', false] }, { $ne: ['$products._id', null] }] }, 1, 0 ] } }, // total number of products
                    QRCodesCount: { $sum: { $size: { $ifNull: ['$products.units', []] } } }, // total number of units across all products
                    scannedUnitsCount: { $sum: { $size: { $filter: { input: { $ifNull: ['$products.units', []] }, as: 'unit', cond: { $eq: ['$$unit.status', 'scanned'] }  } } } }, // total number of scanned units
                    counterfeitReportsCount: { $sum: { $size: { $filter: { input: { $ifNull: ['$products.reports', []] }, as: 'report', cond: { $eq: ['$$report.status', 'counterfeit'] } } } } } // total number of counterfeit reports
                }
            },
            {
                $project: {
                    _id: 0,
                    id: { $toString: '$_id' },
                    name: 1,
                    email: 1,
                    icon: {
                        $cond: {
                            if: { $gt: [{ $type: "$icon" }, "missing"] },
                            then: { $concat: [ req.protocol + "://", req.hostname + ":", { $toString: process.env.port }, "/", "$icon" ] },
                            else: null
                        }
                    },
                    productsCount: 1,
                    QRCodesCount: 1,
                    scannedUnitsCount: 1,
                    counterfeitReportsCount: 1
                }
            }
        ]);
        admins = req.query.name
            ? admins.filter(admin => admin.name.toLowerCase().includes(req.query.name.toLowerCase()))
            : admins;
        res.status(200).json(admins);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

router.post('/register', async (req, res) => {
    const { name, email, password, address, phone_number } = req.body;
    if (!name || !email || !password) {
        return res.status(400).json('Name, email and password are required');
    }
    if (!validator.isEmail(email)) {
        return res.status(400).json('Invalid email format');
    }
    try{
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json('Email is already taken');
        }
        if (password.length < 8) {
            return res.status(400).json('Password must be at least 8 characters long');
        }
        await User.create({ name, email, password, role: 'client', address, phone_number });
        res.status(201).json('Registered successfully');
    }catch(error){
        res.status(500).json(error.message);
    };
});
router.post('/create-admin-account', auth, role('super_admin'), async (req, res) => {
    const { name, email, password} = req.body;
    if (!name || !email || !password) {
        return res.status(400).json('Name, email and password are required');
    }
    if (!validator.isEmail(email)) {
        return res.status(400).json('Invalid email format');
    }
    try{
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json('Email is already taken');
        }
        if (password.length < 8) {
            return res.status(400).json('Password must be at least 8 characters long');
        }
        await User.create({ name, email, password, role: 'admin' });
        res.status(201).json('Admin account created successfully');
    }catch(error){
        res.status(500).json(error.message);
    };
});
router.post('/login', async (req, res) => {
    const { email, password } = req.body;
    if (!email || !password) {
        return res.status(400).json('email and password are required');
    }
    if (!validator.isEmail(email)) {
        return res.status(400).json('Invalid email format');
    }
    try {
        const user = await User.findOne({ email }).select('+password');
        if (!user || !(await user.comparePassword(password))) {
            return res.status(401).send('Invalid email or password');
        }
        const payload = {
            id: user._id,
            role: user.role
        };
        if (user.role === 'admin') {
            payload.name = user.name;
            if (user.icon)
                { payload.icon = `${req.protocol}://${req.hostname}:${process.env.port}/${user.icon}`; }
        } else if (user.role === 'client') {
            payload.name = user.name;
            if (user.photo)
                { payload.photo = `${req.protocol}://${req.hostname}:${process.env.port}/${user.photo}`; }
        }
        const token = jwt.sign(payload, process.env.token);
        res.status(200).json({ token });
    } catch (error) {
        res.status(400).json(error.message);
    }
});

router.patch('/change-password', auth, async (req, res) => {
    try{
        const { currentPassword, newPassword } = req.body;
        if (!currentPassword || !newPassword) {
            return res.status(400).json({ message: 'Current password and new password are required' });
        }
        const user = await User.findById(req.user._id);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        const isMatch = await bcrypt.compare(currentPassword, user.password);
        if (!isMatch) {
            return res.status(400).json({ message: 'Current password is incorrect' });
        }
        if (newPassword.length < 8) {
            return res.status(400).json('Password must be at least 8 characters long');
        }
        user.password = newPassword;
        await user.save();
        const userObj = user.toObject(); delete userObj.password;
        res.status(200).json(userObj);
    }catch(error){
        res.status(400).json(error.message);
    }
});
router.patch('/change-admin-icon', auth, role('admin'), upload.single("icon"), async (req, res) => {
    try{
        if (!req.file) {
            return res.status(400).json({ message: "icon is Required" }); 
        }
        const admin = await User.findById(req.user.id);
        if (!admin) {
            fs.unlinkSync(req.file.path);
            return res.status(404).json({ message: 'user not found' });
        }
        if (admin.icon) {
            try {
                fs.unlinkSync("./upload/" + admin.icon);
            } catch (err) {
                fs.unlinkSync(req.file.path);
                console.error('Failed to delete old icon:', err);
            }
        }
        admin.icon = req.file.filename;
        await admin.save();
        res.status(200).json({ message: 'Icon updated successfully' });
    }catch(error){
        if (req.file) {
            fs.unlinkSync(req.file.path);
        }
        res.status(500).json({ message: 'Failed to update icon', error: error.message });
    }
});
router.patch('/change-client-photo', auth, role('client'), upload.single("photo"), async (req, res) => {
    try{
        if (!req.file) {
            return res.status(400).json({ message: "photo is Required" }); 
        }
        const client = await User.findById(req.user.id);
        if (!client) {
            fs.unlinkSync(req.file.path);
            return res.status(404).json({ message: 'user not found' });
        }
        if (client.photo) {
            try {
                fs.unlinkSync("./upload/" + client.photo);
            } catch (err) {
                fs.unlinkSync(req.file.path);
                console.error('Failed to delete old photo:', err);
            }
        }
        client.photo = req.file.filename;
        await client.save();
        res.status(200).json({ message: 'Photo updated successfully' });
    }catch(error){
        if (req.file) {
            fs.unlinkSync(req.file.path);
        }
        res.status(500).json({ message: 'Failed to update photo', error: error.message });
    }
});

router.delete('/admin/:id', auth, role('super_admin'), async (req, res) => {
    try {
        const { id } = req.params;
        if (!mongoose.Types.ObjectId.isValid(id)) {
            return res.status(400).json({ message: 'Invalid user ID' });
        }
        const user = await User.findById(id);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        if (user.role !== 'admin') {
            return res.status(403).json({ message: 'This user is not an admin' });
        }
        if (user.icon){ 
            try{
                fs.unlinkSync("./upload/" + user.icon);
            } catch (err) {
                console.error('Failed to delete icon:', err);
            }
        }
        await User.findByIdAndDelete(id);
        res.status(200).json({ message: 'User deleted successfully', user });
    } catch (error) {
        res.status(400).send(error.message);
    }
});

module.exports = router;