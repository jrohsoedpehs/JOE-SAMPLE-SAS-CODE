proc contents data = raw.walkabout_form2;run;

proc contents data =  out =  noprint;
run;

/*QA ON */
proc print data= ;
run;

proc sql noprint;
	select name into : varlist separated by ' ' from ___ 
	where type = 2;
quit;
%put &varlist;
