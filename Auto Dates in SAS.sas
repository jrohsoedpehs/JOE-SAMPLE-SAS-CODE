/*Automatic Dates in SAS*/

/*Auto start with today's date and 7 days ago*/



data test;
today = today();
day_7 = %eval(%sysfunc(today())-7);
format today day_7 mmddyy10.
run;
proc contents data= test varnum;run;
proc print data= test; run;



data dsn1;
input study_id $ referral_date;
cards;
1 1
2 0
3 0
4 1
;
run;

title "";
proc freq data=  derived.referral_tracking ;
tables pre_screen_interest*outcome_of_consent_visit /list missing nopercent nocol;
/*pre_screen_interest = yes*/
where pre_screen_interest = 1 
/*past 7 days*/
and %eval(%sysfunc(today())-7) < referral_date < today()
;
title "# of Pos. Referrals in past 7 days";
run;


