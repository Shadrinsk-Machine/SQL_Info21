-------------------->>> FIRST <<<--------------------
-- Returns the TransferredPoints table in a more human-readable form

CREATE OR REPLACE FUNCTION func_points_amount()
    RETURNS TABLE (Peer1 varchar, Peer2 varchar, PointsAmount bigint) AS $$
    BEGIN
        RETURN QUERY (
            SELECT t1.checkingpeer, t1.checkedpeer, (t1.pointsamount - t2.pointsamount)
            FROM transferredpoints t1
            JOIN transferredpoints t2 ON t1.checkingpeer = t2.checkedpeer AND t1.checkedpeer = t2.checkingpeer AND t1.id < t2.id
        );
    END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM func_points_amount();

-------------------->>> END <<<--------------------


-------------------->>> SECOND <<<--------------------
-- Returns the table: Peer, Task, XP

CREATE OR REPLACE FUNCTION func_xp()
    RETURNS TABLE (Peer varchar, Task varchar, XP bigint) AS $$
    BEGIN
        RETURN QUERY (SELECT Checks.Peer, Checks.Task, XP.XPAmount
                      FROM XP
                      JOIN Checks ON XP."Check" = Checks.Id
        );
    END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM func_xp();

-------------------->>> END <<<--------------------


-------------------->>> THIRD <<<--------------------
-- Defines people who did not leave campus all day

CREATE OR REPLACE FUNCTION func_peers_in_campus(IN Date_parameter date)
    RETURNS TABLE (Peers varchar) AS $$
    BEGIN
        RETURN QUERY (SELECT Peer
                      FROM TimeTracking
                      WHERE TimeTracking."Date" = Date_parameter
                      GROUP BY Peer
                      HAVING COUNT(State) < 3
        );
    END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM func_peers_in_campus('2022-05-12');

-------------------->>> END <<<--------------------


-------------------->>> FOURTH <<<--------------------
-- Finds the percentage of successful and unsuccessful checks for all time

CREATE OR REPLACE FUNCTION func_percent_of_projects()
    RETURNS TABLE (SuccessfulChecks real, UnsuccessfulChecks real) AS $$
    BEGIN
        RETURN QUERY (WITH tmp AS (SELECT P2P.state AS p2p, Verter.state AS verter
                                   FROM P2P
                                   JOIN Checks ON P2P."Check" = Checks.Id
                                   LEFT JOIN Verter ON Verter."Check" = Checks.Id
                                   WHERE P2P.State IN ('Success', 'Failure') AND (Verter.State IN ('Success', 'Failure') OR Verter.State IS NULL)),
                           success AS (SELECT round(((SELECT COUNT(*)
                                                      FROM tmp
                                                      WHERE p2p = 'Success' AND (verter = 'Success' OR verter IS NULL))::real * 100) / (SELECT COUNT(*) FROM tmp))::real AS a),
                           fail AS (SELECT round(((SELECT COUNT(*)
                                                   FROM tmp
                                                   WHERE p2p = 'Failure' OR verter = 'Failure')::real * 100) / (SELECT COUNT(*) FROM tmp))::real AS b)
                      SELECT a, b
                      FROM success
                      CROSS JOIN fail
        );
    END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM func_percent_of_projects();

-------------------->>> END <<<--------------------


-------------------->>> FIFTH <<<--------------------
-- Counts the change of p2p of each peer from the TransferredPoints table

CREATE OR REPLACE FUNCTION func_change_points()
    RETURNS TABLE (Peer varchar, PointsChange real) AS $$
    BEGIN
        RETURN QUERY (WITH tmp AS (SELECT CheckingPeer, SUM(PointsAmount)::real AS sum
                                   FROM TransferredPoints
                                   GROUP BY CheckingPeer),
                           tmp1 AS (SELECT CheckedPeer, SUM(PointsAmount)::real AS sum
                                    FROM TransferredPoints
                                    GROUP BY CheckedPeer)
                      SELECT CheckingPeer, (COALESCE(tmp.sum, 0) - COALESCE(tmp1.sum, 0)) AS points
                      FROM tmp
                      JOIN tmp1 ON tmp.CheckingPeer = tmp1.CheckedPeer
                      ORDER BY points DESC
        );
    END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM func_change_points();

