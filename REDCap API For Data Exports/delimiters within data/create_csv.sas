 OPTIONS dlcreatedir;
 LIBNAME data "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\REDCap API\delimiters within data";


filename my_in "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\REDCap API\delimiters within data\api_parameter.txt";
filename my_out "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\REDCap API\delimiters within data\api.csv";
filename status "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\REDCap API\delimiters within data\api_http_status.txt";


%include "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\REDCap API\delimiters within data\project_token.sas";


data _null_ ;
file my_in ;
put "%NRStr(token=)&mytoken%NRStr(&content=record&type=flat&rawOrLabel=raw&format=csv)&";
run;

proc http
in= my_in
out= my_out
headerout = status
url ="https://redcap.nursing.upenn.edu/api/"
method="post";
run;
