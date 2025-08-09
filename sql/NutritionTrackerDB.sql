-- Instruction:
-- Once you create the Database Schema, turn it into a comment. That way it runs smoothly afterwards.
CREATE DATABASE nutrition_tracker_db;
USE nutrition_tracker_db;
-- DDL for Personal Nutrition & Workout Tracker System
-- Drop tables in reverse order of dependency if they exist, to avoid foreign key errors
-- This block is especially useful for development, allowing you to re-run the script easily.
DROP TABLE IF EXISTS Hydration;
DROP TABLE IF EXISTS Health_Metric;
DROP TABLE IF EXISTS Meal_Food;
DROP TABLE IF EXISTS Food;
DROP TABLE IF EXISTS Workout;
DROP TABLE IF EXISTS Goal;
DROP TABLE IF EXISTS Goal_Category;
DROP TABLE IF EXISTS Meal;
DROP TABLE IF EXISTS USER; -- Renamed from 'User' to 'USER' to avoid potential SQL keyword conflicts
-- -----------------------------------------------------
-- Table `USER`
-- This table stores information about the users of the system.
CREATE TABLE USER (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    FName VARCHAR(50) NOT NULL,
    LName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL, -- Email must be unique for each user
    Age INT NOT NULL,
    Height INT NOT NULL, -- Height in inches
    Weight DOUBLE NOT NULL, -- Weight in pounds
    Gender VARCHAR(20), -- Consider an ENUM type if gender options are limited
    DateJoined DATE NOT NULL DEFAULT (CURRENT_DATE) -- Automatically set to current date
);
-- -----------------------------------------------------
-- Table `Goal_Category`
-- This table defines different categories for user goals.
CREATE TABLE Goal_Category (
    GoalCatID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(100) NOT NULL UNIQUE -- Category names should be unique
);
-- -----------------------------------------------------
-- Table `Goal`
-- This table records users' personal health and fitness goals.
CREATE TABLE Goal (
    GoalID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    GoalCatID INT NOT NULL,
    TargetValue DOUBLE, -- Numerical goal value
    Target VARCHAR(255) NOT NULL, -- Description of the target 
    TargetDate DATE, -- Deadline for the goal (can be NULL if no specific deadline)
    Status VARCHAR(50) NOT NULL, -- e.g., 'Active', 'Completed', 'Achieved', 'Abandoned'
    DateSet DATE NOT NULL DEFAULT (CURRENT_DATE), -- Timestamp for when the goal was set

    FOREIGN KEY (UserID) REFERENCES USER(UserID)
        ON UPDATE CASCADE ON DELETE CASCADE, -- If user is deleted, their goals are deleted
    FOREIGN KEY (GoalCatID) REFERENCES Goal_Category(GoalCatID)
        ON UPDATE CASCADE ON DELETE RESTRICT -- Do not delete a goal category if goals still refer to it
);
-- -----------------------------------------------------
-- Table `Meal`
-- This table logs individual meals consumed by users.
CREATE TABLE Meal (
    MealID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    MealDate DATE NOT NULL,
    MealType VARCHAR(50) NOT NULL, -- e.g., 'Breakfast', 'Lunch', 'Dinner', 'Snack'

    FOREIGN KEY (UserID) REFERENCES USER(UserID)
        ON UPDATE CASCADE ON DELETE CASCADE -- If user is deleted, their meal logs are deleted
);
-- -----------------------------------------------------
-- Table `Food`
-- This table stores information about different food items, including nutritional data.
CREATE TABLE Food (
    FoodID INT PRIMARY KEY AUTO_INCREMENT,
    FoodName VARCHAR(255) NOT NULL,
    Calories DOUBLE NOT NULL,
    Protein DOUBLE NOT NULL, -- Grams of protein
    Carbs DOUBLE NOT NULL,   -- Grams of carbohydrates
    Fats DOUBLE NOT NULL     -- Grams of fat
);
-- Table `Meal_Food` (Associative Entity)
-- This table resolves the Many-to-Many relationship between Meal and Food,
CREATE TABLE Meal_Food (
    MealID INT NOT NULL,
    FoodID INT NOT NULL,
    PortionSize DOUBLE NOT NULL, -- Number of servings consumed

    PRIMARY KEY (MealID, FoodID), -- Composite primary key for uniqueness
    FOREIGN KEY (MealID) REFERENCES Meal(MealID)
        ON UPDATE CASCADE ON DELETE CASCADE, -- If a meal is deleted, its food entries are also deleted
    FOREIGN KEY (FoodID) REFERENCES Food(FoodID)
        ON UPDATE CASCADE ON DELETE RESTRICT -- Do not delete a food if it's referenced in a meal log
);
-- Table `Workout`
-- This table logs individual workout sessions performed by users.
CREATE TABLE Workout (
    WorkoutID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    WorkoutDate DATE NOT NULL,
    Duration TIME NOT NULL, -- Duration of the workout (e.g., '01:30:00' for 1 hour 30 mins)
    WorkoutType VARCHAR(100) NOT NULL, -- e.g., 'Cardio', 'Strength', 'Yoga', 'HIIT'
    CaloriesBurned DOUBLE NOT NULL,

    FOREIGN KEY (UserID) REFERENCES USER(UserID)
        ON UPDATE CASCADE ON DELETE CASCADE -- If user is deleted, their workout logs are deleted
);
-- -----------------------------------------------------
-- Table `Health_Metric`
-- This table stores various health metrics recorded by users.
CREATE TABLE Health_Metric (
    MetricID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    DateMeasured DATE NOT NULL, -- Changed from VARCHAR to DATE based on common practice for dates
    MetricType VARCHAR(100) NOT NULL, -- e.g., 'Heart Rate', 'Sleep', 'Blood Pressure', 'BMI', 'Glucose Levels'
    Value DOUBLE NOT NULL,
    Unit VARCHAR(50) NOT NULL, -- e.g., 'bpm', 'mmHg', 'hours', 'kg/m^2', 'mg/dL'

    FOREIGN KEY (UserID) REFERENCES USER(UserID)
        ON UPDATE CASCADE ON DELETE CASCADE -- If user is deleted, their health metrics are deleted
);
-- -----------------------------------------------------
-- Table `Hydration`
-- This table logs daily hydration levels for users.
CREATE TABLE Hydration (
    HydrationID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    DateLogged DATE NOT NULL,
    VolumeOz DOUBLE NOT NULL, -- Volume in ounces

    FOREIGN KEY (UserID) REFERENCES USER(UserID)
        ON UPDATE CASCADE ON DELETE CASCADE -- If user is deleted, their hydration logs are deleted
);

