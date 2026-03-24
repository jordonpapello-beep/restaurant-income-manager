/*
The following is the data base management system for the 'barbackDB' which contains the 'income' table which stores
all of the income types and associated metrics like dates, position worked, hourly wage, etc... . Below you will find the scripts
for the creation of the income table and its triggers (columns in the table that are calculated from other table columns), 
and the associated table actions created for this data base: stored procedures, and views.
*/

-- 								-------------------- CREATION --------------------
-- Currently the only table in the barbackDB. Stores all date, money, hours, position, and location information about shifts worked.
CREATE TABLE income (
date DATE, -- Insert
hourly_wage DEC(4,2) DEFAULT 10.65,
cash_tips DEC(6,2), -- Insert
credit_tips DEC(5,2) DEFAULT 0.00,
hours_worked DEC(4,2), -- Insert
wage_pay DEC(5,2), -- Trigger (52% of hourly * hours)
total_income DEC(6,2), -- Trigger (Sum of income)
position VARCHAR(10), -- Insert
location VARCHAR(10) DEFAULT "Dublin",
PRIMARY KEY (date, position)
);


/* To veiw the code for a specific table in main:
	SHOW CREATE TABLE income;
*/

-- 								-------------------- INSERTION EXAMPLE --------------------
-- When inserting new shift info into income, you only require the following.

INSERT INTO income (date, cash_tips, hours_worked, position) -- Use when logging a new shift
VALUES( "2024-04-27", 445, 10.5, "Bartender");


-- 									-------------------- TRIGGERS --------------------
-- Trigger to INSERT a value into "wage_pay" after a new shift is logged
-- For Adjusting the percentage that gets taken out from Gross to Net pay for "wage_pay":
DELIMITER //
CREATE TRIGGER calculate_wage_pay
BEFORE INSERT ON income
FOR EACH ROW
BEGIN
    SET NEW.wage_pay = NEW.hours_worked * (0.52 * NEW.hourly_wage);
END;
//
DELIMITER ;


-- Trigger to INSERT a value into "total_income" after a new shift is logged
DELIMITER //
CREATE TRIGGER calculate_total_income
BEFORE INSERT ON income
FOR EACH ROW
BEGIN
    SET NEW.total_income = NEW.cash_tips + NEW.credit_tips + NEW.wage_pay;
END;
//
DELIMITER ;

/* To veiw the code for a specific trigger in main:
	SHOW CREATE TRIGGER calculate_wage_pay;
*/

-- 								-------------------- STORED PROCEDURES --------------------
-- Best shifts procedure that takes 1 INT paramater that defines how much to LIMIT the result by
-- bestShifts(5) would return the 5 shifts with the highest total_income listed in descending order
DELIMITER $$
CREATE PROCEDURE bestShifts (IN lim INT)
BEGIN
	SELECT date AS "Best Shifts",
		   DAYNAME(date) AS "Day of Week", 
		   hours_worked AS "Hours Worked",
		   wage_pay AS "Moeny from Wage",
           CONCAT("$", cash_tips) AS "Cash Tips",
           CONCAT("$",total_income) AS "Total Money Made"
	FROM income
	ORDER BY total_income DESC
    LIMIT lim;
END $$
DELIMITER ;

/* To veiw the code for a specific stroed procedure in main:
	SHOW CREATE PROCEDURE bestShifts;
*/
        
           
-- 									-------------------- VIEWS --------------------
-- This view is used for displaying the monetary columns of the income table per shift worked in a clear way to the user:
CREATE VIEW  money AS 
SELECT date AS `Date`,
dayname(date) AS "Day of Week",
wage_pay AS "Wage Pay",
credit_tips AS "Credit Tips",
cash_tips AS "Cash Tips",
total_income AS "Total Income" 
FROM income;


