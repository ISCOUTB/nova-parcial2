from flask import Flask, jsonify
import os

app = Flask(__name__)

APP_VERSION = os.getenv("APP_VERSION", "v2")
APP_ENV = os.getenv("APP_ENV", "dev")


@app.route("/")
def home():
    return jsonify(
        {
            "message": "Nova Taller 2 funcionando correctamente",
            "version": APP_VERSION,
            "environment": APP_ENV,
        }
    )


@app.route("/health")
def health():
    return jsonify(
        {
            "status": "ok",
            "version": APP_VERSION,
        }
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)