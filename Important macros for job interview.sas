/*
 
 
From: Rex Ahima [mailto:ahima@mail.med.upenn.edu] 
Sent: Tuesday, March 10, 2015 9:14 AM
To: Vetter, Marion; Rex Ahima; Thomas Wadden
Cc: Scott Ritter; Chittams, Jesse
Subject: Re: Fwd: shell table
 
Hi Marion,

(1) The summary table should show comparisons of actual as well as relative values. To calculate the "% baseline" in the summary table,  divide the "6 month value" by the "baseline value" for the control and surgery groups respectively and multiply the ratio by 100
(2) I prefer "% fasting value" for comparing the relative responses for glucose and various hormones to meal testing. Divide the 15, 30, 60 min etc values within each group by time 0 and multiply by 100. This should be done for the "baseline" and "6 month" data for control and surgery groups. The time 0 value should be 100%

On 3/10/15 6:09 AM, Vetter, 

Marion wrote:
HI Rex-
 
Thanks for weighing in- can you give us some guidance on how % change is calculated?  I haven’t used this methodology before.  I reviewed some papers where the % change from baseline was calculated at each time point during an OGTT or MMTT and then compared by repeated measures ANOVA.  So I can see how you may compare the insulin response to a meal at say, 15 min or 30 min, but I’m not sure how you compare the change over the entire sampling period.   
 
(Jesse, the mean change at each time point would be calculated in a similar manner to the AUC.  For example, the mean % change in insulin at 15 minutes would be calculated as follows:  [insulin value at 15 min – average of the two fasting insulin values]/average of two fasting insulin values x 100.)  Rex, please confirm that this is correct.
 
Also, if we are calculating the % change at each time point, would we need to plot those values instead of the absolute values at each time point? 
 
Thanks,
Marion*/

libname raw 'U:\Lucy Faulconbridge\NEWS_study_2014\data\Raw';
libname derived 'U:\Lucy Faulconbridge\NEWS_study_2014\data\Derived';
options nofmterr; 
footnote 'SAS program stored: U:\Lucy Faulconbridge\NEWS_study_2014\programs\Draft\auc_jc.sas';
*********************************************************************************************************************************;
proc format;
	value colmn 1 = 'time 0-10'/*time is in minutes (x-axis), use to find the area of a trapezoid*/
		        2 = 'time 22'
				3 = 'time 32'
				4 = 'time 47'
		        5 = 'time 64'
				6 = 'time 90'
				7 = 'time 120'
		        8 = 'time 150'
				9 = 'time 180';
run;






/*run this proc print and proc contents to see what your data looks like*/
proc print data=raw.iAuc (obs=20);
	*var enrollment_id event_name gluc: ;
run;

proc contents data=raw.tauc varnum; run; /*varnum will list the variables in the order that they were brought in from the original dataset*/


ods pdf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\output\New TotalAUC Means &sysdate..pdf"style=journal;
proc means data=raw.tauc;
title ' ';
run;
ods pdf close;

ods pdf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\output\New IncrementalAUC Means &sysdate..pdf"style=journal;
proc means data=raw.iauc;
title ' ';
run;
ods pdf close;
*******;

/*this macro is creating the area under the curve for the glucose variable using the trapezoid rule*/
/*the y-axis is glucose, the x-axis is time*/

data auc;
	set raw.tauc;
	array Glu(*) Glucose_1_2_Avg Glucose_3 Glucose_4 Glucose_5 Glucose_6 Glucose_7 Glucose_8 Glucose_9 Glucose_10 Glucose_11 ;
	/*time1-9 are variables that are created based on intervals that the investigator gave us, they are the time
	gaps for the proc formats that were created above*/
	time1 = 10; time2 = 12; time3 = 10; time4 = 15; time5 = 17; time6 = 26; time7 = 30; time8 = 30; time9 = 30; 
	array tt(*) time1-time9;
	glu_tauc = 0;
	do i = 1 to 9;
		glu(i) = round(glu(i),0.1); glu(i+1) = round(glu(i+1),0.1);
		glu_tauc = glu_tauc +  tt(i)*((glu(i) + glu(i+1))/2);

		*glu_tauc =   ((glu(i) + glu(i+1))/2);
	end;
run;

/*QA*/
/* var: will print all of the variables that start with "var"*/
proc print data=auc (obs=20);
	var enrollment_id event_name gluc: glu_tauc;
run;


/* This works for several variables: TOTAL AUC, this is doing the exact same thing that the macro on line 75 is doing*/
%macro tauc(x);
	array &x(*) &x._1_2_Avg &x._3 &x._4 &x._5 &x._6 &x._7 &x._8 &x._9 &x._10 &x._11 ;	
	&x._tauc = 0;
	do i = 1 to 9;
		&x(i) = round(&x(i),0.1); &x(i+1) = round(&x(i+1),0.1);
		&x._tauc = &x._tauc +  tt(i)*((&x(i) + &x(i+1))/2);
	end;
%mend;
data auc2;
	set RAW.newdata2;/********* needs to be replaced with dataset that was brought in at the bottom of the program*/
	time1 = 10; time2 = 12; time3 = 10; time4 = 15; time5 = 17; time6 = 26; time7 = 30; time8 = 30; time9 = 30; 
	array tt(*) time1-time9;
   %tauc(glucose); %tauc(Leptin);%tauc(GLP_1_Active);%tauc(Insulin);%tauc(Active_Ghrelin);%tauc(Specific_PYY);
run;
/*QA 18 MO*/
%LOOK(auc2);
/*QA*/
proc print data=auc2 (obs=25);
	var enrollment_id event_name  glucose_tauc leptin_tauc glp_1_active_tauc insulin_tauc active_ghrelin_tauc specific_pyy_tauc;
run;

