/*intnx function*/

data dummy;
date = mdy(8,26,2020);
date_week_start = 1 * (intnx('WEEK',  date, 0, 'beginning')); 
date_month_start = 1 * (intnx('MONTH',  date, 0, 'beginning')); 
format date date_week_start date_month_start mmddyy10.;
run;

proc print data=dummy;
run;
