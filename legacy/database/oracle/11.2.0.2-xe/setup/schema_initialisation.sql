CREATE USER TRAVELBUDDY IDENTIFIED BY welcome DEFAULT TABLESPACE USERS QUOTA UNLIMITED ON USERS;
GRANT CONNECT, RESOURCE TO TRAVELBUDDY;

---------------------
--- FlightSpecial ---
---------------------

-- Create a sequence for flightspecial
CREATE SEQUENCE travelbuddy.flightspecial_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Create flightspecial table
CREATE TABLE travelbuddy.flightspecial (
    id NUMBER PRIMARY KEY,
    header VARCHAR2(255) DEFAULT '' NOT NULL,
    body VARCHAR2(255),
    origin VARCHAR2(255),
    originCode VARCHAR2(6),
    destination VARCHAR2(255),
    destinationCode VARCHAR2(6),
    cost NUMBER NOT NULL,
    expiryDate NUMBER DEFAULT (TRUNC((SYSDATE - TO_DATE('1970-01-01', 'YYYY-MM-DD')) * 86400 * 1000))
);

-- Create a trigger to automatically insert the next value from the sequence
CREATE OR REPLACE TRIGGER travelbuddy.flightspecial_trigger
BEFORE INSERT ON travelbuddy.flightspecial
FOR EACH ROW
BEGIN
    :new.id := flightspecial_seq.NEXTVAL;
END;
/

INSERT INTO travelbuddy.flightspecial (header, body, origin, originCode, destination, destinationCode, cost, expiryDate)
VALUES (
    'London to Paris',
    'Jewel of the East',
    'London',
    'LHR',
    'Paris',
    'CDG',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 200)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 30))) * 86400000 AS GMT_EPOCH FROM DUAL)
);


-- noinspection SqlNoDataSourceInspection
INSERT INTO travelbuddy.flightspecial (header, body, origin, originCode, destination, destinationCode, cost, expiryDate)
VALUES (
    'Paris to London',
    'Weekend getaway!',
    'Paris',
    'CDG',
    'London',
    'LHR',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 200)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 30))) * 86400000 AS GMT_EPOCH FROM DUAL)
);


INSERT INTO travelbuddy.flightspecial (header, body, origin, originCode, destination, destinationCode, cost, expiryDate)
VALUES (
    'Dubai to Cairo',
    'Middle East adventure',
    'Dubai',
    'DXB',
    'Cairo',
    'CAI',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 200)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 30))) * 86400000 AS GMT_EPOCH FROM DUAL)
);

INSERT INTO travelbuddy.flightspecial (header, body, origin, originCode, destination, destinationCode, cost, expiryDate)
VALUES (
    'Melbourne to Hawaii',
    'Escape to the sun this winter',
    'Melbourne',
    'MEL',
    'Hawaii',
    'HNL',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 200)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 30))) * 86400000 AS GMT_EPOCH FROM DUAL)
);

INSERT INTO travelbuddy.flightspecial (header, body, origin, originCode, destination, destinationCode, cost, expiryDate)
VALUES (
    'Buenos Aires to Rio',
    'Time to Carnival!',
    'Buenos Aires',
    'EZE',
    'Rio',
    'GIG',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 200)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 30))) * 86400000 AS GMT_EPOCH FROM DUAL)
);

INSERT INTO travelbuddy.flightspecial (header, body, origin, originCode, destination, destinationCode, cost, expiryDate)
VALUES (
    'Sydney to Rome',
    'An Italian classic',
    'Sydney',
    'SYD',
    'Rome',
    'FCO',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 200)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 30))) * 86400000 AS GMT_EPOCH FROM DUAL)
);

INSERT INTO travelbuddy.flightspecial (header, body, origin, originCode, destination, destinationCode, cost, expiryDate)
VALUES (
    'Melbourne to Sydney',
    'Well trodden path',
    'Melbourne',
    'MEL',
    'Sydney',
    'SYD',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 200)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 30))) * 86400000 AS GMT_EPOCH FROM DUAL)
);

INSERT INTO travelbuddy.flightspecial (header, body, origin, originCode, destination, destinationCode, cost, expiryDate)
VALUES (
    'Hong Kong to Kuala Lumpur',
    'Hop step and a jump',
    'Hong Kong',
    'HKG',
    'Kuala Lumpur',
    'KUL',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 200)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 30))) * 86400000 AS GMT_EPOCH FROM DUAL)
);

INSERT INTO travelbuddy.flightspecial (header, body, origin, originCode, destination, destinationCode, cost, expiryDate)
VALUES (
    'Lisbon to Madrid',
    'Spanish adventure',
    'Lisbon',
    'LIS',
    'Madrid',
    'MAD',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 200)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 30))) * 86400000 AS GMT_EPOCH FROM DUAL)
);

INSERT INTO travelbuddy.flightspecial (header, body, origin, originCode, destination, destinationCode, cost, expiryDate)
VALUES (
    'Aswan to Cairo',
    'An experience of a lifetime',
    'Aswan',
    'ASW',
    'Cairo',
    'CAI',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 200)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 30))) * 86400000 AS GMT_EPOCH FROM DUAL)
);

