# CREATE TABLE () to generate a table
DROP TABLE 
	Students,
    Courses,
    Grades,
    Sports;
## Introduction
CREATE TABLE Students (
	sid CHAR(4) PRIMARY KEY,
    name CHAR(50),
    country CHAR(50),
    age INTEGER);
DROP TABLE Students;

# Primary Key
CREATE TABLE Students (
	sid CHAR(4),
    name CHAR(50));
DROP TABLE Students;

CREATE TABLE Students (
	sid CHAR(10) PRIMARY KEY, 
    name CHAR(50));
DROP TABLE Students;

# FOREIGN KEY to refer to a relation
CREATE TABLE Students (
	sid CHAR(4) PRIMARY KEY, 
    name CHAR(50), 
    country CHAR(20), 
    age INTEGER);

CREATE TABLE Sports (
	sid CHAR(4), 
    sport CHAR(50),
    FOREIGN KEY (sid) REFERENCES Students (sid)); 
DROP TABLE Sports;

# Foreign key constraints
## R: referencing relation; S: referenced relation
## If there is a foreign key constraint for attributes of a relation R referring to the primary key of relation S, 2 violations are possible:
## (1) An insert/update to R introduces values not found in S
## (2) A delete/update to S causes some tuples of R to violate integrity
## Enforcing foreign key constraints:
## (1) Referencing relation changes: an insert/update to R that introduces a non-existent record in S must be rejected
## (2) Referenced relation changes
		-- DEFAULT: reject the modification
        -- CASCADE: make the same changes in the referencing table: delete/update the student ID
        -- SET NULL: set the PRIMARY KEY attribute to NULL in the referencing table
        
CREATE TABLE Sports (
	sid CHAR(10), 
    sport CHAR(50),
    FOREIGN KEY(sid) REFERENCES Students (sid)
    ON DELETE SET NULL # If a student id is deleted in the table Students, then student id in this table will be set to NULL
    ON UPDATE CASCADE);  # If a student id is updated in the table Students, then it will also be updated in this table
    
# Integrity constraint
-- NOT NULL --- Ensures that a column cannot have a NULL value
-- UNIQUE --- Ensures that all values in a column are different
-- PRIMARY KEY --- A combination of a NOT NULL and UNIQUE. Uniquely identifies each row in a table
-- FOREIGN KEY --- Uniquely identifies a row/record in another table
-- CHECK --- Ensures that all values in a column satisfies a specific condition
-- DEFALUT --- Sets a default value for a column hen no value is specified
-- INDEX --- Used to create and retrieve data from the database very quickly

## NOT NULL and CHECK 
SET FOREIGN_KEY_CHECKS=0; # To disable the foreign key check so that we can delete the table with a foreign key
DROP TABLE Students;
SET FOREIGN_KEY_CHECKS=1; # To enable the foreign key check
CREATE TABLE Students (
	sid CHAR(16) PRIMARY KEY,
    name CHAR(50) NOT NULL,
    country CHAR(50),
    age INTEGER CHECK (age >=0 AND age<200)); 
### If you need multiple constrains, don't need a AND to connect 2 constrains

# Modify a table -- INSERT
## INSERT INTO <relation> VALUES <values>
INSERT INTO Students
VALUES ('000001', 'Achilles', 'Greece', 20);

INSERT INTO Students (name, sid, country, age)
VALUES('James', '000002', 'USA', 25);

## INSERT a tuple using the DEFAULT constraint: leave it blank or fill in with DEFAULT
SET FOREIGN_KEY_CHECKS=0; 
DROP TABLE Students;
SET FOREIGN_KEY_CHECKS=1; 
CREATE TABLE Students (
	sid CHAR(16) PRIMARY KEY,
    name CHAR(50) DEFAULT 'Student',
    country CHAR(50) DEFAULT 'United Kingdom',
    age INTEGER DEFAULT 20);

INSERT INTO Students
VALUES 
	('000001', 'Achilles', 'Greece', 20),
    ('000002', 'James', 'USA', 25);

INSERT INTO Students (sid)
VALUES ('000003');

## INSERT multiple tuples - one by one
INSERT INTO students (sid, name, age) 
VALUES
	('000005', 'Paul', 24), 
	('000006', 'Jay', 24);

## Insert multiple tuples - make use of a subquery
CREATE TABLE Old_Students
	(sid CHAR(16) PRIMARY KEY,
     name VARCHAR(50) DEFAULT 'Student',
     country CHAR(50) DEFAULT 'United Kingdom',
     age INTEGER DEFAULT 25);
     
INSERT INTO Old_Students
VALUES 
('000007', 'James', 'CHINA', 20),
('000008', 'Rice', 'Japan', DEFAULT);

INSERT INTO Students (sid)
SELECT sid
FROM Old_Students;

# Delete tuples
## Deleting a tuple
INSERT INTO Sports
VALUES 
	('000005', 'Basketball'),
    ('000006', 'Football'),
    ('000007', 'Tennis');

DELETE FROM sports
WHERE sid = '000007' AND sport = 'Tennis';

## Deleting multiple tuples using subqueries
## Example 1
DELETE FROM Sports
WHERE sid IN (
	SELECT sid
    FROM Students
    WHERE country = 'United Kingdom');

## Example 2
### Explicit CROSS JOIN
DELETE FROM Students
WHERE sid IN (
	SELECT DISTINCT S1.sid
    FROM Students S1
    CROSS JOIN Students S2
    ON S1.sid = S1.sid
    WHERE S1.sid <> S2.sid 
    AND S1.country = S2.country);

### Implicit CROSS JOIN
DELETE FROM Students
WHERE sid IN (
	SELECT DISTINCT S1.sid
    FROM Students S1, Students S2
    WHERE S1.sid <> S2.sid AND S1.country = S2.country);

# Update a tuple: UPDATE <relation> SET <list of attribute assignments> WHERE <condition on tuples>;
UPDATE Students
SET age = 26
WHERE sid = '000006';

# View
-- A view is a virtual table/relation, that is defined on base tables
-- Views can be regarded as query results, which are not stored in the database but in the workspace

## Create a view: CREATE VIEW <name of view> AS <query> 
CREATE VIEW Students_UK AS
SELECT *
FROM Students
WHERE country = "United Kingdom" 
AND age >20;

## Query a view: a view can queried as if it wasa base table
SELECT sid
FROM Students_uk;

## Modify a VIEW: 
-- As VIEWs are created from other tables
-- Updating VIEWs can have consequences to the base tables
-- So, it's preferable to update base tables instead
UPDATE Students_uk
SET name = 'Kobayashi'
WHERE  sid = '000005';

DROP VIEW Students_uk;

# INDEX
## Create an index 
-- Create from an existing table
CREATE INDEX idx_age
ON Students (age);

-- Create with a new table
DROP TABLE Old_students;
CREATE TABLE Old_students (
	sid CHAR(4) PRIMARY KEY,
    name CHAR(50),
    country CHAR(50),
    age INTEGER,
    INDEX idx_age (age));

## Check indexes
SHOW INDEX
FROM Students;