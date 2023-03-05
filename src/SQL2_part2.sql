-------------------->>> FIRST <<<--------------------
-- Adds p2p check

CREATE OR REPLACE PROCEDURE proc_p2p_review(IN nick_checkedpeer varchar, IN nick_checkingpeer varchar, IN task_name varchar, IN status_review check_status, IN check_time time) AS $$
    BEGIN
        IF status_review = 'Start' THEN
            IF ((SELECT COUNT(*) FROM P2P
                 JOIN Checks ON P2P."Check" = Checks.Id
                 WHERE P2P.CheckingPeer = nick_checkingpeer AND Checks.Peer = nick_checkedpeer AND Checks.Task = task_name) = 1) THEN
                 RAISE EXCEPTION 'Unfinished P2P stage';
            ELSE
                INSERT INTO Checks VALUES ((SELECT MAX(Id) FROM Checks) + 1, nick_checkedpeer, task_name, NOW());
                INSERT INTO P2P VALUES ((SELECT MAX(Id) FROM P2P) + 1, (SELECT MAX(Id) FROM Checks), nick_checkingpeer, status_review, check_time);
            END IF;
        ELSE 
            INSERT INTO P2P VALUES ((SELECT MAX(Id) FROM P2P) + 1, 
                                    (SELECT "Check" FROM P2P
                                    JOIN Checks ON P2P."Check" = Checks.Id
                                    WHERE P2P.CheckingPeer = nick_checkingpeer AND Checks.Peer = nick_checkedpeer AND Checks.Task = task_name),
                                    nick_checkingpeer, status_review, check_time);
        END IF;        
    END;
$$ LANGUAGE plpgsql;

-- CALL proc_p2p_review('illidant', 'rosettel', 'C6_s21_matrix', 'Start', '10:00:00'); -- Easy adds
-- CALL proc_p2p_review('illidant', 'rosettel', 'C6_s21_matrix', 'Start', '10:00:00'); -- Can't add, 'cause P2P stage unfinished
-- CALL proc_p2p_review('illidant', 'rosettel', 'C6_s21_matrix', 'Success', '11:00:00'); -- Easy adds
-- CALL proc_p2p_review('changeli', 'rosettel', 'C6_s21_matrix', 'Start', '10:00:00'); -- Start
-- CALL proc_p2p_review('changeli', 'rosettel', 'C6_s21_matrix', 'Failure', '10:00:00'); -- Failure

-------------------->>> END <<<--------------------


-------------------->>> SECOND <<<--------------------
-- Adds checking by Verter

CREATE OR REPLACE PROCEDURE proc_add_verter(IN nick_checkedpeer varchar, IN task_name varchar, IN status_verter check_status, IN check_time time) AS $$
	BEGIN
        IF (status_verter = 'Start') THEN
            IF ((SELECT MAX(P2P."Time") FROM P2P
                 JOIN Checks ON P2P."Check" = Checks.Id
                 WHERE Checks.Peer = nick_checkedpeer AND Checks.Task = task_name AND P2P.State = 'Success') IS NOT NULL) THEN
                 INSERT INTO Verter VALUES ((SELECT MAX(Id) FROM Verter) + 1,
                                            (SELECT Checks.Id FROM P2P
                                             JOIN Checks ON P2P."Check" = Checks.Id
                                             WHERE Checks.Peer = nick_checkedpeer AND Checks.Task = task_name AND P2P.State = 'Success'), status_verter, check_time);
            ELSE
                RAISE EXCEPTION 'Review not completed or "Failure"';
            END IF;
        ELSE
    	   INSERT INTO Verter VALUES ((SELECT MAX(Id) FROM Verter) + 1, (SELECT "Check" FROM verter GROUP BY "Check" HAVING COUNT(*) % 2 = 1), status_verter, check_time);
        END IF;
    END;
$$ LANGUAGE plpgsql;

