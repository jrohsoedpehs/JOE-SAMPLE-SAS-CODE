/*IMPORT COGSTATE DATA FROM THE LAB*/


/*LIBRARIES ARE CREATED IN cr01_setup_libraries.sas */
footnote "SAS Programs Stored in: https:/github.com/biostatistics-analysis-core-becca-lab/M2_DCC_COG_SAS-Programs";

 /*REDCap Formats*/
options fmtsearch=(&projectlib.i.UPenn_formats &projectlib.i.m2main_formats);
options nofmterr;

/*BASED ON TABLES FROM "Q:\Nalaka Gooneratne\Memories2\documents\project protocol\Cogstate Research - Cogstate Pediatric and Adult Normative Data - 22 June 2018[12779].docx"*/
/*IDN and DET use the REACTION TIME tables*/
/*OCL and ONB use the ACCURACY tables*/

proc format;
    value site_code_
        11 = "UP"
        12 = "UT"
        14 = "UV"
        15 = "WU"
        16 = "JU";

    value age_category_clean_
        1 = "35-49"
        2 = "55-59"
        3 = "60-69"
        4 = "70-79"
        5 = "80-89"
        6 = "90-99";

     value TCode_clean_
        1 = "IDN"
        2 = "DET"
        3 = "OCL"
        4 = "ONB";

	value age_years
		1  = "4"
		2  = "5"
		3  = "6"
		4  = "7"
		5  = "8"
		6  = "9"
		7  = "10"
		8  = "11"
		9  = "12"
		10 = "13"
		11 = "14"
		12 = "15"
		13 = "16"
		14 = "17"
		15 = "18-34"
		16 = "35-49"
		17 = "50-59"
		18 = "60-69"
		19 = "70-79"
		20 = "80-89"
		21 = "90-99";
run;  

/*IMPORT COGSTATE Data*/
proc import datafile="&path/COGSTATE/Raw Data/Cogstate Full Data Extract 7-2-19.xlsx"
    DBMS=xlsx
    out=cogi.cogstate_data replace;
    SHEET="Sheet1";
run;

/*CHECK THAT THE DATASET IS NOT EMPTY*/
proc contents data=cogi.cogstate_data_new varnum; 
run;
proc print data=cogi.cogstate_data(obs=30);
run;

proc print data=cogi.cogstate_data; *(obs=5);
    where SubjID = "1500546";
    format TTime;
run;

/*TROUBLESHOOT*/
proc sort data=cogi.cogstate_data;
    by SubjID  TCode;
run;

data cogi.cogstate_data_new;
    set cogi.cogstate_data;
    retain visit_num;
        if first.TCode then visit_num = 1;
	    else visit_num = visit_num + 1;
        by SubjID  TCode;

	if visit_num = 1 then redcap_event_name = "visit_2_baseline_m_arm_1";
	if visit_num = 2 then redcap_event_name = "visit_5_6_month_me_arm_1";
	if visit_num = 3 then redcap_event_name = "visit_6_12_month_m_arm_1";

    subject_id=SubjID;
    if subject_id in ("test", "test12-00211", "test3") then delete;
    if subject_id = "1500546" and TTime = 49331 then delete;
run;

/*QA*/
proc sort data=cogi.cogstate_data_new;
    by subject_id TDate TCode;
run;

proc print data=cogi.cogstate_data_new (obs = 20);
var subject_id TDate TCode visit_num redcap_event_name;
run;


/*CHECK FOR DUPLICATES*/
proc sort data=cogi.cogstate_data_new  ;
    by subject_id TDate TCode;
run;
data duplicates;
    set cogi.cogstate_data_new ;
        by subject_id TDate TCode;
        if first.TCode ne last.TCode or first.TCode= 0 and last.TCode=0;
run;

ods Excel file="&path/COGSTATE/Output/COGSTATE DUPLICATES &sysdate..xlsx" ;
ods Excel OPTIONS(SHEET_INTERVAL="none" SHEET_NAME="COGSTATE DUPLICATES" EMBEDDED_TITLES="yes");
title "COGSTATE DUPLICATES by subject_id TDate and TCode";
proc print data= duplicates noobs;
run;
ods Excel close;


/*MISSING DATA lmn lsd acc cor and err */
ods Excel file="&path/COGSTATE/Output/COGSTATE where lmn lsd acc cor and err are missing  &sysdate..xlsx" ;
ods Excel OPTIONS(SHEET_INTERVAL="none" SHEET_NAME="MISSING DATA" EMBEDDED_TITLES="yes");
proc print data= cogi.cogstate_data_new;
    where missing(lmn) and missing(lsd) and missing(acc) and missing(cor) and missing(err);
    title "COGSTATE where lmn lsd acc cor and err are missing ";
run;
ods Excel close;


/*SUMMARY STATS*/
proc contents data=cogi.cogstate_data_new varnum; run;
proc print data=cogi.cogstate_data_new (obs=5); run;


/*proc means*/
proc means data=cogi.cogstate_data_new n nmiss mean std min max maxdec=2;run;

/*proc freq*/
proc freq data=cogi.cogstate_data_new ;
    tables  Hand  Sex Sessn TCode cfo protocolId /list missing;
run;


/*Missing data*/
%macro missing_data(var);
proc print data=cogi.cogstate_data_new ;
    where missing(&var );
    var SubjID TDate TCode &var;
    run;
quit;
%mend;


ods Excel file="&path/COGSTATE/Output/COGSTATE Missing Data on all fields &sysdate..xlsx" ;
ods Excel OPTIONS(SHEET_INTERVAL="none" SHEET_NAME="Missing Data" EMBEDDED_TITLES="yes");
/*title "COGSTATE Missing Data on all fields";*/
proc means data=cogi.cogstate_data_new  maxdec=2 n nmiss min max mean std;
var TDate TTime GMLidx mps dur ter ler rer per lmn lsd acc cor err presnt cmv rth sti res;
run;

proc means data=cogi.cogstate_data_new  maxdec=2 n nmiss min max mean std;
class TCode;
var TDate TTime GMLidx mps dur ter ler rer per lmn lsd acc cor err presnt cmv rth sti res;
run;
ods Excel close;

