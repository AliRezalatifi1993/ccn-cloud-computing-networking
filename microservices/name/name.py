from flask import Flask, jsonify, request

# insert flask annotation here
app = Flask(__name__)


@app.route('/name')
def _name():
    return jsonify({'your name is' : 'alireza'})

@app.route('/surname')
def _surname():
    return jsonify({'your surname is' : 'latifi'})


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=30123)
