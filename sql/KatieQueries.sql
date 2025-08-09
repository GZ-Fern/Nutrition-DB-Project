-- ==================================
-- Team Project: Queries
-- Member: Katie
-- Date: 7/13/25
-- ==================================
USE nutrition_tracker_db;
-- ===========================
-- Part 1: Subquery
-- ===========================
-- Description: List users whose BMI is higher than the average BMI across all users.
-- This helps identify users who may need to focus on weight management or seek health advice.

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

-- ===========================
-- Part 2 - Query 1
-- ===========================
-- Description: Show the average calories consumed per meal for each user.
-- This query helps users understand their typical calorie intake per meal session.

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

-- ===========================
-- Part 2 - Query 2
-- ===========================
-- Description: Retrieve each user’s most recent health metric log entry.
-- Useful for monitoring progress and tracking the latest update for each user.

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

-- ===========================
-- Optional Bonus: Trigger
-- ===========================
-- Description: This trigger logs a warning message into a new table
-- if a user logs less than 64oz of water in a day.
-- First, we define the trigger and a log table, then run an insert that fires it.

-- Drop the log table first if re-running for testing
DROP TABLE IF EXISTS Hydration_Alert_Log;

-- Create a table to log hydration alerts (ONLY if not already created)
CREATE TABLE IF NOT EXISTS Hydration_Alert_Log (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT,
    VolumeLogged DOUBLE,
    AlertMessage VARCHAR(255),
    LoggedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create a trigger that logs if user logs hydration < 64oz
DELIMITER //
CREATE TRIGGER trg_Hydration_LowAlert
AFTER INSERT ON Hydration
FOR EACH ROW
BEGIN
    IF NEW.VolumeOz < 64 THEN
        INSERT INTO Hydration_Alert_Log (UserID, VolumeLogged, AlertMessage)
        VALUES (NEW.UserID, NEW.VolumeOz, 'Hydration below recommended 64oz');
    END IF;
END;
//
DELIMITER ;

-- This insert statement will activate the above trigger
-- and log the alert to the Hydration_Alert_Log table.
INSERT INTO Hydration (UserID, DateLogged, VolumeOz)
VALUES (3, '2025-07-06', 50);
