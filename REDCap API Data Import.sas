/*****************************************************************
Step 0. Create date stamped library to store export files;
*******************************************************************/

OPTIONS dlcreatedir;
LIBNAME data "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\data\raw\archive%sysfunc( today(), YYMMDDn8 )";


/*****************************************************************
Step 1. Define file names and macro variable for the
project-specific token.
*******************************************************************/

*** Text file for API parameters that the define the request sent to
REDCap API. Will be created in a DATA step. Extension can be .csv,
.txt, .dat ***;
filename my_in "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\data\raw\archive%sysfunc( today(), YYMMDDn8 )\API Raw Request Parameters.txt";

*** .CSV output file to contain the exported data ***;
filename my_out "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\data\raw\archive%sysfunc( today(), YYMMDDn8 )\API Data Export.csv";

*** Output file to contain PROC HTTP status information returned from
REDCap API (this is optional) ***;
/*200 is OK*/
/*404 is ERROR*/
filename status "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\data\raw\archive%sysfunc( today(), YYMMDDn8 )\API HTTP status.txt";

*** Project- and user-specific token obtained from REDCap ***;
%let mytoken = CD6218549301F0D0A413BC00ABC7F8D6;

/**********************************************************
Step 2. Request all observations (CONTENT=RECORDS) with one
row per record (TYPE=FLAT). Note: Obtain your site-specific
url from your local REDCap support team.
******************************************************/

*** Create the text file to hold the API parameters. ***;

data _null_ ;
file my_in ;
put "%NRStr(token=)&mytoken%NRStr(&content=record&type=flat&format=csv)&";
run;

/*&fields=record_id*/
/*&records=1,2,3*/
/*&rawOrLabel=raw*/
/*&rawOrLabelHeaders=raw*/
/*&exportCheckboxLabel=false*/
/*&exportSurveyFields=false*/
/*&exportDataAccessGroups=false*/
/*&returnFormat:csv*/

*** PROC HTTP call. Everything except HEADEROUT= is required. ***;

proc http
in= my_in
out= my_out
headerout = status
/*url ="https://redcap.mysite.org/api/"*/
url ="https://redcap.nursing.upenn.edu/api/"
method="post";
run;

/**********************************************************
Step 3. Read .CSV data file into SAS and save it.
Uses project-specific SAS code generated through the REDCap
Data Export Tool with a modification (shown below) to the
first DATA step in the program to work with the REDCap
API data.
*********************************************************/

*** Code copied from the REDCap-generated SAS program
(this is optional, may use PROC IMPORT or a DATA step) ***;
*** Change INFILE name to data named in PROC HTTP OUT = ***;
*** Change FIRSTOBS=1 to FIRSTOBS=2 to indicate that
a header row exists ***;
/*<lines omitted>*/

/*data REDCAP; %let _EFIERR_ = 0;*/
/*infile my_out delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;*/
/*run;*/
/*run; quit;*/

*** Save as a permanent SAS data set ***;
/*proc contents data= redcap varnum;*/
/*run;*/
/*proc print data= redcap;*/
/*run;*/
/*libname raw "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\data\raw";*/
/*data raw.API_import;*/
/*set redcap;*/
/*run;*/
