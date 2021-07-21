/*MACRO - RUN THE SAME CODE FOR A GROUP OF VARIABLES */

/* need to run the same code for 5 variables, and each variable 4 times, so total 20 times:*/
 
 
 
%macro scatter(var=,p=);
data test;
set percent.&var._&p;
ID = _n_;  /* have to create a ID variable as x-axis variable for scatter plot purpose */
run;
proc sgplot data=test;
scatter x=ID y=&var;
title "&var  &p";
run;
%mend scatter;
%scatter(var=betting_days,p=p90)
%scatter(var=betting_days,p=p95)
%scatter(var=betting_days,p=p98)
%scatter(var=betting_days,p=p99)

%scatter(var=total_bet_times,p=p90)
%scatter(var=total_bet_times,p=p95)
%scatter(var=total_bet_times,p=p98)
%scatter(var=total_bet_times,p=p99)

%scatter(var=max_wager,p=p90)
%scatter(var=max_wager,p=p95)
%scatter(var=max_wager,p=p98)
%scatter(var=max_wager,p=p99)

%scatter(var=sum_wager,p=p90)
%scatter(var=sum_wager,p=p95)
%scatter(var=sum_wager,p=p98)
%scatter(var=sum_wager,p=p99)

%scatter(var=aver_wager_day,p=p90)
%scatter(var=aver_wager_day,p=p95)
%scatter(var=aver_wager_day,p=p98)
%scatter(var=aver_wager_day,p=p99)



/*macro*/

data macro_call;
do var='betting_days', 'total_bet_times', 'max_wager', 'sum_wager';
do p='p90', 'p95', 'p98','p99';

str=catt('%scatter(var=', var, ', p=', p, ')');

call execute(str);

end;
end;
run;
