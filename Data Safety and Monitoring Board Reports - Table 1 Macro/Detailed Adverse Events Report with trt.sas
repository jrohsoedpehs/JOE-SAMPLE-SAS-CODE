/*DETAILED AE REPORT FOR DSMB*/


libname raw "path";
libname derived "path";

footnote "SAS Program stored in: path";

/*FORMATS */
options fmtsearch=(raw.ae_formats raw.ae_online_formats); 
options nofmterr;

proc format;
    value trt 1 = "A" 2 = "B";
    value count_ 0 = "0" 1 = "1" 2 = "More than 1";
run;


/*GET VARIABLEs FOR ID AND PATIENT*/
proc contents data=derived.Adverse_events_trt varnum; run;
/*ID IS dyad_id*/
/*ae_status TRACKS PATIENT/CAREGIVER*/

/*GET CODE FOR PATIENT*/
proc freq data=derived.Adverse_events_trt;
tables ae_status;
run;
proc freq data=derived.Adverse_events_trt;
tables ae_status;
format ae_status;
run;
/*0=PATIENT*/
/*1=CAREGIVER*/


/*LIMIT DATA TO PATIENTS*/
/*EXPECT 21 AES*/
/*derived.Adverse_events_trt created in "path"*/
/*CREATE FLAG FOR AE*/
data work.patient_ae;
set derived.Adverse_events_trt;
where ae_status=0;
if ae_event ne . then ae_flag=1;
if ae_event = . then ae_flag=0;
run;
/*QA PATIENTS ONLY*/
proc freq data=work.patient_ae;
tables ae_status ;
run;
proc freq data=work.patient_ae;
tables ae_event*ae_flag/list missing;
run;


/*OUTPUT*/
ods rtf file =  "path\Adverse Events Summary by trt &sysdate..doc" style=journal;


/*SORT DATA BY dyad_id AND trt TO PREPARE FOR PROC MEANS*/
proc sort data=work.patient_ae; by dyad_id trt; run;

/*OUTPUT THE MAX AND SUM/TOTAL NUMBER OF SEVERAL AE VARIABLES*/
proc means data=work.patient_ae noprint;
by dyad_id trt;
var ae_flag ae_grade;
output out=o 
sum=tot_ae tot_ae_grade
max=ae_event ae_grade;
run;

/*Table 1. Average number of AE per patient compared between the two treatment groups*/
proc means data=o n min median max mean std maxdec=2;
class trt;
var tot_ae;
title "Table 1. Average number of AE per patient compared between the two treatment groups";
format trt trt.;
run;
title;


/*Figure 1. Distribution of patient level number of AE's across the two treatment groups*/
proc npar1way data=o anova wilcoxon;
class trt;
var tot_ae;
title "Figure 1. Distribution of patient level number of AE's across the two treatment groups";
format trt trt.;
run;
title;


/*Categorize number of AEs*/
data ae_cat;
    set o;
    if tot_ae = 0 then tot_ae_cat = 0;
        else if tot_ae = 1 then tot_ae_cat = 1;
        else tot_ae_cat = 2;
    format tot_ae_cat count_. trt trt.;
run;

/*QA*/
proc freq data=ae_cat;
    table tot_ae*tot_ae_cat / missing;
run;

/*Percentage of AEs across treatment group (3 categories: 0, 1, >1)*/
proc freq data=ae_cat;
    table trt*(tot_ae_cat) / nopercent nocol chisq fisher;
run;

/*Percentage of AEs across treatment groups (2 categories: yes or no)*/
proc freq data = ae_cat;
    tables trt*(tot_ae_cat) / nopercent nocol chisq fisher relrisk ;
/*  format yesno.;*/
run;

/*proc freq data = ae_cat;*/
/*  tables trt*(tot_resp_cat) / nopercent nocol chisq fisher relrisk ;*/
/*  table tot_resp*tot_resp_cat / list missing;*/
/*  format death kidney liver CV resp GI infection ICU thrombocytopenia delirium neurologic yesno.;*/
/*run;*/


/*WHAT ARE THE LABELS FOR AE*/
/*proc contents data= work.patient_ae;run;*/

/*PLEASE NOTE THAT 4004 AND 4005 HAVE ADVERSE EVENTS BUT ARE NOT RANDOMIZED AS OF THE FREEZE DATE*/


/*Table 2. Percentage of serious AEs across the two treatmet groups*/
/*Table 3. Percentage of Expected AE across the two treatment groups*/
/*proc freq data = work.patient_ae;*/
/*  tables trt*serious / nopercent nocol chisq;*/
/*  label organ = "Organ System";*/
/*    title "Table 2. Percentage of serious AEs across the two treatmet groups";*/
/*run;*/
/*title;*/


/*proc freq data = work.patient_ae;*/
/*  tables trt*expected / nopercent nocol chisq;*/
/*  label organ = "Organ System";*/
/*    title "Table 3. Percentage of Expected AE across the two treatment groups";*/
/*run;*/
/*title;*/


ods rtf close;
