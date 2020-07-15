libname raw "Q:\George Demiris\PISCES\data\Raw";
libname derived "Q:\George Demiris\PISCES\data\Derived";

footnote "SAS Program Stored in: Q:\George Demiris\PISCES\programs\Draft\Table_1_Summary_Stats.sas";

/*FORMATS*/
options fmtsearch=(raw.referral_formats );
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

/*Limit data to consented participants - see makeData.sas*/
proc contents data=raw.referral_tracking varnum;run;  /*UNDERSTAND THE SIZE, AND VARIABLE TYPES OF THE DATASET*/

data demo;
set raw.referral_tracking ;
/*Create TRT*/
obs = _n_;
/*The MOD function returns the remainder from the division of obs by 2*/
trt = (mod(obs,2)=0)+1;
/*Auto start with today's date and 7 days ago*/
today = today();
day_7 = %eval(%sysfunc(today())-7);
day_30 = %eval(%sysfunc(today())-30);
where mdy(9,30,2018) < referral_date < mdy(11,1,2018);
format today day_7 day_30 mmddyy10.;
run;


proc freq data= demo;
table record_id*referral_date/list missing;
run;

/*QA Variable types*/
proc contents data= demo varnum;run;

proc freq data= demo;
tables today day_7 day_30 referral_date;
run;

/*QA TRT*/
proc freq data = demo;
	tables trt*obs*record_id/list missing;
run;

* prepare data for Jean's macro;
data derived.demo_phase1;
	set demo;
run;

data demo1;
	set derived.demo_phase1; 
run;
data demo;
	set demo1;
run;

proc sort data=demo1; by trt; run;
proc sort data=demo; by trt; run;

/*proc freq data= derived.concatenate_redcap;*/
/*tables sex;*/
/*run;*/
/**/
/*proc freq data= demo1;*/
/*tables sex;*/
/*run;*/

%include "Q:\George Demiris\PISCES\programs\Draft\macro_table1.sas";

/*DECLINES/POSITIVES*/
/*pre_screen_interest*/
%catg(pre_screen_interest,Pre-Screen Caregiver Interest,pre_screen_interest_.,fisher,1,%str(where pre_screen_interest ne .),demo1);

/*CONSENTS (%)*/
/*outcome_of_consent_visit*/
%catg(outcome_of_consent_visit,Consents,outcome_of_consent_visit_.,fisher,2,%str(where outcome_of_consent_visit ne .),demo1);

/*# of Pos. Referrals in past 7 days*/
%catg(pre_screen_interest,%str(Pre-Screen Caregiver Interest in past 7 days),pre_screen_interest_.,fisher,3,
%str(where consent_visit_scheduled ne . and mdy(10,24,2018) < referral_date < mdy(11,1,2018)),demo1);

/*QA on # of Pos. Referrals in past 7 days*/
/*proc freq data=demo1;*/
/*tables consent_visit_scheduled referral_date;*/
/*run;*/
/*proc freq data=demo1;*/
/*tables consent_visit_scheduled*referral_date/list missing;*/
/*where day_7 < referral_date < today;*/
/*run;*/


/*# of Pos. Referrals in past 30 days*/
%catg(pre_screen_interest,%str(Pre-Screen Caregiver Interest in past 30 days),pre_screen_interest_.,fisher,4,
%str(where consent_visit_scheduled ne . and mdy(9,30,2018) < referral_date < mdy(11,1,2018)),demo1);

/*QA on # of Pos. Referrals in past 30 days*/
proc freq data=demo1;
tables consent_visit_scheduled referral_date;
run;
/*proc freq data=demo1;*/
/*tables consent_visit_scheduled*referral_date/list missing;*/
/*where day_30 < referral_date < today;*/
/*run;*/

/*no data*/
/*# of Consents in past 7 days*/
%catg(outcome_of_consent_visit,%str(Consents in past 7 days),outcome_of_consent_visit_.,fisher,5,
%str(where outcome_of_consent_visit ne . and mdy(10,24,2018) < referral_date < mdy(11,1,2018)),demo1);

