-------------------->>> FIRST <<<--------------------
-- Creates and inputs all tables

CREATE TABLE Peers (
    Nickname varchar primary key NOT NULL,
    Birthday date NOT NULL
);

INSERT INTO Peers VALUES ('illidant', '2000-01-01');
INSERT INTO Peers VALUES ('smithjan', '2000-02-02');
INSERT INTO Peers VALUES ('changeli', '2000-03-03');
INSERT INTO Peers VALUES ('shondraf', '2000-03-04');
INSERT INTO Peers VALUES ('chillwav', '2000-05-05');
INSERT INTO Peers VALUES ('rosettel', '2000-06-06');
INSERT INTO Peers VALUES ('turkeyca', '2000-07-07');
INSERT INTO Peers VALUES ('frozenma', '2000-08-08');

CREATE TABLE Tasks (
    Title varchar primary key NOT NULL,
    ParentTask varchar DEFAULT NULL,
    MaxXP bigint NOT NULL,
    FOREIGN KEY (ParentTask) REFERENCES Tasks (Title)
);

INSERT INTO Tasks VALUES ('C2_SimpleBashUtils', NULL, 350);
INSERT INTO Tasks VALUES ('C3_s21_string+', 'C2_SimpleBashUtils', 750);
INSERT INTO Tasks VALUES ('C4_s21_math', 'C3_s21_string+', 300);
INSERT INTO Tasks VALUES ('C5_s21_decimal', 'C4_s21_math', 350);
INSERT INTO Tasks VALUES ('C6_s21_matrix', 'C5_s21_decimal', 200);
INSERT INTO Tasks VALUES ('C7_SmartCalc_v1.0', 'C6_s21_matrix', 650);
INSERT INTO Tasks VALUES ('D1_Linux', 'C7_SmartCalc_v1.0', 300);
INSERT INTO Tasks VALUES ('D2_Linux_Network', 'D1_Linux', 350);
INSERT INTO Tasks VALUES ('D3_Linux_Monitoring_v1.0', 'D2_Linux_Network', 350);
INSERT INTO Tasks VALUES ('D4_Linux_Monitoring_v2.0', 'D3_Linux_Monitoring_v1.0', 501);
INSERT INTO Tasks VALUES ('CPP1_s21_matrix+', 'D4_Linux_Monitoring_v2.0', 300);
INSERT INTO Tasks VALUES ('CPP2_s21_containers', 'CPP1_s21_matrix+', 501);

CREATE TYPE check_status AS ENUM ('Start', 'Success', 'Failure');

CREATE TABLE Checks (
    ID bigint primary key NOT NULL,
    Peer varchar NOT NULL,
    Task varchar NOT NULL,
    "Date" date NOT NULL,
    FOREIGN KEY (Peer) REFERENCES Peers (Nickname),
    FOREIGN KEY (Task) REFERENCES Tasks (Title)
);

