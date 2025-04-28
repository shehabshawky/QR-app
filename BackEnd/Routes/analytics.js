const express = require('express');
const mongoose = require('mongoose');
const User = require('../Models/User');
const Product = require('../Models/Product');
const Report = require('../Models/Report');
const Log = require('../Models/Log');
const { auth, role } = require('../Middlewares/auth');

// route -> /api/analytics
const router = express.Router();

// Utility functions
const validateTimeFrame = (startDate, endDate) => {
    if ((startDate && isNaN(startDate.getTime())) || (endDate && isNaN(endDate.getTime()))) {
        throw new Error('Invalid date format. Use ISO format (YYYY-MM-DD)');
    }
    
    if (startDate && endDate && startDate > endDate) {
        throw new Error('Start date must be before or equal to end date');
    }
};
const validateInterval = (interval) => {
    const validIntervals = ['daily', 'weekly', 'monthly', 'yearly'];
    if (!validIntervals.includes(interval)) {
        throw new Error('Invalid interval. Must be one of: daily, weekly, monthly, yearly');
    }
};
const getDateGrouping = (interval, dateField = '$dateField') => {
    switch (interval) {
        case 'daily':
            return {
                year: { $year: dateField },
                month: { $month: dateField },
                day: { $dayOfMonth: dateField }
            };
        case 'weekly':
            return {
                year: { $year: dateField },
                week: { $week: dateField }
            };
        case 'monthly':
            return {
                year: { $year: dateField },
                month: { $month: dateField }
            };
        case 'yearly':
            return {
                year: { $year: dateField }
            };
        default:
            throw new Error('Invalid interval. Must be one of: daily, weekly, monthly, yearly');
    }
};
const formatPeriod = (interval) => ({
    $cond: {
        if: { $eq: [interval, 'daily'] },
        then: {
            $concat: [
                { $toString: '$_id.year' },
                '/',
                { $toString: { $cond: [{ $lte: ['$_id.month', 9] }, { $concat: ['0', { $toString: '$_id.month' }] }, '$_id.month'] } },
                '/',
                { $toString: { $cond: [{ $lte: ['$_id.day', 9] }, { $concat: ['0', { $toString: '$_id.day' }] }, '$_id.day'] } }
            ]
        },
        else: {
            $cond: {
                if: { $eq: [interval, 'weekly'] },
                then: {
                    $concat: [
                        { $toString: '$_id.year' },
                        '/W',
                        { $toString: { $cond: [{ $lte: ['$_id.week', 9] }, { $concat: ['0', { $toString: '$_id.week' }] }, '$_id.week'] } }
                    ]
                },
                else: {
                    $cond: {
                        if: { $eq: [interval, 'monthly'] },
                        then: {
                            $concat: [
                                { $toString: '$_id.year' },
                                '/',
                                { $toString: { $cond: [{ $lte: ['$_id.month', 9] }, { $concat: ['0', { $toString: '$_id.month' }] }, '$_id.month'] } }
                            ]
                        },
                        else: { $toString: '$_id.year' }
                    }
                }
            }
        }
    }
});
const getWeekNumber = (date) => {
    const d = new Date(date);
    d.setHours(0, 0, 0, 0);
    d.setDate(d.getDate() + 4 - (d.getDay() || 7));
    const yearStart = new Date(d.getFullYear(), 0, 1);
    return Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
};
const generateAllPeriods = (interval, startDate, endDate) => {
    const periods = [];
    let currentDate = new Date(startDate);
    endDate = new Date(endDate);
    while (currentDate <= endDate) {
        if (interval === 'daily') {
            periods.push({
                period: currentDate.toISOString().split('T')[0].replace(/-/g, '/'),
                value: 0
            });
            currentDate.setDate(currentDate.getDate() + 1);
        } else if (interval === 'weekly') {
            const year = currentDate.getFullYear();
            const week = getWeekNumber(currentDate);
            periods.push({
                period: `${year}/W${week}`,
                value: 0
            });
            currentDate.setDate(currentDate.getDate() + 7);
        } else if (interval === 'monthly') {
            periods.push({
                period: `${currentDate.getFullYear()}/${String(currentDate.getMonth() + 1).padStart(2, '0')}`,
                value: 0
            });
            currentDate.setMonth(currentDate.getMonth() + 1);
        } else if (interval === 'yearly') {
            periods.push({
                period: `${currentDate.getFullYear()}`,
                value: 0
            });
            currentDate.setFullYear(currentDate.getFullYear() + 1);
        }
    }
    return periods;
};
const mergePeriodsWithData = (periods, data, valueKey) => {
    return periods.map(period => {
        const found = data.find(d => d.period === period.period);
        return {
            period: period.period,
            [valueKey]: found ? found[valueKey] : period.value.toString()
        };
    });
};