-------------------->>> END <<<--------------------


-------------------->>> SIXTH <<<--------------------
-- Counts the change of p2p of each peer from the func_points_amount()

CREATE OR REPLACE FUNCTION func_change_points_from_first_function()
    RETURNS TABLE (Peer varchar, PointsChange real) AS $$
    BEGIN
        RETURN QUERY (WITH tmp AS (SELECT Peer1, SUM(PointsAmount)::real AS sum
                                   FROM func_points_amount()
                                   GROUP BY Peer1),
                           tmp1 AS (SELECT Peer2, SUM(PointsAmount)::real AS sum
                                    FROM func_points_amount()
                                    GROUP BY Peer2)
                      SELECT COALESCE(Peer1, Peer2), (COALESCE(tmp.sum, 0) - COALESCE(tmp1.sum, 0)) AS points
                      FROM tmp
                      FULL JOIN tmp1 ON tmp.Peer1 = tmp1.Peer2
                      ORDER BY points DESC
        );
    END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM func_change_points_from_first_function();

-------------------->>> END <<<--------------------


-------------------->>> SEVENTH <<<--------------------
-- Defines the most testable task for each day

CREATE OR REPLACE FUNCTION func_the_most_testable_task()
    RETURNS TABLE (Day text, Task varchar) AS $$
    BEGIN
        RETURN QUERY (WITH tmp AS (SELECT Checks.Task, Checks."Date", COUNT(*) AS counts
                                   FROM Checks
                                   GROUP BY Checks.Task, Checks."Date"),
                           tmp1 AS (SELECT tmp.Task, tmp."Date", rank() OVER (PARTITION BY tmp."Date" ORDER BY counts DESC) AS rank
                           FROM tmp)
                      SELECT TO_CHAR("Date", 'dd.mm.yyyy'), tmp1.Task
                      FROM tmp1
                      WHERE rank = 1
                      ORDER BY "Date" DESC
        );
    END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM func_the_most_testable_task();

-------------------->>> END <<<--------------------


-------------------->>> EIGHTH <<<--------------------
-- Defines duration of the last p2p

CREATE OR REPLACE FUNCTION func_duration_of_the_last_p2p()
    RETURNS TABLE (duration time) AS $$
    BEGIN
        RETURN QUERY (WITH tmp AS (SELECT "Check", (MAX(p2p."Time") - MIN(p2p."Time"))::time AS result
                                   FROM P2P
                                   WHERE "Check" = (SELECT MAX("Check") FROM P2P)
                                   GROUP BY "Check")
                      SELECT result
                      FROM tmp
        );
    END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM func_duration_of_the_last_p2p();

-------------------->>> END <<<--------------------


-------------------->>> NINTH <<<--------------------
-- Finds all peers who have completed the whole given block of tasks and the completion date of the last task

CREATE OR REPLACE PROCEDURE proc_peers_made_tasks(IN name varchar, IN ref refcursor) AS $$
    BEGIN
        OPEN ref FOR
        WITH tmp AS (SELECT *
                     FROM Tasks
                     WHERE Title SIMILAR TO CONCAT(name, '[0-7]%')),
             check_task AS (SELECT MAX(title) AS Title FROM tmp),
             check_date AS (SELECT Checks.peer, Checks.task, Checks."Date"
                            FROM Checks
                            JOIN P2P ON Checks.Id = P2P."Check"
                            WHERE P2P.State = 'Success')
        SELECT check_date.Peer AS Peer, TO_CHAR("Date", 'dd.mm.yyyy') AS Day
        FROM check_date
        JOIN check_task ON check_date.Task = check_task.Title;
    END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL proc_peers_made_tasks('D', 'ref');
-- FETCH ALL IN "ref";
-- END;
--
-- BEGIN;
-- CALL proc_peers_made_tasks('CPP', 'ref');
-- FETCH ALL IN "ref";
-- END;
--
-- BEGIN;
-- CALL proc_peers_made_tasks('C', 'ref');
-- FETCH ALL IN "ref";
-- END;

