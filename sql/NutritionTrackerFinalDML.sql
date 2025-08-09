-- ----------------------------------------------------------------------------------------------
-- Team Project: Nutrition Tracker DML
-- Members: Fernanda, Ashley, Hilary, Katie
-- Date: 07/20/2025
-- ----------------------------------------------------------------------------------------------
USE nutrition_tracker_db;
-- ----------------------------------------------------------------------------------------------
-- Query 1: A select statement with that includes at least two aggregate functions
-- Member: Hilary
-- Description: This query lists users who burned more calories through workouts than they consumed from meals.
-- Uses aggregate functions (SUM), multiple JOINs, and sorts by total calories burned.
-- ----------------------------------------------------------------------------------------------
select u.UserID, u.FName, u.LName, burned.totalBurn, consumed.totalConsume
from user u
join (select UserID, sum(CaloriesBurned) as totalBurn
from workout
group by UserID)
as burned on u.UserID = burned.UserID
join( select m.UserID, sum(f.Calories * mf.PortionSize) as totalConsume 
from meal m
	join meal_food mf on m.MealID = mf.MealID
		join food f on mf.FoodID = f.FoodID 
        group by m.UserID)
as consumed on u.UserID = consumed.UserID where burned.totalBurn > consumed.totalConsume
order by burned.totalBurn desc;

-- ----------------------------------------------------------------------------------------------
-- Query 2: A select statement that uses at least one join, concatenation, and distinct clause
-- Member: Fernanda
-- Description: Showing distinct users & food items they have consumed by...
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

-- ----------------------------------------------------------------------------------------------
-- Query 3: A select statement that includes at least one subquery
-- Member: Katie
-- Description:  List users whose BMI is higher than the average BMI across all users.
-- This helps identify users who may need to focus on weight management or seek health advice.
-- ----------------------------------------------------------------------------------------------
SELECT
    U.UserID,
    U.FName,
    U.LName,
    HM.Value AS BMI
FROM
    USER AS U
JOIN
    Health_Metric AS HM ON U.UserID = HM.UserID
WHERE
    HM.MetricType = 'BMI'
    AND HM.Value > (
        SELECT AVG(Value)
        FROM Health_Metric
        WHERE MetricType = 'BMI'
    )
ORDER BY
    HM.Value DESC;
    
-- ----------------------------------------------------------------------------------------------
-- Query 4: A select statement that uses an order by clause
-- Member: Ashley
-- Description: List all the workout sessions, ordered by the calories burned in descending order 
-- and then by workout date in descending order for ties.
-- ----------------------------------------------------------------------------------------------
SELECT
    W.WorkoutID,
    U.FName,
    U.LName,
    W.WorkoutType,
    W.CaloriesBurned,
    W.WorkoutDate,
    W.Duration
FROM
    Workout AS W
JOIN
    USER AS U ON W.UserID = U.UserID
ORDER BY
    W.CaloriesBurned DESC, W.WorkoutDate DESC;
    
-- ----------------------------------------------------------------------------------------------
-- Query 5: An insert statement that runs a trigger in which the trigger adds data or updates data in a table
-- Member: Fernanda
-- Description: Automatically setting `CaloriesBurned` value during an insert into the `Workout` table 
-- based on the selected `WorkoutType`. 
-- ----------------------------------------------------------------------------------------------
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
WHERE UserID = 1 AND WorkoutDate = '2025-07-13' AND WorkoutType = 'Pilates';

-- ----------------------------------------------------------------------------------------------
-- Query 6: A delete statement that runs a trigger in which the trigger deletes data in one table
-- Member: Hilary
-- Description: Trigger deletes food links when a meal is removed
-- ----------------------------------------------------------------------------------------------
delimiter //
create trigger trgDelMeal_foodlinks
after delete on meal
for each row
begin
    delete from Meal_Food
    where MealID = old.MealID;
end;
//
delimiter ;
-- Delete statement to activate the trigger
delete from meal
where MealID = 2; 

