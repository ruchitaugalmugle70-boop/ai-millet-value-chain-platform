from flask import Blueprint, request, jsonify, current_app
from werkzeug.utils import secure_filename
from bson import ObjectId
from datetime import datetime
import os

equipment_bp = Blueprint("equipment_bp", __name__)

UPLOAD_FOLDER = "uploads/equipment"


# ---------------- ADD EQUIPMENT ----------------
@equipment_bp.route("/add-equipment", methods=["POST"])
def add_equipment():
    db = current_app.db

    equipment_name = request.form.get("equipment_name")
    type_ = request.form.get("type")
    location = request.form.get("location")
    farmer_name = request.form.get("farmer_name")
    price_per_day = request.form.get("price_per_day")
    sale_price = request.form.get("sale_price")
    contact_number = request.form.get("contact_number")

    image = request.files.get("image")

    filename = None
    if image:
        os.makedirs(UPLOAD_FOLDER, exist_ok=True)
        filename = secure_filename(image.filename)
        image.save(os.path.join(UPLOAD_FOLDER, filename))

    equipment_data = {
        "equipment_name": equipment_name,
        "type": type_,
        "location": location,
        "farmer_name": farmer_name,
        "price_per_day": int(price_per_day) if price_per_day else None,
        "sale_price": int(sale_price) if sale_price else None,
        "contact_number": contact_number,
        "image": filename,
        "created_at": datetime.utcnow()
    }

    db.equipment.insert_one(equipment_data)

    return jsonify({"message": "Equipment added successfully"}), 201


# ---------------- GET ALL EQUIPMENT ----------------
@equipment_bp.route("/get-equipment", methods=["GET"])
def get_equipment():
    db = current_app.db

    # 🔎 DEBUG INFORMATION
    print("\n===== DEBUG EQUIPMENT API =====")
    print("Database Name:", db.name)
    print("Collections:", db.list_collection_names())
    print("Equipment Count:", db.equipment.count_documents({}))
    print("================================\n")

    equipments = list(db.equipment.find())

    for e in equipments:
        e["_id"] = str(e["_id"])

    return jsonify(equipments), 200


# ---------------- GET SINGLE EQUIPMENT ----------------
@equipment_bp.route("/equipment/<id>", methods=["GET"])
def get_single_equipment(id):
    db = current_app.db

    equipment = db.equipment.find_one({"_id": ObjectId(id)})

    if not equipment:
        return jsonify({"error": "Equipment not found"}), 404

    equipment["_id"] = str(equipment["_id"])

    return jsonify(equipment), 200