-------------------->>> END <<<--------------------


-------------------->>> TENTH <<<--------------------
-- Determines which peer should go to for p2p

CREATE OR REPLACE FUNCTION func_recommended_peer()
    RETURNS TABLE (Peer varchar, RecommendedPeer varchar) AS $$
    BEGIN
        RETURN QUERY (WITH tmp AS (SELECT Nickname,
                                  (CASE WHEN Nickname = Friends.Peer1 THEN Peer2
                                   ELSE Peer1
                                   END) AS t
                                   FROM Peers
                                   JOIN Friends ON Peers.Nickname = Friends.Peer1 OR peers.Nickname = Friends.Peer2),
                           tmp1 AS (SELECT tmp.Nickname, Recommendations.RecommendedPeer, COUNT(Recommendations.RecommendedPeer) AS count
                                    FROM tmp
                                    JOIN Recommendations ON tmp.t = Recommendations.Peer
                                    WHERE tmp.Nickname != Recommendations.RecommendedPeer
                                    GROUP BY tmp.Nickname, Recommendations.RecommendedPeer),
                           tmp2 AS (SELECT Nickname
                                    FROM tmp1
                                    GROUP BY Nickname)
                      SELECT tmp1.Nickname, tmp1.RecommendedPeer
                      FROM tmp1
                      JOIN tmp2 ON tmp1.Nickname = tmp2.Nickname
                      WHERE tmp1.count = (SELECT MAX(count) FROM tmp1)
        );
    END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM func_recommended_peer();

-------------------->>> END <<<--------------------


-------------------->>> ELEVENTH <<<--------------------
-- Determines the percentage of peers who: Started only block 1, Started only block 2, Started both, Have not started any of them

CREATE OR REPLACE PROCEDURE proc_peers_percent(IN name1 text, IN name2 text, OUT StartedBlock1 real, OUT StartedBlock2 real, OUT StartedBothBlock real, OUT DidntStartAnyBlock real) AS $$
    BEGIN
        CREATE TABLE tmp (
            name1_tmp varchar,
            name2_tmp varchar
        );
        INSERT INTO tmp VALUES (name1, name2);
        CREATE VIEW tmp1 AS (
            WITH first_parameter AS (SELECT DISTINCT Peer
                                     FROM Checks
                                     WHERE Checks.Task SIMILAR TO CONCAT((SELECT name1_tmp FROM tmp), '[0-7]%')),
                 second_parameter AS (SELECT DISTINCT Peer
                                      FROM Checks
                                      WHERE Checks.Task SIMILAR TO CONCAT((SELECT name2_tmp FROM tmp), '[0-7]%')),
                 started_block1 AS (SELECT Peer FROM first_parameter
                                    EXCEPT
                                    SELECT Peer FROM second_parameter),
                 started_block2 AS (SELECT Peer FROM second_parameter
                                    EXCEPT
                                    SELECT Peer FROM first_parameter),
                 started_both_block AS (SELECT Peer FROM first_parameter
                                        INTERSECT
                                        SELECT Peer FROM second_parameter),
                 didnt_start_any_block AS (SELECT Nickname
                                           FROM Peers
                                           JOIN Checks ON Peers.Nickname = Checks.Peer
                                           EXCEPT
                                           SELECT Peer FROM started_block1
                                           EXCEPT
                                           SELECT Peer FROM started_block2
                                           EXCEPT
                                           SELECT Peer FROM started_both_block),
                 didnt_start_any_block2 AS (SELECT Nickname
                                            FROM Peers
                                            LEFT JOIN Checks ON Peers.Nickname = Checks.Peer
                                            WHERE Peer IS NULL)
            SELECT (((SELECT COUNT(*) FROM started_block1)::real * 100) / (SELECT COUNT(peers.nickname) FROM peers)::real) AS cringe,
                   (((SELECT COUNT(*) FROM started_block2)::real * 100) / (SELECT COUNT(peers.nickname) FROM peers)::real) AS cringe1,
                   (((SELECT COUNT(*) FROM started_both_block)::real * 100) / (SELECT COUNT(peers.nickname) FROM peers)::real) AS cringe2,
                   (((SELECT COUNT(*) FROM didnt_start_any_block)::real * 100) / (SELECT COUNT(peers.nickname) FROM peers)::real) AS cringe3,
                   (((SELECT COUNT(*) FROM didnt_start_any_block2)::real * 100) / (SELECT COUNT(Peers.Nickname) FROM peers)::real) AS cringe4);
        StartedBlock1 = (SELECT cringe FROM tmp1);
        StartedBlock2 = (SELECT cringe1 FROM tmp1);
        StartedBothBlock = (SELECT cringe2 FROM tmp1);
        DidntStartAnyBlock = (SELECT cringe3 + cringe4 FROM tmp1);
        DROP VIEW tmp1 CASCADE;
        DROP TABLE tmp CASCADE;
    END;
