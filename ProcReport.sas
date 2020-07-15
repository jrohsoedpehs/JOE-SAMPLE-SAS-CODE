/*THIS CODE DEMONSTRATES HOW TO CREATE A DATASET AND THEN APPLY PROC REPORT TO IT*/
*libname raw"C:\Users\lqing\Dropbox\Jean (1)\HFpEF_SUMMER_2014\DSMB\DSMB2014SPRING\data\Raw";
*libname raw "U:\Julio Chirinos\HFpEF_SUMMER_2014\DSMB\DSMB2014Summer\data\raw";

libname raw "Q:\Julio Chirinos\Knock_out_Summer_2016\DSMB\DSMB_fall_2017\data\Raw";
libname derived "Q:\Julio Chirinos\Knock_out_Summer_2016\DSMB\DSMB_fall_2017\data\Derived";
footnote "SAS program stored: Q:\Julio Chirinos\Knock_out_Summer_2016\DSMB\DSMB_fall_2017\programs\DSMB_report.sas";

options fmtsearch=(raw); /*FORMATS DO NOT WORK TROUBLESHOOT THEM AFTER CODE WORKS BOTH AE AND NW KO*/
/*options nofmterr;*/




/**************************************************************************************************************
11/6/2017
Purpose

This code prepares VA's data for a merge.
The merged dataset is used to generate a tables for the DSMB.

For each site there is a table for 
Summary Stats

Adverse Events
*****************************************************/


/*CREATE NEW SEX AND RACE VARS*/

proc format;
value race 1='Caucasian'
			2='African American' 
			3='Asian' 
			4='American Indian/Alaska Native' 
			5='Native Hawaiian/Pacific Islander' 
			6='Multiracial or Other'
			. ='Missing';
value ethnici 1='Hisp' 0='No Hisp' ;
value trt 1="A" 2="B";
value yesno 1='Yes' 0='No' ;
value sex 1='Male' 2='Female' ;
value Smoke 1 = 'Current smoker or past smoker' 0 = 'Never used tobacco';
value  $Etoh '0'='Etoh Former Abuse' '1' = 'Less than 3 drinks' '2' ='3-7 drinks' '3' ='7-14 drinks';
value site 1 = 'PENN' 2 = 'NW';
value walking  
1 = 'Extremely limited'
3 = 'Moderately limited'
4 = 'Slightly limited'
5 = 'Not at all limited';

run;   




/*VA SITE*/
/*FULL DATASET*/

/*SUMMARY STATS*/
proc contents data=raw.vaknockout varnum;run;  /*UNDERSTAND THE SIZE, AND VARIABLE TYPES OF THE DATASET*/

proc freq data=raw.vaknockout;
tables redcap_event_name activity_dressing path_and_files_complete activity_showering; /*VARS OF INTEREST*/
run;

/*CREATE NEW SEX AND RACE VARS*/



ods rtf file = "Q:\Julio Chirinos\Knock_out_Summer_2016\DSMB\DSMB_Fall_2017\summary..&sysdate.doc" style=journal;
proc means data=raw.vaknockout maxdec=2;
var age glucose hemoglobin_a1c_value peak_bld_systolic_1 peak_bld_diastolic_1 ;
run;

proc freq data=raw.vaknockout;
tables gender  race___1 - race___6 current_smoker prior_smoker high_cholesterol glucose hemoglobin_a1c_value htn
Diabetes insulin osa peak_bld_systolic_1 peak_bld_diastolic_1 activity_walking;
run;
ods rtf close;



/*VARIABLES OF INTEREST in both UPENN KNOCK OUT AND NORTHWESTERN KNOCK OUT*/
%LET important_vars =     BMi	activity_walking	age	creatinine	current_smoker	diabetes egfr_value	egfr_non_aa	non_aa_oth	egfr_aa	aa_oth	gender	glucose	height	height_2	height_2_units	height_units	hemoglobin_a1c_value	high_cholesterol	htn	hyperkalemia_serum	insulin	osa	peak_bld_diastolic_1	peak_bld_systolic_1	potassium	prior_smoker	race___1	race___2	race___3	race___4	race___5	race___6	redcap_event_name	site_1	sodium	stan_diastolic_2	stan_systolic_2	study_id	study_site	total_meters_walked	weight	weight_2	weight_2_units	weight_units
;

