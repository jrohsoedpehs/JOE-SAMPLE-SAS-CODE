/*USE TO DEBUG MACRO*/
options mprint mlogic symbolgen; 

/*DISPLAY SAS VERSION AND OPERATING SYSTEM*/
%put &sysvlong;
%put &sysscpl;


/*libname raw "Q:\George Demiris\PISCES\data\Raw";*/
/*libname derived "Q:\George Demiris\PISCES\data\Derived";*/
/*footnote "Q:\George Demiris\PISCES\programs\Draft\missing_data_report_Referral Tracking automated.sas";*/
/*options fmtsearch=(raw.referral_formats);*/
/*options nofmterr;*/

/*Import using stat transfer*/
/*original "Q:\George Demiris\PISCES\REDCap Downloads\archive20190506 Referral Tracking data dictionary for missing data report\ReferralTracking_Dictionary.csv"*/
/*converted to "Q:\George Demiris\PISCES\REDCap Downloads\archive20190506 Referral Tracking data dictionary for missing data report\ReferralTracking_Dictionary.sas7bdat"*/

%MACRO missingReport(dictionary, data);
/*FIND A VARIABLE TO EXPLOIT IN THE DICTIONARY*/
/*FIND ALL VARIABLES WITHIN A GIVEN FORM*/
/*EXPLOIT VARIABLE Col2*/
proc print data= &dictionary;
run;

/*USE A DATASET OF PROC CONTENTS TO DISPLAY VARIABLE NAMES AS OBSERVATIONS*/
proc contents data=&data noprint out=cont_out;
run;

/*EXPLOIT THE NAMES VARIABLE WHICH CONTAINS VARIABLE NAMES AS OBSERVATIONS*/
proc print data=cont_out;
run;

/*GET ALL VARIABLES WITH SUFFIX _complete*/
proc sql ;
    select name
    into :complete separated by ' '
    from cont_out
	where lowcase(trim(name)) like "%^_complete" escape '^';
quit;
%put &complete;


/*DELETE THE 1ST ROW OF DATA FROM THE DICTIONARY, WHICH ARE VARIABLE LABELS*/
data work.dictionary;
    set &dictionary;
	if Col2 = "Form Name" then delete;
run;
proc print data=work.dictionary;run;

/*COUNT THE TOTAL NUMBER OF FORMS USING DATA DICTIONARY*/
proc sql;
    select count(distinct Col2)
    into :obs
    from work.dictionary;
quit;
%put &obs;

/*SAVE THE NAME OF EACH FORM AS A MACRO VARIABLE USING DATA DICTIONARY*/
proc sql ;
    select distinct Col2
    into :form1-
    from work.dictionary;
quit;

/*GROUP VARIABLES BY FORM, LOOP UP TO THE TOTAL # OF FORMS AND REMOVE FREE TEXT FIELDS AND HEADERS USING DATA DICTIONARY*/
%do i = 1 %to &obs;
%let logic&i = %str( );
%let vars&i %str( );


/*%do i = 8 %to 8;*/
/*VARIABLES IN FORM i*/
proc sql ;
    select Col1, TRANWRD(TRANWRD(TRANWRD(TRANWRD(Col12,"]"," "),"["," "),""""," "),"'"," ")
/*    select Col1, TRANWRD(  TRANWRD(Col12,"]"," ")  ,"["," ")*/
    into :vars&i separated by ' ', :logic&i separated by ' !'
    from work.dictionary
/*where Col2 in("&&form8");*/
	where Col2 in("&&form&i") and Col11 ne "y" and (Col4 notin("descriptive", "notes") and (Col4 = "text" and Col8 ne "") or 
    Col4 in("yesno","radio","checkbox","file","dropdown"));
quit;
%put &&logic&i;
%put &&vars&i;


/*	GROUP VARIABLES BY FORM SAVE AS TEMP DATASET USING THE SAS DATASET*/
/*data test8;*/
/*    set raw.referral_tracking;*/
/*    keep record_id &vars8 &complete;*/
/*run;*/

/*proc print data=raw.referral_tracking (obs=5);*/
/*    var record_id &vars8 &complete;*/
/*run;*/


%let logicvars = %str( ) &&logic&i;
%put &logicvars;
/*%put &logic8;*/

/*This works just need to align the index for Col12************************************************************************************/
/*PROC PRINT ON VARS WHERE &YVAR NE 0*/

	/*Start Loop for each variable in the form*/
    %local j xvar yvar zvar;

    /*do loop for i.  to count of # of x variables specified in macro call (&x)*/
    %do j=1 %to %sysfunc(countw(&&vars&i));

    /*&xvar will be each variabel specifid in &x*/
	%let xvar=%sysfunc(scan(&&vars&i, &j));
	%let yvar=%sysfunc(scan(&complete, &i));

%if %sysfunc(prxmatch('/!*/',&logicvars)) %then %do;
	%let zvar=%sysfunc(scan(&logicvars, %eval(&j+1), "!"));
%end;
%else %do;
%let zvar=%sysfunc(scan(&logicvars, &j, "!"));
%end;


/*print values in log*/
    %put &j &xvar &yvar &zvar;
	%put &logicvars;

/*        OUTPUT*/
/*        title "&xvar";*/

%if %sysfunc(countw(%quote(&zvar), %str( ) ))>0 %then %do;
        proc print data=&data;
		    var record_id &xvar /*&yvar*/;
			where missing(&xvar) and &yvar ne 0 and &zvar;
        run;
%end;
%else %do;
proc print data=&data;
		    var record_id &xvar /*&yvar*/;
			where missing(&xvar) and &yvar ne 0;
        run;
%end;
%end;
%end;
%mend;
/*%missingReport(raw.ReferralTracking_Dictionary, raw.referral_tracking);*/
