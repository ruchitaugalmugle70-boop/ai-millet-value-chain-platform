from flask import Flask, send_from_directory
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from pymongo import MongoClient
from config import Config
import os

# ---------------- APP INIT ----------------
app = Flask(__name__)
CORS(app)

# ---------------- JWT ----------------
app.config["JWT_SECRET_KEY"] = "super-secret-key"
jwt = JWTManager(app)

# ---------------- MONGODB ----------------
client = MongoClient(Config.MONGO_URI)
db = client[Config.DB_NAME]
app.db = db

# ---------------- UPLOAD FOLDERS ----------------
BASE_UPLOAD_FOLDER = "uploads"
app.config["UPLOAD_FOLDER"] = BASE_UPLOAD_FOLDER

# Create base folder if not exists
os.makedirs(BASE_UPLOAD_FOLDER, exist_ok=True)

# Existing folders
os.makedirs(os.path.join(BASE_UPLOAD_FOLDER, "aadhar"), exist_ok=True)
os.makedirs(os.path.join(BASE_UPLOAD_FOLDER, "land"), exist_ok=True)
os.makedirs(os.path.join(BASE_UPLOAD_FOLDER, "crop_photos"), exist_ok=True)
os.makedirs(os.path.join(BASE_UPLOAD_FOLDER, "millet_reports"), exist_ok=True)

# New folder for equipment images
os.makedirs(os.path.join(BASE_UPLOAD_FOLDER, "equipment"), exist_ok=True)

# ---------------- REGISTER BLUEPRINTS ----------------
from routes.auth_routes import auth_bp
from routes.crop_routes import crop_bp
from routes.government_routes import gov_bp
from routes.market_routes import market_bp
from routes.equipment_routes import equipment_bp   # ✅ NEW IMPORT
from routes.warehouse_routes import warehouse_bp
from routes.buyer_routes import buyer_bp

app.register_blueprint(auth_bp, url_prefix="/api/auth")
app.register_blueprint(crop_bp, url_prefix="/api/crop")
app.register_blueprint(gov_bp, url_prefix="/api/government")
app.register_blueprint(market_bp)   # market endpoint: /market
app.register_blueprint(warehouse_bp, url_prefix="/api")
app.register_blueprint(buyer_bp, url_prefix="/api/buyer")

# Register equipment under /api/equipment (clean structure)
app.register_blueprint(equipment_bp, url_prefix="/api/equipment")

# ---------------- SERVE UPLOADS ----------------
@app.route('/uploads/<path:filename>')
def serve_uploaded_file(filename):
    return send_from_directory(BASE_UPLOAD_FOLDER, filename)

# ---------------- ROOT ----------------
@app.route("/")
def home():
    return {
        "status": "success",
        "message": "Backend Running"
    }

# ---------------- RUN ----------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)