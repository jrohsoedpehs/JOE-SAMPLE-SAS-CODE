libname raw "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\REDCap API\delimiters within data";

/* Edit the following line to reflect the full path to your CSV file */
%let csv_file = "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\REDCap API\delimiters within data\api.csv";

OPTIONS nofmterr;

proc format library=raw.api_formats;
	value radio_ 1='Choice 1' 2='Choice 2';
	value checkbox___1_ 0='Unchecked' 1='Checked';
	value checkbox___2_ 0='Unchecked' 1='Checked';
	value field_types_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';

	run;
options fmtsearch=(raw.api_formats);

/*CREATE A COPY OF THE CSV IF IT IS DIFFICULT TO OBTAIN*/
/*OPEN THE CSV AND REPLACE NEWLINE CHARACTERS WITH A SPACE*/
/*INFILE MUST MATCH FILE*/
/*'0A'x, '13'x and '0D'x - ARE SYNTAX FOR ASCII newline (carriage return) characters*/
data _null_;
    infile &csv_file recfm=n sharebuffers;
    file &csv_file recfm=n;
    input a $char1.;
    retain open 0;
/*  This statement toggles the open flag. */
    if a='"' then open=not open;
    if a in ('0D'x '13'x '0A'x) and open then put ' ';
run;

/*COPY INFILE FROM REDCAP MANUAL EXPORT*/
/*EXCLUDE SURVEY TIMESTAMPS*/
/*LIMIT USER RIGHTS TO TAGGED IDENTIFIERS ONLY*/
data raw.api; %let _EFIERR_ = 0;
infile &csv_file  delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;

	informat record_id $500. ;
	informat notes $5000. ;
	informat free_text $500. ;
	informat number best32. ;
	informat date yymmdd10. ;
	informat radio best32. ;
	informat checkbox___1 best32. ;
	informat checkbox___2 best32. ;
	informat field_types_complete best32. ;

	format record_id $500. ;
	format notes $5000. ;
	format free_text $500. ;
	format number best12. ;
	format date yymmdd10. ;
	format radio best12. ;
	format checkbox___1 best12. ;
	format checkbox___2 best12. ;
	format field_types_complete best12. ;

input
	record_id $
	notes $
	free_text $
	number
	date
	radio
	checkbox___1
	checkbox___2
	field_types_complete
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc print data=raw.api;run;
proc contents data=raw.api;run;

data raw.api;
	set raw.api;
	label record_id='Record ID';
	label notes='Notes';
	label free_text='Free text';
	label number='Number';
	label date='Date';
	label radio='Multiple Choice Single Answer';
	label checkbox___1='Checkbox (choice=Choice 1)';
	label checkbox___2='Checkbox (choice=Choice 2)';
	label field_types_complete='Complete?';
	format radio radio_.;
	format checkbox___1 checkbox___1_.;
	format checkbox___2 checkbox___2_.;
	format field_types_complete field_types_complete_.;
run;

proc contents data=raw.api;run;
proc print data=raw.api;run;
