options mprint mlogic symbolgen; 

%put &sysvlong;
%put &sysscpl;


libname raw "Q:\George Demiris\PISCES\data\Raw";
libname derived "Q:\George Demiris\PISCES\data\Derived";
footnote "Q:\George Demiris\PISCES\programs\Draft\missing_data_report_Referral Tracking automated.sas";
options fmtsearch=(raw.referral_formats);
options nofmterr;

/*Import using stat transfer*/
/*original "Q:\George Demiris\PISCES\REDCap Downloads\archive20190506 Referral Tracking data dictionary for missing data report\ReferralTracking_Dictionary.csv"*/
/*converted to "Q:\George Demiris\PISCES\REDCap Downloads\archive20190506 Referral Tracking data dictionary for missing data report\ReferralTracking_Dictionary.sas7bdat"*/


/*FIND A VARIABLE TO EXPLOIT IN THE DICTIONARY*/
/*FIND ALL VARIABLES WITHIN A GIVEN FORM*/
/*EXPLOIT VARIABLE Col2*/
proc print data= raw.ReferralTracking_Dictionary;
run;

/*DELETE THE 1ST ROW OF DATA FROM THE DICTIONARY, WHICH ARE VARIABLE LABELS*/
data work.dictionary;
    set raw.ReferralTracking_Dictionary;
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
/*%do i = 1 %to &obs;*/
/*%do i = 8 %to 8;*/
/*VARIABLES IN FORM i*/
proc sql ;
    select Col1, TRANWRD(TRANWRD(TRANWRD(TRANWRD(Col12,"]"," "),"["," "),""""," "),"'"," ")
/*    select Col1, TRANWRD(  TRANWRD(Col12,"]"," ")  ,"["," ")*/
    into :vars8 separated by ' ', :logic8 separated by ' !'
    from work.dictionary
/*where Col2 in("&&form8");*/
	where Col2 in("&&form8") and Col11 ne "y" and (Col4 notin("descriptive", "notes") and (Col4 = "text" and Col8 ne "") or 
    Col4 in("yesno","radio","checkbox","file","dropdown"));
quit;
%put &logic8;
%put &vars8;

/*USE A DATASET OF PROC CONTENTS TO DISPLAY VARIABLE NAMES AS OBSERVATIONS*/
proc contents data=raw.referral_tracking noprint out=cont_out;
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

/*	GROUP VARIABLES BY FORM SAVE AS TEMP DATASET USING THE SAS DATASET*/
/*data test8;*/
/*    set raw.referral_tracking;*/
/*    keep record_id &vars8 &complete;*/
/*run;*/

/*proc print data=raw.referral_tracking (obs=5);*/
/*    var record_id &vars8 &complete;*/
/*run;*/




/*PROC PRINT ON VARS WHERE &YVAR NE 0*/
%macro loop1();

	/*Start Loop for each variable in the form*/
    %local j xvar yvar zvar;

    /*do loop for i.  to count of # of x variables specified in macro call (&x)*/
    %do j=1 %to %sysfunc(countw(&logic8));

    /*&xvar will be each variabel specifid in &x*/
	%let xvar=%sysfunc(scan(&vars8, &j));
	%let yvar=%sysfunc(scan(&complete, 8));

    /*print values in log*/
    %put &j &xvar &yvar ;

/*        OUTPUT*/
        title "&xvar";
        proc print data=raw.referral_tracking;
		    var record_id &xvar &yvar;
			where missing(&xvar) and &yvar ne 0;
        run;

    %end;
%mend;
%loop1();



%let logicvars = %str( ) &logic8;
%put &logicvars;
/*%put &logic8;*/

/*This works just need to align the index for Col12************************************************************************************/
/*PROC PRINT ON VARS WHERE &YVAR NE 0*/
%macro loop();

	/*Start Loop for each variable in the form*/
    %local j xvar yvar zvar;

    /*do loop for i.  to count of # of x variables specified in macro call (&x)*/
    %do j=1 %to %sysfunc(countw(&vars8));

    /*&xvar will be each variabel specifid in &x*/
	%let xvar=%sysfunc(scan(&vars8, &j));
	%let yvar=%sysfunc(scan(&complete, 8));

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
        proc print data=raw.referral_tracking;
		    var record_id &xvar &yvar;
			where missing(&xvar) and &yvar ne 0 and &zvar;
        run;
%end;
%else %do;
proc print data=raw.referral_tracking;
		    var record_id &xvar &yvar;
			where missing(&xvar) and &yvar ne 0;
        run;
%end;
    %end;
%mend;
%loop();








/*PROC PRINT ON VARS WHERE &YVAR NE 0 AND &ZVAR IN WHERE*/
%macro loop2();

/*do loop for i.  to count of # of x variables specified in macro call (&x)*/
/*%do j=1 %to %sysfunc(countw(%quote(&vars8), %str( ) ));*/
/*&xvar will be each variabel specifid in &x*/
/*%let xvar=%sysfunc(scan(&logic8, &j)); */
/*%if %sysfunc(countw(%quote(&logic8), %str( ) ))>0 %then %do;*/



	/*Start Loop for each variable in the form*/
    %local j xvar yvar zvar;

    /*do loop for i.  to count of # of x variables specified in macro call (&x)*/
/*    %do j=1 %to %sysfunc(countw(&vars8));*/
/*    %do j=1 %to %sysfunc(countw(%quote(&logic8), %str( ) ));*/

    /*&xvar will be each variabel specifid in &x*/
/*	%let xvar=%sysfunc(scan(&vars8, &j));*/
/*	%let yvar=%sysfunc(scan(&complete, 8));*/
	%let zvar=%qsysfunc(scan(&logic8, %eval(&j+1), "|"));

/*    %if %sysfunc(countw(%quote(&logic8), %str( ) ))>1 %then %do;*/


	/*create macro variables i and xvar*/
/*%local i xvar;*/

/*do loop for i.  to count of # of x variables specified in macro call (&x)*/
 %do j=1 %to %sysfunc(countw(%quote(&logic8), %str( ) ));
/*&xvar will be each variabel specifid in &x*/
%let xvar=%sysfunc(scan(&vars8, &j));
%let yvar=%sysfunc(scan(&complete, 8));
%let zvar=%sysfunc(scan(&logic8, &j, "|")); 
%if %sysfunc(countw(%quote(&zvar), %str( ) ))>0 %then %do;

/*type operations that you would perform on nonmissing values here**/
%put &j &xvar &yvar &zvar ;

%end;



/*        OUTPUT*/
/*        title "&xvar";*/
/*        proc print data=raw.referral_tracking;*/
/*		    var record_id &xvar &yvar;*/
/*			where missing(&xvar) and &yvar ne 0 and &zvar;*/
/*        run;*/

/*		%words(&zvar)*/

%end;
%mend;
%loop2();
