-- SELECTING DATA:
-- Popular Selects:
-- Show the entrie table:
SELECT * FROM income; 

-- Show the data from a single year in descending date order:
SELECT * FROM income
WHERE date LIKE "2024%"
ORDER BY date DESC;

-- Convert dates to the day of the week it was and show income data in date descending order for a single year:
SELECT date, DAYNAME(date) AS "day_name", wage_pay, cash_tips, total_income FROM income
WHERE date LIKE "2024%"
ORDER BY date DESC;


-- INSERTING:
-- Use when logging a new shift for bartending:
INSERT INTO income (date, cash_tips, hours_worked, position) 
VALUES("2024-10-13", 256, 6.03, "Bartender");

-- Use when logging a new shift for barbacking:
INSERT INTO income (date, cash_tips, hours_worked, position) 
VALUES("2024-10-12", 598, 14.67, "Barback");

-- Use when logging a new shift for managing:
INSERT INTO income (date, cash_tips, hours_worked, position) 
VALUES("2024-12-25",1000, 1, "Managing");
 

-- VIEWS:
SELECT * FROM money; -- Displays the money view
SELECT * FROM get_averages_barback; -- Displays the daily averages view for barbacking shifts
SELECT * FROM get_averages_bartender; -- Displays the daily averages view for bartending shifts
SELECT * FROM get_statisticsCASH; -- Displays Statistical Data from Dublin Shifts for 'cash_tips'
SELECT * FROM get_statisticsTotal; -- Same as above, but for 'total_income'
SELECT * FROM dublin_yearly_comparison; -- compares various column sums, grouped by years, for shifts worked at dublin


-- STORED PROCEDURES:
CALL bestShifts(10); -- Return "x" number of best shifts ordered by "total_income"
