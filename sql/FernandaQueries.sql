-- ----------------------------------------------------------------------------------------------
-- Team Project: Individual Queries
-- Member: Fern
-- Date: 07/13/2025
-- ----------------------------------------------------------------------------------------------
-- Selecting Database
USE nutrition_tracker_db;
-- ----------------------------------------------------------------------------------------------
-- Part 1: #2 A select statement that uses at least one join, concatenation, and distinct clause.
-- ----------------------------------------------------------------------------------------------
-- Showing distinct users & food items they have consumed by...
-- using JOINs between USER, Meal, Meal_Food, and Food.
-- CONCAT then combines first and last names.
-- DISTINCT is then utilized to avoid duplicate rows.
-- ----------------------------------------------------------------------------------------------
SELECT DISTINCT
	CONCAT(u.FName, ' ', LName) AS FullName, -- Combining first and last name
    f.FoodName -- Showing food item consumed
FROM
	USER u
JOIN
	Meal m ON u.UserID = m.UserID -- Matching users to their meals
JOIN
	Meal_Food mf ON m.MealID = mf.MealID
JOIN
	Food f ON mf.FoodID = f.FoodID
ORDER BY
	FullName, f.FoodName; -- Ordering alphabetically by user and food

-- -----------------------------------------------------------------------------------------------------
-- Part 2: Queries
-- First Query:
-- Shows the number of goals each user has and their average target value...
-- to help us understand what kind of targets they aim for, giving us a sense of their motivation levels.
-- ------------------------------------------------------------------------------------------------------
SELECT
	u.UserID,
    CONCAT(u.FName, ' ', u.LName) AS FullName, -- Combining names again
    COUNT(g.GoalID) AS GoalCount, -- Total number of goals set
    AVG(g.TargetValue) AS AvgTarget -- Average value of the goals
FROM
	USER u
LEFT JOIN
	Goal g ON u.UserID = g.UserID -- Including users even with no goals
GROUP BY
	u.UserID;

-- Second Query:
-- Listing all users who consumed over 150 calories in a day.
-- Ideally I want to do higher calorie intakes, but it is set to 150 due to limited dataset.
-- This query was intended to calculate the total calories consumed by user per day.
-- ------------------------------------------------------------------------------------------------
SELECT
	u.UserID,
    CONCAT(u.FName, ' ', u.LName) AS FullName,
    m.MealDate, 
    SUM(f.Calories * mf.PortionSize) AS TotalCalories -- Total daily calories consumed
FROM
	USER u
JOIN
	Meal m ON u.UserID = m.UserID
JOIN
	Meal_Food mf ON m.MealID = mf.MealID
JOIN
	Food f ON mf.FoodID = f.FoodID
GROUP BY
	u.UserID, m.MealDate -- Grouping by user and day to get daily totals
HAVING
	TotalCalories > 150; -- Only showing users wih more than 150 calories that day

-- -----------------------------------------------------------------------------------------------------
-- BONUS --
-- INSERT Trigger:
-- Automatically setting `CaloriesBurned` value during an insert into the `Workout` table based on
-- the selected `WorkoutType`
-- ------------------------------------------------------------------------------------------------------
DELIMITER //
CREATE TRIGGER trg_calc_calories
BEFORE INSERT ON Workout
FOR EACH ROW
BEGIN
	-- Setting predefined calories based on workout type
	IF NEW.WorkoutType = 'Cardio' THEN
		SET NEW.CaloriesBurned = 400;
	ELSEIF NEW.WorkoutType = 'Strength' THEN
		SET NEW.CaloriesBurned = 500;
	ELSEIF NEW.WorkoutType = 'Yoga' THEN
		SET NEW.CaloriesBurned = 200;
	ELSEIF NEW.WorkoutType = 'HIIT' THEN
		SET NEW.CaloriesBurned = 450;
	ELSEIF NEW.WorkoutType = 'Cycling' THEN
		SET NEW.CaloriesBurned = 600;
	ELSEIF NEW.WorkoutType = 'Swimming' THEN
		SET NEW.CaloriesBurned = 350;
	ELSEIF NEW.WorkoutType = 'Pilates' THEN
		SET NEW.CaloriesBurned = 300;
	ELSEIF NEW.WorkoutType = 'Running' THEN
		SET NEW.CaloriesBurned = 550;
	ELSEIF NEW.WorkoutType = 'CrossFit' THEN
		SET NEW.CaloriesBurned = 500;
	ELSEIF NEW.WorkoutType = 'Stretching' THEN
		SET NEW.CaloriesBurned = 150;
	ELSE
		SET NEW.CaloriesBurned = 100; -- Fallback value for unspecified types
	END IF;
END;
//
DELIMITER ;

-- This trigger will automatically assign 300 calories burned based on `Pilates`
INSERT INTO Workout (UserID, WorkoutDate, Duration, WorkoutType)
VALUES (1, '2025-07-13', '00:30:00', 'Pilates');

-- Checking my work
SELECT * FROM Workout
WHERE UserID = 1 AND WorkoutDate = '2025-07-13' AND WorkoutType = 'Pilates'
	
