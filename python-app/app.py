from flask import Flask, jsonify, request
import os
import sys
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        'message': 'Hello from Python Flask App!',
        'status': 'running',
        'environment': os.getenv('ENVIRONMENT', 'development')
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'service': 'python-app'
    })

@app.route('/api/data', methods=['GET', 'POST'])
def data():
    if request.method == 'GET':
        return jsonify({
            'data': [
                {'id': 1, 'name': 'Item 1'},
                {'id': 2, 'name': 'Item 2'},
                {'id': 3, 'name': 'Item 3'}
            ]
        })
    elif request.method == 'POST':
        data = request.get_json()
        logger.info(f"Received data: {data}")
        return jsonify({
            'message': 'Data received successfully',
            'data': data
        }), 201

@app.route('/api/status')
def status():
    return jsonify({
        'python_version': sys.version,
        'hostname': os.uname().nodename,
        'environment': os.getenv('ENVIRONMENT', 'development')
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('ENVIRONMENT', 'development') == 'development'
    app.run(host='0.0.0.0', port=port, debug=debug) 