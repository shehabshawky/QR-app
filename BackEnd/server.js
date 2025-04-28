const mongoose = require('mongoose');
const express = require('express');
const cors = require('cors');
require('dotenv').config({ path: './config.env' });
const users = require('./Routes/users');
const products = require('./Routes/products');
const reports = require('./Routes/reports');
const analytics = require('./Routes/analytics');
const recommendations = require('./Routes/recommendationRoutes');

// DB connection
mongoose.connect(process.env.db)
.catch((error) => {
    console.error("Error connecting to MongoDB:", error.message);
});

// express
let app = express();
app.use(express.json());

// cors
const corsOptions = { origin: '*', optionsSuccessStatus: 200 };
app.use(cors(corsOptions));

// uploads
app.use(express.static("upload"));

// health_check
app.use("/api/health", async (req, res) => {
    res.status(200).send("Server is alive!");
});

// routes
app.use('/api/users', users);
app.use('/api/products', products);
app.use('/api/reports', reports);
app.use('/api/analytics', analytics);
app.use('/api/recommendations', recommendations);

// 404 handler
app.all('*', (req, res, next) => {
    res.status(404).json(`can't find ${req.originalUrl}`);
});

// error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json('Unexpected Server Error');
});

// server
const port = process.env.port;
app.listen(port, () => console.log(`Server listening on port ${port}`));