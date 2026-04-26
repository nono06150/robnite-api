from flask import Flask, jsonify, send_from_directory, request, make_response
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

    response = make_response(send_from_directory(".", "version.json"))
    response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
    response.headers["Pragma"] = "no-cache"
    return response

@app.route("/download/<path:filename>")
def download(filename):
    if request.headers.get("X-API-KEY") != API_KEY:
        return jsonify({"error": "Unauthorized"}), 401

    response = make_response(send_from_directory("updates", filename))
    response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
    response.headers["Pragma"] = "no-cache"
    return response

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