PROC FREQ DATA=raw.vaknockout ;
TABLES height_2_units weight_2_units;
RUN;

/*SUBSET RAW.vaknockout*/

data derived.va;
	set raw.vaknockout;
	study_site = 3;

height_units= height_2_units;                                  /*CONVERSION FOR COMMON HEIGHT AND WEIGHT UNITS FOR BMI*/

weight_units = weight_2_units;	

height = height_2;
if height_units = 1 then height = height_2 * 0.3937;           /*CHANGE FROM CM TO INCHES*/
weight = weight_2;
if weight_units = 1 then weight = weight_2 * 2.2046;           /*CHANGE FROM KG TO LBS*/  
BMi = 703*weight /(height)**2;                                 /*CREATE BMI in inches and lbs*/

	keep bmi gender  race___1 - race___6 current_smoker prior_smoker high_cholesterol            /*VARIABLES OF INTERESST*/
    glucose hemoglobin_a1c_value htn
	Diabetes insulin osa peak_bld_systolic_1 peak_bld_diastolic_1 activity_walking
    age glucose hemoglobin_a1c_value
	peak_bld_systolic_1    stan_systolic_2 peak_bld_diastolic_1  stan_diastolic_2  
    site_1 study_id REDCAP_EVENT_NAME study_site weight_2 weight_2_units
	height_2 height_2_units total_meters_walked height_units weight_units weight height

hyperkalemia_serum Diabetes sodium potassium creatinine

;	

*At this point we are eliminated all but the baseline data for actual patients only keeps those;
	if REDCAP_EVENT_NAME = "baseline_visit_arm_1" and study_id ne "samp" and study_id ne "sample";
run;



/*QA BMI FORMULA*/

proc print data=derived.va;
var bmi weight height;
run;


/*QA WEIGHT AND HEIGHT CONVERSIONS*/
proc freq data=derived.va;
	tables weight*weight_2/list missing;
	tables height*height_2/list missing;
	tables height_units*height_2_units/list missing;
	tables weight_units*weight_2_units/list missing;	
run;


/*CREATE RTF OF MEANS*/
ods rtf file= "Q:\Julio Chirinos\Knock_out_Summer_2016\DSMB\DSMB_Fall_2017\documents\output\penn_summary_stat &sysdate..doc" style=journal;
proc means data=derived.va maxdec=2;
	var high_cholesterol glucose hemoglobin_a1c_value insulin osa 
	activity_walking   age glucose hemoglobin_a1c_value
    stan_systolic_2 peak_bld_diastolic_1  stan_diastolic_2 weight_2 
	height_2 bmi total_meters_walked ;
	title "VA raw summary statistics";
run;



proc freq data=derived.va (drop=study_id);
tables 
/* gender  race___1 - race___6 current_smoker prior_smoker high_cholesterol glucose  htn
	Diabetes insulin osa peak_bld_systolic_1 peak_bld_diastolic_1 activity_walking glucose
peak_bld_systolic_1 peak_bld_diastolic_1*/

 gender  race___1 - race___6 current_smoker prior_smoker high_cholesterol glucose hemoglobin_a1c_value htn
	Diabetes insulin osa peak_bld_systolic_1 peak_bld_diastolic_1 activity_walking   age glucose hemoglobin_a1c_value
	   stan_systolic_2  stan_diastolic_2 weight_2 weight_2_units
	height_2 height_2_units total_meters_walked bmi;
run;
title;
ods rtf close;




proc print data=derived.va;
	var study_id REDCAP_EVENT_NAME gender glucose race___1 - race___6; 
run;

proc print data=derived.va noobs;
	var study_id ;
run;





*At this point penn data is prepared for the merge, now preparing nw data for the merge;






/*****************************************************
10/30/2017
Purpose

This code generates tables for a DSMB

For each site there is a table for 
Summary Stats

Adverse Events



*****************************************************/

