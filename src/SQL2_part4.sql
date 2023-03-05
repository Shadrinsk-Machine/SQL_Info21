-------------------->>> FIRST <<<--------------------
-- Deletes tables that begin with an input parameter

-------->>> Firstly, you need to create tables <<<--------

-- CREATE TABLE tmp_table1 (
--     peer varchar,
--     birthday date
-- );
--
-- CREATE TABLE tmp_table2 (
--     peer varchar,
--     birthday date
-- );
--
-- CREATE TABLE tmp_table3 (
--     peer varchar,
--     birthday date
-- );

CREATE OR REPLACE PROCEDURE proc_remove_table(IN name varchar) AS $$
    BEGIN
        FOR name IN
            SELECT table_name
            FROM information_schema.tables
            WHERE table_name LIKE CONCAT(name, '%') AND table_schema = 'public'
        LOOP
            EXECUTE CONCAT('DROP TABLE ', name);
        END LOOP;
    END;
$$ LANGUAGE plpgsql;

CALL proc_remove_table('tmp');

-------------------->>> END <<<--------------------


-------------------->>> SECOND <<<--------------------
-- Outputs the number of functions with parameters in Result and the list of functions in Output

CREATE OR REPLACE PROCEDURE proc_count_functions(OUT count bigint) AS $$
    DECLARE i text;
    BEGIN
        CREATE VIEW view AS (
            WITH tmp AS
                     (SELECT CONCAT(routines.routine_name, ' ---> ', '{', parameters.parameter_mode, ', ', parameters.parameter_name, ', ', parameters.data_type, '}') AS func
                      FROM information_schema.routines
                      JOIN information_schema.parameters ON routines.specific_name = parameters.specific_name
                      WHERE routines.specific_schema = 'public' AND routine_type = 'FUNCTION' AND parameter_name IS NOT NULL)
            SELECT CONCAT(func, ' ') AS cringe
            FROM tmp
            GROUP BY func);
        FOR i IN (SELECT cringe FROM view)
            LOOP
                RAISE NOTICE '%', i;
            END LOOP;
        SELECT COUNT(*)
        INTO count
        FROM view;
        DROP VIEW view;
    END
$$ LANGUAGE plpgsql;

-- CALL proc_count_functions(NULL);

-------------------->>> END <<<--------------------


-------------------->>> THIRD <<<--------------------
-- Outputs the number of all triggers and removes them

CREATE OR REPLACE PROCEDURE proc_remove_triggers(OUT count bigint) AS $$
    DECLARE name_of_trigger varchar; table_of_trigger varchar;
    BEGIN
        SELECT DISTINCT COUNT(trigger_name)
        INTO count
        FROM information_schema.triggers;
        FOR name_of_trigger, table_of_trigger IN
            (SELECT DISTINCT trigger_name, event_object_table FROM information_schema.triggers)
        LOOP
            EXECUTE CONCAT('DROP TRIGGER ', name_of_trigger, ' ON ', table_of_trigger);
        END LOOP;
    END;
$$ LANGUAGE plpgsql;

-------->>> I have triggers on "XP" and "P2P tables <<<--------

-- CALL proc_remove_triggers(NULL);

-------------------->>> END <<<--------------------


-------------------->>> FOURTH <<<--------------------
-- Outputs all procedures and functions that contain input parameter

CREATE OR REPLACE PROCEDURE proc_name_and_type(IN name varchar, IN ref refcursor) AS $$
    BEGIN
        OPEN ref FOR
            SELECT routine_name, routine_type
            FROM information_schema.routines
            WHERE routines.specific_schema = 'public' AND routine_definition LIKE CONCAT('%', name, '%');
    END;
$$ LANGUAGE plpgsql;

-- BEGIN;
--     CALL proc_name_and_type('max', 'ref');
--     FETCH ALL IN "ref";
-- END;

-- BEGIN;
--     CALL proc_name_and_type('c', 'ref');
--     FETCH ALL IN "ref";
-- END;

-------------------->>> END <<<--------------------