INSERT INTO Checks VALUES (1, 'illidant', 'C2_SimpleBashUtils', '2022-12-21');
INSERT INTO Checks VALUES (2, 'smithjan', 'C3_s21_string+', '2023-02-02');
INSERT INTO Checks VALUES (3, 'changeli', 'D2_Linux_Network', '2023-03-03');
INSERT INTO Checks VALUES (4, 'chillwav', 'C6_s21_matrix', '2023-06-28');
INSERT INTO Checks VALUES (5, 'smithjan', 'C4_s21_math', '2023-05-10');
INSERT INTO Checks VALUES (6, 'illidant', 'C3_s21_string+', '2023-05-10');
INSERT INTO Checks VALUES (7, 'shondraf', 'D3_Linux_Monitoring_v1.0', '2023-05-10');
INSERT INTO Checks VALUES (8, 'illidant', 'C4_s21_math', '2023-05-10');
INSERT INTO Checks VALUES (9, 'shondraf', 'D4_Linux_Monitoring_v2.0', '2023-06-14');
INSERT INTO Checks VALUES (10, 'chillwav', 'C5_s21_decimal', '2023-07-10');
INSERT INTO Checks VALUES (11, 'smithjan', 'C5_s21_decimal', '2023-07-10');
INSERT INTO Checks VALUES (12, 'rosettel', 'C7_SmartCalc_v1.0', '2023-07-21');
INSERT INTO Checks VALUES (13, 'rosettel', 'D1_Linux', '2023-07-27');
INSERT INTO Checks VALUES (14, 'illidant', 'C5_s21_decimal', '2023-07-27');
INSERT INTO Checks VALUES (15, 'frozenma', 'D1_Linux', '2023-07-27');
INSERT INTO Checks VALUES (16, 'frozenma', 'D2_Linux_Network', '2023-08-08');
INSERT INTO Checks VALUES (17, 'illidant', 'C6_s21_matrix', '2023-07-27');
INSERT INTO Checks VALUES (18, 'frozenma', 'D3_Linux_Monitoring_v1.0', '2023-10-25');
INSERT INTO Checks VALUES (19, 'frozenma', 'D4_Linux_Monitoring_v2.0', '2023-10-26');
INSERT INTO Checks VALUES (20, 'shondraf', 'CPP1_s21_matrix+', '2023-10-27');
INSERT INTO Checks VALUES (21, 'shondraf', 'CPP2_s21_containers', '2023-10-28');
INSERT INTO Checks VALUES (22, 'changeli', 'D3_Linux_Monitoring_v1.0', '2022-12-22');
INSERT INTO Checks VALUES (23, 'smithjan', 'C6_s21_matrix', '2023-10-21');
INSERT INTO Checks VALUES (24, 'changeli', 'D4_Linux_Monitoring_v2.0', '2023-12-31');

CREATE TABLE P2P (
    ID bigint primary key NOT NULL,
    "Check" bigint NOT NULL,
    CheckingPeer varchar NOT NULL,
    State check_status NOT NULL,
    "Time" time NOT NULL,
    FOREIGN KEY (CheckingPeer) REFERENCES Peers (Nickname),
    FOREIGN KEY ("Check") REFERENCES Checks (ID)
);

