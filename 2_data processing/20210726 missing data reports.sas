libname raw "Q:\Anne Cappola\R61_2019\data\Raw";
libname derived "Q:\Anne Cappola\R61_2019\data\Derived";

footnote "SAS Program Stored in: Q:\Anne Cappola\R61_2019\programs\Draft\adverse_events_missing.sas";

/*SAVE THE SAS LOG TO THE FOLLOWING TEXT FILE*/
/*filename test 'Q:\Anne Cappola\R61_2019\documents\output\adverse_events_missing Log &sysdate..log';*/
/*proc printto log=test new;*/
/*run;*/

/*Log with macro debugging options turned on */
/*options mprint mlogic symbolgen; */


/*FORMATS*/
options fmtsearch=(raw.adv_events_formats);
options nofmterr;

/*Preview Data*/
proc contents data=raw.adv_events varnum; run;
proc print data= raw.adv_events (obs=5) label noobs; run;

/*GOAL REPEAT THE FOLLOWING PROC PRINT FOR ALL VARIABLES IN THE MAIN SURVEY*/
proc print data= raw.adv_events label noobs;
    where study_id = "R-001" and missing(ae_category) and adverse_events_complete not in (. , 0);
    var study_id redcap_repeat_instrument redcap_repeat_instance ae_category;
/*    title1 "R-001";*/
/*    title2 "Adverse Events";*/
/*    title3 "severity";*/
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
/*;*/
/*CHECK THAT THE DATASET HAS 3 FIELDS*/
/*proc contents data= macro_variables; run;*/
/*proc print data=macro_variables; run;*/







/*IMPORT AE DATA DICTIONARY*/
/*https://redcap.nursing.upenn.edu/redcap_v11.1.1/Design/data_dictionary_upload.php?pid=1501*/
PROC IMPORT OUT= raw.ae_dictionary
            DATAFILE= "C:\Users\josephrh\Downloads\HFDOT3HFAdverseEvents_DataDictionary_2021-07-30.csv"
            DBMS=CSV REPLACE;
*     GUESSINGROWS = 32767; /*avoids truncation by checking x rows for format vs default 20*/
     GETNAMES=no
;
     DATAROW=1; /*read data starting at row 2*/
RUN;

proc contents data=raw.ae_dictionary varnum; run;
proc print data=raw.ae_dictionary; run;

data work.dictionary;
    set raw.ae_dictionary
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
/*DELETE THE 1ST ROW OF DATA FROM THE DICTIONARY, WHICH ARE VARIABLE LABELS*/
/*    if Form_Name = "Form Name" then delete;*/
/*    branching_logic_clean = TRANWRD(TRANWRD(TRANWRD(TRANWRD(Branching_Logic__Show_field_onl,"]"," "),"["," "),""""," "),"'"," ");*/

    if VAR12 ne "" then 
    do;
        branching_logic_clean = TRANWRD(VAR12,"]","");
        branching_logic_clean = TRANWRD(branching_logic_clean,"[","");
        branching_logic_clean = TRANWRD(branching_logic_clean,"""","");
        branching_logic_clean = TRANWRD(branching_logic_clean,"'","");
        branching_logic_clean = TRANWRD(branching_logic_clean, "<>"," ne . ");
        branching_logic_clean = TRANWRD(branching_logic_clean, "<>"," ne . ");
    end;

run;
proc contents data= work.dictionary;run;
/*QA FIELD TYPES ARE "text" "yesno","radio","checkbox","file","dropdown"*/
proc freq data=work.dictionary;
    tables VAR4;
run;

/*QA FOLLOWING CHARACTERS ARE STRIPPED FROM branching_logic_clean*/
/*[   ] "" '*/
proc freq data=work.dictionary;
    tables branching_logic_clean * VAR12 / list missing;
run;


proc print data=work.dictionary; run;









/*GENERATES A LIST OF ALL study_ids*/
proc sql /*noprint*/;
select distinct study_id
into :name_list separated by " " from raw.adv_events;
quit;
/*VIEW THE LIST IN THE LOG*/
%put &name_list;
/*R-001 R-003 R-004 R-005*/

/*proc freq with output on ids*/

/*IDS*/
data IDS;
    length study_id$100;
    infile datalines delimiter='|';
    input study_id$;
    datalines;  
R-001
R-003
R-004 
R-005
;
proc contents data= IDS; run;
proc print data=IDS; run;


/*CARTESIAN PRODUCT BETWEEN IDS AND VARIABLES*/
/*N*M OBS*/
/*10 OBS * 4 OBS = 40 OBS TOTAL*/

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
proc contents data= work.CartDataStep;run;
proc print data=work.CartDataStep;run;

/*SORT BY study_id*/
proc sort data=work.CartDataStep;
    by study_id;
run;


%macro missing(ID, variable, logic, title);

data id_i;
    set raw.adv_events ;
    where study_id = "&ID" ;
run;

proc print data= id_i label noobs;
    where missing(&variable) &logic;
    var study_id redcap_repeat_instrument redcap_repeat_instance &variable;
    title1 "&ID";
    title2 "&title";
    title3 "&variable";
run;

%mend;

/*QA missing() on R-001*/
%missing(R-001, ae_category, %str( and adverse_events_complete not in (. , 0)), Adverse Events);


/*CREATE EXCEL FILE*/
ods Excel file="Q:\Anne Cappola\R61_2019\documents\output\ Adverse Events Missing Data Report &sysdate..xlsx" ;

/*MISSING REPORT R-001*/
/*data _null_;*/
data work.temp;
    set work.CartDataStep;
/*    macro_call = cats( '%sample(', var1, ',' var2, ')' );*/
/*    macro_call = cats('%missing(',study_id,',', variable, ',', '%str(', logic, ')', ',', title,')');*/
    if VAR12 = "" then macro_call = cats('%missing(',study_id,',', VAR1, ',', '%str(', branching_logic_clean, ')', ',', VAR2,')');
    else macro_call = cats('%missing(',study_id,',', VAR1, ',', '%str( and ', branching_logic_clean, ')', ',', VAR2,')');

    if VAR1 = 'Variable / Field Name' then macro_call = cats( 'ods Excel OPTIONS(SHEET_INTERVAL="now" SHEET_NAME="', study_id,' " EMBEDDED_TITLES="yes");' );
    if VAR1 = 'Variable / Field Name' and study_id = 'R-001' then macro_call = cats( 'ods Excel OPTIONS(SHEET_INTERVAL="none" SHEET_NAME="', study_id,' " EMBEDDED_TITLES="yes");' );
    call execute(macro_call);
run;
 

 
/*SAS LOG*/
/*ods Excel OPTIONS(SHEET_INTERVAL="now" SHEET_NAME="log" EMBEDDED_TITLES="yes");*/
/*proc printto;run;*/
/*proc document name=mydoc(write);*/
/*                import textfile=test to logfile;run;*/
/*                replay;run;*/
/*quit;*/
/* */

ods Excel close;
proc print data=work.temp; run;


VAR12 = "" then /*no and*/
else /*and*/
