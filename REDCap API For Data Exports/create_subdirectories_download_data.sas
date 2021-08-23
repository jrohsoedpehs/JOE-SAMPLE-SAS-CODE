/*ADD API DATA IMPORT TEMPLATE************************************************/
/*SET UP LIBRARIES*/

/*The following creates a SC subdirectory i.e. Q:\Jordana Cohen\BLOCK HFpEF\DSMB\DSMB_AUG2021*/
/*similar to the way we have a DSMB directory*/

/*UPDATE PATH WITH SUBDIRECTORY AS NEEDED*/
%let path = Q:\Jordana Cohen\BLOCK HFpEF;
%let fullPath = &path\DSMB\DSMB_%sysfunc(today(), MONYY7. /*YYMMDDn8*/);

%let test = DSMB_%sysfunc(today(), MONYY7.);
%put &test;
%put &fullpath;

/*Create the monthly folder and standard subdirectories i.e. &path\SC_JUN2021
-If the folders already exist, they will not be over-written or replaced */

data _null_;
/*  set work.directoryData;*/
    v2 = "&path\DSMB";
    fullPath = "&path" || "\DSMB\DSMB_%sysfunc( today(), MONYY7.)";
    out = dcreate("DSMB_%sysfunc( today(), MONYY7.)", v2);

    outarchive = dcreate("archive", fullPath);

    Pathdata =  fullPath || "\data";
    outdata = dcreate("data", fullPath);
    outDerived = dcreate("Derived", Pathdata);
    outRaw = dcreate("Raw", Pathdata);

    Pathdocuments = fullPath || "\documents";
    outdocuments = dcreate("documents", fullPath);
    outbilling = dcreate("billing", Pathdocuments);
    outoutput = dcreate("output", Pathdocuments);
    outprotocol = dcreate("project protocol", Pathdocuments);
    outQA = dcreate("QA", Pathdocuments);
    outReports = dcreate("Reports", Pathdocuments);
    outprocedures = dcreate("scoring procedures", Pathdocuments);

    Pathprograms =  fullPath || "\programs";
    outprograms = dcreate("programs", fullPath);
    outDraft = dcreate("Draft", Pathprograms);
    outFinal = dcreate("Final", Pathprograms);

    outREDCap = dcreate("REDCap Downloads", fullPath);
run;











/*
Description of task

IMPORT BLOCK HFpEF Trial
  
USE REDCap API TO IMPORT DATA FROM REDCAP TO AN EXCEL CSV UNDER 
Q:\Jordana Cohen\BLOCK HFpEF\DSMB\DSMB_mmyyyy\REDCap Downloads\archiveyyyymmdd data import

USING THE FOLLOWING STEPS:

Step 0. Create date stamped library to store export files;

Step 1. Define file names and macro variable for the project-specific token.

Step 2. Request all observations (CONTENT=RECORDS) with one
        row per record (TYPE=FLAT) EXCLUDE ALL IDENTIFIERS EXPECT KEY DATES NEEDED FOR REPORT. 

Step 3. Read .CSV data file into SAS and save it.
    Uses project-specific SAS code generated through the REDCap
    Data Export Tool with a modification (shown below) to the
    first DATA step in the program to work with the REDCap API data.
*/

libname raw "&fullPath\data\Raw";
libname derived "&fullPath\data\Derived";
footnote "SAS Program Stored in: &path\programs\Draft\dsmb_all_in_one.sas";
/*options fmtsearch=();*/
options nofmterr;
/*%put "SAS Program Stored in: &path\programs\Draft\dsmb_all_in_one.sas";*/

/*DOWNLOAD ENGLISH DATASET FROM */
/*https://redcap.med.upenn.edu/redcap_v11.1.1/index.php?pid=24136*/

/*CREATE DATE STAMPED FOLDER IN REDCAP DOWNLOADS TO STORE .CSV AND ASSOCIATED FILES*/
OPTIONS dlcreatedir;
LIBNAME data "&fullPath\REDCap Downloads\archive%sysfunc( today(), YYMMDDn8 ) export data to SAS";


/*CREATE THE FOLLOWING FILES*/
/*EXCEL CSV*/
/*TEXT THAT SAVES API COMMAND*/
/*TEXT FILE THAT SAVES THE API STATUS (SUCCESSFUL YES/NO)*/
filename my_in "&fullPath\REDCap Downloads\archive%sysfunc( today(), YYMMDDn8 ) export data to SAS\BLOCK_HF_pEF_api_request.txt";
filename my_out "&fullPath\REDCap Downloads\archive%sysfunc( today(), YYMMDDn8 ) export data to SAS\BLOCK_HF_pEF.csv";
filename status "&fullPath\REDCap Downloads\archive%sysfunc( today(), YYMMDDn8 ) export data to SAS\FERMIN_http_status.txt";

/*PROJECT TOKEN NEED TO SAVE DATA*/
/*SIMILAR TO A PASSWORD*/
%let mytoken = /*replace with API TOKEN FROM REDCap*/;