INSERT INTO P2P VALUES (1, 1, 'smithjan', 'Start', '01:00:00');
INSERT INTO P2P VALUES (2, 1, 'smithjan', 'Success', '02:00:00');
INSERT INTO P2P VALUES (3, 2, 'changeli', 'Start', '03:00:00');
INSERT INTO P2P VALUES (4, 2, 'changeli', 'Failure', '04:00:00'); -- peer
INSERT INTO P2P VALUES (5, 3, 'chillwav', 'Start', '05:00:00');
INSERT INTO P2P VALUES (6, 3, 'chillwav', 'Success', '06:00:00');
INSERT INTO P2P VALUES (7, 4, 'shondraf', 'Start', '07:00:00');
INSERT INTO P2P VALUES (8, 4, 'shondraf', 'Success', '08:00:00');
INSERT INTO P2P VALUES (9, 5, 'chillwav', 'Start', '09:00:00');
INSERT INTO P2P VALUES (10, 5, 'chillwav', 'Success', '10:00:00');
INSERT INTO P2P VALUES (11, 6, 'rosettel', 'Start', '11:00:00');
INSERT INTO P2P VALUES (12, 6, 'rosettel', 'Success', '12:00:00');
INSERT INTO P2P VALUES (13, 7, 'turkeyca', 'Start', '13:00:00');
INSERT INTO P2P VALUES (14, 7, 'turkeyca', 'Success', '14:00:00');
INSERT INTO P2P VALUES (15, 8, 'frozenma', 'Start', '15:00:00');
INSERT INTO P2P VALUES (16, 8, 'frozenma', 'Success', '16:00:00'); -- verter
INSERT INTO P2P VALUES (17, 9, 'chillwav', 'Start', '17:00:00');
INSERT INTO P2P VALUES (18, 9, 'chillwav', 'Failure', '18:00:00'); -- peer
INSERT INTO P2P VALUES (19, 10, 'illidant', 'Start', '19:00:00');
INSERT INTO P2P VALUES (20, 10, 'illidant', 'Success', '20:00:00'); -- verter
INSERT INTO P2P VALUES (21, 15, 'rosettel', 'Start', '07:00:00');
INSERT INTO P2P VALUES (22, 15, 'rosettel', 'Success', '08:00:00');
INSERT INTO P2P VALUES (23, 16, 'illidant', 'Start', '09:00:00');
INSERT INTO P2P VALUES (24, 16, 'illidant', 'Success', '10:00:00');
INSERT INTO P2P VALUES (25, 18, 'chillwav', 'Start', '11:00:00');
INSERT INTO P2P VALUES (26, 18, 'chillwav', 'Success', '12:00:00');
INSERT INTO P2P VALUES (27, 19, 'turkeyca', 'Start', '13:00:00');
INSERT INTO P2P VALUES (28, 19, 'turkeyca', 'Success', '14:00:00');
INSERT INTO P2P VALUES (29, 20, 'rosettel', 'Start', '11:00:00');
INSERT INTO P2P VALUES (30, 20, 'rosettel', 'Success', '12:00:00');
INSERT INTO P2P VALUES (31, 21, 'rosettel', 'Start', '13:00:00');
INSERT INTO P2P VALUES (32, 21, 'rosettel', 'Success', '14:00:00');
INSERT INTO P2P VALUES (33, 22, 'chillwav', 'Start', '15:00:00');
INSERT INTO P2P VALUES (34, 22, 'chillwav', 'Success', '16:00:00');
INSERT INTO P2P VALUES (35, 24, 'chillwav', 'Start', '15:00:00');
INSERT INTO P2P VALUES (36, 24, 'chillwav', 'Failure', '16:00:00'); -- peer

CREATE TABLE Verter (
    ID bigint primary key NOT NULL,
    "Check" bigint NOT NULL,
    State check_status NOT NULL,
    "Time" time NOT NULL,
    FOREIGN KEY ("Check") REFERENCES Checks (ID)
);

INSERT INTO Verter VALUES (1, 1, 'Start',  '02:01:00');
INSERT INTO Verter VALUES (2, 1, 'Success', '02:02:00');
INSERT INTO Verter VALUES (3, 4, 'Start', '08:01:00');
INSERT INTO Verter VALUES (4, 4, 'Success', '08:02:00');
INSERT INTO Verter VALUES (5, 6, 'Start', '12:01:00');
INSERT INTO Verter VALUES (6, 6, 'Success', '12:02:00');
INSERT INTO Verter VALUES (7, 8, 'Start', '16:01:00');
INSERT INTO Verter VALUES (8, 8, 'Failure', '16:02:00');
INSERT INTO Verter VALUES (9, 10, 'Start', '20:01:00');
INSERT INTO Verter VALUES (10, 10, 'Failure', '20:02:00');
INSERT INTO Verter VALUES (11, 15, 'Start', '08:01:00');
INSERT INTO Verter VALUES (12, 15, 'Success', '08:02:00');
INSERT INTO Verter VALUES (13, 3, 'Start',  '06:01:00');
INSERT INTO Verter VALUES (14, 3, 'Success', '06:02:00');
INSERT INTO Verter VALUES (15, 22, 'Start', '16:01:00');
INSERT INTO Verter VALUES (16, 22, 'Success', '16:02:00');

CREATE TABLE TransferredPoints (
    ID bigint primary key NOT NULL,
    CheckingPeer varchar NOT NULL,
    CheckedPeer varchar NOT NULL,
    PointsAmount bigint NOT NULL,
    FOREIGN KEY (CheckingPeer) REFERENCES Peers (Nickname),
    FOREIGN KEY (CheckedPeer) REFERENCES Peers (Nickname)
);

