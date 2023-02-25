SELECT * FROM `olympic games`.olympic_history;
SELECT * FROM `olympic games`.olympic_history_noc_regions;

-- 1. How many olympics games have been held?
SELECT COUNT(DISTINCT Games) AS total_olympic_games
FROM olympic_history;

-- 2. List down all olympics games held so far.
SELECT DISTINCT(Year), Season, City 
FROM olympic_history
ORDER BY Year;

-- 3. Mention the total no of nations who participated in each olympics game?
WITH all_countries AS
        (SELECT oh.Games, nr.Region
        FROM olympic_history oh
        JOIN olympic_history_noc_regions nr ON nr.NOC = oh.NOC
        GROUP BY Games, nr.Region)
    SELECT Games, COUNT(1) AS total_countries
    FROM all_countries
	GROUP BY Games
    ORDER BY Games;

-- 4. Which year saw the highest and lowest no of countries participating in olympics.
WITH T1 AS 
		(SELECT Games, COUNT(DISTINCT NOC) AS total_countries
		FROM olympic_history
		GROUP BY Games
		ORDER BY Games)
	SELECT CONCAT(first_value(Games) over (order by total_countries), ' - ', 
	first_value(total_countries) over (order by total_countries)) AS lowest_countries,
		   CONCAT(first_value(Games) over (order by total_countries desc), ' - ', 
	first_value(total_countries) over (order by total_countries desc)) AS highest_countries 
	FROM T1
    LIMIT 1;
    
-- 5. Which nation has participated in all of the olympic games.
SELECT nr.region AS ountry, COUNT(DISTINCT(oh.Games)) AS total_participated
FROM olympic_history oh
JOIN olympic_history_noc_regions nr
ON oh.NOC = nr.NOC
GROUP BY  nr.region
ORDER BY total_participated DESC;  

-- 6. Identify the sport which was played in all summer olympics.
WITH T1 AS 
		(SELECT COUNT(DISTINCT Games) AS total_games
		FROM olympic_history
		WHERE Season = 'Summer'),
	T2 AS
		(SELECT DISTINCT Sport, Games
		FROM olympic_history
		WHERE Season = 'Summer'), 
	T3 AS
		(SELECT Sport, COUNT(Games) AS no_of_games 
		FROM T2
		GROUP BY Sport)
	SELECT * FROM T3
	JOIN T1 
	ON T1.total_games = T3.no_of_games;

-- 7. Which Sports were just played only once in the olympics.
WITH CTE1 AS
		(SELECT Sport, COUNT(DISTINCT Games) AS No_of_games, Games
		FROM olympic_history
		GROUP BY Sport)
	SELECT * 
	FROM CTE1 
	WHERE No_of_games = 1;   

-- 8. Fetch the total no of sports played in each olympic games.
SELECT Games, COUNT(DISTINCT Sport) AS No_of_sports
FROM olympic_history
GROUP BY Games
ORDER BY No_of_sports DESC;

-- 9. Fetch oldest athletes to win a gold medal.
SELECT * 
FROM olympic_history 
WHERE Age = (SELECT MAX(Age) FROM olympic_history WHERE Medal = 'Gold')
ORDER BY Games;

-- 10. Find the ratio of male and female athletes participated in all olympic games.
WITH T1 AS
		(SELECT Sex, COUNT(Sex) AS female
		FROM olympic_history
		WHERE Sex = 'F'),
	T2 AS
		(SELECT Sex, COUNT(Sex) AS male
		FROM olympic_history
		WHERE Sex = 'M')
	SELECT CONCAT('1:', round((male/female),2)) AS ratio
	FROM T2,T1    

-- 11. Fetch the top 5 athletes who have won the most gold medals.
WITH T1 AS
		(SELECT Name, Team, COUNT(1) AS total_gold_medals
		FROM olympic_history
		WHERE medal = 'Gold'
		GROUP BY Name, team
		ORDER BY total_gold_medals DESC),
	T2 AS
		(SELECT *, DENSE_RANK() OVER (ORDER BY total_gold_medals DESC) AS rnk
		FROM T1)
    SELECT Name, Team, total_gold_medals, rnk
    FROM T2
    WHERE rnk <= 5;
    
-- 12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
WITH T1 AS
		(SELECT Name, Team, COUNT(1) as total_medals
		FROM olympic_history
		WHERE Medal IN ('Gold', 'Silver', 'Bronze')
		GROUP BY Name, Team
		ORDER BY total_medals DESC),
	T2 AS
		(SELECT *, DENSE_RANK() OVER (ORDER BY total_medals DESC) AS rnk
		FROM T1)
    SELECT Name, Team, total_medals, rnk
    FROM T2
    WHERE rnk <= 5;

-- 13. Fetch the top 5 most successful countries in olympics.
--     Success is defined by no of medals won.
WITH T1 AS
		(SELECT nr.region, COUNT(1) as total_medals
		FROM olympic_history oh
		JOIN olympic_history_noc_regions nr
		ON oh.noc = nr.noc
		WHERE oh.Medal <> 'NA'
		GROUP BY nr.region
		ORDER BY total_medals desc),
	T2 as
		(SELECT *, DENSE_RANK() OVER (ORDER BY total_medals DESC) AS rnk
		FROM T1)
		SELECT region, total_medals, rnk
		FROM T2
		WHERE rnk <= 5;
    
-- 14. In which Sport/event, India has won highest medals.
WITH T1 AS 	
		(SELECT Team, Sport, COUNT(Medal) AS total_medals
		FROM olympic_history
		WHERE Medal <> 'NA' AND Team = 'India'
		GROUP BY Sport
		ORDER BY total_medals DESC),
	T2 AS
		(SELECT *, RANK() OVER(ORDER BY total_medals DESC) AS rnk
		FROM T1)
	SELECT sport, total_medals
	FROM t2
	WHERE rnk = 1;

-- 15. Break down all olympic games where India won medal for Hockey and how many medals in each olympic games
SELECT Team, Sport, Games, COUNT(1) AS total_medals
FROM olympic_history
WHERE Medal <> 'NA' AND Team = 'India' AND Sport = 'Hockey'
GROUP BY Team, Sport, Games
ORDER BY total_medals DESC;
