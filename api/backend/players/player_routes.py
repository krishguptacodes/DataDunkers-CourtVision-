from flask import Blueprint, jsonify, request
from backend.db_connection import db
from mysql.connector import Error
from flask import current_app

# Create a Blueprint for NGO routes
<<<<<<< HEAD
players = Blueprint("players", __name__)

# Add a new game's statistics for a player
# Example: POST /games/stats with JSON body containing game stats

@players.route("/stats", methods=["POST"])
def add_game_stats():
    cursor = None
    try:
        data = request.get_json()
        
        # Required fields
        required_fields = ["gameID", "playerID", "minutes", "points", "rebounds", 
                          "assists", "steals", "blocks", "turnovers", "fouls", "three_pt"]
        
        # Check if all required fields are present
        for field in required_fields:
            if field not in data:
                return jsonify({"error": f"Missing required field: {field}"}), 400
        
        cursor = db.get_db().cursor()
        
        # Check if player exists
        cursor.execute("SELECT * FROM Players WHERE playerID = %s", (data["playerID"],))
        if not cursor.fetchone():
            return jsonify({"error": "Player not found"}), 404
        
        # Check if game exists
        cursor.execute("SELECT * FROM Games WHERE gameID = %s", (data["gameID"],))
        if not cursor.fetchone():
            return jsonify({"error": "Game not found"}), 404
        
        # Insert new game stats (CHECK YOUR TABLE NAME!)
        query = """
            INSERT INTO GameStats 
            (gameID, playerID, minutes, points, rebounds, assists, steals, blocks, turnovers, fouls, three_pt)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        
        params = (
            data["gameID"],
            data["playerID"],
            data["minutes"],
            data["points"],
            data["rebounds"],
            data["assists"],
            data["steals"],
            data["blocks"],
            data["turnovers"],
            data["fouls"],
            data["three_pt"]
        )
        
        cursor.execute(query, params)
        db.get_db().commit()
        
        return jsonify({"message": "Game stats added successfully"}), 201
        
    except Error as e:
        if db.get_db():
            db.get_db().rollback()
        return jsonify({"error": str(e)}), 500
    finally:
        if cursor:
            cursor.close()
=======
players = Blueprint("players", __name__)
>>>>>>> origin/main