// Analytics utility functions
const getMostScannedProduct = async (req, startDate, endDate) => {
    return await Product.aggregate([
        {
            $match: { admin: req.user._id }
        },
        {
            $unwind: '$units'
        },
        {
            $match: {
                'units.status': 'scanned'
            }
        },
        {
            $match: startDate && endDate ? {
                'units.warranty_start_date': { 
                    $exists: true, 
                    $ne: null,
                    $gte: startDate.toISOString(),
                    $lte: endDate.toISOString()
                }
            } : {}
        },
        {
            $group: {
                _id: '$_id',
                name: { $first: '$name' },
                image: { $first: '$image' },
                scanCount: { $sum: 1 }
            }
        },
        {
            $project: {
                _id: 0,
                ID: '$_id',
                name: 1,
                image: {
                    $cond: {
                        if: { $gt: [{ $type: "$image" }, "missing"] },
                        then: { $concat: [ req.protocol + "://", req.hostname + ":", { $toString: process.env.port }, "/", "$image" ] },
                        else: null
                    }
                },
                scanCount: 1
            }
        },
        {
            $sort: { scanCount: -1 }
        },
        {
            $limit: 1
        }
    ]).then(results => results[0] || { name: 'No Data', scanCount: 0 });
};
const getMostCounterfeitProduct = async (req, startDate, endDate) => {
    return await Report.aggregate([
        {
            $lookup: {
                from: 'products',
                localField: 'product',
                foreignField: '_id',
                as: 'productDetails'
            }
        },
        {
            $unwind: '$productDetails'
        },
        {
            $match: {
                'productDetails.admin': req.user._id,
                'status': 'counterfeit'
            }
        },
        {
            $match: startDate && endDate ? {
                'date': { 
                    $exists: true, 
                    $ne: null,
                    $gte: startDate.toISOString(),
                    $lte: endDate.toISOString()
                }
            } : {}
        },
        {
            $group: {
                _id: '$product',
                name: { $first: '$productDetails.name' },
                image: { $first: '$productDetails.image' },
                counterfeitCount: { $sum: 1 }
            }
        },
        {
            $project: {
                _id: 0,
                ID: '$_id',
                name: 1,
                image: {
                    $cond: {
                        if: { $gt: [{ $type: "$image" }, "missing"] },
                        then: { $concat: [ req.protocol + "://", req.hostname + ":", { $toString: process.env.port }, "/", "$image" ] },
                        else: null
                    }
                },
                counterfeitCount: 1
            }
        },
        {
            $sort: { counterfeitCount: -1 }
        },
        {
            $limit: 1
        }
    ]).then(results => results[0] || { name: 'No Data', counterfeitCount: 0 });
};
const getOverviewAnalytics = async (req, startDate, endDate, productId) => {
    const productStats = await Product.aggregate([
        {
            $match: {
                admin: req.user._id,
                ...(productId ? { _id: new mongoose.Types.ObjectId(productId) } : {})
            }
        },
        {
            $unwind: '$units'
        },
        {
            $match: {
                'units.status': 'scanned',
                'units.warranty_start_date': { $exists: true, $ne: null }
            }
        },
        {
            $addFields: {
                dateField: { $toDate: '$units.warranty_start_date' },
                priceValue: { $toDouble: '$price' }
            }
        },
        {
            $match: startDate && endDate ? {
                dateField: { 
                    $gte: startDate,
                    $lte: endDate
                }
            } : {}
        },
        {
            $group: {
                _id: null,
                totalScans: { $sum: 1 },
                totalRevenue: { $sum: '$priceValue' }
            }
        }
    ]);
    const reportStats = await Report.aggregate([
        {
            $match: {
                status: 'counterfeit',
                ...(productId ? { product: new mongoose.Types.ObjectId(productId) } : {})
            }
        },
        {
            $lookup: {
                from: 'products',
                localField: 'product',
                foreignField: '_id',
                as: 'productDetails'
            }
        },
        {
            $unwind: '$productDetails'
        },
        {
            $match: {
                'productDetails.admin': req.user._id
            }
        },
        {
            $addFields: {
                dateField: { $toDate: '$date' },
                priceValue: { $toDouble: '$productDetails.price' }
            }
        },
        {
            $match: startDate && endDate ? {
                dateField: { 
                    $gte: startDate,
                    $lte: endDate
                }
            } : {}
        },
        {
            $group: {
                _id: null,
                totalReports: { $sum: 1 },
                revenueLost: { $sum: '$priceValue' }
            }
        }
    ]);
    return {
        totalScans: parseFloat(productStats[0]?.totalScans || 0),
        totalRevenue: parseFloat(productStats[0]?.totalRevenue || 0),
        totalReports: parseFloat(reportStats[0]?.totalReports || 0),
        revenueLost: parseFloat(reportStats[0]?.revenueLost || 0)
    };
};
const getGeographicalDistribution = async (req, startDate, endDate, productId) => {
    return await User.aggregate([
        {
            $match: {
                role: 'client',
                address: { $exists: true, $ne: null },
                scanned_units: { $exists: true, $ne: [] }
            }
        },
        {
            $lookup: {
                from: 'products',
                let: { scanned_units: '$scanned_units' },
                pipeline: [
                    {
                        $match: {
                            admin: req.user._id,
                            ...(productId ? { _id: new mongoose.Types.ObjectId(productId) } : {})
                        }
                    },
                    {
                        $unwind: '$units'
                    },
                    {
                        $match: {
                            $expr: {
                                $in: ['$units._id', '$$scanned_units']
                            }
                        }
                    },
                    {
                        $addFields: {
                            dateField: { $toDate: '$units.warranty_start_date' }
                        }
                    },
                    {
                        $match: startDate && endDate ? {
                            dateField: { 
                                $exists: true, 
                                $ne: null,
                                $gte: startDate,
                                $lte: endDate
                            }
                        } : {}
                    }
                ],
                as: 'scanned_products'
            }
        },
        {
            $lookup: {
                from: 'reports',
                let: { scanned_units: '$scanned_units' },
                pipeline: [
                    {
                        $match: {
                            status: 'counterfeit',
                            ...(productId ? { product: new mongoose.Types.ObjectId(productId) } : {})
                        }
                    },
                    {
                        $lookup: {
                            from: 'products',
                            localField: 'product',
                            foreignField: '_id',
                            as: 'productDetails'
                        }
                    },
                    {
                        $unwind: '$productDetails'
                    },
                    {
                        $match: {
                            'productDetails.admin': req.user._id
                        }
                    },
                    {
                        $addFields: {
                            dateField: { $toDate: '$date' }
                        }
                    },
                    {
                        $match: startDate && endDate ? {
                            dateField: { 
                                $exists: true, 
                                $ne: null,
                                $gte: startDate,
                                $lte: endDate
                            }
                        } : {}
                    }
                ],
                as: 'counterfeit_reports'
            }
        },
        {
            $match: {
                $or: [
                    { 'scanned_products': { $ne: [] } },
                    { 'counterfeit_reports': { $ne: [] } }
                ]
            }
        },
        {
            $group: {
                _id: '$address',
                scansCount: { $sum: { $size: '$scanned_products' } },
                counterfeitCount: { $sum: { $size: '$counterfeit_reports' } }
            }
        },
        {
            $project: {
                location: '$_id',
                scansCount: 1,
                counterfeitCount: 1,
                _id: 0
            }
        },
        {
            $sort: { scansCount: -1 }
        }
    ]);
};
const getCategoriesDistribution = async (req, startDate, endDate, productId) => {
    const categories = Product.schema.path('category').enumValues;
    const aggregationResult = await Product.aggregate([
        {
            $match: {
                admin: req.user._id,
                ...(productId ? { _id: new mongoose.Types.ObjectId(productId) } : {})
            }
        },
        {
            $lookup: {
                from: 'reports',
                localField: '_id',
                foreignField: 'product',
                as: 'reports'
            }
        },
        {
            $facet: {
                scanCounts: [
                    {
                        $unwind: '$units'
                    },
                    {
                        $match: {
                            'units.status': 'scanned',
                            'units.warranty_start_date': { $exists: true, $ne: null }
                        }
                    },
                    {
                        $addFields: {
                            dateField: { $toDate: '$units.warranty_start_date' }
                        }
                    },
                    {
                        $match: startDate && endDate ? {
                            dateField: {
                                $gte: startDate,
                                $lte: endDate
                            }
                        } : {}
                    },
                    {
                        $group: {
                            _id: '$category',
                            scansCount: { $sum: 1 }
                        }
                    }
                ],
                counterfeitCounts: [
                    {
                        $unwind: '$reports'
                    },
                    {
                        $match: {
                            'reports.status': 'counterfeit'
                        }
                    },
                    {
                        $addFields: {
                            dateField: { $toDate: '$reports.date' }
                        }
                    },
                    {
                        $match: startDate && endDate ? {
                            dateField: {
                                $gte: startDate,
                                $lte: endDate
                            }
                        } : {}
                    },
                    {
                        $group: {
                            _id: '$category',
                            counterfeitCount: { $sum: 1 }
                        }
                    }
                ]
            }
        }
    ]);
    const result = categories.map(category => ({
        category,
        scansCount: 0,
        counterfeitCount: 0
    }));
    aggregationResult[0].scanCounts.forEach(scan => {
        const categoryEntry = result.find(entry => entry.category === scan._id);
        if (categoryEntry) {
            categoryEntry.scansCount = scan.scansCount;
        }
    });
    aggregationResult[0].counterfeitCounts.forEach(counterfeit => {
        const categoryEntry = result.find(entry => entry.category === counterfeit._id);
        if (categoryEntry) {
            categoryEntry.counterfeitCount = counterfeit.counterfeitCount;
        }
    });
    return result.sort((a, b) => b.scansCount - a.scansCount);
};
const getWarrantyDistribution = async (req, startDate, endDate, productId) => {
    const warrantyData = await Product.aggregate([
        {
            $match: {
                admin: req.user._id,
                ...(productId ? { _id: new mongoose.Types.ObjectId(productId) } : {})
            }
        },
        {
            $unwind: '$units'
        },
        {
            $match: {
                'units.status': 'scanned',
                'units.warranty_start_date': { $ne: null }
            }
        },
        {
            $addFields: {
                warrantyStartDate: { $toDate: '$units.warranty_start_date' },
                currentDate: new Date()
            }
        },
        {
            $match: startDate && endDate ? {
                warrantyStartDate: { 
                    $gte: startDate,
                    $lte: endDate
                }
            } : {}
        },
        {
            $addFields: {
                monthsUsed: {
                    $add: [
                        { $multiply: [
                            { $subtract: [{ $year: '$currentDate' }, { $year: '$warrantyStartDate' }] },
                            12
                        ]},
                        { $subtract: [{ $month: '$currentDate' }, { $month: '$warrantyStartDate' }] }
                    ]
                }
            }
        },
        {
            $addFields: {
                durationLeft: { $subtract: ['$warranty_duration', '$monthsUsed'] }
            }
        },
        {
            $group: {
                _id: null,
                totalCount: { $sum: 1 },
                activeCount: {
                    $sum: {
                        $cond: [{ $gt: ['$durationLeft', 0] }, 1, 0]
                    }
                },
                expiredCount: {
                    $sum: {
                        $cond: [{ $lte: ['$durationLeft', 0] }, 1, 0]
                    }
                }
            }
        },
        {
            $project: {
                _id: 0,
                totalCount: 1,
                activeCount: 1,
                expiredCount: 1,
                activePercentage: {
                    $multiply: [
                        { $divide: ['$activeCount', '$totalCount'] },
                        100
                    ]
                },
                expiredPercentage: {
                    $multiply: [
                        { $divide: ['$expiredCount', '$totalCount'] },
                        100
                    ]
                }
            }
        }
    ]);
    return warrantyData[0] || { 
        totalCount: 0, 
        activeCount: 0, 
        expiredCount: 0, 
        activePercentage: 0, 
        expiredPercentage: 0 
    };
};
const getExpirationDateChart = async (req, interval, startDate, endDate, productId) => {
    const data = await Product.aggregate([
        {
            $match: {
                admin: req.user._id,
                ...(productId ? { _id: new mongoose.Types.ObjectId(productId) } : {})
            }
        },
        {
            $unwind: {
                path: '$units',
                preserveNullAndEmptyArrays: false
            }
        },
        {
            $match: {
                'units.status': 'scanned',
                'units.warranty_start_date': {
                    $exists: true,
                    $ne: null,
                    $regex: /^\d{4}-\d{2}-\d{2}$/
                },
                warranty_duration: { $type: ['int', 'double', 'long'] }
            }
        },
        {
            $addFields: {
                warrantyStartDate: { $toDate: '$units.warranty_start_date' },
                expirationDate: {
                    $dateAdd: {
                        startDate: { $toDate: '$units.warranty_start_date' },
                        unit: 'month',
                        amount: { $toInt: '$warranty_duration' }
                    }
                }
            }
        },
        {
            $match: {
                warrantyStartDate: { $ne: null },
                expirationDate: {
                    $gte: startDate,
                    $lte: endDate
                }
            }
        },
        {
            $group: {
                _id: getDateGrouping(interval, '$expirationDate'),
                expiredCount: { $sum: 1 }
            }
        },
        {
            $project: {
                _id: 0,
                expiredCount: { $toString: '$expiredCount' },
                period: formatPeriod(interval)
            }
        },
        {
            $sort: { period: 1 }
        }
    ]);
    const allPeriods = generateAllPeriods(interval, startDate, endDate);
    return mergePeriodsWithData(allPeriods, data, 'expiredCount');
};
const getScansChart = async (req, interval, startDate, endDate, productId) => {
    const data = await Product.aggregate([
        {
            $match: {
                admin: req.user._id,
                ...(productId ? { _id: new mongoose.Types.ObjectId(productId) } : {})
            }
        },
        {
            $unwind: '$units'
        },
        {
            $match: {
                'units.status': 'scanned',
                'units.warranty_start_date': {
                    $exists: true,
                    $ne: null
                }
            }
        },
        {
            $addFields: {
                dateField: { $toDate: '$units.warranty_start_date' }
            }
        },
        {
            $match: {
                dateField: {
                    $gte: startDate,
                    $lte: endDate
                }
            }
        },
        {
            $group: {
                _id: getDateGrouping(interval),
                scansCount: { $sum: 1 }
            }
        },
        {
            $project: {
                _id: 0,
                scansCount: { $toString: '$scansCount' },
                period: formatPeriod(interval)
            }
        },
        {
            $sort: { period: 1 }
        }
    ]);
    const allPeriods = generateAllPeriods(interval, startDate, endDate);
    return mergePeriodsWithData(allPeriods, data, 'scansCount');
};
const getReportsChart = async (req, interval, startDate, endDate, productId) => {
    const data = await Report.aggregate([
        {
            $match: {
                status: 'counterfeit',
                ...(productId ? { product: new mongoose.Types.ObjectId(productId) } : {})
            }
        },
        {
            $lookup: {
                from: 'products',
                localField: 'product',
                foreignField: '_id',
                as: 'productDetails'
            }
        },
        {
            $unwind: '$productDetails'
        },
        {
            $match: {
                'productDetails.admin': req.user._id
            }
        },
        {
            $addFields: {
                dateField: { $toDate: '$date' }
            }
        },
        {
            $match: {
                dateField: {
                    $gte: startDate,
                    $lte: endDate
                }
            }
        },
        {
            $group: {
                _id: getDateGrouping(interval),
                reportsCount: { $sum: 1 }
            }
        },
        {
            $project: {
                _id: 0,
                reportsCount: { $toString: '$reportsCount' },
                period: formatPeriod(interval)
            }
        },
        {
            $sort: { period: 1 }
        }
    ]);
    const allPeriods = generateAllPeriods(interval, startDate, endDate);
    return mergePeriodsWithData(allPeriods, data, 'reportsCount');
};
const getRevenueChart = async (req, interval, startDate, endDate, productId) => {
    const data = await Product.aggregate([
        {
            $match: {
                admin: req.user._id,
                ...(productId ? { _id: new mongoose.Types.ObjectId(productId) } : {})
            }
        },
        {
            $unwind: '$units'
        },
        {
            $match: {
                'units.status': 'scanned',
                'units.warranty_start_date': {
                    $exists: true,
                    $ne: null
                }
            }
        },
        {
            $addFields: {
                dateField: { $toDate: '$units.warranty_start_date' },
                priceValue: { $toDouble: '$price' }
            }
        },
        {
            $match: {
                dateField: {
                    $gte: startDate,
                    $lte: endDate
                }
            }
        },
        {
            $group: {
                _id: getDateGrouping(interval),
                revenue: { $sum: '$priceValue' }
            }
        },
        {
            $project: {
                _id: 0,
                revenue: { $toString: '$revenue' },
                period: formatPeriod(interval)
            }
        },
        {
            $sort: { period: 1 }
        }
    ]);
    const allPeriods = generateAllPeriods(interval, startDate, endDate);
    return mergePeriodsWithData(allPeriods, data, 'revenue');
};
const getRevenueLostChart = async (req, interval, startDate, endDate, productId) => {
    const data = await Report.aggregate([
        {
            $match: {
                status: 'counterfeit',
                ...(productId ? { product: new mongoose.Types.ObjectId(productId) } : {})
            }
        },
        {
            $lookup: {
                from: 'products',
                localField: 'product',
                foreignField: '_id',
                as: 'productDetails'
            }
        },
        {
            $unwind: '$productDetails'
        },
        {
            $match: {
                'productDetails.admin': req.user._id
            }
        },
        {
            $addFields: {
                dateField: { $toDate: '$date' },
                priceValue: { $toDouble: '$productDetails.price' }
            }
        },
        {
            $match: {
                dateField: {
                    $gte: startDate,
                    $lte: endDate
                }
            }
        },
        {
            $group: {
                _id: getDateGrouping(interval),
                revenueLost: { $sum: '$priceValue' }
            }
        },
        {
            $project: {
                _id: 0,
                revenueLost: { $toString: '$revenueLost' },
                period: formatPeriod(interval)
            }
        },
        {
            $sort: { period: 1 }
        }
    ]);
    const allPeriods = generateAllPeriods(interval, startDate, endDate);
    return mergePeriodsWithData(allPeriods, data, 'revenueLost');
};

