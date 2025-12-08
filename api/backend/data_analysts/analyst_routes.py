from flask import Blueprint, jsonify, request
from backend.db_connection import db
from mysql.connector import Error
from flask import current_app

# Create a Blueprint for NGO routes
analysts = Blueprint("analysts", __name__)

# list of dashboard with names, metrics displayed, and last updated timestamp
@analysts.route('/dashboards', methods=['GET'])
def get_all_dashboards():
    try:
        cursor = db.get_db().cursor()
        
        cursor.execute("""
            SELECT 
                dashboardID,
                dashboardName,
                metricDisplayed,
                lastUpdated,
                chartType,
                recommendation
            FROM Dashboard
            ORDER BY lastUpdated DESC
        """)
        
        dashboards = cursor.fetchall()
        cursor.close()
        
        # Format the response
        dashboard_list = []
        for dashboard in dashboards:
            dashboard_list.append({
                'dashboardID': dashboard[0],
                'dashboardName': dashboard[1],
                'metricDisplayed': dashboard[2],
                'lastUpdated': dashboard[3].strftime('%Y-%m-%d %H:%M:%S') if dashboard[3] else None,
                'chartType': dashboard[4],
                'recommendation': dashboard[5]
            })
        
        return jsonify({
            'success': True,
            'count': len(dashboard_list),
            'dashboards': dashboard_list
        }), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500

# removing a dashboard 
@analysts.route('/dashboards/<int:dashboardID>/remove', methods=['DELETE'])
def remove_dashboard(dashboardID):
    try:
        cursor = db.get_db().cursor()
        
        # Check if dashboard exists
        cursor.execute("SELECT dashboardName FROM Dashboard WHERE dashboardID = %s", (dashboardID,))
        dashboard = cursor.fetchone()
        
        if not dashboard:
            cursor.close()
            return jsonify({"error": "Dashboard not found"}), 404
        
        dashboard_name = dashboard[0]
        
        # Delete dashboard (cascades to DashboardMetrics due to FK constraints)
        cursor.execute("DELETE FROM Dashboard WHERE dashboardID = %s", (dashboardID,))
        
        # Log the deletion
        cursor.execute("""
            INSERT INTO Reports (adminID, repStatus, userReported, date)
            VALUES (%s, 'completed', %s, NOW())
        """, (3, f"Deleted dashboard: {dashboard_name} (ID: {dashboardID})"))
        
        db.get_db().commit()
        cursor.close()
        
        return jsonify({
            "success": True,
            "message": f"Dashboard '{dashboard_name}' has been removed"
        }), 200
        
    except Error as e:
        db.get_db().rollback()
        return jsonify({"error": str(e)}), 500


