libname raw "Q:\George Demiris\PISCES\data\Raw";
libname derived "Q:\George Demiris\PISCES\data\Derived";
footnote "SAS Program Stored in: Q:\George Demiris\PISCES\programs\Draft\API_REDCap_Data_Import_PISCES.sas";
/*options fmtsearch=();*/
options nofmterr;

/******************************************************************************
Description of task

APPLICATION PROGRAMMING INTERFACE(API)  

REDCAP API LETS REDCAP AND STATISTICAL PROGRAMS TALK TO EACH OTHER TO 
PERFORM DATA EXPORTS


USE REDCap API TO IMPORT DATA FROM REDCAP TO AN EXCEL CSV UNDER 
Q:\George Demiris\PISCES\REDCap Downloads\archiveyyyymmdd data import

USING THE FOLLOWING STEPS:

Step 0. Create date stamped library to store export files;

Step 1. Define file names and macro variable for the project-specific token.

Step 2. Request all observations (CONTENT=RECORDS) with one
        row per record (TYPE=FLAT). Note: Obtain your site-specific 
        url from your local REDCap support team.

Step 3. Read .CSV data file into SAS and save it.
    Uses project-specific SAS code generated through the REDCap
    Data Export Tool with a modification (shown below) to the
    first DATA step in the program to work with the REDCap 
     data.

******************************************************************************/
/*LOAD TOKEN*/
/*TOKEN IS SEPARATE SINCE IT CAN BE USED TO ACCESS DATA */
/*VIA REDCAP WITHOUT A PASSWORD*/
/*%include ;*/
%let mytoken = /*REPLACE WITH API TOKEN FROM REDCAP*/;

/*SET SUBDIRECTORY*/
%let path= ;


/*%macro api(project, key);*/
OPTIONS dlcreatedir;
LIBNAME data "Q:\George Demiris\PISCES\REDCap Downloads\archive%sysfunc( today(), YYMMDDn8 ) export data to SAS";

filename my_in "&path\REDCap Downloads\archive%sysfunc( today(), YYMMDDn8) export data to SAS\project._api_parameter.txt";
filename my_out "&path\REDCap Downloads\archive%sysfunc( today(), YYMMDDn8) export data to SAS\project..csv";
filename status "&path\REDCap Downloads\archive%sysfunc( today(), YYMMDDn8) export data to SAS\project._http_status.txt";
data _null_ ;
file my_in ;
/*put "%NRStr(token=)&mytoken%NRStr(&content=record)%NRStr(&type=flat&format=csv&csvDelimiter=|)&";*/
/*CREATE STANDARD CSV EXPORT OF ALL RECORDS FOR ALL DEIDENTIFIED VARIABLES*/
put "%NRStr(token=)&mytoken%NRStr(&content=record)%NRStr(&type=flat&format=csv)&";

/*EXPORT SPECIFIC VARIABLES*/
/*put "%NRStr(token=)&mytoken%NRStr(&content=record)%NRStr(&type=flat&format=csv&fields=caregiver_id,redcap_event_name,interventionist,caregiver_id_complete,datetime_seconds_2)&";*/
run;

proc http
in= my_in
out= my_out
headerout = status
url ="https://redcap.nursing.upenn.edu/api/"
method="post";
run;

/*%mend;*/
