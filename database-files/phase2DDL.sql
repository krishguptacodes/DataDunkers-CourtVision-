DROP DATABASE IF EXISTS courtvision;
CREATE DATABASE courtvision;
USE courtvision;

DROP TABLE IF EXISTS CalculatedMetrics;
DROP TABLE IF EXISTS Annotations;
DROP TABLE IF EXISTS PlayerReports;
DROP TABLE IF EXISTS ScoutActivity;
DROP TABLE IF EXISTS GameStats;
DROP TABLE IF EXISTS PlayerStats;
DROP TABLE IF EXISTS SeasonStats;
DROP TABLE IF EXISTS PlayerSchedule;
DROP TABLE IF EXISTS ScheduledFor;
DROP TABLE IF EXISTS Footage;
DROP TABLE IF EXISTS RecruitingInterest;
DROP TABLE IF EXISTS Offers;
DROP TABLE IF EXISTS Verifications;
DROP TABLE IF EXISTS ExportRequests;
DROP TABLE IF EXISTS Reports;
DROP TABLE IF EXISTS PlaysIn;
DROP TABLE IF EXISTS Dashboard;
DROP TABLE IF EXISTS DashboardMetrics;
DROP TABLE IF EXISTS MetricsFormulas;
DROP TABLE IF EXISTS SystemAdmin;
DROP TABLE IF EXISTS Scouts;
DROP TABLE IF EXISTS ScoutViewStats;
DROP TABLE IF EXISTS Games;
DROP TABLE IF EXISTS Schools;
DROP TABLE IF EXISTS Teams;
DROP TABLE IF EXISTS Players;
 
-- INDEPENDENT

-- Players Table
CREATE TABLE Players (
    playerID INT AUTO_INCREMENT PRIMARY KEY,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    dateOfBirth DATE,
    age INT,
    phoneNumber VARCHAR(20),
    userBio TEXT,
    height INT,
    `weight` INT,
    acctStatus VARCHAR(20) DEFAULT 'active',
    position VARCHAR(20),
    teamID INT,
    CONSTRAINT fk_players_team
        FOREIGN KEY (teamID) REFERENCES Teams(teamID)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    INDEX idx_player_name (lastName, firstName),
    INDEX idx_player_email (email),
    INDEX idx_player_team (teamID)
);

-- Team Table
CREATE TABLE Teams (
    teamID INT AUTO_INCREMENT PRIMARY KEY,
    teamName VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    teamAbbrev VARCHAR(10),
    league VARCHAR(50),
    INDEX idx_team_name (teamName)
);

-- School Table
CREATE TABLE Schools (
    schoolID INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    `state` VARCHAR(50)
);

-- Game Table
CREATE TABLE Games (
    gameID INT AUTO_INCREMENT PRIMARY KEY,
    `date` DATE NOT NULL,
    startTime TIME,
    endTime TIME,
    opponent VARCHAR(100),
    venue VARCHAR(100),
    tournament VARCHAR(100),
    score VARCHAR(20)
);

-- Scout Table
CREATE TABLE Scouts (
    scoutID INT AUTO_INCREMENT PRIMARY KEY,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    dateOfBirth DATE,
    age INT,
    phoneNum VARCHAR(20),
    acctStatus VARCHAR(20) DEFAULT 'active',
    `role` VARCHAR(50)
);

-- SystemAdmin Table
CREATE TABLE SystemAdmin (
    adminID INT AUTO_INCREMENT PRIMARY KEY,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    adminLvl VARCHAR(20),
    acctStatus VARCHAR(20) DEFAULT 'active',
    dept VARCHAR(50)
);

-- Dashboard Table
CREATE TABLE Dashboard (
    dashboardID INT AUTO_INCREMENT PRIMARY KEY,
    dashboardName VARCHAR(100),
    metricDisplayed VARCHAR(100),
    chartType VARCHAR(50),
    lastUpdated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    filterCriteria TEXT,
    recommendation TEXT
);