-- ----------------------------------------------------------------------------------------------
-- Query of Choice 1 | Member: Fernanda
-- Description: Shows the number of goals each user has and their average target value...
-- to help us understand what kind of targets they aim for, giving us a sense of their motivation levels.
-- ----------------------------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------------------------
-- Query of Choice 2 | Member: Fernanda
-- Description: Listing all users who consumed over 150 calories in a day.
-- Ideally I want to do higher calorie intakes, but it is set to 150 due to limited dataset.
-- This query was intended to calculate the total calories consumed by user per day, and can... 
-- be adjusted when we have more data.
-- ----------------------------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------------------------
-- Query of Choice 1 | Member: Ashley
-- Description: This query counts the total number of meals logged by each user.
-- It helps understand which users are most actively tracking their nutrition.
-- ----------------------------------------------------------------------------------------------
SELECT
    U.UserID,
    U.FName,
    U.LName,
    COUNT(M.MealID) AS TotalMealsLogged
FROM
    USER AS U
JOIN
    Meal AS M ON U.UserID = M.UserID
GROUP BY
    U.UserID, U.FName, U.LName
ORDER BY
    TotalMealsLogged DESC, U.LName, U.FName;
    
-- ----------------------------------------------------------------------------------------------
-- Query of Choice 2 | Member: Ashley
-- Description: This query lists the average daily hydration volume for each user over their logged history.
-- It provides insight into users' consistency with their hydration goals.
-- ----------------------------------------------------------------------------------------------
SELECT
    U.UserID,
    U.FName,
    U.LName,
    AVG(H.VolumeOz) AS AverageDailyHydrationOz
FROM
    USER AS U
JOIN
    Hydration AS H ON U.UserID = H.UserID
GROUP BY
    U.UserID, U.FName, U.LName
ORDER BY
    AverageDailyHydrationOz DESC; 
    
-- ----------------------------------------------------------------------------------------------
-- Query of Choice 1 | Member: Katie
-- Description: Show the average calories consumed per meal for each user.
-- This query helps users understand their typical calorie intake per meal session.
-- ----------------------------------------------------------------------------------------------
SELECT
    U.UserID,
    U.FName,
    U.LName,
    ROUND(AVG(F.Calories * MF.PortionSize), 2) AS AvgCaloriesPerMeal
FROM
    USER AS U
JOIN
    Meal AS M ON U.UserID = M.UserID
JOIN
    Meal_Food AS MF ON M.MealID = MF.MealID
JOIN
    Food AS F ON MF.FoodID = F.FoodID
GROUP BY
    U.UserID, U.FName, U.LName
ORDER BY
    AvgCaloriesPerMeal DESC;
    
-- ----------------------------------------------------------------------------------------------
-- Query of Choice 2 | Member: Katie
-- Description: Retrieve each user’s most recent health metric log entry.
-- Useful for monitoring progress and tracking the latest update for each user.
-- ----------------------------------------------------------------------------------------------
SELECT
    HM.UserID,
    U.FName,
    U.LName,
    HM.MetricType,
    HM.Value,
    HM.Unit,
    HM.DateMeasured
FROM
    Health_Metric HM
JOIN
    USER U ON HM.UserID = U.UserID
WHERE
    (HM.UserID, HM.DateMeasured) IN (
        SELECT UserID, MAX(DateMeasured)
        FROM Health_Metric
        GROUP BY UserID
    )
ORDER BY
    HM.DateMeasured DESC;
-- ----------------------------------------------------------------------------------------------
-- Query of Choice 1 | Member: Hilary
-- Description: This query finds users who have logged workouts longer than 40 minutes ordered by duration.
-- ----------------------------------------------------------------------------------------------
select u.UserID, u.FName, u.LName, w.duration
from User u
join workout w on u.UserID = w.UserID
where w.Duration > '00:40:00'
order by w.Duration desc;

-- ----------------------------------------------------------------------------------------------
-- Query of Choice 2 | Member: Hilary
-- Description: This query retrieves users who had at least one snack-type meal, sorted by UserID.
-- ----------------------------------------------------------------------------------------------
select u.UserId, u.FName, u.LName,
( select count(*) 
	from meal m
	where m.UserID = u.UserID and m.MealType = 'Snack' )
as snackCount
from user u
having snackcount >0
order by u.UserId;