*proc format library=raw.formats cntlin=raw.formats; 
*run; 

*proc format library=work.formats cntlout = raw.formats; 
*run; 


/*UPENN SITE*/
/*FULL DATASET*/

/*SUMMARY STATS*/
proc contents data=raw.upenn_knockout varnum;run;  /*UNDERSTAND THE SIZE, AND VARIABLE TYPES OF THE DATASET*/

proc freq data=raw.upenn_knockout;
tables redcap_event_name activity_dressing path_and_files_complete activity_showering; /*VARS OF INTEREST*/
run;




/* 
ods rtf file = "Q:\Julio Chirinos\Knock_out_Summer_2016\DSMB\DSMB_Fall_2017\summary..&sysdate.doc" style=journal;
proc means data=redcap.redcap;
var age glucose hemoglobin_a1c_value peak_bld_systolic_1 peak_bld_diastolic_1 ;
run;;
run;

proc freq data=redcap.redcap;
tables gender  race___1 - race___6 current_smoker prior_smoker high_cholesterol glucose hemoglobin_a1c_value htn
Diabetes insulin osa peak_bld_systolic_1 peak_bld_diastolic_1 activity_walking;
run;
ods rtf close;
*/


/*VARIABLES OF INTEREST in both UPENN KNOCK OUT AND NORTHWESTERN KNOCK OUT*/
%LET important_vars =     BMi	activity_walking	age	creatinine	current_smoker	diabetes egfr_value	egfr_non_aa	non_aa_oth	egfr_aa	aa_oth	gender	glucose	height	height_2	height_2_units	height_units	hemoglobin_a1c_value	high_cholesterol	htn	hyperkalemia_serum	insulin	osa	peak_bld_diastolic_1	peak_bld_systolic_1	potassium	prior_smoker	race___1	race___2	race___3	race___4	race___5	race___6	redcap_event_name	site_1	sodium	stan_diastolic_2	stan_systolic_2	study_id	study_site	total_meters_walked	weight	weight_2	weight_2_units	weight_units
;

PROC FREQ DATA=raw.upenn_knockout ;
TABLES height_2_units weight_2_units;
RUN;

/*SUBSET RAW.UPENN_KNOCKOUT*/

data derived.penn;
	set raw.upenn_knockout;
	study_site = 1;

height_units= height_2_units;                                  /*CONVERSION FOR COMMON HEIGHT AND WEIGHT UNITS FOR BMI*/

weight_units = weight_2_units;	

height = height_2;
if height_units = 1 then height = height_2 * 0.3937;           /*CHANGE FROM CM TO INCHES*/
weight = weight_2;
if weight_units = 1 then weight = weight_2 * 2.2046;           /*CHANGE FROM KG TO LBS*/  
BMi = 703*weight /(height)**2;                                 /*CREATE BMI in inches and lbs*/

	keep bmi gender  race___1 - race___6 current_smoker prior_smoker high_cholesterol            /*VARIABLES OF INTERESST*/
    glucose hemoglobin_a1c_value htn
	Diabetes insulin osa peak_bld_systolic_1 peak_bld_diastolic_1 activity_walking
    age glucose hemoglobin_a1c_value
	peak_bld_systolic_1    stan_systolic_2 peak_bld_diastolic_1  stan_diastolic_2  
    site_1 study_id REDCAP_EVENT_NAME study_site weight_2 weight_2_units
	height_2 height_2_units total_meters_walked height_units weight_units weight height

hyperkalemia_serum Diabetes sodium potassium creatinine

;	
;
*At this point we are eliminated all but the baseline data for actual patients only keeps those;
	if REDCAP_EVENT_NAME = "baseline_visit_arm_1" and study_id ne "samp" and study_id ne "sample";
run;



/*QA BMI FORMULA*/

proc print data=derived.penn;
var bmi weight height;
run;


/*QA WEIGHT AND HEIGHT CONVERSIONS*/
proc freq data=derived.penn;
	tables weight*weight_2/list missing;
	tables height*height_2/list missing;
	tables height_units*height_2_units/list missing;
	tables weight_units*weight_2_units/list missing;	
