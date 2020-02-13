DROP TABLE IF EXISTS JOHNS;
DROP VIEW IF EXISTS AverageHeightWeight, AverageHeight;

/*QUESTION 0
EXAMPLE QUESTION
What is the highest salary in baseball history?
*/
Select MAX(salary) as Max_Salary
FROM Salaries;
;
/*SAMPLE ANSWER*/
SELECT MAX(salary) as Max_Salary
FROM Salaries;

/*QUESTION 1
Select the first name, last name, and given name of players who are taller than 6 ft
[hint]: Use "People"
*/
SELECT nameFirst, nameLast, nameGiven
FROM people
WHERE height > 72;

/*QUESTION 2
Create a Table of all the distinct players with a first name of John who were born in the United States and
played at Fordham university
Include their first name, last name, playerID, and birth state
Add a column called nameFull that is a concatenated version of first and last
[hint] Use a Join between People and CollegePlaying
*/
CREATE Table JOHNS as
	SELECT DISTINCT nameFirst, nameLast, people.playerID, birthState, concat(nameFirst, ' ', nameLast) as nameFull
    FROM people INNER JOIN collegeplaying
    ON people.playerID = collegeplaying.playerID
    WHERE people.nameFirst = "John" AND People.birthCountry = "USA" AND collegeplaying.schoolID = "fordham";

    
/*QUESTION 3
Delete all Johns from the above table whose total career runs batted in is less than 2
[hint] use a subquery to select these johns from people by playerid
[hint] you may have to set sql_safe_updates = 1 to delete without a key
*/
SET SQL_SAFE_UPDATES = 0;
Delete From JOHNS
	WHERE playerID IN (
		SELECT playerID
        FROM batting
        GROUP BY playerID
        HAVING SUM(RBI) < 2);
SET SQL_SAFE_UPDATES = 1;

/*QUESTION 4
Group together players with the same birth year, and report the year, 
 the number of players in the year, and average height for the year
 Order the resulting by year in descending order. Put this in a view
 [hint] height will be NULL for some of these years
*/
CREATE VIEW AverageHeight(birthYear, counts, average_height)
AS
  SELECT birthYear, COUNT(playerID) as counts, AVG(height) as average_height
  FROM people
  GROUP BY birthYear
  ORDER BY birthYear DESC;

/*QUESTION 5
Using Question 3, only include groups with an average weight >180 lbs,
also return the average weight of the group. This time, order by ascending
*/
CREATE VIEW AverageHeightWeight(birthYear, counts, average_height, average_weight)
AS
  SELECT avg_wt.birthYear, counts, average_height, average_weight
  FROM (
	SELECT birthYear, AVG(weight) as average_weight 
    FROM people
    GROUP BY birthYear) as avg_wt
  INNER JOIN averageheight 
  ON averageheight.birthYear = avg_wt.birthYear
  WHERE average_weight > 180
  ORDER BY birthYear ASC;

#select * from schools where state = 'NY';

/*QUESTION 6
Find the players who made it into the hall of fame who played for a college located in NY
return the player ID, first name, last name, and school ID. Order the players by School alphabetically.
Update all entries with full name Columbia University to 'Columbia University!' in the schools table
*/
SELECT people.playerID, nameFirst, nameLast, schoolID
FROM people INNER JOIN (
	SELECT halloffame.playerID, schoolID, name_full
	FROM halloffame INNER JOIN (
		SELECT playerID, collegeplaying.schoolID, name_full	
		FROM collegeplaying INNER JOIN schools
		ON collegeplaying.schoolID = schools.schoolID
		WHERE schools.state = "NY") as school
	ON halloffame.playerID = school.playerID
    ORDER BY name_full) as halloffame_ny
ON people.playerID = halloffame_ny.playerID
ORDER BY name_full;
             
SET SQL_SAFE_UPDATES = 0;             
UPDATE schools SET name_full = "Columbia University!"
WHERE name_full = "Columbia University";
SET SQL_SAFE_UPDATES = 1;


/*QUESTION 7
Find the team id, yearid and average HBP for each team using a subquery.
Limit the total number of entries returned to 100
group the entries by team and year and order by descending values
[hint] be careful to only include entries where AB is > 0
*/
SELECT teamID, yearID, AVG(HBP) as average_hbp
FROM (
	SELECT teamID, yearID, HBP
    FROM teams
    WHERE AB > 0) as tmp
GROUP BY teamID, yearID
ORDER BY average_hbp DESC
LIMIT 100;
