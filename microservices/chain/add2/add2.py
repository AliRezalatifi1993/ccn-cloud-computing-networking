from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route('/add')
def add():
    n = request.args.get('n', default=0, type=float)

    result = n + 20

    return jsonify({
        "received_number": n,
        "added_by_add2": 20,
        "result": result
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

