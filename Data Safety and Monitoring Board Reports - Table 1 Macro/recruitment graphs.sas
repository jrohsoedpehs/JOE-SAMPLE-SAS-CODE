/*LIBRARIES AND FOOTNOTE*/
%let path = ;

libname raw "&path\data\Raw";
libname derived "&path\data\Derived";
footnote "SAS Program Stored in: &path\programs\Draft\recruitment graphs.sas";

/*FORMATS*/
options fmtsearch=(raw.FERMIN_formats); 
options nofmterr;

proc format; 
    value country_ 1='USA' 2='Mexico' 3='Peru';
run;   





/*CHECK IF country ALREADY EXISTS*/
proc contents data= derived.demo_phase1 ;run;

/*OUTPUT*/

/*site_id COLLAPSE INTO COUNTRIES*/
ods rtf file="&path\documents\output\site_id &sysdate..doc" ;

proc freq data= derived.demo_phase1;
    table site_id;
run;
proc freq data= derived.demo_phase1;
    table site_id;
    format site_id;
run;

proc print data= derived.demo_phase1;
    where site_id = .;
run;
ods rtf close;


/*HOLD OFF UNTIL GRAPHS ARE DONE*/
/*proc freq data= derived.demo_phase1;*/
/*    table inpatient_vs_outpatient;*/
/*run;*/



/*CREATE country FROM site_id*/
data derived.recruitment;
    set derived.demo_phase1;

/*    month_inclusion_date = inclusion_date;*/
    month = month(inclusion_date);
    year = year(inclusion_date);
    month_inclusion_date = mdy(month, 1, year);

    if site_id in(1 2) then country = 1;
    if site_id in(3) then country = 2;
    if site_id in(4 5 6 7 8 12) then country = 3;

    if site_id = . and redcap_data_access_group='6_hospital_edgardo'
    then country = 3;

    format country country_. month_inclusion_date monyy7.;
run;

/*CHECK country*/
/*    Penn and Arizona are USA, */
/*    Guadalajara (site 3) is Mexico, */
/*    the others are Peru*/
proc freq data = derived.recruitment;
    tables country*redcap_data_access_group*site_id / list missing;
run;

proc freq data = derived.recruitment;
    tables month_inclusion_date*inclusion_date / list missing;
run;



/*ROUGH SUMMARY STATS ON inclusion_date*/
proc means data = derived.recruitment n nmiss;
    var inclusion_date;
run;


/*CHECK 5 HIGHEST AND LOWEST inclusion_date FOR OUTLIERS*/
ods trace on;
ods select extremeobs;
proc univariate data=derived.recruitment;
    var inclusion_date;
    histogram inclusion_date;
    id pt_id inclusion_date;
    title "5 highest and lowest dates for inclusion_date";
run;
ods trace off;
title;


/*AGGREGATE*/
proc freq data = derived.recruitment /*noprint*/;
    table month_inclusion_date / outcum out = work.total_enrolled_per_month;
    title "Cumulative patients enrolled per month";
run;
/*QA - check dataset prescreen*/
/*gives height of cumul graph*/
proc print data = work.total_enrolled_per_month; run; title;

/*USA*/
proc freq data = derived.recruitment /*noprint*/;
    where country = 1;
    table month_inclusion_date / outcum out = work.USA;
    title "Cumulative patients enrolled per month USA";
run;
/*QA - check dataset prescreen*/
proc print data = work.USA; run; title;


/*Mexico*/
proc freq data = derived.recruitment /*noprint*/;
    where country = 2;
    table month_inclusion_date / outcum out = work.Mexico;
    title "Cumulative patients enrolled per month Mexico";
run;
/*QA - check dataset prescreen*/
proc print data = work.Mexico; run; title;


/*Peru*/
proc freq data = derived.recruitment /*noprint*/;
    where country = 3;
    table month_inclusion_date / outcum out = work.Peru;
    title "Cumulative patients enrolled per Peru";
run;
/*QA - check dataset prescreen*/
proc print data = work.Peru; run; title;


/*BY country*/
proc sort data = derived.recruitment; by country; run;
proc freq data = derived.recruitment /*noprint*/;
    by country;
    table month_inclusion_date / outcum out = work.by_country;
    title "Cumulative patients enrolled per Peru";
run;
/*QA - check dataset prescreen*/
proc print data = work.by_country; run; title;


/*TRANSPOSE CUM_FREQ*/
proc sort data = work.by_country; by month_inclusion_date; run;
proc transpose data = work.by_country out=work.CUM_FREQ prefix=CUM_;
   by month_inclusion_date;
   id Country;
   var CUM_FREQ;
run;
proc print data = work.CUM_FREQ; run;

data work.CUM_FREQ;
    set work.CUM_FREQ;
/*    retain CUM_Mexico;*/
/*    temp = lag(CUM_Mexico);*/
/*    SOMETIMES lag() cannot be created within an if then statement*/
/*    assign a variable to lag() first then use the lag variable in the if then statement*/
/*    if CUM_Mexico = . then CUM_Mexico = temp;*/

    if CUM_USA ne . then _USA = CUM_USA;
    if CUM_USA = . and first.month_inclusion_date ne 1 then CUM_USA = _USA;

    if CUM_Mexico ne . then _mexico = CUM_Mexico;
    if CUM_Mexico = . and first.month_inclusion_date ne 1 then CUM_Mexico = _mexico;

    if CUM_Peru ne . then _Peru = CUM_Peru;
    if CUM_Peru = . and first.month_inclusion_date ne 1 then CUM_Peru = _Peru;

    retain _USA _Mexico _Peru ;

    temp_date = month_inclusion_date;
