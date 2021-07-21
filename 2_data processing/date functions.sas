/*Working with dates*/

/*If a variable has a SAS date format, the following functions can extract the month, day, or year*/

/*year(date)*/
/*month(date)*/
/*day(date)*/

/*example*/
data graph_data;
set deleteme_t1_wide;
month = month(intake_week_start);
year = year(intake_week_start);
run;
