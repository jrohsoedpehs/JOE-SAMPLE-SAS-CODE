libname raw "Q:\STUDENT Stefanie Zavodny\Dissertation\data\Raw";
libname derived "Q:\STUDENT Stefanie Zavodny\Dissertation\data\Derived";
footnote "SAS program stored: :\STUDENT Stefanie Zavodny\Dissertation\programs\Draft\Demographics_Table_1.sas";
options fmtsearch=(redcap.nursing_formats raw.chop_formats);
options nofmterr;


/*Hi Stephanie,*/
/**/
/*To make the education variable stable enough for analyses, we would like to combine */
/*“Some high school” with “High school diploma” and “Some college” with 2-year college degree”.  */
/*Let us know if that is O.K. with you.*/
/**/
/*You and Joseph may have already resolved that.*/
/**/
/**/
/*Thank you,*/
/*Jesse*/

/*proc contents  data = derived.chop_nursing_merge varnum; run;*/
/*proc freq data = derived.chop_nursing_merge ; */
/*tables demographics_q08;*/
/*run;*/

/*Should I Limit data to consented participants?*/
/*race format*/
proc format ;
	value race
		1 = "American Indian or Alaska Native"
		2 = "Asian"
		3 = "Black/African American"
		4 = "Hispanic"
		5 = "Native Hawaiian or Other Pacific Islander"
		6 = "White"
		7 = "Multi-racial";

	value demog_q08_composite_
		1="High school diploma"
		2="2-year college degree"
		3="Bachelor's degree"
		4="Graduate degree";
	value yesno
		1 = "Yes"
		0 = "No";
	value fad_function_
		1= "Normal"
		0= "Worse";
	value yesnoother_
		0 = "No"
		1 = "Yes"
		2 = "Other";
run;

/*QA Demog variables*/
proc contents data= derived.chop_nursing_merge varnum;run;

/*demographics_q08 crashes macro collapse some categories*/
/*The total percentages will be off if trt is missing*/
data demo;
	set derived.chop_nursing_merge;

    parent_race = demographics_q01___1 + demographics_q01___2 + demographics_q01___3 + demographics_q01___4 + demographics_q01___5 + demographics_q01___6  ;	
 	child_race  = demographics_q02___1 + demographics_q02___2 + demographics_q02___3 + demographics_q02___4 + demographics_q02___5 + demographics_q02___6  ;	

    if parent_race > 1 then parent_race = 7; else parent_race = 1*(demographics_q01___1 = 1) + 2*(demographics_q01___2 = 1) + 3*(demographics_q01___3) + 4*(demographics_q01___4) + 5*(demographics_q01___5) + 6*(demographics_q01___6);
	if parent_race = 0 then parent_race = .;

    if child_race > 1 then child_race = 7; else child_race = 1*(demographics_q02___1 = 1) + 2*(demographics_q02___2 = 1) + 3*(demographics_q02___3) + 4*(demographics_q02___4) + 5*(demographics_q02___5) + 6*(demographics_q02___6);
	if child_race = 0 then child_race = .;

/*	convert vars to num*/
    demographics_q03_clean_n=demographics_q03_clean*1;
    demographics_q05_clean_n=demographics_q05_clean*1;
    demographics_q10_clean_n=demographics_q10_clean*1;
    demographics_q11_clean_n=demographics_q11_clean*1;
    demographics_12_clean_n=demographics_12_clean*1;


/*To make the education variable stable enough for analyses, */
/*we would like to combine “Some high school” with “High school diploma” */
/*and “Some college” with 2-year college degree”*/
	if demographics_q08 in (1,2) then demog_q08_composite = 1 ;
	if demographics_q08 in (3,4) then demog_q08_composite = 2 ;
	if demographics_q08 = 5      then demog_q08_composite = 3 ;
	if demographics_q08 = 6      then demog_q08_composite = 4 ;
	if trt ne .;

 	format parent_race child_race race. ;
run;

/*QA percent*/
/*proc freq data= demo;*/
/*tables parent_race;*/
/*run;*/

/*QA*/
/*proc freq data=demo;*/
/*tables trt;*/
/*tables parent_race*demographics_q01___1 * demographics_q01___2 * demographics_q01___3 * demographics_q01___4 * demographics_q01___5 * demographics_q01___6/list missing  ;*/
/*tables child_race*demographics_q02___1 * demographics_q02___2 * demographics_q02___3 * demographics_q02___4 * demographics_q02___5 * demographics_q02___6/list missing  ;*/
/*run;*/
  
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