-- ------------------------------
-- Insert data into USER table
-- ------------------------------
INSERT INTO USER (FName, LName, Email, Age, Height, Weight, Gender)
VALUES
('Alice', 'Smith', 'alice@example.com', 25, 64, 130, 'Female'),
('Bob', 'Johnson', 'bob@example.com', 30, 70, 180, 'Male'),
('Carol', 'Williams', 'carol@example.com', 22, 66, 140, 'Female'),
('David', 'Brown', 'david@example.com', 28, 72, 175, 'Male'),
('Eve', 'Davis', 'eve@example.com', 35, 62, 120, 'Female'),
('Frank', 'Miller', 'frank@example.com', 40, 68, 200, 'Male'),
('Grace', 'Wilson', 'grace@example.com', 29, 65, 150, 'Female'),
('Henry', 'Moore', 'henry@example.com', 33, 71, 190, 'Male'),
('Isabel', 'Taylor', 'isabel@example.com', 24, 63, 125, 'Female'),
('Jack', 'Anderson', 'jack@example.com', 26, 69, 165, 'Male');

-- ------------------------------
-- Insert data into Goal_Category
-- ------------------------------
INSERT INTO Goal_Category (CategoryName)
VALUES
('Weight Loss'),
('Muscle Gain'),
('Cardio Endurance'),
('Strength Training'),
('Healthy Eating'),
('Flexibility Improvement');

-- ------------------------------
-- Insert data into Goal
-- ------------------------------
INSERT INTO Goal (UserID, GoalCatID, TargetValue, Target, TargetDate, Status)
VALUES
(1, 1, 125, 'Lose weight to 125 lbs', '2025-08-01', 'Active'),
(2, 2, 185, 'Increase weight to 185 lbs', '2025-09-15', 'Active'),
(3, 3, 5, 'Run 5 miles without stopping', '2025-07-31', 'Completed'),
(4, 4, 200, 'Bench press 200 lbs', '2025-12-01', 'Active'),
(5, 5, NULL, 'Eat 5 servings of vegetables daily', '2025-07-15', 'Active'),
(6, 1, 190, 'Reduce weight to 190 lbs', '2025-10-01', 'Active'),
(7, 3, 10, 'Cycle 10 miles', '2025-08-20', 'Active'),
(8, 4, 250, 'Deadlift 250 lbs', '2025-11-15', 'Completed'),
(9, 5, NULL, 'Reduce sugar intake by 50%', '2025-07-20', 'Active'),
(10, 6, NULL, 'Practice yoga 3 times a week', '2025-07-10', 'Active');

-- ------------------------------
-- Insert data into Food
-- ------------------------------
INSERT INTO Food (FoodName, Calories, Protein, Carbs, Fats)
VALUES
('Grilled Chicken Breast', 165, 31, 0, 4),
('Brown Rice', 216, 5, 45, 2),
('Broccoli', 55, 4, 11, 0),
('Oatmeal', 150, 5, 27, 3),
('Apple', 95, 0, 25, 0),
('Banana', 105, 1, 27, 0),
('Salmon', 208, 20, 0, 13),
('Egg', 78, 6, 1, 5),
('Peanut Butter', 190, 7, 8, 16),
('Greek Yogurt', 100, 10, 5, 0),
('Protein Shake', 250, 30, 10, 5);

