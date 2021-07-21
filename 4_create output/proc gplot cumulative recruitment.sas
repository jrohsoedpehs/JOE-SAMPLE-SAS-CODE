proc freq data = work.recruitment /*noprint*/;
    table month_inclusion_date / outcum out = work.total_enrolled_per_month;
	title "patients enrolled per month";
run;
title;


/*QA - check dataset prescreen*/
proc print data = work.total_enrolled_per_month;
	title 'Check montly counts';
run;
title;


/*DEFINE OBJECTS FOR PLOT*/

/*DEFINE SYMBOLS AND LINE FOR ACTUAL PATIENTS ENROLLED PER MONTH*/
symbol1 
         c = red  /*LINES AND DOTS ARE RED*/
         i = join /*DOTS ARE JOINED WITH A LINE*/
         v = dot  /*POINTS ARE DOTS*/
     width = 1
    height = 2; 

/*DEFINE SYMBOLS AND LINE FOR PREDICTED PATIENTS ENROLLED PER MONTH*/
/*symbol2 */
/*         c = black */
/*         i = join */
/*         v = circle */
/*    height = 2;*/

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
           ORDER = 0 TO 170 BY 10;

/*DEFINE HORIZONTAL AXIS2*/
     AXIS2 label = (c=black f=swiss h=2 'Month') 
           minor = none
           value = (h=1.5 F=SWISS);
/*           ORDER = NEED FORMAT FOR MONTHS AND YEARS '01DEC2000'd;*/

/*CREATE PLOT*/
proc gplot data = work.total_enrolled_per_month;
	plot (CUM_FREQ)*month_inclusion_date/

    overlay 
        vaxis = AXIS1 
        haxis = AXIS2
 
    FRAME 
        LEGEND = LEGEND1 
         /*vref = 6*/;

	title 'Cumulative PATIENTS ENROLLED PER MONTH'; 
    footnote;
run;
quit;