data derived.tauc;
	set auc2;
run;
/*QA 18 MO*/
%LOOK(derived.tauc);
*Repeat the same macro for IAUC (incremental AUC);
%macro iauc(x);
	&x._1_bl = 0;
	array &x(*) &x._1_bl &x._3_Delta &x._4_Delta &x._5_Delta &x._6_Delta &x._7_Delta &x._8_Delta &x._9_Delta &x._10_Delta &x._11_Delta ;	
	&x._iauc = 0;
	do i = 1 to 9;
		&x(i) = round(&x(i),0.1); &x(i+1) = round(&x(i+1),0.1);
		&x._iauc = &x._iauc +  tt(i)*((&x(i) + &x(i+1))/2);
	end;
%mend;
data auc2;
	set RAW.newdata2;/*I CHANGED THIS FROM raw.iauc TO  RAW.newdata2*/
	time1 = 10; time2 = 12; time3 = 10; time4 = 15; time5 = 17; time6 = 26; time7 = 30; time8 = 30; time9 = 30; 
	array tt(*) time1-time9;
   %iauc(glucose); %iauc(Leptin);%iauc(GLP_1_Active);%iauc(Insulin);%iauc(Active_Ghrelin);%iauc(Specific_PYY) ;
run;

proc print data=auc2 (obs=25);
	var enrollment_id event_name  glucose_iauc leptin_iauc glp_1_active_iauc insulin_iauc active_ghrelin_iauc specific_pyy_iauc;
run;
*checking validity with excel sheet;
proc print data=auc2 ;
where enrollment_id = 1002;
	var enrollment_id event_name  glucose_iauc ;
run;

data derived.iauc;
	set auc2;
run;

**********************************************************************************************************************************
Hi Jesse-

That is terrific!  I think the more mathematically precise method is preferable.  Was this code for both the total AUCs and the 
incremental AUCs?  Did both match up?
I will review the spreadsheet by the weekend to see if anything sticks out.  Great pick-up, Scott!

Best,
Marion
********************************************************************************************************************************;
/*macro creating new column/variable for tauc variables 4/27/15*/
%macro tauc(x);
	&x._1_bl = 0;
	array &x(*) &x._1_2_Avg &x._3 &x._4 &x._5 &x._6 &x._7 &x._8 &x._9 &x._10 &x._11 ;	
	&x._tauc = 0;
	&x._tmaxV = 0;
	do i = 1 to 9;
		*&x(i) = round(&x(i),0.1); *&x(i+1) = round(&x(i+1),0.1);
		&x._tauc = &x._tauc +  tt(i)*((&x(i) + &x(i+1))/2);
		&x._tmaxV = max(&x._tmaxV,&x(i));
		if &x._tmaxV = &x(i) then &x._tmaxL = i;
	format &x._tmaxL colmn.;
	end;
if &x._tmaxV =0 then &x._tmaxV = .;
%mend;
data derived.tauc2;
	set raw.tauc;
	time1 = 10; time2 = 12; time3 = 10; time4 = 15; time5 = 17; time6 = 26; time7 = 30; time8 = 30; time9 = 30; 
	array tt(*) time1-time9;
   %tauc(glucose); %tauc(Leptin);%tauc(GLP_1_Active);%tauc(Insulin);%tauc(Active_Ghrelin);%tauc(Specific_PYY);
run;

proc contents data=derived.tauc2;
run;

proc print data=auc2 (obs=25); /*SOME VARIABLES NOT FOUND?*/
	var enrollment_id event_name  glucose_tauc leptin_tauc glp_1_active_tauc insulin_tauc active_ghrelin_tauc specific_pyy_tauc;
run;

/*QA*/
ods rtf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\Reports\Max_TAUC_QA &sysdate..rtf"style=journal;

proc print data=DERIVED.Tauc2 (obs=25);
	var enrollment_id glucose_tmaxV  glucose_tmaxL;
	TITLE1 'QA for New Variable';
	TITLE2 'TAUC Glucose';
run;
ods rtf close;

data derived.tauc_precise;
	set auc2;
run;

/*macro creating new column/variable for iauc variables 4/27/15

%macro iauc(x);
	&x._1_bl = 0;
	array &x(*) &x._1_2_Avg &x._3_delta &x._4_delta  &x._5_delta  &x._6_delta  &x._7_delta  &x._8_delta  &x._9_delta  &x._10_delta  &x._11_delta  ;	
	&x._iauc = -99999;
	&x._imaxV = 0;
	do i = 1 to 9;
		*&x(i) = round(&x(i),0.1); *&x(i+1) = round(&x(i+1),0.1);
		&x._iauc = &x._iauc +  tt(i)*((&x(i) + &x(i+1))/2);
		&x._imaxV = max(&x._imaxV,&x(i));
		if &x._imaxV = &x(i) then &x._imaxL = i;
	format &x._imaxL colmn.;
	end;
if &x._imaxV =0 then &x._imaxV = .;
%mend;*/



/*archived code*/

%macro iauc(x);
	&x._1_bl = 0;
	array &x(*) &x._1_bl &x._3_Delta &x._4_Delta &x._5_Delta &x._6_Delta &x._7_Delta &x._8_Delta &x._9_Delta &x._10_Delta &x._11_Delta ;	
	&x._iauc = 0;
	&x._imaxV = -99999;
	&x._imaxL = 0;
	do i = 1 to 9;
		*&x(i) = round(&x(i),0.1); *&x(i+1) = round(&x(i+1),0.1);
		&x._iauc = &x._iauc +  tt(i)*((&x(i) + &x(i+1))/2);
		&x._imaxV = max(&x._imaxV,&x(i)); 
		if &x._imaxV = &x(i) then &x._imaxL = i;
	format &x._imaxL colmn.;
	end;
	if &x._imaxV =0 then &x._imaxV = .;
	if &x._imaxV = . then &x._imaxL = .; 
