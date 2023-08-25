-- Get the top 100 rows in the table to see data being queried
SELECT TOP 100 * FROM ChicagoCrimes$;

-- View the first 500 crime cases of the dataset, starting from January 01, 2001
SELECT TOP 500 * FROM ChicagoCrimes$ ORDER BY Year(Date), Month(Date), DAY(Date) ASC;

-- View all of the unique dates including each different marked time for each day of the year
SELECT Date FROM ChicagoCrimes$ ORDER BY Year(Date), Month(Date), DAY(Date) ASC;

-- Get the lower bound of the years covered in the dataset
SELECT MIN(Year) FROM ChicagoCrimes$;

-- Get the upper bound of the years covered in the dataset
SELECT MAX(Year) FROM ChicagoCrimes$;

-- Get the first 100 Primary Type of Crimes
SELECT TOP 100 ID, "Primary Type" FROM ChicagoCrimes$;

-- Group by the Primary Type of the crimes and accumulate a count per type
SELECT "Primary Type", COUNT(*) FROM ChicagoCrimes$ GROUP BY "Primary Type";

-- Group similarly as above but sort by frequency by descending order
SELECT "Primary Type", COUNT(*) AS Frequency FROM ChicagoCrimes$ GROUP BY "Primary Type" ORDER BY Frequency DESC;

-- Get all of the crimes that occurred in 2023
SELECT * FROM ChicagoCrimes$ WHERE YEAR(Date) = 2023;

-- Get the count of the crimes per year
SELECT "Year", COUNT(*) AS number_of_crimes FROM ChicagoCrimes$ GROUP BY "Year" ORDER BY number_of_crimes DESC;

SELECT "Year", COUNT(*) AS number_of_crimes FROM ChicagoCrimes$ GROUP BY "Year" ORDER BY number_of_crimes DESC;

-- Count all total crimes and breakdown the total into the top 5 crimes based on a previous query (3) per year
SELECT "Year", 
	COUNT(*) AS total_crimes, 
	SUM(CASE WHEN "Primary Type" = 'Theft' THEN 1 ELSE 0 END) AS theft_crimes,
	SUM(CASE WHEN "Primary Type" = 'Battery' THEN 1 ELSE 0 END) AS battery_crimes,
	SUM(CASE WHEN "Primary Type" = 'Criminal Damage' THEN 1 ELSE 0 END) AS criminal_dmg_crimes,
	SUM(CASE WHEN "Primary Type" = 'Deceptive Practice' THEN 1 ELSE 0 END) AS deceptive_prac_crimes,
	SUM(CASE WHEN "Primary Type" = 'Assault' THEN 1 ELSE 0 END) AS assault_crimes
	FROM ChicagoCrimes$ GROUP BY "Year";

-- Group by each type of crime to get the counts of both arrested and not arrested cases
SELECT "Primary Type", SUM(CASE WHEN "Arrest" = 'TRUE' THEN 1 ELSE 0 END) AS 'arrested_count', SUM(CASE WHEN "Arrest" = 'FALSE' THEN 1 ELSE 0 END) AS 'not_arrested_count' FROM ChicagoCrimes$ GROUP BY "Primary Type";

-- Group by each type of crime, count the cases of both arrested and not arrested crimes, and calculate the percentage of an arrest occurring for the crime
SELECT "Primary Type", COUNT(*) AS 'total_cases',
	SUM(CASE WHEN "Arrest" = 'TRUE' THEN 1 ELSE 0 END) AS 'arrested_count', 
	SUM(CASE WHEN "Arrest" = 'FALSE' THEN 1 ELSE 0 END) AS 'not_arrested_count', 
	ISNULL((SUM(CASE WHEN "Arrest" = 'TRUE' THEN 1 ELSE 0 END) * 1.0 / NULLIF(COUNT(*),0) * 1.0), 100) * 100 AS 'arrest_percentage'
FROM ChicagoCrimes$ GROUP BY "Primary Type" ORDER BY 'total_cases' DESC;