$$ LANGUAGE plpgsql;

-- CALL proc_peers_percent('C', 'D', NULL, NULL, NULL, NULL);
-- CALL proc_peers_percent('C', 'CPP', NULL, NULL, NULL, NULL);
-- CALL proc_peers_percent('CPP', 'D', NULL, NULL, NULL, NULL);

-------------------->>> END <<<--------------------


-------------------->>> TWELFTH <<<--------------------
-- Determines "N" peers with the highest number of friends

CREATE OR REPLACE PROCEDURE proc_count_friends(IN count int, IN ref refcursor) AS $$
    BEGIN
        OPEN ref FOR
            WITH tmp AS (SELECT * FROM Friends
                         UNION ALL
                         SELECT Id, Peer2 AS Peer1, Peer1 AS Peer2 FROM Friends)
            SELECT Peer1 AS Peer, COUNT(Peer2) AS FriendsCount
            FROM tmp
            GROUP BY Peer1
            ORDER BY FriendsCount DESC LIMIT count;
    END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL proc_count_friends(10,'ref');
-- FETCH ALL IN "ref";
-- END;

-------------------->>> END <<<--------------------


-------------------->>> THIRTEENTH <<<--------------------
-- Determines the percentage of peers who have ever successfully passed a check on their birthday

CREATE OR REPLACE FUNCTION func_birthday()
    RETURNS TABLE (SuccessfulChecks real, UnsuccessfulChecks real) AS $$
    BEGIN
        RETURN QUERY (WITH tmp AS (SELECT Nickname, EXTRACT(day FROM Birthday) AS p, EXTRACT(month FROM Birthday) AS p1
                                   FROM Peers),
                           tmp1 AS (SELECT Checks.Id, Peer, EXTRACT(day FROM "Date") AS c, EXTRACT(month FROM "Date") AS c1, P2P.State AS p2p, Verter.State AS verter
                                    FROM Checks
                                    JOIN P2P on Checks.Id = P2P."Check"
                                    LEFT JOIN Verter ON Checks.Id = Verter."Check"
                                    WHERE P2P.State IN ('Success', 'Failure') AND (Verter.State IN ('Success', 'Failure') OR Verter.State IS NULL)),
                           tmp2 AS (SELECT *
                                    FROM tmp
                                    JOIN tmp1 ON tmp.p = tmp1.c AND tmp.p1 = tmp1.c1),
                           success AS (SELECT COUNT(*) AS s
                                       FROM tmp2
                                       WHERE p2p = 'Success' AND (verter = 'Success' OR verter IS NULL)),
                           fail AS (SELECT COUNT(*) AS f
                                    FROM tmp2
                                    WHERE p2p = 'Failure' OR verter = 'Failure'),
                           last_chance AS (SELECT round(((SELECT s FROM success)::real * 100) / (SELECT COUNT(Nickname) FROM tmp2))::real AS a),
                           last_chance1 AS (SELECT round(((SELECT f FROM fail)::real * 100) / (SELECT COUNT(Nickname) FROM tmp2))::real AS b)
                      SELECT a, b
                      FROM last_chance
                      CROSS JOIN last_chance1
        );
    END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM func_birthday();

