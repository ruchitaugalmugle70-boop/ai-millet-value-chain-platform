from flask import Blueprint, request, jsonify, current_app
from werkzeug.utils import secure_filename
from werkzeug.security import generate_password_hash, check_password_hash
from flask_jwt_extended import create_access_token
import os

auth_bp = Blueprint("auth", __name__)

# ---------------- REGISTER ----------------
@auth_bp.route("/register", methods=["POST"])
def register():
    db = current_app.db

    name = request.form.get("name")
    password = request.form.get("password")
    mobile = request.form.get("mobile")
    area = request.form.get("area")
    state = request.form.get("state")
    district = request.form.get("district")
    taluka = request.form.get("taluka")

    aadhar_file = request.files.get("aadhar")
    land_file = request.files.get("land_record")
    crop_photo = request.files.get("crop_photo")

    if not all([name, password, mobile, area, state, district, taluka, aadhar_file, land_file, crop_photo]):
        return jsonify({"error": "All fields required"}), 400

    if db.farmers.find_one({"mobile": mobile}):
        return jsonify({"error": "Mobile already registered"}), 400

    hashed_password = generate_password_hash(password, method="pbkdf2:sha256")

    aadhar_filename = secure_filename(aadhar_file.filename)
    land_filename = secure_filename(land_file.filename)
    crop_filename = secure_filename(crop_photo.filename)

    aadhar_path = os.path.join("uploads/aadhar", aadhar_filename)
    land_path = os.path.join("uploads/land", land_filename)
    crop_path = os.path.join("uploads/crop_photos", crop_filename)

    aadhar_file.save(aadhar_path)
    land_file.save(land_path)
    crop_photo.save(crop_path)

    farmer = {
        "name": name,
        "mobile": mobile,
        "password": hashed_password,
        "area": area,
        "state": state,
        "district": district,
        "taluka": taluka,
        "aadhar_path": aadhar_path,
        "land_record_path": land_path,
        "crop_photo_path": crop_path,
        "approved": False
    }

    db.farmers.insert_one(farmer)

    return jsonify({
        "message": "Farmer Registered Successfully. Waiting for Government Approval"
    }), 201


# ---------------- LOGIN ----------------
@auth_bp.route("/login", methods=["POST"])
def login():
    db = current_app.db

    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400

    data = request.get_json()

    mobile = data.get("mobile")
    password = data.get("password")

    if not mobile or not password:
        return jsonify({"error": "Mobile and password required"}), 400

    farmer = db.farmers.find_one({"mobile": mobile})

    if not farmer:
        return jsonify({"error": "Farmer not found"}), 404

    if "password" not in farmer:
        return jsonify({"error": "Password not set for this user"}), 400

    if not check_password_hash(farmer["password"], password):
        return jsonify({"error": "Invalid password"}), 401

    if not farmer.get("approved", False):
        return jsonify({
            "error": "Your account is not approved by Government yet"
        }), 403

    access_token = create_access_token(identity=str(farmer["_id"]))

    # ✅ ONLY THIS PART ADDED (NO LOGIC CHANGED)
    return jsonify({
        "message": "Login Successful",
        "access_token": access_token,
        "farmer": {
            "id": str(farmer["_id"]),
            "name": farmer.get("name"),
            "mobile": farmer.get("mobile"),
            "area": farmer.get("area"),
            "state": farmer.get("state"),
            "district": farmer.get("district"),
            "taluka": farmer.get("taluka"),
        }
    }), 200
