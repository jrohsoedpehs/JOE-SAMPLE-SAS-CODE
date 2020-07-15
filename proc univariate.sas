/*Proc univariate*/
/*proc means*/
/*distribution*/
/*5 lowest and highest*/

proc univariate data=derived.fitnessgram_accelerometer normal ;
var bmi;
histogram bmi;
id Accelerometer;
run;



/*SHOW HIGHEST AND LOWEST ONLY*/
/*CHOOSE / FILTER OUTPUT FROM A PROCEDURE*/
ods trace on;
ods select extremeobs;
proc univariate data=test;
class TCode;
var diff_date;
histogram diff_date;
id subject_id TCode TDate;
run;
ods trace off;