INSERT INTO TransferredPoints VALUES (1, 'smithjan', 'frozenma', 1);
INSERT INTO TransferredPoints VALUES (2, 'rosettel', 'chillwav', 2);
INSERT INTO TransferredPoints VALUES (3, 'changeli', 'illidant', 0);
INSERT INTO TransferredPoints VALUES (4, 'frozenma', 'smithjan', 1);
INSERT INTO TransferredPoints VALUES (5, 'chillwav', 'rosettel', 0);
INSERT INTO TransferredPoints VALUES (6, 'illidant', 'changeli', 3);
INSERT INTO TransferredPoints VALUES (7, 'shondraf', 'turkeyca', 1);

CREATE TABLE Friends (
    ID bigint primary key NOT NULL,
    Peer1 varchar NOT NULL,
    Peer2 varchar NOT NULL,
    FOREIGN KEY (Peer1) REFERENCES Peers (Nickname),
    FOREIGN KEY (Peer2) REFERENCES Peers (Nickname)
);

INSERT INTO Friends VALUES (1, 'smithjan', 'frozenma');
INSERT INTO Friends VALUES (2, 'smithjan', 'shondraf');
INSERT INTO Friends VALUES (3, 'frozenma', 'illidant');
INSERT INTO Friends VALUES (4, 'chillwav', 'rosettel');
INSERT INTO Friends VALUES (5, 'rosettel', 'turkeyca');
INSERT INTO Friends VALUES (6, 'changeli', 'rosettel');

CREATE TABLE Recommendations (
    ID bigint primary key NOT NULL,
    Peer varchar NOT NULL,
    RecommendedPeer varchar NOT NULL,
    FOREIGN KEY (Peer) REFERENCES Peers (Nickname),
    FOREIGN KEY (RecommendedPeer) REFERENCES Peers (Nickname)
);

INSERT INTO Recommendations VALUES (1, 'frozenma', 'smithjan');
INSERT INTO Recommendations VALUES (2, 'shondraf', 'smithjan');
INSERT INTO Recommendations VALUES (3, 'rosettel', 'smithjan');
INSERT INTO Recommendations VALUES (4, 'turkeyca', 'illidant');
INSERT INTO Recommendations VALUES (5, 'smithjan', 'shondraf');
INSERT INTO Recommendations VALUES (6, 'chillwav', 'turkeyca');

CREATE TABLE XP (
    ID bigint primary key NOT NULL,
    "Check" bigint NOT NULL,
    XPAmount bigint NOT NULL,
    FOREIGN KEY ("Check") REFERENCES Checks (ID)
);

INSERT INTO XP VALUES (1, 1, 300);
INSERT INTO XP VALUES (2, 2, 750);
INSERT INTO XP VALUES (3, 3, 350);
INSERT INTO XP VALUES (4, 4, 200);
INSERT INTO XP VALUES (5, 5, 239);
INSERT INTO XP VALUES (6, 6, 700);
INSERT INTO XP VALUES (7, 7, 350);
INSERT INTO XP VALUES (8, 15, 300);
INSERT INTO XP VALUES (9, 16, 350);
INSERT INTO XP VALUES (10, 20, 300);
INSERT INTO XP VALUES (11, 21, 501);
INSERT INTO XP VALUES (12, 22, 300);

CREATE TABLE TimeTracking (
    ID bigint primary key NOT NULL,
    Peer varchar NOT NULL,
    "Date" date NOT NULL,
    "Time" time NOT NULL,
    State bigint NOT NULL CHECK (State IN (1, 2)),
    FOREIGN KEY (Peer) REFERENCES Peers (Nickname)
);

