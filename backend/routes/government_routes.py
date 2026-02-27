from flask import Blueprint, jsonify, current_app, request
from bson import ObjectId
from flask_jwt_extended import create_access_token

gov_bp = Blueprint("government", __name__)

# =====================================================
# GOVERNMENT LOGIN
# =====================================================
@gov_bp.route("/login", methods=["POST"])
def government_login():

    # 🔥 Prevent crash if no JSON
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400

    data = request.get_json()

    if not data:
        return jsonify({"error": "No data provided"}), 400

    username = data.get("username")
    password = data.get("password")

    if not username or not password:
        return jsonify({"error": "Username and password required"}), 400

    if username == "admin" and password == "admin123":
        access_token = create_access_token(identity="government_admin")
        return jsonify({
            "message": "Government Login Successful",
            "access_token": access_token
        }), 200

    return jsonify({"error": "Invalid credentials"}), 401


# =====================================================
# FARMER STATISTICS
# =====================================================
@gov_bp.route("/stats", methods=["GET"])
def farmer_stats():
    db = current_app.db

    total = db.farmers.count_documents({})
    approved = db.farmers.count_documents({"approved": True})
    pending = db.farmers.count_documents({"approved": False})

    return jsonify({
        "total_farmers": total,
        "approved_farmers": approved,
        "pending_farmers": pending
    }), 200


# =====================================================
# GET FARMERS
# =====================================================
@gov_bp.route("/farmers", methods=["GET"])
def get_farmers():
    db = current_app.db

    district = request.args.get("district")

    query = {}
    if district:
        query["district"] = district

    farmers = list(db.farmers.find(query))

    formatted = []

    for farmer in farmers:
        formatted.append({
            "_id": str(farmer["_id"]),
            "name": farmer.get("name"),
            "mobile": farmer.get("mobile"),
            "area": farmer.get("area"),
            "state": farmer.get("state"),
            "district": farmer.get("district"),
            "taluka": farmer.get("taluka"),
            "aadhar_path": farmer.get("aadhar_path"),
            "land_record_path": farmer.get("land_record_path"),
            "crop_photo_path": farmer.get("crop_photo_path"),
            "approved": farmer.get("approved", False)
        })

    return jsonify(formatted), 200


# =====================================================
# APPROVE FARMER
# =====================================================
@gov_bp.route("/approve/<farmer_id>", methods=["PUT"])
def approve_farmer(farmer_id):
    db = current_app.db

    try:
        result = db.farmers.update_one(
            {"_id": ObjectId(farmer_id)},
            {"$set": {"approved": True}}
        )

        if result.matched_count == 0:
            return jsonify({"error": "Farmer not found"}), 404

        return jsonify({"message": "Farmer Approved"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# =====================================================
# REJECT FARMER
# =====================================================
@gov_bp.route("/reject/<farmer_id>", methods=["DELETE"])
def reject_farmer(farmer_id):
    db = current_app.db

    try:
        result = db.farmers.delete_one({"_id": ObjectId(farmer_id)})

        if result.deleted_count == 0:
            return jsonify({"error": "Farmer not found"}), 404

        return jsonify({"message": "Farmer Rejected"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
