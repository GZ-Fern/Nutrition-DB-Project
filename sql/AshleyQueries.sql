USE Nutrition_Tracker_DB;
-- Part 1:
-- A select statement that uses an order by clause
-- List all the woekout sessions, ordered by the calories burned in descending order 
-- and then by workout date in descending order for ties.
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
    
-- -------------------------------------------------------

-- Part 2:

-- This query counts the total number of meals logged by each user.
-- It helps understand which users are most actively tracking their nutrition.
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
    
-- This query lists the average daily hydration volume for each user over their logged history.
-- It provides insight into users' consistency with their hydration goals.
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

