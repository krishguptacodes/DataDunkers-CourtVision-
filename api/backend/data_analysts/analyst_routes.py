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