from flask import Flask, jsonify, send_from_directory, request
import os

app = Flask(__name__)

API_KEY = "ROBNITE_SECURE_KEY"

@app.route("/")
def home():
    return "Robnite API is running"

@app.route("/version")
def version():
    if request.headers.get("X-API-KEY") != API_KEY:
        return jsonify({"error": "Unauthorized"}), 401

    return send_from_directory(".", "version.json")

@app.route("/download/<path:filename>")
def download(filename):
    if request.headers.get("X-API-KEY") != API_KEY:
        return jsonify({"error": "Unauthorized"}), 401

    return send_from_directory("updates", filename)

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
