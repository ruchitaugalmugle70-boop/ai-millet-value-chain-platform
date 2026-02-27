from flask import Blueprint, jsonify, current_app, request

warehouse_bp = Blueprint("warehouse", __name__)

@warehouse_bp.route("/warehouses", methods=["GET"])
def get_warehouses():
    db = current_app.db
    district = request.args.get("district")

    query = {}

    if district:
        query["district"] = {
            "$regex": f"^{district.strip()}$",
            "$options": "i"
        }

    warehouses = list(db.warehouses.find(query))

    result = []
    for w in warehouses:
        result.append({
            "id": str(w["_id"]),
            "name": w.get("name"),
            "district": w.get("district"),
            "capacity_total": w.get("capacity_total"),
            "capacity_available": w.get("capacity_available"),
            "storage_cost_per_ton": w.get("storage_cost_per_ton"),
           "contact_number": w.get("contact_number") or w.get("contactNumber") or "",
        })

    return jsonify(result), 200