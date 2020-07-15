*Code used by CCC team to monitor recruitment;

*zzz--formatted for Joe's computer;
libname raw "q:\nalaka gooneratne\memories2\data\raw";

*zzz--formatted for Joe's computer;
libname der "q:\nalaka gooneratne\memories2\data\derived";

footnote "sas program stored in: q:\nalaka gooneratne\memories2\programs\draft\cr00_setup_workspace_joseph";

*zzz--this line below may give errors--don't know where adrd_format or long_formats is coming from;
options fmtsearch=(raw.adrd_format /*raw.demog_formats*/ raw.long_formats);

options nofmterr;

/***************************************
description of task
merge the following datasets:
adrd_screening from each site, then merge this with m2_main
***************************************/

/*import datasets from each site using the sas code for the site saved in the Recruitment folder
-Will need to change the infile directory*/

*Confirm that each sites datafile has a site value for each record;

/*UPENN*/
data raw.up_redcap1;
set raw.up_redcap;
/*replace missing site*/
if site=. then site=2;
run;

/*UVirginia*/
data raw.uv_redcap1;
set raw.uv_redcap;
/*replace missing site*/
if site=. then site=4;
run;

/*Utexas*/
data raw.ut_redcap1;
set raw.ut_redcap;
/*replace missing site*/
if site=. then site=3;
run;

/*WashU*/
data raw.wu_redcap1;
set raw.wu_redcap;
/*replace missing site*/
if site=. then site=1;
run;


/*value site_ 1='St. Louis' 2='Philadelphia' */
/*		3='Austin' 4='Virginia';*/
	

*Goal:  Determine how many TICS are being done at each site;
