/*Using retain statement to make demographic data show for all rows. */
/*Especially useful for REDCap data.*/

proc sort data = raw.asthma_2017;
by record_id; /*sort by id, don't include visits*/
run;

data test;
set raw.asthma_2017;
retain smoke1;
if first.record_id then smoke1=smoke; /*first.id (same variable as line 5)*/
else smoke1 = smoke1; /*retain lets smoke1 remember its value from line 11*/
by record_id; /*same variable as line 5*/
run;