%mend;



 proc contents data=raw.iauc;
 run;

data derived.iauc2;
	set raw.iauc;
	time1 = 10; time2 = 12; time3 = 10; time4 = 15; time5 = 17; time6 = 26; time7 = 30; time8 = 30; time9 = 30; 
	array tt(*) time1-time9;
   %iauc(glucose); %iauc(Leptin);%iauc(GLP_1_Active);%iauc(Insulin);%iauc(Active_Ghrelin);%iauc(Specific_PYY) ;
run;

/*QA*/
ods rtf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\Reports\Max_IAUC_QA &sysdate..rtf"style=journal;

proc print data=DERIVED.iauc2 (obs=50);
	var enrollment_id glucose_imaxV glucose_imaxL ;
	TITLE1 'QA for New Variable';
	TITLE2 'IAUC Glucose';
run;
ods rtf close;

proc print data=auc2 (obs=25);
	var enrollment_id event_name  glucose_iauc leptin_iauc glp_1_active_iauc insulin_iauc active_ghrelin_iauc specific_pyy_iauc;
run;
/*MO 2018 IS MISSING, I MISSED A SET STATEMENT*/
%LOOK(auc2);
/*QA 4/14/15*/

proc contents data=derived.iauc2;
run;

/*proc print data=auc2;
	var enrollment_id event_name  glucose_maxV leptin_maxV glp_1_active_maxV insulin_maxV active_ghrelin_maxV specific_pyy_maxV;
run;*/


data derived.iauc_precise;
	set auc2;
run;

*exporting the AUC datasets into excel;
data tauc_precise;
	set derived.tauc_precise;
	keep enrollment_id event_name glucose_tauc leptin_tauc glp_1_active_tauc insulin_tauc active_ghrelin_tauc specific_pyy_tauc ;
run;

proc print data=tauc_precise (obs=25); run;

data iauc_precise;
	set derived.iauc_precise;
	keep enrollment_id event_name  glucose_iauc leptin_iauc glp_1_active_iauc insulin_iauc active_ghrelin_iauc specific_pyy_iauc;
run;

proc print data=iauc_precise (obs=25); run;

/*******create variable for the % baseline in the summary table 3/24/15********/

/*CHANGING EVENT_NAME TO A NUMERIC VARIABLE*/
data iauc_precise;
	set derived.iauc_precise;
	if event_name = "6 Month" then month = 6;
	if event_name = "Baseline" then month = 0;
	if event_name="18 Month" then month=18; /*use newdataset that was brought in at the bottom of the program*/
	keep arm enrollment_id event_name  glucose_iauc leptin_iauc glp_1_active_iauc insulin_iauc active_ghrelin_iauc specific_pyy_iauc month;
run;

proc contents data=derived.iauc_precise;
run;

proc freq data=iauc_precise;
	tables arm;
run;

proc sort data=iauc_precise;
	by enrollment_id month;
run;

/*DATASTEP CREATING THE % CHANGE FROM BASELINE AND ABSOLUTE CHANGE FOR IAUC VARIABLES 4/13/15*/

data iauc;
	set iauc_precise;
	by enrollment_id month;
	retain bl_glucose_iauc bl_leptin_iauc bl_glp_1_active_iauc bl_insulin_iauc bl_active_ghrelin_iauc bl_specific_pyy_iauc;
	if first.enrollment_id and month=0 then bl_glucose_iauc = glucose_iauc;
	pcchbl_gluc_iauc=100*(glucose_iauc-bl_glucose_iauc)/bl_glucose_iauc;
	abchbl_gluc_iauc=glucose_iauc-bl_glucose_iauc;
	if first.enrollment_id and month=0 then bl_leptin_iauc = leptin_iauc;
	pcchbl_leptin_iauc=100*(leptin_iauc-bl_leptin_iauc)/bl_leptin_iauc;
	abchbl_leptin_iauc=leptin_iauc-bl_leptin_iauc;
	if first.enrollment_id and month=0 then bl_glp_1_active_iauc =glp_1_active_iauc;
	pcchbl_glp_1_iauc=100*(glp_1_active_iauc-bl_glp_1_active_iauc)/bl_glp_1_active_iauc;
	abchbl_glp_1_iauc=glp_1_active_iauc-bl_glp_1_active_iauc;
	if first.enrollment_id and month=0 then bl_insulin_iauc =insulin_iauc;
	pcchbl_insulin_iauc=100*(insulin_iauc-bl_insulin_iauc)/bl_insulin_iauc;
	abchbl_insulin_iauc=insulin_iauc-bl_insulin_iauc;
	if first.enrollment_id and month=0 then bl_active_ghrelin_iauc =active_ghrelin_iauc;
	pcchbl_active_ghrelin_iauc=100*(active_ghrelin_iauc-bl_active_ghrelin_iauc)/bl_active_ghrelin_iauc;
	abchbl_active_ghrelin_iauc=active_ghrelin_iauc-bl_active_ghrelin_iauc;
	if first.enrollment_id and month=0 then bl_specific_pyy_iauc =specific_pyy_iauc;
	pcchbl_specific_pyy_iauc=100*(specific_pyy_iauc-bl_specific_pyy_iauc)/bl_specific_pyy_iauc;
	abchbl_specific_pyy_iauc=specific_pyy_iauc-bl_specific_pyy_iauc;
run;


proc freq data=iauc_precise;
	tables event_name*month /list missing;
run;


/*DO A QA ON ALL OF THE VARIABLES THAT CREATED IN THE ABOVE DATASTEP TO MAKE SURE THAT
THEY WERE CREATED CORRECTLY*/


