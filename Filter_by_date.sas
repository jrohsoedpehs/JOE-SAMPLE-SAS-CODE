libname Raw "Q:Nalaka Gooneratne\Memories2\data\Raw";
libname Derived "Q:Nalaka Gooneratne\Memories2\data\Derived";
footnote "SAS Program Stored in: Q:Nalaka Gooneratne\Memories2\programs\Draft\MRI_and_Neuropsych_Tables.sas";
/*options fmtsearch=(raw.m2main_formats);*/
options nofmterr;

proc freq data=NP_screen_fail_rate;
where mdy(06,30,2018) < exit_date < mdy(8,1,2018);
/* by redcap_event_name; */
table site_name*np_screen_fail /nopercent nocol;
run;
/*QA Check if the dates fall between 6/30/2018 and 8/1/2018*/
proc print data= ;
var exit_date;
run;

/*QA Check if the dates fall between 6/30/2018 and 8/1/2018*/
/*proc print data= NP_screen_fail_rate;*/
/*where mdy(06,30,2018) < exit_date < mdy(8,1,2018);*/
/*var exit_date;*/
/*run;*/

