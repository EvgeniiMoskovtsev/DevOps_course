from flask import Flask
import psycopg2
from psycopg2 import OperationalError
import os

app = Flask(__name__)

def create_connection():
    try:
        conn = psycopg2.connect(
            dbname=os.environ.get("POSTGRES_DB", "example"),
            user="postgres",
            password=os.environ.get("POSTGRES_PASSWORD", "postgres"),
            host="db"
        )
        return conn
    except OperationalError as e:
        print(f"The error '{e}' occurred")
        return None

@app.route('/')
def hello():
    connection = create_connection()
    if connection:
        connection.close()
        return "Привет, мир! PostgreSQL успешно подключен."
    else:
        return "Привет, мир! Не удалось подключиться к PostgreSQL."

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8888)
