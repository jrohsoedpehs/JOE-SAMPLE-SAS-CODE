libname raw "Q:\George Demiris\PISCES\data\Raw";
libname derived "Q:\George Demiris\PISCES\data\Derived";
footnote "Q:\George Demiris\PISCES\programs\Draft\missing_data_report_Referral Tracking automated.sas";
options fmtsearch=(raw.referral_formats);
options nofmterr;

/*filename test "Q:\George Demiris\PISCES\documents\output\log &sysdate.log";*/
/*proc printto log=test new; run;*/




/*Import using stat transfer*/
/*original "Q:\George Demiris\PISCES\REDCap Downloads\archive20190506 Referral Tracking data dictionary for missing data report\ReferralTracking_Dictionary.csv"*/
/*converted to "Q:\George Demiris\PISCES\REDCap Downloads\archive20190506 Referral Tracking data dictionary for missing data report\ReferralTracking_Dictionary.sas7bdat"*/

/*proc contents data=raw.ReferralTracking_Dictionary vanum;run;*/
/*proc contents data=raw.referral_tracking vanum;run;*/

/*proc print data=raw.ReferralTracking_Dictionary;run;*/
/*proc contents data=raw.referral_tracking out=cont_out noprint;run;*/


/*Rough Missing Data Report*/

%macro loop(codebook, dsn);
data work.dictionary;
    set &codebook;
	if Col2 = "Form Name" then delete;
run;
%let dictionary = work.dictionary;

proc contents data=&dsn out=cont_out noprint;run;

/*Count the total number of forms using data dictionary*/
proc sql noprint;
    select count(distinct Col2)
    into :obs
    from &dictionary;
quit;
/*Save the name of each form as a macro variable using data dictionary*/
proc sql noprint;
    select distinct Col2
    into :form1-
    from &dictionary;
quit;

/*Group variables by form, loop up to the total # of forms and remove free text fields and headers using data dictionary*/
%do i = 1 %to &obs;
/*    Variables in form i*/
    proc sql noprint;
        select Col1, Col12
        into :vars&i separated by ' ', :logic&i separated by ' '
        from &dictionary
/*        where Col2 in("&&form&i");*/
		where Col2 in("&&form&i") and Col11 ne "y" and (Col4 notin("descriptive", "notes") and (Col4 = "text" and Col8 ne "") or 
		    Col4 in("yesno","radio","checkbox","file","dropdown"));

    quit;

    proc sql noprint;
        select name
        into :complete&i separated by ' '
        from cont_out
	      where lowcase(trim(name)) like "%^_complete" escape '^';
    quit;

/*	Group variables by form save as temp dataset using the sas dataset*/
    data test&i.;
        set &dsn;
        /*form&i._nmiss = nmiss(&&vars&i.);*/
        keep record_id &&vars&i. &&complete&i;
    run;



	/*Start Loop for each variable in the form*/
    %local j xvar yvar;
    /*do loop for i.  to count of # of x variables specified in macro call (&x)*/
    %do j=1 %to %sysfunc(countw(&&vars&i.));
    /*&xvar will be each variabel specifid in &x*/
	%let xvar=%sysfunc(scan(&&vars&i., &j));
	%let yvar=%sysfunc(scan(&&complete&i., &i));

    /*print values in log*/
    %put &j &xvar &i &yvar;

    ods Excel OPTIONS(SHEET_INTERVAL="proc" SHEET_NAME="&xvar" EMBEDDED_TITLES="yes");

/*        OUTPUT*/
        title "&xvar";
        proc print data=test&i.;
		    var record_id &xvar &yvar;
			where missing(&xvar) and &yvar ne 0;
        run;
/*        proc freq data=test&i.;*/
/*		    table &yvar;*/
/*        run;*/

    %end;

%end;
%mend;


/*OUTPUT MANY RESULTS ON THE SAME WORKSHEET*/
ods Excel file="Q:\George Demiris\PISCES\documents\output\ Referral_Tracking_missing_data &sysdate..xlsx" ;

/*CREATE WORKSHEET For a group of output on sheet 1*/
%loop(raw.ReferralTracking_Dictionary,raw.referral_tracking);

/*ods Excel OPTIONS(SHEET_INTERVAL="none" SHEET_NAME="SAS Log" EMBEDDED_TITLES="yes");*/
/*title "SAS Log";*/
/*proc printto;run;*/
/*proc document name=mydoc(write);*/
/*    import textfile=test to logfile;run; */
/*	replay;run;*/
/*quit;*/

ods Excel close;

/*proc print data= raw.referral_tracking;run;*/
