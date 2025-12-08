from flask import Blueprint, jsonify, request
from backend.db_connection import db
from mysql.connector import Error
from flask import current_app

# Create a Blueprint for NGO routes
analysts = Blueprint("analysts", __name__)

# remove a player for fraud 
@players.route('/players/<int:playerID>/remove', methods=['DELETE'])
def remove_player_fraud(playerID):
    try:
        cursor = db.get_db().cursor()
        
        # First check if player exists
        cursor.execute("SELECT * FROM Players WHERE playerID = %s", (playerID,))
        player = cursor.fetchone()
        
        if not player:
            cursor.close()
            return jsonify({"error": "Player not found"}), 404
        
        # Log the removal reason (you might want a separate audit table)
        cursor.execute("""
            INSERT INTO Reports (adminID, repStatus, userReported, date)
            VALUES (%s, 'completed', %s, NOW())
        """, (3, f"Player {playerID} - Fraud/Misinformation"))  

        cursor.execute("DELETE FROM Players WHERE playerID = %s", (playerID,))
        
        db.get_db().commit()
        cursor.close()
        
        return jsonify({
            "success": True,
            "message": f"Player {playerID} removed for fraud/misinformation"
        }), 200
        
    except Error as e:
        db.get_db().rollback()
        return jsonify({"error": str(e)}), 500

