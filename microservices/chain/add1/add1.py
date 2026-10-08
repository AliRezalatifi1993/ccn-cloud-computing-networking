from flask import Flask, jsonify, request
import requests

app = Flask(__name__)

@app.route('/start')
def start():
    n = request.args.get('n', default=0, type=float)

    step1 = n + 10

    response = requests.get(f"http://add2:5000/add?n={step1}")
    data = response.json()

    return jsonify({
        "original_number": n,
        "after_add1_plus_10": step1,
        "final_result": data["result"]
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

