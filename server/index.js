const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Read allowed origins from .env and convert them into an array
const allowedOrigins = process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : [];

const corsOptions = {
    origin: function (origin, callback) {
        if (!origin || allowedOrigins.includes(origin)) {
            callback(null, true);
        } else {
            callback(new Error('Not allowed by CORS'));
        }
    },
    methods: ['GET', 'POST'], 
    credentials: true
};

// Apply CORS middleware
app.use(cors(corsOptions));

app.get('/express/', (request, response) => {
    response.send(`
        <h1>Status Code: ${response.statusCode}</h1>
        <h2>Hello World123 updated 2</h2>
    `);
});

app.listen(PORT, () => {
    console.log(`App is listening on http://localhost:${PORT}`);
    console.log(`Allowed Origins:`, allowedOrigins);
});
