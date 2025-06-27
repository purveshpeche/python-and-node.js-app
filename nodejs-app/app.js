const express = require('express');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;
const ENVIRONMENT = process.env.ENVIRONMENT || 'development';

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging middleware
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    next();
});

// Routes
app.get('/', (req, res) => {
    res.json({
        message: 'Hello from Node.js Express App!',
        status: 'running',
        environment: ENVIRONMENT
    });
});

app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        service: 'nodejs-app'
    });
});

app.get('/api/data', (req, res) => {
    res.json({
        data: [
            { id: 1, name: 'Node Item 1' },
            { id: 2, name: 'Node Item 2' },
            { id: 3, name: 'Node Item 3' }
        ]
    });
});

app.post('/api/data', (req, res) => {
    const data = req.body;
    console.log('Received data:', data);
    res.status(201).json({
        message: 'Data received successfully',
        data: data
    });
});

app.get('/api/status', (req, res) => {
    res.json({
        node_version: process.version,
        hostname: os.hostname(),
        environment: ENVIRONMENT,
        platform: os.platform(),
        arch: os.arch()
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        error: 'Something went wrong!',
        message: err.message
    });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        error: 'Route not found'
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Node.js app listening on port ${PORT}`);
    console.log(`Environment: ${ENVIRONMENT}`);
}); 