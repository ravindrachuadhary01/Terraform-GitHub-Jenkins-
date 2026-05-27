from flask import Flask
import pymysql

app = Flask(__name__)

DB_HOST = "app-mysql-db.cr04wsu2e9r0.ap-south-1.rds.amazonaws.com"
DB_USER = "admin"
DB_PASSWORD = "Admin12345"

@app.route("/")
def home():
    try:
        connection = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD
        )

        return "✅ Flask Backend Connected to RDS Successfully!"

    except Exception as e:
        return f"Database Connection Failed: {e}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)