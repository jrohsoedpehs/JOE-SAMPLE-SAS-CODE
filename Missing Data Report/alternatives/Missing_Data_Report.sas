libname raw "Q:\Julio Chirinos\Knock_out_Summer_2016\data\Raw";
libname derived "Q:\Julio Chirinos\Knock_out_Summer_2016\data\Derived";
footnote "SAS Program Stored in: Q:\Julio Chirinos\Knock_out_Summer_2016\programs\Draft\Missing_Data_Report.sas";
options fmtsearch=(raw.ko_up_formats);
options nofmterr;
/***************************************
Description of task

***************************************/
/*BASIC SUMMARY STATS TO CHECK DATA QUALITY*/

/*CREATE MACRO VARIABLE FOR PROC MEANS AND PROC FREQ*/
data derived.ko_up;
set raw.ko_up;
drop ;
run; 

proc contents data=raw.ko_up varnum out=cont_out noprint; 
run;

proc contents data = cont_out varnum;
run;

proc print data = cont_out;
run;


/*IDENTIFY TYPE AND FORMAT VARS*/
/*proc contents */
/*    data=work.vartype */
/*    varnum;*/
/*run;*/
/*proc print data=work.vartype (obs=100);run;*/

/*NUM VARIABLES*/
proc sql noprint;   
    select name   
    into : numlist separated by ' '   
    from cont_out   
    where type = 1 and format in('BEST'); 
/*	char type=2*/
/*	num  type=1*/
/*	BEST IS THE DEFAULT NUM FORMAT, USUALLY IS NUMERIC*/
quit; 
/*QA SEE LOG COMPARE AGAINST CONTENTS*/
%put &numlist;
proc contents data=raw.ko_up varnum;
run;


/*NUM VARIABLES WITH CHAR FORMATS*/
/*CATEGORY VARIABLES DISGUISED AS NUM*/
proc sql noprint;   
    select name   
    into : charlist1   
    separated by ' '   
    from cont_out   
    where type = 1 and
    format not in ('BEST')
    ; 
/*	char type=2*/
/*	num  type=1*/
/*	BEST IS THE DEFAULT NUM FORMAT, USUALLY IS NUMERIC*/
quit; 
/*QA SEE LOG COMPARE AGAINST CONTENTS*/
%put &charlist1;

/*CHAR VARIABLES*/
proc sql noprint;   
    select name   
    into : charlist2   
    separated by ' '   
    from cont_out   
    where type = 2
    ;
/*	char type=2*/
/*	num  type=1*/
/*	BEST IS THE DEFAULT NUM FORMAT, USUALLY IS NUMERIC*/
quit; 
/*QA SEE LOG COMPARE AGAINST CONTENTS*/
%put &charlist2;

proc means data= raw.ko_up  maxdec=2 n nmiss min max mean std;
    var 
    &numlist
    ;
run;

proc freq data= raw.ko_up;
    tables 
    &charlist1 
    &charlist2
    ;
run;



/*All Missing Data*/

data derived.ko_up;
    set raw.ko_up;

/*DROP VARIABLES FROM WHERE STATEMENT*/
    drop complete_pe heart_2;
run; 

proc contents data=derived.ko_up varnum out=cont_out2 noprint; 
run;

proc sql noprint;   
    select name   
    into : numiss   
    separated by '= . or '
    from cont_out2   
    where type = 1 
/*   and format in ('BEST')*/
    ; 
/*	char type=2*/
/*	num  type=1*/
/*	BEST IS THE DEFAULT NUM FORMAT, USUALLY IS NUMERIC*/
quit; 
%put &numiss;

/*CHAR VARIABLES*/
proc sql noprint;   
    select name   
    into : charmiss   
    separated by '= "" or '   
    from cont_out2   
    where type = 2
    ;
/*	char type=2*/
/*	num  type=1*/
/*	BEST IS THE DEFAULT NUM FORMAT, USUALLY IS NUMERIC*/
quit; 
/*QA SEE LOG COMPARE AGAINST CONTENTS*/
%put &charmiss;


/*DATASET FOR ALL MISSING DATA*/
data derived.knockout_upenn;
set raw.ko_up ;
	  where &numiss = . or &charmiss ="";
/*y = vlabelx(height_2);*/
/*title "y";*/
run;



/*Physical Exam */
%MACRO FORMISS(FORMVARS,TITLE);
title "";
proc print data= derived.knockout_upenn;
title "&TITLE";
var study_id redcap_event_name &FORMVARS;
run;
%MEND;


%FORMISS(height_2 -- complete_pe,Physical Exam);

/*QA*/
/*title "";*/
/*proc print data= derived.knockout_upenn;*/
/*title "Physical Exam";*/
/*var study_id redcap_event_name height_2 -- complete_pe;*/
/*run;*/

/*where phys_date;*/
