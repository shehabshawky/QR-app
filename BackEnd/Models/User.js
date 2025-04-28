const mongoose = require('mongoose');
const validator = require('validator');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
    name: {
        type: String,
        required: [true, "name is required"]
    },
    email: {
        type: String,
        unique: [true, "email already exists"],
        required: [true, "email is required"],
        lowercase: true,
        valide: [validator.isEmail, "not a valid email"]
    },
    password: {
        type: String,
        required: [true, "password is required"],
        minlength: [8, "Password must be at least 8 characters long"],
        select: false
    },
    role: {
        type: String,
        required: [true, "role is required"],
        enum: ['client', 'admin', 'super_admin']
    },
    // for admin
    icon: String,
    // for client
    photo: String,
    address: String,
    phone_number: String,
    scanned_units: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Unit' }]
});

userSchema.pre('save', async function (next) {
    if (this.role !== 'client') this.scanned_units = undefined;
    if (!this.isModified('password')) return next();
    this.password = await bcrypt.hash(this.password, 10);
    next();
});

userSchema.methods.comparePassword = async function (password) {
    return await bcrypt.compare(password, this.password);
};

const User = mongoose.model('User', userSchema);

module.exports = User;