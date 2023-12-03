CREATE temp TABLE IF NOT EXISTS test_range(
    start_point double precision NOT NULL,
    end_point double precision NOT NULL,
    level boolean NOT NULL DEFAULT TRUE
);

CREATE OR REPLACE FUNCTION invoke_test(_expected double precision)
    RETURNS void
    AS $$
DECLARE
    result double precision;
BEGIN
    result := sum_overlapped_ranges('SELECT DISTINCT * FROM test_range ORDER BY start_point ASC');
    RAISE NOTICE 'result is % and expected %', result, _expected;
    IF result != _expected THEN
        RAISE EXCEPTION 'result different from expected';
    END IF;
END
$$
LANGUAGE plpgsql;

DO $$
BEGIN
    DELETE FROM test_range;
    INSERT INTO test_range(start_point, end_point, level)
        VALUES(-2, 6, TRUE),
(-6, -2, FALSE),
(6, 10, FALSE),
(10, 12, TRUE);
    PERFORM
        invoke_test(10);
    DELETE FROM test_range;
    INSERT INTO test_range(start_point, end_point, level)
        VALUES(-2, -6, TRUE),
(2, 3, TRUE),
(-5, -1, TRUE);
    PERFORM
        invoke_test(5);
    DELETE FROM test_range;
    INSERT INTO test_range(start_point, end_point, level)
        VALUES(0, 10, TRUE),
(3, 5, FALSE),
(3, 5, FALSE),
(4, 11, TRUE);
    PERFORM
        invoke_test(9);
    DELETE FROM test_range;
    INSERT INTO test_range(start_point, end_point, level)
        VALUES(0, 10, TRUE),
(3, 5, FALSE),
(-1, 11, FALSE),
(4, 11, TRUE);
    PERFORM
        invoke_test(0);
    DELETE FROM test_range;
    INSERT INTO test_range(start_point, end_point, level)
        VALUES(-2, 3, FALSE),
(10, 15, FALSE),
(0, 30, TRUE),
(4, 6, FALSE),
(27, 30, FALSE);
    PERFORM
        invoke_test(17);
    DELETE FROM test_range;
    INSERT INTO test_range(start_point, end_point, level)
        VALUES(-2, 3, FALSE),
(10, 15, FALSE);
    PERFORM
        invoke_test(0);
    DELETE FROM test_range;
    INSERT INTO test_range(start_point, end_point, level)
        VALUES(2, 2, TRUE);
    PERFORM
        invoke_test(0);
    DELETE FROM test_range;
    PERFORM
        invoke_test(0);
    DELETE FROM test_range;
    INSERT INTO test_range(start_point, end_point, level)
        VALUES(-2, 6, TRUE),
(5, 6, FALSE),
(9, 10, FALSE),
(12, 14, FALSE);
    PERFORM
        invoke_test(7);
    DELETE FROM test_range;
    INSERT INTO test_range(start_point, end_point, level)
        VALUES(-4, -3, TRUE),
(0, 20, TRUE),
(21, 25, TRUE),
(26, 30, TRUE),
(31, 35, TRUE),
(-1, 2, FALSE),
(4, 8, FALSE),
(10, 12, FALSE),
(19, 22, FALSE);
    PERFORM
        invoke_test(23);
    DELETE FROM test_range;
    INSERT INTO test_range(start_point, end_point, level)
        VALUES(2, 10, TRUE),
(20, 100, TRUE),
(0, 1, FALSE),
(30, 40, FALSE),
(50, 60, FALSE);
    PERFORM
        invoke_test(68);
    DELETE FROM test_range;
    INSERT INTO test_range(start_point, end_point, level)
        VALUES(2, 10, TRUE),
(20, 100, TRUE),
(0, 1, FALSE),
(11, 14, FALSE),
(30, 40, FALSE),
(50, 60, FALSE);
    PERFORM
        invoke_test(68);
    DELETE FROM test_range;
    INSERT INTO test_range(start_point, end_point, level)
        VALUES(2, 10, TRUE),
(20, 100, TRUE),
(300, 400, TRUE),
(0, 1, FALSE),
(11, 14, FALSE),
(15, 18, FALSE),
(30, 40, FALSE),
(50, 60, FALSE),
(150, 160, FALSE),
(170, 180, FALSE),
(280, 320, FALSE);
    PERFORM
        invoke_test(148);
    DELETE FROM test_range;
    INSERT INTO test_range(start_point, end_point, level)
        VALUES(2, 10, TRUE),
(20, 100, TRUE),
(0, 1, FALSE),
(-5, -2, FALSE);
    PERFORM
        invoke_test(88);
    DELETE FROM test_range;
    INSERT INTO test_range(start_point, end_point, level)
        VALUES(-4, -3, TRUE),
(0, 3, TRUE),
(5, 8, TRUE),
(10, 15, TRUE),
(-2, 14, FALSE);
    PERFORM
        invoke_test(2);
    DELETE FROM test_range;
    INSERT INTO test_range(start_point, end_point, level)
        VALUES(-4, -3, TRUE),
(0, 3, TRUE),
(5, 8, TRUE),
(10, 15, TRUE),
(-4, 15, FALSE);
    PERFORM
        invoke_test(0);
    DELETE FROM test_range;
    INSERT INTO test_range(start_point, end_point, level)
        VALUES(-4, -3, TRUE),
(0, 3, TRUE),
(5, 8, TRUE),
(10, 15, TRUE),
(-5, 16, FALSE);
    PERFORM
        invoke_test(0);
END
$$
LANGUAGE 'plpgsql'