-- CALL proc_add_verter('illidant', 'C6_s21_matrix', 'Start', '01:00:00'); -- Easy adds
-- CALL proc_add_verter('illidant', 'C6_s21_matrix', 'Success', '02:00:00'); -- Easy adds
-- CALL proc_add_verter('rosettel', 'C6_s21_matrix', 'Start', '10:00:00'); -- Failure from peer

-------------------->>> END <<<--------------------


-------------------->>> THIRD <<<--------------------
-- After adding a record with the "start" status to the P2P table, changes the corresponding record in the TransferredPoints table

CREATE OR REPLACE FUNCTION func_trg_transferredpoints() RETURNS TRIGGER AS $trg_transferredpoints$
    BEGIN
        IF (NEW.State = 'Start') THEN
            WITH tmp AS (
                SELECT Checks.Peer FROM P2P
                JOIN Checks ON P2P."Check" = Checks.Id
                WHERE State = 'Start' AND NEW."Check" = Checks.Id
            )
            UPDATE TransferredPoints
            SET PointsAmount = PointsAmount + 1
            FROM tmp
            WHERE TransferredPoints.CheckingPeer = NEW.CheckingPeer AND TransferredPoints.CheckedPeer = tmp.Peer;
        END IF;
        RETURN NULL;
    END;
$trg_transferredpoints$ LANGUAGE plpgsql;

CREATE TRIGGER trg_transferredpoints
AFTER INSERT ON P2P
FOR EACH ROW EXECUTE FUNCTION func_trg_transferredpoints();

-- INSERT INTO P2P VALUES (41, 19, 'smithjan', 'Start', '10:00:00'); -- method 1
-- CALL proc_p2p_review('chillwav', 'rosettel', 'D1_Linux', 'Start', '10:00:00'); -- method 2

-------------------->>> END <<<--------------------


-------------------->>> FOURTH <<<--------------------
-- Before adding a record to the XP table, checks if it is correct

CREATE OR REPLACE FUNCTION func_trg_xp() RETURNS TRIGGER AS $trg_xp$
    BEGIN
        IF ((SELECT MaxXP FROM Checks
            JOIN Tasks ON Checks.Task = Tasks.Title
            WHERE NEW."Check" = Checks.Id) < NEW.XpAmount) THEN
            RAISE EXCEPTION 'Quantity of ХР is over maximal value';
        ELSEIF (SELECT State FROM P2P
                WHERE NEW."Check" = P2P."Check" AND P2P.State = 'Failure') = 'Failure' THEN
                RAISE EXCEPTION 'Failure from peer';
        ELSEIF (SELECT State FROM Verter
                WHERE NEW."Check" = Verter."Check" AND Verter.State = 'Failure') = 'Failure' THEN
                RAISE EXCEPTION 'Failure from Verter';
        END IF;
    RETURN (NEW.Id, NEW."Check", NEW.XpAmount);
    END;
$trg_xp$ LANGUAGE plpgsql;

CREATE TRIGGER trg_xp
BEFORE INSERT ON XP
FOR EACH ROW EXECUTE FUNCTION func_trg_xp();

-- INSERT INTO XP VALUES (13, 14, 350); -- изи добавляется
-- INSERT INTO XP VALUES (14, 14, 351); -- больше хр, чем можно
-- INSERT INTO XP VALUES (14, 9, 300); -- Failure from peer
-- INSERT INTO XP VALUES (14, 8, 200); -- Failure from Verter

-------------------->>> END <<<--------------------


-------------------->>> Please, delete this before the next part <<<--------------------

-- DELETE FROM P2P WHERE Id > 36;
-- DELETE FROM Verter WHERE Id > 16;
-- DELETE FROM Checks WHERE Id > 24;
-- DELETE FROM XP WHERE Id > 12;
-- UPDATE TransferredPoints
-- SET PointsAmount = PointsAmount - 1
-- Where 'frozenma' = checkedpeer and 'smithjan' = checkingpeer;
-- UPDATE TransferredPoints
-- SET PointsAmount = PointsAmount - 1
-- Where 'chillwav' = checkedpeer and 'rosettel' = checkingpeer;