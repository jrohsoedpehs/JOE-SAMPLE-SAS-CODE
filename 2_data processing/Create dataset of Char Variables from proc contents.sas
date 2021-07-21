/*USING PROC CONTENTS
The output to proc contents can be stored in SAS datasets. This output has some additional information about both
variables and datasets that can be used. The following code creates an output dataset called cont_out from the
dataset science_data.*/
proc contents data = science_data out = cont_out noprint;
run;

/*USING OUTPUT FROM PROC CONTENTS TO BUILD A VARIABLE LIST
Once we know which variables we want to include in our analysis, a macro variable is built using PROC SQL with the
into clause. Here is some sample code using proc contents to build a variable list from of all the character variables
in the dataset called science_data:*/
proc sql noprint;
 select name into : varlist separated by ' ' from cont_out where type = 2;
quit;
%put &varlist;
/*Here is the log…
proc contents data = science_data out = cont_out noprint;
run;
NOTE: The data set WORK.CONT_OUT has 9 observations and 40 variables.
NOTE: PROCEDURE CONTENTS used (Total process time):
 real time 0.01 seconds
 cpu time 0.03 seconds
proc sql noprint;
select name
into : varlist
separated by ' '
from cont_out
where type = 2;
quit;
NOTE: PROCEDURE SQL used (Total process time):
 real time 0.01 seconds
 cpu time 0.03 seconds
%put &varlist;
ASTROSCI CONSCI EDUC MARITAL POLVIEWS RELIG SEX SPEDUC
Macro variable &varlist can now be used in a keep statement or keep = option in a dataset.
If you have a relatively short list of variables you don’t want to keep, those variables can be specifically excluded. If
for example we wanted to exclude ASTROSCI and CONSCI we can use the following code…*/
proc sql noprint;
 select name into : varlist separated by ' ' from cont_out where type = 2 and name not in ('ASTROSCI', 'CONSCI');
quit;