ods rtf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\Reports\QA_Percent_Baseline_AND_Abs_Change_IAUC_Variables_&sysdate..rtf" style=journal;

/*QA pcchbl_gluc_iauc and abchbl_gluc_iauc*/

proc print data=iauc (obs=25);
	var enrollment_id month pcchbl_gluc_iauc glucose_iauc bl_glucose_iauc abchbl_gluc_iauc;
	TITLE 'QA % CHANGE FROM BASELINE AND ABSOLUTE CHANGE FOR INCREMENTAL GLUCOSE';
run;

/*QA pcchbl_leptin_iauc and abchbl_leptin_iauc*/

proc print data=iauc (obs=25);
	var enrollment_id month pcchbl_leptin_iauc leptin_iauc bl_leptin_iauc abchbl_leptin_iauc;
	TITLE 'QA % CHANGE FROM BASELINE AND ABSOLUTE CHANGE FOR INCREMENTAL LEPTIN';
run;

/*QA pcchbl_glp_1_iauc and abchbl_glp_1_iauc*/

proc print data=iauc (obs=25);
	var enrollment_id month pcchbl_glp_1_iauc glp_1_active_iauc bl_glp_1_active_iauc abchbl_glp_1_iauc;
	TITLE 'QA % CHANGE FROM BASELINE AND ABSOLUTE CHANGE FOR INCREMENTAL GLP_1_';
run;

/*QA pcchbl_insulin_iaucc and abchbl_insulin_iauc*/

proc print data=iauc (obs=25);
	var enrollment_id month pcchbl_insulin_iauc insulin_iauc bl_insulin_iauc abchbl_insulin_iauc;
	TITLE 'QA % CHANGE FROM BASELINE AND ABSOLUTE CHANGE FOR INCREMENTAL INSULIN';
run;

/*QA pcchbl_active_ghrelin_iauc and abchbl_active_ghrelin_iauc*/

proc print data=iauc (obs=25);
	var enrollment_id month pcchbl_active_ghrelin_iauc active_ghrelin_iauc bl_active_ghrelin_iauc abchbl_active_ghrelin_iauc;
	TITLE 'QA % CHANGE FROM BASELINE AND ABSOLUTE CHANGE FOR FOR INCREMENTAL GHRELIN';
run;

/*QA pcchbl_specific_pyy_iauc and abchbl_specific_pyy_iauc*/

proc print data=iauc (obs=25);
	var enrollment_id month 	pcchbl_specific_pyy_iauc specific_pyy_iauc bl_specific_pyy_iauc abchbl_specific_pyy_iauc;
	TITLE 'QA % CHANGE FROM BASELINE AND ABSOLUTE CHANGE FOR FOR INCREMENTAL SPECIFIC_PYY';
run;

ods rtf close;


/**********************************************************************************/
/***************PROC UNIVARIATE AND PROC MEAN FOR IAUC VARIABLES*******************/
/**********************************************************************************/


/*PCCHBL*/

/*Univariate Analysis: PCCHBL variables*/

ods rtf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\Reports\Univariate_Analysis_Output_IAUC_Variables_&sysdate..rtf" style=journal;
ods trace on /listing;
proc univariate data=iauc normal plot;
	where month=6;
	id enrollment_id arm;
	var pcchbl_gluc_iauc pcchbl_leptin_iauc pcchbl_glp_1_iauc pcchbl_insulin_iauc pcchbl_active_ghrelin_iauc pcchbl_specific_pyy_iauc;
	TITLE1 'UNIVARIATE ANALYSIS ON PERCENT CHANGE FROM BASELINE ';
	TITLE2 'IAUC VARIABLES';
run;
ods trace off;
ods rtf close;

/*Univariate Analysis: Extreme Obs for PCCHBL variables*/

/*4/27/2015*/
%macro extreme (x,bl,z,titl, WHERE);
proc univariate data=iauc normal plot;
	ods select extremeobs;
	&WHERE;
/*	where month=6; macrolize the where statement*/
	id enrollment_id arm &x &bl;
	var &z;
	TITLE1 "&x &titl";
	TITLE2 'IAUC VARIABLES';
run;
%mend;

/*MACRO FOR EXTREME OBS FOR PCCHBL VARIABLES - IAUC FOR 6 MONTHS*/
ods rtf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\Reports\PCCHBL_Extreme_Obs_Output_IAUC_Variables_&sysdate..rtf" style=journal;
%extreme (glucose_iauc,bl_glucose_iauc, pcchbl_gluc_iauc,EXTREME OBS FOR PERCENT CHANGE FROM BASELINE TO MONTH 6, where month=6);
%extreme (leptin_iauc,bl_leptin_iauc, pcchbl_leptin_iauc, EXTREME OBS FOR PERCENT CHANGE FROM BASELINE TO MONTH 6, where month=6);
%extreme (glp_1_active_iauc,bl_glp_1_active_iauc, pcchbl_glp_1_iauc, EXTREME OBS FOR PERCENT CHANGE FROM BASELINE TO MONTH 6, where month=6);
%extreme (insulin_iauc,bl_insulin_iauc, pcchbl_insulin_iauc, EXTREME OBS FOR PERCENT CHANGE FROM BASELINE TO MONTH 6, where month=6);
%extreme (active_ghrelin_iauc,bl_active_ghrelin_iauc, pcchbl_active_ghrelin_iauc, EXTREME OBS FOR PERCENT CHANGE FROM BASELINE TO MONTH 6, where month=6);
%extreme (specific_pyy_iauc,bl_specific_pyy_iauc, pcchbl_specific_pyy_iauc, EXTREME OBS FOR PERCENT CHANGE FROM BASELINE TO MONTH 6, where month=6);
ods rtf close;
/*FOR 18 MONTHS*/
ods rtf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\Reports\PCCHBL_Extreme_Obs_Output_IAUC_Variables 18 Months_&sysdate..rtf" style=journal;
%extreme (glucose_iauc,bl_glucose_iauc, pcchbl_gluc_iauc,EXTREME OBS FOR PERCENT CHANGE FROM BASELINE TO MONTH 18, where month=18 );
%extreme (leptin_iauc,bl_leptin_iauc, pcchbl_leptin_iauc, EXTREME OBS FOR PERCENT CHANGE FROM BASELINE TO MONTH 18, where month=18);
%extreme (glp_1_active_iauc,bl_glp_1_active_iauc, pcchbl_glp_1_iauc, EXTREME OBS FOR PERCENT CHANGE FROM BASELINE TO MONTH 18, where month=18);
%extreme (insulin_iauc,bl_insulin_iauc, pcchbl_insulin_iauc, EXTREME OBS FOR PERCENT CHANGE FROM BASELINE TO MONTH 18, where month=18);
%extreme (active_ghrelin_iauc,bl_active_ghrelin_iauc, pcchbl_active_ghrelin_iauc, EXTREME OBS FOR PERCENT CHANGE FROM BASELINE TO MONTH 18, where month=18);
%extreme (specific_pyy_iauc,bl_specific_pyy_iauc, pcchbl_specific_pyy_iauc, EXTREME OBS FOR PERCENT CHANGE FROM BASELINE TO MONTH 18, where month=18);
ods rtf close;


