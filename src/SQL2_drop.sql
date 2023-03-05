-------------------->>> FIRST <<<--------------------
-- Drops tables and procedures from first part
DROP TABLE Peers CASCADE;
DROP TABLE Tasks CASCADE;
DROP TABLE Checks CASCADE;
DROP TABLE P2P CASCADE;
DROP TABLE Verter CASCADE;
DROP TABLE TransferredPoints CASCADE;
DROP TABLE Friends CASCADE;
DROP TABLE Recommendations CASCADE;
DROP TABLE XP CASCADE;
DROP TABLE TimeTracking CASCADE;
DROP PROCEDURE proc_export(varchar, text, text) CASCADE;
DROP PROCEDURE proc_import(varchar, text, text) CASCADE;

-------------------->>> END <<<--------------------


-------------------->>> SECOND <<<--------------------
-- Drops procedures and functions from second part

DROP PROCEDURE proc_p2p_review(varchar, varchar, varchar, check_status, time) CASCADE;
DROP PROCEDURE proc_add_verter(varchar, varchar, check_status, time) CASCADE;
DROP FUNCTION func_trg_transferredpoints() CASCADE;
DROP FUNCTION func_trg_xp() CASCADE;

-------------------->>> END <<<--------------------


-------------------->>> THIRD <<<--------------------
-- Drops procedures and functions from third part

DROP FUNCTION func_points_amount() CASCADE;
DROP FUNCTION func_xp() CASCADE;
DROP FUNCTION func_peers_in_campus(date) CASCADE;
DROP FUNCTION func_percent_of_projects() CASCADE;
DROP FUNCTION func_change_points() CASCADE;
DROP FUNCTION func_change_points_from_first_function() CASCADE;
DROP FUNCTION func_the_most_testable_task() CASCADE;
DROP FUNCTION func_duration_of_the_last_p2p() CASCADE;
DROP PROCEDURE proc_peers_made_tasks(varchar, refcursor) CASCADE;
DROP FUNCTION func_recommended_peer() CASCADE;
DROP PROCEDURE proc_peers_percent(text, text, OUT real, OUT real, OUT real, OUT real) CASCADE;
DROP PROCEDURE proc_count_friends(integer, refcursor) CASCADE;
DROP FUNCTION func_birthday() CASCADE;
DROP FUNCTION func_xp_sum() CASCADE;
DROP PROCEDURE proc_first_and_second_success_third_fail(varchar, varchar, varchar, refcursor) CASCADE;
DROP FUNCTION func_parent_task() CASCADE;
DROP PROCEDURE proc_lucky_day(bigint, refcursor) CASCADE;
DROP FUNCTION func_max_tasks() CASCADE;
DROP FUNCTION func_max_xp() CASCADE;
DROP FUNCTION func_try_hard_peer() CASCADE;
DROP PROCEDURE proc_came_before(time, bigint, refcursor) CASCADE;
DROP PROCEDURE proc_peers_left_campus(integer, integer, refcursor) CASCADE;
DROP FUNCTION func_last_peer() CASCADE;
DROP PROCEDURE proc_peer_left_campus(integer, refcursor) CASCADE;
DROP FUNCTION func_percent_of_entrances() CASCADE;

-------------------->>> END <<<--------------------


-------------------->>> FOURTH <<<--------------------
-- Drops procedures and functions from fourth part

DROP PROCEDURE proc_remove_table(varchar) CASCADE;
DROP PROCEDURE proc_count_functions(OUT bigint) CASCADE;
DROP PROCEDURE proc_remove_triggers(OUT bigint) CASCADE;
DROP PROCEDURE proc_name_and_type(varchar, refcursor) CASCADE;

-------------------->>> END <<<--------------------


-------------------->>> FIFTH <<<--------------------
-- Drops type from first part

DROP TYPE check_status CASCADE;

-------------------->>> END <<<--------------------