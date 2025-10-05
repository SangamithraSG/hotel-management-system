from flask import Flask
import mysql.connector

def create_app():
    app = Flask(__name__)
    app.config['SECRET_KEY'] = 'your-secret-key'
    
    # Database configuration
    app.config['MYSQL_CONFIG'] = {
        'host': 'localhost',
        'user': 'root',
        'password': 'Admin123',  # Update with your MySQL password
        'database': 'hotel_management'  # Ensure this matches your MySQL setup
    }
    
    from .routes import bp
    app.register_blueprint(bp)
    
    return app

def get_db_connection():
    return mysql.connector.connect(**create_app().config['MYSQL_CONFIG'])