-- MetricFormula Table
CREATE TABLE MetricFormula (
    formulaID INT AUTO_INCREMENT PRIMARY KEY,
    formulaName VARCHAR(100) NOT NULL,
    createdBy TEXT,
    dateCreated DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ExportRequest Table
CREATE TABLE ExportRequests (
    exportID INT AUTO_INCREMENT PRIMARY KEY,
    format VARCHAR(20),
    `timestamp` DATETIME DEFAULT CURRENT_TIMESTAMP,
    player VARCHAR(20)
);

-- JUNCTION TABLES (M:N Relationships)

-- Playsin - Players to Teams (M:N)
CREATE TABLE PlaysIn (
    teamID INT NOT NULL,
    gameID INT NOT NULL,
    PRIMARY KEY (teamID, gameID),
    CONSTRAINT fk_playsin_team
        FOREIGN KEY (teamID) REFERENCES Teams(teamID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_playsin_game
        FOREIGN KEY (gameID) REFERENCES Games(gameID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    INDEX idx_playsin_team (teamID),
    INDEX idx_playsin_game (gameID)
);

-- PlayerSchedule - Players to Games (M:N)
CREATE TABLE PlayerSchedules (
    playerID INT NOT NULL,
    gameID INT NOT NULL,
    PRIMARY KEY (playerID, gameID),
    CONSTRAINT fk_playersched_player
        FOREIGN KEY (playerID) REFERENCES Players(playerID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_playersched_game
        FOREIGN KEY (gameID) REFERENCES Games(gameID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- Scout_Activity - Scouts to Games (M:N)
CREATE TABLE ScoutActivity (
    scoutID INT NOT NULL,
    gameID INT NOT NULL,
    PRIMARY KEY (scoutID, gameID),
    CONSTRAINT fk_scoutactivity_scout
        FOREIGN KEY (scoutID) REFERENCES Scouts(scoutID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_scoutactivity_game
        FOREIGN KEY (gameID) REFERENCES Games(gameID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ScheduledFor - Games to Teams (M:N)
CREATE TABLE ScheduledFor (
    gameID INT NOT NULL,
    teamID INT NOT NULL,
    PRIMARY KEY (gameID, teamID),
    CONSTRAINT fk_scheduled_game
        FOREIGN KEY (gameID) REFERENCES Games(gameID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_scheduled_team
        FOREIGN KEY (teamID) REFERENCES Teams(teamID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- RecruitingInterest - Players to Schools (M:N)
CREATE TABLE RecruitingInterests (
    playerID INT NOT NULL,
    schoolID INT NOT NULL,
    PRIMARY KEY (playerID, schoolID),
    CONSTRAINT fk_recruiting_player
        FOREIGN KEY (playerID) REFERENCES Players(playerID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_recruiting_school
        FOREIGN KEY (schoolID) REFERENCES Schools(schoolID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    INDEX idx_recruiting_player (playerID),
    INDEX idx_school_recruiting (schoolID)
);


-- DEPENDENT TABLES (Stats and Reports)
 

-- SeasonStats - Player season statistics
CREATE TABLE SeasonStats (
    seasonStatID INT NOT NULL,
    playerID INT NOT NULL,
    season VARCHAR(20) NOT NULL,
    gamesPlayed INT,
    totalMinsPlayed INT,
    avgPts DECIMAL(5,2),
    ptsPerGame DECIMAL(5,2),
    rebPerGame DECIMAL(5,2),
    astPerGame DECIMAL(5,2),
    avgRebounds DECIMAL(5,2),
    avgAsts DECIMAL(5,2),
    threePointers INT,
    threePPercent DECIMAL(5,2),
    fieldGoalPercent DECIMAL(5,2),
    freeThrowPercent DECIMAL(5,2),
    PRIMARY KEY (seasonStatID, playerID),
    CONSTRAINT fk_season_player
        FOREIGN KEY (playerID) REFERENCES Players(playerID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    INDEX idx_season_player (playerID)
);

-- PlayerStats - Player stats per team
CREATE TABLE PlayerStats (
    statsID INT AUTO_INCREMENT PRIMARY KEY,
    playerID INT NOT NULL,
    ptsPerGame DECIMAL(5,2),
    rebPerGame DECIMAL(5,2),
    astPerGame DECIMAL(5,2),
    CONSTRAINT fk_playerstats_player
        FOREIGN KEY (playerID) REFERENCES Players(playerID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    INDEX idx_stats_player (playerID)
);

-- GameStats - Player stats per game
CREATE TABLE GameStats (
    gameStatID INT NOT NULL,
    gameID INT NOT NULL,
    playerID INT NOT NULL,
    `minutes` INT,
    points INT,
    rebounds INT,
    assists INT,
    steals INT,
    blocks INT,
    turnovers INT,
    fouls INT,
    threePts INT,
    PRIMARY KEY (gameStatID, gameID, playerID),  -- Composite PK
    UNIQUE KEY unique_gameStatID (gameStatID),
    CONSTRAINT fk_gamestats_game
        FOREIGN KEY (gameID) REFERENCES Games(gameID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_gamestats_player
        FOREIGN KEY (playerID) REFERENCES Players(playerID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    INDEX idx_gamestats_game (gameID),
    INDEX idx_gamestats_player (playerID)
);

-- PlayerReports - Scout reports on players
CREATE TABLE PlayerReports (
    reportID INT AUTO_INCREMENT PRIMARY KEY,
    playerID INT NOT NULL,
    summary TEXT,
    `date` DATE,
    strengths TEXT,
    weaknesses TEXT,
    grade TEXT,
    CONSTRAINT fk_playerreport_player
        FOREIGN KEY (playerID) REFERENCES Players(playerID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    INDEX idx_report_player (playerID)
);

-- Offers - School offers to players
CREATE TABLE Offers (
    offerID INT AUTO_INCREMENT PRIMARY KEY,
    playerID INT NOT NULL,
    schoolID INT NOT NULL,
    `status` VARCHAR(20) DEFAULT 'pending',
    `date` DATE,
    CONSTRAINT fk_offers_player
        FOREIGN KEY (playerID) REFERENCES Players(playerID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_offers_school
        FOREIGN KEY (schoolID) REFERENCES Schools(schoolID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    INDEX idx_offer_player (playerID),
    INDEX idx_offer_school (schoolID)
);

-- Footage - Game footage/video
CREATE TABLE Footage (
    footageID INT AUTO_INCREMENT PRIMARY KEY,
    gameID INT NOT NULL,
    `URL` VARCHAR(255) NOT NULL,
    duration INT,
    CONSTRAINT fk_footage_game
        FOREIGN KEY (gameID) REFERENCES Games(gameID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    INDEX idx_footage_game (gameID)
);

-- Annotations - Notes/timestamps on footage
CREATE TABLE Annotations (
    annotationID INT AUTO_INCREMENT PRIMARY KEY,
    reportID INT,
    annotatedBy INT,
    `timestamp` TIME,
    `text` TEXT,
    footageID INT,
    CONSTRAINT fk_annotations_report
        FOREIGN KEY (reportID) REFERENCES PlayerReports(reportID)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_annotations_footage
        FOREIGN KEY (footageID) REFERENCES Footage(footageID)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- CalculatedMetrics - Metrics calculated from formulas
CREATE TABLE CalculatedMetrics (
    metricID INT NOT NULL,
    formulaID INT NOT NULL,
    formulaName VARCHAR(100),
    gameID INT NOT NULL,
    calcTimestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (metricID, formulaID),
    CONSTRAINT fk_calcmetrics_game
        FOREIGN KEY (gameID) REFERENCES Games(gameID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_calcmetrics_formula
        FOREIGN KEY (formulaID) REFERENCES MetricFormula(formulaID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    INDEX idx_metric_game (gameID),
    INDEX idx_metric_formula (formulaID)
);

-- DashboardMetrics - Links dashboards to calculated metrics
CREATE TABLE DashboardMetrics (
    dashboardID INT NOT NULL,
    metricID INT NOT NULL,
    PRIMARY KEY (dashboardID, metricID),
    CONSTRAINT fk_dashmetrics_dashboard
        FOREIGN KEY (dashboardID) REFERENCES Dashboard(dashboardID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_dashmetrics_metric
        FOREIGN KEY (metricID) REFERENCES CalculatedMetrics(metricID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- Reports - Tracking reported users/content
CREATE TABLE Reports (
    reportID INT AUTO_INCREMENT PRIMARY KEY,
    adminID INT NOT NULL,
    repStatus VARCHAR(20) DEFAULT 'pending',
    userReported VARCHAR(20),
    `date` DATETIME,
    CONSTRAINT fk_userreported_reviewer
        FOREIGN KEY (adminID) REFERENCES SystemAdmin(adminID)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- Validation - Stat account verification
CREATE TABLE Validations (
    validationID INT AUTO_INCREMENT PRIMARY KEY,
    `status` VARCHAR(20),
    `timestamp` TIMESTAMP,
    reqDate DATE,
    responseDate DATE,
    gameStatID INT NOT NULL,
    CONSTRAINT fk_validation_gamestat
        FOREIGN KEY (gameStatID) REFERENCES GameStats(gameStatID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- Verifications - User verification records
CREATE TABLE Verifications (
    reqID INT AUTO_INCREMENT PRIMARY KEY,
    playerID INT NOT NULL,
    CONSTRAINT fk_validation_admin
        FOREIGN KEY (playerID) REFERENCES Players(playerID)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- Exports - Completed export files
CREATE TABLE Exports (
    playerID INT NOT NULL,
    exportID INT NOT NULL,
    PRIMARY KEY (playerID, exportID),
    CONSTRAINT fk_exports_player
        FOREIGN KEY (playerID) REFERENCES Players(playerID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_exports_request
        FOREIGN KEY (exportID) REFERENCES ExportRequests(exportID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- Metric_Export - Junction table linking MetricsFormulas to Exports
CREATE TABLE MetricExports (
    formulaID INT NOT NULL,
    exportID INT NOT NULL,
    PRIMARY KEY (formulaID, exportID),
    CONSTRAINT fk_metricexport_formula
        FOREIGN KEY (formulaID) REFERENCES MetricFormula(formulaID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_metricexport_export
        FOREIGN KEY (exportID) REFERENCES Exports(exportID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE ScoutViewStats (
    scoutID INT NOT NULL,
    statsID INT NOT NULL,
    PRIMARY KEY (scoutID, statsID),
    CONSTRAINT fk_statview_scout
        FOREIGN KEY (scoutID) REFERENCES Scouts(scoutID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_statview_stats
        FOREIGN KEY (statsID) REFERENCES PlayerStats(statsID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
# SAMPLE DATA

SHOW TABLES;

USE courtvision;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE MetricExports;
TRUNCATE TABLE Exports;
TRUNCATE TABLE Reports;
TRUNCATE TABLE DashboardMetrics;
TRUNCATE TABLE CalculatedMetrics;
TRUNCATE TABLE Annotations;
TRUNCATE TABLE Footage;
TRUNCATE TABLE Offers;
TRUNCATE TABLE PlayerReports;
TRUNCATE TABLE GameStats;
TRUNCATE TABLE PlayerStats;
TRUNCATE TABLE SeasonStats;
TRUNCATE TABLE RecruitingInterests;
TRUNCATE TABLE ScheduledFor;
TRUNCATE TABLE ScoutActivity;
TRUNCATE TABLE PlayerSchedules;
TRUNCATE TABLE PlaysIn;
TRUNCATE TABLE ExportRequests;
TRUNCATE TABLE MetricFormula;
TRUNCATE TABLE Dashboard;
TRUNCATE TABLE Verifications;
TRUNCATE TABLE `Validations`;
TRUNCATE TABLE Reports;
TRUNCATE TABLE Scouts;
TRUNCATE TABLE SystemAdmin;
TRUNCATE TABLE Games;
TRUNCATE TABLE Schools;
TRUNCATE TABLE Teams;
TRUNCATE TABLE Players;

SET FOREIGN_KEY_CHECKS = 1;

-- Players
INSERT INTO Players (firstName, lastName, email, phoneNumber, userBio, dateOfBirth, height, weight, acctStatus) VALUES
('LeBron', 'James', 'lebron.james@email.com', '555-0101', 'Experienced forward with strong leadership skills', '2003-12-30', 78, 250, 'active'),
('Stephen', 'Curry', 'steph.curry@email.com', '555-0102', 'Elite shooter, excellent ball handler', '2004-03-14', 75, 185, 'active'),
('Kevin', 'Durant', 'kd@email.com', '555-0103', 'Versatile scorer, 7-foot forward', '2003-09-29', 82, 240, 'active'),
('Giannis', 'Antetokounmpo', 'giannis@email.com', '555-0104', 'Athletic forward, defensive specialist', '2004-12-06', 83, 242, 'active'),
('Luka', 'Doncic', 'luka.doncic@email.com','555-0105', 'Young talent, excellent court vision', '2005-02-28', 79, 230, 'active');

-- Teams
INSERT INTO Teams (teamName, city, teamAbbrev, league) VALUES
('Lakers', 'Los Angeles', 'LAL', 'AAU'),
('Warriors', 'Oakland', 'GSW', 'AAU'),
('Nets', 'Brooklyn', 'BKN', 'AAU'),
('Bucks', 'Milwaukee', 'MIL', 'NBA'),
('Celtics', 'Boston', 'BOS', 'NBA');

-- Schools
INSERT INTO Schools (name, city, state) VALUES
('Duke University', 'Durham', 'NC'),
('University of Kentucky', 'Lexington', 'KY');

-- Games
INSERT INTO Games (date, startTime, endTime, opponent, venue, tournament, score) VALUES
('2024-11-15', '18:00:00', '20:00:00', 'Warriors', 'Staples Center', 'AAU Championship', '95-88'),
('2024-11-16', '19:00:00', '21:00:00', 'Nets', 'Barclays Center', 'AAU Championship', '102-98');

-- Scouts
INSERT INTO Scouts (firstName, lastName, email, dateOfBirth, age, phoneNum, acctStatus, role) VALUES
('Michael', 'Thompson', 'mthompson@scout.com', '1985-04-12', 38, '657-555-1001', 'active', 'Senior Scout'),
('Sarah', 'Johnson', 'sjohnson@scout.com', '1990-08-22', 33, '433-555-1002', 'active', 'Regional Scout');

-- SystemAdmins
INSERT INTO SystemAdmin (firstName, lastName, email, dept, acctStatus) VALUES
('John', 'Anderson', 'jadmin@courtvision.com', 'IT', 'active'),
('Lisa', 'Chen', 'lchen@courtvision.com', 'Operations', 'active');

-- Dashboards
INSERT INTO Dashboard (dashboardName, metricDisplayed, chartType, filterCriteria) VALUES
('Player Performance Overview', 'Points Per Game', 'Bar Chart', 'season=2024'),
('Team Analytics', 'Win Rate', 'Line Chart', 'league=AAU');

-- Metric formulas
INSERT INTO MetricFormula (formulaName, createdBy, dateCreated) VALUES
('Player Efficiency Rating', 'System', '2024-01-15 10:00:00'),
('True Shooting Percentage', 'System', '2024-01-15 10:30:00');

-- Export requests
INSERT INTO ExportRequests (format, timestamp, player) VALUES
('CSV', '2024-11-20 15:30:00', 'Player 1'),
('PDF', '2024-11-21 10:00:00', 'Player 2');

-- =========================
-- Relationships / junctions
-- =========================

-- Teams play in games
INSERT INTO PlaysIn (teamID, gameID) VALUES
(1, 1), (1, 2),
(2, 1), (2, 2);

-- Player schedule (only existing games)
INSERT INTO PlayerSchedules (playerID, gameID) VALUES
(1, 1), (1, 2),
(2, 1), (2, 2);

-- Scout activity (only existing games)
INSERT INTO ScoutActivity (scoutID, gameID) VALUES
(1, 1),
(1, 2),
(2, 2);

-- Games scheduled for teams (only valid game/team IDs)
INSERT INTO ScheduledFor (gameID, teamID) VALUES
(1, 1), (1, 2),
(2, 3), (2, 4);

-- Recruiting interest (only valid school IDs)
INSERT INTO RecruitingInterests (playerID, schoolID) VALUES
(1, 1),
(1, 2),
(2, 2);

-- =========================
-- Stats tables
-- =========================

-- Season stats
INSERT INTO SeasonStats (seasonStatID, playerID, season, gamesPlayed, totalMinsPlayed, avgPts, ptsPerGame, rebPerGame, astPerGame, avgRebounds, avgAsts, threePointers, threePPercent, fieldGoalPercent, freeThrowPercent) VALUES
(1, 1, '2024', 25, 800, 28.5, 28.5, 8.2, 7.1, 8.2, 7.1, 45, 36.5, 51.2, 78.5),
(2, 2, '2024', 28, 900, 32.1, 32.1, 5.1, 6.8, 5.1, 6.8, 120, 43.2, 48.7, 91.3);

-- Player stats
INSERT INTO PlayerStats (playerID, ptsPerGame, rebPerGame, astPerGame) VALUES
(1, 28.5, 8.2, 7.1),
(2, 32.1, 5.1, 6.8);

-- Game stats
INSERT INTO GameStats (gameStatID, gameID, playerID, minutes, points, rebounds, assists, steals, blocks, turnovers, fouls, threePts) VALUES
(1, 1, 1, 35, 32, 9, 8, 2, 1, 3, 2, 2),
(2, 1, 2, 38, 28, 5, 7, 1, 0, 2, 2, 5),
(3, 1, 3, 28, 19, 4, 6, 1, 0, 2, 3, 3);

-- =========================
-- Scouting / reports / offers
-- =========================

-- Player scouting reports
INSERT INTO PlayerReports (playerID, summary, date, strengths, weaknesses, grade) VALUES
(1, 'Elite all-around player with NBA-ready skills', '2024-11-01', 'Leadership, basketball IQ, versatility', 'Three-point consistency', 'A'),
(2, 'Best shooter in the class, elite range', '2024-11-02', 'Shooting, ball handling', 'Defensive intensity, size', 'A-'),
(3, 'Skilled scorer with length advantage', '2024-11-03', 'Shooting, length', 'Lateral quickness on defense', 'B+');

-- Offers (only valid school IDs)
INSERT INTO Offers (playerID, schoolID, status, date) VALUES
(1, 1, 'accepted', '2024-10-01'),
(2, 2, 'pending', '2024-10-05');

-- System-level reports
INSERT INTO Reports (adminID, repStatus, userReported, date) VALUES
(1, 'completed', 'Player 5', '2024-11-15'),
(2, 'pending', 'Scout 3', '2024-11-20');

-- Footage
INSERT INTO Footage (gameID, URL, duration) VALUES
(1, 'https://footage.courtvision.com/game1_player1.mp4', 180),
(1, 'https://footage.courtvision.com/game1_player2.mp4', 165);

-- Annotations
INSERT INTO Annotations (reportID, timestamp, text) VALUES
(1, '00:05:23', 'Excellent defensive possession'),
(1, '00:12:45', 'Great court vision on assist');

-- Calculated metrics
INSERT INTO CalculatedMetrics (metricID, formulaID, formulaName, gameID, calcTimestamp) VALUES
(1, 1, 'Player Efficiency Rating', 1, '2024-11-15 22:00:00'),
(2, 1, 'Player Efficiency Rating', 1, '2024-11-15 22:00:00');

-- Dashboard ↔ metrics
INSERT INTO DashboardMetrics (dashboardID, metricID) VALUES
(1, 1),
(1, 2);

-- Validations
INSERT INTO Validations (status, timestamp, reqDate, responseDate, gameStatID) VALUES
('approved', '2024-11-16 10:00:00', '2024-11-15', '2024-11-16', 1);

-- Verifications
INSERT INTO Verifications (playerID) VALUES
(1),
(2);

-- Exports
INSERT INTO Exports (playerID, exportID) VALUES
(1, 1),
(2, 2);

-- Metric_Export
INSERT INTO MetricExports (formulaID, exportID) VALUES
(1, 1),
(2, 1);

-- ScoutViewStats
INSERT INTO ScoutViewStats (scoutID, statsID) VALUES
(1, 1),
(1, 2),
(2, 1);

SHOW TABLES;
SELECT * FROM Players;
SELECT * FROM GameStats;
