libname raw "dir\data\Raw";
libname derived "dir\data\Derived";

footnote "SAS Program Stored in: dir\programs\Draft\missing data reports call execute.sas";

/*SAVE THE SAS LOG TO THE FOLLOWING TEXT FILE*/
/*filename test 'Q:\Barbara Riegel\Caregiver_RO1_2019\documents\output\icare4me_missing Log &sysdate..log';*/
/*proc printto log=test new;*/
/*run;*/

/*Log with macro debugging options turned on */
/*options mprint mlogic symbolgen; */


/*FORMATS*/
options fmtsearch=(raw.iCare4me_formats);
options nofmterr;
/*raw.iCare4me*/
/*raw.iCare4me_formats*/

/*Preview Data*/
proc contents data=raw.iCare4me varnum; run;
proc print data= raw.iCare4me (obs=5) label noobs; run;

/*GOAL REPEAT THE FOLLOWING PROC PRINT FOR ALL VARIABLES IN THE MAIN SURVEY*/
proc print data= raw.iCare4me label noobs;
    where dyad_id = "10001" and missing(cg_eligibility_screener) /*and adverse_events_complete not in (. , 0)*/;
    var dyad_id redcap_event_name redcap_repeat_instrument redcap_repeat_instance cg_eligibility_screener;
/*    title1 "10001";*/
/*    title2 "Screening";*/
/*    title3 "cg_eligibility_screener";*/
run;

/*VARS, LOGIC AND TITLES*/
/*data macro_variables;*/
/*    length variable$100 logic$300 title$100;*/
/*    infile datalines delimiter='|';*/
/*    input variable$ logic$ title$;*/
/*    datalines;*/
/*excel_sheet | excel_sheet | excel_sheet */
/*ae_category | %str( and adverse_events_complete not in (. , 0)) | Adverse Events*/
/*ae_detail | %str( and adverse_events_complete not in (. , 0)) | Adverse Events*/
/*ae_date_site_notified | %str( and adverse_events_complete not in (. , 0)) | Adverse Events*/
/*ae_start_date_time | %str( and adverse_events_complete not in (. , 0)) | Adverse Events*/
/*ae_stop_date_time | %str( and adverse_events_complete not in (. , 0)) | Adverse Events*/
/*ae_severity | %str( and adverse_events_complete not in (. , 0)) | Adverse Events*/
/*ae_relation_to_study | %str( and adverse_events_complete not in (. , 0)) | Adverse Events*/
/*ae_expected | %str( and adverse_events_complete not in (. , 0)) | Adverse Events*/
/*ae_serious | %str( and adverse_events_complete not in (. , 0)) | Adverse Events*/
/*adverse_events_complete | %str( and adverse_events_complete not in (. , 0)) | Adverse Events*/
;
/*CHECK THAT THE DATASET HAS 3 FIELDS*/
/*proc contents data= macro_variables; run;*/
/*proc print data=macro_variables; run;*/




/*NEWLINE CHARACTERS (IN FREE TEXT) ARE TREATED AS DELIMITERS FOR SAS IMPORT*/
/*SINCE THE DATA IS ALREADY COMMA DELIMITED, THIS WILL BREAK THE IMPORT*/
/*REPLACE NEWLINE CHARACTERS WITH SPACES*/

/*THIS WILL OVERWRITE THE CSV*/
/*CREATE A COPY OF THE CSV IF IT IS DIFFICULT TO OBTAIN*/

