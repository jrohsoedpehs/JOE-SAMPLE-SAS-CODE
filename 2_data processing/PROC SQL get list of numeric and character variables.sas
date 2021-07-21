/*use proc sql to output a dataset cont_out*/
proc contents data=sashelp.cars varnum out=cont_out noprint; run;

proc print data= cont_out /*(obs=10)*/;
run;

/*NUMERIC*/
proc sql noprint;  
    select NAME into : NUMERIC separated by '1 ' from cont_out  
/*    where type = 1 and format in ('BEST');*/
    where type = 1; 
quit; 
%put &NUMERIC;

/*CHARACTER*/
proc sql noprint;  
    select NAME into : CHARACTER separated by ' ' from cont_out  
    where type = 2; 
quit; 
%put &CHARACTER;
