libname raw "Q:\Nalaka Gooneratne\Memories2\DSMB\DSMB_2018_Fall\data\Raw";
libname derived "Q:\Nalaka Gooneratne\Memories2\DSMB\DSMB_2018_Fall\data\Derived";
footnote "SAS program stored: Q:\Nalaka Gooneratne\Memories2\DSMB\DSMB_2018_Fall\programs\Draft\makeData.sas";

options fmtsearch=(raw.upenn_formats raw.m2main_formats);
options nofmterr;

/*PROC TABULATE gives you the same output as a proc means, but you have more control over how your output tables look*/
proc tabulate data = derived.adrd_m2main format=8.2;
      class site_code;	*Classes for evaluation;
      var dx_overall_ahi; *Variables to be used for the analysis;
      table (dx_overall_ahi)*site_code*(n);  *The final parentheses can include whatever statistical values you would like;
*      title ______;   *Whatever your title is;
run;

proc tabulate data = derived.adrd_m2main format=8.2;
*Classes for evaluation;
var dx_overall_ahi; *Variables to be used for the analysis;
class site_code;
table site_code, (dx_overall_ahi)*(n);  *The final parentheses can include whatever statistical values you would like;
*      title ______;   *Whatever your title is;
run;

proc tabulate data = derived.adrd_m2main format=8.2;
*Classes for evaluation;
var dx_overall_ahi; *Variables to be used for the analysis;
class site_code;
table  (dx_overall_ahi)*(n), site_code;  *The final parentheses can include whatever statistical values you would like;
*      title ______;   *Whatever your title is;
run;

proc tabulate data = derived.adrd_m2main format=8.2;
*Classes for evaluation;
var dx_overall_ahi; *Variables to be used for the analysis;
class site_code;
table  (dx_overall_ahi)*(n), site_code;  *The final parentheses can include whatever statistical values you would like;
*      title ______;   *Whatever your title is;
run;