-- View of the the daily averages from barbacking shifts at dublin
CREATE VIEW get_averages_barback AS
SELECT DAYNAME(date) AS "Day Of Shift", 
	   COUNT(DAYNAME(date)) AS "Number of Shifts Worked", 
       ROUND(AVG(hours_worked), 2) AS "Average Hours Worked",
       CONCAT("$", ROUND(AVG(total_income) / AVG(hours_worked), 2)) AS "Average Hourly Pay",
       CONCAT("$", ROUND(AVG(cash_tips),2)) AS "Average Cash Tips",
       CONCAT("$", ROUND(AVG(total_income),2)) AS "Average Total Income",
       CONCAT("$", ROUND(SUM(total_income), 2)) AS "Total Money Made"
FROM income
WHERE location = "Dublin" AND position = "Barback"
GROUP BY DAYNAME(date)
ORDER BY AVG(total_income) DESC;


-- View of the daily averages from bartending shifts at dublin
CREATE VIEW get_averages_bartender AS
SELECT DAYNAME(date) AS "Day Of Shift", 
	   COUNT(DAYNAME(date)) AS "Number of Shifts Worked", 
       ROUND(AVG(hours_worked), 2) AS "Average Hours Worked",
       CONCAT("$", ROUND(AVG(total_income) / AVG(hours_worked), 2)) AS "Average Hourly Pay",
       CONCAT("$", ROUND(AVG(cash_tips),2)) AS "Average Cash Tips",
       CONCAT("$", ROUND(AVG(total_income),2)) AS "Average Total Income",
       CONCAT("$", ROUND(SUM(total_income), 2)) AS "Total Money Made"
FROM income
WHERE location = "Dublin" AND position = "Bartender"
GROUP BY DAYNAME(date)
ORDER BY AVG(total_income) DESC;


-- View of the Statistical Data from Dublin Shifts for 'cash_tips'
-- Table of statistical analysis of the 'cash_tips' column data:
-- The sample formula is used when the data set represents a random sample from the entire population in question. 
-- The population formula is used when there is data from the entire population being studied or considered.
-- The variance measures the average degree to which each number is different from the mean. Measured in percents.
-- The vaiance of a data set is technically the average of the squared differences from the mean.
/*
The extent of the variance correlates to the size of the overall range of numbers, 
which means the variance is greater when there is a wider range of numbers in the group, 
and the variance is less when there is a narrower range of numbers.
*/ 
-- Both standard deviation and variance measure the "variability/volatility" of the data set, just in different units.
-- Both are in relation to the mean of the data set.
CREATE VIEW get_statisticsCASH AS
SELECT  COUNT(cash_tips) AS "Number of Data Points",
		CONCAT("$", MIN(cash_tips)) AS "Minimum",
        CONCAT("$", MAX(cash_tips)) AS "Maximum",
        CONCAT("$", MAX(cash_tips)-MIN(cash_tips)) AS "Range",
		CONCAT("$", ROUND(AVG(cash_tips), 2)) AS "Mean", -- Average or MEAN of cash_tips
        CONCAT("$", ROUND(STD(cash_tips), 2)) AS "Standard Deviation", -- ST. DEV measures how far apart data is in the set on average.
	    -- CONCAT("$", ROUND(STDDEV_POP(cash_tips), 2)) AS "Pop. Stndrd DV", -- Same as STD
        -- CONCAT("$", ROUND(STDDEV_SAMP(cash_tips), 2)) AS "Samp. Stndrd DV",
        CONCAT(ROUND(VAR_POP(cash_tips), 2), "%") AS "Pop. Variance", -- Variance measures an actual value to how much the numbers in a data set vary from the mean.
        -- CONCAT(ROUND(VAR_SAMP(cash_tips), 2), "%") AS "Samp. Variance",
        CONCAT(CONCAT("$", ROUND((AVG(cash_tips)-STD(cash_tips)), 2)),
			   " to ", 
               CONCAT("$", ROUND((AVG(cash_tips)+STD(cash_tips)), 2))) AS "1 STD AWAY / 68%",  -- 68% of data falls into this range
		CONCAT(CONCAT("$", ROUND((AVG(cash_tips)-(2*STD(cash_tips))), 2)),
			   " to ", 
               CONCAT("$", ROUND((AVG(cash_tips)+(2*STD(cash_tips))), 2))) AS "2 STD's AWAY / 95.5%"
