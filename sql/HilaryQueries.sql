-- Team Project: Queries
-- Member: Hilary
-- Date: 7/13/25

-- Selecting database
USE Nutrition_Tracker_DB;
-- part1:
-- This query lists users who burned more calories through workouts than they consumed from meals.
-- Uses aggregate functions (SUM), multiple JOINs, and sorts by total calories burned.

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


-- part2:
-- This query retrieves users who had at least one snack-type meal, sorted by UserID.
select u.UserId, u.FName, u.LName,
( select count(*) 
	from meal m
	where m.UserID = u.UserID and m.MealType = 'Snack' )
as snackCount
from user u
having snackcount >0
order by u.UserId;

-- This query finds users who have logged workouts longer than 40 minutes ordered by duration.
select u.UserID, u.FName, u.LName, w.duration
from User u
join workout w on u.UserID = w.UserID
where w.Duration > '00:40:00'
order by w.Duration desc;


-- Part 3: 
-- Trigger deletes food links when a meal is removed
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
