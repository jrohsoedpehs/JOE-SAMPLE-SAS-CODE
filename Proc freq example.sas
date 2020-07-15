/*EXAMPLE*/
proc contents data = sashelp.class;
run;
proc print data = cont_out;
run;


proc contents data = sashelp.class out = cont_out noprint;
run;


proc sql noprint;
 select name into : chargroup separated by ' ' from cont_out where type = 2; /*char is not necessarily categorical ie text field like name, may be*/
quit;
%put &chargroup;  /* just lets you see the variables in your log*/

proc freq data= sashelp.class (keep= &chargroup); /*Global macro, you can call it anywhere*/
run;

/*SHOWS YOU EVERY MACRO VARIABLE THAT IS RUNNING IN SAS*/
%PUT _global_ ; 

/*ADVICE: ALWAYS DO SUMMARY STATS AND QA SO YOU KNOW THAT YOUR CODE IS CORRECT AND CATCH MISTAKES*/
