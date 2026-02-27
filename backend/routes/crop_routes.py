from flask import Blueprint, request, jsonify, current_app, send_from_directory
from flask_jwt_extended import jwt_required, get_jwt_identity
from werkzeug.utils import secure_filename
from datetime import datetime
from bson import ObjectId
import os
import requests
from config import Config

crop_bp = Blueprint("crop", __name__)

# =====================================================
# WEATHER FUNCTION
# =====================================================
def get_weather_data(region):
    try:
        url = f"http://api.openweathermap.org/data/2.5/weather?q={region},IN&appid={Config.WEATHER_API_KEY}&units=metric"
        response = requests.get(url)
        data = response.json()

        if response.status_code != 200:
            return None

        return {
            "temperature": data["main"]["temp"],
            "humidity": data["main"]["humidity"],
            "rainfall": data.get("rain", {}).get("1h", 0)
        }
    except:
        return None


# =====================================================
# WEATHER ROUTE
# =====================================================
@crop_bp.route("/weather/<region>", methods=["GET"])
def get_weather(region):
    weather = get_weather_data(region)
    if not weather:
        return jsonify({"error": "Weather data not available"}), 400
    return jsonify(weather), 200


# =====================================================
# ADD MILLET
# =====================================================
@crop_bp.route("/add-millet", methods=["POST"])
@jwt_required()
def add_millet():
    try:
        db = current_app.db
        farmer_id = get_jwt_identity()

        farmer = db.farmers.find_one({"_id": ObjectId(farmer_id)})

        if not farmer or not farmer.get("approved", False):
            return jsonify({"error": "Unauthorized farmer"}), 403

        millet_name = request.form.get("millet_name")
        millet_variety = request.form.get("millet_variety")
        quantity = int(request.form.get("quantity"))
        price_per_kg = float(request.form.get("price_per_kg"))
        storage_method = request.form.get("storage_method")
        hardware_verified = request.form.get("hardware_verified") == "true"

        report_file = request.files.get("hardware_report")
        report_path = None

        if storage_method == "Fumigation":

            if not report_file:
                return jsonify({"error": "Hardware report image required"}), 400

            upload_folder = os.path.join(
                current_app.config["UPLOAD_FOLDER"],
                "millet_reports"
            )

            os.makedirs(upload_folder, exist_ok=True)

            file_extension = report_file.filename.split(".")[-1].lower()

            filename = secure_filename(
                f"{farmer_id}_{int(datetime.utcnow().timestamp())}.{file_extension}"
            )

            full_path = os.path.join(upload_folder, filename)
            report_file.save(full_path)

            # store only filename (not full path)
            report_path = filename

        millet = {
            "farmer_id": farmer_id,
            "farmer_name": farmer.get("name"),
            "millet_name": millet_name,
            "millet_variety": millet_variety,
            "quantity": quantity,
            "price_per_kg": price_per_kg,
            "location": farmer.get("district"),
            "storage_method": storage_method,
            "hardware_verified": hardware_verified,
            "hardware_report": report_path,
            "created_at": datetime.utcnow(),
            "status": "available"
        }

        db.millets.insert_one(millet)

        return jsonify({"message": "Millet added successfully"}), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# =====================================================
# SERVE IMAGE
# =====================================================
@crop_bp.route("/millet-report/<filename>", methods=["GET"])
def get_millet_report(filename):
    upload_folder = os.path.join(
        current_app.config["UPLOAD_FOLDER"],
        "millet_reports"
    )
    return send_from_directory(upload_folder, filename)