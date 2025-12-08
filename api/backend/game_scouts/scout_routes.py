from flask import Blueprint, jsonify, request
from backend.db_connection import db
from mysql.connector import Error
from flask import current_app

# Create a Blueprint for NGO routes
scouts = Blueprint("scouts", __name__)

# Returns player stats that were recommended by the data analyst scout
@scouts.route("/players/<int:playerID>/stats/filtered", methods=["GET"])
def get_filtered_player_stats(playerID):
    try:
        cursor = db.get_db().cursor()
        # Get recommended players with their stats based on scout reports
        cursor.execute("""
            SELECT DISTINCT
                p.playerID,
                p.firstname,
                p.lastname,
                p.height,
                p.weight,
                ps.rebPerGame,
                ps.ptsPerGame,
                ps.astPerGame,
                d.metricDisplayed
            FROM Players p
                JOIN PlayerStats ps ON p.playerID = ps.playerID
                JOIN Exports e ON e.playerID = p.playerID
                JOIN ExportRequests er ON e.exportID = er.exportID
                JOIN MetricExports me ON me.exportID = e.exportID
                JOIN MetricFormula mf ON mf.formulaID = me.formulaID
                JOIN CalculatedMetrics cm ON cm.formulaID = mf.formulaID
                JOIN DashboardMetrics dm ON dm.metricID = cm.metricID
                JOIN Dashboard d ON d.dashboardID = dm.dashboardID
            WHERE p.playerID = %s AND d.recommendation = 'yes'
        """, (playerID,))
        
        stats = cursor.fetchall()
        cursor.close()
        
        if not stats:
            return jsonify({"message": "No recommended stats found for this player"}), 404
            
        return jsonify(stats), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500


# Get all uploaded highlight videos for this player 
@scouts.route("/players/<int:playerID>/videos", methods=["GET"])
def get_player_videos(playerID):
    try:
        cursor = db.get_db().cursor()
        
        # Check if player exists 
        cursor.execute("SELECT * FROM Players WHERE playerID = %s", (playerID,))
        if not cursor.fetchone():
            cursor.close()
            return jsonify({"error": "Player not found"}), 404
            
        # Get all highlight videos for this player
        cursor.execute("""
            SELECT
                f.footageID,
                p.playerID,
                f.gameID,
                f.URL
            FROM Footage f
                JOIN Annotations a ON f.footageID = a.footageID
                JOIN PlayerReports pr ON a.reportID = pr.reportID
                JOIN Players p ON pr.playerID = p.playerID
            WHERE p.playerID = %s
            ORDER BY f.gameID DESC, f.footageID DESC
        """, (playerID,))
        
        videos = cursor.fetchall()
        cursor.close()
        
        if not videos:
            return jsonify({"message": "No videos found for this player"}), 200
            
        return jsonify(videos), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500

        