/*OPEN THE CSV, READ EACH CHARACTER LINE BY LINE AND REPLACE/OVERWRITE NEWLINE CHARACTERS WITH A SPACE*/
/*CLOSE CSV WHEN THERE ARE NO MORE CHARACTERS*/
/*INFILE MUST MATCH FILE IN DATASTEP*/
/*'0A'x, '13'x and '0D'x - ARE SYNTAX FOR ASCII newline (carriage return) characters*/
data _null_;
/*OVERWRITE EXCEL FILE*/
    infile "Q:\Barbara Riegel\Caregiver_RO1_2019\REDCap Downloads\archive20210728 test new missing data report\ICare4Me_DataDictionary_2021-07-28.csv" recfm=n sharebuffers;
    file "Q:\Barbara Riegel\Caregiver_RO1_2019\REDCap Downloads\archive20210728 test new missing data report\ICare4Me_DataDictionary_2021-07-28.csv" recfm=n;
/*OPEN THE CSV, READ EACH CHARACTER LINE BY LINE*/
    input a $char1.;
    retain open 0;
/*CLOSE CSV WHEN THERE ARE NO MORE CHARACTERS*/
    if a='"' then open=not open;
/*REPLACE/OVERWRITE NEWLINE CHARACTERS (ASCII) WITH A SPACE*/
    if a in ('0D'x '13'x '0A'x) and open then put ' ';
run;


/*IMPORT AE DATA DICTIONARY*/
/*https://redcap.nursing.upenn.edu/redcap_v11.1.1/Design/data_dictionary_upload.php?pid=1501*/
PROC IMPORT OUT= raw.icare4me_dictionary
            DATAFILE= "Q:\Barbara Riegel\Caregiver_RO1_2019\REDCap Downloads\archive20210728 test new missing data report\ICare4Me_DataDictionary_2021-07-28.csv"
            DBMS=CSV REPLACE;
     GUESSINGROWS = 900; /*avoids truncation by checking x rows for format vs default 20*/
     GETNAMES=no

;
     DATAROW=1; /*read data starting at row 2*/
RUN;

proc contents data=raw.icare4me_dictionary varnum; run;
proc print data=raw.icare4me_dictionary (obs=20); run;

data work.dictionary;
    set raw.icare4me_dictionary 
    (keep=VAR1 
          VAR2 
          VAR4 
          VAR8
          VAR12
    );
    where (VAR4 = "text" and VAR8 ne "")
        or VAR4 in("yesno","radio","file","dropdown", "Field Type")
/*        and Field_Type notin("descriptive", "notes")*/
    ;

    if VAR12 ne "" then 
    do;
