from flask import Flask
import pymysql

app = Flask(__name__)

conn = pymysql.connect(
    host="app-mysql-db.cr04wsu2e9r0.ap-south-1.rds.amazonaws.com",
    user="admin",
    password="Admin12345",
    database="mysql",
    port=3306
)

@app.route("/")
def home():
    return "Flask + RDS Connected"

@app.route("/db")
def db_check():
    cursor = conn.cursor()
    cursor.execute("SELECT 1")
    result = cursor.fetchone()
    return f"DB Response: {result}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)