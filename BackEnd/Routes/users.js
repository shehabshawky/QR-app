const mongoose = require('mongoose');
const express = require("express");
const jwt = require('jsonwebtoken');
require('dotenv').config({ path: './../config.env' });
const validator = require('validator');
const upload = require('../Middlewares/upload');
const fs = require("fs");
const User = require('../Models/User');
const { auth, role } = require('../Middlewares/auth');

// route -> /api/users
const router = express.Router();

// gets super admin profile ( name, email )
router.get('/super_admin_profile', auth, role('super_admin'), async (req, res) => {
    try{
        const user = await User.findById(req.user._id).select('name email -_id');
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.status(200).json(user);
    }catch(error){
        res.status(404).json(error.message);
    }
});
// gets all the admins ( name, email, icon, productsCount, QRCodesCount )
router.get('/admins', auth, role('super_admin'), async (req, res) => {
    try{
        const admins = await User.aggregate([
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
                    from: 'units',
                    localField: 'products._id',
                    foreignField: 'product',
                    as: 'units'
                }
            },
            {
                $group: {
                    _id: '$_id', // admin ID
                    name: { $first: '$name' }, // admin name
                    email: { $first: '$email' }, // admin email
                    icon: { $first: '$icon' }, // admin icon
                    productsCount: { $sum: { $cond: [{ $ifNull: ['$products', false] }, 1, 0] } }, // total number of products
                    QRCodesCount: { $sum: { $size: { $ifNull: ['$units', []] } } } // total number of units across all products
                }
            },
            {
                $project: {
                    _id: 0,
                    id: { $toString: '$_id' },
                    name: 1,
                    email: 1,
                    icon: 1,
                    productsCount: 1,
                    QRCodesCount: 1
                }
            }
        ]);
        for (const admin of admins) {
            if (admin.icon) {
                admin.icon = `${req.protocol}://${req.hostname}:${process.env.port}/${admin.icon}`;
            } else {
                admin.icon = null;
            }
        }
        res.status(200).json(admins);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// creates client acccount
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
// creates admin account
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
// login for all users
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
        const token = jwt.sign({ id: user._id, role: user.role }, process.env.token);
        res.status(200).json({ token });
    } catch (error) {
        res.status(400).json(error.message);
    }
});

// TMP api for changing password
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
// updates admin icon
router.patch('/change-admin-icon', auth, role('admin'), upload.single("icon"), async (req, res) => {
    try{
        if (!req.file) {
            return res.status(400).json({msg: "icon is Required"}); 
        }
        const admin = await User.findById(req.user.id);
        if (!admin) {
            return res.status(404).json({ message: 'user not found' });
        }
        if (admin.role !== 'admin'){
            return res.status(403).json({ message: 'This user is not an admin' });
        }
        if (admin.icon) {
            try {
                fs.unlinkSync("./upload/" + admin.icon);
            } catch (err) {
                console.error('Failed to delete old icon:', err);
            }
        }
        admin.icon = req.file.filename;
        await admin.save();
        res.status(200).json({ message: 'Icon updated successfully' });
    }catch(error){
        res.status(500).json({ message: 'Failed to update icon', error: error.message });
    }
});

// deletes admin
router.delete('/admin/:id', auth, role('super_admin'), async (req, res) => {
    try {
        if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
            return res.status(400).json({ message: 'Invalid user ID' });
        }
        const user = await User.findByIdAndDelete(req.params.id);
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
        res.status(200).json({ message: 'User deleted successfully', user });
    } catch (error) {
        res.status(400).send(error.message);
    }
});

module.exports =  router;