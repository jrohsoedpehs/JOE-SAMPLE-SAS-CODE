/*intck() function counts the number of days, months, years, hours, etc between two dates of the same format*/
/*note abs() is the absolute value this avoids negatives*/
data dsn;
/*set _null_;*/
year= abs(intck('year','31dec94'd,'01jan95'd));
put year;
run;

proc print data= dsn;run;
