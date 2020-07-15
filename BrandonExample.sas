libname raw 'Q:\Nalaka Gooneratne\Memories2\data\Raw'; 
libname derived "Q:\Nalaka Gooneratne\Memories2\data\Derived";
footnote "SAS Program Stored in: path";
options fmtsearch=(raw);
/*options nofmterr;*/

/***************************************
Description of task

***************************************/
proc contents data= raw.adrd;
run;


proc freq data= raw.adrd;
tables cr_nhome tics_rep_m2___1;
run;
