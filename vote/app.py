from flask import Flask, request, g, jsonify
from flask_cors import CORS
from pynats import NATSClient
import os
import socket
import random
import json
import logging
import redis

# Get name of the current container
hostname = socket.gethostname()

# Redis connection string
redis_url = os.getenv('REDIS_URL','redis://redis:6379')

# Define application and enable cors
app = Flask(__name__)
CORS(app)

gunicorn_error_logger = logging.getLogger('gunicorn.error')
app.logger.handlers.extend(gunicorn_error_logger.handlers)
app.logger.setLevel(logging.INFO)

def get_redis():
    if not hasattr(g, 'redis'):
        app.logger.debug("connectiong to redis with connection string [%s]", redis_url)
        g.redis = redis.from_url(redis_url)
        app.logger.debug("connected to redis")
    return g.redis

@app.route("/", methods=['POST'])
def vote():
    # Get json payload
    payload = request.get_json()

    # Make sure vote and voter_id are provider
    if not 'vote' in payload:
        return jsonify({"error": "missing vote parameter"}), 400
    vote = payload['vote']

    # Use voter_id if provided, otherwise create a new one and send it to the current client
    if (not 'voter_id' in payload) or payload['voter_id'] == '':
        voter_id = hex(random.getrandbits(64))[2:-1]
    else:
        voter_id = payload['voter_id']

    app.logger.info('Received a vote for %s', vote)

    # Use provided backend (among 'db' or 'nats')
    # Note: default to 'db' backend
    backend = os.getenv('BACKEND','db')
    app.logger.info('backend is %s', backend)

    # Select backend
    if backend == 'db':
        # Persist vote in redis
        r = get_redis()
        data = json.dumps({'voter_id': voter_id, 'vote': vote})
        r.rpush('votes', data)
        return jsonify({"hostname": hostname, "voter_id": voter_id}), 200

    elif backend == 'nats':
        # Send vote to NATS
        NATS_URL = os.getenv('NATS_URL', 'nats://nats:4222')
        data = json.dumps({"vote": vote, "voter_id": voter_id})
        try:
            with NATSClient(NATS_URL, socket_timeout=2) as client:
                app.logger.info("connected to nats")
                client.publish("vote", payload=json.dumps(data).encode())
        except Exception as e:
            app.logger.info(e)
            return jsonify({"error": "cannot publish payload {} to NATS".format(data)}), 400
        return jsonify({"hostname": hostname, "voter_id": voter_id, "backend": "NATS"}), 200
    
    else:
        return jsonify({"error": "incorrect backend specified (must be db or nats)"}), 500

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True, threaded=True)