run;


/*CREATE RTF OF MEANS*/
ods rtf file= "Q:\Julio Chirinos\Knock_out_Summer_2016\DSMB\DSMB_Fall_2017\documents\output\penn_summary_stat &sysdate..doc" style=journal;
proc means data=derived.penn maxdec=2;
	var high_cholesterol glucose hemoglobin_a1c_value insulin osa 
	activity_walking   age glucose hemoglobin_a1c_value
    stan_systolic_2 peak_bld_diastolic_1  stan_diastolic_2 weight_2 
	height_2 bmi total_meters_walked ;
	title "UPENN raw summary statistics";
run;



proc freq data=derived.penn (drop=study_id);
tables 
/* gender  race___1 - race___6 current_smoker prior_smoker high_cholesterol glucose  htn
	Diabetes insulin osa peak_bld_systolic_1 peak_bld_diastolic_1 activity_walking glucose
peak_bld_systolic_1 peak_bld_diastolic_1*/

 gender  race___1 - race___6 current_smoker prior_smoker high_cholesterol glucose hemoglobin_a1c_value htn
	Diabetes insulin osa peak_bld_systolic_1 peak_bld_diastolic_1 activity_walking   age glucose hemoglobin_a1c_value
	   stan_systolic_2  stan_diastolic_2 weight_2 weight_2_units
	height_2 height_2_units total_meters_walked bmi;
run;
title;
ods rtf close;




proc print data=derived.penn;
	var study_id REDCAP_EVENT_NAME gender glucose race___1 - race___6; 
run;

proc print data=derived.penn noobs;
	var study_id ;
run;





*At this point penn data is prepared for the merge, now preparing nw data for the merge;


 
data derived.nw;
	set raw.nw_knockout;


study_site = 2;

	height_units= height_2_units;

	weight_units = weight_2_units;	

	height = height_2;
	if height_units = 1 then height = height_2 * 0.3937;
	weight = weight_2;
	if weight_units = 1 then weight = weight_2 * 2.2046;
	BMi = 703*weight /(height)**2;

	keep
    BMi	activity_walking	age	creatinine	current_smoker	diabetes egfr_value	egfr_non_aa	non_aa_oth	egfr_aa	aa_oth	gender	glucose	height	height_2	height_2_units	height_units	hemoglobin_a1c_value	high_cholesterol	htn	hyperkalemia_serum	insulin	osa	peak_bld_diastolic_1	peak_bld_systolic_1	potassium	prior_smoker	race___1	race___2	race___3	race___4	race___5	race___6	redcap_event_name	site_1	sodium	stan_diastolic_2	stan_systolic_2	study_id	study_site	total_meters_walked	weight	weight_2	weight_2_units	weight_units;

	if REDCAP_EVENT_NAME = "baseline_visit_arm_1" and study_id ne "sample" and study_id ne "samp";
run;

proc means data=derived.nw ;run;
proc contents data= derived.nw; run;

proc freq data=derived.nw;
tables egfr_value	egfr_non_aa	non_aa_oth	egfr_aa	aa_oth;
run;

*qa;
proc print data=derived.nw;
	var study_id REDCAP_EVENT_NAME gender race___1 - race___6;
run;

proc print data=derived.nw noobs;
	var study_id;
run;

proc print data=derived.penn;
	var study_id REDCAP_EVENT_NAME gender race___1 - race___6;
run;



ods rtf file= "Q:\Julio Chirinos\Knock_out_Summer_2016\DSMB\DSMB_Fall_2017\documents\output\nw_summary_stat &sysdate..doc" style=journal;
proc means data=derived.nw maxdec=2;
	var high_cholesterol glucose hemoglobin_a1c_value insulin osa 
	activity_walking   age glucose hemoglobin_a1c_value
    stan_systolic_2 peak_bld_diastolic_1  stan_diastolic_2 weight_2 
	height_2 bmi total_meters_walked ;
	title "Unw raw summary statistics";
run;