FROM income
WHERE location = "Dublin";

-- Same as previous, but for 'total_income':
CREATE VIEW get_statisticsTotal AS
SELECT  COUNT(total_income) AS "Number of Data Points",
		CONCAT("$", MIN(total_income)) AS "Minimum",
        CONCAT("$", MAX(total_income)) AS "Maximum",
        CONCAT("$", MAX(total_income)-MIN(total_income)) AS "Range",
		CONCAT("$", ROUND(AVG(total_income), 2)) AS "Mean", -- Average or MEAN of cash_tips
        CONCAT("$", ROUND(STD(total_income), 2)) AS "Standard Deviation", -- ST. DEV measures how far apart data is in the set on average.
        CONCAT(ROUND(VAR_POP(total_income), 2), "%") AS "Pop. Variance", -- Variance measures an actual value to how much the numbers in a data set vary from the mean.
        CONCAT(CONCAT("$", ROUND((AVG(total_income)-STD(total_income)), 2)),
			   " to ", 
               CONCAT("$", ROUND((AVG(total_income)+STD(total_income)), 2))) AS "1 STD AWAY / 68%",  -- 68% of data falls into this range
		CONCAT(CONCAT("$", ROUND((AVG(total_income)-(2*STD(total_income))), 2)),
			   " to ", 
               CONCAT("$", ROUND((AVG(total_income)+(2*STD(total_income))), 2))) AS "2 STD's AWAY / 95.5%"
FROM income
WHERE location = "Dublin";

-- View that compares various column sums, grouped by years, for shifts worked at dublin (NOTE: after 2021 all shifts are from dublin):
CREATE VIEW dublin_yearly_comparison AS
SELECT "2024" AS "Year",
	   COUNT(DISTINCT date) AS "Number of Shifts YTD", 
	   CONCAT("$",ROUND(SUM(cash_tips)/(COUNT(DISTINCT date)), 2)) AS "Average $/Shift",
	   CONCAT("$",SUM(wage_pay)) AS "Wage Pay",
	   CONCAT("$",SUM(cash_tips)) AS "Total Cash", 
	   CONCAT("$",SUM(wage_pay)+SUM(cash_tips)) AS "Sum of Total Income" 
FROM income
WHERE date LIKE "2024%"
UNION
SELECT "2023",
	   COUNT(DISTINCT date) AS "Number of Shifts YTD", 
	   CONCAT("$",ROUND(SUM(cash_tips)/(COUNT(DISTINCT date)), 2)) AS "Average $/Shift",
	   CONCAT("$",SUM(wage_pay)) AS "Wage Pay",
	   CONCAT("$",SUM(cash_tips)) AS "Total Cash", 
	   CONCAT("$",SUM(total_income)) AS "Sum of Total Income" 
FROM income
WHERE date LIKE "2023%"
UNION
SELECT "2022",
	   COUNT(DISTINCT date) AS "Number of Shifts YTD", 
	   CONCAT("$",ROUND(SUM(cash_tips)/(COUNT(DISTINCT date)), 2)) AS "Average $/Shift",
	   CONCAT("$",SUM(wage_pay)) AS "Wage Pay",
	   CONCAT("$",SUM(cash_tips)) AS "Total Cash", 
	   CONCAT("$",SUM(total_income)) AS "Sum of Total Income" 
FROM income
WHERE date LIKE "2022%"
UNION
SELECT "2021",
	   COUNT(DISTINCT date) AS "Number of Shifts YTD", 
	   CONCAT("$",ROUND(SUM(cash_tips)/(COUNT(DISTINCT date)), 2)) AS "Average $/Shift",
       CONCAT("$",SUM(wage_pay)) AS "Wage Pay",
	   CONCAT("$",SUM(cash_tips)) AS "Total Cash", 
	   CONCAT("$",SUM(total_income)) AS "Sum of Total Income" 
FROM income
WHERE date LIKE "2021%" AND location = "Dublin";


/* To veiw the code for a specific view in main:
	SHOW CREATE VIEW dublin_yearly_comparison;
*/