-------------------->>> END <<<--------------------


-------------------->>> FOURTEENTH <<<--------------------
-- Determines the total amount of XP got by each peer

CREATE OR REPLACE FUNCTION func_xp_sum()
    RETURNS TABLE (Peer varchar, XP numeric) AS $$
    BEGIN
        RETURN QUERY (WITH tmp AS (SELECT Checks.Peer, MAX(XP.XPAmount) AS m
                                   FROM Checks
                                   JOIN XP ON Checks.Id = XP."Check"
                                   GROUP BY Checks.Peer, Task)
                      SELECT tmp.Peer, SUM(m)
                      FROM tmp
                      GROUP BY tmp.Peer
                      ORDER BY SUM(m) DESC
        );
    END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM func_xp_sum();

-------------------->>> END <<<--------------------


-------------------->>> FIFTEENTH <<<--------------------
-- Determines all peers who passed tasks 1 and 2, but did not pass task 3

CREATE OR REPLACE PROCEDURE proc_first_and_second_success_third_fail(task1 varchar, task2 varchar, task3 varchar, ref refcursor) AS $$
    BEGIN
       OPEN ref FOR
            WITH tmp AS (SELECT Checks.Id, Peer, Task, P2P.State AS p2p, Verter.State AS verter
                         FROM Checks
                         JOIN P2P on Checks.Id = P2P."Check"
                         LEFT JOIN Verter ON Checks.Id = Verter."Check"
                         WHERE P2P.State IN ('Success', 'Failure') AND (Verter.State IN ('Success', 'Failure') OR Verter.State IS NULL)),
                 tmp1 AS (SELECT tmp.Peer
                          FROM tmp
                          LEFT JOIN tmp t ON t.Task IN (SELECT Task FROM Checks)
                          WHERE task1 = tmp.Task AND (tmp.p2p = 'Success' AND (tmp.verter = 'Success' OR tmp.verter IS NULL))),
                 tmp2 AS (SELECT tmp.Peer
                          FROM tmp
                          LEFT JOIN tmp t ON t.Task IN (SELECT Task FROM Checks)
                          WHERE task2 = tmp.Task AND (tmp.p2p = 'Success' AND (tmp.verter = 'Success' OR tmp.verter IS NULL))),
                 tmp3 AS (SELECT tmp.Peer
                          FROM tmp
                          LEFT JOIN tmp t ON t.Task IN (SELECT Task FROM Checks)
                          WHERE task3 = tmp.Task AND (tmp.p2p = 'Failure' OR tmp.verter = 'Failure'))
            SELECT *
            FROM ((SELECT * FROM tmp1)
            INTERSECT
            (SELECT * FROM tmp2)
            INTERSECT
            (SELECT * FROM tmp3)) AS cringe;
    END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL proc_first_and_second_success_third_fail('C2_SimpleBashUtils', 'C3_s21_string+', 'C4_s21_math', 'ref');
-- FETCH ALL IN "ref";
-- END;
--
-- BEGIN;
-- CALL proc_first_and_second_success_third_fail('D2_Linux_Network', 'D3_Linux_Monitoring_v1.0', 'D4_Linux_Monitoring_v2.0', 'ref');
-- FETCH ALL IN "ref";
-- END;

-------------------->>> END <<<--------------------


-------------------->>> SIXTEENTH <<<--------------------
-- Outputs the number of previous tasks for each task

CREATE OR REPLACE FUNCTION func_parent_task()
    RETURNS TABLE (Task varchar, PrevCount integer) AS $$
    BEGIN
        RETURN QUERY (WITH RECURSIVE r AS (SELECT (CASE WHEN Tasks.ParentTask IS NULL THEN 0
                                                   ELSE 1
                                                   END) AS count, Tasks.Title, Tasks.ParentTask, Tasks.ParentTask
                                           FROM Tasks
                                           UNION ALL
                                           SELECT (CASE WHEN Tasks.ParentTask IS NOT NULL THEN count + 1
                                                   ELSE count
                                                   END) AS count,  Tasks.Title, Tasks.ParentTask, r.Title
                                           FROM Tasks
                                           CROSS JOIN r
                                           WHERE r.Title LIKE Tasks.ParentTask)
                      SELECT Title, MAX(count)
                      FROM r
                      GROUP BY Title
                      ORDER BY MAX(count)
        );
    END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM func_parent_task();

