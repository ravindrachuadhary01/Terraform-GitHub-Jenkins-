from flask import Flask, request, jsonify
import pymysql

app = Flask(__name__)

# =========================
# DB CONNECTION FUNCTION
# =========================
def get_conn():
    return pymysql.connect(
        host="app-mysql-db.cr04wsu2e9r0.ap-south-1.rds.amazonaws.com",
        user="admin",
        password="Admin12345",
        database="appdb",   # 🔥 IMPORTANT FIX (NOT mysql)
        port=3306,
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=True
    )

# =========================
# HOME
# =========================
@app.route("/")
def home():
    return "Flask + RDS Working 🚀"

# =========================
# HEALTH CHECK (ALB)
# =========================
@app.route("/health")
def health():
    return "OK", 200

# =========================
# DB TEST
# =========================
@app.route("/db")
def db_test():
    try:
        conn = get_conn()
        cursor = conn.cursor()
        cursor.execute("SELECT 1 AS result")
        result = cursor.fetchone()
        conn.close()
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# =========================
# REGISTER USER
# =========================
@app.route("/register", methods=["POST"])
def register():
    try:
        data = request.get_json()
        username = data.get("username")
        password = data.get("password")

        conn = get_conn()
        cursor = conn.cursor()

        # Create table once safely
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                username VARCHAR(100) UNIQUE,
                password VARCHAR(100)
            )
        """)

        # Insert user
        cursor.execute(
            "INSERT INTO users (username, password) VALUES (%s, %s)",
            (username, password)
        )

        conn.close()

        return jsonify({
            "message": "User Registered Successfully 🎉"
        }), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# =========================
# LOGIN USER
# =========================
@app.route("/login", methods=["POST"])
def login():
    try:
        data = request.get_json()
        username = data.get("username")
        password = data.get("password")

        conn = get_conn()
        cursor = conn.cursor()

        cursor.execute(
            "SELECT * FROM users WHERE username=%s AND password=%s",
            (username, password)
        )

        user = cursor.fetchone()
        conn.close()

        if user:
            return jsonify({
                "message": "Login Successful 🚀"
            }), 200
        else:
            return jsonify({
                "message": "Invalid Credentials ❌"
            }), 401

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# =========================
# RUN APP
# =========================
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)