from flask import Blueprint, jsonify, request
from backend.db_connection import db
from mysql.connector import Error
from flask import current_app

# Create a Blueprint for player routes
players = Blueprint("players", __name__)

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

# Get full profile information for a player
@players.route('/<int:player_id>/profile', methods=['GET'])
def get_player_profile(player_id):
    try:
        cursor = db.get_db().cursor()
        
        # Get full player profile with team information
        cursor.execute("""
            SELECT 
                p.playerID,
                p.firstName,
                p.lastName,
                p.email,
                p.dateOfBirth,
                p.age,
                p.phoneNumber,
                p.userBio,
                p.height,
                p.weight,
                p.acctStatus,
                p.position,
                p.teamID,
                t.teamName,
                t.city,
                t.teamAbbrev,
                t.league
            FROM Players p
            LEFT JOIN Teams t ON p.teamID = t.teamID
            WHERE p.playerID = %s
        """, (player_id,))
        
        profile = cursor.fetchone()
        cursor.close()
        
        if not profile:
            return jsonify({
                'success': False,
                'message': f'Player {player_id} not found'
            }), 404
        
        return jsonify({
            'success': True,
            'profile': {
                'playerID': profile['playerID'],
                'firstName': profile['firstName'],
                'lastName': profile['lastName'],
                'email': profile['email'],
                'dateOfBirth': profile['dateOfBirth'],
                'age': profile['age'],
                'phoneNumber': profile['phoneNumber'],
                'bio': profile['userBio'],
                'height': profile['height'],
                'weight': profile['weight'],
                'position': profile['position'],
                'acctStatus': profile['acctStatus'],
                'team': {
                    'teamID': profile['teamID'],
                    'teamName': profile['teamName'],
                    'city': profile['city'],
                    'teamAbbrev': profile['teamAbbrev'],
                    'league': profile['league']
                } if profile['teamID'] else None
            }
        }), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500


# Upload a new highlight video for a player
@players.route('/<int:player_id>/videos', methods=['POST'])
def upload_player_video(player_id):
    try:
        data = request.json
        cursor = db.get_db().cursor()
        
        # Validate that player exists
        cursor.execute("SELECT playerID, firstName, lastName FROM Players WHERE playerID = %s", (player_id,))
        player = cursor.fetchone()
        
        if not player:
            cursor.close()
            return jsonify({
                'success': False,
                'message': f'Player {player_id} not found'
            }), 404
        
        # Validate required fields
        if 'gameID' not in data or 'URL' not in data:
            cursor.close()
            return jsonify({
                'success': False,
                'message': 'gameID and URL are required fields'
            }), 400
        
        # Validate that game exists
        game_id = data.get('gameID')
        cursor.execute("SELECT gameID FROM Games WHERE gameID = %s", (game_id,))
        if not cursor.fetchone():
            cursor.close()
            return jsonify({
                'success': False,
                'message': f'Game {game_id} not found'
            }), 404
        
        # Validate that player was in this game
        cursor.execute("""
            SELECT playerID 
            FROM PlayerSchedules 
            WHERE playerID = %s AND gameID = %s
        """, (player_id, game_id))
        
        if not cursor.fetchone():
            cursor.close()
            return jsonify({
                'success': False,
                'message': f'Player {player_id} was not scheduled for game {game_id}'
            }), 400
        
        # Insert the footage record
        cursor.execute("""
            INSERT INTO Footage (gameID, URL, duration)
            VALUES (%s, %s, %s)
        """, (
            game_id,
            data.get('URL'),
            data.get('duration')
        ))
        
        footage_id = cursor.lastrowid
        db.get_db().commit()
        cursor.close()
        
        return jsonify({
            'success': True,
            'message': 'Highlight video uploaded successfully',
            'footage': {
                'footageID': footage_id,
                'gameID': game_id,
                'playerID': player_id,
                'URL': data.get('URL'),
                'duration': data.get('duration')
            }
        }), 201
        
    except Error as e:
        db.get_db().rollback()
        return jsonify({"error": str(e)}), 500

# players to get scout reports 
@players.route('/<int:player_id>/scout-reports', methods=['GET'])
def get_player_scout_reports(player_id):
    try:
        cursor = db.get_db().cursor()
        
        cursor.execute("SELECT playerID, firstName, lastName FROM Players WHERE playerID = %s", (player_id,))
        player = cursor.fetchone()
        
        if not player:
            cursor.close()
            return jsonify({'success': False, 'message': f'Player {player_id} not found'}), 404
        
        cursor.execute("""
            SELECT 
                pr.reportID, 
                pr.date, 
                pr.summary, 
                pr.strengths, 
                pr.weaknesses, 
                pr.grade 
            FROM PlayerReports pr 
            WHERE pr.playerID = %s 
            ORDER BY pr.date DESC
        """, (player_id,))
        
        reports = cursor.fetchall()
        cursor.close()
        
        return jsonify({
            'success': True, 
            'player': {
                'playerID': player['playerID'], 
                'firstName': player['firstName'], 
                'lastName': player['lastName']
            }, 
            'reportCount': len(reports), 
            'reports': reports
        }), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500