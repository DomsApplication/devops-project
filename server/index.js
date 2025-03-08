const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI;

mongoose.connect(MONGO_URI)
  .then(() => console.log('✅ MongoDB Connected'))
  .catch(err => console.error('❌ MongoDB Connection Error:', err));

const allowedOrigins = ['http://localhost:80', 'http://139.59.46.155'];

// CORS configuration
const corsOptions = {
    origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);
    if (allowedOrigins.includes(origin)) {
        callback(null, true);
    } else {
        callback(new Error('Not allowed by CORS'));
    }
    },
    methods: ['GET', 'POST'], // Allow specific HTTP methods
    credentials: true         // Allow cookies if needed
};

// Apply CORS middleware
app.use(cors(corsOptions)); 
// app.use(cors({
//     origin: 'http://localhost:3000', // Allow only frontend origin
//     methods: ['GET', 'POST'], // Allow specific HTTP methods
//     credentials: true // Allow cookies if needed
// }));
app.get('/express/', (request, response) => {
    response.send(`
        <h1>Status Code: ${response.statusCode}</h1>
        <h2>Hello World123</h2>
    `)
});

app.listen(PORT, () => {
    console.log(`App is listening on http://localhost:${PORT}`);
})