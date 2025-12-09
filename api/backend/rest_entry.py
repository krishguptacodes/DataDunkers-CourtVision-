from flask import Flask
from dotenv import load_dotenv
import os
import logging
from logging.handlers import RotatingFileHandler
from backend.db_connection import db

# Import your CourtVision blueprints
from backend.players.player_routes import players
from backend.scouts.scout_routes import scouts
from backend.analytics.analytics_routes import analytics
from backend.admin.admin_routes import admin


def create_app():
    app = Flask(__name__)
    app.logger.setLevel(logging.DEBUG)
    app.logger.info('CourtVision API startup')

    # Load environment variables
    load_dotenv()

    # Secret key for session security
    app.config["SECRET_KEY"] = os.getenv("SECRET_KEY")

    # # these are for the DB object to be able to connect to MySQL.
    # app.config['MYSQL_DATABASE_USER'] = 'root'
    app.config["MYSQL_DATABASE_USER"] = "courtvision_user"
    app.config["MYSQL_DATABASE_PASSWORD"] = os.getenv("DB_PASSWORD").strip()    
    app.config["MYSQL_DATABASE_HOST"] = os.getenv("DB_HOST").strip()
    app.config["MYSQL_DATABASE_PORT"] = int(os.getenv("DB_PORT").strip())
    app.config["MYSQL_DATABASE_DB"] = os.getenv("DB_NAME").strip()

    # Initialize the database object
    app.logger.info("Initializing database connection")
    db.init_app(app)

    # Register the routes from each Blueprint with the app object
    # and give a url prefix to each
    app.logger.info("create_app(): registering blueprints with Flask app object.")
    app.register_blueprint(simple_routes)
    app.register_blueprint(scouts, url_prefix='/scouts')
    app.register_blueprint(players, url_prefix='/players')
    app.register_blueprint(analysts, url_prefix='/analysts')
    app.register_blueprint(admins, url_prefix='/admins')

    # Scouts Blueprint - handles scout activity, annotations, player scheduling
    app.register_blueprint(scouts)

    # Analytics Blueprint - handles metrics, dashboards, data exports
    app.register_blueprint(analytics)

    # Admin Blueprint - handles user management, verifications, reports
    app.register_blueprint(admin)

    app.logger.info("All blueprints registered successfully")

    # Return the app object
    return app


def setup_logging(app):
    """
    Configure logging for the Flask application

    Args:
        app: Flask application instance to configure logging for
    """
    pass