INSERT INTO TimeTracking VALUES (1, 'smithjan', '2022-03-01', '10:00:00', 1);
INSERT INTO TimeTracking VALUES (2, 'smithjan', '2022-03-01', '15:00:00', 2);
INSERT INTO TimeTracking VALUES (3, 'turkeyca', '2022-03-01', '10:00:00', 1);
INSERT INTO TimeTracking VALUES (4, 'turkeyca', '2022-03-01', '12:00:00', 2);
INSERT INTO TimeTracking VALUES (5, 'illidant', '2022-05-12', '13:00:00', 1);
INSERT INTO TimeTracking VALUES (6, 'illidant', '2022-05-12', '20:00:00', 2);
INSERT INTO TimeTracking VALUES (7, 'frozenma', '2022-05-12', '05:00:00', 1);
INSERT INTO TimeTracking VALUES (8, 'frozenma', '2022-05-12', '12:00:00', 2);
INSERT INTO TimeTracking VALUES (9, 'frozenma', '2022-05-12', '13:00:00', 1);
INSERT INTO TimeTracking VALUES (10, 'frozenma', '2022-05-12', '21:00:00', 2);
INSERT INTO TimeTracking VALUES (11, 'rosettel', '2022-05-12', '07:00:00', 1);
INSERT INTO TimeTracking VALUES (12, 'rosettel', '2022-05-12', '23:00:00', 2);
INSERT INTO TimeTracking VALUES (13, 'smithjan', CURRENT_DATE, '01:00:00', 1);
INSERT INTO TimeTracking VALUES (14, 'smithjan', CURRENT_DATE, '23:00:00', 2);
INSERT INTO TimeTracking VALUES (15, 'illidant', CURRENT_DATE, '16:00:00', 1);
INSERT INTO TimeTracking VALUES (16, 'illidant', CURRENT_DATE, '23:00:00', 2);
INSERT INTO TimeTracking VALUES (17, 'turkeyca', CURRENT_DATE, '03:00:00', 1);
INSERT INTO TimeTracking VALUES (18, 'turkeyca', CURRENT_DATE, '10:00:00', 2);
INSERT INTO TimeTracking VALUES (19, 'turkeyca', CURRENT_DATE, '11:00:00', 1);
INSERT INTO TimeTracking VALUES (20, 'turkeyca', CURRENT_DATE, '15:00:00', 2);
INSERT INTO TimeTracking VALUES (21, 'turkeyca', CURRENT_DATE, '17:00:00', 1);
INSERT INTO TimeTracking VALUES (22, 'turkeyca', CURRENT_DATE, '23:00:00', 2);
INSERT INTO TimeTracking VALUES (23, 'rosettel', CURRENT_DATE - 1, '10:00:00', 1);
INSERT INTO TimeTracking VALUES (24, 'rosettel', CURRENT_DATE - 1, '15:00:00', 2);
INSERT INTO TimeTracking VALUES (25, 'rosettel', CURRENT_DATE - 1, '16:00:00', 1);
INSERT INTO TimeTracking VALUES (26, 'rosettel', CURRENT_DATE - 1, '20:00:00', 2);
INSERT INTO TimeTracking VALUES (27, 'shondraf', CURRENT_DATE - 1, '10:00:00', 1);
INSERT INTO TimeTracking VALUES (28, 'shondraf', CURRENT_DATE - 1, '17:00:00', 2);
INSERT INTO TimeTracking VALUES (29, 'shondraf', CURRENT_DATE - 1, '19:00:00', 1);
INSERT INTO TimeTracking VALUES (30, 'shondraf', CURRENT_DATE - 1, '20:00:00', 2);
INSERT INTO TimeTracking VALUES (31, 'changeli', '2022-03-12', '11:00:00', 1);
INSERT INTO TimeTracking VALUES (32, 'changeli', '2022-03-12', '20:00:00', 2);
INSERT INTO TimeTracking VALUES (33, 'shondraf', '2022-03-12', '13:00:00', 1);
INSERT INTO TimeTracking VALUES (34, 'shondraf', '2022-03-12', '20:00:00', 2);

-------------------->>> END <<<--------------------


-------------------->>> SECOND <<<--------------------
-- Creates export and import procedures

