from flask import Flask, request, jsonify
import pymysql

app = Flask(__name__)

# 🔥 Create DB connection per request (SAFE)
def get_conn():
    return pymysql.connect(
        host="app-mysql-db.cr04wsu2e9r0.ap-south-1.rds.amazonaws.com",
        user="admin",
        password="Admin12345",
        database="mysql",
        port=3306,
        cursorclass=pymysql.cursors.DictCursor
    )

# ---------------- HOME ----------------
@app.route("/")
def home():
    return "Flask + RDS Connected"

# ---------------- HEALTH ----------------
@app.route("/health")
def health():
    return "OK", 200

# ---------------- DB TEST ----------------
@app.route("/db")
def db_check():
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute("SELECT 1 AS result")
    result = cursor.fetchone()
    conn.close()
    return jsonify(result)

# ---------------- REGISTER ----------------
@app.route("/register", methods=["POST"])
def register():
    data = request.get_json()
    username = data.get("username")
    password = data.get("password")

    conn = get_conn()
    cursor = conn.cursor()

    # 🔥 create table if not exists
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(100) UNIQUE,
            password VARCHAR(100)
        )
    """)

    try:
        cursor.execute(
            "INSERT INTO users (username, password) VALUES (%s, %s)",
            (username, password)
        )
        conn.commit()
        return jsonify({"message": "User Registered Successfully"}), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 400

    finally:
        conn.close()

# ---------------- LOGIN ----------------
@app.route("/login", methods=["POST"])
def login():
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
        return jsonify({"message": "Login Successful"}), 200
    else:
        return jsonify({"message": "Invalid Credentials"}), 401

# ---------------- RUN APP ----------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)