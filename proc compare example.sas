libname raw "Q:\Maureen George\Asma_Study_2016\DSMB\SMC_2019_Spring\data\Raw";
libname derived "Q:\Maureen George\Asma_Study_2016\DSMB\SMC_2019_Spring\data\Derived";
footnote "SAS program stored: Q:\Maureen George\Asma_Study_2016\DSMB\SMC_2019_Spring\programs\draft\proc_compare.sas";

/*FORMATS*/
options fmtsearch=(Raw.AE_formats Raw.asthma_formats Raw.daily_formats Raw.pcp_formats); 
options nofmterr;

proc format;
    value race 
        1='African American'
        2='Caucasian' 
        3='Asian' 
        4='American Indian/Alaska Native' 
        5='Native Hawaiian/Pacific Islander' 
        6='Multiracial or Other';
    value yesno 
        1='Yes' 
        0='No';
    value ethnicity
        1='Hispanic'
        0='Non-Hispanic';
    value newsite
        1="Spectrum"
        2="GPHA";
run;   
/***************************************
Do not use proc compare to compare free text fields

The REDCap datasets were exported omitting all free text fields


Comparing datasets has 3 steps
1. Remove duplicate data
2. compare data (ids that are in both datasets only) of fields that have mismatch values by id
3. check for ids that are in one dataset but are omitted in the other
***************************************/

/*Dates use up too much space*/
/*Use proc sql on date format to quickly group and drop all dates*/

/*Check that dates have correct format*/
proc contents data=raw.asthma_2017;run;
proc contents data=raw.asthma_2017_DDE;run;
/*Dates have format YYMMDD10.*/

/*Create a Macro variable xxx that represents a group of date variables using SQL SELECT*/
proc contents data=raw.asthma_2017 varnum out=cont_out noprint;run;
/*QA - exploit YYMMDD under format*/
proc print data = cont_out;run;

/*LOOK FOR FIELDS TO EXPLOIT IN cont_out*/
/*proc contents data = cont_out varnum;run;*/
/*proc print data = cont_out;run;*/
/*NUM VARIABLES*/
proc sql noprint;   
    select name   
    into : dates   
    separated by ' '   
    from cont_out   
    where type = 1 and
    format in ('YYMMDD'); 
/*	char type=2*/
/*	num  type=1*/
/*	ANY VARIATION OF BEST IS THE DEFAULT NUM FORMAT*/
quit; 
/*VIEW VARIABLES IN &numlist*/
%put &dates;





/*Proc Compare begins here*/

/*datasets*/
/*raw.asthma_2017*/
/*raw.asthma_2017_DDE*/


/*PREPARE DATASETS FOR COMPARE*/

/*CHECK FOR DUPLICATES	*/
/*DUPOUT SHOWS duplicates ids*/
/*OUT SHOWS the 1st unique id for each, respectively*/
proc sort data=raw.asthma_2017 dupout=temp4 nodupkey out=temp1; 
	by record_id redcap_event_name;
run;
proc sort data= raw.asthma_2017_DDE dupout=temp6 nodupkey out=temp5; 
	by record_id redcap_event_name; 
run;

/*check duplicate ids to see if all data is a duplicate or if the row is distinct*/
title "asthma_2017 dups";
proc print data = temp4;run;

title "asthma_2017_DDE dups";
proc print data = temp6;run;


/*continue after there are no duplicates*/
proc sort data=raw.asthma_2017; 
	by record_id redcap_event_name;
run;
proc sort data= raw.asthma_2017_DDE; 
	by record_id redcap_event_name; 
run;


proc contents data = raw.asthma_2017;run;
/*QA*/
proc print data = raw.asthma_2017;
where record_id= "021004" and redcap_event_name = "baseline_arm_1";
var record_id redcap_event_name forget_take;
run;
proc print data = raw.asthma_2017_DDE;
where record_id= "021004" and redcap_event_name = "baseline_arm_1";
var record_id redcap_event_name forget_take;
run;

data asthma_2017;
set raw.asthma_2017;
event = redcap_event_name;
run;
proc freq data = asthma_2017;
tables event * redcap_event_name /list missing;
run;

proc contents data= raw.asthma_2017;
run;
/*Proc Compare*/