/*ABCHBL*/

/*Univariate Analysis: ABCHBL variables*/
ods rtf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\Reports\ABCHBL_Univariate_Analysis_Output_IAUC_Variables_&sysdate..rtf" style=journal;

ods trace on /listing;
proc univariate data=iauc normal plot;
	where month=6;
	id enrollment_id arm;
	var abchbl_gluc_iauc abchbl_leptin_iauc abchbl_glp_1_iauc abchbl_insulin_iauc abchbl_active_ghrelin_iauc abchbl_specific_pyy_iauc;
	TITLE1 'ANALYSIS ON IAUC VARIABLES';
TITLE2 'ANALYSIS ON IAUC VARIABLES';
run;
ods trace off;
ods rtf close;

/*Univariate Analysis: Extreme Obs on ABCHBL variables*/

/*4/27/15*/

/*MACRO FOR EXTREME OBS ABCHBL VARIABLES (LINE 376) - IAUC*/
ods rtf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\Reports\ABCHBL_Extreme_Obs_Univariate_Analysis_Output_IAUC_Variables_&sysdate..rtf" style=journal;
%extreme (glucose_iauc,bl_glucose_iauc, abchbl_gluc_iauc,EXTREME OBS FOR ABSOLUTE CHANGE FROM BASELINE TO MONTH 6 );
%extreme (glucose_iauc,bl_glucose_iauc, abchbl_gluc_iauc,EXTREME OBS FOR ABSOLUTE PERCENT CHANGE FROM BASELINE TO MONTH 6 );
%extreme (leptin_iauc,bl_leptin_iauc, abchbl_leptin_iauc, EXTREME OBS FOR ABSOLUTE PERCENT CHANGE FROM BASELINE TO MONTH 6);
%extreme (glp_1_active_iauc,bl_glp_1_active_iauc, abchbl_glp_1_iauc, EXTREME OBS FOR ABSOLUTE PERCENT CHANGE FROM BASELINE TO MONTH 6);
%extreme (insulin_iauc,bl_insulin_iauc, abchbl_insulin_iauc, EXTREME OBS FOR ABSOLUTE PERCENT CHANGE FROM BASELINE TO MONTH 6);
%extreme (active_ghrelin_iauc,bl_active_ghrelin_iauc, abchbl_active_ghrelin_iauc, EXTREME OBS FOR ABSOLUTE PERCENT CHANGE FROM BASELINE TO MONTH 6);
%extreme (specific_pyy_iauc,bl_specific_pyy_iauc, abchbl_specific_pyy_iauc, EXTREME OBS FOR ABSOLUTE PERCENT CHANGE FROM BASELINE TO MONTH 6);
ods rtf close;


/*ods rtf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\Reports\ABCHBL_Extreme_Obs_Univariate_Analysis_Output_IAUC_Variables_&sysdate..rtf" style=journal;

ods trace on /listing;
proc univariate data=iauc normal plot;
	ods select extremeobs;
	where month=6;
	id enrollment_id arm;
	var abchbl_gluc_iauc abchbl_leptin_iauc abchbl_glp_1_iauc abchbl_insulin_iauc abchbl_active_ghrelin_iauc abchbl_specific_pyy_iauc;
	TITLE1 'ANALYSIS ON IAUC VARIABLES';
TITLE2 'ANALYSIS ON IAUC VARIABLES';
run;
ods trace off;
ods rtf close;

ods rtf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\Reports\Means_IAUC_Variables_&sysdate..rtf" style=journal;
*/

/*PROC MEANS ON IAUC VARIABLES*/

PROC MEANS DATA=IAUC maxdec=2 mean std;
	where month=6;
	CLASS arm;
	var bl_glucose_iauc glucose_iauc  pcchbl_gluc_iauc 
		bl_leptin_iauc leptin_iauc pcchbl_leptin_iauc
		bl_glp_1_active_iauc glp_1_active_iauc pcchbl_glp_1_iauc
		bl_insulin_iauc insulin_iauc pcchbl_insulin_iauc
		bl_active_ghrelin_iauc active_ghrelin_iauc pcchbl_active_ghrelin_iauc
		bl_specific_pyy_iauc specific_pyy_iauc pcchbl_specific_pyy_iauc;
		TITLE 'Means for IAUC Variables';
run;
ods rtf close;

