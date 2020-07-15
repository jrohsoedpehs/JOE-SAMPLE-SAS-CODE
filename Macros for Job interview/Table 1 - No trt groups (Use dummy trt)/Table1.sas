libname raw "Q:\Amy Lisanti\SkintoSkinCare\data\Raw";
libname derived "Q:\Amy Lisanti\SkintoSkinCare\data\Derived";
footnote "SAS program stored: Q:\Amy Lisanti\SkintoSkinCare\programs\Draft\Table1.sas";

options fmtsearch=(raw.upenn_formats raw.m2main_formats);
options nofmterr;

proc format;
value yesno
1="Yes"
0="No";
run;

/*Please create a rough proc freq on prescription med and non prescription med for derived.adrd_m2main*/

proc contents data= derived.skin_to_skin_care;run;
/*Limit data to consented participants - see makeData.sas*/
/*create trt*/
data demo;
	set derived.skin_to_skin_care;
	obs = _n_;
	trt= 1 + (obs > 9);
	where redcap_event_name="intervention_1_pre_arm_1";
run;

proc freq data= demo;
tables trt;
run;

proc contents data=demo varnum;
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

%include "Q:\Amy Lisanti\SkintoSkinCare\programs\Draft\macro_table1.sas";

/*Template for continous vars*/
/*%cont(motherage_mpre_pre1,%str(Age,years), 1,demo1);*/
/*Template for categorical vars*/
/*%catg(ml_hlth_hx_mpre_pre1___1, Anxiety,yesno.,fisher,9,%str(where ml_hlth_hx_mpre_pre1___1  ne .),demo1);*/

/*TABLE 1 MACRO CALLS*/
%cont(motherage_mpre_pre1,%str(Mother age in years), 1,demo1);
%catg(maritalstatus_mpre_pre1,Marital Status,maritalstatus_mpre_pre1_.,fisher,2,%str(where maritalstatus_mpre_pre1 ne .),demo1);
%catg(motherrace_mpre_pre1,Race of Mother,motherrace_mpre_pre1_.,fisher,3,%str(where motherrace_mpre_pre1 ne .),demo1);
%catg(motherethnicity_mpre_pre1,Ethnicity,motherethnicity_mpre_pre1_.,fisher,4,%str(where motherethnicity_mpre_pre1 ne .),demo1);
%catg(mothereducation_mpre_pre1,Level of education,mothereducation_mpre_pre1_.,fisher,5,%str(where mothereducation_mpre_pre1 ne .),demo1);
%cont(annual_household_income_mpre_pre1,%str(Annual Household Income),6,demo1);
%cont(numchildhouse_mpre_pre1,%str(Number of children in household (including your baby in the intensive care unit)),7,demo1);
%cont(age05yrs_mpre_pre1,%str(Number of children in age category 0-5 yrs),8,demo1);
%cont(age610yrs_mpre_pre1,%str(Number of children in age category 6-10 yrs),9,demo1);
%cont(agemore20yrs_mpre_pre1,%str(Number of children in age category > 20 yrs),10,demo1);
%catg(congenital_diagnosis_mpre_pre1,When was your baby diagnosed with congenital heart defect?,CONGENITAL_DIAGNOSIS_MPRE_PRE1_.,fisher,11,%str(where congenital_diagnosis_mpre_pre1 ne .),demo1);
%catg(congenital_prenatal_mpre_pre1,If so how many weeks was the diagnosis?,congenital_prenatal_mpre_pre1_.,fisher,12,%str(where congenital_prenatal_mpre_pre1 ne .),demo1);
%catg(ml_hlth_hx_mpre_pre1___1, Anxiety,yesno.,fisher,13,%str(where ml_hlth_hx_mpre_pre1___1  ne .),demo1);
%catg(ml_hlth_hx_mpre_pre1___2, Depression,yesno.,fisher,14,%str(where ml_hlth_hx_mpre_pre1___2  ne .),demo1);
%catg(ml_hlth_hx_mpre_pre1___3, Other,yesno.,fisher,15,%str(where ml_hlth_hx_mpre_pre1___3  ne .),demo1);
%catg(ml_hlth_hx_mpre_pre1___99, None,yesno.,fisher,16,%str(where ml_hlth_hx_mpre_pre1___99  ne .),demo1);

proc freq data= demo1;
where redcap_event_name="intervention_1_pre_arm_1";
tables trt*congenital_diagnosis_mpre_pre1 ;
run;

proc contents data=demo1;run;

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
ods rtf file= "Q:\Amy Lisanti\SkintoSkinCare\documents\output\open_report_table_1 &sysdate..doc" style=journal;
*options orientation=landscape topmargin=0.5in bottommargin=0.5in rightmargin=0.5in leftmargin=0.5in;
proc report data=new nowd headskip;
	column order varlab cat totstats ;
	break after order/skip;
	define order/order noprint;
	define varlab/order width=50 flow left 'Variable';
	define cat/display spacing=1 width=33 left' ';
	define totstats/display spacing=3 width=30 left "Total/(n=&totall)";  
	title 'Open Report';
	title2 'Table 1';			
	title3 'Over all Baseline Characteristics ';
run;
ods rtf close;

/*Made up TRT TO RUN MACRO DON'T SEND TO AMY*/
/*ods rtf file= "Q:\Amy Lisanti\SkintoSkinCare\documents\output\output\close_report_table   &sysdate..doc" style=journal;*/
/*options orientation=landscape topmargin=0.5in bottommargin=0.5in rightmargin=0.5in leftmargin=0.5in;*/
/**/
/*proc report data=new nowd headskip;*/
/*column order varlab cat totstats _1 _2 pvalue;*/
/*break after order/skip;*/
/*define order/order noprint;*/
/*define varlab/order width=55 flow left 'Variable';*/
/*define cat/display spacing=1 width=33 left' ';*/
/*define totstats/display spacing=3 width=30 left "Total/(n=&totall)";*/
/*define _1/display spacing=1 width=30 left "Control/(n=&tot1)";*/
/*define _2/display spacing=1 width=30 left "Sleep Apnea/(n=&tot2)";*/
/**define _3/display spacing=1 width=30 left "Group C/(n=&tot3)";*/
/*define pvalue/display spacing=1 width=30 left 'Pvalue';*/
/*title 'Table 1';			*/
/*title3 'Baseline Characteristics ';*/
/*/*compute after; */*/
/*/*line @1 "Numbers indicate the median (continuous variables) or percentage (categorical variables).Numbers in parentheses indicate the interquartile range. FG=Fasting Glucose;";*/*/
/*/*line @2 "type-2 diabetes= type 2 diabetes mellitus. Pairwise comparisons: * IFG vs. normal FG.† type-2 diabetes vs. normal FG. ‡ type-2 diabetes vs. IFG."; */*/
/*/*line @3 "§ Statistical comparisons of cardiac output, stroke volume and SVR are adjusted for BSA."; */*/
/*/*endcomp;*/*/
/*run;*/
/*ods rtf close;*/
/**/