%include 'Q:\STUDENT Stefanie Zavodny\Dissertation\programs\Draft\macro_table1.sas';

/*%cont(intake_age,%str(Age,years), 1,demo1);*/
/*%catg(sex,Gender,SEX_.,fisher,2,%str(where sex ne .),demo1);*/

%catg(parent_race,Parent Race,race.,fisher,1,%str(where parent_race ne .),demo1);
%catg(child_race,Child Race,race.,fisher,2,%str(where child_race ne .),demo1);
%cont(demographics_q03_n,%str(What is the age of your CHILD? If you have multiple children, enter the age of the child you thought about while answering the surveys.),3,demo1);
%catg(demographics_q04,Gender,demographics_q04_.,fisher,4,%str(where demographics_q04 ne .),demo1);
%cont(demographics_q05_n,%str(How old was your child when s/he was diagnosed with ASD (in MONTHS)? This includes autism, Asperger Syndrome, or PDD-NOS. If your child does not have a diagnosis of ASD, please write n/a),5,demo1);
%catg(demographics_q07,Marital Status,demographics_q07_.,fisher,6,%str(where demographics_q07 ne .),demo1);
%catg(demog_q08_composite ,Education,demog_q08_composite_.,fisher,7,%str(where demographics_q08 ne .),demo1);
%catg(demographics_q09,Employment,demographics_q09_.,fisher,8,%str(where demographics_q09 ne .),demo1);
%cont(demographics_q10_n,%str(How many children do you have in your family?),9,demo1);
%cont(demographics_q11_n,%str(How many children in your family have a diagnosis of ASD, Down syndrome, developmental delay, cognitive impairment, or any other developmental or learning disability?),10,demo1);
%cont(demographics_q12_n,%str(How many people live in your household (including yourself)?),11,demo1);

/*%catg(var,label,format,test,order,%str(where var ne .),demo1);*/
%catg(demographics_q13___1,%str(Who lives in your home with you? (select all that apply) (choice=Your child(ren))),yesno.,fisher,12,%str(where demographics_q13___1 ne .),demo1);
%catg(demographics_q13___2,%str(Who lives in your home with you? (select all that apply) (choice=Your partner/spouse/significant other)),yesno.,fisher,13,%str(where demographics_q13___2 ne .),demo1);
%catg(demographics_q13___3,%str(Who lives in your home with you? (select all that apply) (choice=Extended family members)),yesno.,fisher,14,%str(where demographics_q13___3 ne .),demo1);
%catg(demographics_q13___4,%str(Who lives in your home with you? (select all that apply) (choice=Roommate/housemate(s))),yesno.,fisher,15,%str(where demographics_q13___4 ne .),demo1);

%cont(demographics_q14,%str(Annual Household Income),16,demo1);
%catg(demographics_q15,Mental Health Condition,demographics_q15_.,fisher,17,%str(where demographics_q15 ne .),demo1);
%catg(demographics_q18,Mental Health Help,demographics_q18_.,fisher,18,%str(where demographics_q18 ne .),demo1);

%catg(demographics_q19___1,%str(What kind of treatment did you receive (select all that apply)? (choice=Talk therapy)),yesno.,fisher,19,%str(where demographics_q19___1 ne .),demo1);
%catg(demographics_q19___2,%str(What kind of treatment did you receive (select all that apply)? (choice=Cognitive behavioral therapy)),yesno.,fisher,20,%str(where demographics_q19___2 ne .),demo1);
%catg(demographics_q19___3,%str(What kind of treatment did you receive (select all that apply)? (choice=Medications)),yesno.,fisher,21,%str(where demographics_q19___3 ne .),demo1);
%catg(demographics_q19___4,%str(What kind of treatment did you receive (select all that apply)? (choice=Other)),yesno.,fisher,22,%str(where demographics_q19___4 ne .),demo1);

%catg(demographics_q21,Currently Receiving Treatment,demographics_q21_.,fisher,23,%str(where demographics_q21 ne .),demo1);
%catg(demographics_q22,Family member diagnosed with mental health,demographics_q22_.,fisher,24,%str(where demographics_q22 ne .),demo1);

