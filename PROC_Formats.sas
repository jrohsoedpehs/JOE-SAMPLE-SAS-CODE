libname RAW "Q:\Maureen George\Asma_Longitudinal_Study_2017\data\Raw";
/*libname redcap "Q:\Maureen George\Asma_Longitudinal_Study_2017\REDCap Downloads\archive20180323 DSMB Adverse Events SAS Export";*/
/*libname redcap1 "Q:\Maureen George\Asma_Longitudinal_Study_2017\REDCap Downloads\archive20180323 DSMB Demographics SAS Export";*/
footnote "SAS programs stored in Q:\Maureen George\Asma_Study_2016\DSMB\DSMB_2018_Spring\programs\Draft";
/*
options fmtsearch=(raw) will use only format which is named 
raw.formats by default
Equivalent to options fmtsearch=(raw.format)
*/
/*options fmtsearch=(raw);*/

/*
To use many formats (besides raw.formats) use the following
options fmtsearch=(raw.format1 raw.format2 ... raw.formatn)
*/
options fmtsearch=(raw.formats raw.formats_1);

/*Below is the syntax for REDCap's SAS data export at bottom of code*/
            /*CHANGE TO RAW*/
proc format library=raw.formats   cntlin=redcap.ae_formats;  
run; 
            /*CHANGE TO RAW*/
proc format library=raw.formats_1 cntlin=redcap1.formats_DEMO; 
run; 

/*ods rtf file="directory\title &sysdate..doc" style=journal;*/
/*code*/
/*ods rtf close;*/




libname test "directory";
/*Make a format permanent*/
proc format;
PROC FORMAT LIBRARY=test ; /*This saves the format directly to given path*/
   value yesno
   0 = "No"
   1 = "Yes";
   value sex_partners
   0 = "One partner"
   1 = "Multiple partners";
   value newrace
   1 = "African American"
   2 = "Caucasian"
   3 = "Native American"
   4 = "Asian/Pacific Islander"
   5 = "Other"
   6 = "Mixed";
run;


/*Assign formats to variables*/
data Derived.HPVinitiationAnalysis06152016; 
set stepup.HPVinitiationAnalysis;
if study_id in(1081, 1230) then PVQ1=.;
/*BS1Q10*/
if BS1Q10 in (0,9) then BS1Q10_b=0;
if BS1Q10=1 then BS1Q10_b=1;
/*BS1Q28 */
if BS1Q28 in (1,2) then BS1Q28_b=1;
if BS1Q28 in (3,4,5) then BS1Q28_b=0;
/*BS1Q35*/
if BS1Q35 in (0,1) then BS1Q35_b=0;
if BS1Q35 >= 2 then BS1Q35_b=1;
/*BS2Q35*/
if BS2Q35 =0 then BS2Q35_b=0;
if BS2Q35 >= 1 then BS2Q35_b=1;
/*new_race*/
if BS1Q3_1 =1 then new_race=1;
if BS1Q3_2 =1 then new_race=2;
if BS1Q3_3 =1 then new_race=3;
if BS1Q3_4 =1 then new_race=4;
if BS1Q3_5 =1 then new_race=5;
if sum(BS1Q3_1,BS1Q3_2,BS1Q3_3,BS1Q3_4,BS1Q3_5) >1 then new_race=6;
/*labels*/
label new_race = "What race do you consider yourself to be?";
label BS1Q10_b = "Did your mother finish high school?";
label BS1Q28_b = "Did you had your last well women's health visit/annual visit/GYN visit?";
label BS1Q35_b = "In the past 2 months, with how many different partners have you had vaginal sex?";
label BS2Q35_b = "In the past 2 months, did you smoke cigarettes?";
format BS1Q10_b BS1Q28_b BS2Q35_b yesno. BS1Q35_b sex_partners. new_race newrace.;
run;





/*save format to library*/
proc format library=work.formats cntlout = test.formats; 
run; 
proc format library=test.formats cntlin=test.formats; 
run; 


/*Use a format in library*/
options fmtsearch=(test);