proc freq data=derived.nw (drop=study_id);
tables 
/* gender  race___1 - race___6 current_smoker prior_smoker high_cholesterol glucose  htn
	Diabetes insulin osa peak_bld_systolic_1 peak_bld_diastolic_1 activity_walking glucose
peak_bld_systolic_1 peak_bld_diastolic_1*/

 gender  race___1 - race___6 current_smoker prior_smoker high_cholesterol glucose hemoglobin_a1c_value htn
	Diabetes insulin osa peak_bld_systolic_1 peak_bld_diastolic_1 activity_walking   age glucose hemoglobin_a1c_value
	   stan_systolic_2  stan_diastolic_2 weight_2 weight_2_units
	height_2 height_2_units total_meters_walked bmi;
run;
title;
ods rtf close;





*new variable for race computed, for all obs with more than one selection for race__# code as other=6, all other observations 
with one selection for race__# keep the categorical indicator related specified as previously with boolean logic;

data demo;
	 set derived.VA derived.nw derived.penn ;
	 race = race___1 + race___2 + race___3 + race___4 + race___5 + race___6;	
		if race > 1 then race = 6; else race = 1*(race___1 = 1) + 2*(race___2 = 1) + 3*(race___3) + 4*(race___4) + 5*(race___5) + 6*(race___6);
		sex = gender;
 	format race race. sex sex.;
run;

proc format library=work.formats cntlout = raw.DEMOformats; 
run; 
proc format library=raw.DEMOformats cntlin=raw.DEMOformats; 
run; 

/*Add Code to make the race and sex formats permanent*/

proc freq data=demo;
tables sex*gender/list missing;
run;



/**/
/*data trt;*/
/*input study_id $ trt $;*/
/*cards;*/
/*KT-1-01 B*/
/*KT-1-02 B*/
/*KT-1-03 A*/
/*KT-1-04 A*/
/*KT-1-05 B*/
/*KT-1-06 B*/
/*KT-2-01 A*/
/*KT-2-02 B*/
/*KT-2-03 A*/
/*;*/
/*run;*/

*Note:  1 = AB 2 = BA;

data trt;
	input study_id	$ trt $ p1 $ p2 $;
	cards;	
 KT-1-02	2 B A
 KT-1-03	1 A B
 KT-1-04	1 A B
 KT-1-05	2 B A
 KT-1-06	2 B A
 KT-1-08	2 B A
 KT-1-09	2 B A
 KT-1-11	2 B A
 KT-1-12	1 A B
 KT-1-13	1 A B
 KT-3-01	2 B A
 KT-1-07	1 A B
 KT-1-01	2 B A
 KT-2-01    1 A B
 KT-2-02    1 A B
 KT-2-03    2 B A
 KT-2-04	2 B A
 KT-2-05	1 A B
 KT-2-06	2 B A
 KT-2-07	2 B A
 KT-2-08	1 A B
 KT-2-09	1 A B
 KT-2-10	2 B A
 KT-2-11	2 B A
 KT-2-12	1 A B
 KT-2-13	1 A B
 KT-2-14    2 B A
;
run;


 proc print data=trt; run;

/*data trt;*/
/*input study_id $ trt egfr; */
/*cards;*/
/*KT-1-01 2 71*/
/*KT-1-02 2 54.2 */
/*KT-1-03 1 107.1*/
/*KT-1-04 1 72.7*/
/*KT-1-05 2 59.4*/
/*KT-1-06 2 61.1*/
/*KT-2-01 1 66*/
/*KT-2-02 2 66*/
/*KT-2-03 1 98*/
/*;*/
/*run;*/

proc contents data=demo; run;

*proc content;




*71
54.2
107.1
72.7
59.4
61.1;

*subject 	diabetes	sodium	potassium	creatinine	hemoglobin_vlr	hematocrit	glucose
KT-2-01	0	138	3.3	1.2		14.6	42.1	80
KT-2-02	0	139	4	0.9		14.2	44.8	72
KT-2-03	1	138	3.8	0.64	14.1	44	    87
;


proc sort data=trt; by study_id; run;
proc sort data=demo; by study_id; run;

data derived.demo;
	merge demo(in=a) trt(in=b);
	by study_id;
	check = a + b;
run;