/*MEETING 3/27/15 PRINT ALL OF THE ID'S FROM THE IAUC DATA THAT HAVE NEGATIVE VALUES EXCEPT FOR GREHLIN*/

ods rtf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\Reports\QA_NEGATIVE_RESULTS_IAUC_&sysdate..rtf" style=journal;

proc print data=iauc_precise NOOBS;
	*where glucose_iauc < 0 and glucose_iauc NE .;
	where . < glucose_iauc < 0;
	*where glucose_iauc in (2,3,100);
	var enrollment_id month arm glucose_iauc;
	TITLE 'QA FOR NEGATIVE VALUES: GLUCOSE';
run;

proc print data=iauc_precise NOOBS;
	where . < leptin_iauc < 0;
	var enrollment_id month arm leptin_iauc;
	TITLE 'QA FOR NEGATIVE VALUES: LEPTIN';
run;

proc print data=iauc_precise NOOBS;
	where . < glp_1_active_iauc < 0;
	var enrollment_id month arm glp_1_active_iauc;
	TITLE 'QA FOR NEGATIVE VALUES: GLP';
run;

proc print data=iauc_precise NOOBS;
	where . < insulin_iauc < 0;
	var enrollment_id month arm insulin_iauc;
run; /*NO OBSERVATIONS WERE NEGATIVE*/

proc print data=iauc_precise NOOBS;
	where . < specific_pyy_iauc < 0;
	var enrollment_id month arm specific_pyy_iauc;
	TITLE 'QA FOR NEGATIVE VALUES: PYY';
run;
ods rtf close;

/*********************************************************************************/

/*DATASTEP CREATING THE % CHANGE FROM BASELINE AND THE ABSOLUTE CHANGE FOR TAUC VARIABLES, COMPLETE 4/14/15*/

/*COPIED FROM LINE 186*/

data tauc_precise;
	set derived.tauc_precise;
	keep enrollment_id event_name glucose_tauc leptin_tauc glp_1_active_tauc insulin_tauc active_ghrelin_tauc specific_pyy_tauc ;
run;

data tauc_precise;
	set derived.tauc_precise;
	if event_name = "6 Month" then month = 6;
	if event_name = "Baseline" then month = 0;	
	if event_name = "18 Month" then month = 18; /*JOE ADDED THIS*/
	keep arm enrollment_id event_name glucose_tauc leptin_tauc glp_1_active_tauc insulin_tauc active_ghrelin_tauc specific_pyy_tauc month;
run;

proc sort data=tauc_precise;
	by enrollment_id month;
run;

data tauc;
	set tauc_precise;
	by enrollment_id month;
	retain bl_glucose_tauc bl_leptin_tauc bl_glp_1_active_tauc bl_insulin_tauc bl_active_ghrelin_tauc bl_specific_pyy_tauc;
	if first.enrollment_id and month=0 then bl_glucose_tauc = glucose_tauc;
	pcchbl_glucose_tauc=100*(glucose_tauc-bl_glucose_tauc)/bl_glucose_tauc;
	abchbl_glucose_tauc=glucose_tauc-bl_glucose_tauc;
	if first.enrollment_id and month=0 then bl_leptin_tauc = leptin_tauc;
	pcchbl_leptin_tauc=100*(leptin_tauc-bl_leptin_tauc)/bl_leptin_tauc;
	abchbl_leptin_tauc=leptin_tauc-bl_leptin_tauc;
	if first.enrollment_id and month=0 then bl_glp_1_active_tauc = glp_1_active_tauc;
	pcchbl_glp_1_active_tauc=100*(glp_1_active_tauc-bl_glp_1_active_tauc)/bl_glp_1_active_tauc;
	abchbl_glp_1_active_tauc=glp_1_active_tauc-bl_glp_1_active_tauc;
	if first.enrollment_id and month=0 then bl_insulin_tauc = insulin_tauc;
	pcchbl_insulin_tauc=100*(insulin_tauc-bl_insulin_tauc)/bl_insulin_tauc;
	abchbl_insulin_tauc=insulin_tauc-bl_insulin_tauc;
	if first.enrollment_id and month=0 then bl_active_ghrelin_tauc = active_ghrelin_tauc;
	pcchbl_active_ghrelin_tauc=100*(active_ghrelin_tauc-bl_active_ghrelin_tauc)/bl_active_ghrelin_tauc;
	abchbl_active_ghrelin_tauc=active_ghrelin_tauc-bl_active_ghrelin_tauc;
	if first.enrollment_id and month=0 then bl_specific_pyy_tauc = specific_pyy_tauc;
	pcchbl_specific_pyy_tauc=100*(specific_pyy_tauc-bl_specific_pyy_tauc)/bl_specific_pyy_tauc;
	abchbl_specific_pyy_tauc=specific_pyy_tauc-bl_specific_pyy_tauc;

run;

PROC CONTENTS DATA=TAUC_PRECISE;
RUN;

/*QA TO MAKE SURE THAT ALL OF THE VARIABLES WERE CREATED CORRECTLY*/

ods rtf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\Reports\QA_Percent_Baseline_AND_Abs_Change_TAUC_Variables_&sysdate..rtf" style=journal;
/*QA pcchbl_glucose_tauc and abchbl_glucose_tauc*/

proc print data=tauc (obs=25);
	var enrollment_id month pcchbl_glucose_tauc glucose_tauc bl_glucose_tauc abchbl_glucose_tauc;
	TITLE 'QA % CHANGE FROM BASELINE AND ABSOLUTE CHANGE FOR TOTAL LEPTIN';
run;

/*QA pcchbl_leptin_tauc and abchbl_leptin_tauc*/

