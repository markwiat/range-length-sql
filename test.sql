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
END
$$
LANGUAGE 'plpgsql'