-------------------->>> END <<<--------------------


-------------------->>> SEVENTEENTH <<<--------------------
-- Finds "lucky" days for checks

CREATE OR REPLACE PROCEDURE proc_lucky_day(IN count bigint, IN ref refcursor) AS $$
    BEGIN
        OPEN ref FOR
            WITH tmp AS (SELECT *
                         FROM Checks
                         JOIN P2P on Checks.Id = P2P."Check"
                         LEFT JOIN Verter ON Checks.Id = Verter."Check"
                         JOIN Tasks ON Checks.Task = Tasks.Title
                         JOIN XP ON Checks.Id = XP."Check"
                         WHERE P2P.State = 'Success' AND (Verter.State = 'Success' OR Verter.State IS NULL))
            SELECT "Date"
            FROM tmp
            WHERE tmp.XPAmount >= tmp.MaxXP * 0.8
            GROUP BY "Date"
            HAVING COUNT("Date") >= count;
    END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL proc_lucky_day(1,'ref'); -- outputs lucky days
-- FETCH ALL IN "ref";
-- END;
--
-- BEGIN;
-- CALL proc_lucky_day(2,'ref'); -- outputs lucky days
-- FETCH ALL IN "ref";
-- END;
--
-- BEGIN;
-- CALL proc_lucky_day(3,'ref'); -- "2023-05-10" 3 completed checks, but id (5) in the table "XP" got less than 80%
-- FETCH ALL IN "ref";
-- END;

-------------------->>> END <<<--------------------


-------------------->>> EIGHTEENTH <<<--------------------
-- Determines the peer with the highest number of completed tasks

CREATE OR REPLACE FUNCTION func_max_tasks()
    RETURNS TABLE (Peer varchar, XP bigint) AS $$
    BEGIN
        RETURN QUERY (SELECT Checks.Peer, COUNT(*)
                      FROM Checks
                      JOIN P2P on Checks.Id = P2P."Check"
                      LEFT JOIN Verter ON Checks.Id = Verter."Check"
                      WHERE P2P.State = 'Success' AND (Verter.State = 'Success' OR Verter.State IS NULL)
                      GROUP BY Checks.Peer
                      ORDER BY COUNT(*) DESC LIMIT 1
        );
    END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM func_max_tasks();

-------------------->>> END <<<--------------------


-------------------->>> NINETEENTH <<<--------------------
-- Determines the peer with the highest amount of XP

CREATE OR REPLACE FUNCTION func_max_xp()
    RETURNS TABLE (Peer varchar, XP numeric) AS $$
    BEGIN
        RETURN QUERY (SELECT Checks.Peer, SUM(XPAmount)
                      FROM XP
                      JOIN Checks ON XP."Check" = Checks.Id
                      GROUP BY Checks.Peer
                      ORDER BY SUM(XPAmount) DESC LIMIT 1
        );
    END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM func_max_xp();

-------------------->>> END <<<--------------------


-------------------->>> TWENTIETH <<<--------------------
-- Finds the peer who spent the longest amount of time on campus today

CREATE OR REPLACE FUNCTION func_try_hard_peer()
    RETURNS TABLE (Peer varchar) AS $$
    BEGIN
        RETURN QUERY (WITH tmp AS (SELECT *
                                   FROM TimeTracking
                                   WHERE TimeTracking.State = 1),
                           tmp1 AS (SELECT *
                                    FROM TimeTracking
                                    WHERE TimeTracking.State = 2)
                      SELECT tmp.Peer
                      FROM tmp
                      JOIN tmp1 ON tmp."Date" = tmp1."Date"
                      WHERE tmp."Date" = CURRENT_DATE
                      GROUP BY tmp.Peer
                      ORDER BY MAX(tmp1."Time" - tmp."Time") DESC LIMIT 1
        );
    END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM func_try_hard_peer();