-- After initial visualization using a bar chart plotting the arrest percentage of each primary type of crime
-- I decided to limit the types to at least having 1000 cases, a more substantial amount
SELECT "Primary Type", COUNT(*) AS 'total_cases',
	SUM(CASE WHEN "Arrest" = 'TRUE' THEN 1 ELSE 0 END) AS 'arrested_count', 
	SUM(CASE WHEN "Arrest" = 'FALSE' THEN 1 ELSE 0 END) AS 'not_arrested_count', 
	ISNULL((SUM(CASE WHEN "Arrest" = 'TRUE' THEN 1 ELSE 0 END) * 1.0 / NULLIF(COUNT(*),0) * 1.0), 100) * 100 AS 'arrest_percentage'
FROM ChicagoCrimes$ GROUP BY "Primary Type" HAVING COUNT(*) >= 1000 ORDER BY 'total_cases' DESC;

-- Group each possible location description to see where crimes most frequently and less frequently occur excluding all crimes without a specified location
SELECT "Location Description", COUNT(*) AS Frequency FROM ChicagoCrimes$ WHERE "Location Description" <> '' GROUP BY "Location Description" ORDER BY Frequency DESC;

-- Get the month from each crime date and count the number of crime cases per month and order in descending order
SELECT MONTH(Date) AS 'Month', COUNT(*) AS crime_frequency FROM ChicagoCrimes$ GROUP BY MONTH(Date) ORDER BY crime_frequency DESC;

-- Based from the description of each crime case, sum each case that is either money related or not to gain a potential insight into the origin of crimes
SELECT 
	SUM(CASE WHEN "Description" LIKE '%$%' THEN 1 ELSE 0 END) AS 'money_related_cases',
	SUM(CASE WHEN "Description" NOT LIKE '%$%' THEN 1 ELSE 0 END) AS 'not_money_related_cases'
FROM ChicagoCrimes$;

-- Find the spread of total cases based on the hour of day using the Date column via DATEPART(...) to access the hour of day
-- Data used in visualization #6
SELECT 
	DATEPART(HOUR, Date) AS hour_of_day,
	COUNT(*) AS total_cases 
	FROM ChicagoCrimes$ GROUP BY DATEPART(HOUR, Date) 
	ORDER BY hour_of_day;

-- An experimentation with subqueries, the inner query will create hour_of_day and total_cases columns converted to a 12-hour day and concatenating AM and PM according to the 24-hour time.
-- The data is then ordered by the total_cases cases in descending order
SELECT hour_of_day, total_cases FROM 
	(SELECT 
		CASE
			WHEN DATEPART(HOUR, Date) < 12 THEN CONCAT(DATEPART(HOUR, Date)+1, ' ' , 'AM')
			ELSE CONCAT(DATEPART(HOUR, Date) - 12 + 1, ' ' , 'PM')
		END AS hour_of_day,
		COUNT(*) AS total_cases FROM ChicagoCrimes$ 
	GROUP BY DATEPART(HOUR, Date)) AS ds
ORDER BY total_cases DESC;

-- Get the total arrests per year and sort the table in terms of ascending year
SELECT "Year", COUNT(CASE WHEN Arrest = 'TRUE' THEN 1 ELSE 0 END) AS total_arrests FROM ChicagoCrimes$ GROUP BY "Year" ORDER BY "Year" ASC;

-- Ordering by year and month, accumulate the total amount of crime cases per month of each year
SELECT "Year", MONTH(Date) AS "Month", COUNT(*) AS total_cases FROM ChicagoCrimes$ GROUP BY "Year", MONTH(Date) ORDER BY Year, Month;

-- Perform a subquery to get the average monthly cases
SELECT AVG(total.total_cases) AS average_monthly_cases FROM (
	SELECT MONTH(Date) AS "Month", COUNT(*) AS total_cases FROM ChicagoCrimes$ GROUP BY MONTH(Date)) AS total;

-- Get the primary type of the case alongside its longitude and latitude to plot the crimes filtered by the
-- type of crime to visualize each crime type and their density. The ID is used to make individual data points on Tableau
SELECT "ID", "Primary Type", "Longitude", "Latitude" FROM ChicagoCrimes$ WHERE "Location" <> ' ';