proc print data=tauc (obs=25);
	var enrollment_id month pcchbl_leptin_tauc leptin_tauc bl_leptin_tauc abchbl_leptin_tauc;
	TITLE 'QA % CHANGE FROM BASELINE AND ABSOLUTE CHANGE FOR TOTAL LEPTIN';
run;

/*QA pcchbl_glp_1_active_tauc and abchbl_glp_1_active_tauc*/

proc print data=tauc (obs=25);
	var enrollment_id month pcchbl_glp_1_active_tauc glp_1_active_tauc bl_glp_1_active_tauc abchbl_glp_1_active_tauc;
	TITLE 'QA % CHANGE FROM BASELINE AND ABSOLUTE CHANGE FOR TOTAL GLP_1_';
run;

/*QA pcchbl_insulin_tauc and abchbl_insulin_tauc*/

proc print data=tauc (obs=25);
	var enrollment_id month pcchbl_insulin_tauc insulin_tauc bl_insulin_tauc abchbl_insulin_tauc;
	TITLE 'QA % CHANGE FROM BASELINE AND ABSOLUTE CHANGE FOR TOTAL INSULIN';
run;

/*QA pcchbl_active_ghrelin_tauc and abchbl_active_ghrelin_tauc*/

proc print data=tauc (obs=25);
	var enrollment_id month pcchbl_active_ghrelin_tauc active_ghrelin_tauc bl_active_ghrelin_tauc abchbl_active_ghrelin_tauc;
	TITLE 'QA % CHANGE FROM BASELINE AND ABSOLUTE CHANGE FOR TOTAL GHRELIN';
run;

/*QA pcchbl_specific_pyy_tauc and abchbl_specific_pyy_tauc*/

proc print data=tauc (obs=25);
	var enrollment_id month pcchbl_specific_pyy_tauc specific_pyy_tauc bl_specific_pyy_tauc abchbl_specific_pyy_tauc;
	TITLE 'QA % CHANGE FROM BASELINE AND ABSOLUTE CHANGE FOR TOTAL SPECIFIC PYY';
run;
ods rtf close;

/**********************************************************************************/
/***************PROC UNIVARIATE AND PROC MEAN FOR TAUC VARIABLES*******************/
/**********************************************************************************/

/*PCCHBL*/


/*Univariate Analysis: PCCHBL variables*/

ods rtf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\Reports\Univariate_Analysis_Output_TAUC_Variables_&sysdate..rtf" style=journal;
proc univariate data=tauc normal plot;
/*	where month=6;*/
	where month=18;
	id enrollment_id arm;
	var pcchbl_glucose_tauc pcchbl_leptin_tauc pcchbl_glp_1_active_tauc pcchbl_insulin_tauc pcchbl_active_ghrelin_tauc pcchbl_specific_pyy_tauc;
	TITLE1 'UNIVARIATE ANALYSIS ON PERCENT CHANGE FROM BASELINE ';
	TITLE2 'TAUC VARIABLES';
run;
ods rtf close;

/*4/27/2015*/
%macro extreme (x,bl,z,titl);
proc univariate data=tauc normal plot;
	ods select extremeobs;
	where month=6;
	id enrollment_id arm &x &bl;
	var &z;
	TITLE1 "&x &titl";
	TITLE2 'TAUC VARIABLES';
run;
%mend;


/*MACRO FOR EXTREME OBS FOR PCCHBL VARIABLES - TAUC*/
ods rtf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\Reports\PCCHBL_Extreme_Obs_Output_TAUC_Variables_&sysdate..rtf" style=journal;
%extreme (glucose_tauc,bl_glucose_tauc, pcchbl_glucose_tauc,EXTREME OBS FOR PERCENT CHANGE FROM BASELINE TO MONTH 6 );
%extreme (leptin_tauc,bl_leptin_tauc, pcchbl_leptin_tauc, EXTREME OBS FOR PERCENT CHANGE FROM BASELINE TO MONTH 6);
%extreme (glp_1_active_tauc,bl_glp_1_active_tauc, pcchbl_glp_1_active_tauc, EXTREME OBS FOR PERCENT CHANGE FROM BASELINE TO MONTH 6);
%extreme (insulin_tauc,bl_insulin_tauc, pcchbl_insulin_tauc, EXTREME OBS FOR PERCENT CHANGE FROM BASELINE TO MONTH 6);
%extreme (active_ghrelin_tauc,bl_active_ghrelin_tauc, pcchbl_active_ghrelin_tauc, EXTREME OBS FOR PERCENT CHANGE FROM BASELINE TO MONTH 6);
%extreme (specific_pyy_tauc,bl_specific_pyy_tauc, pcchbl_specific_pyy_tauc, EXTREME OBS FOR PERCENT CHANGE FROM BASELINE TO MONTH 6);
ods rtf close;



/*Univariate Analysis: Extreme Obs on PCCHBL variables*/

/*ods rtf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\Reports\Extreme_Obs_Output_TAUC_Variables_&sysdate..rtf" style=journal;
proc univariate data=tauc normal plot;
	ods select extremeobs;
	where month=6;
	id enrollment_id arm;
	var pcchbl_glucose_tauc pcchbl_leptin_tauc pcchbl_glp_1_active_tauc pcchbl_insulin_tauc pcchbl_active_ghrelin_tauc pcchbl_specific_pyy_tauc;
	TITLE1 'EXTREME OBS FOR PERCENT CHANGE FROM BASELINE';
	TITLE2 'TAUC VARIABLES';
run;
ods rtf close;*/

/*ABCHBL*/

/*Univariate Analysis: ABCHBL variables*/

ods rtf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\Reports\ABCHBL__Univariate_Analysis_Output_TAUC_Variables_&sysdate..rtf" style=journal;