proc print data=derived.demo;
where study_id = "KT-1-10"; /*THIS PARTICIPANT FAILED SCREENING BASED ON REDCap*/
*var study_id check;
run;

data demo1;
	set derived.demo;
	*remove the KT 10 Penn subject from the dataset because there is no data for this participant;
if study_id = "KT-1-10" then delete ;
run;
data demo;
	set demo1;
run;

proc print data=demo1;
run;

*qa;
proc freq data=derived.demo;
tables study_site;
tables race*race___1*race___2*race___3*race___4*race___5*race___6/list missing;
run;


/*
data  demo ;
  set raw.Baseline (rename=(Rand_No=trt race=race_ etoh=etoh_ Sex=Sex_));
  by id; 
    if strip(race_) in ('White','Caucasian') then race=1;
    else if  strip(race_)='African American' then race=2; 
    else if  strip(race_)='Asian' then race=3; 
    else if  strip(race_)='American Indian/Alaska Native' then race=4; 
    else if  strip(race_)='Native Hawaiian/Pacific Islander' then race=5; 
    else if strip(race_) in ('Other','Multiracial or Other') then race=6;

	if strip(etoh_) in ('Former Abuse') then etoh=1;
    else etoh=0 ;  
	  
	if Sex_='Male' then sex=0;
	else if sex_='Female' then sex=1;

	if  Current_Smoker='NO' and Former_Smoker='NO' then Never_Smoked=1;
	else Never_Smoked=0;
	drop id_   ;
	format race race.;
run;
proc freq data=demo ;
tables etoh_*etoh/list missing;
run;

proc contents data=demo  out=name(keep=name type format) noprint;
run;



data name;
   set name;
where type=2 and name in 
('Current_Smoker','Former_Smoker','Statin','ACEi','Lasix','CCB','Thiazide','CAD','Insulin','PVD','OSA','BB'
,'MI','HTN','DM'); 
run;

%macro creat;
data _null_;
       set name end = last; 
	   call symput(trim(left('varname'))||trim(left(_n_)),trim(left(name))) ;
       if last then call symput ('last',_n_);
run;
data a;
set demo;
keep  %do i=1 %to &last;&&varname&i 
   %end;;
run;

data demo1;
  set  demo (rename=( %do i=1 %to &last; &&varname&i=a&&varname&i %end;)); 
  %do i=1 %to &last;
   if  a&&varname&i in ('YES') then &&varname&i=1; 
   else if a&&varname&i in ('NO') then &&varname&i=0;
   else &&varname&i=.;  
   drop  a&&varname&i ;
   %end;
run; 
%mend;
%creat;   
proc freq data=demo1 ;
tables etoh_*etoh/list missing;
run;
/*data  demo;*/
/*  merge demo raw.Baseline  ;*/
/*  by id; */
/* Apo_A1=sum(of Apo_A1_vb,Apo_A1_vs)/2;*/
/* Apo_B_A1=sum(of Apo_B_A1_vb,Apo_B_A1_vs)/2;*/
/* Apo_B=sum(of Apo_B_vb,Apo_B_vs)/2;*/
/* Diastolic_BP=sum(of Diastolic_BP_vb,Diastolic_BP_vs)/2;*/
/* HDL_Cholesterol=sum(of HDL_Cholesterol_vb,HDL_Cholesterol_vs)/2;*/
/* Height=sum(of Height_vb,Height_vs)/2;*/
/* LDL_Cholesterol=sum(of LDL_Cholesterol_vb,LDL_Cholesterol_vs)/2;*/
/* Lipo_A=sum(of Lipo_A_vb,Lipo_A_vs)/2;*/
/* Systolic_BP=sum(of Systolic_BP_vb,Systolic_BP_vs)/2;*/
/* Total_Cholesterol=sum(of Total_Cholesterol_vb,Total_Cholesterol_vs)/2;*/
/* Triglycerides=sum(of Triglycerides_vb,Triglycerides_vs)/2;*/
/* Waist_Circumference=sum(of Waist_Circumference__vb,Waist_Circumference__vs)/2;*/
/* Weight=sum(of Weight_vb,Weight_vs)/2;*/
/*run;*/


