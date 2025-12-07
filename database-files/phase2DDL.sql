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
    statsID INT NOT NULL,
    playerID INT NOT NULL,
    ptsPerGame DECIMAL(5,2),
    rebPerGame DECIMAL(5,2),
    astPerGame DECIMAL(5,2),
    PRIMARY KEY (statsID, playerID),
    UNIQUE KEY unique_statID (statsID),
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

-- Validations - Stat account validations
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
    adminID INT NOT NULL,
    CONSTRAINT fk_verification_player
        FOREIGN KEY (playerID) REFERENCES Players(playerID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
     CONSTRAINT fk_verification_admin
        FOREIGN KEY (adminID) REFERENCES SystemAdmin(adminID)
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

-- MetricExports - Junction table linking MetricsFormulas to Exports
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

-- Season stats
INSERT INTO SeasonStats (seasonStatID, playerID, season, gamesPlayed, totalMinsPlayed, avgPts, ptsPerGame, rebPerGame, astPerGame, avgRebounds, avgAsts, threePointers, threePPercent, fieldGoalPercent, freeThrowPercent) VALUES
(1, 1, '2024', 25, 800, 28.5, 28.5, 8.2, 7.1, 8.2, 7.1, 45, 36.5, 51.2, 78.5),
(2, 2, '2024', 28, 900, 32.1, 32.1, 5.1, 6.8, 5.1, 6.8, 120, 43.2, 48.7, 91.3);

-- Player stats
INSERT INTO PlayerStats (statsID, playerID, ptsPerGame, rebPerGame, astPerGame) VALUES
(1, 1, 28.5, 8.2, 7.1),
(2, 2, 32.1, 5.1, 6.8);

-- Game stats
INSERT INTO GameStats (gameStatID, gameID, playerID, minutes, points, rebounds, assists, steals, blocks, turnovers, fouls, threePts) VALUES
(1, 1, 1, 35, 32, 9, 8, 2, 1, 3, 2, 2),
(2, 1, 2, 38, 28, 5, 7, 1, 0, 2, 2, 5),
(3, 1, 3, 28, 19, 4, 6, 1, 0, 2, 3, 3);

-- Player scouting reports
INSERT INTO PlayerReports (playerID, summary, date, strengths, weaknesses, grade) VALUES
(1, 'Elite all-around player with NBA-ready skills', '2024-11-01', 'Leadership, basketball IQ, versatility', 'Three-point consistency', 'A'),
(2, 'Best shooter in the class, elite range', '2024-11-02', 'Shooting, ball handling', 'Defensive intensity, size', 'A-'),
(3, 'Skilled scorer with length advantage', '2024-11-03', 'Shooting, length', 'Lateral quickness on defense', 'B+');

-- Offers
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
INSERT INTO Verifications (playerID, adminID) VALUES
(1, 1),
(2, 1);

-- Exports
INSERT INTO Exports (playerID, exportID) VALUES
(1, 1),
(2, 2);

-- MetricExports
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