/*QA on # of Consents in past 7 days*/
/*proc freq data=demo1;*/
/*tables outcome_of_consent_visit consent_visit_date;*/
/*run;*/
/*proc freq data=demo1;*/
/*tables outcome_of_consent_visit*consent_visit_date/list missing;*/
/*where day_7 < consent_visit_date < today;*/
/*run;*/

/*no data*/
/*# of Consents in past 30 days*/
%catg(outcome_of_consent_visit,%str(Consents in past 30 days),outcome_of_consent_visit_.,fisher,6,
%str(where outcome_of_consent_visit ne . and mdy(9,30,2018) < referral_date < mdy(11,1,2018)),demo1);
/**/
/*/*QA on # of Consents in past 30 days*/*/
/*proc freq data=demo1;*/
/*tables outcome_of_consent_visit consent_visit_date;*/
/*run;*/
/*proc freq data=demo1;*/
/*tables outcome_of_consent_visit*consent_visit_date/list missing;*/
/*where day_30 < consent_visit_date < today;*/
/*run;*/


/*no data*/
/*Reasons for declining*/
/*non_participation_reason*/;
%catg(non_participation_reason,Reasons for declining,non_participation_reason_.,fisher,7,%str(where non_participation_reason ne .),demo1);

/*QA*/
/*proc freq data=demo1;*/
/*tables non_participation_reason;*/
/*run;*/

*checking macros above QA;
 
proc freq data=demo1 noprint; 
tables trt/out=trt;  
run;

*checking macros above QA;
  
proc print data=work.new; run;

/*proc freq data=demo1 noprint; */
/*tables trt/out=trt;  */
/*run;*/
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
/*OPEN REPORT*/
ods rtf file=  "Q:\George Demiris\PISCES\documents\output\Referral Tracking Form &sysdate..doc" style=journal;*options orientation=landscape topmargin=0.5in bottommargin=0.5in rightmargin=0.5in leftmargin=0.5in;
proc report data=new nowd headskip;
	column order varlab cat totstats ;
	break after order/skip;
	define order/order noprint;
	define varlab/order width=50 flow left 'Variable';
	define cat/display spacing=1 width=33 left' ';
	define totstats/display spacing=3 width=30 left "Total/Referrals=&totall";  
	title 'Open Report';
	title2 'Table 1';			
	title3 'Referral Tracking Form';
run;
ods rtf close;

/*CLOSE REPORT*/
/*ods rtf file=  "Q:\George Demiris\PISCES\documents\output\closed_report_table_1 &sysdate..doc" style=journal;*/
/*options orientation=landscape topmargin=0.5in bottommargin=0.5in rightmargin=0.5in leftmargin=0.5in;*/
/**/
/*proc report data=new nowd headskip;*/
/*column order varlab cat totstats _1 _2 pvalue;*/
/*break after order/skip;*/
/*define order/order noprint;*/
/*define varlab/order width=55 flow left 'Variable';*/
/*define cat/display spacing=1 width=33 left' ';*/
/*define totstats/display spacing=3 width=30 left "Total/(Total Referrals=&totall)";*/
/*define _1/display spacing=1 width=30 left "Control/(n=&tot1)";*/
/*define _2/display spacing=1 width=30 left "Sleep Apnea/(n=&tot2)";*/
/**define _3/display spacing=1 width=30 left "Group C/(n=&tot3)";*/
/*define pvalue/display spacing=1 width=30 left 'Pvalue';*/
/*title 'Table 1';			*/
/*title3 'Baseline Characteristics ';*/
/*/*compute after; */*/
/*/*line @1 "Numbers indicate the median (continuous variables) or percentage (categorical variables).Numbers in parentheses indicate the interquartile range. FG=Fasting Glucose";*/*/
/*/*line @2 "type-2 diabetes= type 2 diabetes mellitus. Pairwise comparisons: * IFG vs. normal FG.† type-2 diabetes vs. normal FG. ‡ type-2 diabetes vs. IFG."; */*/
/*/*line @3 "§ Statistical comparisons of cardiac output, stroke volume and SVR are adjusted for BSA."; */*/
/*/*endcomp;*/*/
/*run;*/
/*ods rtf close;*/

