const mongoose = require('mongoose');
const express = require('express');
const Product = require('../Models/Product');
const User = require('../Models/User');
const Log = require('../Models/Log');
const upload = require('../Middlewares/upload');
const QRCode = require('qrcode');
const fs = require('fs');
const { auth, role } = require('../Middlewares/auth');

function filterUnits(units, filters) {
    return units.filter(unit => {
        for (const key in filters) {
            const filterVal = filters[key]?.toLowerCase();
            const unitVal = unit[key]?.toLowerCase();
            if (filterVal && (!unitVal || !unitVal.includes(filterVal))) {
                return false;
            }
        }
        return true;
    });
}

// route -> /api/products
const router = express.Router();

router.get('/properties/:productID', auth, role('admin'), async (req, res) => {
    if (!mongoose.Types.ObjectId.isValid(req.params.productID)) {
        return res.status(400).json({ message: 'Invalid product ID' });
    }
    const product = await Product.findById(req.params.productID);
    if (!product) {
        return res.status(404).json({ message: 'Product not found' });
    }
    try {
        res.status(200).json(product.properties);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});
router.get('/categories', auth, role('admin'), async (req, res) => {
    try {
        const categories = Product.schema.path('category').enumValues;
        res.status(200).json(categories);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});
router.get('/', auth, role('admin'), async (req, res) => {
    try {
        var products = await Product.aggregate([
            { $match: { admin: req.user._id } },
            {
                $lookup: {
                    from: 'reports',
                    localField: '_id',
                    foreignField: 'product',
                    as: 'reports'
                }
            },
            {
                $project: {
                    name: 1,
                    image: {
                        $cond: {
                            if: { $gt: [{ $type: "$image" }, "missing"] },
                            then: { $concat: [ req.protocol + "://", req.hostname + ":", { $toString: process.env.port }, "/", "$image" ] },
                            else: null
                        }
                    },
                    price: { $toString: '$price' },
                    release_date: 1,
                    warranty_duration: 1,
                    properties: 1,
                    category: 1,
                    description: 1,
                    unitsCount: { $size: { $ifNull: ['$units', []] } }, // Total number of units
                    scannedUnitsCount: { // Total number of units with status = "scanned"
                        $size: {
                            $filter: {
                                input: { $ifNull: ['$units', []] },
                                as: 'unit',
                                cond: { $eq: ['$$unit.status', 'scanned'] }
                            }
                        }
                    },
                    QRErrorsCount: { // Total number of reports with status = "original"
                        $size: {
                            $filter: {
                                input: { $ifNull: ['$reports', []] },
                                as: 'report',
                                cond: { $eq: ['$$report.status', 'original'] }
                            }
                        }
                    }
                }
            }
        ]);
        products = req.query.name
            ? products.filter(product => product.name.toLowerCase().includes(req.query.name.toLowerCase()))
            : products;
        res.status(200).json(products);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});
router.get('/units/:productID', auth, role('admin'), async (req, res) => {
    const productID = req.params.productID;
    if (!mongoose.Types.ObjectId.isValid(productID)) {
        return res.status(400).json('Invalid product ID');
    }
    try {
        const products = await Product.aggregate([
            { $match: { _id: new mongoose.Types.ObjectId(productID), admin: req.user._id } },
            { $project: {
                    units: {
                        $map: {
                            input: { $ifNull: ['$units', []] }, as: 'unit', 
                            in: { $mergeObjects: [ "$$unit", { qr_code: {
                                $cond: {
                                    if: { $gt: [{ $type: "$$unit.qr_code" }, "missing"] },
                                    then: {  $concat: [ req.protocol + "://", req.hostname + ":", { $toString: process.env.port }, "/", "$$unit.qr_code" ] },
                                    else: null
                                }
                            }}]}
                        }
                    }
                }
            }
        ]);
        if (!products || products.length === 0) {
            return res.status(404).json({ message: 'Product not found' });
        }
        var units = products[0].units;
        units = filterUnits(units, {
            sku: req.query.sku,
            warranty_start_date: req.query.warranty_start_date,
            status: req.query.status
        });
        res.status(200).json(units);
    } catch (error) {
        res.status(500).json(error.message);
    }
});
router.get('/admins-products', auth, role('client'), async (req, res) => {
    try {
        const adminProducts = await Product.aggregate([
            {
                $lookup: {
                    from: 'users',
                    localField: 'admin',
                    foreignField: '_id',
                    as: 'adminDetails'
                }
            },
            {
                $unwind: '$adminDetails'
            },
            {
                $match: {
                    'adminDetails.role': 'admin'
                }
            },
            {
                $group: {
                    _id: '$admin',
                    adminName: { $first: '$adminDetails.name' },
                    products: {
                        $push: {
                            id: '$_id',
                            name: '$name'
                        }
                    }
                }
            },
            {
                $project: {
                    _id: 0,
                    adminId: { $toString: '$_id' },
                    adminName: 1,
                    products: 1
                }
            }
        ]);
        res.status(200).json(adminProducts);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});
router.get('/scanned-products', auth, role('client'), async (req, res) => {
    try {
        const user = await User.findById(req.user._id);
        const scannedUnitIds = user.scanned_units;
        const products = await Product.find({ 'units._id': { $in: scannedUnitIds } });
        var scannedProducts = products.flatMap(product => {
            return product.units
                .filter(unit => scannedUnitIds.includes(unit._id.toString()))
                .map(unit => {
                    const warrantyStartDate = new Date(unit.warranty_start_date);
                    const today = new Date();
                    const monthsUsed = (today.getFullYear() - warrantyStartDate.getFullYear()) * 12 + (today.getMonth() - warrantyStartDate.getMonth());
                    const durationLeft = product.warranty_duration - monthsUsed;
                    return {
                        id: product._id,
                        sku: unit.sku,
                        name: product.name,
                        image: `${req.protocol}://${req.hostname}:${process.env.port}/${product.image}`,
                        description: product.description,
                        duration_left: durationLeft > 0 ? durationLeft : 0,
                        warranty_duration: product.warranty_duration,
                        properties: unit.properties,
                        price: product.price.toString(),
                        category: product.category
                    };
                });
        });
        scannedProducts = req.query.name
            ? scannedProducts.filter(product => product.name.toLowerCase().includes(req.query.name.toLowerCase()))
            : scannedProducts;
        res.status(200).json(scannedProducts);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

router.post('/add-product', auth, role('admin'), upload.single("image"), async (req, res) => {
    if (!req.file) {
        return res.status(400).json("image is Required"); 
    }
    const { name, price, warranty_duration, description, properties, category, release_date } = req.body;
    if ( !name || !price || !warranty_duration || !description || !properties || !category || !release_date) {
        fs.unlinkSync(req.file.path);
        return res.status(400).json('name, price, warranty duration, description, properties, category, release_date are required');
    }
    let parsedProperties;
    try {
        parsedProperties = JSON.parse(properties);
    } catch {
        fs.unlinkSync(req.file.path);
        return res.status(400).json("Properties must be a valid JSON object");
    }
    const admin = await User.findById(req.user.id);
    if (!admin) {
        fs.unlinkSync(req.file.path);
        return res.status(404).json('admin not found');
    }
    try{
        const existingProduct = await Product.findOne({ name });
        if (existingProduct) {
            fs.unlinkSync(req.file.path);
            return res.status(400).json('Product already exists');
        }
        else {
            const product = new Product({
                image: req.file.filename, 
                name, 
                admin: admin._id, 
                price, 
                warranty_duration, 
                description, 
                properties: parsedProperties, 
                category, 
                release_date
            });
            await product.save();
            // Log the action
            await Log.create({
                admin: admin._id,
                adminName: admin.name,
                action: `added product ${name}`
            });
            res.status(201).json('Product Added successfully');
        }
    }catch(error){
        if (req.file) {
            fs.unlinkSync(req.file.path);
        }
        res.status(500).json(error.message);
    };
});

router.patch('/add-units', auth, role('admin'), async (req, res) => {
    if (!mongoose.Types.ObjectId.isValid(req.body.productID)) {
        return res.status(400).json({ message: 'Invalid product ID' });
    }
    const product = await Product.findById(req.body.productID);
    if (!product) {
        return res.status(404).json({ message: 'Product not found' });
    }
    const units = req.body.units;
    if (!Array.isArray(units) || units.length === 0) {
        return res.status(400).json({ message: 'Units must be a non-empty array' });
    }
    try {
        for (const unitData of units) {
            const { sku, properties } = unitData;
            if (!sku || !properties || typeof properties !== 'object' || Array.isArray(properties)) {
                throw new Error('sku and properties (as an object) are required');
            }
            if (typeof sku !== 'string' || sku.trim().length === 0) {
                throw new Error('sku must be a non-empty string');
            }
            const existingUnit = product.units.find(unit => unit.sku === sku);
            if (existingUnit) {
                throw new Error(`Unit with SKU ${sku} already exists`);
            }
            const qrFileName = `${product._id}_${sku}.png`;
            try {
                await QRCode.toFile(`upload/${qrFileName}`, JSON.stringify({ productID: product._id, sku }));
            } catch (error) {
                throw new Error('Failed to generate QR code');
            }
            const unit = {
                sku,
                properties,
                warranty_start_date: null,
                qr_code: qrFileName,
                status: "in stock"
            };
            product.units.push(unit);
        }
        await product.save();
        // Log the action
        const admin = await User.findById(req.user.id);
        await Log.create({
            admin: admin._id,
            adminName: admin.name,
            action: `added ${units.length} units of product ${product.name}`
        });
        res.status(201).json('Units added successfully');
    } catch (error) {
        res.status(400).json(error.message);
    }
});
router.patch('/scan', auth, role('client'), async (req, res) => {
    const { productID, sku } = req.body;
    if ( !productID || !sku ) {
        return res.status(400).json('Invalid QR Code! QR Code must have productID, SKU');
    }
    try {
        const product = await Product.findOne({ _id: productID });
        if (!product){
            return res.status(200).json("Product not in the DB");
        }
        const unit = product.units.find(unit => unit.sku === sku);
        if (!unit){
            return res.status(200).json("Counterfeit, Product doesn't have this unit in the DB");
        }
        const user = await User.findById(req.user.id);
        if (unit.status == "scanned" && !user.scanned_units.includes(unit._id)){
            return res.status(200).json("Counterfeit, another user scanned this unit before");
        }
        if (unit.status == "scanned" && user.scanned_units.includes(unit._id)){
            return res.status(200).json("This user already scanned this unit before");
        }
        unit.status = "scanned"; unit.warranty_start_date = new Date().toISOString().split('T')[0];
        user.scanned_units.push(unit._id);
        await product.save(); await user.save();
        const warrantyStartDate = new Date(unit.warranty_start_date);
        const today = new Date();
        const monthsUsed = (today.getFullYear() - warrantyStartDate.getFullYear()) * 12 + (today.getMonth() - warrantyStartDate.getMonth());
        const durationLeft = product.warranty_duration - monthsUsed;
        const Response = {
            id: product._id,
            sku: unit.sku,
            name: product.name,
            image: `${req.protocol}://${req.hostname}:${process.env.port}/${product.image}`,
            description: product.description,
            duration_left: durationLeft > 0 ? durationLeft : 0,
            warranty_duration: product.warranty_duration,
            properties: unit.properties,
            price: product.price.toString(),
            category: product.category
        }
        res.status(200).json(Response);
    }catch(error){
        res.status(500).json(error.message);
    };
});
router.patch('/:productId/deleteUnit/:unitId', auth, role('admin'), async (req, res) => {
    try {
        const { productId, unitId } = req.params;
        if (!mongoose.Types.ObjectId.isValid(productId)) {
            return res.status(400).json({ message: 'Invalid product ID' });
        }
        if (!mongoose.Types.ObjectId.isValid(unitId)) {
            return res.status(400).json({ message: 'Invalid unit ID' });
        }
        const product = await Product.findById(productId);
        if (!product) {
            return res.status(404).json({ message: 'Product not found' });
        }
        const unit = product.units.find(unit => unit._id.toString() === unitId);
        if (!unit) {
            return res.status(404).json({ message: 'Unit not found' });
        }
        if (unit.status === 'scanned') {
            return res.status(400).json({ message: 'Cannot delete a scanned unit' });
        }
        if (unit.qr_code) {
            try {
                fs.unlinkSync("./upload/" + unit.qr_code);
            } catch (err) {
                console.error('Failed to delete unit QR code:', err);
            }
        }
        product.units.pull({ _id: unitId });
        await product.save();
        // Log the action
        const admin = await User.findById(req.user.id);
        await Log.create({
            admin: admin._id,
            adminName: admin.name,
            action: `deleted unit ${unit.sku} of product ${product.name}`
        });
        res.status(200).json({ message: 'Unit deleted successfully', unit });
    } catch (error) {
        res.status(400).send(error.message);
    }
});

router.delete('/:id', auth, role('admin'), async (req, res) => {
    try {
        const { id } = req.params;
        if (!mongoose.Types.ObjectId.isValid(id)) {
            return res.status(400).json({ message: 'Invalid product ID' });
        }
        const product = await Product.findById(id);
        if (!product) {
            return res.status(404).json({ message: 'Product not found' });
        }
        if (product.units && product.units.some(unit => unit.status === 'scanned')) {
            return res.status(400).json({ message: 'Cannot delete this product because it has at least 1 scanned unit' });
        }
        if (product.image){ 
            try{
                fs.unlinkSync("./upload/" + product.image);
            } catch (err) {
                console.error('Failed to delete image:', err);
            }
        }
        if (product.units && product.units.length > 0) {
            for (const unit of product.units) {
                if (unit.qr_code) {
                    try {
                        fs.unlinkSync("./upload/" + unit.qr_code);
                    } catch (err) {
                        console.error('Failed to delete unit QR code:', err);
                    }
                }
            }
        }
        // Log the action
        const admin = await User.findById(req.user.id);
        await Log.create({
            admin: admin._id,
            adminName: admin.name,
            action: `deleted product ${product.name}`
        });
        await Product.findByIdAndDelete(id);
        res.status(200).json({ message: 'Product deleted successfully', product });
    } catch (error) {
        res.status(400).send(error.message);
    }
});

module.exports = router;