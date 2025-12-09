CourtVision - Basketball Scouting & Analytics Platform
A comprehensive basketball scouting platform connecting players, scouts, and analysts through real-time statistics tracking, video analysis, and data-driven insights.
Prerequisites

Docker Desktop
Git
(Optional) Python 3.11 with Anaconda/Miniconda

Quick Start

Clone the repository

bash   git clone <repository-url>
   cd courtvision

Start the application:

docker compose up -d

Access the app:

Web App: http://localhost:8501
API: http://localhost:4000
MySQL: localhost:3306

Project Structure
courtvision/
├── api/                  # Flask REST API
│   └── backend/          # Route handlers by role
├── app/                  # Streamlit frontend
│   └── src/pages/        # UI pages by role
├── database-files/       # SQL schema and seed data
└── compose.yaml          # Docker configuration
User Roles

Players - View stats, upload videos, manage profiles
Scouts - Write reports, annotate footage, track games
Analysts - Create dashboards, export data
Admins - Manage users, verify accounts, remove fraud

Key API Routes
Players (/players)

GET /{id}/profile - Get player profile
GET /{id}/game-stats - Get season statistics
POST /{id}/game-stats - Add game statistics
POST /{id}/videos - Upload highlight video
GET /{id}/scout-reports - Get scout feedback

Scouts (/scouts)

GET /players/{id}/videos - Get player videos
GET /players/{id}/future-games - Get upcoming games
POST /footage/{id}/annotations - Add video annotations

Admins (/admins)

PUT /players/{id}/update - Update player profile
PUT /scouts/{id}/update - Update scout profile
PUT /scouts/{id}/verify - Verify scout account
DELETE /players/{id}/remove - Remove player

Analysts (/analysts)

GET /dashboards - List all dashboards
GET /export-requests - List export requests
DELETE /dashboards/{id}/remove - Remove dashboard

Development
Start containers:
bashdocker compose up -d
View logs:
bashdocker compose logs -f api
Restart after changes:
bashdocker compose restart api
Update database schema:
bashdocker compose down -v
docker compose up -d
Access MySQL:
bashdocker exec -it mysql_db mysql -u root -p'courtvision_root_2024'
Important Tips

Hot Reloading - Code changes auto-reload. Click "Always Rerun" in Streamlit.
MySQL Container - SQL files in database-files/ run in alphabetical order on first creation.
Database Updates - Must recreate container with docker compose down -v to apply schema changes.
Check Logs - Use Docker Desktop or docker logs <container> to debug issues.

Testing
bash# Test player profile
curl http://localhost:4000/players/4/profile

# Add game stats
curl -X POST http://localhost:4000/players/4/game-stats \
  -H "Content-Type: application/json" \
  -d '{"gameID": 1, "points": 24, "rebounds": 8}'
Troubleshooting
Database connection error:
bashdocker exec -it mysql_db mysql -u root -p'courtvision_root_2024'
GRANT ALL PRIVILEGES ON courtvision.* TO 'courtvision_user'@'%';
FLUSH PRIVILEGES;
API not starting: Check docker logs web-api for syntax errors.
Reset everything: docker compose down -v && docker compose up -d
Team

Caitlin Heery - Backend Development
Sean - Player Features
Ryan Suri - Scout & Admin Features
Sara Chin - Analytics Features

Tech Stack
Flask • Streamlit • MySQL • Docker • PyMySQL
