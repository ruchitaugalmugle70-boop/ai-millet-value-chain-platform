from flask import Blueprint, request, jsonify, current_app
from werkzeug.security import generate_password_hash, check_password_hash
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from datetime import datetime
from bson import ObjectId
import os

buyer_bp = Blueprint("buyer", __name__)

# =====================================================
# REGISTER BUYER
# =====================================================
@buyer_bp.route("/register", methods=["POST"])
def register_buyer():
    try:
        db = current_app.db
        data = request.get_json(silent=True)

        if data is None:
            return jsonify({"error": "Invalid JSON format"}), 400

        name = data.get("name")
        region = data.get("region")
        phone = data.get("phone")
        password = data.get("password")

        if not all([name, region, phone, password]):
            return jsonify({"error": "All fields required"}), 400

        if db.buyers.find_one({"phone": phone}):
            return jsonify({"error": "Phone already registered"}), 400

        hashed_password = generate_password_hash(password)

        buyer = {
            "name": name,
            "region": region,
            "phone": phone,
            "password": hashed_password,
            "role": "buyer",
            "created_at": datetime.utcnow()
        }

        db.buyers.insert_one(buyer)
        return jsonify({"message": "Buyer registered successfully"}), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# =====================================================
# LOGIN BUYER
# =====================================================
@buyer_bp.route("/login", methods=["POST"])
def login_buyer():
    try:
        db = current_app.db
        data = request.get_json(silent=True)

        phone = data.get("phone")
        password = data.get("password")

        buyer = db.buyers.find_one({"phone": phone})

        if not buyer:
            return jsonify({"error": "Buyer not found"}), 404

        if not check_password_hash(buyer["password"], password):
            return jsonify({"error": "Invalid password"}), 401

        access_token = create_access_token(identity=str(buyer["_id"]))

        return jsonify({
            "access_token": access_token,
            "buyer": {
                "id": str(buyer["_id"]),
                "name": buyer.get("name"),
                "region": buyer.get("region"),
                "phone": buyer.get("phone"),
            }
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# =====================================================
# VIEW MARKETPLACE (FIXED)
# =====================================================
@buyer_bp.route("/marketplace", methods=["GET"])
def view_marketplace():
    try:
        db = current_app.db

        # Optional filters
        millet_name = request.args.get("millet_name")
        millet_variety = request.args.get("millet_variety")

        query = {"status": "available"}

        if millet_name:
            query["millet_name"] = {"$regex": millet_name, "$options": "i"}

        if millet_variety:
            query["millet_variety"] = {"$regex": millet_variety, "$options": "i"}

        millets = list(db.millets.find(query))

        result = []

        for m in millets:

            image_url = None

            # ✅ We now store ONLY filename in DB
            if m.get("hardware_report"):
                filename = m.get("hardware_report")
                image_url = f"http://192.168.0.151:5001/api/crop/millet-report/{filename}"

            result.append({
                "id": str(m["_id"]),
                "millet_name": m.get("millet_name"),
                "millet_variety": m.get("millet_variety"),
                "quantity": m.get("quantity"),
                "price_per_kg": m.get("price_per_kg"),
                "location": m.get("location"),
                "farmer_name": m.get("farmer_name"),
                "storage_method": m.get("storage_method"),
                "hardware_verified": bool(m.get("hardware_verified", False)),
                "hardware_report": image_url
            })

        return jsonify(result), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500