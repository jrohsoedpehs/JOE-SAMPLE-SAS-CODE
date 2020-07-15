libname raw "Q:\George Demiris\PISCES\data\Raw";
libname derived "Q:\George Demiris\PISCES\data\Derived";

footnote "SAS Program Stored in: Q:\George Demiris\PISCES\programs\Draft\Table_1_Summary_Stats.sas";

/*FORMATS*/
options fmtsearch=(raw.pisces_formats);
options nofmterr;

/***************************************
Description of task

Hi Joseph:
We are slowly but steadily recruiting participants into our study and things are going well!

We would like to have a weekly report to assess where we are with recruitment. 
I am attaching an example of this weekly dashboard that I had used from the previous trial.
Part of the information (pertaining to referrals and declines) comes outside of RedCap from our own tracking spreadsheet, 
the remaining information (such as attrition, measures completion and demographics) would be generated from RedCap. 
I had two questions for you:

1)	Can you help us generate these data from RedCap for the weekly reports?
2)	Stacey maintains our referral tracking (which is an Excel spreadsheet)-would you be able to help us with the queries that 
would generate the weekly report data?

Thanks! Let us know if you want to meet and discuss more.
George


***************************************/

/*CREATE NEW SEX AND RACE VARS*/

proc format;
value complete 
1='Complete'
0='Incomplete' 
;					
run;   


proc transpose data=raw.pisces out=widef prefix=phq9_total;
    by caregiver_id ;
    id redcap_event_name;
    var phq9_total;
run;

/*QA Transpose*/
proc print data=raw.pisces;
var caregiver_id redcap_event_name phq9_total;
run;
proc print data=widef;
run;

proc transpose data=raw.pisces out=wides prefix=gad_7_total;
    by caregiver_id ;
    id redcap_event_name;
    var gad_7_total;
run;

/*QA Transpose*/
proc print data=raw.pisces;
var caregiver_id redcap_event_name gad_7_total;
run;
proc print data=wides;
run;


proc transpose data=raw.pisces out=wide3 prefix=exit_date_;
    by caregiver_id ;
    id redcap_event_name;
    var date_of_exit_interview;
run;

/*QA Transpose*/
proc print data=raw.pisces;
var caregiver_id redcap_event_name date_of_exit_interview;
run;
proc print data=wide3;
run;

proc sort data= raw.pisces; by caregiver_id;run;
proc sort data= widef; by caregiver_id;run;
proc sort data= wides; by caregiver_id;run;
proc sort data= wide3; by caregiver_id;run;

data derived.pisces;
merge  raw.pisces widef(drop=_name_) wides(drop=_name_) wide3(drop=_name_);
by caregiver_id;
drop
gad_7_totalSession_1 
gad_7_totalSession_2 
gad_7_totalExit_Interview 
gad_7_totalReportable_Events

phq9_totalSession_1 
phq9_totalSession_2 
phq9_totalExit_Interview 
phq9_totalReportable_Events 

exit_date_Consent_Visit 
exit_date_Session_1 
exit_date_Session_2 
exit_date_Session_3 
exit_date_Reportable_Events 
;
run;

/*QA Merge*/
proc print data= derived.pisces;
var caregiver_id 
redcap_event_name 
phq9_total 
phq9_totalConsent_Visit 
phq9_totalSession_3 
gad_7_total 
gad_7_totalConsent_Visit 
gad_7_totalSession_3 ;
run;

/*SUMMARY STATS*/
proc contents data=raw.pisces varnum;run;  /*UNDERSTAND THE SIZE, AND VARIABLE TYPES OF THE DATASET*/

data demo;
set derived.pisces ;

/*make caregiver id numeric*/
obs = _N_ ;

/*Create TRT*/
trt = (mod(obs,2))+1;

/*Convert demog_date to years only*/
year_demog_date = year(demog_date);

/*Create age*/
age = year_demog_date-demog_dob;
if redcap_event_name = "consent_visit_arm_1";/*Baseline*/

/*Baseline Measures Flag*/
if  psi_positive ne .  then baseline_measures = 1;
if  psi_positive = .  then baseline_measures = 0;

/*Final Measures*/
if phq9_totalSession_3 ne .  and gad_7_totalSession_3 ne . then final_measures = 1;
if phq9_totalSession_3 = .  or gad_7_totalSession_3 = . then final_measures = 0;

/*Exit Interview*/
if exit_date_Exit_Interview ne . then exit_interview_flag = 1;
if exit_date_Exit_Interview = . then exit_interview_flag = 0;

where mdy(9,30,2018) < demog_date < mdy(11,1,2018);