// admin analytics
// APIs with optional timeframe (defaults to all data)
// APIs for all products only
router.get('/most-scanned-product', auth, role('admin'), async (req, res) => {
    try {
        const startDate = req.query.start_date ? new Date(req.query.start_date) : null;
        const endDate = req.query.end_date ? new Date(req.query.end_date) : new Date();
        validateTimeFrame(startDate, endDate);
        const data = await getMostScannedProduct(req, startDate, endDate);
        res.json({
            timeframe: startDate && endDate ? {
                start_date: startDate.toISOString().split('T')[0],
                end_date: endDate.toISOString().split('T')[0]
            } : null,
            data
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
router.get('/most-scanned-counterfeit', auth, role('admin'), async (req, res) => {
    try {
        const startDate = req.query.start_date ? new Date(req.query.start_date) : null;
        const endDate = req.query.end_date ? new Date(req.query.end_date) : new Date();
        validateTimeFrame(startDate, endDate);
        const data = await getMostCounterfeitProduct(req, startDate, endDate);
        res.json({
            timeframe: startDate && endDate ? {
                start_date: startDate.toISOString().split('T')[0],
                end_date: endDate.toISOString().split('T')[0]
            } : null,
            data
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// APIs with optional product id
router.get('/overview-analytics', auth, role('admin'), async (req, res) => {
    try {
        const startDate = req.query.start_date ? new Date(req.query.start_date) : null;
        const endDate = req.query.end_date ? new Date(req.query.end_date) : new Date();
        const productId = req.query.product_id;
        validateTimeFrame(startDate, endDate);
        const data = await getOverviewAnalytics(req, startDate, endDate, productId);
        res.json({
            timeframe: startDate && endDate ? {
                start_date: startDate.toISOString().split('T')[0],
                end_date: endDate.toISOString().split('T')[0]
            } : null,
            product_id: productId || null,
            ...data
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
router.get('/geographical-distribution', auth, role('admin'), async (req, res) => {
    try {
        const startDate = req.query.start_date ? new Date(req.query.start_date) : null;
        const endDate = req.query.end_date ? new Date(req.query.end_date) : new Date();
        const productId = req.query.product_id;
        validateTimeFrame(startDate, endDate);
        const data = await getGeographicalDistribution(req, startDate, endDate, productId);
        res.json({
            timeframe: startDate && endDate ? {
                start_date: startDate.toISOString().split('T')[0],
                end_date: endDate.toISOString().split('T')[0]
            } : null,
            product_id: productId || null,
            data
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
router.get('/categories-distribution', auth, role('admin'), async (req, res) => {
    try {
        const startDate = req.query.start_date ? new Date(req.query.start_date) : null;
        const endDate = req.query.end_date ? new Date(req.query.end_date) : new Date();
        const productId = req.query.product_id;
        validateTimeFrame(startDate, endDate);
        const data = await getCategoriesDistribution(req, startDate, endDate, productId);
        res.json({
            timeframe: startDate && endDate ? {
                start_date: startDate.toISOString().split('T')[0],
                end_date: endDate.toISOString().split('T')[0]
            } : null,
            product_id: productId || null,
            data
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
router.get('/warranty-distribution', auth, role('admin'), async (req, res) => {
    try {
        const startDate = req.query.start_date ? new Date(req.query.start_date) : null;
        const endDate = req.query.end_date ? new Date(req.query.end_date) : new Date();
        const productId = req.query.product_id;
        validateTimeFrame(startDate, endDate);
        const data = await getWarrantyDistribution(req, startDate, endDate, productId);
        res.json({
            timeframe: startDate && endDate ? {
                start_date: startDate.toISOString().split('T')[0],
                end_date: endDate.toISOString().split('T')[0]
            } : null,
            product_id: productId || null,
            data
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// APIs with interval and timeframe of default monthly, a year till this month
// APIs with optional product id
router.get('/products-expiration-date', auth, role('admin'), async (req, res) => {
    try {
        const interval = req.query.interval || 'monthly';
        const startDate = req.query.start_date ? new Date(req.query.start_date) : new Date(new Date().setMonth(new Date().getMonth() - 12));
        const endDate = req.query.end_date ? new Date(req.query.end_date) : new Date();
        const productId = req.query.product_id;   
        validateInterval(interval);
        validateTimeFrame(startDate, endDate);
        const data = await getExpirationDateChart(req, interval, startDate, endDate, productId);
        res.json({
            interval,
            timeframe: {
                start_date: startDate.toISOString().split('T')[0],
                end_date: endDate.toISOString().split('T')[0]
            },
            product_id: productId || null,
            data
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
router.get('/total-scans-chart', auth, role('admin'), async (req, res) => {
    try {
        const interval = req.query.interval || 'monthly';
        const startDate = req.query.start_date ? new Date(req.query.start_date) : new Date(new Date().setMonth(new Date().getMonth() - 12));
        const endDate = req.query.end_date ? new Date(req.query.end_date) : new Date();
        const productId = req.query.product_id;
        validateInterval(interval);
        validateTimeFrame(startDate, endDate);
        const data = await getScansChart(req, interval, startDate, endDate, productId);
        res.json({
            interval,
            timeframe: {
                start_date: startDate.toISOString().split('T')[0],
                end_date: endDate.toISOString().split('T')[0]
            },
            product_id: productId || null,
            data
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
router.get('/counterfeit-reports-chart', auth, role('admin'), async (req, res) => {
    try {
        const interval = req.query.interval || 'monthly';
        const startDate = req.query.start_date ? new Date(req.query.start_date) : new Date(new Date().setMonth(new Date().getMonth() - 12));
        const endDate = req.query.end_date ? new Date(req.query.end_date) : new Date();
        const productId = req.query.product_id;
        validateInterval(interval);
        validateTimeFrame(startDate, endDate);
        const data = await getReportsChart(req, interval, startDate, endDate, productId);
        res.json({
            interval,
            timeframe: {
                start_date: startDate.toISOString().split('T')[0],
                end_date: endDate.toISOString().split('T')[0]
            },
            product_id: productId || null,
            data
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
router.get('/total-revenue-chart', auth, role('admin'), async (req, res) => {
    try {
        const interval = req.query.interval || 'monthly';
        const startDate = req.query.start_date ? new Date(req.query.start_date) : new Date(new Date().setMonth(new Date().getMonth() - 12));
        const endDate = req.query.end_date ? new Date(req.query.end_date) : new Date();
        const productId = req.query.product_id;
        validateInterval(interval);
        validateTimeFrame(startDate, endDate);
        const data = await getRevenueChart(req, interval, startDate, endDate, productId);
        res.json({
            interval,
            timeframe: {
                start_date: startDate.toISOString().split('T')[0],
                end_date: endDate.toISOString().split('T')[0]
            },
            product_id: productId || null,
            data
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
router.get('/total-revenue-lost-chart', auth, role('admin'), async (req, res) => {
    try {
        const interval = req.query.interval || 'monthly';
        const startDate = req.query.start_date ? new Date(req.query.start_date) : new Date(new Date().setMonth(new Date().getMonth() - 12));
        const endDate = req.query.end_date ? new Date(req.query.end_date) : new Date();
        const productId = req.query.product_id;
        validateInterval(interval);
        validateTimeFrame(startDate, endDate);
        const data = await getRevenueLostChart(req, interval, startDate, endDate, productId);
        res.json({
            interval,
            timeframe: {
                start_date: startDate.toISOString().split('T')[0],
                end_date: endDate.toISOString().split('T')[0]
            },
            product_id: productId || null,
            data
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// overview analytics for current month with change percentage & optional product id
router.get('/current-month-overview-analytics', auth, role('admin'), async (req, res) => {
    try {
        const now = new Date();
        const productId = req.query.product_id;
        const currentMonthStartDate = new Date(now.getFullYear(), now.getMonth(), 1);
        const currentMonthEndDate = new Date(now.getFullYear(), now.getMonth() + 1, 0);
        const previousMonthStartDate = new Date(now.getFullYear(), now.getMonth() - 1, 1);
        const previousMonthEndDate = new Date(now.getFullYear(), now.getMonth(), 0);
        const formatDate = (date) => {
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            return `${year}-${month}-${day}`;
        };
        const currentMonthAnalytics = await getOverviewAnalytics(req, currentMonthStartDate, currentMonthEndDate, productId);
        const previousMonthAnalytics = await getOverviewAnalytics(req, previousMonthStartDate, previousMonthEndDate, productId);
        const calculateChange = (current, previous) => {
            const change = current - previous;
            const percentage = previous === 0 ? 100 : (change / previous) * 100;
            return {
                value: change,
                percentage: percentage
            };
        };
        const changes = {
            totalScans: calculateChange(currentMonthAnalytics.totalScans, previousMonthAnalytics.totalScans),
            totalRevenue: calculateChange(currentMonthAnalytics.totalRevenue, previousMonthAnalytics.totalRevenue),
            totalReports: calculateChange(currentMonthAnalytics.totalReports, previousMonthAnalytics.totalReports),
            revenueLost: calculateChange(currentMonthAnalytics.revenueLost, previousMonthAnalytics.revenueLost)
        };
        res.json({
            timeframe: {
                previous_month: {
                    start_date: formatDate(previousMonthStartDate),
                    end_date: formatDate(previousMonthEndDate)
                },
                current_month: {
                    start_date: formatDate(currentMonthStartDate),
                    end_date: formatDate(currentMonthEndDate)
                }
            },
            product_id: productId || null,
            previous_month: previousMonthAnalytics,
            current_month: currentMonthAnalytics,
            changes
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// all admin analytics - options: timeframe, interval, product
router.get('/admin-analytics', auth, role('admin'), async (req, res) => {
    try {
        const interval = req.query.interval || 'monthly';
        const startDate = req.query.start_date ? new Date(req.query.start_date) : null;
        const endDate = req.query.end_date ? new Date(req.query.end_date) : new Date();
        const productId = req.query.product_id;
        const chartStartDate = req.query.start_date ? new Date(req.query.start_date) : new Date(new Date().setMonth(new Date().getMonth() - 12));
        const chartEndDate = req.query.end_date ? new Date(req.query.end_date) : new Date();
        validateInterval(interval);
        validateTimeFrame(startDate, endDate);
        if (startDate && endDate && startDate > endDate) {
            return res.status(400).json({ error: 'Start date must be before or equal to end date' });
        }
        const isDefaultState = !req.query.start_date && !req.query.end_date;
        const responses = {};
        if (!productId) {
            responses['most-scanned-product'] = await getMostScannedProduct(req, startDate, endDate);
            responses['most-scanned-counterfeit'] = await getMostCounterfeitProduct(req, startDate, endDate);
        }
        responses['overview-analytics'] = await getOverviewAnalytics(req, startDate, endDate, productId);
        responses['geographical-distribution'] = await getGeographicalDistribution(req, startDate, endDate, productId);
        responses['categories-distribution'] = await getCategoriesDistribution(req, startDate, endDate, productId);
        responses['warranty-distribution'] = await getWarrantyDistribution(req, startDate, endDate, productId);
        responses['products-expiration-date'] = await getExpirationDateChart(req, interval, chartStartDate, chartEndDate, productId);
        responses['total-scans-chart'] = await getScansChart(req, interval, chartStartDate, chartEndDate, productId);
        responses['counterfeit-reports-chart'] = await getReportsChart(req, interval, chartStartDate, chartEndDate, productId);
        responses['total-revenue-chart'] = await getRevenueChart(req, interval, chartStartDate, chartEndDate, productId);
        responses['total-revenue-lost-chart'] = await getRevenueLostChart(req, interval, chartStartDate, chartEndDate, productId);
        const response = {
            interval,
            ...(isDefaultState ? {} : {
                timeframe: {
                    start_date: startDate.toISOString().split('T')[0],
                    end_date: endDate.toISOString().split('T')[0]
                }
            }),
            ...(isDefaultState && !productId ? {
                note: "First 6 APIs (overview-analytics, most-scanned-product, most-scanned-counterfeit, geographical-distribution, categories-distribution, warranty-distribution) return all data by default when no timeframe is provided. Last 5 APIs (products-expiration-date, total-scans-chart, counterfeit-reports-chart, total-revenue-chart, total-revenue-lost-chart) use monthly interval and a year until current month by default."
            } : {}),
            product_id: productId || null,
            data: responses
        };
        res.json(response);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Super Admin APIs
router.get('/super-admin-analytics', auth, role('super_admin'), async (req, res) => {
    try {
        const [adminCount, productStats] = await Promise.all([
            User.countDocuments({ role: 'admin' }),
            Product.aggregate([
                {
                    $group: {
                        _id: null,
                        totalProducts: { $sum: 1 },
                        totalUnits: { $sum: { $size: '$units' } },
                        totalScans: {
                            $sum: {
                                $size: {
                                    $filter: {
                                        input: '$units',
                                        as: 'unit',
                                        cond: { $eq: ['$$unit.status', 'scanned'] }
                                    }
                                }
                            }
                        }
                    }
                }
            ])
        ]);
        const stats = productStats[0] || { totalProducts: 0, totalUnits: 0, totalScans: 0 };
        res.json({
            totalAdmins: adminCount,
            totalProducts: stats.totalProducts,
            totalUnits: stats.totalUnits,
            totalScans: stats.totalScans
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
router.get('/super-admin-logs', auth, role('super_admin'), async (req, res) => {
    try {
        const { adminName, start_date, end_date, action } = req.query;
        const filter = {};
        if (adminName) {
            filter.adminName = { $regex: adminName, $options: 'i' };
        }
        if (action) {
            filter.action = { $regex: action, $options: 'i' };
        }
        if (start_date || end_date) {
            filter.date = {};
            if (start_date) {
                const startDate = new Date(start_date);
                if (isNaN(startDate.getTime())) {
                    return res.status(400).json({ error: 'Invalid start date format. Use ISO format (YYYY-MM-DD)' });
                }
                filter.date.$gte = startDate;
            }
            if (end_date) {
                const endDate = new Date(end_date);
                if (isNaN(endDate.getTime())) {
                    return res.status(400).json({ error: 'Invalid end date format. Use ISO format (YYYY-MM-DD)' });
                }
                filter.date.$lte = endDate;
            }
            if (start_date && end_date && start_date > end_date) {
                return res.status(400).json({ error: 'Start date must be before or equal to end date' });
            }
        }
        const logs = await Log.find(filter)
            .sort({ date: -1 })
            .select('adminName action date')
            .lean();
        res.json({
            filters: {
                adminName: adminName || null,
                start_date: start_date || null,
                end_date: end_date || null,
                action: action || null
            },
            logs
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router; 