-------------------->>> END <<<--------------------


-------------------->>> TWENTY-FIRST <<<--------------------
-- Determines the peers that came before the given time at least "N" times during the whole time

CREATE OR REPLACE PROCEDURE proc_came_before(IN check_time time, IN count bigint, IN ref refcursor) AS $$
    BEGIN
        OPEN ref FOR
            SELECT Peer
            FROM TimeTracking
            WHERE State = 1 AND "Time" < check_time
            GROUP BY Peer
            HAVING COUNT(Peer) >= count;
    END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL proc_came_before('15:00:00', 1, 'ref');
-- FETCH ALL IN "ref";
-- END;
--
-- BEGIN;
-- CALL proc_came_before('15:00:00', 2, 'ref');
-- FETCH ALL IN "ref";
-- END;
--
-- BEGIN;
-- CALL proc_came_before('15:00:00', 3, 'ref');
-- FETCH ALL IN "ref";
-- END;

-------------------->>> END <<<--------------------


-------------------->>> TWENTY-SECOND <<<--------------------
-- Determines the peers who left the campus more than "M" times during the last "N" days

CREATE OR REPLACE PROCEDURE proc_peers_left_campus(IN count integer, IN count1 integer, IN ref refcursor) AS $$
    BEGIN
       OPEN ref FOR
           WITH tmp AS (SELECT Peer, "Date", COUNT(*) AS cringe
                        FROM timetracking
                        WHERE State = 2 AND "Date" > (CURRENT_DATE - count)
                        GROUP BY Peer, "Date")
           SELECT Peer
           FROM tmp
           GROUP BY Peer, cringe
           HAVING cringe > count1;
    END;
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL proc_peers_left_campus(500, 1, 'ref');
-- FETCH ALL IN "ref";
-- END;
--
-- BEGIN;
-- CALL proc_peers_left_campus(500, 2, 'ref');
-- FETCH ALL IN "ref";
-- END;

-------------------->>> END <<<--------------------


-------------------->>> TWENTY-THIRD <<<--------------------
-- Determines which peer was the last to come in today

CREATE OR REPLACE FUNCTION func_last_peer()
    RETURNS TABLE (Peer varchar) AS $$
    BEGIN
        RETURN QUERY (SELECT TimeTracking.Peer
                      FROM TimeTracking
                      WHERE TimeTracking.State = 1 AND TimeTracking."Date" = CURRENT_DATE
                        AND TimeTracking."Time" = (SELECT MAX("Time")
                                                   FROM TimeTracking
                                                   WHERE TimeTracking.State = 1 AND TimeTracking."Date" = CURRENT_DATE)
        );
    END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM func_last_peer();

-------------------->>> END <<<--------------------


-------------------->>> TWENTY-FOURTH <<<--------------------
-- Determines the peer who left the campus yesterday for more than "N" minutes

CREATE OR REPLACE PROCEDURE proc_peer_left_campus(IN count integer, IN ref refcursor) AS $$
    BEGIN
        CREATE TABLE tmp (
            cringe date
        );
        INSERT INTO tmp VALUES (CURRENT_DATE - 1);
        OPEN ref FOR
            WITH tmp1 AS (SELECT Peer, "Date", MIN("Time") AS min_time
                          FROM TimeTracking
                          WHERE State = 1 AND "Date" = (SELECT cringe FROM tmp)
                          GROUP BY Peer, "Date"),
                 tmp2 AS (SELECT Peer, "Date", MAX("Time") AS max_time
                          FROM TimeTracking
                          WHERE State = 2 AND "Date" = (SELECT cringe FROM tmp)
                          GROUP BY Peer, "Date"),
                 tmp3 AS (SELECT t.Peer AS peer, t."Time" AS time
                          FROM TimeTracking AS t
                          JOIN tmp1 ON t.Peer = tmp1.Peer AND t."Time" != tmp1.min_time AND t.State = 1
                          WHERE t."Date" = (SELECT cringe FROM tmp)),
                 tmp4 AS (SELECT t.Peer AS peer, t."Time" AS time
                          FROM TimeTracking AS t
                          JOIN tmp2 ON t.Peer = tmp2.Peer AND t."Time" != tmp2.max_time AND t.State = 2
                          WHERE t."Date" = (SELECT cringe FROM tmp)),
                 tmp5 AS (SELECT *
                          FROM tmp3
                          UNION
                          SELECT *
                          FROM tmp4
                          ORDER BY time),
                 tmp6 AS (SELECT DISTINCT Peer, (SELECT MAX(time)) AS max, (SELECT MIN(time)) AS min
                          FROM tmp5
                          GROUP BY tmp5.Peer)
            SELECT Peer
            FROM tmp6
            WHERE count < (SELECT EXTRACT(hours FROM(SELECT(max - min)) * 60));
    END