/*REQUEST ALL OBSERVATIONS WITH ONE ROW PER RECORD*/
/*
FOR CHECKBOX VARIABLES, USE THE SINGLE REDCAP NAME INSTEAD OF THE 
BINARY FLAGS FOR EACH RESPONSE I.E.

USE 
checklist_bl_2

INSTEAD OF

checklist_bl_2___1,
checklist_bl_2___2,
checklist_bl_2___3,
checklist_bl_2___4,
checklist_bl_2___5,
checklist_bl_2___6,
checklist_bl_2___7,

*/

/*
CONSIDER USING PROC HTTP TO EXPORT DATA DICTIONARY AS DATASET
USE THIS DATASET TO CREATE A MACRO VARIABLE WITH meta data variables WITH commas
AS DELIMITERS
THIS CAN PREVENT MANUALLY WRITING OUT THE FIELD NAMES ON LINE 143 BELOW
*/

data _null_ ;
file my_in ;
/*EXPORT ALL DATA*/
/*put "%NRStr(token=)&mytoken%NRStr(&content=record)%NRStr(&type=flat&format=csv)&";*/

/*EXCLUDED UNNECESSARY IDENTIFIERS BY EXPLICITLY LISTING VARIABLES TO INCLUDE*/
/*ORDER MATTERS! USE VARNUM OR ORDER OF APPEARANCE IN CODEBOOK*/
put "%NRStr(token=)&mytoken%NRStr(&content=record)%NRStr(&type=flat&format=csv&fields=
record_id,
redcap_event_name,
redcap_repeat_instrument,
redcap_repeat_instance,
checklist_bl,
checklist_bl_2,
checklist_complete_baseline,
lost_to_followup_complete
)&";
run;


/*PROC HTTP CALL*/
/*EVERYTHING EXCEPT HEADEROUT= IS REQUIRED*/
proc http
in= my_in
out= my_out
headerout = status
/*url ="https://redcap.nursing.upenn.edu/api/"*/
/*LINK FOR PENN MEDICINE REDCAP IS ...*/
/*LINK FOR PENN NURSING REDCAP IS https://redcap.nursing.upenn.edu/api/*/
url ="https://redcap.med.upenn.edu/api/"
method="post";
run;

/*CREATE MACRO VARIABLE FOR EXCEL CSV*/
%let csv_file = "&fullPath\REDCap Downloads\archive%sysfunc( today(), YYMMDDn8 ) export data to SAS\BLOCK_HF_pEF.csv";


/*GOAL*/
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
    infile &csv_file recfm=n sharebuffers;
    file &csv_file recfm=n;
/*OPEN THE CSV, READ EACH CHARACTER LINE BY LINE*/
    input a $char1.;
    retain open 0;
/*CLOSE CSV WHEN THERE ARE NO MORE CHARACTERS*/
    if a='"' then open=not open;
/*REPLACE/OVERWRITE NEWLINE CHARACTERS (ASCII) WITH A SPACE*/
    if a in ('0D'x '13'x /*'12'x*/ '0A'x /*'10'x '8'x '27'x '9'x '11'x*/) and open then put ' ';
/*
THE MOST COMMON NON PRINTABLE (CONTROL) CHARACTERS ARE
    SOURCE:
        https://documentation.sas.com/doc/en/engelref/2.8/p1orlsbqj20nirn1p17o8j1zsyti.htm
        https://www.lexjansen.com/pharmasug/2010/CC/CC13.pdf

carriage return = '0D'x 
carriage return in a quote ('\r') = '13'x
form feed = '12'x
line feed = '0A'x
line feed = '10'x
backspace = '8'x
escape = '27'x
horizontal tab = '9'x
vertical tab = '11'x
    */
run;
OPTIONS nofmterr;



/*SAS IMPORT CODE*/
OPTIONS nofmterr;

proc format library = raw.BLOCK_HFpEF_Trial_formats;
    value $redcap_event_name_ 'general_study_form_arm_1'='General Study Forms' 'screening_visit_0_arm_1'='Screening: Visit 0' 
        'baseline_visit_1_arm_1'='Baseline: Visit 1' 'phase_a_visit_2_arm_1'='Phase A: Visit 2' 
        'phase_b_visit_3_arm_1'='Phase B: Visit 3';
    value $redcap_repeat_instrument_ 'deviations_and_notes_to_file'='Deviations and Notes to File' 'adverse_events'='Adverse Events';
    value checklist_bl___1_ 0='Unchecked' 1='Checked';
    value checklist_bl___2_ 0='Unchecked' 1='Checked';
    run;
options fmtsearch = (raw.BLOCK_HFpEF_Trial_formats);

data work.redcap; %let _EFIERR_ = 0;
infile &csv_file  delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2;

    informat record_id $500. ;
    informat redcap_event_name $500. ;
    informat redcap_repeat_instrument $500. ;
    informat redcap_repeat_instance best32. ;
    informat checklist_bl___1 best32. ;
    informat checklist_bl___2 best32. ;

run;

/*resaves temporary data as permanent*/
data raw.BLOCK_HFpEF_Trial;
    set redcap;
run;


/*reports*/