proc sort data=demo1 ;
   by trt  ;
run;
proc sort data=demo;
	by trt;
run;


*data new; *run;

%include 'Q:\Julio Chirinos\Knock_out_Summer_2016\DSMB\DSMB_Fall_2017\programs\draft\macro_table1.sas';

%cont(Age,%str(Age,years), 1,demo1);
%cont(BMi,%str(Body Max Index), 2,demo1);


%cont(total_meters_walked,%str(Total Meters Walked), 3,demo1);
%cont(stan_systolic_2,%str(Systolic Blood Pressure), 4,demo1);
%cont(stan_diastolic_2,%str(Diastolic Blood Pressure), 5,demo1);
%cont(hemoglobin_a1c_value,%str(Hemoglobin A1c Value), 6,demo1);
%cont(glucose,%str(Glucose), 7,demo1);
%cont(sodium,%str(Sodium), 8,demo1);
%cont(Potassium,%str(Potassium), 9,demo1);
%cont(creatinine,%str(Creatinine), 10,demo1);



%catg(study_site,Study Site,site.,fisher,11,%str(where study_site ne .),demo1);

%catg(sex,Sex,sex.,fisher,12,%str(where sex ne .),demo1);
%catg(race,Race,race.,fisher,13,%str(where race ne .),demo1);
%catg(current_smoker,Current Smoker,yesno.,fisher,14,%str(where current_smoker ne .),demo1);
%catg(prior_smoker,Prior Smoker,yesno.,fisher,15,%str(where prior_smoker ne .),demo1);
%catg(htn,Hypertension(HTN),yesno.,fisher,16,%str(where htn ne .),demo1);
%catg(Diabetes,Diabetes(DM),yesno.,fisher,17,%str(where diabetes ne .),demo1);
%catg(insulin,Insulin,yesno.,fisher,18,%str(where insulin ne .),demo1);
%catg(osa,OSA,yesno.,fisher,19,%str(where osa ne .),demo1);
*%catg(activity_walking,Walking 1 block on level ground,walking.,fisher,16,%str(where activity_walking ne .),demo1);

/*%cont(egfr,%str(eGFR), 20,demo1);*/
*Diabetes sodium potassium creatinine;

/*proc npar1way data=demo wilcoxon anova;*/
/*class trt;*/
/*var egfr;*/
/*run;*/
/**/
/*Proc print data=new; run;*/



*checking macros above QA;
proc print data=work.new; run;

 
proc freq data=demo1 noprint; 
tables trt/out=trt;  
run;
**********************************************************start here 12pm 11/6;

data trt;
set trt  ;
file print ls=130;
by trt;
retain totall;
if _n_=1 then totall=COUNT;
else  totall+COUNT; 
run;

proc print data=trt; run;

data _null_;
set trt;
select (trt);
when (1) call symput(strip("tot1"), strip(put(count,$4.)));
*when (2) call symput(strip("tot2"), strip(put(count,$4.)));
when (2) 
	do;
		call symput(strip("tot2"), strip(put(count,$4.)));
  		call symput(strip("totall"), strip(put(totall,$4.))); 
	end;
otherwise;
end; 
run; 
   option ls=130;



ods rtf file=  "Q:\Julio Chirinos\Knock_out_Summer_2016\DSMB\DSMB_Fall_2017\documents\output\closed_report_table_1 &sysdate..doc" style=journal;


proc report data=new nowd headskip;
column order varlab cat totstats _1 _2 pvalue;
break after order/skip;
define order/order noprint;
define varlab/order width=50 flow left 'Variable';
define cat/display spacing=1 width=33 left' ';
define totstats/display spacing=3 width=30 left "Total/(n=&totall)";
define _1/display spacing=1 width=30 left "Group AB/(n=&tot1)";
define _2/display spacing=1 width=30 left "Group BA/(n=&tot2)";
*define _3/display spacing=1 width=30 left "Group C/(n=&tot3)";
define pvalue/display spacing=1 width=30 left 'Pvalue[a]';
title 'Table 1';			
title3 'Baseline Characteristics ';
/*compute after; */
/*line @1 "Numbers indicate the median (continuous variables) or percentage (categorical variables).Numbers in parentheses indicate the interquartile range. FG=Fasting Glucose;";*/
/*line @2 "type-2 diabetes= type 2 diabetes mellitus. Pairwise comparisons: * IFG vs. normal FG.† type-2 diabetes vs. normal FG. ‡ type-2 diabetes vs. IFG."; */
/*line @3 "§ Statistical comparisons of cardiac output, stroke volume and SVR are adjusted for BSA."; */
/*endcomp;*/
run;
ods rtf close;