$$ LANGUAGE plpgsql;

-- BEGIN;
-- CALL proc_peer_left_campus(59, 'ref');
-- FETCH ALL IN "ref";
-- END;
-- DROP TABLE tmp CASCADE;
--
-------->>> Please, create procedure proc_peer_left_campus again, 'cause table tmp deletes after call <<<--------
--
-- BEGIN;
-- CALL proc_peer_left_campus(100, 'ref');
-- FETCH ALL IN "ref";
-- END;
-- DROP TABLE tmp CASCADE;

-------------------->>> END <<<--------------------


-------------------->>> TWENTY-FIFTH <<<--------------------
-- Determines for each month the percentage of early entries

CREATE OR REPLACE FUNCTION func_percent_of_entrances()
    RETURNS TABLE (Month text, EarlyEntries real) AS $$
    BEGIN
        RETURN QUERY (WITH tmp AS (SELECT Nickname, EXTRACT(month FROM Birthday) AS birthday
                                   FROM Peers),
                           tmp1 AS (SELECT COUNT(*) AS count, birthday
                                    FROM (SELECT Peer, "Date", birthday
                                          FROM TimeTracking
                                          JOIN tmp ON TimeTracking.Peer = tmp.Nickname
                                          WHERE State = 1 AND EXTRACT(month FROM "Date") = birthday
                                          GROUP BY Peer, "Date", birthday) AS cringe
                                    GROUP BY birthday),
                           tmp2 AS (SELECT COUNT(*) AS count1, birthday
                                                 FROM (SELECT Peer, "Date", birthday
                                                       FROM TimeTracking
                                                       JOIN tmp ON TimeTracking.Peer = tmp.Nickname
                                                       WHERE State = 1 AND EXTRACT(month FROM "Date") = birthday AND "Time" < '12:00:00'
                                                       GROUP BY Peer, "Date", birthday) AS cringe1
                                                 GROUP BY birthday)
                      SELECT (CASE WHEN tmp1.birthday = 1 THEN 'January'
                              WHEN tmp1.birthday = 2 THEN 'February'
                              WHEN tmp1.birthday = 3 THEN 'March'
                              WHEN tmp1.birthday = 4 THEN 'April'
                              WHEN tmp1.birthday = 5 THEN 'May'
                              WHEN tmp1.birthday = 6 THEN 'June'
                              WHEN tmp1.birthday = 7 THEN 'July'
                              WHEN tmp1.birthday = 8 THEN 'August'
                              WHEN tmp1.birthday = 9 THEN 'September'
                              WHEN tmp1.birthday = 10 THEN 'October'
                              WHEN tmp1.birthday = 11 THEN 'November'
                              ELSE 'December'
                              END), ((tmp2.count1 * 100) / tmp1.count)::real
                      FROM tmp1
                      JOIN tmp2 ON tmp1.birthday = tmp2.birthday
                      GROUP BY tmp1.birthday, tmp2.count1, tmp1.count
        );
    END
$$ LANGUAGE plpgsql;

-- SELECT * FROM func_percent_of_entrances(); -- In February smithjan came before 12 o'clock, in March changeli came before 12 o'clock, but shondraf after 12 o'clock

-------------------->>> END <<<--------------------