proc univariate data=tauc normal plot;
	where month=6;
	id enrollment_id arm;
	var abchbl_glucose_tauc abchbl_leptin_tauc abchbl_glp_1_active_tauc abchbl_insulin_tauc abchbl_active_ghrelin_tauc abchbl_specific_pyy_tauc;
	TITLE1 'UNIVARIATE ANALYSIS ON PERCENT CHANGE FROM BASELINE ';
	TITLE2 'TAUC VARIABLES';
run;

ods rtf close;

/*MACRO FOR EXTREME OBS ABCHBL VARIABLES (LINE 628) - TAUC*/
ods rtf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\Reports\ABCHBL_Extreme_Obs_Univariate_Analysis_Output_TAUC_Variables_&sysdate..rtf" style=journal;
%extreme (glucose_tauc,bl_glucose_tauc, abchbl_glucose_tauc,EXTREME OBS FOR ABSOLUTE CHANGE FROM BASELINE TO MONTH 6 );
%extreme (leptin_tauc,bl_leptin_tauc, abchbl_leptin_tauc, EXTREME OBS FOR ABSOLUTE PERCENT CHANGE FROM BASELINE TO MONTH 6);
%extreme (glp_1_active_tauc,bl_glp_1_active_tauc, abchbl_glp_1_active_tauc, EXTREME OBS FOR ABSOLUTE PERCENT CHANGE FROM BASELINE TO MONTH 6);
%extreme (insulin_tauc,bl_insulin_tauc, abchbl_insulin_tauc, EXTREME OBS FOR ABSOLUTE PERCENT CHANGE FROM BASELINE TO MONTH 6);
%extreme (active_ghrelin_tauc,bl_active_ghrelin_tauc, abchbl_active_ghrelin_tauc, EXTREME OBS FOR ABSOLUTE PERCENT CHANGE FROM BASELINE TO MONTH 6);
%extreme (specific_pyy_tauc,bl_specific_pyy_tauc, abchbl_specific_pyy_tauc, EXTREME OBS FOR ABSOLUTE PERCENT CHANGE FROM BASELINE TO MONTH 6);
ods rtf close;

/*Univariate Analysis: Extreme Obs on ABCHBL  variables*/
/*
ods rtf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\Reports\ABCHBL_Extreme_Obs_Univariate_Analysis_Output_TAUC_Variables_&sysdate..rtf" style=journal;
proc univariate data=tauc normal plot;
	ods select extremeobs;
	where month=6;
	id enrollment_id arm;
	var abchbl_glucose_tauc abchbl_leptin_tauc abchbl_glp_1_active_tauc abchbl_insulin_tauc abchbl_active_ghrelin_tauc abchbl_specific_pyy_tauc;
	TITLE1 'EXTREME OBS FOR PERCENT CHANGE FROM BASELINE';
	TITLE2 'TAUC VARIABLES';
run;

ods rtf close;
/*

/*PROC MEANS ON TAUC VARIABLES*/

ods rtf file="U:\Lucy Faulconbridge\NEWS_study_2014\documents\Reports\Means_TAUC_Variables_&sysdate..rtf" style=journal;

PROC MEANS DATA=TAUC maxdec=2 mean std;
	where month=6;
	CLASS arm;
	var	bl_glucose_tauc glucose_tauc pcchbl_glucose_tauc
		bl_leptin_tauc leptin_tauc pcchbl_leptin_tauc
		bl_glp_1_active_tauc glp_1_active_tauc pcchbl_glp_1_active_tauc
		bl_insulin_tauc insulin_tauc pcchbl_insulin_tauc
		bl_active_ghrelin_tauc active_ghrelin_tauc pcchbl_active_ghrelin_tauc
		bl_specific_pyy_tauc specific_pyy_tauc pcchbl_specific_pyy_tauc;
		TITLE 'Means for TAUC Variables';
run;

ods rtf close;

/*****Bringing in new data 8/7/2015********/

PROC IMPORT OUT= RAW.NEWDATA 
            DATAFILE= "U:\Lucy Faulconbridge\NEWS_study_2014\data\Raw\Ne
uroimagingStudyNEW_DATA_LABELS_2015 CSV.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

/*QA ON EVENT_NAME FOR 18 MONTH (IT'S MISSING 18 MONTH DATA)*/
proc freq data= RAW.NEWDATA ;
	tables event_name;
	run;

/*IMPORTING TAUC AND IAUC (HAS 18 MONTH DATA)*/
PROC IMPORT OUT= RAW.newtauc 
            DATAFILE= "U:\Lucy Faulconbridge\NEWS_study_2014\data\Raw\SAS tauc import.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

PROC IMPORT OUT= RAW.newiauc 
            DATAFILE= "U:\Lucy Faulconbridge\NEWS_study_2014\data\Raw\SAS iauc import.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

/*QA ON EVENT_NAME FOR 18 MONTH (IT'S MISSING 18 MONTH DATA)*/
%MACRO LOOK(DATASET);

/*	PROC CONTENTS DATA= &DATASET VARNUM;*/
/*	RUN;*/
/*	PROC PRINT DATA= &DATASET;*/
/*	RUN;*/
	proc freq data= &DATASET;
	tables event_name;
	run;
%MEND;

%LOOK(RAW.newtauc);
%LOOK(RAW.newiauc);
%LOOK(RAW.newdata2);

/*MERGE TAUC AND IAUC TOGETHER AND CALL IT NEWDATA2*/
PROC SORT DATA= RAW.newtauc ;
	BY Enrollment_ID	Event_Name	Arm;
RUN;

PROC SORT DATA= RAW.newiauc;
	BY Enrollment_ID	Event_Name	Arm;
RUN;

DATA RAW.newdata2;
	MERGE RAW.newtauc	RAW.newiauc;
	BY Enrollment_ID	Event_Name	Arm;
RUN;

