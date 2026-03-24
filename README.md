# restaurant-income-manager
---
### Project Overiew:

* Simple one table data base management system (DBMS) that stores the 'income' table which tracks dates and income earned from working various jobs at a restaurant. All basic aspects of SQL are represented: CREATE, INSERT, TRIGGERS, VIEWS, and STORED PROCEDURES.

* This project is split into two seperate files/scripts for clarity: `barbackDB_DBMS.sql`, and `main_barback.sql`. The purpose of this split is to have one script which shows all of the backend code that was used to create the DBMS (table, triggers, views, stored procedure), and the main/primary script which is where the actual viewing and insertion of data takes place.

* The output for the main `income` table can be viewed as a CSV file, along with: chosen popular SELECT statments, the VIEWS, and the created STORED PROCEDURE. All of these files and be found in the `Data` folder.
---

### Project Order:
The following is the order you should view the files of this project in:

* `SQL Files/`
  * `barbackDB_DBMS.sql`
  * `main.sql`
* `Data/SELECT/`
  * `income.csv`
  * `income_2024_desc.csv`
  * `income_2024_desc_dayname.csv`
* `Data/VIEW/`
  * `money.csv`
  * `get_averages_barback.csv`
  * `get_averages_bartender.csv`
  * `get_statisticsCASH.csv`
  * `get_statisticsTotal.csv`
  * `dublin_yearly_comparison.csv`
* `Data/STORED PROCEDURE/`
  * `bestShifts(10).csv`
---
### In Depth Description:
The following will be a description of the purpose of some of the views and the stored procedure in the `Data` folder. For more descriptions please review the comments in the sql files themselves.

**VIEWS:**
* **money:** This view is used for **displaying the monetary columns of the `income` table per shift worked in a clear way to the user.** Furthermore, the `Day of Week` column was added to add further clarity on when the shift was worked specifically during the week.
  
* **get_averages_barback:** This view provides a day by day breakdown of all of the shifts worked as a "barback" on the `income` table WHERE the shift was worked at "dublin". Specificaly, each row represents a day of the week and the following columns are **aggregates** of all rows that fall onto that day. This is advantageous because we can compare the total shifts worked, and more importantly the monetary averages `Average Hourly Pay`, `Average Cash Tips`, `Average Total Income`, and `Total Money Made` across specific days of the week. Furthermore, this table is ORDERED BY `Average Total Income`, so the user can easily determine what shifts are historically the highest paying on average. **This is valuable because all of these columns are calculated based on the data from `income`, and is not directly available or easily ascertainable by simply viewing `income` alone.**
  
* **get_averages_bartender:** This view does the exact same thing as the above view, with the exception that it filters for shifts worked as a "bartender" instead of a "barback".
  
* **get_statisticsCASH:** This view is used to analyze the statistics of the `cash_tips` column of the `income` table for shifts worked at "dublin". The statistics being analyzed are specifically the `Number of Data Points` (number of shifts worked), the `Minimum`, `Maximum`, `Range`, `Mean`, `Standard Deviation`, `Pop. Variance` (population), and the ranges between +-1 STD (68% of data) and +-2 STD (95.5% of data). This view simplifies the analysis of data distribution by calculating key measures of central tendency and dispersion. **It provides an immediate look at the spread and reliability of shift patterns, specifically highlighting the 1σ (68%) and 2σ (95.5%) confidence intervals.**
  
* **get_statisticsTotal:** This view does the same thing as the above view, with the exception of using the `total_income` column from `income` to calculate it's values instead of the `cash_tips` column.
  
* **dublin_yearly_comparison:** This view is used to analyze aggregate data sperated by year for shifts worked at "dublin" from the `income` table. Specifically, for each `Year`, the `Number of Shifts YTD`, `Average$/Shift`, `Wage Pay`, `Total Cash`, and `Sum of Total Income` is displayed. **This is essential for comparing year to year data from the `income` table.**

**STORED PROCEDURE:**
* **bestShifts():** The purpose of this stored procedure is to display the "best shifts" recorded on the income table. The best shifts are determined by the `total_income` column of the `income` table. The user has the capability to set the LIMIT of the select statement that is the STORED PROCEDURE **(e.g. bestShifts(25) displays the rows with the top 25 values for `total_income` in descending order).**
---

   
