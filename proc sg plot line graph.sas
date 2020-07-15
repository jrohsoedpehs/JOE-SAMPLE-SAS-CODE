/*Proc sgplot*/

/*Macrolize this and repeat for each site*/
proc contents data=deleteme_t1_wide;run;
proc print data=deleteme_t1_wide (obs=30);run;

data graph_data;
set deleteme_t1_wide;
/*month = month(intake_week_start);*/
/*year = year(intake_week_start);*/
month_year = intake_week_start;
format month_year mmyy.;
run;
/*QA month and year*/
proc freq data=graph_data;
/*table year*month*intake_week_start/list missing;*/
table month_year*intake_week_start/list missing;
run;
proc print data=graph_data (obs=30);run;

proc sort data=graph_data;
by month_year;
run;

proc means data= graph_data maxdec=2;
by month_year;
var UP UV UT WU;
output out = dsn sum= UP_total UV_total UT_total WU_total ;
run;
/*QA dsn*/
proc print data=dsn (obs=30);run;


ODS GRAPHICS / RESET IMAGENAME = 'T1 Graph' IMAGEFMT =JPEG
 HEIGHT = 6in WIDTH = 6in;
*ODS LISTING GPATH = 'c:\MyGraphs' ; 

PROC SGPLOT DATA = dsn;
/* SERIES X = intake_week_start Y = WU / BREAK*/
/* MARKERS LINEATTRS = (THICKNESS = 1 ); */
 SERIES X = month_year Y = UP_total / BREAK
 MARKERS LINEATTRS = (THICKNESS = 1); 

 XAXIS LABEL = 'Month' TYPE = DISCRETE GRID ;
 YAXIS LABEL = 'Count' Type= Discrete GRID ; 
 TITLE 'Subjects pre-screened by month';
 *INSET 'Source: st01, T1'/ POSITION = TOPLEFT NOBORDER;
 FOOTNOTE 'Source: st01, table T1 (https://upenn.app.box.com/file/332831883988)' justify=right h=1pt;
RUN; 
quit;




/*MACRO VERSION*/

/*Settings for graphics*/
ODS GRAPHICS / RESET IMAGENAME = "T1 Graph" IMAGEFMT =JPEG
HEIGHT = 6in WIDTH = 6in;
*ODS LISTING GPATH = "c:\MyGraphs" ; 

/*Fuction/macro for creating a plot by site*/
%macro site_plot(site_name, site_total);
PROC SGPLOT DATA = dsn;
/* SERIES X = intake_week_start Y = WU / BREAK*/
/* MARKERS LINEATTRS = (THICKNESS = 1 ); */
 SERIES X = month_year Y = &site_total / BREAK
 MARKERS LINEATTRS = (THICKNESS = 1); 

 XAXIS LABEL = "MonthYear" TYPE = DISCRETE GRID ;
 YAXIS LABEL = "Count" Type= Discrete GRID ; 
 TITLE "&site_name Subjects pre-screened by month";
 *INSET "Source: st01, T1"/ POSITION = TOPLEFT NOBORDER;
 FOOTNOTE "Source: st01, table T1 (https://upenn.app.box.com/file/332831883988)" justify=right h=1pt;
RUN; 
quit;
%mend;
/*Use %site_plot(); function to create plots for UP, UV, UT, WU, and total*/
%site_plot(UP, UP_total);
%site_plot(UV, UV_total);
%site_plot(UT, UT_total);
%site_plot(WU, WU_total);
%site_plot(Total, total_total);
