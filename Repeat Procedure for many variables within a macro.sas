/*Loop the same procedure for many variables within a macro*/

%macro excel(x);

/*Start Excel*/
ods Excel file="Q:\Julio Chirinos\Knock_out_Summer_2016\documents\output\Northwestern Missing Data Report &sysdate..xlsx" ;
ods Excel OPTIONS(SHEET_INTERVAL="none" SHEET_NAME="FORM_EL" EMBEDDED_TITLES="yes");

/*Start Loop*/
%local i xvar;
/*do loop for i.  to count of # of x variables specified in macro call (&x)*/
%do i=1 %to %sysfunc(countw(&x));
/*&xvar will be each variabel specifid in &x*/
	%let xvar=%sysfunc(scan(&x, &i));
/*print values in log*/
%put &i &xvar;

/*proc print*/
title "&xvar";
proc print data= derived.test label;
    var study_id redcap_event_name &xvar;
    where missing(&xvar) and FORM_EL_nmiss<76; 
run;

/*End loop*/
%end;
ods Excel close;
%mend;
%excel(&Form_El_3);