@analysts.route('/players/statistics', methods=['GET'])
def get_filtered_player_stats():
    """
    Return full list of player statistics with filtering
    Tukey - Advanced filtering by season, position, team, and statistical thresholds
    """
    try:
        # Get query parameters
        season = request.args.get('season')
        position = request.args.get('position')
        team_id = request.args.get('team_id', type=int)
        min_ppg = request.args.get('min_ppg', type=float)
        max_ppg = request.args.get('max_ppg', type=float)
        min_rpg = request.args.get('min_rpg', type=float)
        min_apg = request.args.get('min_apg', type=float)
        
        cursor = db.get_db().cursor()
        
        # Build dynamic query
        query = """
            SELECT 
                p.playerID,
                p.firstName,
                p.lastName,
                p.position,
                p.height,
                p.weight,
                t.teamName,
                ps.ptsPerGame,
                ps.rebPerGame,
                ps.astPerGame,
                ss.season,
                ss.gamesPlayed,
                ss.fieldGoalPercent,
                ss.threePPercent
            FROM Players p
            LEFT JOIN Teams t ON p.teamID = t.teamID
            LEFT JOIN PlayerStats ps ON p.playerID = ps.playerID
            LEFT JOIN SeasonStats ss ON p.playerID = ss.playerID
            WHERE 1=1
        """
        
        params = []
        
        # Add filters dynamically
        if season:
            query += " AND ss.season = %s"
            params.append(season)
            
        if position:
            query += " AND p.position = %s"
            params.append(position)
            
        if team_id:
            query += " AND p.teamID = %s"
            params.append(team_id)
            
        if min_ppg:
            query += " AND ps.ptsPerGame >= %s"
            params.append(min_ppg)
            
        if max_ppg:
            query += " AND ps.ptsPerGame <= %s"
            params.append(max_ppg)
            
        if min_rpg:
            query += " AND ps.rebPerGame >= %s"
            params.append(min_rpg)
            
        if min_apg:
            query += " AND ps.astPerGame >= %s"
            params.append(min_apg)
        
        query += " ORDER BY ps.ptsPerGame DESC"
        
        cursor.execute(query, params)
        results = cursor.fetchall()
        cursor.close()
        
        # Format response
        players = []
        for row in results:
            players.append({
                'playerID': row[0],
                'name': f"{row[1]} {row[2]}",
                'position': row[3],
                'height': row[4],
                'weight': row[5],
                'team': row[6],
                'ptsPerGame': float(row[7]) if row[7] else 0,
                'rebPerGame': float(row[8]) if row[8] else 0,
                'astPerGame': float(row[9]) if row[9] else 0,
                'season': row[10],
                'gamesPlayed': row[11],
                'fieldGoalPercent': float(row[12]) if row[12] else 0,
                'threePointPercent': float(row[13]) if row[13] else 0
            })
        
        return jsonify({
            'success': True,
            'count': len(players),
            'filters_applied': {
                'season': season,
                'position': position,
                'team_id': team_id,
                'min_ppg': min_ppg,
                'max_ppg': max_ppg,
                'min_rpg': min_rpg,
                'min_apg': min_apg
            },
            'players': players
        }), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500

# returns export details with download URL
@analysts.route('/exports/<int:exportID>', methods=['GET'])
def get_export_details(exportID):
    try:
        cursor = db.get_db().cursor()
        
        # Get basic export info
        cursor.execute("""
            SELECT exportID, format, timestamp, player
            FROM ExportRequests 
            WHERE exportID = %s
        """, (exportID,))
        
        export_info = cursor.fetchone()
        cursor.close()
        
        if not export_info:
            return jsonify({"error": "Export not found"}), 404
        
        # Simple formatted response with just download URL
        return jsonify({
            "exportID": export_info[0],
            "format": export_info[1],
            "downloadURL": f"http://localhost:4000/analysts/exports/{exportID}/download"
        }), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500

# list of data export requets
@analysts.route('/export-requests', methods=['GET'])
def get_export_requests():
    try:
        cursor = db.get_db().cursor()
        cursor.execute("""
            SELECT 
                exportID,
                format,
                timestamp,
                player
            FROM ExportRequests
            ORDER BY timestamp DESC
        """)
        export_requests = cursor.fetchall()
        cursor.close()
        
        export_list = []
        for row in export_requests:
            export_list.append({
                'exportID': row[0],
                'format': row[1],
                'timestamp': row[2].strftime('%Y-%m-%d %H:%M:%S') if row[2] else None,
                'player': row[3]
            })
        
        return jsonify(export_list), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500

# get dashboard metrics 
@analysts.route('/dashboard-metrics', methods=['GET'])
def get_dashboard_metrics():
    try:
        cursor = db.get_db().cursor()
        cursor.execute("""
            SELECT 
                metricID,
                dashboardID
            FROM DashboardMetrics
            ORDER BY dashboardID, metricID
        """)
        
        metrics = cursor.fetchall()
        cursor.close()
        
        metrics_list = []
        for row in metrics:
            metrics_list.append({
                'metricID': row[0],
                'dashboardID': row[1]
            })
        
        return jsonify(metrics_list), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500