/*REDCAP 9.7.7 NEW*/

/*MACRO VARIABLE FOR PATH*/
%let csv_file = 'PISCES_DATA_NOHDRS_2020-03-25_1311.csv';

/*CREATE FORMATS*/
proc format;
	value $redcap_event_name_ reportable_events_arm_1='Reportable Events' consent_visit_arm_1='Consent Visit' 
		session_1_arm_1='Session 1' session_2_arm_1='Session 2' 
		session_3_arm_1='Session 3' exit_interview_arm_1='Exit Interview';
run;

/*INFILE*/
data work.redcap; %let _EFIERR_ = 0;
infile csv_file delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ;
	informat caregiver_id $500. ;
    format caregiver_id $500. ;
input
	caregiver_id $
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

/*LABELS AND ASSIGN FORMATS*/
data redcap;
	set redcap;
	label caregiver_id='Caregiver ID';
	format redcap_event_name redcap_event_name_.;
run;



/*OLD BEFORE REDCAP 9.7.7*/

/*MACRO - REPLACE EXISTING DATASET WITH IMPORTED DATA*/
%macro removeOldFile(bye); %if %sysfunc(exist(&bye.)) %then %do; proc delete data=&bye.; run; %end; %mend removeOldFile;

/*REDCAP LIBRARY*/
libname redcap 'Q:\George Demiris\PISCES\REDCap Downloads\archive20200213 weekly Report\'; 

/*MACRO CALL 
- REPLACE EXISTING DATASET WITH IMPORTED DATA*/
%removeOldFile(redcap.redcap); 


/*INFILE*/
data REDCAP; %let _EFIERR_ = 0; 
infile 'Q:\George Demiris\PISCES\REDCap Downloads\archive20200213 weekly Report\PISCES_DATA_NOHDRS_2020-02-13_0918.CSV' delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat caregiver_id $500. ;
	format caregiver_id $500. ;

input
		caregiver_id $
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

/*CREATE LABELS*/
data redcap;
	set redcap;
	label caregiver_id='Caregiver ID';
RUN;

/*CREATE FORMATS*/
proc format;
	value $redcap_event_name_ reportable_events_arm_1='Reportable Events' consent_visit_arm_1='Consent Visit' 
		session_1_arm_1='Session 1' session_2_arm_1='Session 2' 
		session_3_arm_1='Session 3' exit_interview_arm_1='Exit Interview';
run;

/*ASSIGN FORMATS*/
data redcap;
	set redcap;
	format redcap_event_name redcap_event_name_.;
run;

/*RENAME DATASET*/
data raw.pisces ; 
set REDCAP; 
run; 


/*SAVE FORMATS*/
proc format library=work.formats cntlout = redcap.pisces_formats; 
run; 
proc format library=raw.pisces_formats cntlin=redcap.pisces_formats; 
run; 


/*CNTLOUT=   Create a SAS data set that stores information about informats or formats. */
/*CNTLIN=    Specify a SAS data set from which PROC FORMAT builds informats or formats.*/