/*EXCEL FILE*/
ods Excel file="Q:\Maureen George\Asma_Study_2016\DSMB\SMC_2019_Spring\documents\output\Proc Compare &sysdate..xlsx" ;
ods Excel OPTIONS(SHEET_INTERVAL="proc" SHEET_NAME="Proc compare");

/* Dates to drop*/
%Let dates= date aqlqsdate csq_date date_acq date_consent_obtained meh_date meh_eradmindate1 meh_eradmindate2 meh_eradmindate3 meh_eradmindate4 
meh_eradmindate5 meh_erdischargedate1 meh_erdischargedate2 meh_erdischargedate3 meh_erdischargedate4 meh_erdischargedate5 meh_hospadmindate2 meh_hospadmindate3 
meh_hospadmindate4 meh_hospadmindate5 meh_hospdischargedate1 meh_hospdischargedate2 meh_hospdischargedate3 meh_hospdischargedate4 meh_hospdischargedate5 meh_otherstarted 
meh_prednisoneended meh_prednisonestarted meh_medrolended meh_medrolstarted pdba_date form_cmpd_dt;

/* "Complete?" Drop*/
%Let complete= aqlqs_complete asthma_control_quest_v_3 asthma_history_complete conventional_and_alt_v_1 csq8_complete demographics_complete aqlqs_complete asthma_history_complete conventional_and_alt_v_1
csq8_complete demographics_complete fev1_complete med_change_er_hospit_v_4 medication_adherence_v_2 newest_vital_sign_complete patient_debriefing_a_v_0 promis29_complete 
ra_blinding_assessme_v_5 sdmq9_complete ;


title "Differences Between Two Data Sets";
proc compare base=raw.asthma_2017 (drop = &dates &complete)
compare=raw.asthma_2017_DDE (drop = &dates &complete) nosummary outnoequal maxprint=32000;  
ID record_id redcap_event_name ;
run;

ods Excel close;
/*EXCEL FILE PROC COMPARE FOR TABLE 1*/
ods Excel file="Q:\Maureen George\Asma_Study_2016\DSMB\SMC_2019_Spring\documents\output\Proc Compare for Table 1 &sysdate..xlsx" ;
ods Excel OPTIONS(SHEET_INTERVAL="proc" SHEET_NAME="Proc compare");

title "Differences Between Two Data Sets";
proc compare base=raw.asthma_2017 (keep = record_id redcap_event_name Age demscreen_acqscore site sex race___1 race___2 race___3 race___4 race___5 ethnicity smoke insurance education marital) compare=raw.asthma_2017_DDE (keep = record_id redcap_event_name Age demscreen_acqscore site sex race___1 race___2 race___3 race___4 race___5 ethnicity smoke insurance education marital) nosummary outnoequal maxprint=32000;  
ID record_id redcap_event_name ;
run;
ods Excel close;


/*Check for data that is in one set but not the other*/
/*d = 1 if the data is in raw.asthma_2017_DDE but missing from raw.asthma_2017 and vice versa*/
data injnotd indnotj;
	merge raw.asthma_2017_DDE(in=d) raw.asthma_2017(in=j); 
  	by record_id redcap_event_name;
	if d = 1 and j ne 1 then output indnotj;
	if j = 1 and d ne 1 then output injnotd;
run;

/*RTF FILE*/
%macro rtf(title, dsn);
ods rtf file="Q:\Maureen George\Asma_Study_2016\DSMB\SMC_2019_Spring\documents\output\&title &sysdate..doc" ;
proc print data=&dsn noobs;
    var record_id redcap_event_name;
    title "&title";
run;
ods rtf close;
%mend;
%rtf(In asthma_2017_DDE and missing from asthma_2017, indnotj);
%rtf(In asthma_2017 and missing from asthma_2017_DDE, injnotd);

/*/*Create RTF for each proc seperately*/*/
/*ods rtf file="directory\title &sysdate..doc" style=journal;*/
/*/*code*/*/
/*ods rtf close;*/




/*CREATES RTF OF DATA THAT IS IN ONE SET BUT MISSING IN THE OTHER*/
/*proc print data=indnotj noobs;*/
/*    var record_id redcap_event_name;*/
/*    title 'This data is in raw.asthma_2017_DDE and missing from raw.asthma_2017';*/
/*run;*/
/*proc print noobs data=injnotd;*/
/*    var record_id redcap_event_name;*/
/*    title 'This data is in raw.asthma_2017 and missing from raw.asthma_2017_DDE';*/
/*run;*/


