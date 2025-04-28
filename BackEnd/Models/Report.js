const mongoose = require('mongoose');

const reportSchema = new mongoose.Schema({
    product: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Product',
            required: true
    },
    client: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
            validate: {
                validator: async function (value) {
                    const user = await mongoose.model('User').findById(value);
                    return user && user.role === 'client';
                },
                message: 'The referenced user must have the role of admin'
            }
    },
    image: {
        type: String,
        required: [true, "image is required"]
    },
    sku: {
        type: String,
        required: [true, "sku is required"]
    },
    date: {
        type: String,
        required: [true, "date is required"],
        validate: {
            validator: function (value) {
                return /^\d{4}-\d{2}-\d{2}$/.test(value);
            },
            message: props => `${props.value} is not a valid date format. Use YYYY-MM-DD.`
        }
    },
    status:
    {
        type: String,
        required: [true, "status is required"],
        enum: ['counterfeit', 'original']
    }
});

const Report = mongoose.model('Report', reportSchema);

module.exports = Report;