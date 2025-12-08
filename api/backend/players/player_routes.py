from flask import Blueprint, jsonify, request
from backend.db_connection import db
from mysql.connector import Error
from flask import current_app

# Create a Blueprint for player routes
players = Blueprint("players", __name__)

# add new game stats 
@players.route('/<int:player_id>/game-stats', methods=['POST'])
def add_game_stats_for_player(player_id):
    try:
        data = request.json
        cursor = db.get_db().cursor()
        
        # Validate that player exists
        cursor.execute("SELECT playerID FROM Players WHERE playerID = %s", (player_id,))
        if not cursor.fetchone():
            cursor.close()
            return jsonify({
                'success': False,
                'message': f'Player {player_id} not found'
            }), 404
        
        # Validate that game exists
        game_id = data.get('gameID')
        cursor.execute("SELECT gameID FROM Games WHERE gameID = %s", (game_id,))
        if not cursor.fetchone():
            cursor.close()
            return jsonify({
                'success': False,
                'message': f'Game {game_id} not found'
            }), 404
        
        # Generate a new gameStatID (since it's part of composite primary key)
        cursor.execute("SELECT MAX(gameStatID) FROM GameStats")
        max_id = cursor.fetchone()[0]
        new_game_stat_id = (max_id or 0) + 1
        
        # Insert game statistics
        cursor.execute("""
            INSERT INTO GameStats 
            (gameStatID, gameID, playerID, minutes, points, rebounds, assists, 
             steals, blocks, turnovers, fouls, threePts)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            new_game_stat_id,
            game_id,
            player_id,
            data.get('minutes', 0),
            data.get('points', 0),
            data.get('rebounds', 0),
            data.get('assists', 0),
            data.get('steals', 0),
            data.get('blocks', 0),
            data.get('turnovers', 0),
            data.get('fouls', 0),
            data.get('threePts', 0)
        ))
        
        db.get_db().commit()
        cursor.close()
        
        return jsonify({
            'success': True,
            'message': 'Game statistics added successfully',
            'gameStatID': new_game_stat_id,
            'playerID': player_id,
            'gameID': game_id
        }), 201
        
    except Error as e:
        db.get_db().rollback()
        return jsonify({"error": str(e)}), 500

# add new game's stats for player 
@players.route('/<int:player_id>/game-stats', methods=['POST'])
def add_game_stats_for_player(player_id):
    try:
        data = request.json
        cursor = db.get_db().cursor()
        
        # Validate that player exists
        cursor.execute("SELECT playerID FROM Players WHERE playerID = %s", (player_id,))
        if not cursor.fetchone():
            cursor.close()
            return jsonify({
                'success': False,
                'message': f'Player {player_id} not found'
            }), 404
        
        # Validate that game exists
        game_id = data.get('gameID')
        cursor.execute("SELECT gameID FROM Games WHERE gameID = %s", (game_id,))
        if not cursor.fetchone():
            cursor.close()
            return jsonify({
                'success': False,
                'message': f'Game {game_id} not found'
            }), 404
        
        # Generate a new gameStatID (since it's part of composite primary key)
        cursor.execute("SELECT MAX(gameStatID) FROM GameStats")
        max_id = cursor.fetchone()[0]
        new_game_stat_id = (max_id or 0) + 1
        
        # Insert game statistics
        cursor.execute("""
            INSERT INTO GameStats 
            (gameStatID, gameID, playerID, minutes, points, rebounds, assists, 
             steals, blocks, turnovers, fouls, threePts)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            new_game_stat_id,
            game_id,
            player_id,
            data.get('minutes', 0),
            data.get('points', 0),
            data.get('rebounds', 0),
            data.get('assists', 0),
            data.get('steals', 0),
            data.get('blocks', 0),
            data.get('turnovers', 0),
            data.get('fouls', 0),
            data.get('threePts', 0)
        ))
        
        db.get_db().commit()
        cursor.close()
        
        return jsonify({
            'success': True,
            'message': 'Game statistics added successfully',
            'gameStatID': new_game_stat_id,
            'playerID': player_id,
            'gameID': game_id
        }), 201
        
    except Error as e:
        db.get_db().rollback()
        return jsonify({"error": str(e)}), 500

# Return all game stats for this player across the season
@players.route('/<int:player_id>/game-stats', methods=['GET'])
def get_game_stats_for_player(player_id):
    try:
        cursor = db.get_db().cursor(dictionary=True)
        
        # Validate that player exists
        cursor.execute("SELECT playerID FROM Players WHERE playerID = %s", (player_id,))
        if not cursor.fetchone():
            cursor.close()
            return jsonify({
                'success': False,
                'message': f'Player {player_id} not found'
            }), 404
        
        # Retrieve all game stats for this player, joined with game data
        cursor.execute("""
            SELECT 
                gs.gameStatID,
                gs.gameID,
                g.date,
                g.tournament,
                gs.minutes,
                gs.points,
                gs.rebounds,
                gs.assists,
                gs.steals,
                gs.blocks,
                gs.turnovers,
                gs.fouls,
                gs.threePts
            FROM GameStats gs
            JOIN Games g ON gs.gameID = g.gameID
            WHERE gs.playerID = %s
            ORDER BY g.date DESC
        """, (player_id,))
        
        stats = cursor.fetchall()
        cursor.close()
        
        return jsonify({
            'success': True,
            'playerID': player_id,
            'count': len(stats),
            'gameStats': stats
        }), 200

    except Error as e:
        return jsonify({"error": str(e)}), 500