run;
proc print data= work.CUM_FREQ;
run;


/*PROC GPLOT*/
%MACRO GPLOT(dsn, Yaxis, title, color, height);


/*DEFINE OBJECTS FOR PLOT*/
/*DEFINE SYMBOLS AND LINE FOR ACTUAL PATIENTS ENROLLED PER MONTH*/
symbol1 
         c = &color  /*LINES AND DOTS ARE RED*/
         i = join /*DOTS ARE JOINED WITH A LINE*/
         v = dot  /*POINTS ARE DOTS*/
     width = 3
    height = 2; 

/*DEFINE LEGEND1*/
LEGEND1 POSITION = (TOP LEFT INSIDE) 
     FRAME VALUE = (HEIGHT=1.5 'Actual' /*'Expect'*/) 
          OFFSET = (0.0,0.0)CM 
          ACROSS = 1.5 
            MODE = PROTECT
           LABEL = (HEIGHT=1.5 FONT=SWISS 'Recruitment'); 

/*DEFINE VERTICAL AXIS1*/
     AXIS1 LABEL = (C=black F=SWISS a=90 H=2 'Cumulative Recruitment')
           MINOR = NONE 
           VALUE = (H=1.5 F=SWISS) 
           ORDER = 0 TO &height BY 10;

/*DEFINE HORIZONTAL AXIS2*/
     AXIS2 label = (c=black f=swiss h=2 'Month') 
           minor = none
           value = (h=1.5 F=SWISS)
           /*ORDER = 22190 TO 22371 BY 25*/;

/*CREATE PLOT*/
proc gplot data = &dsn;
    plot (&Yaxis)*month_inclusion_date/

    overlay 
        vaxis = AXIS1 
        haxis = AXIS2
 
    FRAME 
        LEGEND = LEGEND1 
         /*vref = 6*/;

    title "&title"; 
    footnote;
run;
quit;
title;


%MEND;


/*OUTPUT*/

ods rtf file="&path\documents\output\Cumulative Patient Recruitment Graphs &sysdate..doc" ;

%GPLOT(work.total_enrolled_per_month, CUM_FREQ, Cumulative Patient Recruitment for All Countries, black, 250);
%GPLOT(work.CUM_FREQ, CUM_USA, Cumulative Patient Recruitment USA, red, 90);
%GPLOT(work.CUM_FREQ, CUM_Mexico, Cumulative Patient Recruitment Mexico, blue, 70);
%GPLOT(work.CUM_FREQ, CUM_Peru, Cumulative Patient Recruitment Peru, green, 90);


/*DEFINE OBJECTS FOR PLOT*/
/*DEFINE SYMBOLS AND LINE FOR ACTUAL USA PATIENTS ENROLLED PER MONTH*/
symbol1 
         c = red  /*LINES AND DOTS ARE RED*/
         i = join /*DOTS ARE JOINED WITH A LINE*/
         v = dot  /*POINTS ARE DOTS*/
     width = 3
    height = 2; 

/*DEFINE SYMBOLS AND LINE FOR ACTUAL Mexico PATIENTS ENROLLED PER MONTH*/
symbol2 
         c = blue  /*LINES AND DOTS ARE RED*/
         i = join /*DOTS ARE JOINED WITH A LINE*/
         v = dot  /*POINTS ARE DOTS*/
     width = 3
    height = 2; 

/*DEFINE SYMBOLS AND LINE FOR ACTUAL Peru PATIENTS ENROLLED PER MONTH*/
symbol3 
         c = green  /*LINES AND DOTS ARE RED*/
         i = join /*DOTS ARE JOINED WITH A LINE*/
         v = dot  /*POINTS ARE DOTS*/
     width = 3
    height = 2; 

/*DEFINE LEGEND1*/
LEGEND1 POSITION = (TOP LEFT INSIDE) 
     FRAME VALUE = (HEIGHT=1.5 'USA' 'Mexico' 'Peru') 
          OFFSET = (0.0,0.0)CM 
          ACROSS = 1.5 
            MODE = PROTECT
           LABEL = (HEIGHT=1.5 FONT=SWISS 'Recruitment'); 

/*DEFINE VERTICAL AXIS1*/
     AXIS1 LABEL = (C=black F=SWISS a=90 H=2 'Cumulative Recruitment')
           MINOR = NONE 
           VALUE = (H=1.5 F=SWISS) 
           ORDER = 0 TO 100 BY 10;

/*DEFINE HORIZONTAL AXIS2*/
     AXIS2 label = (c=black f=swiss h=2 'Month') 
           minor = none
           value = (h=1.5 F=SWISS);
/*           ORDER = NEED FORMAT FOR MONTHS AND YEARS '01DEC2000'd;*/

/*CREATE PLOT*/
proc gplot data = work.CUM_FREQ;
    plot (CUM_USA CUM_Mexico CUM_Peru)*month_inclusion_date/

    overlay 
        vaxis = AXIS1 
        haxis = AXIS2
 
    FRAME 
        LEGEND = LEGEND1 
         /*vref = 6*/; /*creates a horizontal line y=6*/

    title "Cumulative Patient Recruitment By Country"; 
    footnote;
run;
quit;
title;


ods rtf close;
