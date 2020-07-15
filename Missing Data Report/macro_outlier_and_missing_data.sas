/*To Use this macro include the following %include statement in your program*/
/*%include "Q:\Julio Chirinos\Knock_out_Summer_2016\programs\Draft\Outlier and Missing Data Report Macros.sas";*/
/*%summary(mergedsn,formvars,dsn);*/

/*example*/
/*%summary(derived.trt_ko_up, side_efft_asst_yn -- phys_date_se,Side_Effect_Assessment_Form);*/


/****************************************************************************************/
/*This code is designed to identify outliers for our*/
/*continuous variables*/
/*This may be the Final Code for outliers |Double loop macro*/
%macro outliers(x1)/parmbuff;
*For case | control;
 %let stop=%sysfunc(countw(&syspbuff));
 %put &stop;
 %do i=1 %to 1;  *This is defined by the number of outcome variables of interest  outcome is mmse;
    %let fname=%scan(&syspbuff,&i);
    *ods listing close;
	  %do j=2 %to &stop;  *change this number based on the number of potential categorical confounders;
		%let ccname=%scan(&syspbuff,&j);
		%put &ccname; 
		data ko_up_&ccname;
			set &fname(keep=study_id redcap_event_name &ccname);
		run;
			
		proc means data=ko_up_&ccname noprint;
	 		var &ccname;
	 		output out=&ccname._mean_stddev mean=m_&ccname stddev=sd_&ccname;
	 	run;

	 *create column to merge on;
	data ko_up3;
	 	set ko_up_&ccname;
		mvar = 1;
	run;
	data &ccname._mean_stddev;
		set &ccname._mean_stddev;
		mvar = 1;
	run;
	data outliers_&ccname;
		merge ko_up3 &ccname._mean_stddev;
		by mvar;
	run;

	data outliers_&ccname;
		set outliers_&ccname;
		/*Set (sd)*sd_&ccname to desired number of standard deviations from mean as the cutoff*/
		if . < &ccname < m_&ccname - 3*sd_&ccname or &ccname > m_&ccname + 3*sd_&ccname then &ccname._out = 1;
/*		if . < &ccname < m_&ccname - 1*sd_&ccname or &ccname > m_&ccname + 1*sd_&ccname then &ccname._out = 1;*/
		else &ccname._out = 0;
		mean_&ccname = round(m_&ccname, 0.01);
		stddev_&ccname = round(sd_&ccname, 0.01);
	run;
	

	proc print data=outliers_&ccname;
		title "Outliers from variable: &ccname. (2 standard deviations from the mean)";
		where &ccname._out=1;
		var study_id redcap_event_name &ccname mean_&ccname stddev_&ccname;
	run;

		data a;
			set a outliers_&ccname(where=(&ccname._out=1) keep= &ccname._out study_id redcap_event_name &ccname);
			drop &ccname._out;
			if study_id ne " ";
			***if pctc > 0;
		run; 
	
	 %end;
  %end;
 %mend outliers;

 /*proc contents data= ko_up;run;*/
/*Must create datasets ko_up and a*/
/*data ko_up;*/
/*	set derived.all_sites;*/
/*run;*/
/*data a; run;*/
/*This is where the macro is being called| looks for values that are 2 standard 
deviations from the mean*/
/*%outliers(*/
/* put outcomes here */
/** REPLACE SF12MCS WITH SUM VARIABLE**/
/*ko_up,*/
/*put numeric variables here - for randomized participants */
/*&numlist*/
/*); */

 
%MACRO summary(mergedsn,formvars,dsn);
/*Cognitive Testing*/
title"";
data temp;
    set &mergedsn;
    keep &FORMVARS;
run;

