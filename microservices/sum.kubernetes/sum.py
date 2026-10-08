from flask import Flask, jsonify, request
from random import random

# insert flask annotation here
app = Flask(__name__)


@app.route('/sum')
def _sum():
    # A: first number to sum
    # B: second number to sum
    a = request.args.get('a', default=0, type=float)
    b = request.args.get('b', default=0, type=float)
    return jsonify({'result': str(a + b)})

@app.route('/rand')
def _randomNumber():
    return jsonify({'result': str(random())})


if __name__ == "__main__":
    app.run(host='0.0.0.0')