%catg(demographics_q16_clean,Personal history of depression diagnosis  ,DEMOGRAPHICS_Q16_CLEAN_.,fisher,25,%str(where demographics_q16_clean ne .),demo1);
%catg(demographics_q11_binary,Multiple kids with diagnosis   ,DEMOGRAPHICS_Q11_BINARY_.,fisher,26,%str(where demographics_q11_binary ne .),demo1);
%catg(demographics_q13_clean,Partner in the home   ,DEMOGRAPHICS_Q13_CLEAN_.,fisher,27,%str(where demographics_q13_clean ne .),demo1);
%catg(demographics_q23_family,Family history of depression   ,DEMOGRAPHICS_Q23_FAMILY_.,fisher,28,%str(where demographics_q23_family ne .),demo1);
%catg(demographics_q23_partner,Partner history of depression   ,DEMOGRAPHICS_Q23_PARTNER_.,fisher,29,%str(where demographics_q23_partner ne .),demo1);
%catg(demographics_q06_binary,Child comorbidities     ,DEMOGRAPHICS_Q06_BINARY_.,fisher,30,%str(where demographics_q06_binary ne .),demo1);

%cont(demographics_q03_clean_n,%str(Child age in years   ),31,demo1);
%cont(demographics_q05_clean_n,%str(Child age at autism diagnosis in months),32,demo1);
%cont(demographics_q10_clean_n,%str(Number of children in the family ),33,demo1);
%cont(demographics_q11_clean_n,%str(Number of children with diagnosis  ),34,demo1);
%cont(demographics_12_clean_n,%str(Number of people in the household ),35,demo1);

%cont(phq_9_MEAN_score,%str(PHQ 9 MEAN Score),36,demo1);
%cont(fad_score,%str(FAD Score),37,demo1);
%cont(maternal_se_score,%str(Maternal SE Score),38,demo1);
%cont(irritability_score,%str(Irritability Score),39,demo1);
%cont(social_withdrwl_score,%str(Social Withdrwl Score),40,demo1);
%cont(Stereotypic_score,%str(Stereotypic Score),41,demo1);
%cont(hyperactivity_score,%str(Hyperactivity Score),42,demo1);
%cont(Speech_score,%str(Speech Score),43,demo1);
%cont(scq_yes_score,%str(SCQ Yes Score),44,demo1);
%cont(scq_no_score,%str(SCQ No Score),45,demo1);

%catg(depression,Depression,yesno.,fisher,46,%str(where depression ne .),demo1);
%catg(fad_function,Fad Function,fad_function_.,fisher,47,%str(where fad_function ne .),demo1);
%catg(autism,Autism,yesno.,fisher,48,%str(where autism ne .),demo1);


/*proc freq data=demo; */
/*tables trt ;*/
/*run;*/
  
proc print data=work.new; run;

*Preparing Table of summary stat;  
proc freq data=demo noprint; 
tables trt/out=trt;  
run;
data trt;
set trt  ;
by trt;
retain totall;
if _n_=1 then totall=COUNT;
else  totall+COUNT; 
run;

data _null_;
set trt;
select (trt);
when (1) call symput(strip("tot1"), strip(put(count,$4.)));
when (2) call symput(strip("tot2"), strip(put(count,$4.)));
when (3) 
	do;
		call symput(strip("tot3"), strip(put(count,$4.)));
  		call symput(strip("totall"), strip(put(totall,$4.))); 
	end;
otherwise;
end; 
run;

data new;
   set new;
   if _1=' '  then _1='0  (  0%) ';
run;

ods pdf file="Q:\STUDENT Stefanie Zavodny\Dissertation\documents\output\Table 1 Demographics &sysdate..pdf"  ;
proc report data=new nowd headskip;
column order varlab cat totstats _1 _2 _3 pvalue;
break after order/skip;
define order/order noprint;
define varlab/order width=32 left 'Variable';
define cat/display spacing=3 width=33 left' ';
define totstats/display spacing=3 width=12 left "All/(n=(&totall)";
/*3 treatments*/
define _1/display spacing=3 width=12 left "ADS/(n=&tot1)";
define _2/display spacing=3 width=12 left "DS /(n=&tot2)";
define _3/display spacing=3 width=12 left "TD /(n=&tot3)";
define pvalue/display spacing=4 width=10 left 'Pvalue[a]';
*title 'Table 2';
title3 'Table 1: Demographics';
compute after; 
endcomp;
run;
ods pdf close;


/*proc freq data=demo;*/
/*tables trt;*/
/*run;*/