/*BASIC SUMMARY STATS TO CHECK DATA QUALITY*/
/*CREATE MACRO VARIABLE FOR PROC MEANS AND PROC FREQ*/
/*Assumes the data has been cleaned*/
proc contents data=temp varnum out=cont_out noprint;run;
/*LOOK FOR FIELDS TO EXPLOIT IN cont_out*/
/*proc contents data = cont_out varnum;run;*/
/*proc print data = cont_out;run;*/
/*NUM VARIABLES*/
proc sql noprint;   
    select name   
    into : measures   
    separated by ' '   
    from cont_out   
    where type = 1 and
    format in ('BEST'); 
/*	char type=2*/
/*	num  type=1*/
/*	ANY VARIATION OF BEST IS THE DEFAULT NUM FORMAT*/
quit; 
/*VIEW VARIABLES IN &numlist*/
%put &measures;
/*QA SEE LOG COMPARE AGAINST CONTENTS*/
/*proc contents data=derived.trt_ko_up varnum;run;*/

/*NUM VARIABLES WITH CHAR FORMATS*/
/*CATEGORY VARIABLES DISGUISED AS NUM*/
proc sql noprint;   
    select name   
    into : counts   
    separated by ' '   
    from cont_out   
    where type = 1 and
    format not in ('BEST'); 
/*	char type=2*/
/*	num  type=1*/
/*	BEST IS THE DEFAULT NUM FORMAT, USUALLY IS NUMERIC*/
quit; 
/*QA SEE LOG COMPARE AGAINST CONTENTS*/
%put &counts;

/*Unvalidated text field VARIABLES*/
proc sql noprint;   
    select name   
    into : unvalidated   
    separated by ' '   
    from cont_out   
    where type = 2 and name in("caregiver_id","redcap_event_name","record_id");
/*	char type=2*/
/*	num  type=1*/
/*	BEST IS THE DEFAULT NUM FORMAT, USUALLY IS NUMERIC*/
quit; 
/*QA SEE LOG COMPARE AGAINST CONTENTS*/
%put &unvalidated;
proc sql noprint;   
    select name   
    into : subset   
    separated by '= . or '
    from cont_out  
    where type = 1 
/*   and format in ('BEST')*/
    ; 
/*	char type=2*/
/*	num  type=1*/
/*	BEST IS THE DEFAULT NUM FORMAT, USUALLY IS NUMERIC*/
quit; 
%put &subset;

proc sql noprint;   
    select name   
    into : missing   
    separated by ' = . and '
    from cont_out  
    where type = 1 
/*   and format in ('BEST')*/
    ; 
/*	char type=2*/
/*	num  type=1*/
/*	BEST IS THE DEFAULT NUM FORMAT, USUALLY IS NUMERIC*/
quit; 
%put &missing;

proc sql noprint;   
    select name   
    into : reportVars   
    separated by ' '   
    from cont_out   
    where type = 1; 
/*	char type=2*/
/*	num  type=1*/
/*	BEST IS THE DEFAULT NUM FORMAT, USUALLY IS NUMERIC*/
quit; 
/*QA SEE LOG COMPARE AGAINST CONTENTS*/
%put &reportVars;

/*create summary stats*/
data &dsn;
    set &mergedsn;
	keep &unvalidated &reportVars;
	if &subset=.;
	if &missing=. then delete;

run;

/****OUTPUT****/

/*QA Outliers*/
/*proc sort data= &dsn; by redcap_event_name;run;*/
/*proc means data= &dsn  maxdec=2 n nmiss min max mean std;*/
/*    by redcap_event_name;*/
/*    var &measures;*/
/*    title"&dsn Means";*/
/*run;*/

/*proc freq data= &dsn;*/
/*    tables &counts;*/
/*    title"&dsn" FREQ;*/
/*run;*/

/*Print Report*/
proc sort data= &dsn;by caregiver_id redcap_event_name;run;
proc print data= &dsn label;
title"&dsn Missing";
run;

/*GENERATE OUTLIER USING TEMP DATASETS ABOVE*/
/*%outliers(ko_up , &measures); */

%MEND;
/*macro call*/
/*%outliers(ko_up , &measures); */
