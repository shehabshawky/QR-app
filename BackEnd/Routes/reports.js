const mongoose = require('mongoose');
const express = require('express');
const Report = require('../Models/Report');
const Product = require('../Models/Product');
const User = require('../Models/User');
const upload = require('../Middlewares/upload');
const fs = require('fs');
const { auth, role } = require('../Middlewares/auth');

// route -> /api/reports
const router = express.Router();

router.get('/counterfeit-qrscanerrors-per-product', auth, role('admin'), async (req, res) => {
    try {
        var reports = await Report.aggregate([
            {
                $lookup: {
                    from: 'products',
                    localField: 'product',
                    foreignField: '_id',
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
                $match: {
                    'products.admin': req.user._id
                }
            },
            {
                $group: {
                    _id: '$product',
                    productName: { $first: '$products.name' },
                    image: { $first: '$products.image' },
                    counterfeitReportsCount: { $sum: { $cond: [{ $eq: ['$status', 'counterfeit'] }, 1, 0] } },
                    QRScanErrorsCount: { $sum: { $cond: [{ $eq: ['$status', 'original'] }, 1, 0] } } }
            },
            {
                $project: {
                    _id: 0,
                    productName: 1,
                    image: {
                        $cond: {
                            if: { $gt: [{ $type: "$image" }, "missing"] },
                            then: { $concat: [ req.protocol + "://", req.hostname + ":", { $toString: process.env.port }, "/", "$image" ] },
                            else: null
                        }
                    },
                    counterfeitReportsCount: 1,
                    QRScanErrorsCount: 1
                }
            }
        ]);
        reports = req.query.name
            ? reports.filter(report => report.productName.toLowerCase().includes(req.query.name.toLowerCase()))
            : reports;
        res.status(200).json(reports);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});
router.get('/admin-reports', auth, role('admin'), async (req, res) => {
    try {
        var reports = await Report.aggregate([
            {
                $lookup: {
                    from: 'products',
                    localField: 'product',
                    foreignField: '_id',
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
                $match: {
                    'products.admin': req.user._id
                }
            },
            {
                $lookup: {
                    from: 'users',
                    localField: 'client',
                    foreignField: '_id',
                    as: 'clients'
                }
            },
            {
                $unwind: {
                    path: '$clients',
                    preserveNullAndEmptyArrays: true
                }
            },
            {
                $project: {
                    _id: 0,
                    sku: 1,
                    productName: '$products.name',
                    status: 1,
                    location: '$clients.address'
                }
            }
        ]);
        reports = req.query.name
            ? reports.filter(report => report.productName.toLowerCase().includes(req.query.name.toLowerCase()))
            : reports;
        res.status(200).json(reports);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});
router.get('/client-reports', auth, role('client'), async (req, res) => {
    try {
        var reports = await Report.aggregate([
            { $match: { client: req.user._id } },
            {
                $lookup: {
                    from: 'products',
                    localField: 'product',
                    foreignField: '_id',
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
                $project: {
                    _id: 0,
                    sku: 1,
                    productName: '$products.name',
                    image: {
                        $cond: {
                            if: { $gt: [{ $type: "$image" }, "missing"] },
                            then: { $concat: [ req.protocol + "://", req.hostname + ":", { $toString: process.env.port }, "/", "$image" ] },
                            else: null
                        }
                    },
                    status: 1
                }
            }
        ]);
        reports = req.query.name
            ? reports.filter(report => report.productName.toLowerCase().includes(req.query.name.toLowerCase()))
            : reports;
        res.status(200).json(reports);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

router.post('/', auth, role('client'), upload.single("image"), async (req, res) => {
    if (!req.file) {
        return res.status(400).json("Image is Required"); 
    }
    const { productID, sku } = req.body;
    if ( !productID || !sku ) {
        fs.unlinkSync(req.file.path);
        return res.status(400).json('Product ID and SKU are required');
    }
    if (!mongoose.Types.ObjectId.isValid(productID)) {
        fs.unlinkSync(req.file.path);
        return res.status(400).json('Invalid product ID');
    }
    try{
        const product = await Product.findById(productID);
        if (!product) {
            fs.unlinkSync(req.file.path);
            return res.status(400).json('Product not fount');
        }
        const user = await User.findById(req.user.id);
        if (!user) {
            fs.unlinkSync(req.file.path);
            return res.status(404).json('Client not found');
        }
        const report = new Report({
            product: product._id,
            client: user._id,  
            image: req.file.filename, 
            sku,
            date: new Date().toISOString().split('T')[0],
        });
        const unit = product.units.find(unit => unit.sku === sku);
        if (!unit){
            report.status = "counterfeit";
            await report.save();
            return res.status(201).json("Counterfeit, Product doesn't have this unit in the DB");
        }
        else if (unit.status == "scanned" && !user.scanned_units.includes(unit._id)){
            report.status = "counterfeit";
            await report.save();
            return res.status(201).json("Counterfeit, another user scanned this unit before");
        }
        else if (unit.status == "scanned" && user.scanned_units.includes(unit._id)){
            report.status = "original";
            await report.save();
            return res.status(201).json("This user already scanned this unit before");
        }
        else{
            unit.status = "scanned"; unit.warranty_start_date = new Date().toISOString().split('T')[0];
            user.scanned_units.push(unit._id);
            report.status = "original";
            await product.save(); await user.save(); await report.save();
            const warrantyStartDate = new Date(unit.warranty_start_date);
            const today = new Date();
            const monthsUsed = (today.getFullYear() - warrantyStartDate.getFullYear()) * 12 + (today.getMonth() - warrantyStartDate.getMonth());
            const durationLeft = product.warranty_duration - monthsUsed;
            const response = {
                message: "QR scanning Error, Original product",
                product: {
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
            }
            res.status(201).json(response);    
        }
    }catch(error){
        if (req.file) {
            fs.unlinkSync(req.file.path);
        }
        res.status(500).json({ message: error.message });
    };
});

module.exports = router;
