libname raw "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\REDCap API\delimiters within data";

/* Edit the following line to reflect the full path to your CSV file */
%let csv_file = "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\REDCap API\delimiters within data\api - newline error - Copy.csv";


data api_clean;
    infile &csv_file recfm=n sharebuffers;
    file &csv_file recfm=n;

    input a $char1.;

    retain open 0;
/*  This statement toggles the open flag. */
    if a='"' then open=not open;
    if a='0D'x and open then put ' ';
run;

/*'0A'x - line feed (creates a new data obs)*/
/*'13'x - carriage return (in a paragraph)*/
/*'0D'x - carriage return (in a paragraph/string)*/

proc contents data=api_clean;run;
proc print data=api_clean;run;