/*    REPLACE DUPLICATE SPACES WITH EXACTLY ONE SPACE*/
/*    WE NEED LEADING AND TRAILING SPACES */
/*    DO NOT TRIM*/
        branching_logic_clean = compbl(VAR12);
        branching_logic_clean = TRANWRD(branching_logic_clean,"[datetime_seconds1] = [datetime_seconds1]","");
        branching_logic_clean = TRANWRD(branching_logic_clean,"[datetime_seconds1]=[datetime_seconds1]","");
        branching_logic_clean = TRANWRD(branching_logic_clean,"[datetime_seconds]=[datetime_seconds]","");
        branching_logic_clean = TRANWRD(branching_logic_clean,"[datetime_seconds] = [datetime_seconds]","");
        branching_logic_clean = TRANWRD(branching_logic_clean,"]["," and ");
        branching_logic_clean = TRANWRD(branching_logic_clean,"]","");
        branching_logic_clean = TRANWRD(branching_logic_clean,"[","");
        branching_logic_clean = TRANWRD(branching_logic_clean,"""","");
        branching_logic_clean = TRANWRD(branching_logic_clean,"'","");
        branching_logic_clean = TRANWRD(branching_logic_clean, "<>"," ne . ");
        branching_logic_clean = TRANWRD(branching_logic_clean, "<>"," ne . ");
        branching_logic_clean = TRANWRD(branching_logic_clean, "baseline_arm_1","redcap_event_name='baseline_arm_1'");
        branching_logic_clean = TRANWRD(branching_logic_clean, "1_month_arm_1","redcap_event_name='1_month_arm_1'");
        branching_logic_clean = TRANWRD(branching_logic_clean, "3_month_arm_1","redcap_event_name='3_month_arm_1'");
        branching_logic_clean = TRANWRD(branching_logic_clean, "6_month_arm_1","redcap_event_name='6_month_arm_1'");
        branching_logic_clean = TRANWRD(branching_logic_clean, "9_month_arm_1","redcap_event_name='9_month_arm_1'");
        branching_logic_clean = TRANWRD(branching_logic_clean, "12_month_arm_1","redcap_event_name='12_month_arm_1'");
    end;

    /*    HARDCODE CASES*/
    if branching_logic_clean="acetyl-l-carnitine | 7" then delete;
run;

/*QA branching_logic_clean*/
/*QA FOLLOWING CHARACTERS ARE STRIPPED FROM branching_logic_clean*/
/*[   ] "" '*/
/*[visit][datetime_seconds]=[datetime_seconds] is replaced with redcap_event_name="visit"*/
proc freq data=work.dictionary;
    tables branching_logic_clean * VAR12 / list missing;
run;
/*proc contents data= work.dictionary; run;*/

/*QA FIELD TYPES ARE "text" "yesno","radio","checkbox","file","dropdown"*/
proc freq data=work.dictionary;
    tables VAR4;
run;


proc print data=work.dictionary ;
run;









/*GENERATES A LIST OF ALL dyad_ids*/
proc sql /*noprint*/;
select distinct dyad_id
into :name_list separated by " " from raw.iCare4me;
quit;
/*VIEW THE LIST IN THE LOG*/
%put &name_list;
/*10001 10002 10003 10004 10005 10006 10007 10008 10009 10010 10011 10012 10013 10014 10015 10016 10017*/
/*10018 10019 10020 10021 10022 10023 10024 10025 10026 10027 10028 10029 10030 10031 10032 10033 10034*/
/*10035 10036 10037 10038 10039 10040 10041 10042 10043 10046 10047 10048 10049 10050 10051 10052 10053*/
/*10054 10055 10056 10057 10058 10059 10061 10062 10064 10065 10066 10067 10068 10069 10070 10071 10072*/
/*10073 10074 10077 10078 10079 10080 10081 10082 10083 10086 10087 10088 10090 10091 20001 20002 20003*/
/*20004 20005 20007 20008 20009 20010 20011 20012 20015 30001 30002 30003 30005 30006 40001 40002 40003*/
/*40004 40005 40006 40008 40009 80283*/



/*IDS*/
data IDS;
    length dyad_id$100;
    infile datalines delimiter='|';
    input dyad_id$;
    datalines;  
10001
10002
10003
10004
10005
10006
10007
10008
10009
10010
10011
10012
10013
10014
10015
10016
10017
10018
10019
10020
10021
10022
10023
10024
10025
10026
10027
10028
10029
10030
10031
10032
10033
10034
10035
10036
10037
10038
10039
10040
10041
10042
10043
10046
10047
10048
10049
10050
10051
10052
10053
10054
10055
10056
10057
10058
10059
10061
10062
10064
10065
10066
10067
10068
10069
10070
10071
10072
10073
10074
10077
10078
10079
10080
10081
10082
10083
10086
10087
10088
10090
10091
20001
20002
20003
20004
20005
20007
20008
20009
20010
20011
20012
20015
30001
30002
30003
30005
30006
40001
40002
40003
40004
40005
40006
40008
40009
80283
;
run;
proc contents data= IDS; run;
/*proc print data=IDS; run;*/


/*CARTESIAN PRODUCT BETWEEN IDS AND VARIABLES*/
/*N*M OBS*/
/*10 OBS * 3 OBS = 30 OBS TOTAL*/

/*proc sql;*/
/*   create table CartSQL as*/
/*   select test1.*,*/
/*          test2.var2*/
/*   from test1, test2;*/
/*quit;*/
/**/
/*data CartDataStep;*/
/*   set test1;*/
/*   do i=1 to n;*/
/*      set test2 point=i nobs=n;*/
/*      output;*/
/*   end;*/
/*run;*/


data CartDataStep;
/*   set work.macro_variables;*/
   set work.dictionary;
   do i=1 to n;
      set work.IDS point=i nobs=n;
      output;
   end;
run;
proc contents data= work.CartDataStep; run;
proc print data=work.CartDataStep;run;

/*SORT BY dyad_id*/
proc sort data=work.CartDataStep;
    by dyad_id;
run;


proc contents data=raw.iCare4me varnum; run;
%macro missing(ID, variable, logic, title);

data id_i;
    set raw.iCare4me ;
    where dyad_id = "&ID" ;
run;

proc print data= id_i label noobs;
    where missing(&variable) &logic;
    var dyad_id redcap_event_name redcap_repeat_instrument redcap_repeat_instance &variable;
    title1 "&ID";
    title2 "&title";
    title3 "&variable";
run;

%mend;

/*QA missing() on R-001*/
%missing(10001, cg_eligibility_screener, %str( and redcap_event_name='baseline_arm_1'), screening);


/*CREATE EXCEL FILE*/
/*ods Excel file="dir\documents\output\ Adverse Events Missing Data Report &sysdate..xlsx" ;*/

/*MISSING REPORT R-001*/
/*data _null_;*/
data work.temp;
    length macro_call $600;
    set work.CartDataStep;
    where dyad_id in('10001' '10002' '10003');
/*    macro_call = catx( '%sample(', var1, ',' var2, ')' );*/
    if VAR12 = "" then macro_call = cat('%missing(',dyad_id,',', VAR1, ',', '%str(', branching_logic_clean, ')', ',', VAR2,')');
    else macro_call = cat('%missing(',dyad_id,',', VAR1, ',', '%str( and ', branching_logic_clean, ')', ',', VAR2,')');

    if VAR1 = 'Variable / Field Name' then macro_call = cat( 'ods Excel OPTIONS(SHEET_INTERVAL="now" SHEET_NAME="', dyad_id,' " EMBEDDED_TITLES="yes");' );
    if VAR1 = 'Variable / Field Name' and dyad_id = '10001' then macro_call = cat( 'ods Excel OPTIONS(SHEET_INTERVAL="none" SHEET_NAME="', dyad_id,' " EMBEDDED_TITLES="yes");' );
    call execute(macro_call);
run;
 
options mprint;

 
/*SAS LOG*/
/*ods Excel OPTIONS(SHEET_INTERVAL="now" SHEET_NAME="log" EMBEDDED_TITLES="yes");*/
/*proc printto;run;*/
/*proc document name=mydoc(write);*/
/*                import textfile=test to logfile;run;*/
/*                replay;run;*/
/*quit;*/
/* */

/*ods Excel close;*/

title;
proc print data=work.temp (obs=500); 
/*where VAR1 in ( 'cg_hf_cq_21' -- 'cg_coping_factor_3_q9')*/
run;



/*%macro missing(ID, variable, logic, title);*/

data id_i;
    set raw.iCare4me ;
    where dyad_id = "10001" ;
run;

proc print data= id_i label noobs;
    where missing(cg_ftp1) &logic;
    var dyad_id redcap_event_name redcap_repeat_instrument redcap_repeat_instance cg_ftp1;
    title1 "10001";
    title2 "caregiver_forms";
    title3 "cg_ftp1";
run;

/*%mend;*/

%missing(10001 ,cg_ftp1 ,%str( and redcap_event_name='baseline_arm_1' and cg_consent = 1 and ( redcap_event_name='baseline_arm_1' and cg_consent = 1 and redcap_event_name='baseline_arm_1' or redcap_event_name='baseline_arm_1' and cg_consent = 1 and redcap_event_name='6_month_arm_1' or redcap_event_name='baseline_arm_1' and cg_consent = 1 and),caregiver_forms );
