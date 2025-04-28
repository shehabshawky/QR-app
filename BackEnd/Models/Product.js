const mongoose = require('mongoose');

const unitSchema = new mongoose.Schema({
    sku: {
        type: String,
        required: [true, "SKU is required"]
    },
    warranty_start_date: {
        type: String,
        validate: {
            validator: function (value) {
                if (value === null) {
                    return true;
                }
                return /^\d{4}-\d{2}-\d{2}$/.test(value);
            },
            message: props => `${props.value} is not a valid date format. Use YYYY-MM-DD.`
        }
    },
    properties: {
        type: Map,
        of: String,
        required: [true, "Properties are required"]
    },
    qr_code: {
        type: String,
        required: [true, "QR code is required"]
    },
    status: {
        type: String,
        required: [true, "status is required"],
        enum: ['scanned', 'in stock']
    }
});

const productSchema = new mongoose.Schema({
    name: {
        type: String,
        required: [true, "name is required"]
    },
    admin: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        validate: {
            validator: async function (value) {
                const user = await mongoose.model('User').findById(value);
                return user && user.role === 'admin';
            },
            message: 'The referenced user must have the role of admin'
        }
    },
    description: {
        type: String,
        required: [true, "description is required"]
    },
    release_date: {
        type: String,
        required: [true, "release_date is required"],
        validate: {
            validator: function (value) {
                return /^\d{4}-\d{2}-\d{2}$/.test(value);
            },
            message: props => `${props.value} is not a valid date format. Use YYYY-MM-DD.`
        }
    },
    image: {
        type: String,
        required: [true, "image is required"]
    },
    warranty_duration: {
        type: Number,
        required: [true, "warrany_duration is required"]
    },
    properties: {
        type: Map,
        of: [String],
        required: [true, "Properties are required"]
    },
    price: {
        type: mongoose.Decimal128,
        required: [true, "price is required"]
    },
    category: {
        type: String,
        required: [true, "category is required"],
        enum: [ 
            'Home Appliances',
            'Electronics',
            'Small Appliances',
            'Batteries and Power Solutions',
            'Office Equipment',
            'Health and Personal Care',
            'Lighting Solutions',
            'Furniture' ]
    },
    units: [unitSchema]
});

productSchema.pre('save', function (next) {
    const product = this;
    if (product.units && product.units.length > 0) {
        for (const unit of product.units) {
            const unitProps = unit.properties || {};
            const productProps = product.properties || {};
            for (const key of productProps.keys()) {
                if (!unitProps.has(key)) {
                    return next(new Error(`Unit is missing required property key: ${key}`));
                }
                const value = unitProps.get(key);
                const validValues = productProps.get(key);
                if (!validValues.includes(value)) {
                    return next(new Error(`Invalid value '${value}' for property '${key}'. Allowed values: ${validValues.join(', ')}`));
                }
            }
            for (const key of unitProps.keys()) {
                if (!productProps.has(key)) {
                    return next(new Error(`Unit has extra property key not defined in product: ${key}`));
                }
            }
        }
    }
    next();
});

const Product = mongoose.model('Product', productSchema);

module.exports = Product;