/*Referral Tracking Form Missing Data*/
ods Excel file="path\output\filename &sysdate..xlsx" ;
ods Excel OPTIONS(SHEET_INTERVAL="none" SHEET_NAME="Tab Name" EMBEDDED_TITLES="yes");

%macro missing(var, logic);
proc print data=derived.demo_phase1 ;
where missing(&var) &logic;
var record_id &var;
title "&var";
run;
%mend;

%missing(var, %str(logic));


ods Excel close;
