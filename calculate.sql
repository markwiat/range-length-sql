CREATE OR REPLACE FUNCTION down_ended(_up_start double precision, _up_end double precision, _down_start double precision, _down_end double precision)
    RETURNS TABLE(
        accumulated double precision,
        new_up_start double precision,
        new_up_end double precision
    )
    AS $$
DECLARE
    acc double precision := 0;
    up_start double precision;
    up_end double precision;
BEGIN
    IF _down_start >= _up_end THEN
        acc = _up_end - _up_start;
    ELSIF _down_end <= _up_start THEN
        up_start = _up_start;
        up_end = _up_end;
    ELSIF _down_start <= _up_start
            AND _down_end < _up_end THEN
            up_start = _down_end;
        up_end = _up_end;
    ELSIF _down_start > _up_start THEN
        acc = _down_start - _up_start;
        IF _down_end < _up_end THEN
            up_start = _down_end;
            up_end = _up_end;
        END IF;
    END IF;
    RETURN QUERY
    SELECT
        acc,
        up_start,
        up_end;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION up_ended(_up_start double precision, _up_end double precision, _down_start double precision, _down_end double precision)
    RETURNS double precision
    AS $$
DECLARE
    acc double precision := 0;
BEGIN
    IF _down_start >= _up_end OR _down_end <= _up_start THEN
        acc = _up_end - _up_start;
    ELSIF _down_start <= _up_start
            AND _down_end < _up_end THEN
            acc = _up_end - _down_end;
    ELSIF _down_start > _up_start THEN
        acc = _down_start - _up_start;
        IF _down_end < _up_end THEN
            acc = acc +(_up_end - _down_end);
        END IF;
    END IF;
    RETURN acc;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sum_overlapped_ranges(_query_ordered_by_start text)
    RETURNS double precision
    AS $$
DECLARE
    total double precision := 0;
    acc double precision;
    current_start double precision;
    current_end double precision;
    current_level boolean;
    start_up double precision;
    end_up double precision;
    start_down double precision;
    end_down double precision;
BEGIN
    FOR current_start,
    current_end,
    current_level IN EXECUTE _query_ordered_by_start LOOP
        IF current_level IS TRUE THEN
            IF start_up IS NULL THEN
                start_up = current_start;
                end_up = current_end;
            ELSIF current_start <= end_up THEN
                IF current_end > end_up THEN
                    end_up = current_end;
                END IF;
            ELSE
                IF start_down IS NOT NULL THEN
                    total = total + up_ended(start_up, end_up, start_down, end_down);
                ELSE
                    total = total +(end_up - start_up);
                END IF;
                start_up = current_start;
                end_up = current_end;
            END IF;
        END IF;
        IF current_level IS FALSE THEN
            IF start_down IS NULL THEN
                start_down = current_start;
                end_down = current_end;
            ELSIF current_start <= end_down THEN
                IF current_end > end_down THEN
                    end_down = current_end;
                END IF;
            ELSE
                IF start_up IS NOT NULL THEN
                    SELECT
                        *
                    FROM
                        down_ended(start_up, end_up, start_down, end_down) INTO acc,
    start_up,
    start_down;
                    total = total + acc;
                END IF;
                start_down = current_start;
                end_down = current_end;
            END IF;
        END IF;
    END LOOP;
    IF start_up IS NOT NULL THEN
        IF start_down IS NOT NULL THEN
            total = total + up_ended(start_up, end_up, start_down, end_down);
        ELSE
            total = total +(end_up - start_up);
        END IF;
    END IF;
    RETURN total;
END
$$
LANGUAGE plpgsql;