CREATE OR REPLACE PROCEDURE proc_export(IN table_title varchar, IN path text, IN delimiter text) AS $$
    BEGIN
        EXECUTE format('COPY %s TO ''%s'' DELIMITER ''%s'' CSV HEADER;', table_title, path, delimiter);
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE proc_import(IN table_title varchar, IN path text, IN delimiter text) AS $$
    BEGIN
        EXECUTE format('COPY %s FROM ''%s'' DELIMITER ''%s'' CSV HEADER;', table_title, path, delimiter);
    END;
$$ LANGUAGE plpgsql;

-------------------->>> END <<<--------------------


-------------------->>> THIRD <<<--------------------
-- Calls export procedures

-- CALL proc_export('Peers', '/Users/frozenma/Desktop/info21/src/Peers.csv', ',');
-- CALL proc_export('Tasks', '/Users/frozenma/Desktop/info21/src/Tasks.csv', ',');
-- CALL proc_export('Checks', '/Users/frozenma/Desktop/info21/src/Checks.csv', ',');
-- CALL proc_export('P2P', '/Users/frozenma/Desktop/info21/src/P2P.csv', ',');
-- CALL proc_export('Verter', '/Users/frozenma/Desktop/info21/src/Verter.csv', ',');
-- CALL proc_export('TransferredPoints', '/Users/frozenma/Desktop/info21/src/TransferredPoints.csv', ',');
-- CALL proc_export('Friends', '/Users/frozenma/Desktop/info21/src/Friends.csv', ',');
-- CALL proc_export('Recommendations', '/Users/frozenma/Desktop/info21/src/Recommendations.csv', ',');
-- CALL proc_export('XP', '/Users/frozenma/Desktop/info21/src/XP.csv', ',');
-- CALL proc_export('TimeTracking', '/Users/frozenma/Desktop/info21/src/Timetracking.csv', ',');

-------------------->>> END <<<--------------------


-------------------->>> FOURTH <<<--------------------
-- Truncates all tables for import

-- TRUNCATE TABLE Peers CASCADE;
-- TRUNCATE TABLE Tasks CASCADE;
-- TRUNCATE TABLE Checks CASCADE;
-- TRUNCATE TABLE P2P CASCADE;
-- TRUNCATE TABLE Verter CASCADE;
-- TRUNCATE TABLE TransferredPoints CASCADE;
-- TRUNCATE TABLE Friends CASCADE;
-- TRUNCATE TABLE Recommendations CASCADE;
-- TRUNCATE TABLE XP CASCADE;
-- TRUNCATE TABLE TimeTracking CASCADE;

-------------------->>> END <<<--------------------


-------------------->>> FIFTH <<<--------------------
-- Calls import procedures

-- CALL proc_import('Peers', '/Users/frozenma/Desktop/info21/src/Peers.csv', ',');
-- CALL proc_import('Tasks', '/Users/frozenma/Desktop/info21/src/Tasks.csv', ',');
-- CALL proc_import('Checks', '/Users/frozenma/Desktop/info21/src/Checks.csv', ',');
-- CALL proc_import('P2P', '/Users/frozenma/Desktop/info21/src/P2P.csv', ',');
-- CALL proc_import('Verter', '/Users/frozenma/Desktop/info21/src/Verter.csv', ',');
-- CALL proc_import('TransferredPoints', '/Users/frozenma/Desktop/info21/src/TransferredPoints.csv', ',');
-- CALL proc_import('Friends', '/Users/frozenma/Desktop/info21/src/Friends.csv', ',');
-- CALL proc_import('Recommendations', '/Users/frozenma/Desktop/info21/src/Recommendations.csv', ',');
-- CALL proc_import('XP', '/Users/frozenma/Desktop/info21/src/XP.csv', ',');
-- CALL proc_import('TimeTracking', '/Users/frozenma/Desktop/info21/src/Timetracking.csv', ',');

-------------------->>> END <<<--------------------