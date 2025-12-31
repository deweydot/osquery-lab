import uuid
from flask import Flask, request, jsonify, render_template

app = Flask(__name__)

# Server State
HOSTNAMES = {} # map node key to hostname
QUERY = {"id": None, "sql": None} # current query
RESULTS = {} # results from current query
PROCESSED_NODES = set() # nodes that already been sent query

@app.route('/')
def index(): return render_template('index.html')

@app.route('/api/deploy', methods=['POST'])
def deploy():
    """
    Push a new query to nodes
    """
    global QUERY, RESULTS, PROCESSED_NODES # update server state
    QUERY = {
        "id": str(uuid.uuid4()), # generate unique id for query
        "sql": request.json.get('query', ''), # update query
    }
    RESULTS = {} # empty results
    PROCESSED_NODES = set() # empty processed nodes
    return "ok"

@app.route('/api/results')
def results():
    """
    Returns any stored results
    """
    ret = {}
    for node_key, rows in RESULTS.items():
        if node_key in HOSTNAMES:
            hostname = HOSTNAMES[node_key]
            ret[hostname] = rows
    return jsonify(ret)

@app.route('/enroll', methods=['POST'])
def enroll():
    """
    Endpoint for enrollment of new nodes
    """
    if not request.json.get('host_identifier'): return jsonify(node_invalid=True) # require hostname for enrollment

    node_key = str(uuid.uuid4()) # generate unique node key
    HOSTNAMES[node_key] = request.json.get('host_identifier') # store node hostname
    return jsonify(node_key=node_key, node_invalid=False)

@app.route('/config', methods=['POST'])
def config():
    """
    Endpoint for node configuration (required by osquery)
    """
    return jsonify(node_invalid=False, schedule={})

@app.route('/distributed_read', methods=['POST'])
def read():
    """
    Endpoint for sending distributed queries to nodes
    """
    node_key = request.json.get('node_key', '')
    if node_key not in HOSTNAMES: return jsonify(node_invalid=True) # if host is not known invalidate node

    # check if node has been processed already
    if QUERY["sql"] and node_key not in PROCESSED_NODES:
        PROCESSED_NODES.add(node_key) # mark node as done
        return jsonify(queries={QUERY["id"]: QUERY["sql"]})
    return jsonify(queries={})

@app.route('/distributed_write', methods=['POST'])
def write():
    """
    Endpoint for receiving distributed queries from nodes
    """
    node_key = request.json.get('node_key', '')
    if node_key not in HOSTNAMES: return jsonify(node_invalid=True) # if host is not known invalidate node
    
    # parse request for results
    queries = request.json.get('queries', {})
    for query_id, rows in queries.items():
        if query_id == QUERY["id"]: # verify response is to current query
            RESULTS[node_key] = rows # add to results
    return jsonify({})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)