INSERT INTO travelbuddy.flightspecial (header, body, origin, originCode, destination, destinationCode, cost, expiryDate)
VALUES (
    'New York to London',
    'Trans-Atlantic',
    'New York',
    'JFK',
    'London',
    'LHR',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 200)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 30))) * 86400000 AS GMT_EPOCH FROM DUAL)
);

COMMIT;

--------------------
--- HotelSpecial ---
--------------------

-- Create a sequence for hotelspecial
CREATE SEQUENCE travelbuddy.hotelspecial_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Create hotelspecial table
CREATE TABLE travelbuddy.hotelspecial (
    id NUMBER PRIMARY KEY,
    hotel VARCHAR2(255) DEFAULT '' NOT NULL,
    description VARCHAR2(255),
    location VARCHAR2(255),
    cost NUMBER NOT NULL,
    expiryDate NUMBER DEFAULT (TRUNC((SYSDATE - TO_DATE('1970-01-01', 'YYYY-MM-DD')) * 86400 * 1000))
);

-- Create a trigger to automatically insert the next value from the sequence
CREATE OR REPLACE TRIGGER travelbuddy.hotelspecial_trigger
BEFORE INSERT ON travelbuddy.hotelspecial
FOR EACH ROW
BEGIN
    :new.id := hotelspecial_seq.NEXTVAL;
END;
/


INSERT INTO travelbuddy.hotelspecial (hotel, description, location, cost, expiryDate)
VALUES (
    'Sommerset Hotel',
    'Minimum stay 3 nights',
    'Sydney',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 1000)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 7))) * 86400000 AS GMT_EPOCH FROM DUAL)
);

INSERT INTO travelbuddy.hotelspecial (hotel, description, location, cost, expiryDate)
VALUES (
    'Freedmom Apartments',
    'Pets allowed!',
    'Sydney',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 1000)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 7))) * 86400000 AS GMT_EPOCH FROM DUAL)
);

INSERT INTO travelbuddy.hotelspecial (hotel, description, location, cost, expiryDate)
VALUES (
    'Studio City',
    'Minimum stay one week',
    'Los Angeles',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 1000)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 7))) * 86400000 AS GMT_EPOCH FROM DUAL)
);

INSERT INTO travelbuddy.hotelspecial (hotel, description, location, cost, expiryDate)
VALUES (
    'Le Fleur Hotel',
    'Not available weekends',
    'Los Angeles',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 1000)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 7))) * 86400000 AS GMT_EPOCH FROM DUAL)
);

INSERT INTO travelbuddy.hotelspecial (hotel, description, location, cost, expiryDate)
VALUES (
    'Classic Hotel',
    'Includes breakfast',
    'Dallas',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 1000)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 7))) * 86400000 AS GMT_EPOCH FROM DUAL)
);

INSERT INTO travelbuddy.hotelspecial (hotel, description, location, cost, expiryDate)
VALUES (
    'Groundhog Suites',
    'Internet access included',
    'Florida',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 1000)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 7))) * 86400000 AS GMT_EPOCH FROM DUAL)
);

INSERT INTO travelbuddy.hotelspecial (hotel, description, location, cost, expiryDate)
VALUES (
    'Sophmore Suites',
    'Maximum 2 people per room',
    'London',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 1000)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 7))) * 86400000 AS GMT_EPOCH FROM DUAL)
);

INSERT INTO travelbuddy.hotelspecial (hotel, description, location, cost, expiryDate)
VALUES (
    'Hotel Sandra',
    'Minimum stay two nights',
    'Cairo',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 1000)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 7))) * 86400000 AS GMT_EPOCH FROM DUAL)
);

INSERT INTO travelbuddy.hotelspecial (hotel, description, location, cost, expiryDate)
VALUES (
    'Apartamentos de Nestor',
    'Pool and spa access included',
    'Madrid',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 1000)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 7))) * 86400000 AS GMT_EPOCH FROM DUAL)
);

INSERT INTO travelbuddy.hotelspecial (hotel, description, location, cost, expiryDate)
VALUES (
    'Kangaroo Hotel',
    'Maximum 2 people per room',
    'Manchester',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 1000)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 7))) * 86400000 AS GMT_EPOCH FROM DUAL)
);

INSERT INTO travelbuddy.hotelspecial (hotel, description, location, cost, expiryDate)
VALUES (
    'EasyStay Apartments',
    'Minimum stay one week',
    'Melbourne',
    50 + FLOOR(DBMS_RANDOM.VALUE(0, 1000)),
    -- 12 Hours + Random value between 0 and 7 days
    (SELECT (CAST(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP) AS DATE) - TO_DATE('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') + 0.5 + FLOOR(DBMS_RANDOM.VALUE(0, 7))) * 86400000 AS GMT_EPOCH FROM DUAL)
);

COMMIT;
