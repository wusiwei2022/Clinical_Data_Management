# Introduction: we are going to use the sample data cdm_data for this tutorial
-- (1) Firstly, we need to create a database cdm_data
-- (2) Secondly, we import the 4 tables as the 4 relations of the database using import wizard

USE CDM_DATA;

# SELECT FROM WHERE: 
SELECT name 
FROM Students
WHERE country = 'Greece';

SELECT * # * stands for all fields in the relation 
FROM Students
WHERE country = 'Greece';

## AS <new name> to rename the field
SELECT sid, name AS nam
FROM Students
WHERE country = 'Greece';

## Use Expression in SELECT clause
SELECT 
	name, 
    course,
    grade * 0.04 AS gpa
FROM Grades;

# Complex conditions in WHERE clause
## WHERE clause syntax
--- Operation --- Operators  
--- Comparsion --- =, <>, <, >, >=, <=, IN, NOT IN 
--- Arithmetic operations --- *, /, +, -
--- Comparison on strings, dates, and times --- BETWEEN AND
--- Pattern matching --- LIKE

SELECT grade 
FROM Grades
WHERE name = 'Achilles' AND course = 'Archery';

## String pattern matching with wildcards: LIKE, NOT LIKE, % = anything, _ = any single character  
SELECT name
FROM Students
WHERE name LIKE 'Aga%';

SELECT name
FROM Students
WHERE sid LIKE '____40';

## How MySQL handles NULL 
SELECT name
FROM Students
WHERE age < 20 OR age >= 20; 
## The query won't return those with a NULL age

## Three-valued logic
-- The logic of conditions in SQL is 3-valued: TRUE, FALSE, UNKNOWN
-- Comparing to NULL: When any value is compared with NULL, the return value is UNKNOWN
-- WHERE clause: A query only returns a tuple if its value for the WHERE clause is TRUE (not FALSE or NULL)

## Return NULL value with IS NULL
SELECT name
FROM Students
WHERE age < 20 OR age >= 20 OR age IS NULL;

# Multi-relation query
## Implicit INNER JOIN
SELECT Sports.sport, Students.name
FROM Students, Sports
WHERE Students.country = 'United Kingdom' 
AND Students.sid = Sports.sid;

## Explicit INNER JOIN
SELECT Sports.sport, Students.name
FROM Students
INNER JOIN Sports
ON Students.sid = Sports.sid
WHERE Students.country = 'United Kingdom';

## JOIN
-- INNER JOIN: returns records with matching values in both tables
-- LEFT JOIN: returns all records from the left table
-- RIGHT JOIN: returns all records from the right table
-- FULL OUTER JOIN: returns records where there is a match either in the left or right table

# SELECT DISTINCT:  to remove duplicate rows before output
SELECT DISTINCT Sports.sports
FROM Students, Sports
WHERE Students.country = 'France' AND Students.sid = Sports.sid;

SELECT S.name
FROM Students S, Grades G
WHERE S.sid = G.sid
GROUP BY S.sid 
HAVING COUNT(G.cid)>=1;

# Multi-relation query
## Implicit query
SELECT Grades.grade
FROM Students, Grades, Courses
WHERE Students.country = 'Spain'
	AND Courses.department = 'Science'
    AND Students.sid = Grades.sid
    AND Grades.cid = Courses.cid;

# Alias: to rename relations
# ORDER BY: DESC to sort in descending order
SELECT G.grade
FROM Students S, Grades G, Courses C
WHERE S.country = 'Spain'
AND C.department = 'Science'
AND S.sid = G.sid
AND G.sid = C.cid
ORDER BY G.grade DESC;

# Nested query connected by IN
## Nested query with IN operator
SELECT S.country
FROM Students S
WHERE S.sid IN
	(SELECT G.sid 
    FROM Grades G
    WHERE G.course = 'Mathematics');