*ods rtf file= "Q:\Julio Chirinos\Knock_out_Summer_2016\DSMB\DSMB_Fall_2017\documents\output\open_report_table_1_cont &sysdate..doc" style=journal;


ods rtf file= "Q:\Julio Chirinos\Knock_out_Summer_2016\DSMB\DSMB_Fall_2017\documents\output\open_report_table_1 &sysdate..doc" style=journal;

   option ls=130;
proc report data=new nowd headskip;
column order varlab cat totstats ;
break after order/skip;
define order/order noprint;
define varlab/order width=50 flow left 'Variable';
define cat/display spacing=1 width=33 left' ';
define totstats/display spacing=3 width=30 left "Total/(n=&totall)";
*define _1/display spacing=1 width=30 left "Group A/(n=&tot1)";
*define _2/display spacing=1 width=30 left "Group B/(n=&tot2)";
*define _3/display spacing=1 width=30 left "Group C/(n=&tot3)";
define pvalue/display spacing=1 width=30 left 'Pvalue[a]';
title 'Open Report';
title2 'Table 1';			
title3 'Over all Baseline Characteristics ';
/*compute after; */
/*line @1 "Numbers indicate the median (continuous variables) or percentage (categorical variables).Numbers in parentheses indicate the interquartile range. FG=Fasting Glucose;";*/
/*line @2 "type-2 diabetes= type 2 diabetes mellitus. Pairwise comparisons: * IFG vs. normal FG.† type-2 diabetes vs. normal FG. ‡ type-2 diabetes vs. IFG."; */
/*line @3 "§ Statistical comparisons of cardiac output, stroke volume and SVR are adjusted for BSA."; */
/*endcomp;*/
run;
ods rtf close;


data new;
  set new;
run; 


/*QA to check table accuracy*/
proc freq data=derived.demo;
tables study_site sex race current_smoker prior_smoker htn Diabetes insulin osa;
run;
proc means data=derived.demo;
run;

proc means data=derived.demo;
CLASS trt;
run;
proc freq data=demo;
BY trt;
tables study_site sex race current_smoker prior_smoker htn Diabetes insulin osa;
run;

ods rtf file= "Q:\Julio Chirinos\Knock_out_Summer_2016\DSMB\DSMB_Fall_2017\documents\output\egfr_variable summary stats &sysdate..doc" style=journal;

/*summary statistics and proc print on all egfr variables*/

proc print data= derived.demo;
var egfr_value	egfr_non_aa	non_aa_oth	egfr_aa	aa_oth;
run;

proc freq data=derived.demo;
tables egfr_value	egfr_non_aa   	non_aa_oth  	egfr_aa	aa_oth;
run;

ods rtf close;











*20171105 Email from Mr Chittams: Please check the number for the categorical variables using proc freq and let 
me know what the correct numbers should be.
Also do the same for the continuous (numeric) variables using proc means and show me that the summary statistics 
are correct.;

ods rtf file= "Q:\Julio Chirinos\Knock_out_Summer_2016\DSMB\DSMB_Fall_2017\documents\output\DSMB QA MEANS+FREQ &sysdate..doc" style=journal;


proc means data =derived.demo;
var Age BMi total_meters_walked stan_systolic_2 stan_diastolic_2 hemoglobin_a1c_value glucose sodium Potassium creatinine ;
run;

proc freq data= derived.demo;
tables study_site sex race current_smoker prior_smoker htn Diabetes insulin osa;
run; 

ods rtf close;