format baseline_measures final_measures exit_interview_flag complete. ;
run;

/*QA Variable types*/
proc contents data= demo varnum;run;

/*QA TRT*/
proc freq data = demo;
	tables trt*obs*caregiver_id/list missing;
run;

/*QA baseline_measures*/
proc freq data= demo;
tables baseline_measures;
run;

/*QA final_measures*/
proc freq data= demo;
tables final_measures;
run;

proc freq data= demo;
tables final_measures*redcap_event_name/list missing;
run;

proc print data= demo;
var caregiver_id redcap_event_name phq9_total gad_7_total;
run;


/*QA year_demog_date*/
proc freq data= demo;
tables demog_date*year_demog_date/list missing;
run;

/*QA Age*/
proc freq data= demo;
tables age*year_demog_date*demog_dob/list missing;
run;


data derived.demo;
set demo;
run;

data demo1;
	set derived.demo;
run;

data demo;
	set demo1;
run;


proc sort data=demo1 ;
   by trt  ;
run;
proc sort data=demo;
	by trt;
run;


*data new; *run;

%include 'Q:\George Demiris\PISCES\programs\Draft\macro_table1.sas';

/*Baseline Measures*/
/*psi_positive ne .*/
/*baseline_measures*/
%catg(baseline_measures,Baseline Measures,complete.,fisher,1,%str(where baseline_measures ne .),demo1);

/*Final Measures*/
/*final_measures*/
%catg(final_measures,Final Measures,complete.,fisher,2,%str(where final_measures ne .),demo1);

/*Exit Interview*/
/*exit_interview_flag*/
%catg(exit_interview_flag,Exit Interview,complete.,fisher,3,%str(where exit_interview_flag ne .),demo1);

/*Age*/
/*age*/
%cont(age,%str(Age), 4,demo1);

/*Gender*/
/*demog_gender */
%catg(demog_gender,Gender,demog_gender_.,fisher,5,%str(where demog_gender ne .),demo1);

/*Ethnicity*/
/*demog_ethnic*/
%catg(demog_ethnic,Ethnicity,demog_ethnic_.,fisher,6,%str(where demog_ethnic ne .),demo1);

/*Race*/
/*demog_race*/
%catg(demog_race,Race,demog_race_.,fisher,7,%str(where demog_race ne .),demo1);

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



*ods rtf file=  "Q:\George Demiris\PISCES\documents\output\closed_report_table_1 &sysdate..doc" style=journal;


*proc report data=new nowd headskip;
*column order varlab cat totstats _1 _2 pvalue;
*break after order/skip;
*define order/order noprint;
*define varlab/order width=50 flow left 'Variable';
*define cat/display spacing=1 width=33 left' ';
*define totstats/display spacing=3 width=30 left "Total/(n=&totall)";
*define _1/display spacing=1 width=30 left "Group AB/(n=&tot1)";
*define _2/display spacing=1 width=30 left "Group BA/(n=&tot2)";
*define _3/display spacing=1 width=30 left "Group C/(n=&tot3)";
*define pvalue/display spacing=1 width=30 left 'Pvalue[a]';
*title 'Table 1';			
*title3 'Baseline Characteristics ';
/*compute after; */
/*line @1 "Numbers indicate the median (continuous variables) or percentage (categorical variables).Numbers in parentheses indicate the interquartile range. FG=Fasting Glucose;";*/
/*line @2 "type-2 diabetes= type 2 diabetes mellitus. Pairwise comparisons: * IFG vs. normal FG.† type-2 diabetes vs. normal FG. ‡ type-2 diabetes vs. IFG."; */
/*line @3 "§ Statistical comparisons of cardiac output, stroke volume and SVR are adjusted for BSA."; */
/*endcomp;*/
*run;
*ods rtf close;





ods rtf file= "Q:\George Demiris\PISCES\documents\output\Basic Demographic Information for Study Participants &sysdate..doc" style=journal;

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
/*title 'Open Report';*/
/*title2 'Table 1';			*/
title3 'Basic Demographic Information for Study Participants';
/*compute after; */
/*line @1 "Numbers indicate the median (continuous variables) or percentage (categorical variables).Numbers in parentheses indicate the interquartile range. FG=Fasting Glucose;";*/
/*line @2 "type-2 diabetes= type 2 diabetes mellitus. Pairwise comparisons: * IFG vs. normal FG.† type-2 diabetes vs. normal FG. ‡ type-2 diabetes vs. IFG."; */
/*line @3 "§ Statistical comparisons of cardiac output, stroke volume and SVR are adjusted for BSA."; */
/*endcomp;*/
run;
ods rtf close;







