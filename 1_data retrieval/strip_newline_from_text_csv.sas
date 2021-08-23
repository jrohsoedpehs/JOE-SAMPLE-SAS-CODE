libname raw "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\REDCap API\delimiters within data";

/* Edit the following line to reflect the full path to your CSV file */
%let csv_file = "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\REDCap API\delimiters within data\api - newline error - Copy.csv";


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
    if a in ('0D'x '13'x '0A'x) and open then put ' ';
run;
OPTIONS nofmterr;


proc contents data=api_clean;run;
proc print data=api_clean;run;