-- ------------------------------
-- Insert data into Meal
-- ------------------------------
INSERT INTO Meal (UserID, MealDate, MealType)
VALUES
(1, '2025-07-05', 'Breakfast'),
(1, '2025-07-05', 'Lunch'),
(2, '2025-07-05', 'Dinner'),
(2, '2025-07-05', 'Snack'),
(3, '2025-07-05', 'Breakfast'),
(4, '2025-07-05', 'Lunch'),
(5, '2025-07-05', 'Dinner'),
(6, '2025-07-05', 'Snack'),
(7, '2025-07-05', 'Lunch'),
(8, '2025-07-05', 'Breakfast');

-- ------------------------------
-- Insert data into Meal_Food
-- ------------------------------
INSERT INTO Meal_Food (MealID, FoodID, PortionSize)
VALUES
(1, 1, 1),
(1, 2, 1),
(1, 3, 2),
(2, 4, 1),
(2, 5, 1),
(3, 7, 1),
(3, 2, 1),
(4, 6, 2),
(5, 8, 2),
(6, 9, 1),
(7, 10, 1),
(8, 1, 1),
(8, 2, 1),
(9, 5, 1),
(10, 4, 1);

-- ------------------------------
-- Insert data into Workout
-- ------------------------------
INSERT INTO Workout (UserID, WorkoutDate, Duration, WorkoutType, CaloriesBurned)
VALUES
(1, '2025-07-04', '00:45:00', 'Cardio', 400),
(2, '2025-07-04', '01:00:00', 'Strength', 500),
(3, '2025-07-04', '00:30:00', 'Yoga', 200),
(4, '2025-07-04', '00:50:00', 'HIIT', 450),
(5, '2025-07-04', '01:15:00', 'Cycling', 600),
(6, '2025-07-04', '00:40:00', 'Swimming', 350),
(7, '2025-07-04', '00:35:00', 'Pilates', 300),
(8, '2025-07-04', '01:00:00', 'Running', 550),
(9, '2025-07-04', '00:45:00', 'CrossFit', 500),
(10, '2025-07-04', '00:20:00', 'Stretching', 150);

-- ------------------------------
-- Insert data into Health_Metric
-- ------------------------------
INSERT INTO Health_Metric (UserID, DateMeasured, MetricType, Value, Unit)
VALUES
(1, '2025-07-03', 'Heart Rate', 72, 'bpm'),
(2, '2025-07-03', 'Blood Pressure', 120, 'mmHg'),
(3, '2025-07-03', 'Sleep', 7.5, 'hours'),
(4, '2025-07-03', 'Glucose', 90, 'mg/dL'),
(5, '2025-07-03', 'BMI', 24, 'kg/m^2'),
(6, '2025-07-03', 'Heart Rate', 78, 'bpm'),
(7, '2025-07-03', 'Blood Pressure', 115, 'mmHg'),
(8, '2025-07-03', 'Sleep', 8, 'hours'),
(9, '2025-07-03', 'Glucose', 95, 'mg/dL'),
(10, '2025-07-03', 'BMI', 26, 'kg/m^2');

-- ------------------------------
-- Insert data into Hydration
-- ------------------------------
INSERT INTO Hydration (UserID, DateLogged, VolumeOz)
VALUES
(1, '2025-07-05', 64),
(2, '2025-07-05', 72),
(3, '2025-07-05', 80),
(4, '2025-07-05', 55),
(5, '2025-07-05', 90),
(6, '2025-07-05', 70),
(7, '2025-07-05', 65),
(8, '2025-07-05', 75),
(9, '2025-07-05', 68),
(10, '2025-07-05', 85);

-- ---------------------------------------
-- Verify that data was inserted correctly
-- ---------------------------------------
-- selects all the records from the food table to verify food items
SELECT * FROM food;
-- selects all records from the goal tables to verify the users goal
SELECT * FROM goal;
-- selects all records from the goal_category table to verify the users goal category
SELECT * FROM goal_category;
-- selects all records from the health_metric table to verify the users recorded health metric
SELECT * FROM health_metric;
-- selects all records from the hydration table to verify the users hydration logs
SELECT * FROM hydration;
-- selects all records from the meals table to verify meal entry
SELECT * FROM meal;
-- selects all records from meal_food table to verify associated meals between meals and foods
SELECT * FROM meal_food;
-- select all records from the user table to verify user information
SELECT * FROM user;
-- Select all records from the workout table to verify users workout log
SELECT * FROM workout;
