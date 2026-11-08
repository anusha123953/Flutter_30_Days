from flask import Flask, jsonify, request
from flask_cors import CORS

# 1. Create Flask application
app = Flask(__name__)
CORS(app)


# 2. Homepage API (GET)
@app.route("/")
def home():
    return "Welcome to Anusha's Flask API!"


# 3. JSON API (GET)
@app.route("/api", methods=["GET"])
def my_api():
    return jsonify({
        "name": "Anusha",
        "technology": "Python Flask",
        "project": "Flutter Currency Converter",
        "status": "API Working Successfully"
    })


# 4. Greeting API (POST)
@app.route("/greet", methods=["POST"])
def greet():
    data = request.get_json()

    name = data.get("name", "Guest")

    return jsonify({
        "message": f"Hello {name}!",
        "status": "Success"
    })


# 5. Run Flask server
if __name__ == "__main__":
    app.run(debug=True)