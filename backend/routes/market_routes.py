from flask import Blueprint, request, jsonify
import requests
from statistics import mean

market_bp = Blueprint("market", __name__)

API_KEY = "579b464db66ec23bdd000001a984b9393cf748925f0619debd11f478"
RESOURCE_ID = "9ef84268-d588-465a-a308-a864a43d0070"

# 🔥 Smart Static Fallback Data
FALLBACK_DATA = {
    "onion": {
        "avg": 1400,
        "high": 1650,
        "low": 1200,
    },
    "tomato": {
        "avg": 1800,
        "high": 2100,
        "low": 1500,
    },
    "potato": {
        "avg": 1100,
        "high": 1300,
        "low": 900,
    }
}

@market_bp.route("/market", methods=["GET"])
def get_market_price():

    commodity = request.args.get("commodity")

    if not commodity:
        return jsonify({"error": "Commodity required"}), 400

    commodity_lower = commodity.lower()

    try:
        # 🔹 Try Live API First
        url = f"https://api.data.gov.in/resource/{RESOURCE_ID}?api-key={API_KEY}&format=json&limit=200"

        response = requests.get(url, timeout=5)
        data = response.json()

        records = data.get("records", [])

        filtered = [
            r for r in records
            if commodity_lower in r.get("commodity", "").lower()
        ]

        if filtered:
            prices = []
            market_list = []

            for r in filtered:
                try:
                    modal = int(r["modal_price"])
                    min_p = int(r["min_price"])
                    max_p = int(r["max_price"])

                    prices.append(modal)

                    market_list.append({
                        "market": r["market"],
                        "district": r["district"],
                        "modal_price": modal,
                        "min_price": min_p,
                        "max_price": max_p,
                        "date": r["arrival_date"]
                    })
                except:
                    continue

            if prices:
                return jsonify({
                    "commodity": commodity,
                    "avg": int(mean(prices)),
                    "high": max(prices),
                    "low": min(prices),
                    "markets": market_list,
                    "source": "live"
                })

    except Exception as e:
        print("Live API failed:", e)

    # 🔥 FALLBACK LOGIC
    fallback = FALLBACK_DATA.get(commodity_lower)

    if fallback:
        return jsonify({
            "commodity": commodity,
            "avg": fallback["avg"],
            "high": fallback["high"],
            "low": fallback["low"],
            "markets": [
                {
                    "market": "Demo Market 1",
                    "district": "Sample District",
                    "modal_price": fallback["avg"],
                    "min_price": fallback["low"],
                    "max_price": fallback["high"],
                    "date": "Demo Data"
                }
            ],
            "source": "fallback"
        })

    return jsonify({"error": "No data found"})