SELECT S.country
FROM Students S
WHERE S.sid IN 
	(SELECT G.sid 
    FROM Grades G, Sports SP
    WHERE G.course = 'Mathematics'
    AND SP.sport = 'Football'
    AND G.sid = SP.sid);

## Set comparison operators
-- x IN R: tests whether x is a member of set R
-- EXISTS R: tests whether R is non-empty
-- x =, >, < ANY(R) tests whether x equals to /greater than/ less than at least one tuple in relation R. 
-- x >, < ALL(R) tests whether x is larger/less than every tuple in the relation release savepoint

## ALL operator
SELECT sid 
FROM Grades
WHERE grade >= 
ALL(SELECT grade 
	FROM Grades);

# Set manipulations: UNION, INTERSECTION, and difference
--- (subquery) UNION (subquery): only return one copy
--- (subquery) UNION ALL (subquery): would return duplicates 
--- (subquery) INTERSECT (subquery)
--- (subquery) EXCEPT (subquery)

(SELECT G.sid 
FROM Grades G
WHERE G.course = 'Mathematics')
UNION
(SELECT SP.sid 
FROM Sports SP
WHERE SP.sport = 'Football');

(SELECT G.sid 
FROM Grades G
WHERE G.course = 'Mathematics')
INTERSECT
(SELECT SP.sid 
FROM Sports SP
WHERE SP.sport = 'Football');

## Alternative of INTERSECT with INNER JOIN
SELECT G.sid
FROM Grades G, Sports SP
WHERE G.course = 'Mathematics'
AND SP.sport = 'Football' 
AND G.sid = SP.sid;

SELECT G.sid
FROM Grades G 
INNER JOIN Sports SP
ON G.sid = SP.sid
WHERE G.course = 'Mathematics'
AND SP.sports = 'Football';

# Aggregate Operators
--- COUNT (DISTINCT <A>)
--- SUM (DISTINCT <A>)
--- AVG (DISTINCT <A>)
--- MAX (<A>)
--- MIN (<A>)

SELECT AVG(S.age)
FROM Students S;

SELECT AVG(S.age)
FROM Students S
WHERE S.country = 'Greece';

SELECT S.name, S.age
FROM Students S
WHERE S.age = 
	(SELECT MIN(S2.age)
    FROM Students S2);
    
SELECT S.name, S.age
FROM Students S
WHERE S.age <= 
	ALL(SELECT S2.age 
		FROM Students S2);

SELECT COUNT(*)
FROM Students S
WHERE S.country = 'China';

SELECT COUNT(DISTINCT S.name)
FROM Students S
WHERE S.country = 'China'; 

## NULL values don't contribute to sum, average or count, and can never be the minimum or maximum of a column
## The only exception: If all values in a column are NULL, then the results of the aggregation is NULL

# GROUP BY & HAVING: 
-- Only aggregated variable by GROUP BY & Aggregate operator like MAX、MIN、SUM、AVG can be used
SELECT 
	AVG(S.age)
FROM Students S 
GROUP BY S.country
HAVING S.country LIKE 'United%';

SELECT AVG(S.age)
FROM Students S
GROUP BY S.country
HAVING COUNT(*)>=2;

## GROUP BY vs Nested query
SELECT S.name
FROM Students S
WHERE (
	SELECT COUNT(G.cid)
	FROM Grades G
    WHERE G.sid = S.sid
	)>=1; ## Subquery (Not recommended)

SELECT S.name
FROM Students S, Grades G 
WHERE S.sid = G.sid
GROUP BY G.cid
HAVING COUNT(G.cid) >= 1; ## HAVING

## GROUP BY and HAVING computation steps
-- SELECT S
-- FROM R1, ..., Rn
-- WHERE C1
-- GROUP BY a1, ..., ak
-- HAVING C2

-- (1) Compute the FROM-WHERE part, obtains a table with all attributes in R1, ..., Rn satisfying C1;
-- (2) Group that table obtained in (1) by the attributes a1, ..., ak; 
-- (3) Keep only groups satisfying C2;
-- (4) Compute aggregates in S and returns the result;